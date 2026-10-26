import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/banner_ad_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class BannerAdRepository {
  final ApiService _apiService;

  BannerAdRepository(this._apiService);

  // 5.1 Create banner ad (POST /banner-ad - multipart/form-data)
  Future<BannerAdModel> createBannerAd({
    required File photo,
    required String title,
    required String description,
    required String ctaButtonText,
    required String destinationLink,
    required String position,
  }) async {
    final fields = <String, String>{
      'title': title.trim(),
      'description': description.trim(),
      'ctaButtonText': ctaButtonText.trim(),
      'destinationLink': destinationLink.trim(),
      'position': position.trim(),
    };

    final response = await _apiService.multipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.bannerAdEndpoint,
      fields: fields,
      singleFile: photo,
      singleFileKey: 'photo',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return BannerAdModel.fromJson(data);
  }

  // 5.2 Get my banner ads (GET /banner-ad/my-ads)
  Future<Map<String, dynamic>> getMyBannerAds({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = <String>[
      'page=$page',
      'limit=$limit',
      if (status != null && status.isNotEmpty) 'status=$status',
    ];

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '${ApiEndpoints.myBannerAdsEndpoint}$queryString',
    );

    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];

    final ads = dataList
        .whereType<Map<String, dynamic>>()
        .map((item) => BannerAdModel.fromJson(item))
        .toList();

    return {'data': ads, 'meta': body['meta'] ?? {}};
  }

  // 5.3 Get all banner ads (audience) (GET /banner-ad)
  Future<Map<String, dynamic>> getPublicBannerAds({
    int page = 1,
    int limit = 10,
    String? position,
    String? search,
  }) async {
    final queryParams = <String>[
      'page=$page',
      'limit=$limit',
      if (position != null && position.isNotEmpty) 'position=$position',
      if (search != null && search.trim().isNotEmpty)
        'search=${Uri.encodeComponent(search.trim())}',
    ];

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '${ApiEndpoints.bannerAdEndpoint}$queryString',
    );

    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];

    final ads = dataList
        .whereType<Map<String, dynamic>>()
        .map((item) => BannerAdModel.fromJson(item))
        .toList();

    return {'data': ads, 'meta': body['meta'] ?? {}};
  }

  // 5.4 Get banner ad by id (GET /banner-ad/:id)
  Future<BannerAdModel> getBannerAdById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.bannerAdByIdEndpoint(id),
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final data = body['data'] as Map<String, dynamic>;
    return BannerAdModel.fromJson(data);
  }

  // 5.5 Update banner ad details (PATCH /banner-ad/:id)
  Future<BannerAdModel> updateBannerAdDetails(
    String id, {
    required String title,
    required String description,
    required String ctaButtonText,
    required String destinationLink,
    required String position,
  }) async {
    final body = <String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'ctaButtonText': ctaButtonText.trim(),
      'destinationLink': destinationLink.trim(),
      'position': position.trim(),
    };

    final response = await _apiService.patch(
      ApiEndpoints.bannerAdByIdEndpoint(id),
      body,
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return BannerAdModel.fromJson(data);
  }

  // 5.6 Update banner ad photo (PATCH /banner-ad/:id/photo - multipart)
  Future<BannerAdModel> updateBannerAdPhoto(String id, File photo) async {
    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.bannerAdPhotoEndpoint(id),
      fields: <String, String>{},
      singleFile: photo,
      singleFileKey: 'photo',
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return BannerAdModel.fromJson(data);
  }

  // 5.7 Update banner ad status (PATCH /banner-ad/:id/status)
  Future<BannerAdModel> updateBannerAdStatus(String id, String status) async {
    final response = await _apiService.patch(
      ApiEndpoints.bannerAdStatusEndpoint(id),
      {'status': status},
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return BannerAdModel.fromJson(data);
  }

  // 5.8 Renew banner ad (PATCH /banner-ad/:id/renew)
  Future<BannerAdModel> renewBannerAd(String id) async {
    final response = await _apiService.patch(
      ApiEndpoints.bannerAdRenewEndpoint(id),
      {},
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return BannerAdModel.fromJson(data);
  }

  // 5.9 Record view (POST /banner-ad/:id/view)
  Future<bool> recordView(String id) async {
    try {
      await _apiService.post(ApiEndpoints.bannerAdViewEndpoint(id), {});
      return true;
    } catch (e) {
      debugPrint('BannerAdRepository: Failed to record view for $id: $e');
      return false;
    }
  }

  // 5.10 Record click (POST /banner-ad/:id/click)
  Future<bool> recordClick(String id) async {
    try {
      await _apiService.post(ApiEndpoints.bannerAdClickEndpoint(id), {});
      return true;
    } catch (e) {
      debugPrint('BannerAdRepository: Failed to record click for $id: $e');
      return false;
    }
  }

  // 5.11 Delete banner ad (DELETE /banner-ad/:id)
  Future<bool> deleteBannerAd(String id) async {
    try {
      await _apiService.delete(ApiEndpoints.bannerAdByIdEndpoint(id));
      return true;
    } catch (e) {
      debugPrint('BannerAdRepository: Failed to delete banner ad $id: $e');
      return false;
    }
  }
}
