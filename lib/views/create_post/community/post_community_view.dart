import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/community/community_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/views/create_post/community/widgets/video_attachment_preview.dart';

class PostCommunityView extends StatelessWidget {
  final String? initialGroupId;
  final String? initialGroupName;

  const PostCommunityView({
    super.key,
    this.initialGroupId,
    this.initialGroupName,
  });

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius10),
        ),
      ),
    );
  }

  Future<void> _submitPost(BuildContext context, CommunityViewModel vm) async {
    if (vm.isSubmittingPost) return;

    final validationError = vm.validateCommunityPost();
    if (validationError != null) {
      _showErrorSnackBar(context, validationError);
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;
    final userName = (user?.firstName != null && user!.firstName.isNotEmpty)
        ? '${user.firstName} ${user.lastName ?? ''}'.trim()
        : 'Community Member';

    final success = await vm.submitPostForm(
      userName: userName,
      userProfilePhotoUrl: user?.profilePhotoUrl,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post created successfully!'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius10),
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      final errorMsg =
          vm.errorMessage ?? 'Failed to create post. Please try again.';
      _showErrorSnackBar(context, errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CommunityViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;
    final userName = (user?.firstName != null && user!.firstName.isNotEmpty)
        ? '${user.firstName} ${user.lastName ?? ''}'.trim()
        : (user?.username.isNotEmpty == true
            ? user!.username
            : 'Community Member');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.initPostCommunityForm(
        initialGroupId: initialGroupId,
        initialGroupName: initialGroupName,
      );
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          vm.resetPostCommunityForm();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ────────────────────────────────────────────────────────────────
              // Top App Bar
              // ────────────────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        vm.resetPostCommunityForm();
                        Navigator.pop(context);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SvgPicture.asset(
                          AppIcons.crossSmallAltSvg,
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Community Post',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate900,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: vm.isSubmittingPost
                          ? null
                          : () => _submitPost(context, vm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: vm.isSubmittingPost
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF4353E8),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: vm.isSubmittingPost
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text(
                                'Post',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),

              // ────────────────────────────────────────────────────────────────
              // Scrollable Content
              // ────────────────────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. User Header Row
                      _buildUserHeader(user, userName, vm),
                      const SizedBox(height: 16),

                      // 2. Segmented Post Type Tabs
                      _buildPostTypeTabBar(vm),
                      const SizedBox(height: 18),

                      // 3. Multi-line Text Area
                      CustomTextField(
                        controller: vm.postContentController,
                        hintText: vm.selectedTab == 'Poll'
                            ? 'Ask a question for your poll...'
                            : (vm.selectedTab == 'Photo'
                                ? 'Write a caption for your photos (optional)...'
                                : (vm.selectedTab == 'Video'
                                    ? 'Write a caption for your video (optional)...'
                                    : "What's on your mind?")),
                        maxLines: 6,
                        fontFamily: AppStrings.fontInter,
                        fillColor: AppColors.white,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),

                      // Dynamic Attached Content Previews from Device
                      if (vm.selectedTab == 'Poll') _buildPollBuilder(vm),
                      if (vm.selectedPhotos.isNotEmpty) _buildPhotosPreview(vm),
                      if (vm.selectedVideoFile != null) _buildVideoPreview(vm),
                      if (vm.selectedLocation != null) _buildLocationBadge(vm),
                      if (vm.selectedFeeling != null) _buildFeelingBadge(vm),

                      const SizedBox(height: 14),
                      const Divider(
                        color: Color(0xFFF1F5F9),
                        height: 1,
                        thickness: 1,
                      ),
                      const SizedBox(height: 14),

                      // 4. "Add to your post" Section
                      _buildBottomActionSection(vm),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(
    dynamic user,
    String userName,
    CommunityViewModel vm,
  ) {
    String audienceIcon = AppIcons.globalSvg;
    Color audienceColor = const Color(0xFF3B82F6);
    if (vm.selectedAudience == 'Friends') {
      audienceIcon = AppIcons.peopleCommunitySvg;
      audienceColor = const Color(0xFF10B981);
    } else if (vm.selectedAudience == 'Group') {
      audienceIcon = AppIcons.peopleCommunitySvg;
      audienceColor = const Color(0xFF8B5CF6);
    } else if (vm.selectedAudience == 'Only Me') {
      audienceIcon = AppIcons.lockSvg;
      audienceColor = const Color(0xFFEF4444);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFEF3C7),
          ),
          child: ClipOval(
            child:
                user?.profilePhotoUrl != null &&
                    user!.profilePhotoUrl!.isNotEmpty
                ? Image.network(
                    user.profilePhotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        _buildDefaultIllustration(),
                  )
                : _buildDefaultIllustration(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (String value) => vm.setSelectedAudience(value),
                    tooltip: 'Change Audience',
                    elevation: 6,
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    offset: const Offset(0, 32),
                    itemBuilder: (BuildContext context) {
                      return vm.audienceOptions.map((opt) {
                        final String label = opt['label'] as String;
                        final String icon = opt['icon'] as String;
                        final Color iconColor = opt['iconColor'] as Color;
                        final String desc = opt['desc'] as String;
                        final bool isSelected = vm.selectedAudience == label;

                        return PopupMenuItem<String>(
                          value: label,
                          height: 48,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  icon,
                                  height: 20,
                                  width: 20,
                                  colorFilter: ColorFilter.mode(
                                    iconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                           ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF4353E8)
                                            : const Color(0xFF0F172A),
                                        fontFamily: AppStrings.fontInter,
                                      ),
                                    ),
                                    Text(
                                      desc,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF64748B),
                                        fontFamily: AppStrings.fontInter,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                SvgPicture.asset(
                                  AppIcons.tickAltSvg,
                                  height: 18,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF4353E8),
                                    BlendMode.srcIn,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            audienceIcon,
                            height: 13,
                            colorFilter: ColorFilter.mode(
                              audienceColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vm.selectedAudience,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          const SizedBox(width: 2),
                          SvgPicture.asset(
                            AppIcons.arrowDropDownSvg,
                            height: 15,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF64748B),
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (vm.selectedAudience == 'Group')
                    PopupMenuButton<Map<String, String>>(
                      onOpened: () {
                        if (vm.availableGroups.isEmpty) {
                          vm.fetchMyGroups(force: true, limit: 50);
                        }
                      },
                      onSelected: (Map<String, String> group) {
                        vm.setSelectedGroup(group['id']!, group['name']!);
                      },
                      tooltip: 'Select Group',
                      elevation: 6,
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      offset: const Offset(0, 32),
                      itemBuilder: (BuildContext context) {
                        if (vm.isLoadingMyGroups && vm.availableGroups.isEmpty) {
                          return [
                            const PopupMenuItem<Map<String, String>>(
                              enabled: false,
                              height: 48,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF8B5CF6),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Loading your groups...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate500,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        }
                        if (vm.availableGroups.isEmpty) {
                          return [
                            const PopupMenuItem<Map<String, String>>(
                              enabled: false,
                              height: 42,
                              child: Text(
                                'You haven\'t joined any groups yet',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.slate500,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ),
                          ];
                        }
                        return vm.availableGroups.map((g) {
                          final String id = g['id'] ?? '';
                          final String name = g['name'] ?? '';
                          final bool isSelected = vm.selectedGroupId == id;
                          return PopupMenuItem<Map<String, String>>(
                            value: g,
                            height: 42,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcons.assetCommuintySvg,
                                  height: 16,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF8B5CF6),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF8B5CF6)
                                          : const Color(0xFF0F172A),
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  SvgPicture.asset(
                                    AppIcons.tickAltSvg,
                                    height: 16,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF8B5CF6),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppIcons.assetCommuintySvg,
                              height: 13,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF8B5CF6),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 130),
                              child: Text(
                                vm.isLoadingMyGroups && vm.availableGroups.isEmpty
                                    ? 'Loading...'
                                    : (vm.selectedGroupName.isNotEmpty
                                        ? vm.selectedGroupName
                                        : 'Select Group'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B21A8),
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            SvgPicture.asset(
                              AppIcons.arrowDropDownSvg,
                              height: 15,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF8B5CF6),
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultIllustration() {
    return Center(
      child: SvgPicture.asset(
        AppIcons.personSvg,
        height: 24,
        colorFilter: const ColorFilter.mode(
          AppColors.textLightGray,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildPostTypeTabBar(CommunityViewModel vm) {
    final types = [
      {'label': 'Text', 'icon': AppIcons.menuHorizontalSvg},
      {'label': 'Photo', 'icon': AppIcons.gallerySvg},
      {'label': 'Video', 'icon': AppIcons.videoCameraSvg},
      {'label': 'Poll', 'icon': AppIcons.barSvg},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: types.map((item) {
          final label = item['label'] as String;
          final icon = item['icon'] as String;
          final isSelected = vm.selectedTab == label;

          return Expanded(
            child: GestureDetector(
              onTap: () => vm.onTabChanged(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      icon,
                      height: 15,
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF64748B),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF64748B),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPollBuilder(CommunityViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Poll Options',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF0F172A),
              fontFamily: AppStrings.fontInter,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(vm.pollOptionControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: vm.pollOptionControllers[index],
                      decoration: InputDecoration(
                        hintText: 'Option ${index + 1}',
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (vm.pollOptionControllers.length > 2) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      icon: SvgPicture.asset(
                        AppIcons.deleteSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryRed,
                          BlendMode.srcIn,
                        ),
                        height: 18,
                      ),
                      onPressed: () => vm.removePollOption(index),
                    ),
                  ],
                ],
              ),
            );
          }),
          if (vm.pollOptionControllers.length < 6)
            TextButton.icon(
              onPressed: vm.addPollOption,
              icon: SvgPicture.asset(
                AppIcons.plusCircleSvg,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF4353E8),
                  BlendMode.srcIn,
                ),
                height: 16,
              ),
              label: const Text('Add Option'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4353E8),
              ),
            ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 10),
          const Text(
            'Poll Duration',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF0F172A),
              fontFamily: AppStrings.fontInter,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildDurationChip(vm, label: '1 Day', days: 1),
              _buildDurationChip(vm, label: '3 Days', days: 3),
              _buildDurationChip(vm, label: '7 Days', days: 7),
              _buildDurationChip(vm, label: '14 Days', days: 14),
              _buildDurationChip(vm, label: 'No Expiry', days: 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip(
    CommunityViewModel vm, {
    required String label,
    required int days,
  }) {
    final isSelected = vm.pollDurationDays == days;
    return GestureDetector(
      onTap: () => vm.setPollDurationDays(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDE9FE) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C3AED)
                : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF7C3AED)
                : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosPreview(CommunityViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount:
                vm.selectedPhotos.length + (vm.selectedPhotos.length < 5 ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index < vm.selectedPhotos.length) {
                final photo = vm.selectedPhotos[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        photo,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => vm.removePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.crossSmallAltSvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                            height: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Add more photos button
              return GestureDetector(
                onTap: () => vm.pickSinglePhoto(context),
                child: Container(
                  width: 90,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppIcons.gallerySvg,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF64748B),
                          BlendMode.srcIn,
                        ),
                        height: 22,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Add Photo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${vm.selectedPhotos.length}/5 photos selected',
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildVideoPreview(CommunityViewModel vm) {
    return VideoAttachmentPreview(
      videoFile: vm.selectedVideoFile!,
      onRemove: vm.removeVideo,
    );
  }

  Widget _buildLocationBadge(CommunityViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Chip(
        avatar: SvgPicture.asset(
          AppIcons.locationSvg,
          colorFilter: const ColorFilter.mode(
            Color(0xFFEF4444),
            BlendMode.srcIn,
          ),
          height: 14,
        ),
        label: Text(
          vm.selectedLocation!,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFFFE4E6),
        deleteIcon: SvgPicture.asset(
          AppIcons.crossSmallAltSvg,
          colorFilter: const ColorFilter.mode(
            Color(0xFFEF4444),
            BlendMode.srcIn,
          ),
          height: 14,
        ),
        onDeleted: () => vm.setSelectedLocation(null),
      ),
    );
  }

  Widget _buildFeelingBadge(CommunityViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Chip(
        label: Text(
          vm.selectedFeeling!,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFDBEAFE),
        deleteIcon: SvgPicture.asset(
          AppIcons.crossSmallAltSvg,
          colorFilter: const ColorFilter.mode(
            Color(0xFFEF4444),
            BlendMode.srcIn,
          ),
          height: 14,
        ),
        onDeleted: () => vm.setSelectedFeeling(null),
      ),
    );
  }

  Widget _buildBottomActionSection(CommunityViewModel vm) {
    final cities = [
      'Madrid, Spain',
      'Barcelona, Spain',
      'Valencia, Spain',
      'Seville, Spain',
      'Malaga, Spain',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add to your post',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
            fontFamily: AppStrings.fontInter,
          ),
        ),
        const SizedBox(height: 10),

        // Action Pills: Photo, Video, Poll, Location (wrapped responsively to prevent overflow)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Photo (Green) - Pick Photo from device
            _buildColorActionPill(
              icon: AppIcons.gallerySvg,
              label: 'Photo',
              bgColor: const Color(0xFFDCFCE7),
              fgColor: const Color(0xFF16A34A),
              onTap: () => vm.onTabChanged('Photo'),
            ),

            // Video (Yellow/Amber) - Pick Video from device
            _buildColorActionPill(
              icon: AppIcons.videoCameraSvg,
              label: 'Video',
              bgColor: const Color(0xFFFEF3C7),
              fgColor: const Color(0xFFD97706),
              onTap: () => vm.onTabChanged('Video'),
            ),

            // Poll (Purple)
            _buildColorActionPill(
              icon: AppIcons.barSvg,
              label: 'Poll',
              bgColor: const Color(0xFFEDE9FE),
              fgColor: const Color(0xFF7C3AED),
              onTap: () => vm.onTabChanged('Poll'),
            ),

            // Location (Red/Rose) - Popup Menu
            PopupMenuButton<String>(
              onSelected: (String city) => vm.setSelectedLocation(city),
              tooltip: 'Add Location',
              elevation: 4,
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (ctx) => cities.map((c) {
                return PopupMenuItem<String>(
                  value: c,
                  height: 38,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.locationSvg,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFEF4444),
                          BlendMode.srcIn,
                        ),
                        height: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(c, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
              child: _buildColorActionPillWidget(
                icon: AppIcons.locationSvg,
                label: 'Location',
                bgColor: const Color(0xFFFFE4E6),
                fgColor: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorActionPill({
    required String icon,
    required String label,
    required Color bgColor,
    required Color fgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buildColorActionPillWidget(
        icon: icon,
        label: label,
        bgColor: bgColor,
        fgColor: fgColor,
      ),
    );
  }

  Widget _buildColorActionPillWidget({
    required String icon,
    required String label,
    required Color bgColor,
    required Color fgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(fgColor, BlendMode.srcIn),
            height: 14,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ],
      ),
    );
  }
}
