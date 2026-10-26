import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/utils/image_utils.dart';
import 'package:desilynks/app/routes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/models/community_post_model.dart';
import 'package:desilynks/viewmodels/community/community_viewmodel.dart';
import 'package:desilynks/viewmodels/community/group_members_viewmodel.dart';
import 'package:desilynks/widgets/user_avatar.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class GroupDetailView extends StatelessWidget {
  final Map<String, dynamic>? group;

  const GroupDetailView({super.key, this.group});

  String _extractGroupId(Map<String, dynamic>? data) {
    return data?['id'] as String? ??
        data?['groupId'] as String? ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    final communityVM = context.watch<CommunityViewModel>();
    final vm = context.watch<GroupMembersViewModel>();

    final initialGroupId = _extractGroupId(group);

    // MVVM post frame callback to fetch membership and group details/posts
    if (initialGroupId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        communityVM.ensureGroupDetailInitialized(
          initialGroupId,
          initialGroup: group,
        );
        vm.fetchMyMembership(initialGroupId);
      });
    }

    final Map<String, dynamic>? activeGroup =
        (communityVM.activeGroupId == initialGroupId &&
                communityVM.currentGroupDetails != null)
            ? communityVM.currentGroupDetails
            : group;

    final String groupId = _extractGroupId(activeGroup).isNotEmpty
        ? _extractGroupId(activeGroup)
        : initialGroupId;

    final List<CommunityPostModel> groupPosts =
        (communityVM.activeGroupId == initialGroupId)
            ? communityVM.currentGroupPosts
            : const [];

    final bool isLoadingPosts =
        (communityVM.activeGroupId == initialGroupId) &&
            communityVM.isLoadingGroupPosts;

    final String title =
        (activeGroup?['title'] as String?) ??
        (activeGroup?['name'] as String?) ??
        'Community Group';
    final String members =
        (activeGroup?['members'] as String?) ??
        (activeGroup?['memberCount'] != null
            ? '${activeGroup!['memberCount']} members'
            : 'Members');
    final String coverImageUrl = ImageUtils.resolveGroupCoverUrl(activeGroup);
    final String description =
        (activeGroup?['description'] as String?)?.isNotEmpty == true
            ? activeGroup!['description'] as String
            : 'Welcome to the $title group. Share updates, help each other and stay connected.';

    final bool isJoined = groupId.isNotEmpty
        ? vm.isCurrentUserJoined
        : vm.fallbackIsGroupJoined;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        floatingActionButton: isJoined
            ? FloatingActionButton.extended(
                onPressed: () async {
                  final String groupTitle = (activeGroup?['title'] as String?) ??
                      (activeGroup?['name'] as String?) ??
                      'Group';
                  await Navigator.pushNamed(
                    context,
                    AppRoutes.postCommunity,
                    arguments: {
                      'initialGroupId': groupId,
                      'initialGroupName': groupTitle,
                    },
                  );
                  if (context.mounted && groupId.isNotEmpty) {
                    context.read<CommunityViewModel>().loadActiveGroupPosts(groupId);
                  }
                },
                backgroundColor: AppColors.vibrantBlue,
                icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                label: const Text(
                  'Post in Group',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: AppColors.vibrantBlue,
            onRefresh: () async {
              if (groupId.isNotEmpty) {
                await Future.wait([
                  context.read<GroupMembersViewModel>().fetchMyMembership(
                    groupId,
                    force: true,
                  ),
                  context.read<CommunityViewModel>().refreshActiveGroup(groupId),
                ]);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.padding20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              AppIcons.arrowBackSvg,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate800,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Share Button
                        GestureDetector(
                          onTap: () => _shareGroup(context, groupId, activeGroup),
                          child: Container(
                            width: 36,
                            height: 36,
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              AppIcons.shareSvg,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate800,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 1. Cover Image Banner with Top Navigation Overlay
                  Stack(
                    children: [
                      // Banner Image
                      Container(
                        height: 200,
                        width: double.infinity,
                        color:
                            activeGroup?['bgColor'] as Color? ??
                            AppColors.vibrantBlue,
                        child: coverImageUrl.isNotEmpty
                            ? Image.network(
                                coverImageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: SvgPicture.asset(
                                    AppIcons.assetCommuintySvg,
                                    height: 56,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: SvgPicture.asset(
                                  AppIcons.assetCommuintySvg,
                                  height: 56,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                      ),

                      // Gradient overlay for better icon visibility
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // Bottom Right Group Info Pill Badge
                      Positioned(
                        bottom: 12,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Public Group · ${members.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. Group Header Details Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Description Subtitle
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.slate500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Buttons Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              // Joined Button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (groupId.isNotEmpty) {
                                    if (isJoined) {
                                      await vm.leaveGroup(groupId);
                                      if (context.mounted) {
                                        context
                                            .read<CommunityViewModel>()
                                            .fetchMyGroups(force: true);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('You left the group'),
                                            backgroundColor: AppColors.slate700,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } else {
                                      await vm.joinGroup(groupId);
                                      if (context.mounted) {
                                        context
                                            .read<CommunityViewModel>()
                                            .fetchMyGroups(force: true);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('You joined the group successfully!'),
                                            backgroundColor: AppColors.vibrantBlue,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    vm.toggleFallbackGroupJoined();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isJoined
                                      ? AppColors.vibrantBlue
                                      : const Color(0xFFF1F5F9),
                                  foregroundColor: isJoined
                                      ? Colors.white
                                      : AppColors.slate800,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 9,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: SvgPicture.asset(
                                  AppIcons.assetTickSvg,
                                  height: 12,
                                  width: 12,
                                  colorFilter: ColorFilter.mode(
                                    isJoined
                                        ? Colors.white
                                        : AppColors.slate800,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: Text(
                                  isJoined ? 'Joined' : 'Join',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Members Button
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.groupMembers,
                                    arguments: activeGroup,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  foregroundColor: AppColors.slate800,
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: SvgPicture.asset(
                                  AppIcons.assetMemberSvg,
                                  height: 16,
                                  width: 16,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.slate800,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: const Text(
                                  'Members',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppColors.slate800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Add Members Button
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.addMembers,
                                    arguments: activeGroup,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  foregroundColor: AppColors.slate800,
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.person_add_alt_1_outlined,
                                  size: 16,
                                  color: AppColors.slate800,
                                ),
                                label: const Text(
                                  'Add Member',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppColors.slate800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Share Button
                              OutlinedButton.icon(
                                onPressed: () => _shareGroup(context, groupId, activeGroup),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  foregroundColor: AppColors.slate800,
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: SvgPicture.asset(
                                  AppIcons.shareSvg,
                                  height: 16,
                                  width: 16,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.slate700,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: const Text(
                                  'Share',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppColors.slate800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // More Button
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showGroupOptionsSheet(
                                    context,
                                    vm,
                                    isJoined,
                                    groupId,
                                    activeGroup,
                                  ),
                                  icon: SvgPicture.asset(
                                    AppIcons.assetvertiMoreSvg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (activeGroup?['createdAt'] != null) ...[
                          Text(
                            'Created on ${activeGroup!['createdAt']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.slate500,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        const Text(
                          'Public Group',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Anyone can see members and posts',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Tab Bar (About, Discussion, Media, Events)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: AppColors.vibrantBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.slate600,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'About'),
                        Tab(text: 'Discussion'),
                        Tab(text: 'Media'),
                        Tab(text: 'Events'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Tab Body Content
                  SizedBox(
                    height: 350,
                    child: TabBarView(
                      children: [
                        // Tab 1: About
                        _buildAboutTabContent(activeGroup, title, description, members),

                        // Tab 2: Discussion
                        _buildDiscussionTabContent(context, groupId, activeGroup, groupPosts, isLoadingPosts),

                        // Tab 3: Media
                        _buildMediaTabContent(context, groupPosts),

                        // Tab 4: Events
                        _buildEventsTabContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTabContent(
    Map<String, dynamic>? activeGroup,
    String title,
    String description,
    String members,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Card 1: About Description Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.slate600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Card 2: Group Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeGroup?['createdAt'] != null) ...[
                  Text(
                    'Created on ${activeGroup!['createdAt']}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                const Text(
                  'Public Group',
                  style: TextStyle(fontSize: 13, color: AppColors.slate600),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Anyone can see members and posts',
                  style: TextStyle(fontSize: 13, color: AppColors.slate600),
                ),
                const SizedBox(height: 10),
                Text(
                  members,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionTabContent(
    BuildContext context,
    String groupId,
    Map<String, dynamic>? activeGroup,
    List<CommunityPostModel> groupPosts,
    bool isLoadingPosts,
  ) {
    if (isLoadingPosts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.vibrantBlue),
        ),
      );
    }

    if (groupPosts.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Discussions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No posts yet. Be the first to start a conversation in this group!',
                style: TextStyle(fontSize: 13, color: AppColors.slate500),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final String groupTitle = (activeGroup?['title'] as String?) ??
                      (activeGroup?['name'] as String?) ??
                      'Group';
                  await Navigator.pushNamed(
                    context,
                    AppRoutes.postCommunity,
                    arguments: {
                      'initialGroupId': groupId,
                      'initialGroupName': groupTitle,
                    },
                  );
                  if (context.mounted && groupId.isNotEmpty) {
                    context.read<CommunityViewModel>().loadActiveGroupPosts(groupId);
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Post in Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vibrantBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groupPosts.length,
      itemBuilder: (context, index) {
        final post = groupPosts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(
                    photoUrl: post.authorAvatarUrl,
                    size: 36,
                    fallbackBgColor: AppColors.lightBlue,
                    fallbackIconColor: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: AppColors.slate800,
                          ),
                        ),
                        Text(
                          post.timeAgo,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (post.content.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  post.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.slate700,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.favSvg,
                    height: 15,
                    colorFilter: ColorFilter.mode(
                      post.isLiked ? AppColors.primaryRed : AppColors.slate500,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likesCount}',
                    style: const TextStyle(fontSize: 12, color: AppColors.slate600),
                  ),
                  const SizedBox(width: 16),
                  SvgPicture.asset(
                    AppIcons.chatRoundSvg,
                    height: 15,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate500,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentsCount}',
                    style: const TextStyle(fontSize: 12, color: AppColors.slate600),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaTabContent(
    BuildContext context,
    List<CommunityPostModel> groupPosts,
  ) {
    final mediaUrls = <String>[];
    for (final post in groupPosts) {
      mediaUrls.addAll(post.allPhotoUrls);
      if (post.videoUrl != null && post.videoUrl!.isNotEmpty) {
        mediaUrls.add(post.videoUrl!);
      }
    }

    if (mediaUrls.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No photos or videos shared yet.',
            style: TextStyle(color: AppColors.slate500, fontSize: 13),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isTablet ? 5 : (context.isSmall ? 2 : 3),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: mediaUrls.length,
      itemBuilder: (context, index) {
        final url = mediaUrls[index];
        final isVideo = url.endsWith('.mp4');
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.slate200,
                  child: const Icon(Icons.broken_image, color: AppColors.slate400),
                ),
              ),
              if (isVideo)
                Container(
                  color: Colors.black38,
                  child: const Center(
                    child: Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventsTabContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'No upcoming group events.',
          style: TextStyle(color: AppColors.slate500, fontSize: 13),
        ),
      ),
    );
  }

  void _showGroupOptionsSheet(
    BuildContext context,
    GroupMembersViewModel vm,
    bool isJoined,
    String groupId,
    Map<String, dynamic>? activeGroup,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: SvgPicture.asset(
                    AppIcons.assetMemberSvg,
                    height: 20,
                    width: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate800,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: const Text('View Group Members'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.groupMembers,
                      arguments: activeGroup,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person_add_alt_1_outlined,
                    color: AppColors.slate800,
                    size: 20,
                  ),
                  title: const Text('Add / Invite Members'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addMembers,
                      arguments: activeGroup,
                    );
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    AppIcons.shareSvg,
                    height: 20,
                    width: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate800,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: const Text('Share Group'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _shareGroup(context, groupId, activeGroup);
                  },
                ),
                if (isJoined)
                  ListTile(
                    leading: SvgPicture.asset(
                      AppIcons.logoutSvg,
                      height: 20,
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.red,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: const Text(
                      'Leave Group',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      if (groupId.isNotEmpty) {
                        await vm.leaveGroup(groupId);
                        if (context.mounted) {
                          context
                              .read<CommunityViewModel>()
                              .fetchMyGroups(force: true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You left the group'),
                              backgroundColor: AppColors.slate700,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        vm.setFallbackGroupJoined(false);
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareGroup(
    BuildContext context,
    String groupId,
    Map<String, dynamic>? activeGroup,
  ) {
    final String groupName =
        (activeGroup?['title'] as String?) ??
        (activeGroup?['name'] as String?) ??
        'Community Group';
    final String shareText =
        'Join the "$groupName" community on Desi Connect: https://desiconnect.com/group/$groupId';

    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group link for "$groupName" copied to clipboard!'),
        backgroundColor: AppColors.vibrantBlue,
        duration: const Duration(seconds: 2),
      ),
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Share "$groupName"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          shareText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.slate600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.vibrantBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Copied',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Group link for "$groupName" copied to clipboard!',
                        ),
                        backgroundColor: AppColors.vibrantBlue,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: SvgPicture.asset(
                    AppIcons.assetTickSvg,
                    height: 14,
                    width: 14,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: const Text('Link Copied to Clipboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
}
