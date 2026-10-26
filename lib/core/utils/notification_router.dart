import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../models/notification_model.dart';
import '../../app/routes.dart';
import '../../views/chat/chat_detail_view.dart';
import '../../viewmodels/notifications/notifications_viewmodel.dart';

/// Centralized deep linking router for in-app taps and push notification payloads.
/// Conforms to Notifications Module Documentation.
class NotificationRouter {
  NotificationRouter._();

  /// Routes based on a [NotificationModel], marking it as read if [vm] is supplied.
  static void routeNotification(
    BuildContext context,
    NotificationModel item, {
    NotificationsViewModel? vm,
  }) {
    if (vm != null) {
      vm.markAsRead(item.id);
    }

    developer.log(
      'NotificationRouter: routing notification type=${item.type} id=${item.id}',
      name: 'NotificationRouter',
    );

    switch (item.type) {
      case NotificationType.chatMessage:
        final actor = item.actor;
        final actorId = item.actorId ?? actor?.id ?? '';
        final convId = item.data?['conversationId']?.toString() ??
            item.data?['chatId']?.toString() ??
            '';

        if (actorId.isNotEmpty || convId.isNotEmpty) {
          final conv = ChatConversationModel(
            id: convId,
            otherParticipant: actor ??
                ChatParticipantModel(
                  id: actorId,
                  firstName: item.title,
                  lastName: '',
                ),
            updatedAt: DateTime.now(),
            createdAt: DateTime.now(),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailView(conversation: conv),
            ),
          );
        }
        break;

      case NotificationType.jobApplication:
        // Employer received application
        final jobId = item.data?['jobId']?.toString() ??
            item.jobApplicationId;
        if (jobId != null && jobId.isNotEmpty) {
          Navigator.pushNamed(
            context,
            AppRoutes.applicants,
            arguments: {'id': jobId},
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.myJobs);
        }
        break;

      case NotificationType.applicationStatusUpdated:
        // Applicant received status update on their applied job
        Navigator.pushNamed(context, AppRoutes.myApplications);
        break;

      case NotificationType.workerHired:
      case NotificationType.needWorkerApplied:
      case NotificationType.needWorkerApplicationStatus:
        final requestId = item.workRequestId ??
            item.needAWorkerAppId ??
            item.data?['workRequestId']?.toString();
        if (requestId != null && requestId.isNotEmpty) {
          Navigator.pushNamed(
            context,
            AppRoutes.workerRequests,
            arguments: requestId,
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.workerRequests);
        }
        break;

      case NotificationType.postLiked:
      case NotificationType.postCommented:
      case NotificationType.postShared:
        final groupId = item.groupId ?? item.data?['groupId']?.toString();
        if (groupId != null && groupId.isNotEmpty) {
          Navigator.pushNamed(
            context,
            AppRoutes.groupDetail,
            arguments: {'id': groupId, 'groupId': groupId},
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.myCommunityPosts);
        }
        break;

      case NotificationType.groupInvite:
      case NotificationType.groupJoined:
      case NotificationType.groupMemberAdded:
      case NotificationType.groupPost:
        final groupId = item.groupId ?? item.data?['groupId']?.toString();
        if (groupId != null && groupId.isNotEmpty) {
          Navigator.pushNamed(
            context,
            AppRoutes.groupDetail,
            arguments: {'id': groupId, 'groupId': groupId},
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.allGroups);
        }
        break;

      case NotificationType.productOffer:
      case NotificationType.offerAccepted:
      case NotificationType.offerRejected:
        Navigator.pushNamed(context, AppRoutes.myOffers);
        break;

      case NotificationType.propertyInquiry:
        Navigator.pushNamed(context, AppRoutes.myAds);
        break;

      case NotificationType.system:
      case NotificationType.unknown:
        break;
    }
  }

  /// Parses a remote push or local notification data payload and routes appropriately.
  static void routePayload(
    BuildContext context,
    Map<String, dynamic> payload, {
    NotificationsViewModel? vm,
  }) {
    try {
      final Map<String, dynamic> sanitized = Map<String, dynamic>.from(payload);
      if (sanitized['data'] is String) {
        try {
          sanitized['data'] = jsonDecode(sanitized['data'] as String);
        } catch (_) {}
      }
      if (sanitized['actor'] is String) {
        try {
          sanitized['actor'] = jsonDecode(sanitized['actor'] as String);
        } catch (_) {}
      }
      final notif = NotificationModel.fromJson(sanitized);
      routeNotification(context, notif, vm: vm);
    } catch (e) {
      developer.log(
        'NotificationRouter: failed to parse and route push payload: $e',
        name: 'NotificationRouter',
        error: e,
      );
    }
  }
}
