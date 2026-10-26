import 'dart:convert';
import 'dart:io';
import '../models/need_worker_model.dart';
import '../models/need_worker_application_model.dart';
import '../models/search_result_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class NeedWorkerRepository {
  final ApiService _apiService;

  NeedWorkerRepository(this._apiService);

  // ─── Post Management (Requester Actions) ───

  /// 1. Create a new "Need a worker" post (POST /need-worker - multipart/form-data)
  Future<NeedWorkerModel> createPost({
    String? workerType,
    String? workerTypeId,
    String? needWorkerTypeId,
    required String location,
    required String dateNeeded,

    required String budget,
    required String budgetType,
    required bool isUrgentRequest,
    required String description,
    List<File>? referencePhotos,
  }) async {
    final effectiveWorkerTypeId =
        (workerTypeId != null && workerTypeId.isNotEmpty)
            ? workerTypeId
            : needWorkerTypeId;

    final fields = <String, String>{
      if (effectiveWorkerTypeId != null && effectiveWorkerTypeId.isNotEmpty)
        'workerTypeId': effectiveWorkerTypeId,
      'location': location,
      'dateNeeded': dateNeeded,
      'budget': budget,
      'budgetType': budgetType.toUpperCase(),
      'isUrgentRequest': isUrgentRequest ? 'true' : 'false',
      'description': description,
    };

    final response = await _apiService.multipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.needWorkerEndpoint,
      fields: fields,
      files: referencePhotos,
      filesKey: 'reference-photos',
    );

    final dynamic resBody = jsonDecode(response.body);
    final Map<String, dynamic> data = (resBody is Map<String, dynamic>)
        ? (resBody['data'] as Map<String, dynamic>? ??
            resBody['post'] as Map<String, dynamic>? ??
            resBody)
        : <String, dynamic>{};
    return NeedWorkerModel.fromJson(data);
  }

  /// 2. Update a post (PATCH /need-worker/:id - application/json)
  Future<NeedWorkerModel> updatePost(
    String id, {
    String? workerType,
    String? workerTypeId,
    String? needWorkerTypeId,
    required String location,
    required String dateNeeded,

    required String budget,
    required String budgetType,
    required bool isUrgentRequest,
    required String description,
  }) async {
    final effectiveWorkerTypeId =
        (workerTypeId != null && workerTypeId.isNotEmpty)
            ? workerTypeId
            : needWorkerTypeId;

    final body = <String, dynamic>{
      if (effectiveWorkerTypeId != null && effectiveWorkerTypeId.isNotEmpty)
        'workerTypeId': effectiveWorkerTypeId,
      'location': location,
      'dateNeeded': dateNeeded,

      'budget': budget,
      'budgetType': budgetType.toUpperCase(),
      'isUrgentRequest': isUrgentRequest,
      'description': description,
    };

    final response = await _apiService.patch(
      ApiEndpoints.needWorkerUpdateEndpoint(id),
      body,
    );

    final dynamic resBody = jsonDecode(response.body);
    final Map<String, dynamic> data = (resBody is Map<String, dynamic>)
        ? (resBody['data'] as Map<String, dynamic>? ??
            resBody['post'] as Map<String, dynamic>? ??
            resBody)
        : <String, dynamic>{};
    return NeedWorkerModel.fromJson(data);
  }

  /// 3. Update reference photos (PATCH /need-worker/:id/reference-photos - multipart)
  Future<NeedWorkerModel> updateReferencePhotos(
    String id, {
    List<File>? newPhotos,
    List<String>? photosToRemove,
  }) async {
    final fields = <String, String>{};
    if (photosToRemove != null && photosToRemove.isNotEmpty) {
      fields['refPhotosToRemove'] = jsonEncode(photosToRemove);
    }

    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.needWorkerReferencePhotosEndpoint(id),
      fields: fields,
      files: newPhotos,
      filesKey: 'reference-photos',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return NeedWorkerModel.fromJson(data);
  }

  /// 4. Delete a post (DELETE /need-worker/:id)
  Future<void> deletePost(String id) async {
    await _apiService.delete(ApiEndpoints.needWorkerDeleteEndpoint(id));
  }

  /// 5. Get my posts (GET /need-worker/me)
  Future<PaginatedResponse<NeedWorkerModel>> getMyPosts({
    int page = 1,
    int limit = 50,
    String? budgetType,
  }) async {
    final safeLimit = (limit > 50 || limit < 1) ? 50 : limit;
    final queryParams = <String>['page=$page', 'limit=$safeLimit'];
    if (budgetType != null && budgetType.isNotEmpty) {
      queryParams.add('budgetType=${budgetType.toUpperCase()}');
    }
    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.needWorkerMyPostsEndpoint}$queryString',
    );
    return _parsePaginatedPosts(response.body);
  }

  // ─── Feed and Browsing (Worker Actions) ───

  /// 6. Get feed (GET /need-worker)
  Future<PaginatedResponse<NeedWorkerModel>> getFeed({
    int page = 1,
    int limit = 10,
    String? budgetType,
    String? workerType,
  }) async {
    final safeLimit = (limit > 50 || limit < 1) ? 50 : limit;
    final queryParams = <String>['page=$page', 'limit=$safeLimit'];
    if (budgetType != null && budgetType.isNotEmpty) {
      queryParams.add('budgetType=${budgetType.toUpperCase()}');
    }
    if (workerType != null && workerType.isNotEmpty) {
      queryParams.add('workerType=${workerType.toUpperCase()}');
    }
    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.needWorkerEndpoint}$queryString',
    );
    return _parsePaginatedPosts(response.body);
  }

  /// 7. Get post by ID (GET /need-worker/:id)
  Future<NeedWorkerModel> getPostById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.needWorkerByIdEndpoint(id),
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return NeedWorkerModel.fromJson(data);
  }

  // ─── Applications (Worker Actions) ───

  /// 8. Apply to a post (POST /need-worker/:id/apply)
  Future<NeedWorkerApplicationModel> applyToPost(
    String postId, {
    String? coverLetter,
    String? proposedPrice,
  }) async {
    final body = <String, dynamic>{};
    if (coverLetter != null && coverLetter.isNotEmpty) {
      body['coverLetter'] = coverLetter;
    }
    if (proposedPrice != null && proposedPrice.isNotEmpty) {
      body['proposedPrice'] = proposedPrice;
    }

    final response = await _apiService.post(
      ApiEndpoints.needWorkerApplyEndpoint(postId),
      body,
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return NeedWorkerApplicationModel.fromJson(data);
  }

  /// 9. Get my applications (GET /need-worker/applications/me)
  Future<PaginatedResponse<NeedWorkerApplicationModel>> getMyApplications({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (status != null && status.isNotEmpty) {
      queryParams.add('status=${status.toUpperCase()}');
    }
    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.needWorkerMyApplicationsEndpoint}$queryString',
    );
    return _parsePaginatedApplications(response.body);
  }

  /// 10. Withdraw application (PATCH /need-worker/application/:id/withdraw)
  Future<NeedWorkerApplicationModel> withdrawApplication(
    String applicationId,
  ) async {
    final response = await _apiService.patch(
      ApiEndpoints.needWorkerWithdrawEndpoint(applicationId),
      {},
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return NeedWorkerApplicationModel.fromJson(data);
  }

  // ─── Application Management (Requester Actions) ───

  /// 11. Get applications for a post (GET /need-worker/:id/applications)
  Future<PaginatedResponse<NeedWorkerApplicationModel>> getPostApplications(
    String postId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (status != null && status.isNotEmpty) {
      queryParams.add('status=${status.toUpperCase()}');
    }
    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.needWorkerPostApplicationsEndpoint(postId)}$queryString',
    );
    return _parsePaginatedApplications(response.body);
  }

  /// 12. Accept application (PATCH /need-worker/application/:id/accept)
  Future<NeedWorkerApplicationModel> acceptApplication(
    String applicationId,
  ) async {
    final response = await _apiService.patch(
      ApiEndpoints.needWorkerAcceptEndpoint(applicationId),
      {},
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return NeedWorkerApplicationModel.fromJson(data);
  }

  /// 13. Reject application (PATCH /need-worker/application/:id/reject)
  Future<NeedWorkerApplicationModel> rejectApplication(
    String applicationId,
  ) async {
    final response = await _apiService.patch(
      ApiEndpoints.needWorkerRejectEndpoint(applicationId),
      {},
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return NeedWorkerApplicationModel.fromJson(data);
  }

  // ─── Helpers ───

  PaginatedResponse<NeedWorkerModel> _parsePaginatedPosts(String body) {
    final dynamic resBody = jsonDecode(body);
    List<dynamic> dataList = [];
    SearchMeta meta;

    if (resBody is List) {
      dataList = resBody;
      meta = SearchMeta(
        total: dataList.length,
        page: 1,
        limit: 50,
        totalPages: 1,
      );
    } else if (resBody is Map<String, dynamic>) {
      final rawData = resBody['data'];
      if (rawData is List) {
        dataList = rawData;
      } else if (rawData is Map<String, dynamic>) {
        dataList = (rawData['posts'] ??
                rawData['items'] ??
                rawData['needWorkers'] ??
                rawData['data'] ??
                rawData['results']) as List? ??
            [];
      } else {
        dataList = (resBody['posts'] ??
                resBody['needWorkers'] ??
                resBody['items'] ??
                resBody['results']) as List? ??
            [];
      }
      if (resBody['meta'] is Map<String, dynamic>) {
        meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
      } else if (rawData is Map<String, dynamic> &&
          rawData['meta'] is Map<String, dynamic>) {
        meta = SearchMeta.fromJson(rawData['meta'] as Map<String, dynamic>);
      } else {
        meta = SearchMeta(
          total: dataList.length,
          page: 1,
          limit: 50,
          totalPages: 1,
        );
      }
    } else {
      meta = SearchMeta(total: 0, page: 1, limit: 50, totalPages: 1);
    }

    final posts = dataList
        .whereType<Map<String, dynamic>>()
        .map((item) => NeedWorkerModel.fromJson(item))
        .toList();

    return PaginatedResponse(data: posts, meta: meta);
  }

  PaginatedResponse<NeedWorkerApplicationModel> _parsePaginatedApplications(
    String body,
  ) {
    final Map<String, dynamic> resBody = jsonDecode(body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final apps = dataList
        .map(
          (item) =>
              NeedWorkerApplicationModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(total: apps.length, page: 1, limit: 10, totalPages: 1);
    }

    return PaginatedResponse(data: apps, meta: meta);
  }
}
