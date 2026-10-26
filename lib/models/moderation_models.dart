import 'package:desilynks/services/api/api_endpoints.dart';

enum ReportTargetType {
  user('USER', 'User Profile'),
  communityPost('COMMUNITY_POST', 'Community Post'),
  communityComment('COMMUNITY_COMMENT', 'Comment'),
  communityGroup('COMMUNITY_GROUP', 'Group'),
  communityEvent('COMMUNITY_EVENT', 'Event'),
  message('MESSAGE', 'Chat Message'),
  productAd('PRODUCT_AD', 'Product Ad'),
  property('PROPERTY', 'Property Listing'),
  job('JOB', 'Job Listing'),
  businessListing('BUSINESS_LISTING', 'Business Listing'),
  needAWorker('NEED_A_WORKER', 'Need a Worker Post'),
  workerProfile('WORKER_PROFILE', 'Worker Profile'),
  bannerAd('BANNER_AD', 'Banner Advertisement');

  final String value;
  final String label;
  const ReportTargetType(this.value, this.label);
}

enum ReportReason {
  spam('SPAM', 'Spam'),
  harassment('HARASSMENT', 'Harassment or bullying'),
  hateSpeech('HATE_SPEECH', 'Hate speech'),
  nudity('NUDITY', 'Nudity or sexual content'),
  violence('VIOLENCE', 'Violence'),
  scam('SCAM', 'Scam or fraud'),
  falseInformation('FALSE_INFORMATION', 'False information'),
  other('OTHER', 'Something else');

  final String value;
  final String label;
  const ReportReason(this.value, this.label);
}

class BlockedUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhotoUrl;
  final String? blockedAt;

  const BlockedUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhotoUrl,
    this.blockedAt,
  });

  String get fullName {
    final combined = '$firstName $lastName'.trim();
    return combined.isNotEmpty ? combined : 'Deleted User';
  }

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['profilePhoto'] is Map<String, dynamic>) {
      photoUrl = json['profilePhoto']['url'] as String? ??
          json['profilePhoto']['path'] as String?;
    } else if (json['profilePhoto'] is String) {
      photoUrl = json['profilePhoto'] as String;
    } else if (json['profilePhotoUrl'] is String) {
      photoUrl = json['profilePhotoUrl'] as String;
    }

    if (photoUrl != null &&
        photoUrl.isNotEmpty &&
        !photoUrl.startsWith('http')) {
      final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = photoUrl.startsWith('/') ? photoUrl : '/$photoUrl';
      photoUrl = '$baseUrl$path';
    }

    return BlockedUserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      firstName: (json['firstName'] as String?)?.trim() ?? '',
      lastName: (json['lastName'] as String?)?.trim() ?? '',
      profilePhotoUrl: photoUrl,
      blockedAt: json['blockedAt'] as String?,
    );
  }
}

class BlockedUsersPaginationModel {
  final List<BlockedUserModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const BlockedUsersPaginationModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory BlockedUsersPaginationModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] is List ? json['data'] as List : [];
    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map(BlockedUserModel.fromJson)
        .toList();

    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : <String, dynamic>{};

    return BlockedUsersPaginationModel(
      data: items,
      total: (meta['total'] as num?)?.toInt() ?? items.length,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 20,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
