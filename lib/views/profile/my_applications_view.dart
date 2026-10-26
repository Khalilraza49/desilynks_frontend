import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/models/job_application_model.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class MyApplicationsView extends StatelessWidget {
  const MyApplicationsView({super.key});

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

  Color _statusColor(JobApplicationStatus status) {
    switch (status) {
      case JobApplicationStatus.pending:
        return const Color(0xFFF59E0B);
      case JobApplicationStatus.reviewing:
        return const Color(0xFF3B82F6);
      case JobApplicationStatus.shortlisted:
        return const Color(0xFF8B5CF6);
      case JobApplicationStatus.interview:
        return const Color(0xFF06B6D4);
      case JobApplicationStatus.offered:
        return const Color(0xFF10B981);
      case JobApplicationStatus.rejected:
        return const Color(0xFFEF4444);
      case JobApplicationStatus.withdrawn:
        return const Color(0xFF6B7280);
    }
  }

  String _statusIcon(JobApplicationStatus status) {
    switch (status) {
      case JobApplicationStatus.pending:
        return AppIcons.TimerSvg;
      case JobApplicationStatus.reviewing:
        return AppIcons.eyeSvg;
      case JobApplicationStatus.shortlisted:
        return AppIcons.starFavoriteSvg;
      case JobApplicationStatus.interview:
        return AppIcons.calendarSvg;
      case JobApplicationStatus.offered:
        return AppIcons.tickCircleSvg;
      case JobApplicationStatus.rejected:
        return AppIcons.crossSmallSvg;
      case JobApplicationStatus.withdrawn:
        return AppIcons.arrowBackSvg;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final vm = Provider.of<JobsViewModel>(context, listen: false);
      vm.initApplicantApplications();
    });

    final vm = Provider.of<JobsViewModel>(context);
    final allApplications = vm.applicantApplications;
    final stats = vm.applicantStats;
    final filteredApplications = vm.filteredApplicantApplications;

    return Scaffold(
      backgroundColor: AppColors.slate50,
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
        title: Text(
          'My Job Applications',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: context.sp(20),
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.slate200, height: 1.0),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: RefreshIndicator(
            backgroundColor: AppColors.backgroundOffWhite,
            color: AppColors.vibrantBlue,
            onRefresh: () async {
              await vm.initApplicantApplications(force: true);
            },
            child: Column(
              children: [
                // Application Stats Card (from /job/applications/stats/me API)
                if (stats != null) _buildStatsCard(context, stats),

                // Status Filter Chips
                _buildFilterChips(context, vm, allApplications, stats),

                SizedBox(height: context.scaleH(8).clamp(4.0, 10.0)),

                // Applications List
                Expanded(
                  child: vm.isLoading && allApplications.isEmpty
                      ? const ListSkeleton(showTabs: false)
                      : filteredApplications.isEmpty
                      ? _buildEmptyState(context, vm.applicationsFilter)
                      : _buildApplicationsList(
                          context,
                          filteredApplications,
                          vm,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, ApplicationStatsModel stats) {
    return Container(
      margin: EdgeInsets.all(context.hMargin),
      padding: EdgeInsets.all(context.cardPad),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF014EF3), Color(0xFF6B21A8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF014EF3).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  AppIcons.sendSvg,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: context.scale(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.total}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.sp(24),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Inter",
                      ),
                    ),
                    Text(
                      'Total Applications Sent',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: context.sp(12),
                        fontFamily: "Inter",
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaleH(16).clamp(12.0, 20.0)),

          // Mini stats grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStatMetric(
                  context,
                  'Pending',
                  stats.pending,
                  const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _buildStatMetric(
                  context,
                  'Reviewing',
                  stats.reviewing,
                  const Color(0xFF3B82F6),
                ),
              ),
              Expanded(
                child: _buildStatMetric(
                  context,
                  'Shortlisted',
                  stats.shortlisted,
                  const Color(0xFF8B5CF6),
                ),
              ),
              Expanded(
                child: _buildStatMetric(
                  context,
                  'Selected',
                  stats.offered,
                  const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildStatMetric(
                  context,
                  'Rejected',
                  stats.rejected,
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.scale(6).clamp(4.0, 8.0),
            vertical: context.scaleH(4).clamp(3.0, 6.0),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: context.sp(16),
                fontWeight: FontWeight.bold,
                fontFamily: "Inter",
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: context.sp(10),
                fontFamily: "Inter",
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    JobsViewModel vm,
    List<JobApplicationModel> applications,
    ApplicationStatsModel? stats,
  ) {
    return SizedBox(
      height: context.scaleH(40).clamp(36.0, 44.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.hMargin),
        children: [
          _buildFilterChip(
            context,
            vm,
            'All',
            null,
            stats?.total ?? applications.length,
            const Color(0xFF374151),
          ),
          SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
          ...JobApplicationStatus.values.map((status) {
            int count = 0;
            if (stats != null) {
              switch (status) {
                case JobApplicationStatus.pending:
                  count = stats.pending;
                  break;
                case JobApplicationStatus.reviewing:
                  count = stats.reviewing;
                  break;
                case JobApplicationStatus.shortlisted:
                  count = stats.shortlisted;
                  break;
                case JobApplicationStatus.interview:
                  count = stats.interview;
                  break;
                case JobApplicationStatus.offered:
                  count = stats.offered;
                  break;
                case JobApplicationStatus.rejected:
                  count = stats.rejected;
                  break;
                case JobApplicationStatus.withdrawn:
                  count = stats.withdrawn;
                  break;
              }
            } else {
              count = applications.where((a) => a.status == status).length;
            }

            if (count == 0) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(
                right: context.scale(8).clamp(6.0, 10.0),
              ),
              child: _buildFilterChip(
                context,
                vm,
                status.displayName,
                status,
                count,
                _statusColor(status),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    JobsViewModel vm,
    String label,
    JobApplicationStatus? status,
    int count,
    Color color,
  ) {
    final isSelected = vm.applicationsFilter == status;
    return GestureDetector(
      onTap: () {
        vm.setApplicationsFilter(status);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.scale(14).clamp(10.0, 16.0),
          vertical: context.scaleH(6).clamp(4.0, 8.0),
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                fontSize: context.sp(12),
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.bold,
                  fontFamily: "Inter",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    JobApplicationStatus? selectedFilter,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.hMargin,
                  vertical: context.scaleH(24).clamp(16.0, 36.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: context.scale(80).clamp(64.0, 88.0),
                      height: context.scale(80).clamp(64.0, 88.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppIcons.briefcaseSvg,
                          width: context.scale(40).clamp(32.0, 44.0),
                          height: context.scale(40).clamp(32.0, 44.0),
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF9CA3AF),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.scaleH(16).clamp(12.0, 20.0)),
                    Text(
                      selectedFilter != null
                          ? 'No ${selectedFilter.displayName.toLowerCase()} applications'
                          : 'No job applications submitted yet',
                      style: TextStyle(
                        fontSize: context.sp(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                        fontFamily: "Inter",
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.scaleH(8).clamp(6.0, 12.0)),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text(
                        selectedFilter != null
                            ? 'Try selecting a different filter.'
                            : 'Browse available jobs and apply to track your applications here.',
                        style: TextStyle(
                          fontSize: context.sp(13),
                          color: const Color(0xFF9CA3AF),
                          fontFamily: "Inter",
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

  Widget _buildApplicationsList(
    BuildContext context,
    List<JobApplicationModel> applications,
    JobsViewModel vm,
  ) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.hMargin,
        context.scaleH(12).clamp(8.0, 16.0),
        context.hMargin,
        context.scaleH(24).clamp(16.0, 32.0),
      ),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        return _buildApplicationCard(context, app, vm);
      },
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    JobApplicationModel app,
    JobsViewModel vm,
  ) {
    final job = app.job;
    final statusColor = _statusColor(app.status);
    final statusIcon = _statusIcon(app.status);

    return Container(
      margin: EdgeInsets.only(bottom: context.scaleH(12).clamp(8.0, 16.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Job title, Company & Status Badge
          Padding(
            padding: EdgeInsets.all(context.cardPad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job?.title ?? 'Job Position',
                        style: TextStyle(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          fontFamily: "Inter",
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (job?.companyName != null &&
                          job!.companyName.isNotEmpty)
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.briefcaseSvg,
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF6B7280),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                job.companyName,
                                style: TextStyle(
                                  fontSize: context.sp(13),
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Inter",
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(width: context.scale(8).clamp(6.0, 12.0)),

                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(10).clamp(8.0, 12.0),
                    vertical: context.scaleH(5).clamp(3.0, 6.0),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        statusIcon,
                        width: 13,
                        height: 13,
                        colorFilter: ColorFilter.mode(
                          statusColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        app.status.displayName,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Meta row (Location, WorkMode, Type, Applied Date)
          if (job != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.cardPad),
              child: Wrap(
                spacing: context.scale(12).clamp(8.0, 14.0),
                runSpacing: context.scaleH(6).clamp(4.0, 8.0),
                children: [
                  if (job.location.isNotEmpty)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (context.screenWidth - 80).clamp(
                          160.0,
                          360.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppIcons.locationSvg,
                            width: 13,
                            height: 13,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF9CA3AF),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              job.location,
                              style: TextStyle(
                                fontSize: context.sp(12),
                                color: const Color(0xFF6B7280),
                                fontFamily: "Inter",
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AppIcons.briefcaseSvg,
                        width: 13,
                        height: 13,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF9CA3AF),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        job.type.displayName,
                        style: TextStyle(
                          fontSize: context.sp(12),
                          color: const Color(0xFF6B7280),
                          fontFamily: "Inter",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AppIcons.mobile,
                        width: 13,
                        height: 13,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF9CA3AF),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        job.workMode.displayName,
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

          SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),

          // Applied date
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.cardPad),
            child: Text(
              'Applied on ${_formatDate(app.createdAt)}',
              style: TextStyle(
                fontSize: context.sp(11),
                color: const Color(0xFF9CA3AF),
                fontFamily: "Inter",
              ),
            ),
          ),

          // Cover Letter preview if submitted
          if (app.coverLetter != null && app.coverLetter!.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.cardPad,
                context.scaleH(8).clamp(6.0, 10.0),
                context.cardPad,
                0,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.scale(12).clamp(10.0, 14.0)),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.newspaperSvg,
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            AppColors.vibrantBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Submitted Cover Letter',
                            style: TextStyle(
                              fontSize: context.sp(12),
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate800,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.coverLetter!,
                      style: TextStyle(
                        fontSize: context.sp(12),
                        color: AppColors.slate600,
                        height: 1.4,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: context.scaleH(12).clamp(8.0, 14.0)),

          // Action row
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.scale(12).clamp(8.0, 14.0),
              vertical: context.scaleH(8).clamp(6.0, 10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // View Job Details
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        if (app.jobId.isNotEmpty) {
                          vm.fetchJobDetails(app.jobId);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.jobDetail,
                            arguments: app.jobId,
                          );
                        }
                      },
                      icon: SvgPicture.asset(
                        AppIcons.eyeSvg,
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          AppColors.vibrantBlue,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: Text(
                        'View Job',
                        style: TextStyle(
                          color: AppColors.vibrantBlue,
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: context.scale(8).clamp(4.0, 10.0)),

                // Apply Again (if application is withdrawn)
                if (app.status == JobApplicationStatus.withdrawn)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final jobId = app.job?.id.isNotEmpty == true
                              ? app.job!.id
                              : app.jobId;
                          Navigator.pushNamed(
                            context,
                            AppRoutes.jobDetail,
                            arguments: jobId,
                          );
                        },
                        icon: SvgPicture.asset(
                          AppIcons.restartSvg,
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: Text(
                          'Apply Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vibrantBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scale(10).clamp(8.0, 12.0),
                            vertical: context.scaleH(4).clamp(3.0, 6.0),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Withdraw Application (if active: pending, reviewing, shortlisted, interview)
                if (app.status == JobApplicationStatus.pending ||
                    app.status == JobApplicationStatus.reviewing ||
                    app.status == JobApplicationStatus.shortlisted ||
                    app.status == JobApplicationStatus.interview)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmWithdraw(context, app, vm),
                        icon: SvgPicture.asset(
                          AppIcons.arrowBackSvg,
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryRed,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: Text(
                          'Withdraw',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w600,
                            fontFamily: "Inter",
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          backgroundColor: const Color(0xFFFEF2F2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scale(10).clamp(8.0, 12.0),
                            vertical: context.scaleH(4).clamp(3.0, 6.0),
                          ),
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

  void _confirmWithdraw(
    BuildContext context,
    JobApplicationModel app,
    JobsViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsOverflowButtonSpacing: 8,
        title: Text(
          'Withdraw Application',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: context.sp(18),
            fontFamily: 'Inter',
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Are you sure you want to withdraw your application?\nThis action cannot be undone.',
            style: TextStyle(
              fontSize: context.sp(14),
              height: 1.4,
              fontFamily: 'Inter',
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, top: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.slate600,
                fontWeight: FontWeight.w600,
                fontSize: context.sp(14),
                fontFamily: 'Inter',
              ),
            ),
          ),
          CustomButton(
            text: 'Withdraw',
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await vm.withdrawApplication(app.id);
              if (!context.mounted) return;
              if (success) {
                _showWithdrawSuccessDialog(context);
              } else {
                _showErrorDialog(
                  context,
                  vm.errorMessage ?? 'Failed to withdraw application',
                );
              }
            },
            backgroundColor: AppColors.primaryRed,
            borderRadius: 12,
            fontWeight: FontWeight.bold,
            fontSize: context.sp(14),
            height: 40,
          ),
        ],
      ),
    );
  }

  void _showWithdrawSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: context.scale(24).clamp(16.0, 32.0),
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.scale(24).clamp(16.0, 24.0),
                vertical: context.scaleH(24).clamp(16.0, 24.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: context.scale(70).clamp(56.0, 72.0),
                    height: context.scale(70).clamp(56.0, 72.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.arrowBackSvg,
                        width: context.scale(36).clamp(28.0, 38.0),
                        height: context.scale(36).clamp(28.0, 38.0),
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryRed,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.scaleH(20).clamp(14.0, 22.0)),
                  Text(
                    'Application Withdrawn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.sp(18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
                  Text(
                    'Your application has been withdrawn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.sp(14),
                      color: AppColors.slate500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: context.scaleH(24).clamp(16.0, 26.0)),
                  CustomButton(
                    text: 'Continue',
                    onPressed: () => Navigator.pop(ctx),
                    backgroundColor: AppColors.primaryRed,
                    height: 48,
                    borderRadius: 12,
                    fontWeight: FontWeight.bold,
                    fontSize: context.sp(15),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: context.scale(24).clamp(16.0, 32.0),
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.scale(24).clamp(16.0, 24.0),
                vertical: context.scaleH(24).clamp(16.0, 24.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: context.scale(70).clamp(56.0, 72.0),
                    height: context.scale(70).clamp(56.0, 72.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.infoSvg,
                        width: context.scale(38).clamp(28.0, 40.0),
                        height: context.scale(38).clamp(28.0, 40.0),
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryRed,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.scaleH(20).clamp(14.0, 22.0)),
                  Text(
                    'Application Notice',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.sp(18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.sp(14),
                      color: AppColors.slate600,
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: context.scaleH(24).clamp(16.0, 26.0)),
                  CustomButton(
                    text: 'Got it',
                    onPressed: () => Navigator.pop(ctx),
                    backgroundColor: AppColors.vibrantBlue,
                    height: 48,
                    borderRadius: 12,
                    fontWeight: FontWeight.bold,
                    fontSize: context.sp(15),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
