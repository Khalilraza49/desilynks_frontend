import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/models/community_post_model.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/community/community_viewmodel.dart';
import 'package:desilynks/viewmodels/notifications/notifications_viewmodel.dart';
import 'package:desilynks/widgets/user_avatar.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';
import 'package:desilynks/widgets/app_feed_video_player.dart';
import 'widgets/community_comments_sheet.dart';
import 'package:desilynks/models/moderation_models.dart';
import 'package:desilynks/widgets/report_bottom_sheet.dart';
import 'package:desilynks/core/utils/app_share_helper.dart';

class CommunityView extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const CommunityView({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityViewModel>();
    viewModel.initCommunityFeed();
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;
    final posts = viewModel.filteredPosts;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: (viewModel.isLoading && posts.isEmpty)
            ? const CommunitySkeleton()
            : RefreshIndicator(
                color: AppColors.vibrantBlue,
                onRefresh: () =>
                    context.read<CommunityViewModel>().fetchFeed(page: 1),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.hMargin,
                        vertical: context.scaleH(AppConstants.paddingMedium),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header Section
                          _buildHeader(context),
                          SizedBox(
                            height: context.scaleH(AppConstants.paddingLarge),
                          ),

                          // 2. Filter Pills
                          _buildFilterPills(viewModel, context),
                          SizedBox(
                            height: context.scaleH(AppConstants.padding20),
                          ),

                          // 3. Post Creation Trigger Card ("What's on your mind?")
                          _buildCreatePostCard(context, user),
                          SizedBox(
                            height: context.scaleH(AppConstants.padding20),
                          ),

                          // 4. Groups Section (displays "No Group Available" if empty)
                          _buildGroupsSection(viewModel.groups, context),
                          SizedBox(
                            height: context.scaleH(AppConstants.padding20),
                          ),

                          // 5. Community Spotlight Section (displays "No Spotlight available" if empty)
                          _buildSpotlightSection(
                            viewModel.spotlightMembers,
                            context,
                          ),
                          SizedBox(
                            height: context.scaleH(AppConstants.padding20),
                          ),

                          // 6. Dynamic Feed Posts List
                          if (posts.isEmpty)
                            _buildEmptyState(context)
                          else
                            ...posts.map(
                              (post) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: context.scaleH(
                                    AppConstants.paddingLarge,
                                  ),
                                ),
                                child: _buildPostCard(context, post, viewModel),
                              ),
                            ),

                          SizedBox(
                            height: context.scaleH(
                              AppConstants.paddingExtraLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: context.scale(36),
          height: context.scale(36),
          decoration: BoxDecoration(
            color: const Color(0xFF5B4DFF),
            borderRadius: BorderRadius.circular(
              context.scale(AppConstants.borderRadius10),
            ),
          ),
          child: Center(
            child: SvgPicture.asset(
              AppIcons.assetCommuintySvg,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
              height: context.scaleH(20).clamp(15.0, 20.0),
            ),
          ),
        ),
        SizedBox(width: context.scale(AppConstants.padding10)),
        Text(
          'Community',
          style: TextStyle(
            fontSize: context.sp(AppConstants.fontSizeTitle),
            fontWeight: FontWeight.bold,
            color: AppColors.slate800,
          ),
        ),
        const Spacer(),

        IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: AppColors.slate100,
            padding: EdgeInsets.all(context.scale(AppConstants.paddingSmall)),
            minimumSize: Size(context.scale(38), context.scale(38)),
          ),
          icon: SvgPicture.asset(
            AppIcons.searchSvg,
            height: context.scale(AppConstants.iconSize),
            width: context.scale(AppConstants.iconSize),
            colorFilter: const ColorFilter.mode(
              AppColors.slate700,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: context.scale(AppConstants.paddingSmall)),

        Consumer<NotificationsViewModel>(
          builder: (context, notifVm, _) {
            final count = notifVm.unreadCount;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.slate100,
                    padding: EdgeInsets.all(
                      context.scale(AppConstants.paddingSmall),
                    ),
                    minimumSize: Size(context.scale(38), context.scale(38)),
                  ),
                  icon: SvgPicture.asset(
                    AppIcons.notificationSvg,
                    height: context.scale(AppConstants.iconSize),
                    width: context.scale(AppConstants.iconSize),
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate700,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: context.scaleH(3),
                    right: context.scale(3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(width: context.scale(AppConstants.paddingSmall)),

        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.postCommunity);
          },
          child: Container(
            width: context.scale(36),
            height: context.scale(36),
            padding: EdgeInsets.all(context.scale(8)),
            decoration: const BoxDecoration(
              color: AppColors.vibrantBlue,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppIcons.plusSvg,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPills(CommunityViewModel viewModel, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: viewModel.filterOptions.map((opt) {
          final isSelected = viewModel.selectedFilter == opt.label;
          return Padding(
            padding: EdgeInsets.only(
              right: context.scale(AppConstants.paddingSmall),
            ),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(
                opt.icon.isNotEmpty ? '${opt.icon} ${opt.label}' : opt.label,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.slate700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: context.sp(AppConstants.fontSizeMD),
                ),
              ),
              selected: isSelected,
              onSelected: (val) {
                if (val) viewModel.selectFilter(opt.label);
              },
              backgroundColor: AppColors.white,
              selectedColor: AppColors.vibrantBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  context.scale(AppConstants.padding20),
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.vibrantBlue
                      : AppColors.slate200,
                  width: AppConstants.borderWidth,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: context.scale(AppConstants.paddingStandard),
                vertical: context.scaleH(AppConstants.paddingSmall),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCreatePostCard(BuildContext context, dynamic user) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.postCommunity);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(context.scale(AppConstants.paddingMedium)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            context.scale(AppConstants.borderRadius16),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackOpacity4,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            UserAvatar(
              photoUrl: user?.profilePhotoUrl,
              size: context.scale(40),
              fallbackBgColor: AppColors.lightBlue,
              fallbackIconColor: AppColors.primaryBlue,
            ),
            SizedBox(width: context.scale(AppConstants.paddingMedium)),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(AppConstants.paddingStandard),
                  vertical: context.scaleH(AppConstants.padding10),
                ),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(
                    context.scale(AppConstants.paddingExtraLarge),
                  ),
                ),
                child: Text(
                  "What's on your mind?",
                  style: TextStyle(
                    color: AppColors.slate400,
                    fontSize: context.sp(AppConstants.fontSizeMD),
                  ),
                ),
              ),
            ),
            SizedBox(width: context.scale(AppConstants.padding10)),
            Container(
              width: context.scale(36),
              height: context.scale(36),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(context.scale(18)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.gallerySvg,
                  colorFilter: const ColorFilter.mode(
                    AppColors.vibrantBlue,
                    BlendMode.srcIn,
                  ),
                  height: context.scale(AppConstants.iconSize18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsSection(
    List<CommunityGroup> groups,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Groups',
              style: TextStyle(
                fontSize: context.sp(AppConstants.fontSizeXL),
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.createGroup),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.vibrantBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 14,
                          color: AppColors.vibrantBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'New Group',
                          style: TextStyle(
                            color: AppColors.vibrantBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: context.sp(AppConstants.fontSizeXS),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.allGroups);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(context.scale(50), context.scaleH(30)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View all',
                    style: TextStyle(
                      color: AppColors.vibrantBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: context.sp(AppConstants.fontSizeMD),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: context.scaleH(AppConstants.padding10)),
        if (groups.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.scale(AppConstants.paddingMedium),
              vertical: context.scaleH(AppConstants.padding20),
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                context.scale(AppConstants.borderRadius16),
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.blackOpacity4,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: context.scale(44),
                  height: context.scale(44),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.pcommunitySvg,
                      width: context.scale(22),
                      height: context.scale(22),
                      colorFilter: const ColorFilter.mode(
                        AppColors.vibrantBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(10)),
                Text(
                  'No Groups Available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.sp(AppConstants.fontSizeMD),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                  ),
                ),
                SizedBox(height: context.scaleH(4)),
                Text(
                  'There are no active groups right now',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.sp(AppConstants.fontSizeSM),
                    color: AppColors.slate500,
                  ),
                ),
                SizedBox(height: context.scaleH(12)),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.createGroup),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vibrantBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '+ Create Group',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...groups.map((group) {
                  final initials = group.title.trim().isNotEmpty
                      ? (group.title.trim().length >= 2
                          ? group.title.trim().substring(0, 2).toUpperCase()
                          : group.title.trim().toUpperCase())
                      : 'GP';

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.groupDetail,
                        arguments: {
                          'id': group.id ?? '',
                          'title': group.title,
                          'members': group.members,
                          'bgColor': group.bgColor,
                          'icon': group.icon,
                          'coverImageUrl': group.coverImageUrl,
                        },
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: context.scale(150),
                      height: context.scaleH(120),
                      margin: EdgeInsets.only(
                        right: context.scale(AppConstants.paddingMedium),
                      ),
                      padding: EdgeInsets.all(
                        context.scale(AppConstants.paddingMedium),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          context.scale(AppConstants.borderRadius16),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.blackOpacity4,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  context.scale(AppConstants.borderRadius10),
                                ),
                                child: (group.coverImageUrl != null &&
                                        group.coverImageUrl!.isNotEmpty)
                                    ? Image.network(
                                        group.coverImageUrl!,
                                        width: context.scale(36),
                                        height: context.scale(36),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: context.scale(36),
                                          height: context.scale(36),
                                          color: group.bgColor,
                                          alignment: Alignment.center,
                                          child: Text(
                                            initials,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: context.sp(13),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: context.scale(36),
                                        height: context.scale(36),
                                        color: group.bgColor,
                                        alignment: Alignment.center,
                                        child: Text(
                                          initials,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.sp(13),
                                          ),
                                        ),
                                      ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.group_outlined,
                                      size: 11,
                                      color: AppColors.slate500,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      group.members,
                                      style: TextStyle(
                                        fontSize: context.sp(10),
                                        color: AppColors.slate600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            group.title,
                            style: TextStyle(
                              fontSize: context.sp(AppConstants.fontSizeMD),
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate800,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.allGroups);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: context.scale(95),
                    height: context.scaleH(120),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(
                        context.scale(AppConstants.borderRadius16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: context.scale(32),
                          height: context.scale(32),
                          padding: EdgeInsets.all(context.scale(8)),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.arrowForwardSvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate600,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: context.scaleH(AppConstants.paddingSmall),
                        ),
                        Text(
                          'See All',
                          style: TextStyle(
                            fontSize: context.sp(AppConstants.fontSizeSM),
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSpotlightSection(
    List<SpotlightMember> members,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Community Spotlight',
              style: TextStyle(
                fontSize: context.sp(AppConstants.fontSizeXL),
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(context.scale(50), context.scaleH(30)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View all',
                style: TextStyle(
                  color: AppColors.vibrantBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: context.sp(AppConstants.fontSizeMD),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.scaleH(AppConstants.padding10)),
        if (members.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.scale(AppConstants.paddingMedium),
              vertical: context.scaleH(AppConstants.padding20),
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                context.scale(AppConstants.borderRadius16),
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.blackOpacity4,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: context.scale(44),
                  height: context.scale(44),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.crownSvg,
                      width: context.scale(22),
                      height: context.scale(22),
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFD97706),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(10)),
                Text(
                  'No Spotloght available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.sp(AppConstants.fontSizeMD),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                  ),
                ),
                SizedBox(height: context.scaleH(4)),
                Text(
                  'There are no featured members in spotlight right now',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.sp(AppConstants.fontSizeSM),
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: members.map((member) {
                return Container(
                  margin: EdgeInsets.only(right: context.scale(18)),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              member.hasBorderRing ? context.scale(2.5) : 0,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: member.hasBorderRing
                                  ? Border.all(
                                      color: AppColors.emerald300,
                                      width: AppConstants.borderWidthThick,
                                    )
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: context.scale(26),
                              backgroundImage: NetworkImage(member.imageUrl),
                            ),
                          ),
                          if (member.isOnline)
                            Positioned(
                              bottom: context.scaleH(2),
                              right: context.scale(2),
                              child: Container(
                                width: context.scale(
                                  AppConstants.paddingMedium,
                                ),
                                height: context.scale(
                                  AppConstants.paddingMedium,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.emerald,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: AppConstants.borderWidthThick,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: context.scaleH(AppConstants.paddingSmall - 2),
                      ),
                      Text(
                        member.name,
                        style: TextStyle(
                          fontSize: context.sp(AppConstants.fontSizeSM),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                        ),
                      ),
                      Text(
                        member.role,
                        style: TextStyle(
                          fontSize: context.sp(AppConstants.fontSizeXS),
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scale(AppConstants.padding32)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          context.scale(AppConstants.borderRadius16),
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            AppIcons.chatRoundSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate400,
              BlendMode.srcIn,
            ),
            height: context.scale(AppConstants.fontSizeDisplay26),
          ),
          SizedBox(height: context.scaleH(AppConstants.paddingMedium)),
          Text(
            'No posts in this category yet',
            style: TextStyle(
              fontSize: context.sp(AppConstants.fontSizeLG),
              fontWeight: FontWeight.bold,
              color: AppColors.slate800,
            ),
          ),
          SizedBox(height: context.scaleH(4)),
          Text(
            'Be the first to share an update or question!',
            style: TextStyle(
              fontSize: context.sp(AppConstants.fontSizeSM),
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    CommunityPostModel post,
    CommunityViewModel viewModel,
  ) {
    Color tagBgColor = AppColors.lightBlue;
    Color tagTextColor = AppColors.vibrantBlue;

    if (post.tag == 'Questions') {
      tagBgColor = AppColors.amber100;
      tagTextColor = AppColors.amber700;
    } else if (post.tag == 'Help') {
      tagBgColor = AppColors.redLight100;
      tagTextColor = AppColors.primaryRed;
    } else if (post.tag == 'Events') {
      tagBgColor = AppColors.greenLight100;
      tagTextColor = AppColors.successGreen;
    }

    final currentUser = context.read<AuthViewModel>().currentUser;
    final currentUserId = currentUser?.id;
    final currentUserName = currentUser?.fullName;
    final isMyPost = (currentUserId != null &&
            ((post.authorId != null && post.authorId == currentUserId) ||
             (post.author?.id.isNotEmpty == true && post.author?.id == currentUserId))) ||
        (currentUserName != null &&
         currentUserName.isNotEmpty &&
         post.authorName.toLowerCase() == currentUserName.toLowerCase());

    return Container(
      padding: EdgeInsets.all(context.scale(AppConstants.paddingLarge)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          context.scale(AppConstants.borderRadius16),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackOpacity4,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header Row
          Row(
            children: [
              UserAvatar(
                photoUrl: post.authorAvatarUrl,
                size: context.scale(40),
                fallbackBgColor: AppColors.lightBlue,
                fallbackIconColor: AppColors.primaryBlue,
              ),
              SizedBox(width: context.scale(AppConstants.padding10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.authorName,
                          style: TextStyle(
                            fontSize: context.sp(AppConstants.fontSize),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                          ),
                        ),
                        if (post.isVerified) ...[
                          SizedBox(
                            width: context.scale(AppConstants.paddingSmall - 2),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.scale(
                                AppConstants.paddingSmall - 2,
                              ),
                              vertical: context.scaleH(AppConstants.padding2),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight100,
                              borderRadius: BorderRadius.circular(
                                context.scale(AppConstants.padding10),
                              ),
                            ),
                            child: Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: context.sp(AppConstants.fontSizeXXS),
                                fontWeight: FontWeight.w600,
                                color: AppColors.successGreen,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: context.scaleH(AppConstants.padding2)),
                    Text(
                      '${post.authorLocation} · ${post.timeAgo}',
                      style: TextStyle(
                        fontSize: context.sp(AppConstants.fontSizeXS + 1),
                        color: AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),

              // Tag Chip
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(AppConstants.padding10),
                  vertical: context.scaleH(AppConstants.padding4),
                ),
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(
                    context.scale(AppConstants.paddingMedium),
                  ),
                ),
                child: Text(
                  post.tag,
                  style: TextStyle(
                    fontSize: context.sp(AppConstants.fontSizeXS),
                    fontWeight: FontWeight.w600,
                    color: tagTextColor,
                  ),
                ),
              ),

              if (isMyPost) ...[
                SizedBox(width: context.scale(AppConstants.paddingSmall)),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      context.scale(AppConstants.borderRadius8),
                    ),
                    onTap: () => _showDeletePostDialog(context, viewModel, post),
                    child: Container(
                      padding: EdgeInsets.all(
                        context.scale(AppConstants.padding6),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(
                          context.scale(AppConstants.borderRadius8),
                        ),
                        border: Border.all(
                          color: const Color(0xFFFEE2E2),
                          width: 1,
                        ),
                      ),
                      child: SvgPicture.asset(
                        AppIcons.deleteSvg,
                        width: context.scale(16),
                        height: context.scale(16),
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFEF4444),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (!isMyPost) ...[
                SizedBox(width: context.scale(AppConstants.paddingSmall)),
                Theme(
                  data: Theme.of(context).copyWith(
                    popupMenuTheme: const PopupMenuThemeData(
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: context.scale(20),
                      color: AppColors.slate400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'report') {
                        final authorId = post.authorId ?? post.author?.id;
                        ReportBottomSheet.show(
                          context,
                          targetType: ReportTargetType.communityPost,
                          targetId: post.id,
                          targetOwnerId: authorId,
                          targetTitle: 'Report Post',
                        );
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem<String>(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 18, color: AppColors.primaryRed),
                            SizedBox(width: 8),
                            Text(
                              'Report Post',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: context.scaleH(AppConstants.paddingStandard)),

          // Content Text
          Text(
            post.content,
            style: TextStyle(
              fontSize: context.sp(AppConstants.fontSizeMD),
              color: AppColors.slate700,
              height: 1.4,
            ),
          ),

          // Attached Media (Photos or Video)
          _buildPostMedia(context, post),

          // Poll Card
          if (post.pollOptions != null && post.pollOptions!.isNotEmpty) ...[
            SizedBox(height: context.scaleH(AppConstants.paddingMedium)),
            Container(
              padding: EdgeInsets.all(
                context.scale(AppConstants.paddingMedium),
              ),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(
                  context.scale(AppConstants.borderRadius12),
                ),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(post.pollOptions!.length, (optIdx) {
                    final optionText = post.pollOptions![optIdx];
                    final votes = post.pollVotes[optIdx] ?? 0;
                    final total = post.totalPollVotes;
                    final percent = total > 0 ? (votes / total) : 0.0;
                    final isSelected = post.userVotedOption == optIdx;

                    return Padding(
                      padding: EdgeInsets.only(bottom: context.scaleH(8.0)),
                      child: GestureDetector(
                        onTap: () => viewModel.votePoll(post.id, optIdx),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scale(12),
                            vertical: context.scaleH(10),
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryPurple.withValues(
                                    alpha: 0.08,
                                  )
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(
                              context.scale(8),
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryPurple
                                  : AppColors.slate200,
                            ),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                isSelected
                                    ? AppIcons.tickAltSvg
                                    : AppIcons.tickCircleSvg,
                                height: context.scale(18),
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? AppColors.primaryPurple
                                      : AppColors.slate400,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: context.scale(8)),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    fontSize: context.sp(13),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: AppColors.slate800,
                                  ),
                                ),
                              ),
                              if (total > 0)
                                Text(
                                  '${(percent * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: context.sp(12),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  Text(
                    '${post.totalPollVotes} votes',
                    style: TextStyle(
                      fontSize: context.sp(11),
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Location / Feeling Badges
          if (post.location != null || post.feeling != null) ...[
            SizedBox(height: context.scaleH(AppConstants.paddingSmall)),
            Wrap(
              spacing: context.scale(6),
              children: [
                if (post.location != null)
                  Chip(
                    avatar: SvgPicture.asset(
                      AppIcons.locationSvg,
                      height: context.scale(12),
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryRed,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      post.location!,
                      style: TextStyle(fontSize: context.sp(11)),
                    ),
                    backgroundColor: AppColors.redLight100,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                if (post.feeling != null)
                  Chip(
                    label: Text(
                      post.feeling!,
                      style: TextStyle(fontSize: context.sp(11)),
                    ),
                    backgroundColor: AppColors.blueBg,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],

          // Official Source Banner
          if (post.officialSource != null) ...[
            SizedBox(height: context.scaleH(AppConstants.paddingStandard)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: context.scale(AppConstants.paddingStandard),
                vertical: context.scaleH(AppConstants.padding10),
              ),
              decoration: BoxDecoration(
                color: AppColors.greenLight100,
                borderRadius: BorderRadius.circular(
                  context.scale(AppConstants.padding20),
                ),
              ),
              child: Text(
                'Official source: ${post.officialSource}',
                style: TextStyle(
                  fontSize: context.sp(AppConstants.fontSizeSM),
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                ),
              ),
            ),
          ],

          SizedBox(height: context.scaleH(AppConstants.paddingLarge)),

          // Reaction & Interaction Row
          Row(
            children: [
              // Like Button (Interactive)
              GestureDetector(
                onTap: () => viewModel.toggleLike(post.id),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.favSvg,
                      height: context.scale(18),
                      colorFilter: ColorFilter.mode(
                        post.isLiked
                            ? AppColors.primaryRed
                            : AppColors.slate500,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: context.scale(AppConstants.padding4)),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(
                        fontSize: context.sp(AppConstants.fontSizeSM),
                        color: post.isLiked
                            ? AppColors.primaryRed
                            : AppColors.slate600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: context.scale(AppConstants.padding20)),

              // Comment Button with live count and modal trigger
              GestureDetector(
                onTap: () => _openCommentsSheet(context, post, viewModel),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.chatRoundSvg,
                      height: context.scale(AppConstants.iconSize18),
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate500,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: context.scale(AppConstants.padding4)),
                    Text(
                      '${post.commentsCount}',
                      style: TextStyle(
                        fontSize: context.sp(AppConstants.fontSizeSM),
                        color: AppColors.slate600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: context.scale(AppConstants.padding20)),

              // Share
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.shareSvg,
                    height: context.scale(AppConstants.iconSize18),
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate500,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: context.scale(AppConstants.padding4)),
                  Text(
                    '${post.sharesCount}',
                    style: TextStyle(
                      fontSize: context.sp(AppConstants.fontSizeSM),
                      color: AppColors.slate600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Rich Media (Photos & Video) Rendering
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildPostMedia(BuildContext context, CommunityPostModel post) {
    if (post.hasVideo && post.videoUrl != null && post.videoUrl!.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(
          top: context.scaleH(AppConstants.paddingMedium),
        ),
        child: _buildPostVideo(context, post),
      );
    }

    if (post.hasPhotos && post.allPhotoUrls.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(
          top: context.scaleH(AppConstants.paddingMedium),
        ),
        child: _buildPostPhotos(context, post.allPhotoUrls),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPostPhotos(BuildContext context, List<String> photoUrls) {
    if (photoUrls.length == 1) {
      return _buildSinglePhoto(context, photoUrls.first, photoUrls);
    } else if (photoUrls.length == 2) {
      return _buildTwoPhotos(context, photoUrls);
    } else if (photoUrls.length == 3) {
      return _buildThreePhotos(context, photoUrls);
    } else {
      return _buildFourPlusPhotos(context, photoUrls);
    }
  }

  Widget _buildSinglePhoto(
    BuildContext context,
    String url,
    List<String> allPhotos,
  ) {
    return GestureDetector(
      onTap: () => _openImageViewer(context, allPhotos, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          context.scale(AppConstants.borderRadius12),
        ),
        child: SizedBox(
          height: context.scaleH(220),
          width: double.infinity,
          child: _buildImageWidget(context, url),
        ),
      ),
    );
  }

  Widget _buildTwoPhotos(BuildContext context, List<String> photos) {
    return SizedBox(
      height: context.scaleH(180),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openImageViewer(context, photos, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(
                    context.scale(AppConstants.borderRadius12),
                  ),
                ),
                child: SizedBox.expand(
                  child: _buildImageWidget(context, photos[0]),
                ),
              ),
            ),
          ),
          SizedBox(width: context.scale(4)),
          Expanded(
            child: GestureDetector(
              onTap: () => _openImageViewer(context, photos, 1),
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(
                    context.scale(AppConstants.borderRadius12),
                  ),
                ),
                child: SizedBox.expand(
                  child: _buildImageWidget(context, photos[1]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreePhotos(BuildContext context, List<String> photos) {
    return SizedBox(
      height: context.scaleH(200),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _openImageViewer(context, photos, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(
                    context.scale(AppConstants.borderRadius12),
                  ),
                ),
                child: SizedBox.expand(
                  child: _buildImageWidget(context, photos[0]),
                ),
              ),
            ),
          ),
          SizedBox(width: context.scale(4)),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openImageViewer(context, photos, 1),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                          context.scale(AppConstants.borderRadius12),
                        ),
                      ),
                      child: SizedBox.expand(
                        child: _buildImageWidget(context, photos[1]),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(4)),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openImageViewer(context, photos, 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(
                          context.scale(AppConstants.borderRadius12),
                        ),
                      ),
                      child: SizedBox.expand(
                        child: _buildImageWidget(context, photos[2]),
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

  Widget _buildFourPlusPhotos(BuildContext context, List<String> photos) {
    final remainingCount = photos.length - 4;

    return SizedBox(
      height: context.scaleH(220),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openImageViewer(context, photos, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          context.scale(AppConstants.borderRadius12),
                        ),
                      ),
                      child: SizedBox.expand(
                        child: _buildImageWidget(context, photos[0]),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.scale(4)),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openImageViewer(context, photos, 1),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                          context.scale(AppConstants.borderRadius12),
                        ),
                      ),
                      child: SizedBox.expand(
                        child: _buildImageWidget(context, photos[1]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.scaleH(4)),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openImageViewer(context, photos, 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                          context.scale(AppConstants.borderRadius12),
                        ),
                      ),
                      child: SizedBox.expand(
                        child: _buildImageWidget(context, photos[2]),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.scale(4)),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openImageViewer(context, photos, 3),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(
                              context.scale(AppConstants.borderRadius12),
                            ),
                          ),
                          child: _buildImageWidget(context, photos[3]),
                        ),
                        if (remainingCount > 0)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(
                                  context.scale(AppConstants.borderRadius12),
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '+$remainingCount',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: context.sp(20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
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

  Widget _buildImageWidget(BuildContext context, String path) {
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
            color: AppColors.slate100,
            child: Center(
              child: SizedBox(
                width: context.scale(24),
                height: context.scale(24),
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (ctx, err, stack) => Container(
          color: AppColors.slate200,
          child: Center(
            child: SvgPicture.asset(
              AppIcons.error_imageSvg,
              colorFilter: const ColorFilter.mode(
                AppColors.slate400,
                BlendMode.srcIn,
              ),
              width: context.scale(32),
              height: context.scale(32),
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
        color: AppColors.slate200,
        child: Center(
          child: SvgPicture.asset(
            AppIcons.gallerySvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate400,
              BlendMode.srcIn,
            ),
            width: context.scale(32),
            height: context.scale(32),
          ),
        ),
      );
    }
  }

  Widget _buildPostVideo(BuildContext context, CommunityPostModel post) {
    return AppFeedVideoPlayer(
      videoUrl: post.videoUrl!,
      postTimeAgo: post.timeAgo,
      authorName: post.authorName,
      postContent: post.content,
      isLiked: post.isLiked,
      onLikeToggle: () {
        context.read<CommunityViewModel>().toggleLike(post.id);
      },
      onShare: () {
        AppShareHelper.shareAsLink(
          context: context,
          type: ShareItemType.community,
          id: post.id,
          title: post.authorName,
          description: post.content,
        );
      },
    );
  }

  Future<void> _showDeletePostDialog(
    BuildContext context,
    CommunityViewModel viewModel,
    CommunityPostModel post,
  ) async {
    final confirmed = await showDialog<bool>(
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
                    fontFamily: 'Inter',
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
                    fontFamily: 'Inter',
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
                        fontFamily: 'Inter',
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
                        fontFamily: 'Inter',
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

    if (confirmed != true || !context.mounted) return;

    final success = await viewModel.deletePost(post.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Post deleted successfully!' : 'Failed to delete post',
        ),
        backgroundColor:
            success ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openImageViewer(
    BuildContext context,
    List<String> photos,
    int initialIndex,
  ) {
    context.read<CommunityViewModel>().setActiveGalleryIndex(initialIndex);
    final pageController = PageController(initialPage: initialIndex);

    showDialog(
      context: context,
      builder: (ctx) {
        return _FullScreenGalleryDialog(
          photos: photos,
          pageController: pageController,
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Comments Modal Sheet (Live API & Real-time Comments)
  // ──────────────────────────────────────────────────────────────────────────

  void _openCommentsSheet(
    BuildContext context,
    CommunityPostModel post,
    CommunityViewModel viewModel,
  ) {
    CommunityCommentsSheet.show(context, post);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Full-Screen Image Gallery Dialog (Stateless & Responsive)
// ────────────────────────────────────────────────────────────────────────────

class _FullScreenGalleryDialog extends StatelessWidget {
  final List<String> photos;
  final PageController pageController;

  const _FullScreenGalleryDialog({
    required this.photos,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityViewModel>();
    final currentIndex = viewModel.activeGalleryIndex;

    return Dialog(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: photos.length,
            onPageChanged: (idx) {
              context.read<CommunityViewModel>().setActiveGalleryIndex(idx);
            },
            itemBuilder: (ctx, idx) {
              return InteractiveViewer(
                child: Center(child: _buildGalleryImage(context, photos[idx])),
              );
            },
          ),

          // Close button
          Positioned(
            top: context.scaleH(40),
            right: context.scale(16),
            child: IconButton(
              icon: SvgPicture.asset(
                AppIcons.crossSmallSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
                width: context.scale(28),
                height: context.scale(28),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Counter indicator
          if (photos.length > 1)
            Positioned(
              top: context.scaleH(48),
              left: context.scale(20),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(12),
                  vertical: context.scaleH(4),
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(context.scale(16)),
                ),
                child: Text(
                  '${currentIndex + 1} / ${photos.length}',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGalleryImage(BuildContext context, String path) {
    String resolvedPath = path.trim();
    if (resolvedPath.isNotEmpty && !resolvedPath.startsWith('http')) {
      final localFile = File(resolvedPath);
      if (localFile.existsSync()) {
        return Image.file(localFile, fit: BoxFit.contain);
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
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, stack) => Container(
          color: AppColors.slate200,
          child: Center(
            child: SvgPicture.asset(
              AppIcons.error_imageSvg,
              colorFilter: const ColorFilter.mode(
                AppColors.slate400,
                BlendMode.srcIn,
              ),
              width: context.scale(32),
              height: context.scale(32),
            ),
          ),
        ),
      );
    } else {
      final file = File(resolvedPath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain);
      }
      return Container(
        color: AppColors.slate200,
        child: Center(
          child: SvgPicture.asset(
            AppIcons.gallerySvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate400,
              BlendMode.srcIn,
            ),
            width: context.scale(32),
            height: context.scale(32),
          ),
        ),
      );
    }
  }
}

