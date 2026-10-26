import 'dart:convert';
import '../models/resource_hub_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class ResourceHubRepository {
  final ApiService _apiService;

  ResourceHubRepository(this._apiService);

  Map<String, String> _buildQueryParams({
    required int page,
    int limit = 10,
    String? search,
    ResourceHubCategory? category,
  }) {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    // Only send category when a valid known category is selected.
    // Leaving it out matches "All" categories on the backend.
    if (category != null && category != ResourceHubCategory.unknown) {
      params['category'] = category.value;
    }
    return params;
  }

  String _buildUrl(String basePath, Map<String, String> queryParams) {
    final query = Uri(queryParameters: queryParams).query;
    return query.isEmpty ? basePath : '$basePath?$query';
  }

  /// Get paginated articles with optional search and category filters
  Future<ResourceHubListResponse> getArticles({
    int page = 1,
    int limit = 10,
    String? search,
    ResourceHubCategory? category,
  }) async {
    final params = _buildQueryParams(
      page: page,
      limit: limit,
      search: search,
      category: category,
    );
    final endpoint = _buildUrl(ApiEndpoints.resourceHubEndpoint, params);
    final response = await _apiService.get(endpoint);
    final Map<String, dynamic> body = jsonDecode(response.body);
    return ResourceHubListResponse.fromJson(body);
  }

  /// Get paginated saved articles for the authenticated user
  Future<ResourceHubListResponse> getSavedArticles({
    int page = 1,
    int limit = 10,
    String? search,
    ResourceHubCategory? category,
  }) async {
    final params = _buildQueryParams(
      page: page,
      limit: limit,
      search: search,
      category: category,
    );
    final endpoint = _buildUrl(ApiEndpoints.resourceHubSavedEndpoint, params);
    final response = await _apiService.get(endpoint);
    final Map<String, dynamic> body = jsonDecode(response.body);
    return ResourceHubListResponse.fromJson(body);
  }

  /// Get full article detail (including Markdown content)
  Future<ResourceHubArticle> getArticleDetail(String id) async {
    final endpoint = ApiEndpoints.resourceHubDetailEndpoint(id);
    final response = await _apiService.get(endpoint);
    final Map<String, dynamic> body = jsonDecode(response.body);
    final articleData = body['data'] as Map<String, dynamic>? ?? body;
    return ResourceHubArticle.fromJson(articleData);
  }

  /// Save an article (requires authentication)
  Future<bool> saveArticle(String id) async {
    final endpoint = ApiEndpoints.resourceHubSaveEndpoint(id);
    final response = await _apiService.post(endpoint);
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['saved'] as bool? ?? true;
  }

  /// Unsave an article (requires authentication)
  Future<bool> unsaveArticle(String id) async {
    final endpoint = ApiEndpoints.resourceHubSaveEndpoint(id);
    final response = await _apiService.delete(endpoint);
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['saved'] as bool? ?? false;
  }
}
