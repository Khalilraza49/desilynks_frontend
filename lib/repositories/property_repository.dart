import 'dart:convert';
import 'dart:io';
import '../models/property_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class PropertyRepository {
  final ApiService _apiService;

  PropertyRepository(this._apiService);

  // 1. Get paginated public properties (GET /property)
  Future<Map<String, dynamic>> getProperties({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    final safeLimit = (limit > 50 || limit < 1) ? 50 : limit;
    String query = '?page=$page&limit=$safeLimit';
    if (type != null && type.isNotEmpty) {
      query += '&type=${type.toUpperCase()}';
    }

    final response = await _apiService.get(
      '${ApiEndpoints.propertyEndpoint}$query',
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];

    final properties = dataList
        .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return {'properties': properties, 'meta': body['meta'] ?? {}};
  }

  // 2. Get paginated properties owned by authenticated user (GET /property/user)
  Future<Map<String, dynamic>> getUserProperties({
    int page = 1,
    int limit = 10,
  }) async {
    final safeLimit = (limit > 50 || limit < 1) ? 50 : limit;
    final query = '?page=$page&limit=$safeLimit';
    final response = await _apiService.get(
      '${ApiEndpoints.userPropertiesEndpoint}$query',
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];

    final properties = dataList
        .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return {'properties': properties, 'meta': body['meta'] ?? {}};
  }

  // 3. Get full details of a single property (GET /property/:id)
  Future<PropertyModel> getPropertyDetails(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.propertyDetailsEndpoint(id),
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    return PropertyModel.fromJson(body);
  }

  // 4. Create new property (POST /property)
  Future<PropertyModel> createProperty({
    required String type,
    required String title,
    required String description,
    required String monthlyRent,
    String? deposit, // Deprecated: removed from backend schema
    bool? billsIncluded, // Deprecated: removed from backend schema
    required String availableFrom,
    required String location,
    required int noOfBedRooms,
    required int noOfBathRooms,
    List<String>? featuresAndAmenities, // Deprecated
    List<String>? featureIds,
    required String contactPreference,
    required List<File> photos,
    File? videoTour, // Deprecated: removed from backend schema
  }) async {
    final Map<String, String> fields = {
      'type': type.toUpperCase(),
      'title': title,
      'description': description,
      'monthlyRent': monthlyRent,
      'availableFrom': availableFrom, // ISO Date format e.g. "2026-08-01"
      'location': location,
      'noOfBedRooms': noOfBedRooms.toString(),
      'noOfBathRooms': noOfBathRooms.toString(),
      'contactPreference': contactPreference
          .toUpperCase(), // CHAT, CALL, or WHATSAPP
    };

    if (featureIds != null && featureIds.isNotEmpty) {
      fields['featureIds'] = jsonEncode(featureIds);
    }

    final response = await _apiService.multipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.propertyEndpoint,
      fields: fields,
      files: photos,
      filesKey: 'photos',
    );

    final Map<String, dynamic> body = jsonDecode(response.body);
    return PropertyModel.fromJson(body);
  }

  // 5. Update text details (PATCH /property/:id)
  Future<PropertyModel> updatePropertyDetails(
    String id, {
    required String type,
    required String title,
    required String description,
    required String monthlyRent,
    String? deposit, // Deprecated
    bool? billsIncluded, // Deprecated
    required String availableFrom,
    required String location,
    required int noOfBedRooms,
    required int noOfBathRooms,
    List<String>? featuresAndAmenities, // Deprecated
    List<String>? featureIds,
    String? contactPreference,
  }) async {
    final Map<String, dynamic> body = {
      'type': type.toUpperCase(),
      'title': title,
      'description': description,
      'monthlyRent': monthlyRent,
      'availableFrom': availableFrom,
      'location': location,
      'noOfBedRooms': noOfBedRooms,
      'noOfBathRooms': noOfBathRooms,
      if (featureIds != null && featureIds.isNotEmpty) 'featureIds': featureIds,
      'contactPreference':
          (contactPreference != null && contactPreference.isNotEmpty)
          ? contactPreference.toUpperCase()
          : 'CHAT',
    };

    final response = await _apiService.patch(
      ApiEndpoints.propertyDetailsEndpoint(id),
      body,
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    return PropertyModel.fromJson(resBody);
  }

  // 6. Update property photos (PATCH /property/:id/photos)
  Future<PropertyModel> updatePropertyPhotos(
    String id, {
    List<File>? newPhotos,
    List<String>? photosToRemove,
  }) async {
    final Map<String, String> fields = {};
    if (photosToRemove != null && photosToRemove.isNotEmpty) {
      fields['photosToRemove'] = jsonEncode(photosToRemove);
    }

    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.propertyPhotosEndpoint(id),
      fields: fields,
      files: newPhotos,
      filesKey: 'photos',
    );

    final Map<String, dynamic> body = jsonDecode(response.body);
    return PropertyModel.fromJson(body);
  }

  // 7. Update property video tour (PATCH /property/:id/video)
  Future<PropertyModel> updatePropertyVideo(
    String id, {
    File? videoTour,
    bool removeVideo = false,
  }) async {
    final Map<String, String> fields = {'removeVideo': removeVideo.toString()};

    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.propertyVideoEndpoint(id),
      fields: fields,
      singleFile: videoTour,
      singleFileKey: 'videoTour',
    );

    final Map<String, dynamic> body = jsonDecode(response.body);
    return PropertyModel.fromJson(body);
  }

  // 8. Mark property as rented (PATCH /property/:id/mark-rented)
  Future<String> markPropertyAsRented(String id) async {
    final response = await _apiService.patch(
      ApiEndpoints.propertyMarkRentedEndpoint(id),
      {},
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['message'] ?? 'Property successfully marked as Rented';
  }

  // 9. Mark property as inactive (PATCH /property/:id/mark-inactive)
  Future<String> markPropertyAsInactive(String id) async {
    final response = await _apiService.patch(
      ApiEndpoints.propertyMarkInactiveEndpoint(id),
      {},
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['message'] ?? 'Property successfully marked as Inactive';
  }

  // 10. Mark property as active (PATCH /property/:id/mark-active)
  Future<String> markPropertyAsActive(String id) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.propertyMarkActiveEndpoint(id),
        {},
      );
      final Map<String, dynamic> body = jsonDecode(response.body);
      return body['message'] ?? 'Property successfully marked as Active';
    } catch (e) {
      try {
        final response = await _apiService.patch(
          '/property/$id/activate',
          {},
        );
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['message'] ?? 'Property successfully marked as Active';
      } catch (_) {
        rethrow;
      }
    }
  }

  // 11. Like property (POST /property/:id/like)
  Future<bool> likeProperty(String id) async {
    final response = await _apiService.post(
      ApiEndpoints.propertyLikeEndpoint(id),
      {},
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['liked'] as bool? ?? true;
  }

  // 11. Unlike property (DELETE /property/:id/like)
  Future<bool> unlikeProperty(String id) async {
    final response = await _apiService.delete(
      ApiEndpoints.propertyLikeEndpoint(id),
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['liked'] as bool? ?? false;
  }

  // 12. Delete property (DELETE /property/:id)
  Future<String> deleteProperty(String id) async {
    final response = await _apiService.delete(
      ApiEndpoints.propertyDetailsEndpoint(id),
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['message'] ?? 'Property successfully deleted';
  }
}
