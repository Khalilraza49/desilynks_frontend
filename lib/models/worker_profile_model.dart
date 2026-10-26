import '../services/api/api_endpoints.dart';

class WorkPhotoItem {
  final String id;
  final String url;

  WorkPhotoItem({required this.id, required this.url});

  factory WorkPhotoItem.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      String photoUrl = json['url'] as String? ?? json['path'] as String? ?? '';
      if (photoUrl.isNotEmpty && !photoUrl.startsWith('http')) {
        final path = photoUrl.startsWith('/') ? photoUrl : '/$photoUrl';
        photoUrl = '${ApiEndpoints.baseUrl}$path';
      }
      return WorkPhotoItem(id: json['id'] as String? ?? '', url: photoUrl);
    } else {
      String urlStr = json.toString();
      if (urlStr.isNotEmpty && !urlStr.startsWith('http')) {
        final path = urlStr.startsWith('/') ? urlStr : '/$urlStr';
        urlStr = '${ApiEndpoints.baseUrl}$path';
      }
      return WorkPhotoItem(id: '', url: urlStr);
    }
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url};
}

class CertificateItem {
  final String id;
  final String url;

  CertificateItem({required this.id, required this.url});

  factory CertificateItem.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      String certUrl = json['url'] as String? ?? json['path'] as String? ?? '';
      if (certUrl.isNotEmpty && !certUrl.startsWith('http')) {
        final path = certUrl.startsWith('/') ? certUrl : '/$certUrl';
        certUrl = '${ApiEndpoints.baseUrl}$path';
      }
      return CertificateItem(id: json['id'] as String? ?? '', url: certUrl);
    } else {
      String urlStr = json.toString();
      if (urlStr.isNotEmpty && !urlStr.startsWith('http')) {
        final path = urlStr.startsWith('/') ? urlStr : '/$urlStr';
        urlStr = '${ApiEndpoints.baseUrl}$path';
      }
      return CertificateItem(id: '', url: urlStr);
    }
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url};
}

class WorkerProfileModel {
  final String id;
  final String userId;
  final String name;
  final String? profilePhotoUrl;
  final String profession;
  final int yearsOfExperience;
  final String hourlyRate;
  final String dailyRate;
  final List<String> languages;
  final bool isAvailableToday;
  final bool hasVehicle;
  final bool hasTools;
  final String areaCovered;
  final List<WorkPhotoItem> workPhotoItems;
  final List<CertificateItem> certificateItems;
  final String aboutMe;
  final String phoneNumber;
  final List<String> skills;
  final bool isDraft;
  final DateTime createdAt;
  final double? searchScore;
  final String? workerTypeId;

  WorkerProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    this.profilePhotoUrl,
    required this.profession,
    required this.yearsOfExperience,
    required this.hourlyRate,
    required this.dailyRate,
    required this.languages,
    required this.isAvailableToday,
    required this.hasVehicle,
    required this.hasTools,
    required this.areaCovered,
    required this.workPhotoItems,
    required this.certificateItems,
    required this.aboutMe,
    required this.phoneNumber,
    required this.skills,
    this.isDraft = false,
    required this.createdAt,
    this.searchScore,
    this.workerTypeId,
  });

  List<String> get portfolioPhotos => workPhotoItems.map((e) => e.url).toList();
  List<String> get certificates => certificateItems.map((e) => e.url).toList();
  String get service => profession;
  String get about => aboutMe;

  factory WorkerProfileModel.fromJson(Map<String, dynamic> json) {
    // Profile photo parsing
    String? photoUrl;
    if (json['profilePhoto'] != null && json['profilePhoto'] is Map) {
      photoUrl =
          json['profilePhoto']['url'] as String? ??
          json['profilePhoto']['path'] as String?;
    } else if (json['profilePhoto'] is String) {
      photoUrl = json['profilePhoto'] as String;
    } else if (json['profilePhotoUrl'] != null) {
      photoUrl = json['profilePhotoUrl'] as String?;
    }

    if (photoUrl != null &&
        photoUrl.isNotEmpty &&
        !photoUrl.startsWith('http')) {
      final path = photoUrl.startsWith('/') ? photoUrl : '/$photoUrl';
      photoUrl = '${ApiEndpoints.baseUrl}$path';
    }

    // Languages parsing
    final langsRaw =
        json['languagesSpoken'] as List? ?? json['languages'] as List? ?? [];
    final List<String> languagesList = langsRaw
        .map((e) => e.toString())
        .toList();

    // Work photos parsing
    final workPhotosRaw =
        json['workPhotos'] as List? ?? json['portfolioPhotos'] as List? ?? [];
    final List<WorkPhotoItem> workPhotoItems = workPhotosRaw
        .map((e) => WorkPhotoItem.fromJson(e))
        .toList();

    // Certificates parsing
    final certsRaw = json['certificates'] as List? ?? [];
    final List<CertificateItem> certificateItems = certsRaw
        .map((e) => CertificateItem.fromJson(e))
        .toList();

    // Experience parsing
    int expYears = 0;
    if (json['experienceInYears'] != null) {
      expYears = int.tryParse(json['experienceInYears'].toString()) ?? 0;
    } else if (json['yearsOfExperience'] != null) {
      expYears = int.tryParse(json['yearsOfExperience'].toString()) ?? 0;
    }

    // Boolean fields parsing (supports String or bool)
    bool parseBool(dynamic value, bool defaultValue) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return defaultValue;
    }

    return WorkerProfileModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['workerId'] as String? ?? '',
      name: json['name'] as String? ??
          (json['user'] is Map
              ? (json['user']['name'] ??
                  '${json['user']['firstName'] ?? ''} ${json['user']['lastName'] ?? ''}'.trim())
              : null) ??
          '',
      profilePhotoUrl: photoUrl,
      profession:
          json['service'] as String? ?? json['profession'] as String? ?? '',
      yearsOfExperience: expYears,
      hourlyRate: json['hourlyRate']?.toString() ?? '0',
      dailyRate: json['dailyRate']?.toString() ?? '0',
      languages: languagesList,
      isAvailableToday: parseBool(json['isAvailableToday'], true),
      hasVehicle: parseBool(json['ownVehicle'] ?? json['hasVehicle'], false),
      hasTools: parseBool(json['ownTools'] ?? json['hasTools'], false),
      areaCovered: json['areaCovered'] as String? ?? '',
      workPhotoItems: workPhotoItems,
      certificateItems: certificateItems,
      aboutMe: json['about'] as String? ?? json['aboutMe'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isDraft: json['isDraft'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      searchScore: (json['_score'] as num?)?.toDouble(),
      workerTypeId: json['workerTypeId'] as String? ??
          json['needWorkerTypeId'] as String? ??
          json['categoryId'] as String? ??
          (json['workerType'] is Map
              ? json['workerType']['id']?.toString()
              : null) ??
          (json['category'] is Map
              ? json['category']['id']?.toString()
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
      'service': profession,
      'experienceInYears': yearsOfExperience,
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'languagesSpoken': languages,
      'isAvailableToday': isAvailableToday,
      'ownVehicle': hasVehicle,
      'ownTools': hasTools,
      'areaCovered': areaCovered,
      'workPhotos': workPhotoItems.map((p) => p.toJson()).toList(),
      'certificates': certificateItems.map((c) => c.toJson()).toList(),
      'about': aboutMe,
      'phoneNumber': phoneNumber,
      'skills': skills,
      'isDraft': isDraft,
      'createdAt': createdAt.toIso8601String(),
      if (workerTypeId != null) 'workerTypeId': workerTypeId,
    };
  }
}
