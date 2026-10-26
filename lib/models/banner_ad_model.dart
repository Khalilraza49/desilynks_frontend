import 'package:flutter/material.dart';
import '../services/api/api_endpoints.dart';
import '../core/constants/app_icons.dart';

enum BannerAdPosition {
  popup(
    value: 'POPUP',
    label: 'Popup Banner',
    dropdownLabel: 'Popup Banner — €20 / 7 Days',
    priceText: 'from €20',
    durationText: '7 Days',
    icon: AppIcons.popup,
    iconColor: Color(0xFFDB2777),
    iconBgColor: Color(0xFFFDF2F8),
  ),
  homeScreen(
    value: 'HOME_SCREEN',
    label: 'Home Screen Banner',
    dropdownLabel: 'Home Screen Banner — €15 / 7 Days',
    priceText: 'from €15',
    durationText: '7 Days',
    icon: AppIcons.homeSvg,
    iconColor: Color(0xFF2563EB),
    iconBgColor: Color(0xFFEFF6FF),
  ),
  jobsScreen(
    value: 'JOBS_SCREEN',
    label: 'Jobs Screen Banner',
    dropdownLabel: 'Jobs Screen Banner — €12 / 7 Days',
    priceText: 'from €12',
    durationText: '7 Days',
    icon: AppIcons.businessSvg,
    iconColor: Color(0xFF059669),
    iconBgColor: Color(0xFFECFDF5),
  ),
  roomsScreen(
    value: 'ROOMS_SCREEN',
    label: 'Rooms Screen Banner',
    dropdownLabel: 'Rooms Screen Banner — €12 / 7 Days',
    priceText: 'from €12',
    durationText: '7 Days',
    icon: AppIcons.roomSvg,
    iconColor: Color(0xFFEA580C),
    iconBgColor: Color(0xFFFFF7ED),
  ),
  bottom(
    value: 'BOTTOM',
    label: 'Bottom Banner',
    dropdownLabel: 'Bottom Banner — €10 / 7 Days',
    priceText: 'from €10',
    durationText: '7 Days',
    icon: AppIcons.swag,
    iconColor: Color(0xFFD97706),
    iconBgColor: Color(0xFFFEF3C7),
  );

  final String value;
  final String label;
  final String dropdownLabel;
  final String priceText;
  final String durationText;
  final String icon;
  final Color iconColor;
  final Color iconBgColor;

  const BannerAdPosition({
    required this.value,
    required this.label,
    required this.dropdownLabel,
    required this.priceText,
    required this.durationText,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  static BannerAdPosition fromString(String? val) {
    if (val == null) return BannerAdPosition.homeScreen;
    final upper = val.trim().toUpperCase();
    for (final pos in BannerAdPosition.values) {
      if (pos.value == upper) return pos;
    }
    return BannerAdPosition.homeScreen;
  }
}

enum BannerAdStatus {
  running('RUNNING'),
  paused('PAUSED'),
  expired('EXPIRED');

  final String value;
  const BannerAdStatus(this.value);

  static BannerAdStatus fromString(String? val) {
    if (val == null) return BannerAdStatus.running;
    final upper = val.trim().toUpperCase();
    for (final st in BannerAdStatus.values) {
      if (st.value == upper) return st;
    }
    return BannerAdStatus.running;
  }
}

class BannerAdPhoto {
  final String id;
  final String url;

  BannerAdPhoto({
    required this.id,
    required this.url,
  });

  factory BannerAdPhoto.fromJson(Map<String, dynamic> json) {
    return BannerAdPhoto(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
  };
}

class BannerAdCreator {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhotoUrl;

  BannerAdCreator({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhotoUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory BannerAdCreator.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    final photo = json['profilePhoto'];
    if (photo is Map<String, dynamic>) {
      photoUrl = photo['url'] as String?;
    } else if (photo is String) {
      photoUrl = photo;
    }

    if (photoUrl != null && !photoUrl.startsWith('http')) {
      photoUrl = '${ApiEndpoints.baseUrl}$photoUrl';
    }

    return BannerAdCreator(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      profilePhotoUrl: photoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    if (profilePhotoUrl != null) 'profilePhoto': {'url': profilePhotoUrl},
  };
}

class BannerAdModel {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final String ctaButtonText;
  final String destinationLink;
  final int views;
  final int clicks;
  final BannerAdPosition position;
  final BannerAdStatus status;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BannerAdPhoto? photo;
  final BannerAdCreator? creator;

  BannerAdModel({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.ctaButtonText,
    required this.destinationLink,
    required this.views,
    required this.clicks,
    required this.position,
    required this.status,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.photo,
    this.creator,
  });

  String get photoUrl {
    if (photo?.url != null && photo!.url.isNotEmpty) {
      final u = photo!.url;
      if (u.startsWith('http')) return u;
      return '${ApiEndpoints.baseUrl}$u';
    }
    return '';
  }

  double get clickThroughRate {
    if (views <= 0) return 0.0;
    return (clicks / views) * 100;
  }

  bool get isRunning => status == BannerAdStatus.running;
  bool get isPaused => status == BannerAdStatus.paused;
  bool get isExpired => status == BannerAdStatus.expired;

  factory BannerAdModel.fromJson(Map<String, dynamic> json) {
    return BannerAdModel(
      id: json['id'] as String? ?? '',
      creatorId: json['creatorId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ctaButtonText: json['ctaButtonText'] as String? ?? 'Shop Now',
      destinationLink: json['destinationLink'] as String? ?? '',
      views: (json['views'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      position: BannerAdPosition.fromString(json['position'] as String?),
      status: BannerAdStatus.fromString(json['status'] as String?),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      photo: json['photo'] is Map<String, dynamic>
          ? BannerAdPhoto.fromJson(json['photo'] as Map<String, dynamic>)
          : null,
      creator: json['creator'] is Map<String, dynamic>
          ? BannerAdCreator.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'creatorId': creatorId,
    'title': title,
    'description': description,
    'ctaButtonText': ctaButtonText,
    'destinationLink': destinationLink,
    'views': views,
    'clicks': clicks,
    'position': position.value,
    'status': status.value,
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (photo != null) 'photo': photo!.toJson(),
    if (creator != null) 'creator': creator!.toJson(),
  };
}
