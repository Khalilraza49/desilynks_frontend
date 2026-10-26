class NeedWorkerPhoto {
  final String id;
  final String url;

  NeedWorkerPhoto({required this.id, required this.url});

  factory NeedWorkerPhoto.fromJson(Map<String, dynamic> json) {
    return NeedWorkerPhoto(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url};
}

class NeedWorkerRequester {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhotoUrl;

  NeedWorkerRequester({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhotoUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory NeedWorkerRequester.fromJson(Map<String, dynamic> json) {
    final photo = json['profilePhoto'] as Map<String, dynamic>?;
    return NeedWorkerRequester(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      profilePhotoUrl: photo?['url'] as String?,
    );
  }
}

class NeedWorkerModel {
  final String id;
  final String requesterId;
  final String workerType;
  final String? workerTypeId;
  final String location;
  final DateTime? dateNeeded;
  final String startTime;
  final String endTime;
  final String budget;
  final String budgetType;
  final bool isUrgentRequest;
  final String description;
  final List<NeedWorkerPhoto> referencePhotos;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final NeedWorkerRequester? requester;
  final int applicationCount;
  final String status;
  final int viewsCount;
  final int chatsCount;

  NeedWorkerModel({
    required this.id,
    required this.requesterId,
    required this.workerType,
    this.workerTypeId,
    required this.location,
    this.dateNeeded,
    required this.startTime,
    required this.endTime,
    required this.budget,
    required this.budgetType,
    required this.isUrgentRequest,
    required this.description,
    required this.referencePhotos,
    required this.createdAt,
    this.updatedAt,
    this.requester,
    this.applicationCount = 0,
    this.status = 'ACTIVE',
    this.viewsCount = 0,
    this.chatsCount = 0,
  });

  factory NeedWorkerModel.fromJson(Map<String, dynamic> json) {
    // Parse reference photos (can be list of objects or list of strings)
    final photosRaw = (json['referencePhotos'] ?? json['photos']) as List<dynamic>?;
    final photos = <NeedWorkerPhoto>[];
    if (photosRaw != null) {
      for (final item in photosRaw) {
        if (item is Map<String, dynamic>) {
          photos.add(NeedWorkerPhoto.fromJson(item));
        } else if (item is String) {
          photos.add(NeedWorkerPhoto(id: '', url: item));
        }
      }
    }

    // Parse requester if present
    NeedWorkerRequester? requester;
    if (json['requester'] is Map<String, dynamic>) {
      requester = NeedWorkerRequester.fromJson(
        json['requester'] as Map<String, dynamic>,
      );
    }

    // Parse application count
    int appCount = 0;
    if (json['_count'] is Map<String, dynamic>) {
      appCount =
          (json['_count'] as Map<String, dynamic>)['workerApplications']
              as int? ??
          (json['_count'] as Map<String, dynamic>)['applications'] as int? ??
          0;
    } else if (json['applicationCount'] is int) {
      appCount = json['applicationCount'] as int;
    } else if (json['applicationsCount'] is int) {
      appCount = json['applicationsCount'] as int;
    }

    final String status = json['status']?.toString().toUpperCase() ?? 'ACTIVE';
    final int viewsCount =
        json['viewsCount'] as int? ?? json['views'] as int? ?? 0;
    final int chatsCount = json['chatsCount'] as int? ??
        (json['_count'] is Map
            ? ((json['_count'] as Map)['chats'] as int? ??
                (json['_count'] as Map)['conversations'] as int?)
            : null) ??
        0;

    // Parse workerType (can be a nested Map object from relation or a String)
    String workerType = 'OTHER';
    String? workerTypeId = json['workerTypeId']?.toString();

    final dynamic rawWorkerType =
        json['workerType'] ?? json['needWorkerType'];
    if (rawWorkerType is String) {
      workerType = rawWorkerType;
    } else if (rawWorkerType is Map) {
      workerType = rawWorkerType['title']?.toString() ??
          rawWorkerType['name']?.toString() ??
          rawWorkerType['workerType']?.toString() ??
          rawWorkerType['type']?.toString() ??
          'OTHER';
      workerTypeId ??= rawWorkerType['id']?.toString();
    }

    // Parse location (can be String or Map)
    final dynamic rawLocation = json['location'];
    String location = '';
    if (rawLocation is String) {
      location = rawLocation;
    } else if (rawLocation is Map) {
      location = rawLocation['address']?.toString() ??
          rawLocation['name']?.toString() ??
          rawLocation['city']?.toString() ??
          '';
    }

    // Parse budgetType (can be String or Map)
    final dynamic rawBudgetType = json['budgetType'];
    String budgetType = 'FIXED';
    if (rawBudgetType is String) {
      budgetType = rawBudgetType;
    } else if (rawBudgetType is Map) {
      budgetType = rawBudgetType['name']?.toString() ??
          rawBudgetType['title']?.toString() ??
          'FIXED';
    }

    final String requesterId = json['requesterId']?.toString() ??
        (json['requester'] is Map
            ? json['requester']['id']?.toString()
            : null) ??
        '';

    return NeedWorkerModel(
      id: json['id']?.toString() ?? '',
      requesterId: requesterId,
      workerType: workerType,
      workerTypeId: workerTypeId,
      location: location,
      dateNeeded: json['dateNeeded'] != null
          ? DateTime.tryParse(json['dateNeeded'].toString())
          : null,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      budget: json['budget']?.toString() ?? '0',
      budgetType: budgetType,
      isUrgentRequest:
          json['isUrgentRequest'] == true || json['isUrgentRequest'] == 'true',
      description: json['description']?.toString() ?? '',
      referencePhotos: photos,
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      requester: requester,
      applicationCount: appCount,
      status: status,
      viewsCount: viewsCount,
      chatsCount: chatsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'workerType': workerType,
      if (workerTypeId != null) 'workerTypeId': workerTypeId,
      'location': location,
      'dateNeeded': dateNeeded?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'budget': budget,
      'budgetType': budgetType,
      'isUrgentRequest': isUrgentRequest,
      'description': description,
      'referencePhotos': referencePhotos.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
