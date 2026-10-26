import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/models/community_comment_model.dart';
import 'package:desilynks/models/community_post_model.dart';
import 'package:desilynks/models/user_model.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/services/local/storage_service.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/community/my_community_posts_viewmodel.dart';
import 'package:desilynks/views/community/widgets/community_comments_sheet.dart';
import 'package:desilynks/widgets/app_feed_video_player.dart';
import 'package:desilynks/widgets/user_avatar.dart';
import 'package:desilynks/core/utils/app_share_helper.dart';

/// Responsive, Stateless "My Community Posts" view adhering to MVVM with Provider.
/// Uses exclusively SVG icons and renders attached pictures matching the community feed design.
class MyCommunityPostsView extends StatelessWidget {
  const MyCommunityPostsView({super.key});

  void _onSharePressed(
    BuildContext context,
    MyCommunityPostsViewModel vm,
    CommunityPostModel post,
  ) {
    vm.sharePost(post.id);
    AppShareHelper.shareAsLink(
      context: context,
      type: ShareItemType.community,
      id: post.id,
      title: 'Community Post',
      description: post.content,
    );
  }

  Future<void> _openCommentsSheetForComment(
    BuildContext context,
    MyCommunityPostsViewModel vm,
    CommunityCommentModel comment,
  ) async {
    final post = await vm.getOrFetchPost(comment);
    if (!context.mounted) return;
    CommunityCommentsSheet.show(context, post);
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.deleteSvg,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFEF4444),
                        BlendMode.srcIn,
                      ),
                      width: 36,
                      height: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete This Post?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                    fontFamily: AppStrings.fontInter,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'This post and its content will be permanently deleted. This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                    fontFamily: AppStrings.fontInter,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx, true),
                    icon: SvgPicture.asset(
                      AppIcons.deleteSvg,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      width: 18,
                      height: 18,
                    ),
                    label: const Text(
                      'Yes, Delete Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF374151),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onDeletePostPressed(
    BuildContext context,
    MyCommunityPostsViewModel vm,
    CommunityPostModel post,
  ) async {
    final confirm = await _showDeleteConfirmDialog(context);
    if (confirm != true || !context.mounted) return;

    final success = await vm.deletePost(post.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Post deleted successfully!'
              : (vm.errorMessage ?? 'Failed to delete post'),
        ),
        backgroundColor:
            success ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onDeleteCommentPressed(
    BuildContext context,
    MyCommunityPostsViewModel vm,
    CommunityCommentModel comment,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Comment?'),
        content: const Text(
          'Are you sure you want to delete this comment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    final success = await vm.deleteComment(comment.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Comment deleted successfully!'
              : (vm.errorMessage ?? 'Failed to delete comment'),
        ),
        backgroundColor:
            success ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final vm = context.read<MyCommunityPostsViewModel>();
      if (!vm.hasFetched && !vm.isLoading) {
        vm.fetchMyPosts();
      }
    });

    final vm = context.watch<MyCommunityPostsViewModel>();

    final isSmall = context.isSmall;
    final hPadding = isSmall ? 14.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header Bar with Back Arrow SVG & Screen Title
            _buildHeader(context, isSmall, hPadding),

            // 2. Custom Tabs Row ("Posts" | "Comments")
            _buildTabBar(context, vm, isSmall, hPadding),

            // 3. Tab Content (Posts List or Comments List)
            Expanded(
              child: vm.isLoading && !vm.hasFetched
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2563EB),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF2563EB),
                      onRefresh: () => vm.refresh(),
                      child: vm.selectedTabIndex == 0
                          ? _buildPostsList(context, vm, isSmall, hPadding)
                          : _buildCommentsList(context, vm, isSmall, hPadding),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. Header Bar: Back Arrow SVG + Title
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isSmall, double hPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 14, hPadding, 10),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.only(
                right: 14.0,
                top: 2.0,
                bottom: 2.0,
              ),
              child: SvgPicture.asset(
                AppIcons.arrowBackSvg,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate900,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'My Community Posts',
              style: TextStyle(
                fontSize: context.sp(isSmall ? 19 : 21),
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
                letterSpacing: -0.3,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Tabs Row: "Posts" | "Comments" with active indicator line
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTabBar(
    BuildContext context,
    MyCommunityPostsViewModel vm,
    bool isSmall,
    double hPadding,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Row(
            children: [
              // Posts Tab
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => vm.setTabIndex(0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Posts',
                          style: TextStyle(
                            fontSize: context.sp(isSmall ? 14 : 15),
                            fontWeight: vm.selectedTabIndex == 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: vm.selectedTabIndex == 0
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B),
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: vm.selectedTabIndex == 0
                              ? const Color(0xFF2563EB)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Comments Tab
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => vm.setTabIndex(1),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: context.sp(isSmall ? 14 : 15),
                            fontWeight: vm.selectedTabIndex == 1
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: vm.selectedTabIndex == 1
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B),
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: vm.selectedTabIndex == 1
                              ? const Color(0xFF2563EB)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Full width subtle baseline divider
        Container(
          height: 1,
          width: double.infinity,
          color: const Color(0xFFE2E8F0),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Posts List View
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPostsList(
    BuildContext context,
    MyCommunityPostsViewModel vm,
    bool isSmall,
    double hPadding,
  ) {
    if (vm.myPosts.isEmpty) {
      return _buildEmptyState(
        context: context,
        title: 'No community posts yet',
        subtitle: 'Share your questions, ideas or updates with the community.',
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
      itemCount: vm.myPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final post = vm.myPosts[index];
        return _buildPostCard(context, vm, post, isSmall);
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Single Post Card
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPostCard(
    BuildContext context,
    MyCommunityPostsViewModel vm,
    CommunityPostModel post,
    bool isSmall,
  ) {
    final hasLocation =
        post.location != null && post.location!.trim().isNotEmpty;
    final photoUrls = post.allPhotoUrls;

    // Subtitle displays author location / city with time ago (e.g. "Madrid · 7 hours ago")
    final String subtitleText =
        post.location != null && post.location!.trim().isNotEmpty
        ? '${post.location!.trim()} · ${post.timeAgo}'
        : (post.authorLocation.isNotEmpty && post.authorLocation != 'Madrid'
              ? '${post.authorLocation} · ${post.timeAgo}'
              : post.timeAgo);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header: Avatar + Name + Subtitle (Location · Time Ago) + Tag Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child:
                      post.authorAvatarUrl != null &&
                          post.authorAvatarUrl!.isNotEmpty
                      ? Image.network(
                          post.authorAvatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildAvatarFallback(),
                        )
                      : _buildAvatarFallback(),
                ),
              ),

              const SizedBox(width: 12),

              // Author Name and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 14.5 : 15.5),
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 11.5 : 12.5),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),

              // Category/Tag Pill (e.g. "General")
              if (post.tag.isNotEmpty &&
                  post.tag.toLowerCase() != 'all' &&
                  post.tag.toLowerCase() != 'none') ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.tag,
                    style: TextStyle(
                      fontSize: context.sp(isSmall ? 11 : 12),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Delete Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _onDeletePostPressed(context, vm, post),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFEE2E2),
                        width: 1,
                      ),
                    ),
                    child: SvgPicture.asset(
                      AppIcons.deleteSvg,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFEF4444),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Post Content
          if (post.content.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              post.content,
              style: TextStyle(
                fontSize: context.sp(isSmall ? 13.5 : 14.5),
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1E293B),
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ],

          // Post Video (if attached)
          if (post.hasVideo &&
              post.videoUrl != null &&
              post.videoUrl!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPostVideo(context, vm, post, isSmall),
          ],

          // Post Pictures/Media Gallery
          if (photoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPostPhotos(context, photoUrls, isSmall),
          ],

          // Optional Location Pin Row
          if (hasLocation && !subtitleText.contains(post.location!)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                SvgPicture.asset(
                  AppIcons.locationSvg,
                  width: 15,
                  height: 15,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF64748B),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    post.location!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.sp(isSmall ? 12 : 13),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Bottom Interactions: Heart (Likes), Bubble (Comments), Share (Shares)
          Row(
            children: [
              // Like Action & Count
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => vm.toggleLike(post.id),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.favSvg,
                      width: 17,
                      height: 17,
                      colorFilter: ColorFilter.mode(
                        post.isLiked
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF64748B),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 12 : 13),
                        fontWeight: FontWeight.w500,
                        color: post.isLiked
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF64748B),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 22),

              // Comment Count (tappable to open comments sheet)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => CommunityCommentsSheet.show(context, post),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.chatRoundSvg,
                      width: 17,
                      height: 17,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF64748B),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.commentsCount}',
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 12 : 13),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 22),

              // Share Action & Count
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onSharePressed(context, vm, post),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.share2Svg,
                      width: 17,
                      height: 17,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF64748B),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.sharesCount}',
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 12 : 13),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostVideo(
    BuildContext context,
    MyCommunityPostsViewModel vm,
    CommunityPostModel post,
    bool isSmall,
  ) {
    return AppFeedVideoPlayer(
      videoUrl: post.videoUrl!,
      postTimeAgo: post.timeAgo,
      authorName: post.authorName,
      postContent: post.content,
      isLiked: post.isLiked,
      onLikeToggle: () => vm.toggleLike(post.id),
      onShare: () => _onSharePressed(context, vm, post),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Photo Grid Renderers (1, 2, 3, 4+ photos)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPostPhotos(
    BuildContext context,
    List<String> photoUrls,
    bool isSmall,
  ) {
    if (photoUrls.isEmpty) return const SizedBox.shrink();
    if (photoUrls.length == 1) {
      return _buildSinglePhoto(context, photoUrls.first, photoUrls, isSmall);
    } else if (photoUrls.length == 2) {
      return _buildTwoPhotos(context, photoUrls, isSmall);
    } else if (photoUrls.length == 3) {
      return _buildThreePhotos(context, photoUrls, isSmall);
    } else {
      return _buildFourPlusPhotos(context, photoUrls, isSmall);
    }
  }

  Widget _buildSinglePhoto(
    BuildContext context,
    String url,
    List<String> allPhotos,
    bool isSmall,
  ) {
    final height = context.scaleH(210).clamp(170.0, 250.0);
    return GestureDetector(
      onTap: () => _openGalleryViewer(context, allPhotos, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: _buildPostImageWidget(context, url),
        ),
      ),
    );
  }

  Widget _buildTwoPhotos(
    BuildContext context,
    List<String> photos,
    bool isSmall,
  ) {
    final height = context.scaleH(180).clamp(150.0, 210.0);
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openGalleryViewer(context, photos, 0),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: SizedBox.expand(
                  child: _buildPostImageWidget(context, photos[0]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => _openGalleryViewer(context, photos, 1),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
                child: SizedBox.expand(
                  child: _buildPostImageWidget(context, photos[1]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreePhotos(
    BuildContext context,
    List<String> photos,
    bool isSmall,
  ) {
    final height = context.scaleH(195).clamp(165.0, 230.0);
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: () => _openGalleryViewer(context, photos, 0),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: SizedBox.expand(
                  child: _buildPostImageWidget(context, photos[0]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openGalleryViewer(context, photos, 1),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                      ),
                      child: SizedBox.expand(
                        child: _buildPostImageWidget(context, photos[1]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openGalleryViewer(context, photos, 2),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                      child: SizedBox.expand(
                        child: _buildPostImageWidget(context, photos[2]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourPlusPhotos(
    BuildContext context,
    List<String> photos,
    bool isSmall,
  ) {
    final height = context.scaleH(205).clamp(175.0, 240.0);
    final remainingCount = photos.length - 4;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openGalleryViewer(context, photos, 0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                      ),
                      child: SizedBox.expand(
                        child: _buildPostImageWidget(context, photos[0]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openGalleryViewer(context, photos, 2),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                      child: SizedBox.expand(
                        child: _buildPostImageWidget(context, photos[2]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openGalleryViewer(context, photos, 1),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                      ),
                      child: SizedBox.expand(
                        child: _buildPostImageWidget(context, photos[1]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openGalleryViewer(context, photos, 3),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildPostImageWidget(context, photos[3]),
                          if (remainingCount > 0)
                            Container(
                              color: Colors.black.withValues(alpha: 0.55),
                              alignment: Alignment.center,
                              child: Text(
                                '+$remainingCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImageWidget(BuildContext context, String path) {
    String resolvedPath = path.trim();
    if (resolvedPath.isNotEmpty && !resolvedPath.startsWith('http')) {
      final localFile = File(resolvedPath);
      if (localFile.existsSync()) {
        return Image.file(localFile, fit: BoxFit.cover);
      }
      final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final relativePath = resolvedPath.startsWith('/')
          ? resolvedPath
          : '/$resolvedPath';
      resolvedPath = '$baseUrl$relativePath';
    }

    if (resolvedPath.startsWith('http://') ||
        resolvedPath.startsWith('https://')) {
      return Image.network(
        resolvedPath,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
              ),
            ),
          );
        },
        errorBuilder: (ctx, err, stack) => Container(
          color: const Color(0xFFE2E8F0),
          child: Center(
            child: SvgPicture.asset(
              AppIcons.gallerySvg,
              colorFilter: const ColorFilter.mode(
                Color(0xFF94A3B8),
                BlendMode.srcIn,
              ),
              width: 28,
              height: 28,
            ),
          ),
        ),
      );
    } else {
      final file = File(resolvedPath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
      return Container(
        color: const Color(0xFFE2E8F0),
        child: Center(
          child: SvgPicture.asset(
            AppIcons.gallerySvg,
            colorFilter: const ColorFilter.mode(
              Color(0xFF94A3B8),
              BlendMode.srcIn,
            ),
            width: 28,
            height: 28,
          ),
        ),
      );
    }
  }

  void _openGalleryViewer(
    BuildContext context,
    List<String> photos,
    int initialIndex,
  ) {
    final pageController = PageController(initialPage: initialIndex);
    final ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(
      initialIndex,
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: photos.length,
                onPageChanged: (idx) => currentIndexNotifier.value = idx,
                itemBuilder: (context, idx) {
                  return InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 3.5,
                    child: Center(
                      child: _buildPostImageWidget(context, photos[idx]),
                    ),
                  );
                },
              ),

              // Top Bar with Close SVG and Page Indicator
              Positioned(
                top: MediaQuery.of(ctx).padding.top + 10,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          AppIcons.arrowBackSvg,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    if (photos.length > 1)
                      ValueListenableBuilder<int>(
                        valueListenable: currentIndexNotifier,
                        builder: (ctx, currentIdx, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${currentIdx + 1} / ${photos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. Comments List View (when Comments tab active)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCommentsList(
    BuildContext context,
    MyCommunityPostsViewModel vm,
    bool isSmall,
    double hPadding,
  ) {
    if (vm.myComments.isEmpty) {
      return _buildEmptyState(
        context: context,
        title: 'No comments yet',
        subtitle:
            'Engage with community discussions to see your comments here.',
      );
    }

    final authVm = context.watch<AuthViewModel>();
    UserModel? currentUser = authVm.currentUser;
    if (currentUser == null) {
      try {
        currentUser = context.read<StorageService>().getUser();
      } catch (_) {}
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
      itemCount: vm.myComments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final comment = vm.myComments[index];
        return _buildCommentCard(
          context,
          vm,
          comment,
          currentUser,
          isSmall,
        );
      },
    );
  }

  Widget _buildCommentCard(
    BuildContext context,
    MyCommunityPostsViewModel vm,
    CommunityCommentModel comment,
    UserModel? currentUser,
    bool isSmall,
  ) {
    final isMe = (currentUser != null &&
        (comment.userId == currentUser.id ||
            comment.user?.id == currentUser.id));

    final String myPostAuthorName =
        vm.myPosts.isNotEmpty ? vm.myPosts.first.authorName : '';
    final String? myPostAuthorPhoto =
        vm.myPosts.isNotEmpty ? vm.myPosts.first.authorAvatarUrl : null;

    final String authorName = (currentUser != null &&
            currentUser.fullName.trim().isNotEmpty)
        ? currentUser.fullName
        : ((comment.user != null &&
                comment.user!.fullName.trim().isNotEmpty &&
                comment.user!.fullName != 'User')
            ? comment.user!.fullName
            : (myPostAuthorName.isNotEmpty
                ? myPostAuthorName
                : (isMe ? 'You' : 'Community Member')));

    final String? authorPhotoUrl = currentUser?.profilePhotoUrl ??
        comment.user?.profilePhotoUrl ??
        myPostAuthorPhoto;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openCommentsSheetForComment(context, vm, comment),
          child: Padding(
            padding: EdgeInsets.all(isSmall ? 14 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      photoUrl: authorPhotoUrl,
                      size: 38,
                      fallbackBgColor: const Color(0xFFE0F2FE),
                      fallbackIconColor: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName,
                            style: TextStyle(
                              fontSize: context.sp(isSmall ? 14 : 15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate900,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CommunityPostModel.formatTimeAgo(comment.createdAt),
                            style: TextStyle(
                              fontSize: context.sp(isSmall ? 11.5 : 12.5),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () =>
                            _onDeleteCommentPressed(context, vm, comment),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFEE2E2),
                              width: 1,
                            ),
                          ),
                          child: SvgPicture.asset(
                            AppIcons.deleteSvg,
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFEF4444),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: context.sp(isSmall ? 13.5 : 14.5),
                    height: 1.45,
                    color: const Color(0xFF1E293B),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),

                if (comment.post != null) ...[
                  const SizedBox(height: 12),
                  _buildCommentPostBanner(context, comment, isSmall),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentPostBanner(
    BuildContext context,
    CommunityCommentModel comment,
    bool isSmall,
  ) {
    final postSummary = comment.post!;
    final postType = postSummary.type.toUpperCase();
    final authorName = postSummary.author?.fullName.trim() ?? '';
    final content = postSummary.content.trim();

    String title;
    if (content.isNotEmpty) {
      title = content;
    } else if (postType == 'PHOTO') {
      title = authorName.isNotEmpty ? '$authorName\'s Photo Post' : 'Photo Post';
    } else if (postType == 'VIDEO') {
      title = authorName.isNotEmpty ? '$authorName\'s Video Post' : 'Video Post';
    } else {
      title = authorName.isNotEmpty ? '$authorName\'s Post' : 'Community Post';
    }

    final String iconSvg;
    if (postType == 'PHOTO') {
      iconSvg = AppIcons.cameraSvg;
    } else if (postType == 'VIDEO') {
      iconSvg = AppIcons.videocamSvg;
    } else {
      iconSvg = AppIcons.chatRoundSvg;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconSvg,
                width: 15,
                height: 15,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF2563EB),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'On post',
                      style: TextStyle(
                        fontSize: context.sp(11.5),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    if (authorName.isNotEmpty) ...[
                      Text(
                        ' · $authorName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.sp(11.5),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.sp(12.5),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(
            AppIcons.arrowForwardSvg,
            width: 14,
            height: 14,
            colorFilter: const ColorFilter.mode(
              Color(0xFF94A3B8),
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: SvgPicture.asset(
        AppIcons.personSvg,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.messageSvg,
                  width: 30,
                  height: 30,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF2563EB),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: context.sp(17),
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
                fontFamily: AppStrings.fontInter,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.sp(13.5),
                color: const Color(0xFF64748B),
                height: 1.4,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
