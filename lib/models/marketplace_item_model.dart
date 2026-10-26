import '../services/api/api_endpoints.dart';

class ProductPhoto {
  final String id;
  final String url;

  const ProductPhoto({required this.id, required this.url});

  factory ProductPhoto.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['url'] as String? ?? '';
    if (rawUrl.isNotEmpty && !rawUrl.startsWith('http')) {
      final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
      rawUrl = '$baseUrl$path';
    }
    return ProductPhoto(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      url: rawUrl,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url};
}

class MarketplaceItemModel {
  final String id;
  final String title;
  final String location;
  final String price;
  final String? condition;
  final String category;
  final String badgeType; // 'Premium', 'Golden'
  final String imageUrl;
  final bool isGolden;
  final String description;
  final String? brand;
  final String timeAgo;
  final bool isNegotiable;
  final String sellerId;
  final String sellerName;
  final String sellerAvatar;
  final double sellerRating;
  final int sellerReviewCount;
  final String sellerMemberSince;
  final String sellerPhone;
  final List<String> photoUrls;
  final List<ProductPhoto> photos;
  final DateTime createdAt;
  final String status;
  final int viewsCount;
  final int offersCount;
  final int chatsCount;
  final int likesCount;
  final bool isSaved;

  MarketplaceItemModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    this.condition,
    required this.category,
    required this.badgeType,
    required this.imageUrl,
    this.isGolden = false,
    this.description = '',
    this.brand,
    this.timeAgo = 'Just now',
    this.isNegotiable = true,
    this.sellerId = '',
    this.sellerName = 'Desi Seller',
    this.sellerAvatar =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
    this.sellerRating = 4.8,
    this.sellerReviewCount = 36,
    this.sellerMemberSince = '2022',
    this.sellerPhone = '+34600000000',
    this.photoUrls = const [],
    this.photos = const [],
    DateTime? createdAt,
    this.status = 'ACTIVE',
    this.viewsCount = 0,
    this.offersCount = 0,
    this.chatsCount = 0,
    this.likesCount = 0,
    this.isSaved = false,
  }) : createdAt = createdAt ?? DateTime.now();

  MarketplaceItemModel copyWith({
    String? id,
    String? title,
    String? location,
    String? price,
    String? condition,
    String? category,
    String? badgeType,
    String? imageUrl,
    bool? isGolden,
    String? description,
    String? brand,
    String? timeAgo,
    bool? isNegotiable,
    String? sellerId,
    String? sellerName,
    String? sellerAvatar,
    double? sellerRating,
    int? sellerReviewCount,
    String? sellerMemberSince,
    String? sellerPhone,
    List<String>? photoUrls,
    List<ProductPhoto>? photos,
    DateTime? createdAt,
    String? status,
    int? viewsCount,
    int? offersCount,
    int? chatsCount,
    int? likesCount,
    bool? isSaved,
  }) {
    return MarketplaceItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      category: category ?? this.category,
      badgeType: badgeType ?? this.badgeType,
      imageUrl: imageUrl ?? this.imageUrl,
      isGolden: isGolden ?? this.isGolden,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      timeAgo: timeAgo ?? this.timeAgo,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      sellerRating: sellerRating ?? this.sellerRating,
      sellerReviewCount: sellerReviewCount ?? this.sellerReviewCount,
      sellerMemberSince: sellerMemberSince ?? this.sellerMemberSince,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      photoUrls: photoUrls ?? this.photoUrls,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      offersCount: offersCount ?? this.offersCount,
      chatsCount: chatsCount ?? this.chatsCount,
      likesCount: likesCount ?? this.likesCount,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  factory MarketplaceItemModel.fromJson(Map<String, dynamic> json) {
    // Photos parsing & image URL resolution
    final List<ProductPhoto> parsedPhotos = [];
    final List<String> photosList = [];
    String firstImageUrl =
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=600';

    final rawPhotos = json['photos'] ?? json['productPhotos'] ?? json['images'];
    if (rawPhotos is List && rawPhotos.isNotEmpty) {
      for (var photo in rawPhotos) {
        if (photo is Map) {
          final p = ProductPhoto.fromJson(Map<String, dynamic>.from(photo));
          parsedPhotos.add(p);
          photosList.add(p.url);
        } else if (photo is String && photo.isNotEmpty) {
          String url = photo;
          if (!url.startsWith('http')) {
            final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
                ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
                : ApiEndpoints.baseUrl;
            final path = url.startsWith('/') ? url : '/$url';
            url = '$baseUrl$path';
          }
          parsedPhotos.add(ProductPhoto(id: '', url: url));
          photosList.add(url);
        }
      }
      if (photosList.isNotEmpty) {
        firstImageUrl = photosList.first;
      }
    }

    if (parsedPhotos.isEmpty) {
      final singleImg = json['imageUrl'] ?? json['photo'] ?? json['image'];
      if (singleImg != null && singleImg.toString().isNotEmpty) {
        String url = singleImg.toString();
        if (!url.startsWith('http')) {
          final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
              ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
              : ApiEndpoints.baseUrl;
          final path = url.startsWith('/') ? url : '/$url';
          url = '$baseUrl$path';
        }
        parsedPhotos.add(ProductPhoto(id: '', url: url));
        photosList.add(url);
        firstImageUrl = url;
      }
    }

    // Seller resolution
    String sId = json['sellerId']?.toString() ?? '';
    String sName = 'Seller';
    String sAvatar =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200';
    String sPhone = '+34600000000';

    if (json['seller'] is Map) {
      final sellerMap = json['seller'] as Map<String, dynamic>;
      if (sId.isEmpty) {
        sId = (sellerMap['id'] ?? sellerMap['_id'] ?? '').toString();
      }
      final fn = sellerMap['firstName'] ?? '';
      final ln = sellerMap['lastName'] ?? '';
      final fullName = '$fn $ln'.trim();
      if (fullName.isNotEmpty) sName = fullName;
      if (sellerMap['phoneNumber'] != null) {
        sPhone = sellerMap['phoneNumber'].toString();
      }
      if (sellerMap['profilePhoto'] is Map &&
          sellerMap['profilePhoto']['url'] != null) {
        String pUrl = sellerMap['profilePhoto']['url'].toString();
        if (!pUrl.startsWith('http')) {
          pUrl = '${ApiEndpoints.baseUrl}$pUrl';
        }
        sAvatar = pUrl;
      }
    }

    // Format price
    final rawPrice = json['price']?.toString() ?? '0';
    final formattedPrice = rawPrice.startsWith('€') ? rawPrice : '€ $rawPrice';

    DateTime parsedCreatedAt;
    try {
      if (json['createdAt'] != null) {
        final dt = DateTime.tryParse(json['createdAt'].toString());
        parsedCreatedAt = dt != null ? dt.toLocal() : DateTime.now();
      } else {
        parsedCreatedAt = DateTime.now();
      }
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    final String status = json['status']?.toString().toUpperCase() ?? 'ACTIVE';
    final int viewsCount =
        json['viewsCount'] as int? ?? json['views'] as int? ?? 0;
    final int offersCount = (json['_count'] is Map
            ? ((json['_count'] as Map)['offers'] as int? ??
                (json['_count'] as Map)['productAdOffers'] as int?)
            : null) ??
        (json['offersCount'] as int?) ??
        (json['offers'] is List ? (json['offers'] as List).length : 0);
    final int chatsCount = json['chatsCount'] as int? ??
        (json['_count'] is Map
            ? ((json['_count'] as Map)['chats'] as int? ??
                (json['_count'] as Map)['conversations'] as int?)
            : null) ??
        0;
    final int likesCount = json['likesCount'] as int? ??
        (json['_count'] is Map
            ? ((json['_count'] as Map)['likes'] as int? ??
                (json['_count'] as Map)['saves'] as int?)
            : null) ??
        0;

    return MarketplaceItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      price: formattedPrice,
      condition: conditionFromApi(json['condition']?.toString()),
      category: categoryFromApi(json['category']?.toString()),
      badgeType: 'Premium',
      imageUrl: firstImageUrl,
      isGolden: false,
      description: json['description']?.toString() ?? '',
      brand: json['brand']?.toString(),
      timeAgo: _formatTimeAgo(json['createdAt']?.toString()),
      isNegotiable: json['negotiable'] ?? true,
      sellerId: sId,
      sellerName: sName,
      sellerAvatar: sAvatar,
      sellerPhone: sPhone,
      photoUrls: photosList,
      photos: parsedPhotos,
      createdAt: parsedCreatedAt,
      status: status,
      viewsCount: viewsCount,
      offersCount: offersCount,
      chatsCount: chatsCount,
      likesCount: likesCount,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'price': price,
      'condition': condition,
      'category': category,
      'badgeType': badgeType,
      'imageUrl': imageUrl,
      'isGolden': isGolden,
      'description': description,
      'brand': brand,
      'timeAgo': timeAgo,
      'negotiable': isNegotiable,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAvatar': sellerAvatar,
      'sellerRating': sellerRating,
      'sellerReviewCount': sellerReviewCount,
      'sellerMemberSince': sellerMemberSince,
      'sellerPhone': sellerPhone,
      'photos': photoUrls.map((url) => {'url': url}).toList(),
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'viewsCount': viewsCount,
      'offersCount': offersCount,
      'chatsCount': chatsCount,
      'likesCount': likesCount,
      'isSaved': isSaved,
    };
  }

  // --- Helper Enums Mappers ---
  static String categoryFromApi(String? category) {
    switch (category?.toUpperCase()) {
      case 'PHONES':
        return 'Phones';
      case 'CARS':
        return 'Cars';
      case 'ELECTRONICS':
        return 'Electronics';
      case 'FURNITURE':
        return 'Furniture';
      case 'CLOTHES':
        return 'Clothes';
      case 'BOOKS':
        return 'Books';
      case 'KIDS':
        return 'Kids';
      case 'OTHER':
        return 'Other';
      default:
        return category ?? 'Other';
    }
  }

  static String categoryToApi(String category) {
    switch (category.trim()) {
      case 'Phones':
      case 'Mobile Phones':
        return 'PHONES';
      case 'Cars':
        return 'CARS';
      case 'Electronics':
        return 'ELECTRONICS';
      case 'Furniture':
        return 'FURNITURE';
      case 'Clothes':
        return 'CLOTHES';
      case 'Books':
        return 'BOOKS';
      case 'Kids':
        return 'KIDS';
      case 'Other':
      default:
        return 'OTHER';
    }
  }

  static String conditionFromApi(String? condition) {
    switch (condition?.toUpperCase()) {
      case 'NEW':
        return 'New';
      case 'LIKE_NEW':
        return 'Like New';
      case 'GOOD':
        return 'Good';
      case 'FAIR':
        return 'Fair';
      case 'FOR_PARTS':
        return 'For Parts';
      default:
        return condition ?? 'New';
    }
  }

  static String conditionToApi(String condition) {
    switch (condition.trim()) {
      case 'New':
        return 'NEW';
      case 'Like New':
        return 'LIKE_NEW';
      case 'Good':
        return 'GOOD';
      case 'Fair':
        return 'FAIR';
      case 'For Parts':
        return 'FOR_PARTS';
      default:
        return 'NEW';
    }
  }

  static String _formatTimeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Just now';
    try {
      final dateTime = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 60) {
        return diff.inMinutes <= 1 ? "Just now" : "${diff.inMinutes} mins ago";
      } else if (diff.inHours < 24) {
        return '${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago';
      } else {
        return '${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago';
      }
    } catch (_) {
      return 'Just now';
    }
  }
}
