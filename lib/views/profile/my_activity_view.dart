import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/my_activity_viewmodel.dart';
import 'package:desilynks/widgets/custom_bottom_navigation.dart';

class MyActivityView extends StatelessWidget {
  const MyActivityView({super.key});

  Future<void> _fetchAllActivities(BuildContext context) async {
    final activityVM = Provider.of<MyActivityViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final jobsVM = Provider.of<JobsViewModel>(context, listen: false);

    if (authVM.isAuthenticated) {
      if (authVM.currentUser == null && !authVM.isLoading) {
        authVM.fetchUserProfile();
      }
      await Future.wait([
        activityVM.fetchActivities(),
        jobsVM.fetchApplicantApplications(),
      ]);
    }
  }

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
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final activityVM = Provider.of<MyActivityViewModel>(context, listen: false);
      if (!activityVM.hasFetched && !activityVM.isLoading) {
        _fetchAllActivities(context);
      }
    });

    final viewModel = Provider.of<MyActivityViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final jobsViewModel = Provider.of<JobsViewModel>(context);

    // Current user info
    final user = authViewModel.currentUser;
    final String userName = user != null && user.firstName.isNotEmpty
        ? '${user.firstName} ${user.lastName ?? ''}'.trim()
        : 'Guest User';
    final String? userPhotoUrl = user?.profilePhotoUrl;

    // Convert real backend job applications into MyActivityItem instances
    final List<MyActivityItem>
    realAppActivities = jobsViewModel.applicantApplications.map((app) {
      final jobTitle = app.job?.title ?? 'Job Position';
      return MyActivityItem(
        title: 'You applied for $jobTitle',
        time:
            '${_formatTimeAgo(app.createdAt)} · Status: ${app.status.displayName}',
        icon: AppIcons.send2,
        iconColor: AppColors.primaryPurple,
        iconBgColor: AppColors.violetLight,
        category: 'Application',
        jobId: app.jobId,
        applicationId: app.id,
      );
    }).toList();

    // Merge real activities with job applications
    final List<MyActivityItem> todayItems = [
      ...realAppActivities,
      ...viewModel.todayActivities,
    ];
    final List<MyActivityItem> yesterdayItems = viewModel.yesterdayActivities;

    final filteredToday = viewModel.filterActivities(todayItems);
    final filteredYesterday = viewModel.filterActivities(yesterdayItems);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add option coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: AppColors.vibrantBlue,
        shape: const CircleBorder(),
        elevation: 6,
        child: SvgPicture.asset(
          AppIcons.assetaddSvg,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          height: 32,
          width: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            Navigator.pop(context);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header (Fixed at the top)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.hMargin,
                vertical: (context.scaleH(8.0)).clamp(6.0, 12.0),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.assetBackArrow,
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'My Activity',
                    style: TextStyle(
                      color: AppColors.slate800,
                      fontSize: context.sp(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Divider(
              thickness: 1,
              color: AppColors.black.withValues(alpha: 0.1),
            ),

            // Fixed Header (Profile Card & Filter Chips - Pinned at top)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.hMargin,
                    (context.scaleH(12.0)).clamp(8.0, 16.0),
                    context.hMargin,
                    16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Section Card
                      Container(
                        padding: EdgeInsets.all(context.cardPad),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                          border: Border.all(color: AppColors.blackOpacity4),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.blackOpacity4,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.shade50,
                              ),
                              child: ClipOval(
                                child:
                                    userPhotoUrl != null &&
                                        userPhotoUrl.isNotEmpty
                                    ? Image.network(
                                        userPhotoUrl,
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                SvgPicture.asset(
                                                  AppIcons.assetPerson,
                                                  fit: BoxFit.cover,
                                                ),
                                      )
                                    : SvgPicture.asset(
                                        AppIcons.assetPerson,
                                        fit: BoxFit.cover,
                                      ),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray800,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  InkWell(
                                    onTap: () {
                                      if (user != null) {
                                        final owner = PropertyOwner(
                                          id: user.id,
                                          firstName: user.firstName,
                                          lastName: user.lastName ?? '',
                                          profilePhotoUrl: user.profilePhotoUrl,
                                          createdAt: user.createdAt ?? '',
                                          email: user.email,
                                          phoneNumber: user.phoneNumber,
                                        );
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.publicProfile,
                                          arguments: owner,
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'View Public Profile',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.vibrantBlue,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Filter horizontal list chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTabChip(context, viewModel, 'All'),
                            const SizedBox(width: 8),
                            _buildTabChip(context, viewModel, 'Posts'),
                            const SizedBox(width: 8),
                            _buildTabChip(context, viewModel, 'Comments'),
                            const SizedBox(width: 8),
                            _buildTabChip(context, viewModel, 'Application'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Content (Activities Feed)
            Expanded(
              child: viewModel.isLoading && !viewModel.hasFetched
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.vibrantBlue,
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.vibrantBlue,
                      onRefresh: () => _fetchAllActivities(context),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                context.hMargin,
                                8.0,
                                context.hMargin,
                                (context.scaleH(12.0)).clamp(8.0, 16.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // TODAY Section List
                                  if (filteredToday.isNotEmpty) ...[
                                    const Text(
                                      'TODAY / RECENT',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gray400,
                                        letterSpacing: 1.1,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: filteredToday.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 14),
                                      itemBuilder: (context, index) {
                                        return _buildActivityItemCard(
                                          context,
                                          filteredToday[index],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  // YESTERDAY Section List
                                  if (filteredYesterday.isNotEmpty) ...[
                                    const Text(
                                      'YESTERDAY',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gray400,
                                        letterSpacing: 1.1,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: filteredYesterday.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 14),
                                      itemBuilder: (context, index) {
                                        return _buildActivityItemCard(
                                          context,
                                          filteredYesterday[index],
                                        );
                                      },
                                    ),
                                  ],

                                  if (filteredToday.isEmpty &&
                                      filteredYesterday.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 40.0,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              AppIcons.history,
                                              height: 48,
                                              width: 48,
                                              colorFilter: ColorFilter.mode(
                                                Colors.grey.shade400,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No activities found in "${viewModel.selectedTab}"',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500],
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 80),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(
    BuildContext context,
    MyActivityViewModel viewModel,
    String title,
  ) {
    final bool isSelected = viewModel.selectedTab == title;
    return GestureDetector(
      onTap: () {
        viewModel.setSelectedTab(title);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (context.scale(11)).clamp(9.0, 14.0),
          vertical: (context.scaleH(5)).clamp(4.0, 7.0),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vibrantBlue : Colors.white,
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadiusLarge + 2,
          ),
          border: Border.all(
            color: isSelected ? AppColors.vibrantBlue : AppColors.gray200,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.gray800,
            fontSize: context.sp(14),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItemCard(BuildContext context, MyActivityItem item) {
    final double iconBoxSize = (context.scale(40)).clamp(34.0, 46.0);
    final double svgSize = (context.scale(20)).clamp(16.0, 22.0);

    return GestureDetector(
      onTap: () {
        if (item.category == 'Application') {
          // Open My Job Applications view for full details & application status
          Navigator.pushNamed(context, AppRoutes.myApplications);
        }
      },
      child: Container(
        padding: EdgeInsets.all(context.cardPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                border: Border.all(color: AppColors.blackOpacity4, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.blackOpacity4,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  item.icon,
                  colorFilter: ColorFilter.mode(
                    item.iconColor,
                    BlendMode.srcIn,
                  ),
                  height: svgSize,
                  width: svgSize,
                ),
              ),
            ),
            SizedBox(width: (context.scale(12)).clamp(8.0, 14.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.time,
                    style: TextStyle(
                      fontSize: context.sp(11),
                      color: AppColors.gray400,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              AppIcons.calrightArrow,
              colorFilter: ColorFilter.mode(
                AppColors.gray400.withValues(alpha: 0.7),
                BlendMode.srcIn,
              ),
              height: 14,
              width: 14,
            ),
          ],
        ),
      ),
    );
  }
}
