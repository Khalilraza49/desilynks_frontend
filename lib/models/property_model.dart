import 'dart:convert';
import '../services/api/api_endpoints.dart';
import 'room_post.dart';

class PropertyFeature {
  final String id;
  final String name;
  final String? icon;

  PropertyFeature({required this.id, required this.name, this.icon});

  factory PropertyFeature.fromJson(Map<String, dynamic> json) {
    return PropertyFeature(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (icon != null) 'icon': icon};
  }
}

class PropertyFeatureHelper {
  PropertyFeatureHelper._();

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool isUuid(String value) => _uuidRegex.hasMatch(value.trim());

  static const Map<String, String> _nameToUuid = {
    'wifi': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c01',
    'furnished': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c02',
    'heating': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c03',
    'a/c': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c04',
    'ac': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c04',
    'air conditioning': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c04',
    'washing machine': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c05',
    'pets ok': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c06',
    'pets allowed': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c06',
    'bath tub': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c07',
    'bathtub': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c07',
    'parking': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c08',
    'balcony': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c09',
    'garden': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c10',
    'elevator': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c11',
    'lift': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c11',
    'gym': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c12',
    'swimming pool': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c13',
    'pool': 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c13',
  };

  static const Map<String, String> _uuidToName = {
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c01': 'WiFi',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c02': 'Furnished',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c03': 'Heating',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c04': 'A/C',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c05': 'Washing Machine',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c06': 'Pets Ok',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c07': 'Bath Tub',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c08': 'Parking',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c09': 'Balcony',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c10': 'Garden',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c11': 'Elevator',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c12': 'Gym',
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c13': 'Swimming Pool',
  };

  static String? getNameByUuid(String uuid) {
    return _uuidToName[uuid.trim().toLowerCase()];
  }

  static String toUuid(String nameOrId) {
    final trimmed = nameOrId.trim();
    if (isUuid(trimmed)) return trimmed.toLowerCase();
    final lower = trimmed.toLowerCase();
    if (_nameToUuid.containsKey(lower)) {
      return _nameToUuid[lower]!;
    }
    // Generate deterministic RFC-4122 compliant UUID v4 string
    final bytes = utf8.encode(lower);
    int h1 = 5381;
    int h2 = 0;
    for (final b in bytes) {
      h1 = ((h1 << 5) + h1) ^ b;
      h2 = ((h2 << 7) + h2) ^ b;
    }
    final hex1 = (h1.abs() & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
    final hex2 = (h2.abs() & 0xFFFF).toRadixString(16).padLeft(4, '0');
    final hex3 = '4${(h1.abs() & 0x0FFF).toRadixString(16).padLeft(3, '0')}';
    final hex4 = 'a${(h2.abs() & 0x0FFF).toRadixString(16).padLeft(3, '0')}';
    final hex5 = ((h1.abs() ^ h2.abs()) & 0xFFFFFFFFFFFF)
        .toRadixString(16)
        .padLeft(12, '0');
    return '$hex1-$hex2-$hex3-$hex4-$hex5';
  }
}

class PropertyModel {
  final String id;
  final String ownerId;
  final String type; // ROOM, APARTMENT, HOUSE, STUDIO
  final String title;
  final String description;
  final String status; // PUBLISHED, RENTED, INACTIVE, DRAFT, ARCHIVED
  final String monthlyRent;
  final DateTime availableFrom;
  final String location;
  final int noOfBedRooms;
  final int noOfBathRooms;
  final String? contactPreference;
  final int viewsCount;
  final int chatsCount;
  final int offersCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PropertyPhoto> propertyPhotos;
  final int likesCount;
  final bool isLiked;
  final PropertyOwner? owner;
  final double? searchScore;
  final List<String> parsedFeatureIds;
  final List<Map<String, String>> parsedFeatures;

  // Backward compatibility getters for removed fields
  String get deposit => '0.00';
  bool get billsIncluded => false;
  List<String> get featuresAndAmenities {
    if (parsedFeatures.isNotEmpty) {
      final titles = parsedFeatures
          .map((f) => f['title'] ?? '')
          .where((t) => t.trim().isNotEmpty)
          .toList();
      if (titles.isNotEmpty) return titles;
    }
    return parsedFeatureIds;
  }
  List<String> get featureIds => parsedFeatureIds;

  String get ownerFirstName => owner?.firstName ?? 'User';
  String? get ownerLastName => owner?.lastName ?? 'Name';
  String? get ownerProfilePhotoUrl => owner?.profilePhotoUrl;
  String get depositText => '0.00';

