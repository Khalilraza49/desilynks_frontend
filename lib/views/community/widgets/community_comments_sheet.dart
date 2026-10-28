import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../models/community_comment_model.dart';
import '../../../models/community_enums.dart';
import '../../../models/community_post_model.dart';
import '../../../viewmodels/auth/auth_viewmodel.dart';
import '../../../viewmodels/community/community_viewmodel.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/user_avatar.dart';
import '../../../models/moderation_models.dart';
import '../../../widgets/report_bottom_sheet.dart';

/// Reusable Community Comments Bottom Sheet with MVVM Provider binding.
/// Supports viewing comments, replying, optimistic updates, and keyboard avoidance.
class CommunityCommentsSheet extends StatelessWidget {
  final CommunityPostModel post;

  const CommunityCommentsSheet({
    super.key,
    required this.post,
  });

  /// Static helper to display the sheet from any view.
  static void show(BuildContext context, CommunityPostModel post) {
    final viewModel = context.read<CommunityViewModel>();
    viewModel.loadCommentsForPost(post.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.scale(20)),
        ),
      ),
      builder: (ctx) {
        return CommunityCommentsSheet(post: post);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final currentUser = authViewModel.currentUser;
    final comments = viewModel.activeComments;
    final replyingTo = viewModel.replyingToComment;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final totalReplies = comments.fold<int>(
      0,
      (sum, c) {
        final localReplies = viewModel.repliesMap[c.id]?.length ?? 0;
        final count = localReplies > c.repliesCount ? localReplies : c.repliesCount;
        return sum + count;
      },
    );
    final totalComments = comments.length + totalReplies;
    final commentCount = totalComments > post.commentsCount
        ? totalComments
        : post.commentsCount;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                    top: context.scaleH(10),
                    bottom: context.scaleH(10),
                  ),
                  width: context.scale(38),
                  height: context.scaleH(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(context.scale(2)),
                  ),
                ),
              ),

              // Header Bar
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(16),
                  vertical: context.scaleH(4),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.chatRoundSvg,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF8B9CB2),
                        BlendMode.srcIn,
                      ),
                      width: context.scale(22),
                      height: context.scale(22),
                    ),
                    SizedBox(width: context.scale(10)),
                    Text(
                      'Comments ($commentCount)',
                      style: TextStyle(
                        fontSize: context.sp(17.5),
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(context.scale(4)),
                        child: SvgPicture.asset(
                          AppIcons.crossSmallSvg,
                          height: context.scale(20),
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate700,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Post summary banner (if post has content or author)
              if (post.content.trim().isNotEmpty ||
                  post.authorName.isNotEmpty) ...[
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: context.scale(16),
                    vertical: context.scaleH(6),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(12),
                    vertical: context.scaleH(8),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(context.scale(10)),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      UserAvatar(
                        photoUrl: post.authorAvatarUrl,
                        size: context.scale(28),
                        fallbackBgColor: const Color(0xFFE0F2FE),
                        fallbackIconColor: AppColors.primaryBlue,
                      ),
                      SizedBox(width: context.scale(8)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: TextStyle(
                                fontSize: context.sp(12),
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                            Text(
                              post.content.trim().isNotEmpty
                                  ? post.content.trim()
                                  : (post.type == CommunityPostType.PHOTO
                                      ? 'Photo Post'
                                      : (post.type == CommunityPostType.VIDEO
                                          ? 'Video Post'
                                          : 'Community Post')),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: context.sp(11.5),
                                color: AppColors.slate600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Comments List
              Expanded(
                child: viewModel.isLoadingComments
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF4353E8),
                        ),
                      )
                    : comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.chatRoundSvg,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate400,
                                BlendMode.srcIn,
                              ),
                              width: context.scale(40),
                              height: context.scale(40),
                            ),
                            SizedBox(height: context.scaleH(8)),
                            Text(
                              'No comments yet. Be the first to comment!',
                              style: TextStyle(
                                color: AppColors.slate500,
                                fontSize: context.sp(13),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scale(16),
                          vertical: context.scaleH(12),
                        ),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final isReply = comment.isReply;

                          final isMe = (currentUser != null &&
                              (comment.userId == currentUser.id ||
                                  comment.user?.id == currentUser.id));

                          final String? photoUrl = comment.user?.profilePhotoUrl ??
                              (isMe ? currentUser.profilePhotoUrl : null);

                          final String authorName = comment.user?.fullName.isNotEmpty == true
                              ? comment.user!.fullName
                              : (isMe
                                  ? (currentUser.fullName.isNotEmpty
                                      ? currentUser.fullName
                                      : 'You')
                                  : 'User');

                          return Padding(
                            padding: EdgeInsets.only(
                              left: isReply ? context.scale(44) : 0.0,
                              bottom: context.scaleH(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UserAvatar(
                                  photoUrl: photoUrl,
                                  size: isReply
                                      ? context.scale(32)
                                      : context.scale(38),
                                  fallbackBgColor: AppColors.lightBlue,
                                  fallbackIconColor: AppColors.primaryBlue,
                                ),
                                SizedBox(width: context.scale(10)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            authorName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: isReply
                                                  ? context.sp(13.5)
                                                  : context.sp(14),
                                              color: AppColors.slate900,
                                            ),
                                          ),
                                          SizedBox(width: context.scale(8)),
                                          Text(
                                            CommunityPostModel.formatTimeAgo(
                                              comment.createdAt,
                                            ),
                                            style: TextStyle(
                                              fontSize: isReply
                                                  ? context.sp(11.5)
                                                  : context.sp(12),
                                              color: const Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (isMe)
                                            GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () => _confirmDeleteComment(
                                                context,
                                                viewModel,
                                                comment,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: context.scale(4),
                                                ),
                                                child: SvgPicture.asset(
                                                  AppIcons.deleteSvg,
                                                  width: context.scale(14),
                                                  height: context.scale(14),
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                    Color(0xFFEF4444),
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (!isMe)
                                            GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                ReportBottomSheet.show(
                                                  context,
                                                  targetType: ReportTargetType.communityComment,
                                                  targetId: comment.id,
                                                  targetOwnerId: comment.userId,
                                                  targetTitle: 'Report Comment',
                                                );
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: context.scale(4),
                                                ),
                                                child: Icon(
                                                  Icons.flag_outlined,
                                                  size: context.scale(14),
                                                  color: AppColors.slate400,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: context.scaleH(6)),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: context.scale(16),
                                          vertical: context.scaleH(12),
                                        ),
                                        decoration: BoxDecoration(
                                          color: isReply
                                              ? const Color(0xFFF1F5F9)
                                              : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            context.scale(16),
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Text(
                                          comment.content,
                                          style: TextStyle(
                                            fontSize: isReply
                                                ? context.sp(13)
                                                : context.sp(13.5),
                                            color: AppColors.slate800,
                                            height: 1.38,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: context.scaleH(6),
                                          left: context.scale(4),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () =>
                                                  viewModel.setReplyingTo(comment),
                                              child: Text(
                                                'Reply',
                                                style: TextStyle(
                                                  fontSize: context.sp(12.5),
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF4353E8),
                                                ),
                                              ),
                                            ),
                                            if (comment.repliesCount > 0 ||
                                                viewModel.getRepliesFor(comment.id).isNotEmpty) ...[
                                              SizedBox(width: context.scale(14)),
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onTap: () => viewModel.toggleReplies(
                                                  post.id,
                                                  comment.id,
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (viewModel.isLoadingReplies(comment.id)) ...[
                                                      SizedBox(
                                                        width: context.scale(12),
                                                        height: context.scale(12),
                                                        child: const CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Color(0xFF4353E8),
                                                        ),
                                                      ),
                                                      SizedBox(width: context.scale(6)),
                                                    ],
                                                    Text(
                                                      viewModel.isRepliesExpanded(comment.id)
                                                          ? 'Hide replies'
                                                          : '${comment.repliesCount > 0 ? comment.repliesCount : viewModel.getRepliesFor(comment.id).length} ${((comment.repliesCount > 0 ? comment.repliesCount : viewModel.getRepliesFor(comment.id).length) == 1) ? "reply" : "replies"}',
                                                      style: TextStyle(
                                                        fontSize: context.sp(11.5),
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFF4353E8),
                                                      ),
                                                    ),
                                                    SizedBox(width: context.scale(2)),
                                                    Icon(
                                                      viewModel.isRepliesExpanded(comment.id)
                                                          ? Icons.keyboard_arrow_up
                                                          : Icons.keyboard_arrow_down,
                                                      size: context.scale(16),
                                                      color: const Color(0xFF4353E8),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (viewModel.isRepliesExpanded(comment.id)) ...[
                                        SizedBox(height: context.scaleH(8)),
                                        ...viewModel
                                            .getRepliesFor(comment.id)
                                            .map((reply) => _buildReplyItem(
                                                  context: context,
                                                  viewModel: viewModel,
                                                  currentUser: currentUser,
                                                  parentComment: comment,
                                                  reply: reply,
                                                )),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Replying banner
              if (replyingTo != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(16),
                    vertical: context.scaleH(8),
                  ),
                  color: const Color(0xFFEEF2FF),
                  child: Row(
                    children: [
                      Text(
                        'Replying to ${replyingTo.user?.fullName ?? "comment"}',
                        style: TextStyle(
                          fontSize: context.sp(12.5),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4353E8),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => viewModel.clearReplyingTo(),
                        child: SvgPicture.asset(
                          AppIcons.crossSmallSvg,
                          height: context.scale(18),
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate700,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // Bottom Input Bar
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(16),
                  vertical: context.scaleH(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: viewModel.commentInputController,
                        hintText: replyingTo != null
                            ? 'Replying to ${replyingTo.user?.fullName ?? "comment"}...'
                            : 'Write a comment...',
                        fontSize: context.sp(14),
                        borderRadius: BorderRadius.circular(context.scale(14)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.scale(14),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.scale(14),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.scale(14),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scale(16),
                          vertical: context.scaleH(12),
                        ),
                        textInputAction: TextInputAction.send,
                        onFieldSubmitted: (_) => viewModel.submitActiveComment(
                          postId: post.id,
                          currentUser: currentUser,
                        ),
                      ),
                    ),
                    SizedBox(width: context.scale(10)),
                    GestureDetector(
                      onTap: () => viewModel.submitActiveComment(
                        postId: post.id,
                        currentUser: currentUser,
                      ),
                      child: Container(
                        width: context.scale(46),
                        height: context.scale(46),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4353E8),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.send2,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                            width: context.scale(22),
                            height: context.scale(22),
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
      },
    );
  }

  Future<void> _confirmDeleteComment(
    BuildContext context,
    CommunityViewModel viewModel,
    CommunityCommentModel comment, {
    String? parentId,
  }) async {
    final confirmed = await showDialog<bool>(
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
    if (confirmed == true && context.mounted) {
      await viewModel.deleteActiveComment(
        comment.id,
        postId: post.id,
        parentId: parentId,
      );
    }
  }

  Widget _buildReplyItem({
    required BuildContext context,
    required CommunityViewModel viewModel,
    required dynamic currentUser,
    required CommunityCommentModel parentComment,
    required CommunityCommentModel reply,
  }) {
    final isMe = (currentUser != null &&
        (reply.userId == currentUser.id || reply.user?.id == currentUser.id));

    final String? photoUrl =
        reply.user?.profilePhotoUrl ?? (isMe ? currentUser?.profilePhotoUrl : null);

    final String authorName = reply.user?.fullName.isNotEmpty == true
        ? reply.user!.fullName
        : (isMe
            ? (currentUser != null && currentUser.fullName.isNotEmpty
                ? currentUser.fullName
                : 'You')
            : 'User');

    return Padding(
      padding: EdgeInsets.only(
        top: context.scaleH(8),
        bottom: context.scaleH(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            photoUrl: photoUrl,
            size: context.scale(28),
            fallbackBgColor: AppColors.lightBlue,
            fallbackIconColor: AppColors.primaryBlue,
          ),
          SizedBox(width: context.scale(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      authorName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: context.sp(13),
                        color: AppColors.slate900,
                      ),
                    ),
                    SizedBox(width: context.scale(6)),
                    Text(
                      CommunityPostModel.formatTimeAgo(reply.createdAt),
                      style: TextStyle(
                        fontSize: context.sp(11),
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const Spacer(),
                    if (isMe)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _confirmDeleteComment(
                          context,
                          viewModel,
                          reply,
                          parentId: parentComment.id,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scale(4),
                          ),
                          child: SvgPicture.asset(
                            AppIcons.deleteSvg,
                            width: context.scale(13),
                            height: context.scale(13),
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFEF4444),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    if (!isMe)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          ReportBottomSheet.show(
                            context,
                            targetType: ReportTargetType.communityComment,
                            targetId: reply.id,
                            targetOwnerId: reply.userId,
                            targetTitle: 'Report Comment',
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scale(4),
                          ),
                          child: Icon(
                            Icons.flag_outlined,
                            size: context.scale(13),
                            color: AppColors.slate400,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: context.scaleH(4)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(14),
                    vertical: context.scaleH(10),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(context.scale(14)),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    reply.content,
                    style: TextStyle(
                      fontSize: context.sp(13),
                      color: AppColors.slate800,
                      height: 1.35,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: context.scaleH(4),
                    left: context.scale(4),
                  ),
                  child: GestureDetector(
                    onTap: () => viewModel.setReplyingTo(reply),
                    child: Text(
                      'Reply',
                      style: TextStyle(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4353E8),
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
}
