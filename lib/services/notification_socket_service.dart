import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'api/api_endpoints.dart';
import '../models/notification_model.dart';
import 'awesome_notification_service.dart';

typedef OnNewNotificationCallback =
    void Function(NotificationModel notification);

Map<String, dynamic> _toMap(dynamic obj) {
  if (obj == null) return {};
  if (obj is Map<String, dynamic>) return obj;
  if (obj is Map) {
    final Map<String, dynamic> res = {};
    obj.forEach((key, value) {
      res[key.toString()] = value;
    });
    return res;
  }
  return {};
}

/// Listens to real-time notification events on the Socket.IO root namespace.
/// Mirrors the architecture of [ChatSocketService].
class NotificationSocketService {
  socket_io.Socket? _socket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Callback fired when a new notification arrives from the server.
  OnNewNotificationCallback? onNewNotification;

  // Callback fired when socket successfully connects or reconnects.
  void Function()? onConnected;

  void connect(String token, {String? currentUserId}) {
    if (_socket != null && _socket!.connected) {
      developer.log(
        'NotificationSocket already connected.',
        name: 'NotificationSocketService',
      );
      if (currentUserId != null && currentUserId.isNotEmpty) {
        _joinUserRoom(currentUserId);
      }
      return;
    }

    // Strip trailing slash from baseUrl if present
    final String base = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;

    // Use root namespace (/) — notifications are emitted globally
    final String socketUrl = base;

    // Strip "Bearer " prefix if present
    final String rawToken = token.startsWith('Bearer ')
        ? token.substring(7).trim()
        : token.trim();

    developer.log(
      'NotificationSocket: connecting to $socketUrl with user: $currentUserId',
      name: 'NotificationSocketService',
    );

    _socket = socket_io.io(
      socketUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({
            'token': rawToken,
            'authorization': 'Bearer $rawToken',
            if (currentUserId != null) 'userId': currentUserId,
          })
          .setExtraHeaders({
            'Authorization': 'Bearer $rawToken',
          })
          .setQuery({
            'token': rawToken,
            if (currentUserId != null) 'userId': currentUserId,
          })
          .enableReconnection()
          .build(),
    );

    _registerListeners(currentUserId);
    _socket!.connect();
  }

  void _joinUserRoom(String? userId) {
    if (_socket == null || !_isConnected || userId == null || userId.isEmpty) {
      return;
    }
    developer.log(
      'NotificationSocket joining user room: user:$userId',
      name: 'NotificationSocketService',
    );
    _socket!.emit('join', 'user:$userId');
    _socket!.emit('joinRoom', 'user:$userId');
    _socket!.emit('join', {'userId': userId, 'room': 'user:$userId'});
  }

  void _registerListeners(String? currentUserId) {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      if (_socket == null) return;
      _isConnected = true;
      developer.log(
        'NotificationSocket connected! ID: ${_socket?.id}',
        name: 'NotificationSocketService',
      );
      _joinUserRoom(currentUserId);
      onConnected?.call();
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      developer.log(
        'NotificationSocket disconnected: $reason',
        name: 'NotificationSocketService',
      );
    });

    _socket!.onError((err) {
      developer.log(
        'NotificationSocket error: $err',
        name: 'NotificationSocketService',
      );
    });

    // The server emits 'newNotification' with a notification payload
    _socket!.on('newNotification', (data) => handlePayload(data, 'newNotification'));
    _socket!.on('notification', (data) => handlePayload(data, 'notification'));
  }

  void handlePayload(dynamic data, String eventName) {
    developer.log(
      'NotificationSocket received [$eventName]: $data',
      name: 'NotificationSocketService',
    );
    try {
      final dataMap = _toMap(data);
      if (dataMap.isNotEmpty) {
        final notifMap = dataMap.containsKey('notification')
            ? _toMap(dataMap['notification'])
            : dataMap;
        if (notifMap.isNotEmpty) {
          final notification = NotificationModel.fromJson(notifMap);
          onNewNotification?.call(notification);
          AwesomeNotificationService.instance.showNotification(notification);
        }
      }
    } catch (e) {
      developer.log(
        'NotificationSocket: error parsing $eventName: $e',
        name: 'NotificationSocketService',
        error: e,
      );
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      developer.log(
        'NotificationSocket disconnected and disposed.',
        name: 'NotificationSocketService',
      );
    }
  }
}
