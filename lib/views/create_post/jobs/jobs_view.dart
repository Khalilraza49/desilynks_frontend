import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/models/job_model.dart';
import 'package:desilynks/models/need_worker_model.dart';
import 'package:desilynks/models/need_worker_enums.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/need_worker_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';

class JobsView extends StatelessWidget {
  const JobsView({super.key});

  void _navigateToFilters(BuildContext context) async {
    final roomViewModel = Provider.of<PostRoomViewModel>(
      context,
      listen: false,
    );
    final jobsViewModel = Provider.of<JobsViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userLocation = jobsViewModel.getUserLocationLabel(authViewModel);

    roomViewModel.enterFiltersScreen(
      initialCategory: 'Jobs',
      defaultLocation: userLocation,
    );
    final result = await Navigator.pushNamed(context, AppRoutes.filters);
    if (!context.mounted) return;

    if (result == true || roomViewModel.isFilterApplied) {
      if (roomViewModel.appliedJobTypes.isNotEmpty) {
        final selectedType = roomViewModel.appliedJobTypes.first;
        jobsViewModel.onFilterSelected(selectedType);
      } else {
        jobsViewModel.onFilterSelected('All');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final jobsViewModel = context.watch<JobsViewModel>();

    if (!jobsViewModel.hasLoadedJobsView && !jobsViewModel.isLoadingJobsView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        jobsViewModel.initializeJobsView(
          authVM: context.read<AuthViewModel>(),
          needWorkerVM: context.read<NeedWorkerViewModel>(),
        );
      });
    }

    final jobs = jobsViewModel.getSortedJobs(authViewModel);
    final locationLabel = jobsViewModel.getUserLocationLabel(authViewModel);
    final selectedViewMode = jobsViewModel.selectedViewMode;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: AppConstants.elevationNone,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.assetBackArrowSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate400,
              BlendMode.srcIn,
            ),
            width: context.scale(20).clamp(18.0, 24.0),
            height: context.scale(20).clamp(18.0, 24.0),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Provider.of<NavigationViewModel>(
                context,
                listen: false,
              ).setIndex(0);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jobs',
              style: TextStyle(
                color: AppColors.slate800,
                fontSize: context.sp(20).clamp(18.0, 22.0),
                fontWeight: FontWeight.bold,
                fontFamily: AppStrings.fontInter,
              ),
            ),
            Row(
              children: [
                SvgPicture.asset(
                  AppIcons.locationSvg,
                  colorFilter: const ColorFilter.mode(
                    AppColors.slate400,
                    BlendMode.srcIn,
                  ),
                  width: context.scale(12).clamp(10.0, 14.0),
                  height: context.scale(12).clamp(10.0, 14.0),
                ),
                SizedBox(width: context.scale(4).clamp(2.0, 6.0)),
                Flexible(
                  child: Text(
                    locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.slate500.withValues(alpha: 0.8),
                      fontSize: context.sp(12).clamp(11.0, 13.0),
                      fontWeight: FontWeight.w500,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.searchSvg,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.textLightGray,
                  BlendMode.srcIn,
                ),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          IconButton(
            tooltip: 'Filter',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.filterSvg,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.textLightGray,
                  BlendMode.srcIn,
                ),
              ),
            ),
            onPressed: () => _navigateToFilters(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(context.scale(104).clamp(96.0, 114.0)),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              bottom: context.scale(12).clamp(10.0, 14.0),
              left: context.hMargin,
              right: context.hMargin,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    // Mode Toggle: Job Vacancies vs Work Requests
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => jobsViewModel.setSelectedViewMode(0),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.scale(8).clamp(6.0, 10.0),
                              ),
                              decoration: BoxDecoration(
                                color: selectedViewMode == 0
                                    ? AppColors.vibrantBlue
                                    : AppColors.slate100,
                                borderRadius: BorderRadius.circular(
                                  context.scale(10).clamp(8.0, 12.0),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Job Vacancies',
                                style: TextStyle(
                                  color: selectedViewMode == 0
                                      ? Colors.white
                                      : AppColors.slate700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.sp(13).clamp(12.0, 14.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              jobsViewModel.setSelectedViewMode(1);
                              final needWorkerVM =
                                  Provider.of<NeedWorkerViewModel>(
                                    context,
                                    listen: false,
                                  );
                              if (!needWorkerVM.hasFetchedFeed ||
                                  needWorkerVM.feedPosts.isEmpty) {
                                needWorkerVM.fetchFeed(force: true);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.scale(8).clamp(6.0, 10.0),
                              ),
                              decoration: BoxDecoration(
                                color: selectedViewMode == 1
                                    ? AppColors.orangeAccent
                                    : AppColors.slate100,
                                borderRadius: BorderRadius.circular(
                                  context.scale(10).clamp(8.0, 12.0),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Work Requests',
                                style: TextStyle(
                                  color: selectedViewMode == 1
                                      ? Colors.white
                                      : AppColors.slate700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.sp(13).clamp(12.0, 14.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedViewMode == 0) ...[
                      SizedBox(height: context.scale(10).clamp(8.0, 12.0)),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: jobsViewModel.filters.map((filter) {
                            final bool isSelected =
                                jobsViewModel.selectedTab == filter;
                            return Padding(
                              padding: EdgeInsets.only(
                                right: context.scale(8).clamp(6.0, 10.0),
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    jobsViewModel.onFilterSelected(filter),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context
                                        .scale(16)
                                        .clamp(12.0, 20.0),
                                    vertical: context.scale(6).clamp(4.0, 8.0),
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.slate900
                                        : AppColors.white,
                                    borderRadius: BorderRadius.circular(
                                      context.scale(16).clamp(12.0, 20.0),
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.slate900
                                          : AppColors.slate300,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.slate800,
                                      fontSize: context
                                          .sp(13)
                                          .clamp(12.0, 14.0),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: context.scale(10).clamp(8.0, 12.0)),
                      Consumer2<CategoriesViewModel, NeedWorkerViewModel>(
                        builder: (context, catVM, needWorkerVM, _) {
                          final workerTypes = [
                            'All',
                            ...catVM.needWorkerTypes.map((t) => t.title),
                          ];
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: workerTypes.map((type) {
                                final isSelected =
                                    needWorkerVM.feedWorkerTypeFilter
                                        .toLowerCase() ==
                                    type.toLowerCase();
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: context.scale(8).clamp(6.0, 10.0),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => needWorkerVM
                                        .setFeedWorkerTypeFilter(type),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context
                                            .scale(16)
                                            .clamp(12.0, 20.0),
                                        vertical: context
                                            .scale(6)
                                            .clamp(4.0, 8.0),
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.orangeAccent
                                            : AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                          context.scale(16).clamp(12.0, 20.0),
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.orangeAccent
                                              : AppColors.slate300,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.white
                                              : AppColors.slate800,
                                          fontSize: context
                                              .sp(13)
                                              .clamp(12.0, 14.0),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: selectedViewMode == 0
              ? (jobsViewModel.isLoading && jobs.isEmpty
                    ? const JobsSkeleton()
                    : jobs.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () => jobsViewModel.fetchPublicJobs(),
                        color: AppColors.vibrantBlue,
                        backgroundColor: AppColors.backgroundOffWhite,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: context.scale(120).clamp(80.0, 140.0),
                            ),
                            Center(
                              child: Text(
                                'No jobs found matching your criteria.',
                                style: TextStyle(
                                  color: AppColors.slate500,
                                  fontSize: context.sp(14).clamp(13.0, 16.0),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => jobsViewModel.fetchPublicJobs(),
                        color: AppColors.vibrantBlue,
                        backgroundColor: AppColors.backgroundOffWhite,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.hMargin,
                            vertical: context.scale(16).clamp(12.0, 20.0),
                          ),
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            return _buildJobCard(context, job, jobsViewModel);
                          },
                        ),
                      ))
              : Consumer<NeedWorkerViewModel>(
                  builder: (context, needWorkerVM, child) {
                    final posts = needWorkerVM.getSortedNeedWorkers(
                      authViewModel,
                    );
                    if (needWorkerVM.isLoading && posts.isEmpty) {
                      return const JobsSkeleton();
                    }
                    if (posts.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => needWorkerVM.fetchFeed(force: true),
                        color: AppColors.orangeAccent,
                        backgroundColor: AppColors.backgroundOffWhite,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: context.scale(120).clamp(80.0, 140.0),
                            ),
                            Center(
                              child: Text(
                                'No work requests available right now.',
                                style: TextStyle(
                                  color: AppColors.slate500,
                                  fontSize: context.sp(14).clamp(13.0, 16.0),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => needWorkerVM.fetchFeed(force: true),
                      color: AppColors.orangeAccent,
                      backgroundColor: AppColors.backgroundOffWhite,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.hMargin,
                          vertical: context.scale(16).clamp(12.0, 20.0),
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return _buildNeedWorkerCard(context, post);
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    JobModel job,
    JobsViewModel viewModel,
  ) {
    final bool isApplied = viewModel.isUserAppliedToJob(job.id);
    final double avatarSize = context.scale(60).clamp(48.0, 64.0);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.jobDetail, arguments: job);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: context.scale(16).clamp(12.0, 18.0)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            context.scale(16).clamp(12.0, 18.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(context.cardPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon/Avatar Placeholder or Job Poster
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(
                        context.scale(12).clamp(10.0, 14.0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: (job.posterUrl != null && job.posterUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              context.scale(12).clamp(10.0, 14.0),
                            ),
                            child: Image.network(
                              job.posterUrl!,
                              width: avatarSize,
                              height: avatarSize,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  SvgPicture.asset(
                                    AppIcons.error_imageSvg,
                                    width: context.scale(28).clamp(24.0, 32.0),
                                    height: context.scale(28).clamp(24.0, 32.0),
                                  ),
                            ),
                          )
                        : SvgPicture.asset(
                            AppIcons.businessSvg,
                            width: context.scale(28).clamp(24.0, 32.0),
                            height: context.scale(28).clamp(24.0, 32.0),
                            colorFilter: const ColorFilter.mode(
                              AppColors.vibrantBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                  SizedBox(width: context.scale(14).clamp(10.0, 16.0)),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(
                            fontSize: context.sp(16).clamp(14.0, 18.0),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: context.scale(4).clamp(3.0, 6.0)),
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.businessSvg,
                              width: context.scale(14).clamp(12.0, 16.0),
                              height: context.scale(14).clamp(12.0, 16.0),
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate400,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: context.scale(4).clamp(3.0, 6.0)),
                            Expanded(
                              child: Text(
                                job.companyName,
                                style: TextStyle(
                                  fontSize: context.sp(13).clamp(11.0, 14.0),
                                  color: AppColors.slate500,
                                  fontFamily: 'Inter',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.scale(4).clamp(3.0, 6.0)),
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.locationSvg,
                              width: context.scale(14).clamp(12.0, 16.0),
                              height: context.scale(14).clamp(12.0, 16.0),
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate400,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: context.scale(4).clamp(3.0, 6.0)),
                            Expanded(
                              child: Text(
                                job.location,
                                style: TextStyle(
                                  fontSize: context.sp(13).clamp(11.0, 14.0),
                                  color: AppColors.slate500,
                                  fontFamily: 'Inter',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Job Type Chip
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scale(10).clamp(8.0, 12.0),
                          vertical: context.scale(4).clamp(3.0, 5.0),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(
                            context.scale(12).clamp(10.0, 14.0),
                          ),
                        ),
                        child: Text(
                          job.type.displayName,
                          style: TextStyle(
                            color: AppColors.emerald,
                            fontSize: context.sp(11).clamp(10.0, 12.0),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      SizedBox(height: context.scale(4).clamp(3.0, 6.0)),
                      // Work Mode Chip
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scale(8).clamp(6.0, 10.0),
                          vertical: context.scale(2).clamp(2.0, 4.0),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(
                            context.scale(8).clamp(6.0, 10.0),
                          ),
                        ),
                        child: Text(
                          job.workMode.displayName,
                          style: TextStyle(
                            color: const Color(0xFF7C3AED),
                            fontSize: context.sp(10).clamp(9.0, 11.0),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: context.scale(12).clamp(8.0, 14.0)),
              Divider(
                color: Colors.black.withValues(alpha: 0.1),
                height: 1,
                thickness: 1,
              ),
              SizedBox(height: context.scale(12).clamp(8.0, 14.0)),
              // Salary and Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '€${job.salary} / ${job.salaryPeriod.displayName}',
                      style: TextStyle(
                        fontSize: context.sp(14).clamp(12.0, 15.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.vibrantBlue,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.jobDetail,
                        arguments: job,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApplied
                          ? AppColors.slate300
                          : AppColors.vibrantBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          context.scale(8).clamp(6.0, 10.0),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scale(12).clamp(10.0, 16.0),
                        vertical: context.scale(6).clamp(5.0, 8.0),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isApplied ? 'Applied' : 'Apply Now',
                        style: TextStyle(
                          fontSize: context.sp(13).clamp(12.0, 14.0),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
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
    );
  }

  Widget _buildNeedWorkerCard(BuildContext context, NeedWorkerModel post) {
    final tradeName = WorkerTypeX.fromString(post.workerType).displayName;
    final budgetTypeName = BudgetTypeX.fromString(post.budgetType).displayName;
    final double avatarSize = context.scale(56).clamp(46.0, 60.0);

    return Container(
      margin: EdgeInsets.only(bottom: context.scale(16).clamp(12.0, 18.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          context.scale(16).clamp(12.0, 18.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(context.cardPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(
                      context.scale(12).clamp(10.0, 14.0),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AppIcons.workerHelmetSvg,
                    width: context.scale(28).clamp(24.0, 32.0),
                    height: context.scale(28).clamp(24.0, 32.0),
                  ),
                ),
                SizedBox(width: context.scale(14).clamp(10.0, 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need $tradeName',
                        style: TextStyle(
                          fontSize: context.sp(16).clamp(14.0, 18.0),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: context.scale(4).clamp(3.0, 6.0)),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.personSvg,
                            width: context.scale(14).clamp(12.0, 16.0),
                            height: context.scale(14).clamp(12.0, 16.0),
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate400,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: context.scale(4).clamp(3.0, 6.0)),
                          Expanded(
                            child: Text(
                              post.requester?.fullName.isNotEmpty == true
                                  ? post.requester!.fullName
                                  : 'Client Request',
                              style: TextStyle(
                                fontSize: context.sp(13).clamp(11.0, 14.0),
                                color: AppColors.slate500,
                                fontFamily: 'Inter',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.scale(4).clamp(3.0, 6.0)),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.locationSvg,
                            width: context.scale(14).clamp(12.0, 16.0),
                            height: context.scale(14).clamp(12.0, 16.0),
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate400,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: context.scale(4).clamp(3.0, 6.0)),
                          Expanded(
                            child: Text(
                              post.location,
                              style: TextStyle(
                                fontSize: context.sp(13).clamp(11.0, 14.0),
                                color: AppColors.slate500,
                                fontFamily: 'Inter',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                if (post.isUrgentRequest)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(8).clamp(6.0, 10.0),
                      vertical: context.scale(3).clamp(2.0, 4.0),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(
                        context.scale(8).clamp(6.0, 10.0),
                      ),
                    ),
                    child: Text(
                      'URGENT',
                      style: TextStyle(
                        color: const Color(0xFFEF4444),
                        fontSize: context.sp(10).clamp(9.0, 11.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.scale(12).clamp(8.0, 14.0)),
            Text(
              post.description,
              style: TextStyle(
                fontSize: context.sp(13).clamp(12.0, 14.0),
                color: AppColors.slate600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.scale(12).clamp(8.0, 14.0)),
            Divider(
              color: Colors.black.withValues(alpha: 0.1),
              height: 1,
              thickness: 1,
            ),
            SizedBox(height: context.scale(12).clamp(8.0, 14.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '€${post.budget} / $budgetTypeName',
                    style: TextStyle(
                      fontSize: context.sp(15).clamp(13.0, 16.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.orangeAccent,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.applyNeedWorkerForm,
                      arguments: post,
                    );
                  },
                  icon: SvgPicture.asset(
                    AppIcons.sendSvg,
                    width: context.scale(14).clamp(12.0, 16.0),
                    height: context.scale(14).clamp(12.0, 16.0),
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Apply Now',
                      style: TextStyle(
                        fontSize: context.sp(13).clamp(12.0, 14.0),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        context.scale(8).clamp(6.0, 10.0),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(14).clamp(10.0, 16.0),
                      vertical: context.scale(6).clamp(5.0, 8.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
