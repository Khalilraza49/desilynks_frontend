import 'dart:async';
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'api/api_endpoints.dart';
import '../models/chat_model.dart';

typedef OnNewMessageCallback =
    void Function(ChatMessageModel message, String conversationId);
typedef OnMessagesReadCallback =
    void Function(String conversationId, String readBy);
typedef OnUserTypingCallback =
    void Function(String conversationId, String userId);
typedef OnUserStopTypingCallback =
    void Function(String conversationId, String userId);
typedef OnMessageDeletedCallback =
    void Function(String messageId, String conversationId);
typedef OnUserOnlineCallback = void Function(String userId);
typedef OnUserOfflineCallback = void Function(String userId);
typedef OnSocketErrorCallback = void Function(String errorMessage);

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

class ChatSocketService {
  socket_io.Socket? _socket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Event Callbacks
  OnNewMessageCallback? onNewMessage;
  OnMessagesReadCallback? onMessagesRead;
  OnUserTypingCallback? onUserTyping;
  OnUserStopTypingCallback? onUserStopTyping;
  OnMessageDeletedCallback? onMessageDeleted;
  OnUserOnlineCallback? onUserOnline;
  OnUserOfflineCallback? onUserOffline;
  OnSocketErrorCallback? onError;
  void Function(dynamic data)? onNotificationReceived;

  void connect(String token, {String? currentUserId}) {
    if (_socket != null && _socket!.connected) {
      developer.log('Socket already connected.', name: 'ChatSocketService');
      return;
    }

    final String base = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;
    final String socketUrl = '$base${ApiEndpoints.chatSocketNamespace}';

    final String rawToken = token.startsWith('Bearer ')
        ? token.substring(7).trim()
        : token.trim();

    developer.log(
      'Connecting to Socket.IO namespace at: $socketUrl',
      name: 'ChatSocketService',
    );

    _socket = socket_io.io(
      socketUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({'token': rawToken})
          .enableReconnection()
          .build(),
    );

    _registerListeners(currentUserId);
    _socket!.connect();
  }

