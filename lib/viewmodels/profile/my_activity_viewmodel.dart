import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import '../../models/community_post_model.dart';
import '../../models/community_comment_model.dart';
import '../../models/search_result_model.dart';
import '../../repositories/community_repository.dart';

class MyActivityItem {
  final String title;
  final String time;
  final String icon;
  final Color iconColor;
  final Color iconBgColor;
  final String category; // 'Posts', 'Comments', 'Application'
  final String? jobId;
  final String? applicationId;
  final String? postId;
  final DateTime? createdAt;

  const MyActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.category,
    this.jobId,
    this.applicationId,
    this.postId,
    this.createdAt,
  });
}

class MyActivityViewModel extends ChangeNotifier {
  final CommunityRepository? _communityRepository;

  MyActivityViewModel([this._communityRepository]);

  String _selectedTab = 'All';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<MyActivityItem> _todayActivities = [];
  List<MyActivityItem> _yesterdayActivities = [];

  String get selectedTab => _selectedTab;
  List<MyActivityItem> get todayActivities => _todayActivities;
  List<MyActivityItem> get yesterdayActivities => _yesterdayActivities;

  void setSelectedTab(String tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  List<MyActivityItem> filterActivities(List<MyActivityItem> items) {
    if (_selectedTab == 'All') {
      return items;
    }
    return items.where((item) => item.category == _selectedTab).toList();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Fetch real activities from backend
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> fetchActivities() async {
    final repo = _communityRepository;
    if (repo == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch my posts and my comments in parallel
      final results = await Future.wait([
        repo
            .getMyPosts(page: 1, limit: 20)
            .catchError((_) => _emptyPostsResponse()),
        repo
            .getMyComments(page: 1, limit: 20)
            .catchError((_) => _emptyCommentsResponse()),
      ]);

      final postsResponse = results[0] as PaginatedResponse<CommunityPostModel>;
      final commentsResponse =
          results[1] as PaginatedResponse<CommunityCommentModel>;

      // Convert posts to activity items
      final List<MyActivityItem> postActivities = postsResponse.data.map((
        post,
      ) {
        final groupName = post.group?.name;
        final title = groupName != null && groupName.isNotEmpty
            ? 'You posted in $groupName'
            : 'You created a post';
        return MyActivityItem(
          title: title,
          time: _formatTimeAgo(post.createdAt ?? DateTime.now()),
          icon: AppIcons.edit03Svg,
          iconColor: AppColors.primaryBlue,
          iconBgColor: AppColors.lightBlue,
          category: 'Posts',
          postId: post.id,
          createdAt: post.createdAt,
        );
      }).toList();

      // Convert comments to activity items
      final List<MyActivityItem> commentActivities = commentsResponse.data.map((
        comment,
      ) {
        final postContent = comment.post?.content;
        final title = postContent != null && postContent.isNotEmpty
            ? 'You commented on "${_truncate(postContent, 30)}"'
            : 'You commented on a post';
        return MyActivityItem(
          title: title,
          time: _formatTimeAgo(comment.createdAt),
          icon: AppIcons.chatRoundSvg,
          iconColor: AppColors.emerald,
          iconBgColor: AppColors.softGreen,
          category: 'Comments',
          postId: comment.postId,
          createdAt: comment.createdAt,
        );
      }).toList();

      // Merge all activities and sort by date (newest first)
      final allActivities = [...postActivities, ...commentActivities];
      allActivities.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      // Split into today and yesterday
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));

      _todayActivities = allActivities
          .where((a) => a.createdAt != null && a.createdAt!.isAfter(todayStart))
          .toList();

      _yesterdayActivities = allActivities
          .where(
            (a) =>
                a.createdAt != null &&
                a.createdAt!.isAfter(yesterdayStart) &&
                a.createdAt!.isBefore(todayStart),
          )
          .toList();

      // Activities older than yesterday are also added to yesterday for display
      final olderActivities = allActivities
          .where(
            (a) => a.createdAt != null && a.createdAt!.isBefore(yesterdayStart),
          )
          .toList();
      if (olderActivities.isNotEmpty) {
        _yesterdayActivities.addAll(olderActivities);
      }

      _hasFetched = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────
  String _formatTimeAgo(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inHours < 24) {
      if (difference.inHours < 1) {
        final mins = difference.inMinutes.clamp(1, 60);
        return '$mins mins ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  PaginatedResponse<CommunityPostModel> _emptyPostsResponse() {
    return PaginatedResponse<CommunityPostModel>(
      data: [],
      meta: SearchMeta(total: 0, page: 1, limit: 20, totalPages: 0),
    );
  }

  PaginatedResponse<CommunityCommentModel> _emptyCommentsResponse() {
    return PaginatedResponse<CommunityCommentModel>(
      data: [],
      meta: SearchMeta(total: 0, page: 1, limit: 20, totalPages: 0),
    );
  }
}