  PropertyModel({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.monthlyRent,
    required this.availableFrom,
    required this.location,
    required this.noOfBedRooms,
    required this.noOfBathRooms,
    this.contactPreference,
    required this.viewsCount,
    this.chatsCount = 0,
    this.offersCount = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.propertyPhotos,
    this.likesCount = 0,
    this.isLiked = false,
    this.owner,
    this.searchScore,
    this.parsedFeatureIds = const [],
    this.parsedFeatures = const [],
    // Deprecated optional params for backward compatibility
    String? deposit,
    bool? billsIncluded,
    PropertyVideo? videoTour,
    List<String>? featureIds,
    List<dynamic>? features,
    List<String>? featuresAndAmenities,
  });

  PropertyModel copyWith({
    String? id,
    String? ownerId,
    String? type,
    String? title,
    String? description,
    String? status,
    String? monthlyRent,
    DateTime? availableFrom,
    String? location,
    int? noOfBedRooms,
    int? noOfBathRooms,
    String? contactPreference,
    int? viewsCount,
    int? chatsCount,
    int? offersCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PropertyPhoto>? propertyPhotos,
    int? likesCount,
    bool? isLiked,
    PropertyOwner? owner,
    double? searchScore,
    String? deposit,
    bool? billsIncluded,
    PropertyVideo? videoTour,
    List<String>? featureIds,
    List<dynamic>? features,
    List<String>? featuresAndAmenities,
    List<String>? parsedFeatureIds,
    List<Map<String, String>>? parsedFeatures,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      availableFrom: availableFrom ?? this.availableFrom,
      location: location ?? this.location,
      noOfBedRooms: noOfBedRooms ?? this.noOfBedRooms,
      noOfBathRooms: noOfBathRooms ?? this.noOfBathRooms,
      contactPreference: contactPreference ?? this.contactPreference,
      viewsCount: viewsCount ?? this.viewsCount,
      chatsCount: chatsCount ?? this.chatsCount,
      offersCount: offersCount ?? this.offersCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      propertyPhotos: propertyPhotos ?? this.propertyPhotos,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      owner: owner ?? this.owner,
      searchScore: searchScore ?? this.searchScore,
      parsedFeatureIds: parsedFeatureIds ?? this.parsedFeatureIds,
      parsedFeatures: parsedFeatures ?? this.parsedFeatures,
    );
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    // Determine the root property map (sometimes nested under 'data' or 'user')
    final map = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['user'] is Map<String, dynamic>
              ? json['user'] as Map<String, dynamic>
              : json);

    final photosList = map['propertyPhotos'] as List? ?? [];
    final propertyPhotos = photosList
        .map((p) => PropertyPhoto.fromJson(p as Map<String, dynamic>))
        .toList();

    // Extract likes count and user liked status
    int likesCount = map['likesCount'] as int? ?? 0;
    int chatsCount = map['chatsCount'] as int? ?? 0;
    int offersCount = map['offersCount'] as int? ?? 0;
    if (map['_count'] != null && map['_count'] is Map<String, dynamic>) {
      likesCount = map['_count']['likes'] as int? ?? likesCount;
      chatsCount = map['_count']['chats'] as int? ??
          map['_count']['conversations'] as int? ??
          map['_count']['inquiries'] as int? ??
          chatsCount;
      offersCount = map['_count']['offers'] as int? ??
          map['_count']['inquiries'] as int? ??
          offersCount;
    }

    final isLiked = map['isLiked'] as bool? ?? false;

    PropertyOwner? owner;
    if (map['owner'] != null && map['owner'] is Map<String, dynamic>) {
      owner = PropertyOwner.fromJson(map['owner'] as Map<String, dynamic>);
    }

    // Parse featuresAndAmenities from API response [{id, title}, ...]
    final rawFeatures = map['featuresAndAmenities'] as List? ?? [];
    final List<String> parsedFeatureIds = [];
    final List<Map<String, String>> parsedFeatures = [];
    for (final item in rawFeatures) {
      if (item is Map<String, dynamic>) {
        final fId = item['id'] as String? ?? '';
        final fTitle = item['title'] as String? ?? '';
        if (fId.isNotEmpty) {
          parsedFeatureIds.add(fId);
          parsedFeatures.add({'id': fId, 'title': fTitle});
        }
      }
    }

