import 'dart:convert';
import 'dart:developer' as developer;
import 'package:awesome_notifications/awesome_notifications.dart' hide NotificationModel;
import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/notification_router.dart';
import '../models/notification_model.dart';

/// Top-level/static controller required by awesome_notifications
class AwesomeNotificationController {
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    developer.log(
      'AwesomeNotificationController: onActionReceivedMethod: ${receivedAction.payload}',
      name: 'AwesomeNotificationController',
    );
    final payload = receivedAction.payload;
    if (payload != null && payload.isNotEmpty) {
      AwesomeNotificationService.instance.handleTap(payload);
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    developer.log(
      'AwesomeNotificationController: onNotificationCreatedMethod: ${receivedNotification.id}',
      name: 'AwesomeNotificationController',
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    developer.log(
      'AwesomeNotificationController: onNotificationDisplayedMethod: ${receivedNotification.id}',
      name: 'AwesomeNotificationController',
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    developer.log(
      'AwesomeNotificationController: onDismissActionReceivedMethod: ${receivedAction.id}',
      name: 'AwesomeNotificationController',
    );
  }
}

/// Service managing OS-level notifications via awesome_notifications.
/// Handles channels, foreground banners, sound, permissions, and system tray tap dispatching.
class AwesomeNotificationService {
  AwesomeNotificationService._();
  static final AwesomeNotificationService instance =
      AwesomeNotificationService._();

  final AwesomeNotifications _notifications = AwesomeNotifications();

  // Channel Keys
  static const String generalChannel = 'general_channel';
  static const String jobsChannel = 'jobs_channel';
  static const String chatChannel = 'chat_channel';
  static const String dealsChannel = 'deals_channel';
  static const String communityChannel = 'community_channel';

  // Group Keys
  static const String generalGroup = 'general_group';
  static const String jobsGroup = 'jobs_group';
  static const String chatGroup = 'chat_group';
  static const String dealsGroup = 'deals_group';
  static const String communityGroup = 'community_group';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Map<String, dynamic>? _pendingPayload;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _notifications.initialize(
        'resource://mipmap/launcher_icon',
        [
          NotificationChannel(
            channelGroupKey: generalGroup,
            channelKey: generalChannel,
            channelName: 'General Notifications',
            channelDescription: 'Notifications for announcements and updates',
            defaultColor: AppColors.primaryBlue,
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            defaultPrivacy: NotificationPrivacy.Public,
            enableVibration: true,
            channelShowBadge: true,
            playSound: true,
          ),
          NotificationChannel(
            channelGroupKey: jobsGroup,
            channelKey: jobsChannel,
            channelName: 'Jobs & Applications',
            channelDescription:
                'Notifications for job posts, applications, and worker requests',
            defaultColor: AppColors.primaryBlue,
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            defaultPrivacy: NotificationPrivacy.Public,
            enableVibration: true,
            channelShowBadge: true,
            playSound: true,
          ),
          NotificationChannel(
            channelGroupKey: chatGroup,
            channelKey: chatChannel,
            channelName: 'Chat & Messages',
            channelDescription: 'Real-time messages from users',
            defaultColor: AppColors.vibrantBlue,
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            defaultPrivacy: NotificationPrivacy.Public,
            enableVibration: true,
            channelShowBadge: true,
            playSound: true,
          ),
          NotificationChannel(
            channelGroupKey: dealsGroup,
            channelKey: dealsChannel,
            channelName: 'Deals & Offers',
            channelDescription:
                'Notifications for marketplace product offers and property inquiries',
            defaultColor: AppColors.primaryBlue,
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            defaultPrivacy: NotificationPrivacy.Public,
            enableVibration: true,
            channelShowBadge: true,
            playSound: true,
          ),
          NotificationChannel(
            channelGroupKey: communityGroup,
            channelKey: communityChannel,
            channelName: 'Community Notifications',
            channelDescription:
                'Notifications for group posts, invites, and comments',
            defaultColor: AppColors.primaryBlue,
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            defaultPrivacy: NotificationPrivacy.Public,
            enableVibration: true,
            channelShowBadge: true,
            playSound: true,
          ),
        ],
        channelGroups: [
          NotificationChannelGroup(
            channelGroupKey: generalGroup,
            channelGroupName: 'General',
          ),
          NotificationChannelGroup(
            channelGroupKey: jobsGroup,
            channelGroupName: 'Jobs',
          ),
          NotificationChannelGroup(
            channelGroupKey: chatGroup,
            channelGroupName: 'Chat',
          ),
          NotificationChannelGroup(
            channelGroupKey: dealsGroup,
            channelGroupName: 'Deals',
          ),
          NotificationChannelGroup(
            channelGroupKey: communityGroup,
            channelGroupName: 'Community',
          ),
        ],
        debug: false,
      );

      // Register background & action callbacks
      await _notifications.setListeners(
        onActionReceivedMethod:
            AwesomeNotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            AwesomeNotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            AwesomeNotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            AwesomeNotificationController.onDismissActionReceivedMethod,
      );

      _isInitialized = true;
      developer.log(
        'AwesomeNotificationService initialized successfully.',
        name: 'AwesomeNotificationService',
      );
    } catch (e, stack) {
      developer.log(
        'AwesomeNotificationService initialization failed: $e',
        name: 'AwesomeNotificationService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Request runtime notification permissions (POST_NOTIFICATIONS on Android 13+)
  Future<bool> requestPermission() async {
    try {
      final isAllowed = await _notifications.isNotificationAllowed();
      if (!isAllowed) {
        return await _notifications.requestPermissionToSendNotifications();
      }
      return true;
    } catch (e) {
      developer.log(
        'Failed to request notification permission: $e',
        name: 'AwesomeNotificationService',
      );
      return false;
    }
  }

  /// Show an OS-level notification tray banner from a [NotificationModel]
  Future<bool> showNotification(NotificationModel item) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final isAllowed = await _notifications.isNotificationAllowed();
      if (!isAllowed) {
        debugPrint('[AwesomeNotificationService] Notifications are not allowed yet. Requesting permission...');
        final granted = await requestPermission();
        if (!granted) {
          debugPrint('[AwesomeNotificationService] Permission denied by user. Notification suppressed.');
          return false;
        }
      }

      final channelKey = _resolveChannelKey(item.type);
      final category = _resolveCategory(item.type);

      // Stable 32-bit positive integer ID based on item.id hashCode
      final int notifId = item.id.isNotEmpty
          ? (item.id.hashCode.abs() % 2147483647)
          : (DateTime.now().millisecondsSinceEpoch % 2147483647);

      debugPrint('[AwesomeNotificationService] Showing notification id: $notifId on channel: $channelKey: ${item.title}');

      // Construct flat String payload for awesome_notifications
      final Map<String, String> payload = {
        'id': item.id,
        'type': item.type.name,
        'title': item.title,
        'body': item.body,
        if (item.recipientId != null) 'recipientId': item.recipientId!,
        if (item.actorId != null) 'actorId': item.actorId!,
        if (item.postId != null) 'postId': item.postId!,
        if (item.commentId != null) 'commentId': item.commentId!,
        if (item.workRequestId != null) 'workRequestId': item.workRequestId!,
        if (item.jobApplicationId != null)
          'jobApplicationId': item.jobApplicationId!,
        if (item.productAdOfferId != null)
          'productAdOfferId': item.productAdOfferId!,
        if (item.groupId != null) 'groupId': item.groupId!,
        if (item.needAWorkerAppId != null)
          'needAWorkerAppId': item.needAWorkerAppId!,
        if (item.data != null) 'data_json': jsonEncode(item.data),
        if (item.actor != null) 'actor_json': jsonEncode(item.actor!.toJson()),
      };

      final bool success = await _notifications.createNotification(
        content: NotificationContent(
          id: notifId,
          channelKey: channelKey,
          title: item.title.isNotEmpty ? item.title : 'DesiLynks',
          body: item.body,
          notificationLayout: NotificationLayout.BigText,
          category: category,
          wakeUpScreen: true,
          payload: payload,
        ),
      );

      debugPrint('[AwesomeNotificationService] createNotification result: $success');
      return success;
    } catch (e, stack) {
      debugPrint('[AwesomeNotificationService] createNotification error: $e');
      developer.log(
        'Failed to display notification: $e',
        name: 'AwesomeNotificationService',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  /// Show a quick local test notification to verify UI display
  Future<bool> showTestNotification() async {
    return await showNotification(
      NotificationModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.chatMessage,
        title: 'DesiLynks Notification Test',
        body: 'Awesome Notifications is working perfectly on this device!',
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );
  }

  /// Handle tap from background/terminated/foreground OS tray
  void handleTap(Map<String, String?> rawPayload) {
    developer.log(
      'AwesomeNotificationService: handleTap called with $rawPayload',
      name: 'AwesomeNotificationService',
    );

    // Convert to Map<String, dynamic> and decode any nested json strings
    final Map<String, dynamic> payload = {};
    rawPayload.forEach((key, value) {
      if (value != null) {
        payload[key] = value;
      }
    });

    if (payload.containsKey('data_json') && payload['data_json'] is String) {
      try {
        payload['data'] = jsonDecode(payload['data_json'] as String);
      } catch (_) {}
    }
    if (payload.containsKey('actor_json') && payload['actor_json'] is String) {
      try {
        payload['actor'] = jsonDecode(payload['actor_json'] as String);
      } catch (_) {}
    }

    _pendingPayload = payload;
    _dispatchPendingTap();
  }

  void _dispatchPendingTap() {
    if (_pendingPayload == null) return;
    final context = AppRoutes.navigatorKey.currentContext;
    if (context != null) {
      final payloadToRoute = Map<String, dynamic>.from(_pendingPayload!);
      _pendingPayload = null;
      NotificationRouter.routePayload(context, payloadToRoute);
    } else {
      // Retry when navigator is mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _dispatchPendingTap();
        });
      });
    }
  }

