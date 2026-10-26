import 'dart:ui';
import '../services/api/api_endpoints.dart';
import '../core/constants/app_icons.dart';
import '../core/utils/image_utils.dart';
import 'community_enums.dart';

String _normalizeUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return '';
  final trimmed = rawUrl.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
      ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
      : ApiEndpoints.baseUrl;
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$baseUrl$path';
}

/// Basic creator user details embedded in CommunityGroup responses
class CommunityGroupCreator {
  final String id;
  final String firstName;
  final String? lastName;
  final String? profilePhotoUrl;

  const CommunityGroupCreator({
    required this.id,
    required this.firstName,
    this.lastName,
    this.profilePhotoUrl,
  });

  String get fullName {
    if (lastName != null && lastName!.trim().isNotEmpty) {
      return '$firstName ${lastName!.trim()}';
    }
    return firstName;
  }

  factory CommunityGroupCreator.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['profilePhoto'] != null && json['profilePhoto'] is Map) {
      photoUrl = json['profilePhoto']['url'] as String?;
    } else if (json['profilePhotoUrl'] != null) {
      photoUrl = json['profilePhotoUrl'] as String?;
    }

    return CommunityGroupCreator(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String?,
      profilePhotoUrl: photoUrl != null && photoUrl.isNotEmpty
          ? _normalizeUrl(photoUrl)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'profilePhoto': profilePhotoUrl != null ? {'url': profilePhotoUrl} : null,
    };
  }
}

/// Model representing a Community Group
class CommunityGroupModel {
  final String id;
  final String name;
  final String description;
  final CommunityGroupStatus status;
  final CommunityGroupCategory category;
  final CommunityGroupPrivacy privacy;
  final String creatorId;
  final int memberCount;
  final String? coverPhotoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CommunityGroupCreator? creator;

  const CommunityGroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.category,
    required this.privacy,
    required this.creatorId,
    required this.memberCount,
    this.coverPhotoUrl,
    this.createdAt,
    this.updatedAt,
    this.creator,
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Helper Getters
  // ──────────────────────────────────────────────────────────────────────────
  String get title => name;
  bool get isPublic => privacy == CommunityGroupPrivacy.PUBLIC;
  bool get isPrivate => privacy == CommunityGroupPrivacy.PRIVATE;
  bool get isActive => status == CommunityGroupStatus.ACTIVE;
  bool get isArchived => status == CommunityGroupStatus.ARCHIVED;
  bool get isSuspended => status == CommunityGroupStatus.SUSPENDED;

  String get formattedMemberCount {
    if (memberCount == 1) return '1 member';
    return '$memberCount members';
  }

  /// Converts the model to a map suitable for existing UI components that accept Map
  Map<String, dynamic> toMapForUI() {
    final initials = name.trim().isNotEmpty
        ? (name.trim().length >= 2 ? name.trim().substring(0, 2).toUpperCase() : name.trim().toUpperCase())
        : 'GP';

    return {
      'id': id,
      'groupId': id,
      'title': name,
      'name': name,
      'description': description,
      'members': formattedMemberCount,
      'memberCount': memberCount,
      'coverImageUrl': coverPhotoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'imageUrl': coverPhotoUrl,
      'coverPhoto': coverPhotoUrl != null ? {'url': coverPhotoUrl} : null,
      'category': category.name,
      'categoryLabel': category.displayName,
      'privacy': privacy.name,
      'status': status.name,
      'creatorId': creatorId,
      'creator': creator?.fullName ?? 'Admin',
      'tag': initials,
      'bgColor': const Color(0xFF0052FF),
      'icon': AppIcons.assetCommuintySvg,
      'iconColor': const Color(0xFF0052FF),
      'isJoined': false,
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Serialization
  // ──────────────────────────────────────────────────────────────────────────
  factory CommunityGroupModel.fromJson(Map<String, dynamic> json) {
    final map = (json['group'] is Map<String, dynamic>)
        ? json['group'] as Map<String, dynamic>
        : json;

    final resolvedCover = ImageUtils.resolveGroupCoverUrl(json);

    return CommunityGroupModel(
      id: (map['id'] ?? map['groupId'] ?? json['id'] ?? '') as String,
      name: (map['name'] ?? map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      status: CommunityGroupStatus.fromJson(map['status'] as String?),
      category: CommunityGroupCategory.fromJson(map['category'] as String?),
      privacy: CommunityGroupPrivacy.fromJson(map['privacy'] as String?),
      creatorId: (map['creatorId'] ?? '') as String,
      memberCount: (map['memberCount'] is num)
          ? (map['memberCount'] as num).toInt()
          : 0,
      coverPhotoUrl: resolvedCover.isNotEmpty ? resolvedCover : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
      creator: map['creator'] != null && map['creator'] is Map<String, dynamic>
          ? CommunityGroupCreator.fromJson(
              map['creator'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.toJson(),
      'category': category.toJson(),
      'privacy': privacy.toJson(),
      'creatorId': creatorId,
      'memberCount': memberCount,
      'coverPhoto': coverPhotoUrl != null ? {'url': coverPhotoUrl} : null,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      if (creator != null) 'creator': creator!.toJson(),
    };
  }

  CommunityGroupModel copyWith({
    String? id,
    String? name,
    String? description,
    CommunityGroupStatus? status,
    CommunityGroupCategory? category,
    CommunityGroupPrivacy? privacy,
    String? creatorId,
    int? memberCount,
    String? coverPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    CommunityGroupCreator? creator,
  }) {
    return CommunityGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      privacy: privacy ?? this.privacy,
      creatorId: creatorId ?? this.creatorId,
      memberCount: memberCount ?? this.memberCount,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creator: creator ?? this.creator,
    );
  }
}
