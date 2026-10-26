import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/search_result_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';
import '../services/local/storage_service.dart';

class EventRepository {
  final ApiService _apiService;
  final StorageService? _storageService;

  EventRepository(this._apiService, [this._storageService]);

  /// Fetch All Events
  Future<PaginatedResponse<EventModel>> getEvents({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    final safeLimit = (limit > 50 || limit < 1) ? 50 : limit;
    final queryParams = <String>['page=$page', 'limit=$safeLimit'];
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams.add('category=$category');
    }
    if (search != null && search.isNotEmpty) {
      queryParams.add('search=$search');
    }

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.eventsEndpoint}$queryString',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final List<dynamic> dataList = resBody['data'] as List? ?? [];
    final events = dataList
        .map((item) => EventModel.fromJson(item as Map<String, dynamic>))
        .toList();

    SearchMeta meta;
    if (resBody['meta'] is Map<String, dynamic>) {
      meta = SearchMeta.fromJson(resBody['meta'] as Map<String, dynamic>);
    } else {
      meta = SearchMeta(
        total: events.length,
        page: 1,
        limit: 10,
        totalPages: 1,
      );
    }

    return PaginatedResponse(data: events, meta: meta);
  }

  /// Create Event (multipart/form-data)
  Future<EventModel> createEvent({
    required String title,
    required String category,
    required String location,
    required DateTime date,
    required String time,
    required String price,
    required String description,
    File? coverImage,
    String? organizerName,
    String? organizerId,
    String? organizerAvatar,
    DateTime? endDate,
    String? endTime,
    int? maxAttendees,
  }) async {
    final cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final priceVal = cleanPrice.isEmpty ? '0' : cleanPrice;

    final fields = <String, String>{
      'title': title,
      'category': category,
      'location': location,
      'date': date.toIso8601String(),
      'startDate': date.toIso8601String(),
      'time': time,
      'startTime': time,
      'price': priceVal,
      'ticketPrice': priceVal,
      'description': description,
      if (organizerName != null && organizerName.isNotEmpty)
        'organizer': organizerName,
      if (organizerName != null && organizerName.isNotEmpty)
        'organizerName': organizerName,
      if (organizerId != null && organizerId.isNotEmpty)
        'organizerId': organizerId,
      if (organizerAvatar != null && organizerAvatar.isNotEmpty)
        'organizerAvatar': organizerAvatar,
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (endTime != null && endTime.isNotEmpty) 'endTime': endTime,
      if (maxAttendees != null) 'maxAttendees': maxAttendees.toString(),
    };

    if (coverImage == null) {
      final response = await _apiService.multipartRequest(
        method: 'POST',
        endpoint: ApiEndpoints.eventsEndpoint,
        fields: fields,
      );
      final Map<String, dynamic> resBody = jsonDecode(response.body);
      final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
      final parsed = EventModel.fromJson(data);
      return parsed.copyWith(
        organizerId: parsed.organizerId ?? organizerId,
        organizerName: (parsed.organizerName.isNotEmpty &&
                parsed.organizerName != 'Community Organizer')
            ? parsed.organizerName
            : (organizerName ?? parsed.organizerName),
        organizerAvatar: (parsed.organizerAvatar.isNotEmpty &&
                !parsed.organizerAvatar.contains('unsplash.com'))
            ? parsed.organizerAvatar
            : (organizerAvatar ?? parsed.organizerAvatar),
      );
    }

    // Try keys in order based on NestJS backend conventions:
    // 1. 'coverPhoto' (canonical across business and groups)
    // 2. 'image'
    // 3. 'photo'
    // 4. 'banner'
    // 5. 'coverImage'
    // 6. 'file'
    final candidateKeys = [
      'coverPhoto',
      'image',
      'photo',
      'banner',
      'coverImage',
      'file',
    ];
    dynamic lastError;

    for (final key in candidateKeys) {
      try {
        final response = await _apiService.multipartRequest(
          method: 'POST',
          endpoint: ApiEndpoints.eventsEndpoint,
          fields: fields,
          singleFile: coverImage,
          singleFileKey: key,
        );

        final Map<String, dynamic> resBody = jsonDecode(response.body);
        final data = resBody['data'] as Map<String, dynamic>? ?? resBody;
        final parsed = EventModel.fromJson(data);
        final resolvedImg = ((parsed.imageUrl.isEmpty ||
                    parsed.imageUrl.contains('unsplash.com')) &&
                coverImage.existsSync())
            ? coverImage.path
            : parsed.imageUrl;

        return parsed.copyWith(
          imageUrl: resolvedImg,
          organizerId: parsed.organizerId ?? organizerId,
          organizerName: (parsed.organizerName.isNotEmpty &&
                  parsed.organizerName != 'Community Organizer')
              ? parsed.organizerName
              : (organizerName ?? parsed.organizerName),
          organizerAvatar: (parsed.organizerAvatar.isNotEmpty &&
                  !parsed.organizerAvatar.contains('unsplash.com'))
              ? parsed.organizerAvatar
              : (organizerAvatar ?? parsed.organizerAvatar),
        );
      } catch (e) {
        lastError = e;
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('unexpected field')) {
          continue;
        }
        rethrow;
      }
    }

    throw lastError;
  }

  /// Get events created by current user
  Future<List<EventModel>> getMyEvents({int page = 1, int limit = 50}) async {
    final safeLimit = (limit > 50 || limit < 1) ? 50 : limit;
    try {
      final res = await getEvents(page: page, limit: safeLimit);
      final currentUser = _storageService?.getUser();
      final currentUserId = currentUser?.id;
      final currentUserName = currentUser?.fullName.trim().toLowerCase();

      if ((currentUserId == null || currentUserId.isEmpty) &&
          (currentUserName == null || currentUserName.isEmpty)) {
        return [];
      }

      return res.data.where((e) {
        final matchesId = currentUserId != null &&
            currentUserId.isNotEmpty &&
            e.organizerId != null &&
            e.organizerId == currentUserId;
        final matchesName = currentUserName != null &&
            currentUserName.isNotEmpty &&
            e.organizerName.trim().toLowerCase() == currentUserName;
        return matchesId || matchesName;
      }).toList();
    } catch (e) {
      debugPrint('[EventRepository] Error fetching user events: $e');
      return [];
    }
  }

  /// Delete event (DELETE /community/event/:id)
  Future<bool> deleteEvent(String id) async {
    try {
      final response = await _apiService.delete(
        '${ApiEndpoints.eventsEndpoint}/$id',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
