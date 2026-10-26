import 'dart:convert';
import 'dart:developer' as developer;
import 'package:desilynks/models/moderation_models.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/services/api/api_service.dart';

class ModerationRepository {
  final ApiService _apiService;

  ModerationRepository(this._apiService);

  /// 1. Report Content (POST /report)
  Future<String> reportContent({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReason reason,
    String? details,
  }) async {
    final Map<String, dynamic> body = {
      'targetType': targetType.value,
      'targetId': targetId,
      'reason': reason.value,
    };
    if (details != null && details.trim().isNotEmpty) {
      body['details'] = details.trim();
    }

    developer.log(
      'ModerationRepository: Reporting ${targetType.value} ($targetId) with reason ${reason.value}',
      name: 'ModerationRepository',
    );

    final response = await _apiService.post(
      ApiEndpoints.reportEndpoint,
      body,
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['message'] as String? ?? 'Report submitted successfully';
  }

  /// 2. List Blocked Users (GET /block?page=...&limit=...)
  Future<BlockedUsersPaginationModel> getBlockedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final endpoint = '${ApiEndpoints.blockListEndpoint}?page=$page&limit=$limit';
    developer.log(
      'ModerationRepository: Fetching blocked users page $page (limit $limit)',
      name: 'ModerationRepository',
    );

    final response = await _apiService.get(endpoint);
    final Map<String, dynamic> data = jsonDecode(response.body);
    return BlockedUsersPaginationModel.fromJson(data);
  }

  /// 3. Block User (POST /block/:userId)
  Future<bool> blockUser(String userId) async {
    developer.log(
      'ModerationRepository: Blocking user $userId',
      name: 'ModerationRepository',
    );

    final response = await _apiService.post(
      ApiEndpoints.blockUserEndpoint(userId),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['blocked'] == true;
  }

  /// 4. Unblock User (DELETE /block/:userId)
  Future<bool> unblockUser(String userId) async {
    developer.log(
      'ModerationRepository: Unblocking user $userId',
      name: 'ModerationRepository',
    );

    final response = await _apiService.delete(
      ApiEndpoints.unblockUserEndpoint(userId),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['blocked'] == false;
  }
}
