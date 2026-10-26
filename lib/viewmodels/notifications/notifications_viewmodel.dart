import 'dart:developer' as developer;
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/api/notification_service.dart';
import '../../services/notification_socket_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationApiService _apiService;
  final NotificationSocketService _socketService;

  NotificationsViewModel({
    required NotificationApiService apiService,
    required NotificationSocketService socketService,
  }) : _apiService = apiService,
       _socketService = socketService {
    // Wire up real-time socket callbacks
    _socketService.onNewNotification = _handleNewNotification;
    _socketService.onConnected = () {
      refreshUnreadCount();
    };
    refreshUnreadCount();
  }

  // ─── Tabs ───────────────────────────────────────────────────────────────────
  final List<String> _tabs = const [
    'All',
    'Jobs',
    'Chat',
    'Deals',
    'Community',
  ];
  String _activeTab = 'All';

  List<String> get tabs => _tabs;
  String get activeTab => _activeTab;

  // ─── State ──────────────────────────────────────────────────────────────────
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _unreadCount = 0;

  // Pagination
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _isFetchingMore = false;
  bool _hasFetched = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasNextPage => _hasNextPage;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasFetched => _hasFetched;

  void ensureInitialized() {
    if (!_hasFetched && !_isLoading) {
      fetchNotifications(refresh: true);
    }
  }

  List<NotificationModel> get filteredNotifications {
    if (_activeTab == 'All') return _notifications;
    return _notifications.where((n) => n.type.category == _activeTab).toList();
  }

  // ─── Tab Control ─────────────────────────────────────────────────────────────
  void setActiveTab(String tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
  }

  // ─── Fetch Notifications ─────────────────────────────────────────────────────
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _notifications = [];
    }

    _isLoading = true;
    _hasError = false;
    _hasFetched = true;
    notifyListeners();

    try {
      final result = await _apiService.fetchNotifications(
        page: _currentPage,
        limit: 20,
      );
      final fetched = result['notifications'] as List<NotificationModel>;

      if (refresh) {
        _notifications = fetched;
      } else {
        _notifications = [..._notifications, ...fetched];
      }

      _hasNextPage = result['hasNextPage'] as bool;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      // Also sync global unread count from GET /notifications/unread-count
      _apiService.fetchUnreadCount().then((count) {
        if (count > 0 || _unreadCount == 0) {
          _unreadCount = count;
          notifyListeners();
        }
      }).catchError((_) {});
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString().replaceAll('HttpException: ', '');
      developer.log(
        'NotificationsViewModel: fetchNotifications error: $e',
        name: 'NotificationsViewModel',
        error: e,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMore() async {
    if (_isFetchingMore || !_hasNextPage) return;
    _isFetchingMore = true;
    _currentPage++;
    notifyListeners();

    try {
      final result = await _apiService.fetchNotifications(
        page: _currentPage,
        limit: 20,
      );
      final fetched = result['notifications'] as List<NotificationModel>;
      _notifications = [..._notifications, ...fetched];
      _hasNextPage = result['hasNextPage'] as bool;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      _currentPage--; // rollback on error
      developer.log(
        'NotificationsViewModel: fetchMore error: $e',
        name: 'NotificationsViewModel',
        error: e,
      );
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  // ─── Fetch Unread Count ───────────────────────────────────────────────────────
  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _apiService.fetchUnreadCount();
      notifyListeners();
    } catch (e) {
      developer.log(
        'NotificationsViewModel: refreshUnreadCount error: $e',
        name: 'NotificationsViewModel',
        error: e,
      );
    }
  }

  // ─── Mark Single as Read ──────────────────────────────────────────────────────
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    if (_notifications[index].isRead) return; // already read

    // Optimistic UI update
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    if (_unreadCount > 0) _unreadCount--;
    notifyListeners();

    // Persist to backend (best-effort, no rollback for UX)
    await _apiService.markAsRead(id);
  }

  // ─── Mark All as Read ─────────────────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    // Optimistic UI update
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _unreadCount = 0;
    notifyListeners();

    await _apiService.markAllAsRead();
  }

  // ─── Delete Notification ──────────────────────────────────────────────────────
  Future<void> deleteNotification(String id) async {
    // Find before removing to determine read state
    final NotificationModel? removed = _notifications
        .cast<NotificationModel?>()
        .firstWhere((n) => n?.id == id, orElse: () => null);

    // Optimistic UI update
    _notifications.removeWhere((n) => n.id == id);
    if (removed != null && !removed.isRead && _unreadCount > 0) {
      _unreadCount--;
    }
    notifyListeners();

    await _apiService.deleteNotification(id);
  }

  // ─── Real-time Socket Handler ─────────────────────────────────────────────────
  void _handleNewNotification(NotificationModel notification) {
    developer.log(
      'NotificationsViewModel: new real-time notification: ${notification.title}',
      name: 'NotificationsViewModel',
    );
    final existingIndex =
        _notifications.indexWhere((n) => n.id == notification.id);
    if (existingIndex != -1) {
      _notifications[existingIndex] = notification;
    } else {
      // Prepend to the top of the list
      _notifications = [notification, ..._notifications];
      if (!notification.isRead) _unreadCount++;
    }
    // Also sync the authoritative count from API
    _apiService.fetchUnreadCount().then((count) {
      _unreadCount = count;
      notifyListeners();
    }).catchError((_) {});
    notifyListeners();
  }

  // ─── Socket Connect/Disconnect ───────────────────────────────────────────────
  void connectSocket(String token) {
    _socketService.connect(token);
  }

  void disconnectSocket() {
    _socketService.disconnect();
  }

  // ─── Presentation Helpers ──────────────────────────────────────────────────
  String getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.postLiked:
        return AppIcons.favSvg;
      case NotificationType.chatMessage:
        return AppIcons.chatRoundSvg;
      case NotificationType.postShared:
        return AppIcons.share2Svg;
      case NotificationType.groupPost:
        return AppIcons.assetCommuintySvg;
      case NotificationType.groupInvite:
      case NotificationType.groupJoined:
      case NotificationType.groupMemberAdded:
        return AppIcons.assetMemberSvg;
      case NotificationType.propertyInquiry:
        return AppIcons.homeSvg;
      case NotificationType.productOffer:
      case NotificationType.offerAccepted:
      case NotificationType.offerRejected:
        return AppIcons.TagSvg;
      case NotificationType.jobApplication:
      case NotificationType.applicationStatusUpdated:
      case NotificationType.workerHired:
      case NotificationType.needWorkerApplied:
      case NotificationType.needWorkerApplicationStatus:
      case NotificationType.postCommented:
      case NotificationType.system:
      case NotificationType.unknown:
        return AppIcons.notificationSvg;
    }
  }

  Color getNotificationIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.postLiked:
        return const Color(0xFF7C3AED); // Vibrant purple matching screenshot
      case NotificationType.chatMessage:
        return AppColors.vibrantBlue;
      case NotificationType.productOffer:
      case NotificationType.offerAccepted:
      case NotificationType.offerRejected:
        return AppColors.orange;
      case NotificationType.postShared:
      case NotificationType.groupPost:
      case NotificationType.groupInvite:
      case NotificationType.groupJoined:
      case NotificationType.groupMemberAdded:
      case NotificationType.propertyInquiry:
      case NotificationType.jobApplication:
      case NotificationType.applicationStatusUpdated:
      case NotificationType.workerHired:
      case NotificationType.needWorkerApplied:
      case NotificationType.needWorkerApplicationStatus:
      case NotificationType.postCommented:
      case NotificationType.system:
      case NotificationType.unknown:
        return AppColors.slate500;
    }
  }

  Color getNotificationIconBgColor(NotificationType type) {
    switch (type) {
      case NotificationType.postLiked:
        return const Color(0xFFF3E8FF); // Soft light purple matching screenshot
      case NotificationType.chatMessage:
        return AppColors.lightBlue;
      case NotificationType.productOffer:
      case NotificationType.offerAccepted:
      case NotificationType.offerRejected:
        return AppColors.lightOrange;
      case NotificationType.postShared:
      case NotificationType.groupPost:
      case NotificationType.groupInvite:
      case NotificationType.groupJoined:
      case NotificationType.groupMemberAdded:
      case NotificationType.propertyInquiry:
      case NotificationType.jobApplication:
      case NotificationType.applicationStatusUpdated:
      case NotificationType.workerHired:
      case NotificationType.needWorkerApplied:
      case NotificationType.needWorkerApplicationStatus:
      case NotificationType.postCommented:
      case NotificationType.system:
      case NotificationType.unknown:
        return AppColors.slate100;
    }
  }

  @override
  void dispose() {
    _socketService.onNewNotification = null;
    _socketService.onConnected = null;
    super.dispose();
  }
}
