import 'dart:convert';
import '../models/property_model.dart';
import '../models/job_model.dart';
import '../models/worker_profile_model.dart';
import '../models/search_result_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class SearchRepository {
  final ApiService _apiService;

  SearchRepository(this._apiService);

  /// Build query string from a map, skipping null/empty values.
  String _buildQuery(Map<String, dynamic> params) {
    final filtered = params.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}');
    return filtered.isEmpty ? '' : '?${filtered.join('&')}';
  }

  /// Helper to extract list from diverse response structures
  List<dynamic> _extractList(Map<String, dynamic> body) {
    if (body['data'] is List) {
      return body['data'] as List;
    }
    if (body['data'] is Map<String, dynamic>) {
      final mapData = body['data'] as Map<String, dynamic>;
      if (mapData['items'] is List) return mapData['items'] as List;
      if (mapData['properties'] is List) return mapData['properties'] as List;
      if (mapData['jobs'] is List) return mapData['jobs'] as List;
      if (mapData['workers'] is List) return mapData['workers'] as List;
      if (mapData['results'] is List) return mapData['results'] as List;
    }
    if (body['items'] is List) return body['items'] as List;
    if (body['properties'] is List) return body['properties'] as List;
    if (body['jobs'] is List) return body['jobs'] as List;
    if (body['workers'] is List) return body['workers'] as List;
    if (body['results'] is List) return body['results'] as List;
    return [];
  }

  // ─── 1. Properties Search ───

  /// Search properties with optional filters.
  Future<PaginatedResponse<PropertyModel>> searchProperties({
    String? query,
    String? type,
    String? status,
    String? contactPreference,
    double? minRent,
    double? maxRent,
    int? minBedrooms,
    int? minBathrooms,
    bool? billsIncluded,
    String? location,
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryString = _buildQuery({
        'query': query,
        'type': type,
        'status': status,
        'contactPreference': contactPreference,
        'minRent': minRent?.toString(),
        'maxRent': maxRent?.toString(),
        'minBedrooms': minBedrooms?.toString(),
        'minBathrooms': minBathrooms?.toString(),
        'billsIncluded': billsIncluded?.toString(),
        'location': location,
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      });

      final response = await _apiService.get(
        '${ApiEndpoints.searchPropertiesEndpoint}$queryString',
      );
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> dataList = _extractList(body);

      final items = dataList
          .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final meta = body['meta'] is Map<String, dynamic>
          ? SearchMeta.fromJson(body['meta'] as Map<String, dynamic>)
          : SearchMeta(
              total: items.length,
              page: page,
              limit: limit,
              totalPages: 1,
            );

      return PaginatedResponse(data: items, meta: meta);
    } catch (_) {
      // Fallback: If /search/properties fails, query standard properties feed and filter locally
      try {
        final fallbackResponse = await _apiService.get(
          '${ApiEndpoints.propertyEndpoint}?page=$page&limit=50',
        );
        final Map<String, dynamic> body = jsonDecode(fallbackResponse.body);
        final List<dynamic> dataList = _extractList(body);
        var items = dataList
            .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (query != null && query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          items = items.where((p) {
            return p.title.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q) ||
                p.location.toLowerCase().contains(q) ||
                p.type.toLowerCase().contains(q);
          }).toList();
        }
        return PaginatedResponse(
          data: items,
          meta: SearchMeta(
            total: items.length,
            page: page,
            limit: limit,
            totalPages: 1,
          ),
        );
      } catch (_) {
        rethrow;
      }
    }
  }

  // ─── 2. Jobs Search ───

  /// Search jobs with optional filters.
  Future<PaginatedResponse<JobModel>> searchJobs({
    String? query,
    String? category,
    String? type,
    String? workMode,
    String? experience,
    String? education,
    String? salaryPeriod,
    String? status,
    double? minSalary,
    double? maxSalary,
    String? location,
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryString = _buildQuery({
        'query': query,
        'category': category,
        'type': type,
        'workMode': workMode,
        'experience': experience,
        'education': education,
        'salaryPeriod': salaryPeriod,
        'status': status,
        'minSalary': minSalary?.toString(),
        'maxSalary': maxSalary?.toString(),
        'location': location,
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      });

      final response = await _apiService.get(
        '${ApiEndpoints.searchJobsEndpoint}$queryString',
      );
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> dataList = _extractList(body);

      final items = dataList
          .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final meta = body['meta'] is Map<String, dynamic>
          ? SearchMeta.fromJson(body['meta'] as Map<String, dynamic>)
          : SearchMeta(
              total: items.length,
              page: page,
              limit: limit,
              totalPages: 1,
            );

      return PaginatedResponse(data: items, meta: meta);
    } catch (_) {
      // Fallback: If /search/jobs fails, query standard jobs feed and filter locally
      try {
        final fallbackResponse = await _apiService.get(
          '${ApiEndpoints.jobEndpoint}?page=$page&limit=50',
        );
        final Map<String, dynamic> body = jsonDecode(fallbackResponse.body);
        final List<dynamic> dataList = _extractList(body);
        var items = dataList
            .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (query != null && query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          items = items.where((j) {
            return j.title.toLowerCase().contains(q) ||
                j.companyName.toLowerCase().contains(q) ||
                j.location.toLowerCase().contains(q) ||
                j.requiredSkills.toLowerCase().contains(q) ||
                j.description.toLowerCase().contains(q);
          }).toList();
        }
        return PaginatedResponse(
          data: items,
          meta: SearchMeta(
            total: items.length,
            page: page,
            limit: limit,
            totalPages: 1,
          ),
        );
      } catch (_) {
        rethrow;
      }
    }
  }

  // ─── 3. Worker Profiles Search ───

  /// Search worker profiles with optional filters.
  Future<PaginatedResponse<WorkerProfileModel>> searchWorkerProfiles({
    String? query,
    String? service,
    bool? isAvailableToday,
    bool? ownVehicle,
    bool? ownTools,
    double? maxHourlyRate,
    double? maxDailyRate,
    int? minExperienceYears,
    String? areaCovered,
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryString = _buildQuery({
        'query': query,
        'service': service,
        'isAvailableToday': isAvailableToday?.toString(),
        'ownVehicle': ownVehicle?.toString(),
        'ownTools': ownTools?.toString(),
        'maxHourlyRate': maxHourlyRate?.toString(),
        'maxDailyRate': maxDailyRate?.toString(),
        'minExperienceYears': minExperienceYears?.toString(),
        'areaCovered': areaCovered,
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      });

      final response = await _apiService.get(
        '${ApiEndpoints.searchWorkerProfilesEndpoint}$queryString',
      );
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> dataList = _extractList(body);

      final items = dataList
          .map(
            (item) => WorkerProfileModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      final meta = body['meta'] is Map<String, dynamic>
          ? SearchMeta.fromJson(body['meta'] as Map<String, dynamic>)
          : SearchMeta(
              total: items.length,
              page: page,
              limit: limit,
              totalPages: 1,
            );

      return PaginatedResponse(data: items, meta: meta);
    } catch (_) {
      // Fallback: If /search/worker-profiles fails, query standard workers feed and filter locally
      try {
        final fallbackResponse = await _apiService.get(
          '${ApiEndpoints.workerProfileEndpoint}?page=$page&limit=50',
        );
        final Map<String, dynamic> body = jsonDecode(fallbackResponse.body);
        final List<dynamic> dataList = _extractList(body);
        var items = dataList
            .map(
              (item) =>
                  WorkerProfileModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        if (query != null && query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          items = items.where((w) {
            return w.profession.toLowerCase().contains(q) ||
                w.service.toLowerCase().contains(q) ||
                w.areaCovered.toLowerCase().contains(q) ||
                w.about.toLowerCase().contains(q) ||
                w.languages.any((l) => l.toLowerCase().contains(q));
          }).toList();
        }
        return PaginatedResponse(
          data: items,
          meta: SearchMeta(
            total: items.length,
            page: page,
            limit: limit,
            totalPages: 1,
          ),
        );
      } catch (_) {
        rethrow;
      }
    }
  }

  // ─── 4. Autocomplete / Suggestions ───

  /// Get autocomplete suggestions. Debounce in ViewModel (300ms).
  Future<List<String>> getSuggestions({
    required String query,
    String index = 'properties',
    String field = 'title',
    int size = 5,
  }) async {
    try {
      final queryString = _buildQuery({
        'query': query,
        'index': index,
        'field': field,
        'size': size.toString(),
      });

      final response = await _apiService.get(
        '${ApiEndpoints.searchSuggestEndpoint}$queryString',
      );
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> suggestions =
          body['suggestions'] as List<dynamic>? ?? [];
      return suggestions.map((s) => s.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── 5. Health Check ───

  /// Get Elasticsearch cluster health and index counts.
  Future<SearchHealthModel> getHealth() async {
    final response = await _apiService.get(ApiEndpoints.searchHealthEndpoint);
    final Map<String, dynamic> body = jsonDecode(response.body);
    return SearchHealthModel.fromJson(body);
  }
}
