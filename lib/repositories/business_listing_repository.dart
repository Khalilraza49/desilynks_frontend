import 'dart:convert';
import 'dart:io';
import '../models/business_listing_model.dart';
import '../models/search_result_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class BusinessListingRepository {
  final ApiService _apiService;

  BusinessListingRepository(this._apiService);

  /// 1. Create Business Listing (POST /business-listing - multipart/form-data)
  Future<BusinessListingModel> createBusinessListing({
    required String name,
    required String category,
    required String address,
    required String phone,
    String? whatsApp,
    String? website,
    required String description,
    required String monToFriStartTime,
    required String monToFriEndTime,
    required String saturdayStartTime,
    required String saturdayEndTime,
    String? sundayStartTime,
    String? sundayEndTime,
    required bool isClosedOnSunday,
    File? logo,
    File? coverPhoto,
    List<File>? gallery,
  }) async {
    final fields = <String, String>{
      'name': name,
      'categoryId': category.trim(),
      'address': address,
      'phone': phone,
      if (whatsApp != null && whatsApp.isNotEmpty) 'whatsApp': whatsApp,
      if (website != null && website.isNotEmpty) 'website': website,
      'description': description,
      'monToFriStartTime': monToFriStartTime,
      'monToFriEndTime': monToFriEndTime,
      'saturdayStartTime': saturdayStartTime,
      'saturdayEndTime': saturdayEndTime,
      if (sundayStartTime != null && sundayStartTime.isNotEmpty)
        'sundayStartTime': sundayStartTime,
      if (sundayEndTime != null && sundayEndTime.isNotEmpty)
        'sundayEndTime': sundayEndTime,
      'isClosedOnSunday': isClosedOnSunday ? 'true' : 'false',
    };

    final filesMap = <String, List<File>>{};
    if (logo != null) filesMap['logo'] = [logo];
    if (coverPhoto != null) filesMap['coverPhoto'] = [coverPhoto];
    if (gallery != null && gallery.isNotEmpty) filesMap['gallery'] = gallery;

    final response = await _apiService.multipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.businessListingEndpoint,
      fields: fields,
      filesMap: filesMap.isNotEmpty ? filesMap : null,
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return BusinessListingModel.fromJson(data);
  }

  /// 2. Get User Business Listings (GET /business-listing/my-listings)
  Future<PaginatedResponse<BusinessListingModel>> getMyListings({
    int page = 1,
    int limit = 10,
    String? status,
    String? category,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (status != null && status.isNotEmpty) {
      queryParams.add('status=${status.toUpperCase()}');
    }
    if (category != null && category.isNotEmpty) {
      if (RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(category.trim())) {
        queryParams.add('categoryId=${category.trim()}');
      } else {
        queryParams.add('category=${category.toUpperCase()}');
      }
    }

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.businessListingMyListingsEndpoint}$queryString',
    );

    return _parsePaginatedResponse(response.body);
  }

  /// 3. Get All Business Listings (GET /business-listing)
  Future<PaginatedResponse<BusinessListingModel>> getAllListings({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (category != null && category.isNotEmpty) {
      if (RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(category.trim())) {
        queryParams.add('categoryId=${category.trim()}');
      } else {
        queryParams.add('category=${category.toUpperCase()}');
      }
    }

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.businessListingEndpoint}$queryString',
    );

    return _parsePaginatedResponse(response.body);
  }

  /// 4. Get Business Listing Analytics (GET /business-listing/:id/analytics)
  Future<BusinessAnalyticsModel> getListingAnalytics(
    String id, {
    String period = 'THIS_MONTH',
  }) async {
    final response = await _apiService.get(
      '${ApiEndpoints.businessListingAnalyticsEndpoint(id)}?period=${period.toUpperCase()}',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return BusinessAnalyticsModel.fromJson(data);
  }

  /// 5. Get Business Listing By ID (GET /business-listing/:id)
  Future<BusinessListingModel> getListingById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.businessListingByIdEndpoint(id),
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return BusinessListingModel.fromJson(data);
  }

  /// 6. Update Business Listing Details (PATCH /business-listing/:id)
  Future<BusinessListingModel> updateListingDetails(
    String id, {
    String? name,
    String? category,
    String? address,
    String? phone,
    String? whatsApp,
    String? website,
    String? description,
    String? monToFriStartTime,
    String? monToFriEndTime,
    String? saturdayStartTime,
    String? saturdayEndTime,
    String? sundayStartTime,
    String? sundayEndTime,
    bool? isClosedOnSunday,
  }) async {
    final body = <String, dynamic>{
      'name': ?name,
      if (category != null) 'categoryId': category.trim(),
      'address': ?address,
      'phone': ?phone,
      'whatsApp': ?whatsApp,
      'website': ?website,
      'description': ?description,
      'monToFriStartTime': ?monToFriStartTime,
      'monToFriEndTime': ?monToFriEndTime,
      'saturdayStartTime': ?saturdayStartTime,
      'saturdayEndTime': ?saturdayEndTime,
      'sundayStartTime': ?sundayStartTime,
      'sundayEndTime': ?sundayEndTime,
      'isClosedOnSunday': ?isClosedOnSunday,
    };

    final response = await _apiService.patch(
      ApiEndpoints.businessListingUpdateEndpoint(id),
      body,
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return BusinessListingModel.fromJson(data);
  }

  /// 7. Update Business Listing Status (PATCH /business-listing/:id/status)
  Future<BusinessListingModel> updateListingStatus(
    String id,
    String status,
  ) async {
    final response = await _apiService.patch(
      ApiEndpoints.businessListingStatusEndpoint(id),
      {'status': status.toUpperCase()},
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return BusinessListingModel.fromJson(data);
  }

  /// 8. Update Business Logo (PATCH /business-listing/:id/logo)
  Future<BusinessListingModel> updateLogo(String id, File logoFile) async {
    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.businessListingLogoEndpoint(id),
      fields: {},
      singleFile: logoFile,
      singleFileKey: 'logo',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return BusinessListingModel.fromJson(data);
  }

  /// 9. Update Business Cover Photo (PATCH /business-listing/:id/cover-photo)
  Future<BusinessListingModel> updateCoverPhoto(
    String id,
    File coverPhotoFile,
  ) async {
    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.businessListingCoverPhotoEndpoint(id),
      fields: {},
      singleFile: coverPhotoFile,
      singleFileKey: 'coverPhoto',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return BusinessListingModel.fromJson(data);
  }

  /// 10. Update Business Gallery (PATCH /business-listing/:id/gallery)
  Future<BusinessListingModel?> updateGallery(
    String id, {
    List<String>? photosToRemove,
    List<File>? newPhotos,
  }) async {
    final fields = <String, String>{};
    if (photosToRemove != null && photosToRemove.isNotEmpty) {
      fields['photosToRemove'] = jsonEncode(photosToRemove);
    }

    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.businessListingGalleryEndpoint(id),
      fields: fields,
      files: newPhotos,
      filesKey: 'gallery',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    if (resBody['data'] == null) return null;
    final data = resBody['data'] as Map<String, dynamic>;
    return BusinessListingModel.fromJson(data);
  }

  /// 11. Record Business Listing Click (POST /business-listing/:id/click)
  Future<void> recordClick(String id) async {
    await _apiService.post(ApiEndpoints.businessListingClickEndpoint(id), {});
  }

  /// 12. Delete Business Listing (DELETE /business-listing/:id)
  Future<void> deleteListing(String id) async {
    await _apiService.delete(ApiEndpoints.businessListingDeleteEndpoint(id));
  }

  // Helper
  PaginatedResponse<BusinessListingModel> _parsePaginatedResponse(String body) {
    final Map<String, dynamic> resBody = jsonDecode(body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final listings = dataList
        .map(
          (item) => BusinessListingModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: listings.length,
        page: 1,
        limit: 10,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: listings, meta: meta);
  }
}
