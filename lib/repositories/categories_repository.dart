import 'dart:convert';
import '../models/category_item.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class CategoriesRepository {
  final ApiService _apiService;

  CategoriesRepository(this._apiService);

  Future<List<CategoryItem>> _fetch(String endpoint) async {
    final response = await _apiService.get(endpoint);
    final dynamic body = jsonDecode(response.body);
    final List<dynamic> data;
    if (body is List) {
      data = body;
    } else if (body is Map<String, dynamic>) {
      data = body['data'] as List? ??
          body['types'] as List? ??
          body['categories'] as List? ??
          [];
    } else {
      data = [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => CategoryItem.fromJson(e))
        .toList();
  }

  Future<List<CategoryItem>> fetchBusinessCategories() =>
      _fetch(ApiEndpoints.businessCategoriesEndpoint);

  Future<List<CategoryItem>> fetchJobCategories() =>
      _fetch(ApiEndpoints.jobCategoriesEndpoint);

  Future<List<CategoryItem>> fetchNeedWorkerTypes() =>
      _fetch(ApiEndpoints.needWorkerTypesEndpoint);

  Future<List<CategoryItem>> fetchPropertyFeatures() =>
      _fetch(ApiEndpoints.propertyFeaturesEndpoint);
}
