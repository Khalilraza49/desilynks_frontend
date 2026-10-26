import 'dart:convert';
import 'dart:io';
import '../models/community_comment_model.dart';
import '../models/community_enums.dart';
import '../models/community_group_member_model.dart';
import '../models/community_group_model.dart';
import '../models/community_poll_model.dart';
import '../models/community_post_model.dart';
import '../models/search_result_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

/// Repository handling all Community Post, Interaction, Poll, and Comment network operations.
class CommunityRepository {
  final ApiService _apiService;

  CommunityRepository(this._apiService);

  // ──────────────────────────────────────────────────────────────────────────
  // 1. Post Controller Operations
  // ──────────────────────────────────────────────────────────────────────────

  /// Create a new Community Post (`POST /community/post` multipart/form-data)
  Future<CommunityPostModel> createPost({
    required CommunityPostType type,
    required CommunityPostVisibility visibility,
    String? content,
    String? groupId,
    String? pollQuestion,
    List<String>? pollOptions,
    DateTime? pollExpiresAt,
    List<File>? photos,
    File? video,
  }) async {
    final fields = <String, String>{
      'type': type.name,
      'visibility': visibility.name,
    };

    if (content != null && content.isNotEmpty) {
      fields['content'] = content;
    }
    if (groupId != null && groupId.isNotEmpty) {
      fields['groupId'] = groupId;
    }
    if (pollQuestion != null && pollQuestion.isNotEmpty) {
      fields['pollQuestion'] = pollQuestion;
    }
    if (pollOptions != null && pollOptions.isNotEmpty) {
      fields['pollOptions'] = jsonEncode(pollOptions);
      for (int i = 0; i < pollOptions.length; i++) {
        fields['pollOptions[$i]'] = pollOptions[i];
      }
    }
    if (pollExpiresAt != null) {
      fields['pollExpiresAt'] = pollExpiresAt.toIso8601String();
    }

    final response = await _apiService.multipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.communityPostEndpoint,
      fields: fields,
      files: photos,
      filesKey: 'photos',
      singleFile: video,
      singleFileKey: 'video',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityPostModel.fromJson(data);
  }

  /// Get Public Feed (`GET /community/post`)
  Future<PaginatedResponse<CommunityPostModel>> getFeed({
    int page = 1,
    int limit = 10,
    CommunityPostType? type,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (type != null) {
      queryParams.add('type=${type.name}');
    }

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.communityPostEndpoint}$queryString',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final posts = dataList
        .map(
          (item) => CommunityPostModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: posts.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: posts, meta: meta);
  }

  /// Get User's Own Posts (`GET /community/post/me`)
  Future<PaginatedResponse<CommunityPostModel>> getMyPosts({
    int page = 1,
    int limit = 10,
    CommunityPostType? type,
    CommunityPostVisibility? visibility,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (type != null) queryParams.add('type=${type.name}');
    if (visibility != null) queryParams.add('visibility=${visibility.name}');

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.communityMyPostsEndpoint}$queryString',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final posts = dataList
        .map(
          (item) => CommunityPostModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: posts.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: posts, meta: meta);
  }

  /// Get Group Posts (`GET /community/post/group/:groupId`)
  Future<PaginatedResponse<CommunityPostModel>> getGroupPosts({
    required String groupId,
    int page = 1,
    int limit = 10,
    CommunityPostType? type,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (type != null) queryParams.add('type=${type.name}');

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.communityGroupPostsEndpoint(groupId)}$queryString',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final posts = dataList
        .map(
          (item) => CommunityPostModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: posts.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: posts, meta: meta);
  }

