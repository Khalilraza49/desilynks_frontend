import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/utils/image_utils.dart';
import 'package:desilynks/viewmodels/community/community_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AllGroupsView extends StatelessWidget {
  const AllGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<CommunityViewModel>().ensureAllGroupsInitialized();
    });

    final vm = context.watch<CommunityViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar
            _buildHeader(context),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    vm.fetchGroups(force: true),
                    vm.fetchMyGroups(force: true),
                  ]);
                },
                child: SingleChildScrollView(
                  controller: vm.allGroupsScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Filter Pills Bar
                      _buildFilterPills(vm),
                      const SizedBox(height: 20),

                      // 3. My Groups Section
                      _buildMyGroupsSection(context, vm),
                      const SizedBox(height: 24),

                      // 4. Discover Group Section
                      _buildDiscoverGroupsSection(context, vm),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
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
          const SizedBox(width: 12),

          // Title
          const Text(
            'Groups',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          const Spacer(),

          // Search Button
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
            child: Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.searchSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate700,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Share Button
          GestureDetector(
            onTap: () => _shareAppGroups(context),
            child: Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.shareSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate700,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Plus Add Button
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.createGroup);
            },
            child: Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.vibrantBlue,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.plusSvg,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills(CommunityViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: vm.allGroupsFilters.map((filter) {
          final isSelected = vm.allGroupsFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.slate700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  vm.setAllGroupsFilter(filter);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.black : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMyGroupsSection(BuildContext context, CommunityViewModel vm) {
    if (vm.myGroupsList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
          children: [
            SvgPicture.asset(
              AppIcons.peopleCommunitySvg,
              height: 36,
              colorFilter: const ColorFilter.mode(
                AppColors.slate400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Joined Groups Yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Join an existing group or create your own community group.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.slate500),
            ),
          ],
        ),
      );
    }

    final bool isMyGroupsFilter = vm.allGroupsFilter == 'My Groups';
    final List<Map<String, dynamic>> displayedGroups =
        (vm.showAllMyGroups || isMyGroupsFilter)
        ? vm.myGroupsList
        : vm.myGroupsList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Groups (${vm.myGroupsList.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            TextButton(
              onPressed: vm.toggleShowAllMyGroups,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                (vm.showAllMyGroups || isMyGroupsFilter)
                    ? 'Show Less'
                    : 'View All',
                style: const TextStyle(
                  color: AppColors.vibrantBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...displayedGroups.map((group) {
          final String title = (group['title'] as String?) ??
              (group['name'] as String?) ??
              'Community Group';
          final String members = (group['members'] as String?) ??
              (group['memberCount'] != null
                  ? '${group['memberCount']} members'
                  : '1 member');
          final String coverUrl = ImageUtils.resolveGroupCoverUrl(group);
          final String tag = (group['tag'] as String?) ??
              (title.length >= 2 ? title.substring(0, 2).toUpperCase() : 'GP');
          final Color bgColor =
              (group['bgColor'] as Color?) ?? AppColors.vibrantBlue;

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.groupDetail,
                arguments: group,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
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
              child: Row(
                children: [
                  // Cover Photo / Tag Box
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: coverUrl.isNotEmpty
                        ? Image.network(
                            coverUrl,
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 42,
                              height: 42,
                              color: bgColor,
                              alignment: Alignment.center,
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Group Title & Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          members,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Chevron Icon
                  SvgPicture.asset(
                    AppIcons.arrowForwardSvg,
                    height: 16,
                    width: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate400,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDiscoverGroupsSection(
    BuildContext context,
    CommunityViewModel vm,
  ) {
    if (vm.allGroupsFilter == 'My Groups') {
      return const SizedBox.shrink();
    }

    if (vm.discoverGroupsList.isEmpty) {
      if (vm.isLoadingGroups) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
          children: [
            SvgPicture.asset(
              AppIcons.peopleCommunitySvg,
              height: 36,
              colorFilter: const ColorFilter.mode(
                AppColors.slate400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Groups Available',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Be the first to create a community group!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.slate500),
            ),
          ],
        ),
      );
    }

    final List<Map<String, dynamic>> displayedGroups = vm.showAllDiscoverGroups
        ? vm.discoverGroupsList
        : vm.discoverGroupsList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Discover Group (${vm.discoverGroupsList.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            TextButton(
              onPressed: vm.toggleShowAllDiscoverGroups,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                vm.showAllDiscoverGroups ? 'Show Less' : 'View All Groups',
                style: const TextStyle(
                  color: AppColors.vibrantBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...displayedGroups.asMap().entries.map((entry) {
          final int index = entry.key;
          final Map<String, dynamic> group = entry.value;
          final bool isJoined = (group['isJoined'] as bool?) ?? false;
          final String title = (group['title'] as String?) ??
              (group['name'] as String?) ??
              'Community Group';
          final String members = (group['members'] as String?) ??
              (group['memberCount'] != null
                  ? '${group['memberCount']} members'
                  : '1 member');
          final String coverUrl = ImageUtils.resolveGroupCoverUrl(group);
          final String tag = (group['tag'] as String?) ??
              (title.length >= 2 ? title.substring(0, 2).toUpperCase() : 'GP');
          final Color iconColor = (group['iconColor'] as Color?) ??
              AppColors.vibrantBlue;

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.groupDetail,
                arguments: group,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
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
              child: Row(
                children: [
                  // Icon / Cover Box
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: coverUrl.isNotEmpty
                        ? Image.network(
                            coverUrl,
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 42,
                              height: 42,
                              color: const Color(0xFFEFF6FF),
                              alignment: Alignment.center,
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: AppColors.vibrantBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: group['icon'] is String
                                ? SvgPicture.asset(
                                    group['icon'] as String,
                                    colorFilter: ColorFilter.mode(
                                      iconColor,
                                      BlendMode.srcIn,
                                    ),
                                    width: 20,
                                    height: 20,
                                  )
                                : Text(
                                    tag,
                                    style: const TextStyle(
                                      color: AppColors.vibrantBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Group Title & Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          members,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Join Button
                  ElevatedButton(
                    onPressed: () async {
                      final willJoin = !isJoined;
                      await vm.toggleJoinDiscoverGroup(index);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              willJoin
                                  ? 'Joined "$title" successfully!'
                                  : 'Left "$title"',
                            ),
                            backgroundColor:
                                willJoin ? AppColors.vibrantBlue : AppColors.slate700,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isJoined
                          ? const Color(0xFFF1F5F9)
                          : AppColors.vibrantBlue,
                      foregroundColor: isJoined
                          ? AppColors.slate800
                          : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      minimumSize: const Size(54, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isJoined ? 'Joined' : 'Join',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _shareAppGroups(BuildContext context) {
    const String shareText =
        'Explore and join Desi Connect community groups: https://desiconnect.com/groups';

    Clipboard.setData(const ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Groups link copied to clipboard!'),
        backgroundColor: AppColors.vibrantBlue,
        duration: Duration(seconds: 2),
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
                const Text(
                  'Share Community Groups',
                  style: TextStyle(
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
                      const Expanded(
                        child: Text(
                          shareText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
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
