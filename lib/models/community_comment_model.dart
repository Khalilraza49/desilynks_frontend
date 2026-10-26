import '../services/api/api_endpoints.dart';

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

/// Model representing a Community Post Comment / Reply
class CommunityCommentModel {
  final String id;
  final String content;
  final String postId;
  final String userId;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int repliesCount;
  final CommunityCommentUser? user;
  final CommunityCommentPostSummary? post;

  const CommunityCommentModel({
    required this.id,
    required this.content,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.repliesCount = 0,
    this.user,
    this.post,
  });

  bool get isReply => parentId != null && parentId!.isNotEmpty;

  factory CommunityCommentModel.fromJson(Map<String, dynamic> json) {
    return CommunityCommentModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      parentId: json['parentId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      repliesCount: (json['repliesCount'] as num?)?.toInt() ?? 0,
      user: json['user'] != null
          ? CommunityCommentUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      post: json['post'] != null
          ? CommunityCommentPostSummary.fromJson(
              json['post'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'postId': postId,
      'userId': userId,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'repliesCount': repliesCount,
      if (user != null) 'user': user!.toJson(),
      if (post != null) 'post': post!.toJson(),
    };
  }
}

/// Author metadata in Comment response
class CommunityCommentUser {
  final String id;
  final String firstName;
  final String? lastName;
  final String? profilePhotoUrl;

  const CommunityCommentUser({
    required this.id,
    required this.firstName,
    this.lastName,
    this.profilePhotoUrl,
  });

  String get fullName => lastName != null && lastName!.isNotEmpty
      ? '$firstName $lastName'
      : firstName;

  factory CommunityCommentUser.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['profilePhoto'] != null && json['profilePhoto'] is Map) {
      photoUrl = json['profilePhoto']['url'] as String?;
    } else if (json['profilePhotoUrl'] != null) {
      photoUrl = json['profilePhotoUrl'] as String?;
    }

    return CommunityCommentUser(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? 'User',
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
      'profilePhoto': {'url': profilePhotoUrl},
    };
  }
}

/// Post summary in `GET /community/post/comment/me`
class CommunityCommentPostSummary {
  final String id;
  final String type;
  final String content;
  final CommunityCommentUser? author;

  const CommunityCommentPostSummary({
    required this.id,
    required this.type,
    required this.content,
    this.author,
  });

  factory CommunityCommentPostSummary.fromJson(Map<String, dynamic> json) {
    return CommunityCommentPostSummary(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'TEXT',
      content: json['content'] as String? ?? '',
      author: json['author'] != null
          ? CommunityCommentUser.fromJson(
              json['author'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      if (author != null) 'author': author!.toJson(),
    };
  }
}
