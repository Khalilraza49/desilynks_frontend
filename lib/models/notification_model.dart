import 'chat_model.dart';

/// Enum matching the backend NotificationType values.
enum NotificationType {
  postLiked,
  postShared,
  postCommented,
  chatMessage,
  jobApplication,
  applicationStatusUpdated,
  workerHired,
  needWorkerApplied,
  needWorkerApplicationStatus,
  propertyInquiry,
  productOffer,
  offerAccepted,
  offerRejected,
  groupInvite,
  groupJoined,
  groupMemberAdded,
  groupPost,
  system,
  unknown;

  static NotificationType fromString(String? value) {
    if (value == null || value.isEmpty) return NotificationType.unknown;
    for (final t in NotificationType.values) {
      if (t.name.toLowerCase() == value.toLowerCase()) return t;
    }
    switch (value.toUpperCase()) {
      case 'POST_LIKED':
        return NotificationType.postLiked;
      case 'POST_SHARED':
        return NotificationType.postShared;
      case 'POST_COMMENTED':
        return NotificationType.postCommented;
      case 'CHAT_MESSAGE':
        return NotificationType.chatMessage;
      case 'JOB_APPLICATION':
        return NotificationType.jobApplication;
      case 'APPLICATION_ACCEPTED':
      case 'APPLICATION_STATUS_UPDATED':
        return NotificationType.applicationStatusUpdated;
      case 'WORKER_HIRED':
        return NotificationType.workerHired;
      case 'NEED_WORKER_APPLIED':
        return NotificationType.needWorkerApplied;
      case 'NEED_WORKER_APPLICATION_STATUS':
        return NotificationType.needWorkerApplicationStatus;
      case 'PROPERTY_INQUIRY':
        return NotificationType.propertyInquiry;
      case 'PRODUCT_OFFER':
        return NotificationType.productOffer;
      case 'OFFER_ACCEPTED':
        return NotificationType.offerAccepted;
      case 'OFFER_REJECTED':
        return NotificationType.offerRejected;
      case 'GROUP_INVITE':
        return NotificationType.groupInvite;
      case 'GROUP_JOINED':
        return NotificationType.groupJoined;
      case 'GROUP_MEMBER_ADDED':
        return NotificationType.groupMemberAdded;
      case 'GROUP_POST':
        return NotificationType.groupPost;
      case 'SYSTEM':
        return NotificationType.system;
      default:
        return NotificationType.unknown;
    }
  }

  /// Returns a human-readable category label for tab filtering.
  String get category {
    switch (this) {
      case NotificationType.chatMessage:
        return 'Chat';
      case NotificationType.jobApplication:
      case NotificationType.applicationStatusUpdated:
      case NotificationType.workerHired:
      case NotificationType.needWorkerApplied:
      case NotificationType.needWorkerApplicationStatus:
        return 'Jobs';
      case NotificationType.postLiked:
      case NotificationType.postShared:
      case NotificationType.postCommented:
      case NotificationType.groupInvite:
      case NotificationType.groupJoined:
      case NotificationType.groupMemberAdded:
      case NotificationType.groupPost:
        return 'Community';
      case NotificationType.propertyInquiry:
      case NotificationType.productOffer:
      case NotificationType.offerAccepted:
      case NotificationType.offerRejected:
        return 'Deals';
      case NotificationType.system:
      case NotificationType.unknown:
        return 'All';
    }
  }
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String? recipientId;
  final String? actorId;
  final String title;
  final String body;
  final String? postId;
  final String? commentId;
  final String? workRequestId;
  final String? jobApplicationId;
  final String? productAdOfferId;
  final String? groupId;
  final String? needAWorkerAppId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final ChatParticipantModel? actor;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.type,
    this.recipientId,
    this.actorId,
    required this.title,
    required this.body,
    this.postId,
    this.commentId,
    this.workRequestId,
    this.jobApplicationId,
    this.productAdOfferId,
    this.groupId,
    this.needAWorkerAppId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.actor,
    this.data,
  });

  NotificationModel copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationModel(
      id: id,
      type: type,
      recipientId: recipientId,
      actorId: actorId,
      title: title,
      body: body,
      postId: postId,
      commentId: commentId,
      workRequestId: workRequestId,
      jobApplicationId: jobApplicationId,
      productAdOfferId: productAdOfferId,
      groupId: groupId,
      needAWorkerAppId: needAWorkerAppId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      actor: actor,
      data: data,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    ChatParticipantModel? parsedActor;
    if (json['actor'] is Map) {
      try {
        parsedActor = ChatParticipantModel.fromJson(
          Map<String, dynamic>.from(json['actor'] as Map),
        );
      } catch (_) {}
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: NotificationType.fromString(json['type']?.toString()),
      recipientId: json['recipientId']?.toString(),
      actorId: json['actorId']?.toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      postId: json['postId']?.toString() ?? json['data']?['postId']?.toString(),
      commentId: json['commentId']?.toString() ?? json['data']?['commentId']?.toString(),
      workRequestId: json['workRequestId']?.toString() ?? json['data']?['workRequestId']?.toString(),
      jobApplicationId: json['jobApplicationId']?.toString() ?? json['data']?['jobApplicationId']?.toString(),
      productAdOfferId: json['productAdOfferId']?.toString() ?? json['data']?['productAdOfferId']?.toString(),
      groupId: json['groupId']?.toString() ?? json['data']?['groupId']?.toString(),
      needAWorkerAppId: json['needAWorkerAppId']?.toString() ?? json['data']?['needAWorkerAppId']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      actor: parsedActor,
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'recipientId': recipientId,
    'actorId': actorId,
    'title': title,
    'body': body,
    'postId': postId,
    'commentId': commentId,
    'workRequestId': workRequestId,
    'jobApplicationId': jobApplicationId,
    'productAdOfferId': productAdOfferId,
    'groupId': groupId,
    'needAWorkerAppId': needAWorkerAppId,
    'isRead': isRead,
    'readAt': readAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'actor': actor?.toJson(),
    'data': data,
  };

  /// Relative time string (e.g., "2 hours ago", "Just now").
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