  String _resolveChannelKey(NotificationType type) {
    switch (type) {
      case NotificationType.chatMessage:
        return chatChannel;
      case NotificationType.jobApplication:
      case NotificationType.applicationStatusUpdated:
      case NotificationType.workerHired:
      case NotificationType.needWorkerApplied:
      case NotificationType.needWorkerApplicationStatus:
        return jobsChannel;
      case NotificationType.propertyInquiry:
      case NotificationType.productOffer:
      case NotificationType.offerAccepted:
      case NotificationType.offerRejected:
        return dealsChannel;
      case NotificationType.postLiked:
      case NotificationType.postShared:
      case NotificationType.postCommented:
      case NotificationType.groupInvite:
      case NotificationType.groupJoined:
      case NotificationType.groupMemberAdded:
      case NotificationType.groupPost:
        return communityChannel;
      case NotificationType.system:
      case NotificationType.unknown:
        return generalChannel;
    }
  }

  NotificationCategory _resolveCategory(NotificationType type) {
    switch (type) {
      case NotificationType.chatMessage:
        return NotificationCategory.Message;
      case NotificationType.jobApplication:
      case NotificationType.applicationStatusUpdated:
      case NotificationType.workerHired:
      case NotificationType.needWorkerApplied:
      case NotificationType.needWorkerApplicationStatus:
        return NotificationCategory.Reminder;
      case NotificationType.propertyInquiry:
      case NotificationType.productOffer:
      case NotificationType.offerAccepted:
      case NotificationType.offerRejected:
        return NotificationCategory.Promo;
      case NotificationType.postLiked:
      case NotificationType.postShared:
      case NotificationType.postCommented:
      case NotificationType.groupInvite:
      case NotificationType.groupJoined:
      case NotificationType.groupMemberAdded:
      case NotificationType.groupPost:
        return NotificationCategory.Social;
      case NotificationType.system:
      case NotificationType.unknown:
        return NotificationCategory.Event;
    }
  }

  /// Clear all notifications from system tray
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Clear specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
