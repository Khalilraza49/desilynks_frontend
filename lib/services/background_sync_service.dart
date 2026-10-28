import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../core/constants/app_strings.dart';
import '../models/chat_model.dart';
import '../models/notification_model.dart';
import 'api/api_endpoints.dart';
import 'awesome_notification_service.dart';

/// Top-level background entry point executed when the background service starts.
/// Operates independently of the main UI thread to receive real-time Socket.IO events
/// and poll REST APIs without requiring Google/Firebase services.
@pragma('vm:entry-point')
Future<void> onBackgroundServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications display engine for background isolate
  await AwesomeNotificationService.instance.initialize();

  developer.log(
    'BackgroundSyncService started.',
    name: 'BackgroundSyncService',
  );

  // Load stored credentials
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString(AppStrings.keyUserToken);
  String? userJson = prefs.getString(AppStrings.keyUserData);

  String? currentUserId;
  if (userJson != null && userJson.isNotEmpty) {
    try {
      final userMap = jsonDecode(userJson);
      currentUserId = userMap['id']?.toString();
    } catch (_) {}
  }

  socket_io.Socket? chatSocket;
  socket_io.Socket? notifSocket;

  int lastNotifUnreadCount = prefs.getInt('bg_last_notif_unread') ?? -1;
  int lastChatUnreadCount = prefs.getInt('bg_last_chat_unread') ?? -1;

  void showNotificationDirect(NotificationModel notif) {
    AwesomeNotificationService.instance.showNotification(notif);
  }

  void setupSockets() {
    final curToken = token;
    final uid = currentUserId;
    if (curToken == null || curToken.isEmpty) return;

    final String rawToken = curToken.startsWith('Bearer ')
        ? curToken.substring(7).trim()
        : curToken.trim();

    final String base = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;

    // 1. Notification Socket (root namespace)
    try {
      notifSocket = socket_io.io(
        base,
        socket_io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setAuth({
              'token': rawToken,
              'authorization': 'Bearer $rawToken',
              if (uid != null) 'userId': uid,
            })
            .setQuery({'token': rawToken, if (uid != null) 'userId': uid})
            .enableReconnection()
            .build(),
      );

      notifSocket?.onConnect((_) {
        developer.log(
          'Background notif socket connected',
          name: 'BackgroundSync',
        );
        if (uid != null && uid.isNotEmpty) {
          notifSocket?.emit('join', 'user:$uid');
          notifSocket?.emit('joinRoom', 'user:$uid');
        }
      });

      void handleNotifData(dynamic data) {
        try {
          if (data is Map) {
            final map = Map<String, dynamic>.from(data);
            final inner =
                map.containsKey('notification') && map['notification'] is Map
                ? Map<String, dynamic>.from(map['notification'])
                : map;
            final notif = NotificationModel.fromJson(inner);
            showNotificationDirect(notif);
          }
        } catch (e) {
          developer.log(
            'Background notif parse error: $e',
            name: 'BackgroundSync',
          );
        }
      }

      notifSocket?.on('newNotification', handleNotifData);
      notifSocket?.on('notification', handleNotifData);
      notifSocket?.connect();
    } catch (e) {
      developer.log(
        'Error creating bg notif socket: $e',
        name: 'BackgroundSync',
      );
    }

    // 2. Chat Socket (/chat namespace)
    try {
      final chatUrl = '$base${ApiEndpoints.chatSocketNamespace}';
      chatSocket = socket_io.io(
        chatUrl,
        socket_io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setAuth({'token': rawToken})
            .enableReconnection()
            .build(),
      );

      chatSocket?.onConnect((_) {
        developer.log(
          'Background chat socket connected',
          name: 'BackgroundSync',
        );
      });

      chatSocket?.on('newMessage', (data) {
        try {
          if (data is Map) {
            final dataMap = Map<String, dynamic>.from(data);
            final rawMessage = dataMap['message'];
            if (rawMessage is Map) {
              final msgMap = Map<String, dynamic>.from(rawMessage);
              final msg = ChatMessageModel.fromJson(msgMap, currentUserId: uid);
              if (!msg.isMe) {
                final sender = msg.sender;
                final senderName =
                    (sender != null && sender.fullName.trim().isNotEmpty)
                    ? sender.fullName.trim()
                    : 'New Message';
                final notif = NotificationModel(
                  id: msg.id,
                  type: NotificationType.chatMessage,
                  title: senderName,
                  body: msg.content.isNotEmpty
                      ? msg.content
                      : 'Sent an attachment',
                  createdAt: msg.createdAt,
                  isRead: false,
                  actorId: msg.senderId,
                  actor: sender,
                  data: {
                    'conversationId':
                        dataMap['conversationId']?.toString() ?? '',
                    'chatId': dataMap['conversationId']?.toString() ?? '',
                  },
                );
                showNotificationDirect(notif);
              }
            }
          }
        } catch (e) {
          developer.log(
            'Background chat parse error: $e',
            name: 'BackgroundSync',
          );
        }
      });

      chatSocket?.connect();
    } catch (e) {
      developer.log(
        'Error creating bg chat socket: $e',
        name: 'BackgroundSync',
      );
    }
  }

  // Periodic REST API Fallback Poller (every 30 seconds)
  // Ensures background notifications still arrive even if WebSockets are temporarily idle
  Future<void> pollRestApis() async {
    final curToken = prefs.getString(AppStrings.keyUserToken);
    if (curToken == null || curToken.isEmpty) return;

    final String authHeader = curToken.startsWith('Bearer ')
        ? curToken
        : 'Bearer $curToken';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': authHeader,
    };

    final String base = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;

    // 1. Check Notifications Unread Count
    try {
      final notifRes = await http.get(
        Uri.parse('$base${ApiEndpoints.notificationsUnreadCountEndpoint}'),
        headers: headers,
      );
      if (notifRes.statusCode == 200) {
        final body = jsonDecode(notifRes.body);
        final count = (body['count'] is num)
            ? (body['count'] as num).toInt()
            : 0;
        if (lastNotifUnreadCount != -1 && count > lastNotifUnreadCount) {
          // Fetch the latest unread notification to display its content
          final listRes = await http.get(
            Uri.parse(
              '$base${ApiEndpoints.notificationsEndpoint}?isRead=false&limit=1',
            ),
            headers: headers,
          );
          if (listRes.statusCode == 200) {
            final listBody = jsonDecode(listRes.body);
            final List items = listBody['data'] ?? [];
            if (items.isNotEmpty) {
              final latest = NotificationModel.fromJson(
                Map<String, dynamic>.from(items.first),
              );
              showNotificationDirect(latest);
            }
          }
        }
        lastNotifUnreadCount = count;
        await prefs.setInt('bg_last_notif_unread', count);
      }
    } catch (e) {
      developer.log('Background notif poll error: $e', name: 'BackgroundSync');
    }

    // 2. Check Chat Unread Count
    try {
      final chatRes = await http.get(
        Uri.parse('$base${ApiEndpoints.chatUnreadCountEndpoint}'),
        headers: headers,
      );
      if (chatRes.statusCode == 200) {
        final body = jsonDecode(chatRes.body);
        final count = (body['count'] is num)
            ? (body['count'] as num).toInt()
            : 0;
        if (lastChatUnreadCount != -1 && count > lastChatUnreadCount) {
          // Fetch the latest conversation with new message
          final convRes = await http.get(
            Uri.parse('$base${ApiEndpoints.chatConversationsEndpoint}'),
            headers: headers,
          );
          if (convRes.statusCode == 200) {
            final convBody = jsonDecode(convRes.body);
            final List items = convBody['data'] ?? [];
            if (items.isNotEmpty) {
              final first = Map<String, dynamic>.from(items.first);
              final otherUser = first['otherParticipant'] is Map
                  ? Map<String, dynamic>.from(first['otherParticipant'])
                  : null;
              final String name = otherUser != null
                  ? '${otherUser['firstName'] ?? ''} ${otherUser['lastName'] ?? ''}'
                        .trim()
                  : 'New Message';
              final lastMsg = first['lastMessage'] is Map
                  ? Map<String, dynamic>.from(first['lastMessage'])
                  : null;
              final content =
                  lastMsg?['content']?.toString() ?? 'You have a new message';

              showNotificationDirect(
                NotificationModel(
                  id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
                  type: NotificationType.chatMessage,
                  title: name.isNotEmpty ? name : 'New Message',
                  body: content,
                  createdAt: DateTime.now(),
                  isRead: false,
                  data: {'conversationId': first['id']?.toString() ?? ''},
                ),
              );
            }
          }
        }
        lastChatUnreadCount = count;
        await prefs.setInt('bg_last_chat_unread', count);
      }
    } catch (e) {
      developer.log('Background chat poll error: $e', name: 'BackgroundSync');
    }
  }

  // Initial socket setup
  setupSockets();

  // Run periodic REST fallback check every 30 seconds
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    await pollRestApis();
  });

  // Handle service control commands
  service.on('stopService').listen((event) {
    notifSocket?.disconnect();
    notifSocket?.dispose();
    chatSocket?.disconnect();
    chatSocket?.dispose();
    service.stopSelf();
  });

  service.on('updateToken').listen((event) {
    if (event != null && event['token'] != null) {
      token = event['token'].toString();
      currentUserId = event['userId']?.toString();
      notifSocket?.disconnect();
      chatSocket?.disconnect();
      setupSockets();
    }
  });
}

