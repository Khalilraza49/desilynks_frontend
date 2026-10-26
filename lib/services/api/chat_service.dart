import 'dart:convert';
import 'dart:developer' as developer;
import 'api_endpoints.dart';
import 'api_service.dart';
import '../../models/chat_model.dart';

class PaginatedMessagesResponse {
  final List<ChatMessageModel> messages;
  final bool hasMore;
  final String? nextCursor;

  PaginatedMessagesResponse({
    required this.messages,
    required this.hasMore,
    this.nextCursor,
  });
}

class ChatApiService {
  final ApiService _apiService;

  ChatApiService(this._apiService);

  /// 5.1 GET /chat/conversations
  Future<List<ChatConversationModel>> getConversations({
    String? currentUserId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.chatConversationsEndpoint,
      );
      final dynamic decoded = jsonDecode(response.body);

      List<dynamic> dataList = [];
      if (decoded is List) {
        dataList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        dataList = decoded['conversations'] ?? decoded['data'] ?? [];
      }

      return dataList
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => ChatConversationModel.fromJson(
              item,
              currentUserId: currentUserId,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error fetching conversations: $e',
        name: 'ChatApiService',
        error: e,
      );
      rethrow;
    }
  }

  /// 5.2 GET /chat/conversations/:id/messages?limit=30&cursor=...
  Future<PaginatedMessagesResponse> getMessages(
    String conversationId, {
    String? cursor,
    int limit = 30,
    String? currentUserId,
  }) async {
    if (conversationId.trim().isEmpty) {
      return PaginatedMessagesResponse(messages: [], hasMore: false);
    }
    try {
      var query = 'limit=$limit';
      if (cursor != null && cursor.isNotEmpty) {
        query += '&cursor=$cursor';
      }

      final endpoint =
          '${ApiEndpoints.chatMessagesEndpoint(conversationId)}?$query';
      final response = await _apiService.get(endpoint);
      final dynamic decoded = jsonDecode(response.body);

      List<dynamic> rawMessages = [];
      bool hasMore = false;
      String? nextCursor;

      if (decoded is List) {
        rawMessages = decoded;
      } else if (decoded is Map<String, dynamic>) {
        rawMessages = decoded['messages'] ?? decoded['data'] ?? [];
        hasMore = decoded['hasMore'] == true;
        nextCursor = decoded['nextCursor']?.toString();
      }

      final messages = rawMessages
          .whereType<Map<String, dynamic>>()
          .map(
            (item) =>
                ChatMessageModel.fromJson(item, currentUserId: currentUserId),
          )
          .toList();

      return PaginatedMessagesResponse(
        messages: messages,
        hasMore: hasMore,
        nextCursor: nextCursor,
      );
    } catch (e) {
      developer.log(
        'Error fetching messages for conv $conversationId: $e',
        name: 'ChatApiService',
        error: e,
      );
      rethrow;
    }
  }

  /// 5.3 POST /chat/conversations/:id/read
  Future<int> markAsReadRest(String conversationId) async {
    if (conversationId.trim().isEmpty) return 0;
    try {
      final response = await _apiService.post(
        ApiEndpoints.chatMarkReadEndpoint(conversationId),
        {},
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      return (data['count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      developer.log(
        'Error marking conversation as read via REST: $e',
        name: 'ChatApiService',
        error: e,
      );
      rethrow;
    }
  }

  /// 5.4 DELETE /chat/conversations/:id
  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _apiService.delete(
        ApiEndpoints.chatDeleteConversationEndpoint(conversationId),
      );
      return true;
    } catch (e) {
      developer.log(
        'Error soft-deleting conversation $conversationId: $e',
        name: 'ChatApiService',
        error: e,
      );
      rethrow;
    }
  }

  /// 5.5 GET /chat/unread-count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.chatUnreadCountEndpoint,
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      return (data['unreadCount'] as num?)?.toInt() ?? 0;
    } catch (e) {
      developer.log(
        'Error fetching unread count: $e',
        name: 'ChatApiService',
        error: e,
      );
      return 0;
    }
  }

  /// 6.1 POST /fcm-token/register
  Future<bool> registerFcmToken(String token, {String? device}) async {
    try {
      await _apiService.post(ApiEndpoints.fcmRegisterTokenEndpoint, {
        'token': token,
        if (device != null && device.isNotEmpty) 'device': device,
      });
      return true;
    } catch (e) {
      developer.log(
        'Error registering FCM token: $e',
        name: 'ChatApiService',
        error: e,
      );
      rethrow;
    }
  }

  /// 6.2 DELETE /fcm-token/remove
  Future<bool> removeFcmToken(String token) async {
    try {
      final response = await _apiService.delete(
        ApiEndpoints.fcmRemoveTokenEndpoint,
        body: {'token': token},
      );
      return response.statusCode == 200;
    } catch (e) {
      developer.log(
        'Error removing FCM token: $e',
        name: 'ChatApiService',
        error: e,
      );
      rethrow;
    }
  }
}
