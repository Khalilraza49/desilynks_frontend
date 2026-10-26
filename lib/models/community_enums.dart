// ignore_for_file: constant_identifier_names

/// Prisma Enums for Community Module
enum CommunityPostType {
  TEXT,
  PHOTO,
  VIDEO,
  POLL;

  String toJson() => name;

  static CommunityPostType fromJson(String? value) {
    if (value == null) return CommunityPostType.TEXT;
    return CommunityPostType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => CommunityPostType.TEXT,
    );
  }
}

enum CommunityPostVisibility {
  PUBLIC,
  GROUP,
  PRIVATE;

  String toJson() => name;

  static CommunityPostVisibility fromJson(String? value) {
    if (value == null) return CommunityPostVisibility.PUBLIC;
    return CommunityPostVisibility.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => CommunityPostVisibility.PUBLIC,
    );
  }
}

enum CommunityPostStatus {
  ACTIVE,
  HIDDEN,
  REMOVED;

  String toJson() => name;

  static CommunityPostStatus fromJson(String? value) {
    if (value == null) return CommunityPostStatus.ACTIVE;
    return CommunityPostStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => CommunityPostStatus.ACTIVE,
    );
  }
}

enum CommunityGroupMemberRole {
  ADMIN,
  MODERATOR,
  MEMBER;

  String toJson() => name;

  static CommunityGroupMemberRole fromJson(String? value) {
    if (value == null) return CommunityGroupMemberRole.MEMBER;
    return CommunityGroupMemberRole.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => CommunityGroupMemberRole.MEMBER,
    );
  }

  bool get isAdmin => this == CommunityGroupMemberRole.ADMIN;
  bool get isModerator => this == CommunityGroupMemberRole.MODERATOR;
  bool get isMember => this == CommunityGroupMemberRole.MEMBER;
}

enum CommunityGroupMemberStatus {
  ACTIVE,
  PENDING,
  REJECTED,
  BANNED;

  String toJson() => name;

  static CommunityGroupMemberStatus fromJson(String? value) {
    if (value == null) return CommunityGroupMemberStatus.ACTIVE;
    return CommunityGroupMemberStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => CommunityGroupMemberStatus.ACTIVE,
    );
  }

  bool get isActive => this == CommunityGroupMemberStatus.ACTIVE;
  bool get isPending => this == CommunityGroupMemberStatus.PENDING;
  bool get isRejected => this == CommunityGroupMemberStatus.REJECTED;
  bool get isBanned => this == CommunityGroupMemberStatus.BANNED;
}

enum CommunityGroupCategory {
  FUN,
  SPORT,
  EDUCATIONAL,
  OTHER;

  String toJson() => name;

  static CommunityGroupCategory fromJson(String? value) {
    if (value == null) return CommunityGroupCategory.OTHER;
    return CommunityGroupCategory.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => CommunityGroupCategory.OTHER,
    );
  }

  String get displayName {
    switch (this) {
      case CommunityGroupCategory.FUN:
        return 'Fun & Social';
      case CommunityGroupCategory.SPORT:
        return 'Sports & Fitness';
      case CommunityGroupCategory.EDUCATIONAL:
        return 'Educational & Learning';
      case CommunityGroupCategory.OTHER:
        return 'Other';
    }
  }
}

enum CommunityGroupPrivacy {
  PUBLIC,
  PRIVATE;

  String toJson() => name;

  static CommunityGroupPrivacy fromJson(String? value) {
    if (value == null) return CommunityGroupPrivacy.PUBLIC;
    return CommunityGroupPrivacy.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => CommunityGroupPrivacy.PUBLIC,
    );
  }

  bool get isPublic => this == CommunityGroupPrivacy.PUBLIC;
  bool get isPrivate => this == CommunityGroupPrivacy.PRIVATE;

  String get displayName {
    switch (this) {
      case CommunityGroupPrivacy.PUBLIC:
        return 'Public (Anyone can join)';
      case CommunityGroupPrivacy.PRIVATE:
        return 'Private (Admin approval required)';
    }
  }
}

enum CommunityGroupStatus {
  ACTIVE,
  ARCHIVED,
  SUSPENDED;

  String toJson() => name;

  static CommunityGroupStatus fromJson(String? value) {
    if (value == null) return CommunityGroupStatus.ACTIVE;
    return CommunityGroupStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => CommunityGroupStatus.ACTIVE,
    );
  }

  bool get isActive => this == CommunityGroupStatus.ACTIVE;
  bool get isArchived => this == CommunityGroupStatus.ARCHIVED;
  bool get isSuspended => this == CommunityGroupStatus.SUSPENDED;
}

