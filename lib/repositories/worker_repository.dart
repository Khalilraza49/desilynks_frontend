import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/worker_profile_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class WorkerRepository {
  final ApiService _apiService;

  WorkerRepository(this._apiService);

  // 1. Create Worker Profile (POST /worker-profile - multipart/form-data)
  Future<WorkerProfileModel> createWorkerProfile({
    required File profilePhoto,
    List<File>? workPhotos,
    List<File>? certificates,
    required String service,
    required String experienceInYears,
    required String hourlyRate,
    required String dailyRate,
    required List<String> languagesSpoken,
    required bool isAvailableToday,
    required bool ownVehicle,
    required bool ownTools,
    required String areaCovered,
    required String about,
  }) async {
    final fields = <String, String>{
      'service': service.toUpperCase(),
      'experienceInYears': experienceInYears,
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'languagesSpoken': jsonEncode(languagesSpoken),
      'isAvailableToday': isAvailableToday ? 'true' : 'false',
      'ownVehicle': ownVehicle ? 'true' : 'false',
      'ownTools': ownTools ? 'true' : 'false',
      'areaCovered': areaCovered,
      'about': about,
    };

    final filesMap = <String, List<File>>{};
    if (workPhotos != null && workPhotos.isNotEmpty) {
      filesMap['workPhotos'] = workPhotos;
    }
    if (certificates != null && certificates.isNotEmpty) {
      filesMap['certificates'] = certificates;
    }

    final response = await _apiService.multipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.workerProfileEndpoint,
      fields: fields,
      singleFile: profilePhoto,
      singleFileKey: 'profilePhoto',
      filesMap: filesMap.isNotEmpty ? filesMap : null,
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return WorkerProfileModel.fromJson(data);
  }

  // 2. Update Worker Profile Details (PATCH /worker-profile/:id - multipart/form-data)
  Future<WorkerProfileModel> updateWorkerProfileDetails(
    String id, {
    File? profilePhoto,
    required String service,
    required String experienceInYears,
    required String hourlyRate,
    required String dailyRate,
    required List<String> languagesSpoken,
    required bool isAvailableToday,
    required bool ownVehicle,
    required bool ownTools,
    required String areaCovered,
    required String about,
  }) async {
    final fields = <String, String>{
      'service': service.toUpperCase(),
      'experienceInYears': experienceInYears,
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'languagesSpoken': jsonEncode(languagesSpoken),
      'isAvailableToday': isAvailableToday ? 'true' : 'false',
      'ownVehicle': ownVehicle ? 'true' : 'false',
      'ownTools': ownTools ? 'true' : 'false',
      'areaCovered': areaCovered,
      'about': about,
    };

    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.workerProfileDetailsEndpoint(id),
      fields: fields,
      singleFile: profilePhoto,
      singleFileKey: 'profilePhoto',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return WorkerProfileModel.fromJson(data);
  }

  // 3. Update Work Photos (PATCH /worker-profile/:id/work-photos - multipart/form-data)
  Future<WorkerProfileModel> updateWorkPhotos(
    String id, {
    List<File>? newWorkPhotos,
    List<String>? photosToRemove,
  }) async {
    final fields = <String, String>{};
    if (photosToRemove != null && photosToRemove.isNotEmpty) {
      fields['photosToRemove'] = jsonEncode(photosToRemove);
    }

    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.workerProfileWorkPhotosEndpoint(id),
      fields: fields,
      files: newWorkPhotos,
      filesKey: 'workPhotos',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return WorkerProfileModel.fromJson(data);
  }

  // 4. Update Certificates (PATCH /worker-profile/:id/certificates - multipart/form-data)
  Future<WorkerProfileModel> updateCertificates(
    String id, {
    List<File>? newCertificates,
    List<String>? certificatesToRemove,
  }) async {
    final fields = <String, String>{};
    if (certificatesToRemove != null && certificatesToRemove.isNotEmpty) {
      fields['certificatesToRemove'] = jsonEncode(certificatesToRemove);
    }

    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.workerProfileCertificatesEndpoint(id),
      fields: fields,
      files: newCertificates,
      filesKey: 'certificates',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return WorkerProfileModel.fromJson(data);
  }

  // 5. Get My Worker Profile (GET /worker-profile/me)
  Future<WorkerProfileModel?> getMyWorkerProfile() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.userWorkerProfileEndpoint,
      );
      final Map<String, dynamic> resBody = jsonDecode(response.body);
      final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
      return WorkerProfileModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  // 6. Get Worker Profile by ID (GET /worker-profile/:id)
  Future<WorkerProfileModel> getWorkerProfileById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.workerProfileDetailsEndpoint(id),
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
    return WorkerProfileModel.fromJson(data);
  }

  // 7. Get Public Worker Profiles (GET /worker-profile)
  Future<List<WorkerProfileModel>> getPublicWorkerProfiles({
    int page = 1,
    int limit = 10,
    String? service,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];
    if (service != null && service.isNotEmpty) {
      queryParams.add('service=${service.toUpperCase()}');
    }

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.workerProfileEndpoint}$queryString',
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];

    return dataList
        .map(
          (item) => WorkerProfileModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  // 8. Hire Worker (POST /worker-profile/:id/hire)
  Future<bool> hireWorker(
    String workerId, {
    required String taskDescription,
    required String dateNeeded,
    required String durationHours,
    required String contactPhone,
    required String offerPrice,
  }) async {
    try {
      final response = await _apiService
          .post(ApiEndpoints.hireWorkerEndpoint(workerId), {
            'taskDescription': taskDescription,
            'dateNeeded': dateNeeded,
            'durationHours': durationHours,
            'contactPhone': contactPhone,
            'offerPrice': offerPrice,
          });

      final Map<String, dynamic> body = jsonDecode(response.body);
      return body['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('WorkerRepository.hireWorker route unavailable or error: $e');
      return false;
    }
  }
}
