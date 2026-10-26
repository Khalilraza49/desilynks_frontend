import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/models/job_model.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';
import 'package:desilynks/views/chat/chat_view.dart';
import 'package:desilynks/widgets/coming_soon_dialog.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class MyJobsView extends StatelessWidget {
  const MyJobsView({super.key});

  String _formatDate(DateTime dt) {
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
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final jobsViewModel = Provider.of<JobsViewModel>(context, listen: false);
      jobsViewModel.initUserJobs();
    });

    final jobsViewModel = Provider.of<JobsViewModel>(context);
    final userJobs = jobsViewModel.userJobs;
    final filteredJobs = jobsViewModel.filteredUserJobs;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 12),
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppColors.slate800,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 8,
        title: const Text(
          'My Jobs',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.myApplications);
            },
            icon: SvgPicture.asset(
              AppIcons.sendSvg,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.vibrantBlue,
                BlendMode.srcIn,
              ),
            ),
            label: const Text(
              'My Applications',
              style: TextStyle(
                color: AppColors.vibrantBlue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.slate200, height: 1.0),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Tabs (Active, Pending, Expired)
              _buildFilterTabs(jobsViewModel, context),

              // Jobs List
              Expanded(
                child: jobsViewModel.isLoading && userJobs.isEmpty
                    ? const ListSkeleton(showTabs: false)
                    : jobsViewModel.errorMessage != null && userJobs.isEmpty
                        ? _buildErrorState(context, jobsViewModel)
                        : RefreshIndicator(
                            backgroundColor: AppColors.backgroundOffWhite,
                            color: AppColors.vibrantBlue,
                            onRefresh: () async {
                              await jobsViewModel.initUserJobs(force: true);
                            },
                            child: filteredJobs.isEmpty
                                ? _buildEmptyState(
                                    context,
                                    jobsViewModel.myJobsSelectedTab == 'All'
                                        ? 'No jobs posted yet.'
                                        : 'No ${jobsViewModel.myJobsSelectedTab.toLowerCase()} jobs found.',
                                  )
                                : ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.hMargin,
                                      vertical: context.scaleH(8),
                                    ),
                                    itemCount: filteredJobs.length,
                                    itemBuilder: (context, index) {
                                      return _buildJobCard(
                                        context,
                                        filteredJobs[index],
                                        jobsViewModel,
                                      );
                                    },
                                  ),
                          ),
              ),

              // Pinned Bottom Button
              Padding(
                padding: EdgeInsets.only(
                  left: context.hMargin,
                  right: context.hMargin,
                  bottom: context.scaleH(24.0),
                  top: context.scaleH(8),
                ),
                child: CustomButton(
                  text: 'Post New Job',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.postJob).then((_) {
                      if (context.mounted) {
                        jobsViewModel.initUserJobs(force: true);
                      }
                    });
                  },
                  backgroundColor: AppColors.vibrantBlue,
                  height: context.scaleH(52.0),
                  borderRadius: 12,
                  svgAsset: AppIcons.plusSvg,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(JobsViewModel jobsViewModel, BuildContext context) {
    final tabs = ['All', 'Active', 'Pending', 'Expired'];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: context.scaleH(12),
        horizontal: context.hMargin,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs.map((tab) {
          final bool isSelected = jobsViewModel.myJobsSelectedTab == tab;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.scale(4.0)),
              child: InkWell(
                onTap: () => jobsViewModel.setMyJobsSelectedTab(tab),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: context.scaleH(8)),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.vibrantBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.slate200, width: 1.0),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.slate600,
                      fontSize: context.sp(14),
                      fontFamily: "Inter",
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.hMargin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.briefcaseSvg,
                      width: context.scale(64.0),
                      height: context.scale(64.0),
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate300,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: context.scaleH(12)),
                    Text(
                      message,
                      style: TextStyle(
                        color: AppColors.slate500,
                        fontSize: context.sp(15),
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, JobsViewModel jobsViewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.hMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.primaryRed,
            ),
            const SizedBox(height: 12),
            Text(
              jobsViewModel.errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.slate600,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => jobsViewModel.initUserJobs(force: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    JobModel job,
    JobsViewModel jobsViewModel,
  ) {
    final String salaryRange =
        "€${job.salary}/${job.salaryPeriod.displayName.toLowerCase().replaceAll('per ', '')}";
    final String dateStr = _formatDate(job.createdAt);

    String statusText = 'Active';
    Color statusBgColor = const Color(0xFFD1FAE5); // Light green pill
    Color statusTextColor = const Color(0xFF059669); // Emerald text

    if (job.status == JobStatus.pending) {
      statusText = 'Pending';
      statusBgColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFD97706);
    } else if (job.status == JobStatus.closed ||
        job.status == JobStatus.archived) {
      statusText = 'Expired';
      statusBgColor = const Color(0xFFF3F4F6);
      statusTextColor = const Color(0xFF6B7280);
    }

    // Stats calculations from real job data
    final int viewsCount = job.viewsCount;
    final int applicantsCount =
        (jobsViewModel.fetchedJobApplicationsId == job.id &&
            jobsViewModel.jobApplications.isNotEmpty)
        ? jobsViewModel.jobApplications.length
        : job.applicantsCount;
    final int chatsCount = job.chatsCount;

    final posterSize = context.scale(50.0);

    return Container(
      margin: EdgeInsets.only(bottom: context.scaleH(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Top Section matching mockup
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.jobDetail,
                arguments: job,
              ).then((_) {
                if (context.mounted) {
                  jobsViewModel.initUserJobs(force: true);
                }
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(context.cardPad),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (job.posterUrl != null && job.posterUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        job.posterUrl!,
                        width: posterSize,
                        height: posterSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    SizedBox(width: context.scale(12)),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(
                            fontSize: context.sp(16),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                            fontFamily: "Inter",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.companyName,
                          style: TextStyle(
                            fontSize: context.sp(13),
                            color: const Color(0xFF6B7280),
                            fontFamily: "Inter",
                          ),
                        ),
                        SizedBox(height: context.scaleH(6)),
                        Text(
                          salaryRange,
                          style: TextStyle(
                            fontSize: context.sp(14),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2563EB),
                            fontFamily: "Inter",
                          ),
                        ),
                        SizedBox(height: context.scaleH(6)),
                        Text(
                          "Posted on: $dateStr",
                          style: TextStyle(
                            fontSize: context.sp(12),
                            color: const Color(0xFF6B7280),
                            fontFamily: "Inter",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scale(10),
                          vertical: context.scaleH(4),
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusTextColor,
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.bold,
                            fontFamily: "Inter",
                          ),
                        ),
                      ),
                      SizedBox(height: context.scaleH(16)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.editJob,
                            arguments: job,
                          ).then((_) {
                            if (context.mounted) {
                              jobsViewModel.initUserJobs(force: true);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(context.scale(6)),
                          decoration: const BoxDecoration(
                            color: AppColors.slate100,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.editSvg,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate600,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // 2. Middle Stats Row (Views: Black, Saved: Red, Chats: Green)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.scaleH(12)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$viewsCount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: context.sp(16),
                          color: const Color(0xFF111827),
                          fontFamily: "Inter",
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.eyeSvg,
                            width: 14,
                            height: 14,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF6B7280),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Views',
                            style: TextStyle(
                              fontSize: context.sp(12),
                              color: const Color(0xFF6B7280),
                              fontFamily: "Inter",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.applicants,
                        arguments: job,
                      ).then((_) {
                        if (context.mounted) {
                          jobsViewModel.initUserJobs(force: true);
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          '$applicantsCount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: context.sp(16),
                            color: const Color(0xFFEF4444),
                            fontFamily: "Inter",
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.personSvg,
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF6B7280),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Applicants',
                              style: TextStyle(
                                fontSize: context.sp(12),
                                color: const Color(0xFF6B7280),
                                fontFamily: "Inter",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatView()),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          '$chatsCount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: context.sp(16),
                            color: const Color(0xFF10B981),
                            fontFamily: "Inter",
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.chatRoundSvg,
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF6B7280),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Chats',
                              style: TextStyle(
                                fontSize: context.sp(12),
                                color: const Color(0xFF6B7280),
                                fontFamily: "Inter",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pending Alert Banner
          if (statusText == 'Pending')
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                left: context.scale(12),
                right: context.scale(12),
                bottom: context.scaleH(8),
              ),
              padding: EdgeInsets.symmetric(
                vertical: context.scaleH(8),
                horizontal: context.scale(12),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.TimerSvg,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFD97706),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Under review — usually takes 24 hours',
                    style: TextStyle(
                      fontSize: context.sp(12),
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.w500,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // 3. Action Buttons Row (View, Applicants, Boost, Del)
          Padding(
            padding: EdgeInsets.all(context.scale(12)),
            child: Row(
              children: [
                _buildActionButton(
                  context: context,
                  label: 'View',
                  svgIcon: AppIcons.eyeSvg,
                  bgColor: const Color(0xFFEFF6FF),
                  textColor: const Color(0xFF2563EB),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.jobDetail,
                      arguments: job,
                    ).then((_) {
                      if (context.mounted) {
                        jobsViewModel.initUserJobs(force: true);
                      }
                    });
                  },
                ),
                SizedBox(width: context.scale(8)),
                _buildActionButton(
                  context: context,
                  label: 'Applicants',
                  svgIcon: AppIcons.personSvg,
                  bgColor: const Color(0xFFECFDF5),
                  textColor: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.applicants,
                      arguments: job,
                    ).then((_) {
                      if (context.mounted) {
                        jobsViewModel.initUserJobs(force: true);
                      }
                    });
                  },
                ),
                SizedBox(width: context.scale(8)),
                _buildActionButton(
                  context: context,
                  label: 'Boost',
                  svgIcon: AppIcons.boostRocketSvg,
                  bgColor: const Color(0xFFFFF7ED),
                  textColor: const Color(0xFFF97316),
                  onTap: () {
                    ComingSoonDialog.show(
                      context,
                      title: 'Coming Soon',
                      featureName: 'Job Boost',
                      svgIcon: AppIcons.boostRocketSvg,
                      badgeColor: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFF97316),
                      message:
                          'Job Boost is currently under development. Soon you will be able to boost your job listings to reach more candidates!',
                    );
                  },
                ),
                SizedBox(width: context.scale(8)),
                _buildActionButton(
                  context: context,
                  label: 'Del',
                  svgIcon: AppIcons.deleteSvg,
                  bgColor: const Color(0xFFFEF2F2),
                  textColor: const Color(0xFFEF4444),
                  onTap: () async {
                    final confirm = await _showDeleteConfirmDialog(
                      context: context,
                      isProperty: false,
                    );
                    if (confirm == true) {
                      final success = await jobsViewModel.deleteJob(job.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Job deleted successfully!'
                                  : (jobsViewModel.errorMessage ??
                                        'Failed to delete job'),
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required String svgIcon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: context.scaleH(8),
            horizontal: context.scale(2),
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  svgIcon,
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog({
    required BuildContext context,
    required bool isProperty,
  }) {
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
                  child: SvgPicture.asset(
                    AppIcons.deleteSvg,
                    width: 36,
                    height: 36,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFEF4444),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isProperty ? 'Delete This Ad?' : 'Delete This Job?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isProperty
                      ? 'All information including pictures will be permanently deleted. This cannot be undone.'
                      : 'All information including applicant data will be permanently deleted. This cannot be undone.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: isProperty ? 'Yes, Delete Ad' : 'Yes, Delete Job',
                  onPressed: () => Navigator.pop(ctx, true),
                  backgroundColor: const Color(0xFFEF4444),
                  height: 48,
                  borderRadius: 12,
                  svgAsset: AppIcons.deleteSvg,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(ctx, false),
                  backgroundColor: const Color(0xFFF3F4F6),
                  textColor: const Color(0xFF374151),
                  height: 48,
                  borderRadius: 12,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
