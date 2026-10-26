import 'dart:convert';
import 'dart:developer' as developer;
import '../api/api_service.dart';
import '../api/api_endpoints.dart';
import '../../models/notification_model.dart';

class NotificationApiService {
  final ApiService _apiService;

  NotificationApiService(this._apiService);

  /// 1.1 GET /notifications — paginated list
  Future<Map<String, dynamic>> fetchNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null && type.isNotEmpty) 'type': type,
        if (isRead != null) 'isRead': isRead.toString(),
      };

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '${ApiEndpoints.notificationsEndpoint}?$queryString';

      developer.log(
        'NotificationApiService: GET $endpoint',
        name: 'NotificationApiService',
      );

      final response = await _apiService.get(endpoint);
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final dataList = json['data'] as List<dynamic>? ?? [];
      final notifications = dataList
          .map(
            (item) => NotificationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      final meta = (json['meta'] as Map<String, dynamic>?) ??
          (json['pagination'] as Map<String, dynamic>?) ??
          {};
      final parsedPage = meta['page'] as int? ?? page;
      final parsedTotalPages = meta['totalPages'] as int? ?? 1;
      final parsedLimit = meta['limit'] as int? ?? limit;
      final parsedTotal = meta['total'] as int? ?? notifications.length;
      final hasNext = meta['hasNextPage'] as bool? ?? (parsedPage < parsedTotalPages);

      return {
        'notifications': notifications,
        'total': parsedTotal,
        'page': parsedPage,
        'limit': parsedLimit,
        'totalPages': parsedTotalPages,
        'hasNextPage': hasNext,
      };
    } catch (e) {
      developer.log(
        'NotificationApiService: fetchNotifications error: $e',
        name: 'NotificationApiService',
        error: e,
      );
      rethrow;
    }
  }

  /// 1.2 GET /notifications/unread-count
  Future<int> fetchUnreadCount() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.notificationsUnreadCountEndpoint,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['count'] as int? ??
          json['data']?['unreadCount'] as int? ??
          json['unreadCount'] as int? ??
          0;
    } catch (e) {
      developer.log(
        'NotificationApiService: fetchUnreadCount error: $e',
        name: 'NotificationApiService',
        error: e,
      );
      return 0;
    }
  }

  /// 1.3 PATCH /notifications/:id/read — mark single as read
  Future<bool> markAsRead(String id) async {
    try {
      await _apiService.patch(
        ApiEndpoints.notificationMarkReadEndpoint(id),
        {},
      );
      return true;
    } catch (e) {
      developer.log(
        'NotificationApiService: markAsRead error: $e',
        name: 'NotificationApiService',
        error: e,
      );
      return false;
    }
  }

  /// 1.4 PATCH /notifications/read-all — mark all as read
  Future<bool> markAllAsRead() async {
    try {
      await _apiService.patch(ApiEndpoints.notificationsReadAllEndpoint, {});
      return true;
    } catch (e) {
      developer.log(
        'NotificationApiService: markAllAsRead error: $e',
        name: 'NotificationApiService',
        error: e,
      );
      return false;
    }
  }

  /// 1.5 DELETE /notifications/:id — delete single notification
  Future<bool> deleteNotification(String id) async {
    try {
      await _apiService.delete(ApiEndpoints.notificationDeleteEndpoint(id));
      return true;
    } catch (e) {
      developer.log(
        'NotificationApiService: deleteNotification error: $e',
        name: 'NotificationApiService',
        error: e,
      );
      return false;
    }
  }

  /// 3. FCM Token Management: POST /fcm-token/register
  Future<bool> registerFcmToken(String token, {String? device}) async {
    try {
      await _apiService.post(ApiEndpoints.fcmRegisterTokenEndpoint, {
        'token': token,
        if (device != null && device.isNotEmpty) 'device': device,
      });
      return true;
    } catch (e) {
      developer.log(
        'NotificationApiService: registerFcmToken error: $e',
        name: 'NotificationApiService',
        error: e,
      );
      return false;
    }
  }

  /// 3. FCM Token Management: DELETE /fcm-token/remove
  Future<bool> removeFcmToken(String token) async {
    try {
      final response = await _apiService.delete(
        ApiEndpoints.fcmRemoveTokenEndpoint,
        body: {'token': token},
      );
      return response.statusCode == 200;
    } catch (e) {
      developer.log(
        'NotificationApiService: removeFcmToken error: $e',
        name: 'NotificationApiService',
        error: e,
      );
      return false;
    }
  }
}