  void _registerListeners(String? currentUserId) {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      if (_socket == null) return;
      _isConnected = true;
      developer.log(
        'Socket Connected! ID: ${_socket?.id}',
        name: 'ChatSocketService',
      );
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      developer.log('Socket Disconnected: $reason', name: 'ChatSocketService');
    });

    _socket!.onError((err) {
      developer.log('Socket Error event: $err', name: 'ChatSocketService');
      String msg = 'Socket error occurred';
      if (err is Map && err['message'] != null) {
        msg = err['message'].toString();
      } else if (err is String) {
        msg = err;
      }
      onError?.call(msg);
    });

    // 4.1 newMessage
    _socket!.on('newMessage', (data) {
      developer.log(
        'Socket received [newMessage]: $data',
        name: 'ChatSocketService',
      );
      try {
        final dataMap = _toMap(data);
        if (dataMap.isNotEmpty) {
          final convId = dataMap['conversationId']?.toString() ?? '';
          final rawMessage = dataMap['message'];
          final msgMap = _toMap(rawMessage);
          if (msgMap.isNotEmpty) {
            final msg = ChatMessageModel.fromJson(
              msgMap,
              currentUserId: currentUserId,
            );
            onNewMessage?.call(msg, convId);
          }
        }
      } catch (e) {
        developer.log(
          'Error parsing newMessage: $e',
          name: 'ChatSocketService',
          error: e,
        );
      }
    });

    // 4.2 messagesRead
    _socket!.on('messagesRead', (data) {
      developer.log(
        'Socket received [messagesRead]: $data',
        name: 'ChatSocketService',
      );
      try {
        final dataMap = _toMap(data);
        if (dataMap.isNotEmpty) {
          final convId = dataMap['conversationId']?.toString() ?? '';
          final readBy = dataMap['readBy']?.toString() ?? '';
          onMessagesRead?.call(convId, readBy);
        }
      } catch (e) {
        developer.log(
          'Error parsing messagesRead: $e',
          name: 'ChatSocketService',
          error: e,
        );
      }
    });

    // 4.3 userTyping
    _socket!.on('userTyping', (data) {
      developer.log(
        'Socket received [userTyping]: $data',
        name: 'ChatSocketService',
      );
      try {
        final dataMap = _toMap(data);
        if (dataMap.isNotEmpty) {
          final convId = dataMap['conversationId']?.toString() ?? '';
          final userId = dataMap['userId']?.toString() ?? '';
          onUserTyping?.call(convId, userId);
        }
      } catch (e) {
        developer.log(
          'Error parsing userTyping: $e',
          name: 'ChatSocketService',
          error: e,
        );
      }
    });

    // 4.4 userStopTyping
    _socket!.on('userStopTyping', (data) {
      developer.log(
        'Socket received [userStopTyping]: $data',
        name: 'ChatSocketService',
      );
      try {
        final dataMap = _toMap(data);
        if (dataMap.isNotEmpty) {
          final convId = dataMap['conversationId']?.toString() ?? '';
          final userId = dataMap['userId']?.toString() ?? '';
          onUserStopTyping?.call(convId, userId);
        }
      } catch (e) {
        developer.log(
          'Error parsing userStopTyping: $e',
          name: 'ChatSocketService',
          error: e,
        );
      }
    });

    // 4.5 messageDeleted
    _socket!.on('messageDeleted', (data) {
      developer.log(
        'Socket received [messageDeleted]: $data',
        name: 'ChatSocketService',
      );
      try {
        final dataMap = _toMap(data);
        if (dataMap.isNotEmpty) {
          final msgId = dataMap['messageId']?.toString() ?? '';
          final convId = dataMap['conversationId']?.toString() ?? '';
          onMessageDeleted?.call(msgId, convId);
        }
      } catch (e) {
        developer.log(
          'Error parsing messageDeleted: $e',
          name: 'ChatSocketService',
          error: e,
        );
      }
    });

    // 4.6 error
    _socket!.on('error', (data) {
      developer.log(
        'Socket received [error]: $data',
        name: 'ChatSocketService',
      );
      String msg = 'Socket authentication/connection error';
      if (data is Map && data['message'] != null) {
        msg = data['message'].toString();
      } else if (data is String) {
        msg = data;
      }
      onError?.call(msg);
    });

    // 4.7 userOnline
    _socket!.on('userOnline', (data) {
      developer.log(
        'Socket received [userOnline]: $data',
        name: 'ChatSocketService',
      );
      try {
        String userId = '';
        if (data is String) {
          userId = data;
        } else {
          final dataMap = _toMap(data);
          userId = dataMap['userId']?.toString() ?? dataMap['id']?.toString() ?? '';
        }
        if (userId.isNotEmpty) {
          onUserOnline?.call(userId);
        }
      } catch (e) {
        developer.log(
          'Error parsing userOnline: $e',
          name: 'ChatSocketService',
          error: e,
        );
      }
    });

    // 4.8 userOffline
    _socket!.on('userOffline', (data) {
      developer.log(
        'Socket received [userOffline]: $data',
        name: 'ChatSocketService',
      );
      try {
        String userId = '';
        if (data is String) {
          userId = data;
        } else {
          final dataMap = _toMap(data);
          userId = dataMap['userId']?.toString() ?? dataMap['id']?.toString() ?? '';
        }
        if (userId.isNotEmpty) {
          onUserOffline?.call(userId);
        }
      } catch (e) {
        developer.log(
          'Error parsing userOffline: $e',
          name: 'ChatSocketService',
          error: e,
        );
      }
    });

    // 4.9 Real-time notifications on chat namespace
    _socket!.on('newNotification', (data) {
      developer.log('ChatSocket received [newNotification]: $data', name: 'ChatSocketService');
      onNotificationReceived?.call(data);
    });
    _socket!.on('notification', (data) {
      developer.log('ChatSocket received [notification]: $data', name: 'ChatSocketService');
      onNotificationReceived?.call(data);
    });
  }

  // --- CLIENT EMITS (Section 3) ---

  /// 3.1 sendMessage
  Future<ChatMessageModel?> sendMessage(
    String receiverId,
    String content, {
    String? currentUserId,
  }) async {
    if (_socket == null || !_isConnected) {
      developer.log(
        'Cannot emit sendMessage: socket not connected',
        name: 'ChatSocketService',
      );
      return null;
    }

    final Completer<ChatMessageModel?> completer = Completer();
    final payload = {'receiverId': receiverId, 'content': content};

    developer.log(
      'Emitting [sendMessage]: $payload',
      name: 'ChatSocketService',
    );

    _socket!.emitWithAck(
      'sendMessage',
      payload,
      ack: (response) {
        developer.log(
          'Ack response for [sendMessage]: $response',
          name: 'ChatSocketService',
        );
        if (response is Map) {
          final respMap = _toMap(response);
          final event = respMap['event']?.toString();
          final data = _toMap(respMap['data']);
          if (event == 'messageSent' && data['message'] != null) {
            final msgMap = _toMap(data['message']);
            // Inject conversationId from ack data into the message map
            final ackConvId = data['conversationId']?.toString();
            if (ackConvId != null &&
                ackConvId.isNotEmpty &&
                (msgMap['conversationId'] == null ||
                    msgMap['conversationId'].toString().isEmpty)) {
              msgMap['conversationId'] = ackConvId;
            }
            final msg = ChatMessageModel.fromJson(
              msgMap,
              currentUserId: currentUserId,
            );
            completer.complete(msg);
            return;
          } else if (event == 'error') {
            final errStr =
                data['message']?.toString() ?? 'Error sending message';
            onError?.call(errStr);
          }
        }
        completer.complete(null);
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        developer.log(
          'sendMessage ack timed out, proceeding optimistically',
          name: 'ChatSocketService',
        );
        return null;
      },
    );
  }

  /// 3.2 markAsRead
  void markAsRead(String conversationId) {
    if (_socket == null || !_isConnected) return;
    final payload = {'conversationId': conversationId};
    developer.log('Emitting [markAsRead]: $payload', name: 'ChatSocketService');
    _socket!.emitWithAck(
      'markAsRead',
      payload,
      ack: (response) {
        developer.log(
          'Ack response for [markAsRead]: $response',
          name: 'ChatSocketService',
        );
      },
    );
  }

  /// 3.3 typing
  void emitTyping(String conversationId, String receiverId) {
    if (_socket == null || !_isConnected) return;
    final payload = {
      'conversationId': conversationId,
      'receiverId': receiverId,
    };
    developer.log('Emitting [typing]: $payload', name: 'ChatSocketService');
    _socket!.emit('typing', payload);
  }

  /// 3.4 stopTyping
  void emitStopTyping(String conversationId, String receiverId) {
    if (_socket == null || !_isConnected) return;
    final payload = {
      'conversationId': conversationId,
      'receiverId': receiverId,
    };
    developer.log('Emitting [stopTyping]: $payload', name: 'ChatSocketService');
    _socket!.emit('stopTyping', payload);
  }

  /// 3.5 deleteMessage
  Future<bool> deleteMessage(String messageId, DeleteScope scope) async {
    if (_socket == null || !_isConnected) return false;

    final Completer<bool> completer = Completer();
    final payload = {'messageId': messageId, 'scope': scope.toJson()};

    developer.log(
      'Emitting [deleteMessage]: $payload',
      name: 'ChatSocketService',
    );

    _socket!.emitWithAck(
      'deleteMessage',
      payload,
      ack: (response) {
        developer.log(
          'Ack response for [deleteMessage]: $response',
          name: 'ChatSocketService',
        );
        if (response is Map) {
          final event = response['event']?.toString();
          if (event == 'messageDeletedAck') {
            completer.complete(true);
            return;
          } else if (event == 'error' && response['data'] is Map) {
            final errStr =
                response['data']['message']?.toString() ??
                'Error deleting message';
            onError?.call(errStr);
          }
        }
        completer.complete(false);
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        developer.log(
          'deleteMessage ack timed out, proceeding optimistically',
          name: 'ChatSocketService',
        );
        return true;
      },
    );
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      developer.log(
        'Socket disconnected and disposed.',
        name: 'ChatSocketService',
      );
    }
  }
}