/// Helper singleton service to initialize and control the background sync service
class BackgroundSyncService {
  BackgroundSyncService._();
  static final BackgroundSyncService instance = BackgroundSyncService._();

  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> initialize() async {
    try {
      await _service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onBackgroundServiceStart,
          autoStart: true,
          isForegroundMode: true,
          notificationChannelId: AwesomeNotificationService.generalChannel,
          initialNotificationTitle: 'DesiLynks Sync',
          initialNotificationContent:
              'Receiving messages and notifications in background',
          foregroundServiceNotificationId: 888,
          foregroundServiceTypes: [
            AndroidForegroundType.dataSync,
            AndroidForegroundType.remoteMessaging,
          ],
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onBackgroundServiceStart,
        ),
      );

      final isRunning = await _service.isRunning();
      if (!isRunning) {
        await _service.startService();
      }
      developer.log(
        'BackgroundSyncService initialized successfully. isRunning: $isRunning',
        name: 'BackgroundSyncService',
      );
    } catch (e, stack) {
      developer.log(
        'Error configuring BackgroundSyncService: $e',
        name: 'BackgroundSyncService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Notify the background service when the user logs in or token is refreshed
  void updateToken(String token, {String? userId}) {
    _service.invoke('updateToken', {'token': token, 'userId': userId});
  }

  /// Stop the background service on logout
  void stop() {
    _service.invoke('stopService');
  }
}