    return PropertyModel(
      id: map['id'] as String? ?? map['_id'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      type: map['type'] as String? ?? 'ROOM',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'PUBLISHED',
      monthlyRent: map['monthlyRent']?.toString() ?? '0.00',
      availableFrom: map['availableFrom'] != null
          ? DateTime.parse(map['availableFrom'] as String)
          : DateTime.now(),
      location: map['location'] as String? ?? '',
      noOfBedRooms: map['noOfBedRooms'] as int? ?? 1,
      noOfBathRooms: map['noOfBathRooms'] as int? ?? 1,
      contactPreference: map['contactPreference'] as String?,
      viewsCount: map['viewsCount'] as int? ?? 0,
      chatsCount: chatsCount,
      offersCount: offersCount,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
      propertyPhotos: propertyPhotos,
      likesCount: likesCount,
      isLiked: isLiked,
      owner: owner,
      searchScore: (map['_score'] as num?)?.toDouble(),
      parsedFeatureIds: parsedFeatureIds,
      parsedFeatures: parsedFeatures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'type': type,
      'title': title,
      'description': description,
      'status': status,
      'monthlyRent': monthlyRent,
      'availableFrom': availableFrom.toIso8601String(),
      'location': location,
      'noOfBedRooms': noOfBedRooms,
      'noOfBathRooms': noOfBathRooms,
      'contactPreference': contactPreference,
      'viewsCount': viewsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'propertyPhotos': propertyPhotos.map((p) => p.toJson()).toList(),
      'likesCount': likesCount,
      'isLiked': isLiked,
      'owner': owner?.toJson(),
    };
  }

  // Convert to RoomPost for UI components expecting it
  RoomPost toRoomPost() {
    final String formattedPrice =
        double.tryParse(monthlyRent)?.toStringAsFixed(0) ?? monthlyRent;

    // Map status enum: PUBLISHED -> Active, RENTED -> Expired, INACTIVE -> Expired, etc.
    String uiStatus = 'Active';
    if (status == 'RENTED' || status == 'INACTIVE' || status == 'ARCHIVED') {
      uiStatus = 'Expired';
    } else if (status == 'DRAFT') {
      uiStatus = 'Pending';
    }

    // Combine bedrooms, bathrooms, wifi etc to mimic original amenities format
    final List<String> uiAmenities = [
      '$noOfBedRooms Bed',
      '$noOfBathRooms Bath',
    ];
    uiAmenities.addAll(featuresAndAmenities);

    final String firstPhotoUrl = propertyPhotos.isNotEmpty
        ? propertyPhotos.first.url
        : 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80';

    return RoomPost(
      title: title,
      location: location,
      price: formattedPrice,
      status: uiStatus,
      date: _formatDate(createdAt),
      propertyType: type.toLowerCase() == 'room' ? 'Room' : type,
      amenities: uiAmenities,
      imageUrl: firstPhotoUrl,
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }
}

class PropertyPhoto {
  final String id;
  final String url;

  PropertyPhoto({required this.id, required this.url});

  factory PropertyPhoto.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['url'] as String? ?? '';
    if (rawUrl.isNotEmpty && !rawUrl.startsWith('http')) {
      final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
      rawUrl = '$baseUrl$path';
    }
    return PropertyPhoto(id: json['id'] as String? ?? '', url: rawUrl);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url};
  }
}

class PropertyVideo {
  final String id;
  final String url;

  PropertyVideo({required this.id, required this.url});

  factory PropertyVideo.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['url'] as String? ?? '';
    if (rawUrl.isNotEmpty && !rawUrl.startsWith('http')) {
      final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
      rawUrl = '$baseUrl$path';
    }
    return PropertyVideo(id: json['id'] as String? ?? '', url: rawUrl);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url};
  }
}

class PropertyOwner {
  final String id;
  final String firstName;
  final String? lastName;
  final String? profilePhotoUrl;
  final String createdAt;
  final String? email;
  final String? phoneNumber;
  final String? coverLetter;

  PropertyOwner({
    required this.id,
    required this.firstName,
    this.lastName,
    this.profilePhotoUrl,
    required this.createdAt,
    this.email,
    this.phoneNumber,
    this.coverLetter,
  });

  String get fullName => (lastName != null && lastName!.isNotEmpty)
      ? '$firstName $lastName'
      : firstName;

  factory PropertyOwner.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['profilePhoto'] != null &&
        json['profilePhoto'] is Map<String, dynamic>) {
      photoUrl = json['profilePhoto']['url'] as String?;
    }
    return PropertyOwner(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String?,
      profilePhotoUrl: photoUrl,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': createdAt,
    };
  }
}
