import '../services/api/api_endpoints.dart';
import 'community_enums.dart';
import 'community_poll_model.dart';

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

/// Photo item attached to a post
class PostPhotoModel {
  final String id;
  final String url;

  const PostPhotoModel({required this.id, required this.url});

  factory PostPhotoModel.fromJson(dynamic json) {
    if (json is String) {
      return PostPhotoModel(id: '', url: _normalizeUrl(json));
    }
    if (json is Map) {
      final rawUrl = (json['url'] ??
              json['photoUrl'] ??
              json['imageUrl'] ??
              json['path'] ??
              json['link']) as String? ??
          '';
      return PostPhotoModel(
        id: (json['id'] ?? json['_id'])?.toString() ?? '',
        url: _normalizeUrl(rawUrl),
      );
    }
    return const PostPhotoModel(id: '', url: '');
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url};
}

/// Video item attached to a post
class PostVideoModel {
  final String id;
  final String url;

  const PostVideoModel({required this.id, required this.url});

  factory PostVideoModel.fromJson(dynamic json) {
    if (json is String) {
      return PostVideoModel(id: '', url: _normalizeUrl(json));
    }
    if (json is Map) {
      final rawUrl = (json['url'] ??
              json['videoUrl'] ??
              json['path'] ??
              json['link']) as String? ??
          '';
      return PostVideoModel(
        id: (json['id'] ?? json['_id'])?.toString() ?? '',
        url: _normalizeUrl(rawUrl),
      );
    }
    return const PostVideoModel(id: '', url: '');
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url};
}

/// Author metadata in PostObject
class PostAuthorModel {
  final String id;
  final String firstName;
  final String? lastName;
  final String? profilePhotoUrl;

  const PostAuthorModel({
    required this.id,
    required this.firstName,
    this.lastName,
    this.profilePhotoUrl,
  });

  String get fullName => lastName != null && lastName!.isNotEmpty
      ? '$firstName $lastName'
      : firstName;

  factory PostAuthorModel.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['profilePhoto'] != null && json['profilePhoto'] is Map) {
      photoUrl = json['profilePhoto']['url'] as String?;
    } else if (json['profilePhotoUrl'] != null) {
      photoUrl = json['profilePhotoUrl'] as String?;
    }

    return PostAuthorModel(
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

/// Group metadata in PostObject
class PostGroupModel {
  final String id;
  final String name;
  final String? coverPhotoUrl;

  const PostGroupModel({
    required this.id,
    required this.name,
    this.coverPhotoUrl,
  });

  factory PostGroupModel.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    if (json['coverPhoto'] != null && json['coverPhoto'] is Map) {
      coverUrl = json['coverPhoto']['url'] as String?;
    }
    return PostGroupModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      coverPhotoUrl: coverUrl != null && coverUrl.isNotEmpty
          ? _normalizeUrl(coverUrl)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverPhoto': {'url': coverPhotoUrl},
    };
  }
}

/// Comprehensive Community Post Model representing PostObject in DesiConnect
class CommunityPostModel {
  final String id;
  final String? authorId;
  final String? groupId;
  final CommunityPostType type;
  final CommunityPostVisibility visibility;
  final CommunityPostStatus status;
  final String content;
  final String? officialSource;
  final String authorLocation;
  final bool isVerified;
  final String timeAgo;
  final String tag;
  final String? location;
  final String? feeling;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relations
  final PostAuthorModel? author;
  final PostGroupModel? group;
  final List<PostPhotoModel> photos;
  final PostVideoModel? video;
  final PollModel? poll;

  // Interactions
  int likesCount;
  int commentsCount;
  int sharesCount;
  bool isLiked;
  bool isSaved;

  // Backwards compatibility / UI helpers
  final String? legacyAuthorName;
  final String? legacyAuthorAvatar;
  final String? legacyMediaUrl;
  final List<String>? legacyPollOptions;
  final Map<int, int> pollVotes;
  int? userVotedOption;

  CommunityPostModel({
    required this.id,
    this.authorId,
    this.groupId,
    this.type = CommunityPostType.TEXT,
    this.visibility = CommunityPostVisibility.PUBLIC,
    this.status = CommunityPostStatus.ACTIVE,
    required this.content,
    this.officialSource,
    this.authorLocation = 'Madrid',
    this.isVerified = false,
    required this.timeAgo,
    this.tag = 'General',
    this.location,
    this.feeling,
    this.createdAt,
    this.updatedAt,
    this.author,
    this.group,
    this.photos = const [],
    this.video,
    this.poll,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    String? authorName,
    String? authorAvatarUrl,
    String? postType,
    String? mediaUrl,
    List<String>? pollOptions,
    Map<int, int>? pollVotes,
    this.userVotedOption,
    String? audience,
  }) : legacyAuthorName = authorName,
       legacyAuthorAvatar = authorAvatarUrl,
       legacyMediaUrl = mediaUrl,
       legacyPollOptions = pollOptions,
       pollVotes = pollVotes ?? {};

