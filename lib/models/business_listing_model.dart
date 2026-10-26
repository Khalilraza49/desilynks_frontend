import 'business_listing_enums.dart';

class BusinessPhotoModel {
  final String id;
  final String url;

  BusinessPhotoModel({required this.id, required this.url});

  factory BusinessPhotoModel.fromJson(Map<String, dynamic> json) {
    return BusinessPhotoModel(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url};
}

class BusinessHoursModel {
  final String id;
  final String businessId;
  final String monToFriStartTime;
  final String monToFriEndTime;
  final String saturdayStartTime;
  final String saturdayEndTime;
  final String? sundayStartTime;
  final String? sundayEndTime;
  final bool isClosedOnSunday;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BusinessHoursModel({
    required this.id,
    required this.businessId,
    required this.monToFriStartTime,
    required this.monToFriEndTime,
    required this.saturdayStartTime,
    required this.saturdayEndTime,
    this.sundayStartTime,
    this.sundayEndTime,
    required this.isClosedOnSunday,
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessHoursModel.fromJson(Map<String, dynamic> json) {
    return BusinessHoursModel(
      id: json['id'] as String? ?? '',
      businessId: json['businessId'] as String? ?? '',
      monToFriStartTime: json['monToFriStartTime'] as String? ?? '09:00',
      monToFriEndTime: json['monToFriEndTime'] as String? ?? '18:00',
      saturdayStartTime: json['saturdayStartTime'] as String? ?? '10:00',
      saturdayEndTime: json['saturdayEndTime'] as String? ?? '16:00',
      sundayStartTime: json['sundayStartTime'] as String?,
      sundayEndTime: json['sundayEndTime'] as String?,
      isClosedOnSunday: json['isClosedOnSunday'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'businessId': businessId,
    'monToFriStartTime': monToFriStartTime,
    'monToFriEndTime': monToFriEndTime,
    'saturdayStartTime': saturdayStartTime,
    'saturdayEndTime': saturdayEndTime,
    'sundayStartTime': sundayStartTime,
    'sundayEndTime': sundayEndTime,
    'isClosedOnSunday': isClosedOnSunday,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}

class BusinessOwnerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePhotoUrl;

  BusinessOwnerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePhotoUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory BusinessOwnerModel.fromJson(Map<String, dynamic> json) {
    final photo = json['profilePhoto'] as Map<String, dynamic>?;
    return BusinessOwnerModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePhotoUrl: photo?['url'] as String?,
    );
  }
}

class BusinessListingModel {
  final String id;
  final String ownerId;
  final String name;
  final String category;
  final String? categoryId;
  final String address;
  final String phone;
  final String? whatsApp;
  final String? website;
  final String description;
  final String status;
  final int viewsCount;
  final int clicks;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final BusinessHoursModel? businessHours;
  final BusinessPhotoModel? logo;
  final BusinessPhotoModel? coverPhoto;
  final List<BusinessPhotoModel> businessGalleries;
  final BusinessOwnerModel? owner;
  String get title => name;

  BusinessListingModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.category,
    this.categoryId,
    required this.address,
    required this.phone,
    this.whatsApp,
    this.website,
    required this.description,
    required this.status,
    required this.viewsCount,
    required this.clicks,
    required this.createdAt,
    this.updatedAt,
    this.businessHours,
    this.logo,
    this.coverPhoto,
    required this.businessGalleries,
    this.owner,
  });

  BusinessCategory get categoryEnum => BusinessCategory.fromString(category);
  BusinessListingStatus get statusEnum =>
      BusinessListingStatus.fromString(status);

  factory BusinessListingModel.fromJson(Map<String, dynamic> json) {
    final galleriesRaw = json['businessGalleries'] as List?;
    final galleries = galleriesRaw != null
        ? galleriesRaw
              .map(
                (item) =>
                    BusinessPhotoModel.fromJson(item as Map<String, dynamic>),
              )
              .toList()
        : <BusinessPhotoModel>[];

    final rawCategory = json['category'];
    String categoryName = 'OTHER';
    String? categoryIdVal;
    if (rawCategory is Map) {
      categoryName = rawCategory['title']?.toString() ??
          rawCategory['name']?.toString() ??
          rawCategory['slug']?.toString() ??
          'OTHER';
      categoryIdVal = rawCategory['id']?.toString();
    } else if (rawCategory is String) {
      categoryName = rawCategory;
    } else if (json['categoryName'] != null) {
      categoryName = json['categoryName'].toString();
    }
    if (json['categoryId'] != null) {
      categoryIdVal ??= json['categoryId'].toString();
    }

    return BusinessListingModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: categoryName,
      categoryId: categoryIdVal,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      whatsApp: json['whatsApp'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      viewsCount: json['viewsCount'] as int? ?? 0,
      clicks: json['clicks'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      businessHours: json['businessHours'] != null
          ? BusinessHoursModel.fromJson(
              json['businessHours'] as Map<String, dynamic>,
            )
          : null,
      logo: json['logo'] != null
          ? BusinessPhotoModel.fromJson(json['logo'] as Map<String, dynamic>)
          : null,
      coverPhoto: json['coverPhoto'] != null
          ? BusinessPhotoModel.fromJson(
              json['coverPhoto'] as Map<String, dynamic>,
            )
          : null,
      businessGalleries: galleries,
      owner: json['owner'] != null
          ? BusinessOwnerModel.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PeriodStats {
  final String startDate;
  final String endDate;
  final int views;
  final int clicks;

  PeriodStats({
    required this.startDate,
    required this.endDate,
    required this.views,
    required this.clicks,
  });

  factory PeriodStats.fromJson(Map<String, dynamic> json) {
    return PeriodStats(
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      views: json['views'] as int? ?? 0,
      clicks: json['clicks'] as int? ?? 0,
    );
  }
}

class AnalyticsChange {
  final double viewsPercent;
  final double clicksPercent;

  AnalyticsChange({required this.viewsPercent, required this.clicksPercent});

  factory AnalyticsChange.fromJson(Map<String, dynamic> json) {
    return AnalyticsChange(
      viewsPercent: (json['viewsPercent'] as num?)?.toDouble() ?? 0.0,
      clicksPercent: (json['clicksPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BusinessAnalyticsModel {
  final String period;
  final PeriodStats currentPeriod;
  final PeriodStats previousPeriod;
  final AnalyticsChange change;

  BusinessAnalyticsModel({
    required this.period,
    required this.currentPeriod,
    required this.previousPeriod,
    required this.change,
  });

  factory BusinessAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return BusinessAnalyticsModel(
      period: json['period'] as String? ?? 'THIS_MONTH',
      currentPeriod: PeriodStats.fromJson(
        json['currentPeriod'] as Map<String, dynamic>? ?? {},
      ),
      previousPeriod: PeriodStats.fromJson(
        json['previousPeriod'] as Map<String, dynamic>? ?? {},
      ),
      change: AnalyticsChange.fromJson(
        json['change'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
