import 'dart:convert';
import '../models/explore_country_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class ExploreCountryRepository {
  final ApiService _apiService;

  ExploreCountryRepository(this._apiService);

  /// Fetch paginated list of explore countries.
  ///
  /// NOTE: The backend global pipe strictly forbids non-whitelisted query params;
  /// ONLY [page] and [limit] are allowed.
  Future<ExploreCountryListResponse> getCountries({
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '${ApiEndpoints.exploreCountryEndpoint}?$queryString';

    final response = await _apiService.get(endpoint);
    final Map<String, dynamic> body = jsonDecode(response.body);
    return ExploreCountryListResponse.fromJson(body);
  }

  /// Fetch single explore country detail by UUID.
  /// Includes full nested banner, emergency numbers, and popular cities.
  Future<ExploreCountry> getCountryDetail(String id) async {
    final endpoint = ApiEndpoints.exploreCountryDetailEndpoint(id);
    final response = await _apiService.get(endpoint);
    final Map<String, dynamic> body = jsonDecode(response.body);
    final data = body['data'] as Map<String, dynamic>? ?? body;
    return ExploreCountry.fromJson(data);
  }
}