  String get authorName =>
      author?.fullName ?? legacyAuthorName ?? 'Community Member';
  String? get authorAvatarUrl => author?.profilePhotoUrl ?? legacyAuthorAvatar;
  String? get mediaUrl =>
      photos.isNotEmpty ? photos.first.url : (video?.url ?? legacyMediaUrl);
  List<String>? get pollOptions =>
      poll?.options.map((o) => o.text).toList() ?? legacyPollOptions;

  int get totalPollVotes =>
      poll?.totalVotes ?? pollVotes.values.fold(0, (sum, count) => sum + count);

  bool get hasPhotos =>
      photos.isNotEmpty ||
      (legacyMediaUrl != null &&
          !legacyMediaUrl!.endsWith('.mp4') &&
          type == CommunityPostType.PHOTO) ||
      (photos.isEmpty &&
          video == null &&
          legacyMediaUrl != null &&
          !legacyMediaUrl!.endsWith('.mp4'));

  bool get hasVideo =>
      video != null ||
      type == CommunityPostType.VIDEO ||
      (legacyMediaUrl != null &&
          (legacyMediaUrl!.endsWith('.mp4') ||
              legacyMediaUrl!.contains('video')));

  String? get videoUrl => video?.url ?? (hasVideo ? legacyMediaUrl : null);

  List<String> get allPhotoUrls {
    if (photos.isNotEmpty) {
      return photos.map((p) => p.url).toList();
    }
    if (legacyMediaUrl != null && !hasVideo) {
      return [legacyMediaUrl!];
    }
    return [];
  }

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    final rawPhotos = (json['photos'] ??
            json['media'] ??
            json['images'] ??
            json['attachments']) as List<dynamic>? ??
        [];
    final photosList = <PostPhotoModel>[];
    for (final p in rawPhotos) {
      if (p is String && p.trim().isNotEmpty) {
        photosList.add(PostPhotoModel(id: '', url: _normalizeUrl(p)));
      } else if (p is Map) {
        final photo = PostPhotoModel.fromJson(p);
        if (photo.url.isNotEmpty) {
          photosList.add(photo);
        }
      }
    }
    if (photosList.isEmpty) {
      final single = json['mediaUrl'] ??
          json['imageUrl'] ??
          json['photoUrl'] ??
          json['photo'] ??
          json['image'];
      if (single is String && single.trim().isNotEmpty) {
        photosList.add(PostPhotoModel(id: '', url: _normalizeUrl(single)));
      }
    }

    final authorLoc = json['authorLocation'] ??
        (json['author'] is Map
            ? (json['author']['city'] ?? json['author']['location'])
            : null) ??
        'Madrid';

    return CommunityPostModel(
      id: json['id'] as String? ?? '',
      authorId: json['authorId'] as String?,
      groupId: json['groupId'] as String? ??
          (json['group'] is Map
              ? (json['group']['id'] ?? json['group']['_id'])?.toString()
              : null),
      type: CommunityPostType.fromJson(json['type'] as String?),
      visibility: CommunityPostVisibility.fromJson(
        json['visibility'] as String?,
      ),
      status: CommunityPostStatus.fromJson(json['status'] as String?),
      content: json['content'] as String? ?? '',
      tag: (json['tag'] ?? json['category'] ?? 'General').toString(),
      authorLocation: authorLoc.toString(),
      location: json['location'] as String?,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLikedByMe'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      timeAgo: json['timeAgo'] as String? ??
          formatTimeAgo(
            json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'] as String)
                : null,
          ),
      author: json['author'] != null
          ? PostAuthorModel.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      group: json['group'] != null
          ? PostGroupModel.fromJson(json['group'] as Map<String, dynamic>)
          : null,
      photos: photosList,
      video: json['video'] != null
          ? PostVideoModel.fromJson(json['video'] as Map<String, dynamic>)
          : null,
      poll: json['poll'] != null
          ? PollModel.fromJson(json['poll'] as Map<String, dynamic>)
          : null,
      mediaUrl: json['mediaUrl'] != null
          ? _normalizeUrl(json['mediaUrl'] as String)
          : null,
    );
  }

  static String formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) {
      return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours} hours ago';
    }
    if (diff.inDays < 7) {
      return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }
    final months = (diff.inDays / 30).floor();
    return months == 1 ? '1 month ago' : '$months months ago';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'groupId': groupId,
      'type': type.toJson(),
      'visibility': visibility.toJson(),
      'status': status.toJson(),
      'content': content,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'isLikedByMe': isLiked,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      if (author != null) 'author': author!.toJson(),
      if (group != null) 'group': group!.toJson(),
      'photos': photos.map((p) => p.toJson()).toList(),
      if (video != null) 'video': video!.toJson(),
      if (poll != null) 'poll': poll!.toJson(),
    };
  }
}