  /// Get Post by ID (`GET /community/post/:id`)
  Future<CommunityPostModel> getPostById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.communityPostByIdEndpoint(id),
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityPostModel.fromJson(data);
  }

  /// Delete Post (`DELETE /community/post/:id`)
  Future<bool> deletePost(String id) async {
    final response = await _apiService.delete(
      ApiEndpoints.communityPostByIdEndpoint(id),
    );
    return response.statusCode == 200;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Interaction Operations
  // ──────────────────────────────────────────────────────────────────────────

  /// Like a Post (`POST /community/post/:postId/interaction/like`)
  Future<bool> likePost(String postId) async {
    final response = await _apiService.post(
      ApiEndpoints.communityPostLikeEndpoint(postId),
      {},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Unlike a Post (`DELETE /community/post/:postId/interaction/like`)
  Future<bool> unlikePost(String postId) async {
    final response = await _apiService.delete(
      ApiEndpoints.communityPostLikeEndpoint(postId),
    );
    return response.statusCode == 200;
  }

  /// Share a Post (`POST /community/post/:postId/interaction/share`)
  Future<bool> sharePost(String postId) async {
    final response = await _apiService.post(
      ApiEndpoints.communityPostShareEndpoint(postId),
      {},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Poll Operations
  // ──────────────────────────────────────────────────────────────────────────

  /// Cast Vote on Poll Option (`POST /community/post/:postId/poll/vote`)
  Future<PollModel> castPollVote({
    required String postId,
    required String optionId,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.communityPollVoteEndpoint(postId),
      {'optionId': optionId},
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return PollModel.fromJson(data);
  }

  /// Get Poll Results (`GET /community/post/:postId/poll`)
  Future<PollModel> getPollResults(String postId) async {
    final response = await _apiService.get(
      ApiEndpoints.communityPollResultsEndpoint(postId),
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return PollModel.fromJson(data);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Comment Operations
  // ──────────────────────────────────────────────────────────────────────────

  /// Create Comment or Nested Reply (`POST /community/post/comment`)
  Future<CommunityCommentModel> createComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    final body = <String, dynamic>{
      'postId': postId,
      'content': content,
      if (parentId != null && parentId.isNotEmpty) 'parentId': parentId,
    };

    final response = await _apiService.post(
      ApiEndpoints.communityCommentEndpoint,
      body,
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityCommentModel.fromJson(data);
  }

  /// Get Authenticated User's Own Comments (`GET /community/post/comment/me`)
  Future<PaginatedResponse<CommunityCommentModel>> getMyComments({
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = 'page=$page&limit=$limit';
    final response = await _apiService.get(
      '${ApiEndpoints.communityMyCommentsEndpoint}?$queryParams',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final comments = dataList
        .map(
          (item) =>
              CommunityCommentModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: comments.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: comments, meta: meta);
  }

  /// Get Comments for a Post (`GET /community/post/comment/:postId`)
  Future<PaginatedResponse<CommunityCommentModel>> getPostComments({
    required String postId,
    int page = 1,
    int limit = 20,
    String? parentId,
  }) async {
    final queryParams = <String>[
      'page=$page',
      'limit=$limit',
    ];
    if (parentId != null && parentId.trim().isNotEmpty) {
      queryParams.add('parentId=${parentId.trim()}');
    }

    final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final response = await _apiService.get(
      '${ApiEndpoints.communityPostCommentsEndpoint(postId)}$queryString',
    );

    dynamic resBody;
    try {
      resBody = jsonDecode(response.body);
    } catch (_) {
      resBody = {};
    }

    final List<dynamic> dataList;
    if (resBody is List) {
      dataList = resBody;
    } else if (resBody is Map<String, dynamic>) {
      dataList =
          (resBody['data'] ?? resBody['comments'] ?? resBody['items'])
              as List? ??
          [];
    } else {
      dataList = [];
    }

    final comments = dataList
        .whereType<Map<String, dynamic>>()
        .map((item) => CommunityCommentModel.fromJson(item))
        .toList();

    SearchMeta meta;
    if (resBody is Map<String, dynamic> &&
        resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: comments.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: comments, meta: meta);
  }

  /// Delete a Comment (`DELETE /community/post/comment/:id`)
  Future<bool> deleteComment(String id) async {
    final response = await _apiService.delete(
      ApiEndpoints.communityCommentByIdEndpoint(id),
    );
    return response.statusCode == 200;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. Community Group Operations
  // ──────────────────────────────────────────────────────────────────────────

  /// Create a Community Group (`POST /community/group` multipart/form-data)
  Future<CommunityGroupModel> createGroup({
    required String name,
    required String description,
    required CommunityGroupCategory category,
    required CommunityGroupPrivacy privacy,
    File? coverPhoto,
  }) async {
    final fields = <String, String>{
      'name': name,
      'description': description,
      'category': category.name,
      'privacy': privacy.name,
    };

    final response = await _apiService.multipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.communityGroupEndpoint,
      fields: fields,
      singleFile: coverPhoto,
      singleFileKey: 'coverPhoto',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityGroupModel.fromJson(data);
  }

  /// Update Group Details (`PATCH /community/group/:id`)
  Future<CommunityGroupModel> updateGroup({
    required String id,
    required String name,
    required String description,
    required CommunityGroupCategory category,
    required CommunityGroupPrivacy privacy,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.communityGroupByIdEndpoint(id),
      {
        'name': name,
        'description': description,
        'category': category.name,
        'privacy': privacy.name,
      },
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityGroupModel.fromJson(data);
  }

  /// Update Group Cover Photo (`PATCH /community/group/:id/cover-photo` multipart)
  Future<CommunityGroupModel> updateGroupCoverPhoto({
    required String id,
    required File coverPhoto,
  }) async {
    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.communityGroupCoverPhotoEndpoint(id),
      fields: {},
      singleFile: coverPhoto,
      singleFileKey: 'coverPhoto',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityGroupModel.fromJson(data);
  }

  /// Get All Active Groups (`GET /community/group`)
  Future<PaginatedResponse<CommunityGroupModel>> getGroups({
    int page = 1,
    int limit = 10,
    CommunityGroupCategory? category,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (category != null) {
      queryParams.add('category=${category.name}');
    }
    final queryString = '?${queryParams.join('&')}';

    final response = await _apiService.get(
      '${ApiEndpoints.communityGroupEndpoint}$queryString',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final groups = dataList
        .map(
          (item) => CommunityGroupModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: groups.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: groups, meta: meta);
  }

  /// Get User's Groups (`GET /community/group/me`)
  Future<PaginatedResponse<CommunityGroupModel>> getMyGroups({
    int page = 1,
    int limit = 10,
    CommunityGroupCategory? category,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (category != null) {
      queryParams.add('category=${category.name}');
    }
    final queryString = '?${queryParams.join('&')}';

    final response = await _apiService.get(
      '${ApiEndpoints.communityGroupMeEndpoint}$queryString',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final groups = dataList
        .map(
          (item) => CommunityGroupModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: groups.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: groups, meta: meta);
  }

  /// Get Group By ID (`GET /community/group/:id`)
  Future<CommunityGroupModel> getGroupById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.communityGroupByIdEndpoint(id),
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityGroupModel.fromJson(data);
  }

  /// Toggle Group Archive Status (`PATCH /community/group/:id/toggle-archive`)
  Future<CommunityGroupModel> toggleArchiveGroup(String id) async {
    final response = await _apiService.patch(
      ApiEndpoints.communityGroupToggleArchiveEndpoint(id),
      {},
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityGroupModel.fromJson(data);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 6. Group Member Operations
  // ──────────────────────────────────────────────────────────────────────────

  /// Join a Community Group (`POST /community/group/:groupId/member/join`)
  Future<CommunityGroupMemberModel> joinGroup(String groupId) async {
    final response = await _apiService.post(
      ApiEndpoints.communityGroupMemberJoinEndpoint(groupId),
      {},
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityGroupMemberModel.fromJson(data);
  }

  /// Leave a Community Group (`DELETE /community/group/:groupId/member/leave`)
  Future<bool> leaveGroup(String groupId) async {
    final response = await _apiService.delete(
      ApiEndpoints.communityGroupMemberLeaveEndpoint(groupId),
    );
    return response.statusCode == 200;
  }

  /// Remove a Member from Group (`DELETE /community/group/:groupId/member/:userId`)
  Future<bool> removeMember({
    required String groupId,
    required String userId,
  }) async {
    final response = await _apiService.delete(
      ApiEndpoints.communityGroupMemberByIdEndpoint(groupId, userId),
    );
    return response.statusCode == 200;
  }

  /// Get Group Members (`GET /community/group/:groupId/member`)
  Future<PaginatedResponse<CommunityGroupMemberModel>> getGroupMembers({
    required String groupId,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    final queryString = '?${queryParams.join('&')}';

    final response = await _apiService.get(
      '${ApiEndpoints.communityGroupMemberEndpoint(groupId)}$queryString',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final members = dataList
        .map(
          (item) =>
              CommunityGroupMemberModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: members.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: members, meta: meta);
  }

  /// Get Admin Group Members (`GET /community/group/:groupId/member/admin`)
  Future<PaginatedResponse<CommunityGroupMemberModel>> getAdminGroupMembers({
    required String groupId,
    int page = 1,
    int limit = 10,
    CommunityGroupMemberStatus? status,
    CommunityGroupMemberRole? role,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (status != null) queryParams.add('status=${status.name}');
    if (role != null) queryParams.add('role=${role.name}');
    final queryString = '?${queryParams.join('&')}';

    final response = await _apiService.get(
      '${ApiEndpoints.communityGroupMemberAdminEndpoint(groupId)}$queryString',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final members = dataList
        .map(
          (item) =>
              CommunityGroupMemberModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: members.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: members, meta: meta);
  }

  /// Get Current User's Group Membership (`GET /community/group/:groupId/member/me`)
  Future<CommunityGroupMemberModel?> getMyMembership(String groupId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.communityGroupMemberMeEndpoint(groupId),
      );

      if (response.statusCode != 200) return null;

      final Map<String, dynamic> resBody = jsonDecode(response.body);
      final data = resBody['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      return CommunityGroupMemberModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Update Member Status (`PATCH /community/group/:groupId/member/:userId/status`)
  Future<CommunityGroupMemberModel> updateMemberStatus({
    required String groupId,
    required String userId,
    required CommunityGroupMemberStatus status,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.communityGroupMemberStatusEndpoint(groupId, userId),
      {'status': status.name},
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityGroupMemberModel.fromJson(data);
  }

  /// Update Member Role (`PATCH /community/group/:groupId/member/:userId/role`)
  Future<CommunityGroupMemberModel> updateMemberRole({
    required String groupId,
    required String userId,
    required CommunityGroupMemberRole role,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.communityGroupMemberRoleEndpoint(groupId, userId),
      {'role': role.name},
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return CommunityGroupMemberModel.fromJson(data);
  }
}
