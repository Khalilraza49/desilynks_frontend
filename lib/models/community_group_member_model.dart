import '../services/api/api_endpoints.dart';
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

/// Basic user profile embedded in CommunityGroupMember responses
class CommunityGroupMemberUser {
  final String id;
  final String firstName;
  final String? lastName;
  final String? profilePhotoUrl;

  const CommunityGroupMemberUser({
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

  factory CommunityGroupMemberUser.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['profilePhoto'] != null && json['profilePhoto'] is Map) {
      photoUrl = json['profilePhoto']['url'] as String?;
    } else if (json['profilePhotoUrl'] != null) {
      photoUrl = json['profilePhotoUrl'] as String?;
    }

    return CommunityGroupMemberUser(
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

/// Community Group Member model
class CommunityGroupMemberModel {
  final String id;
  final String groupId;
  final String userId;
  final CommunityGroupMemberRole role;
  final CommunityGroupMemberStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CommunityGroupMemberUser? user;

  const CommunityGroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Helper Getters
  // ──────────────────────────────────────────────────────────────────────────
  String get displayName =>
      user?.fullName.isNotEmpty == true ? user!.fullName : 'Member';

  String? get avatarUrl => user?.profilePhotoUrl;

  bool get isAdmin => role == CommunityGroupMemberRole.ADMIN;
  bool get isModerator => role == CommunityGroupMemberRole.MODERATOR;
  bool get isMember => role == CommunityGroupMemberRole.MEMBER;

  bool get isActive => status == CommunityGroupMemberStatus.ACTIVE;
  bool get isPending => status == CommunityGroupMemberStatus.PENDING;
  bool get isRejected => status == CommunityGroupMemberStatus.REJECTED;
  bool get isBanned => status == CommunityGroupMemberStatus.BANNED;

  // ──────────────────────────────────────────────────────────────────────────
  // Serialization
  // ──────────────────────────────────────────────────────────────────────────
  factory CommunityGroupMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityGroupMemberModel(
      id: json['id'] as String? ?? '',
      groupId: json['groupId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      role: CommunityGroupMemberRole.fromJson(json['role'] as String?),
      status: CommunityGroupMemberStatus.fromJson(json['status'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? CommunityGroupMemberUser.fromJson(
              json['user'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'role': role.toJson(),
      'status': status.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
    };
  }

  CommunityGroupMemberModel copyWith({
    String? id,
    String? groupId,
    String? userId,
    CommunityGroupMemberRole? role,
    CommunityGroupMemberStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    CommunityGroupMemberUser? user,
  }) {
    return CommunityGroupMemberModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
