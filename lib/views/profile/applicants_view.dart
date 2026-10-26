import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/models/chat_model.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/models/job_model.dart';
import 'package:desilynks/models/job_application_model.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/views/chat/chat_detail_view.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class ApplicantsView extends StatelessWidget {
  final dynamic job;

  const ApplicantsView({super.key, required this.job});

  String get jobId {
    if (job is JobModel) return (job as JobModel).id;
    if (job is String) return job as String;
    return '';
  }

  String get jobTitle {
    if (job is JobModel) return (job as JobModel).title;
    return 'Job Applicants';
  }

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

  Widget _statusIcon(
    JobApplicationStatus status, {
    double size = 16,
    Color? color,
  }) {
    final String assetName;
    switch (status) {
      case JobApplicationStatus.pending:
        assetName = AppIcons.TimerSvg;
        break;
      case JobApplicationStatus.reviewing:
        assetName = AppIcons.eyeSvg;
        break;
      case JobApplicationStatus.shortlisted:
        assetName = AppIcons.starFavoriteSvg;
        break;
      case JobApplicationStatus.interview:
        assetName = AppIcons.calendarSvg;
        break;
      case JobApplicationStatus.offered:
        assetName = AppIcons.tickCircleSvg;
        break;
      case JobApplicationStatus.rejected:
        assetName = AppIcons.crossSmallSvg;
        break;
      case JobApplicationStatus.withdrawn:
        assetName = AppIcons.arrowBackBasicSvg;
        break;
    }
    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        final jobsVm = Provider.of<JobsViewModel>(context, listen: false);
        if (jobId.isNotEmpty && jobsVm.fetchedJobApplicationsId != jobId) {
          jobsVm.fetchJobApplications(jobId);
        }
      }
    });

    final vm = Provider.of<JobsViewModel>(context);
    final allApplications = vm.jobApplications;
    final filteredApplications = vm.filteredJobApplications;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: context.scale(42),
        leading: IconButton(
          padding: EdgeInsets.only(left: context.scale(12)),
          icon: SvgPicture.asset(
            AppIcons.arrowBackBasicSvg,
            width: context.scale(22),
            height: context.scale(22),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: context.scale(8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applicants',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: context.sp(20),
                fontWeight: FontWeight.w700,
                fontFamily: "Inter",
              ),
            ),
            Text(
              jobTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.slate500,
                fontSize: context.sp(12),
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
          ],
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
          child: Column(
            children: [
              // Status summary card
              _buildSummaryCard(context, allApplications),

              // Filter chips row
              _buildFilterChips(context, vm, allApplications),

              // Content
              Expanded(
                child: vm.isLoading && allApplications.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.emerald,
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.emerald,
                        onRefresh: () async {
                          if (jobId.isNotEmpty) {
                            await vm.fetchJobApplications(jobId);
                          }
                        },
                        child: filteredApplications.isEmpty
                            ? _buildEmptyState(context, vm.jobApplicantsFilter)
                            : _buildApplicantsList(context, filteredApplications, vm),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    List<JobApplicationModel> applications,
  ) {
    // Count by status
    final Map<JobApplicationStatus, int> counts = {};
    for (final status in JobApplicationStatus.values) {
      counts[status] = applications.where((a) => a.status == status).length;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.hMargin,
        vertical: context.scaleH(12),
      ),
      padding: EdgeInsets.all(context.cardPad),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A5F), Color(0xFF0F2A44)],
        ),
        borderRadius: BorderRadius.circular(context.scale(16)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.3),
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
                padding: EdgeInsets.all(context.scale(8)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(context.scale(10)),
                ),
                child: SvgPicture.asset(
                  AppIcons.peopleCommunitySvg,
                  width: context.scale(22),
                  height: context.scale(22),
                ),
              ),
              SizedBox(width: context.scale(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${applications.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.sp(24),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Inter",
                      ),
                    ),
                    Text(
                      'Total Applications',
                      style: TextStyle(
                        color: const Color(0xFFB0C4DE),
                        fontSize: context.sp(12),
                        fontFamily: "Inter",
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.scale(8)),
              // Quick stats
              _buildMiniStat(
                context,
                'Pending',
                '${counts[JobApplicationStatus.pending] ?? 0}',
                const Color(0xFFF59E0B),
              ),
              SizedBox(width: context.scale(12)),
              _buildMiniStat(
                context,
                'Shortlisted',
                '${counts[JobApplicationStatus.shortlisted] ?? 0}',
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
          SizedBox(height: context.scaleH(16)),
          // Horizontal stats bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: applications.isEmpty
                ? Container(
                    height: context.scaleH(4),
                    color: Colors.white.withValues(alpha: 0.12),
                  )
                : Row(
                    children: JobApplicationStatus.values
                        .where((s) {
                          return (counts[s] ?? 0) > 0;
                        })
                        .map((s) {
                          final count = counts[s] ?? 0;
                          final fraction = count / applications.length;
                          return Expanded(
                            flex: (fraction * 100).round().clamp(1, 100),
                            child: Container(
                              height: context.scaleH(4),
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                color: _statusColor(s),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context,
    String label,
    String count,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFB0C4DE),
            fontSize: context.sp(10),
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    JobsViewModel vm,
    List<JobApplicationModel> applications,
  ) {
    return SizedBox(
      height: context.scaleH(40),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.hMargin),
        children: [
          Center(
            child: _buildFilterChip(
              context,
              vm,
              'All',
              null,
              applications.length,
              const Color(0xFF374151),
            ),
          ),
          SizedBox(width: context.scale(8)),
          ...JobApplicationStatus.values.map((status) {
            final count = applications.where((a) => a.status == status).length;
            if (count == 0) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(right: context.scale(8)),
              child: Center(
                child: _buildFilterChip(
                  context,
                  vm,
                  status.displayName,
                  status,
                  count,
                  _statusColor(status),
                ),
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
    final isSelected = vm.jobApplicantsFilter == status;
    return GestureDetector(
      onTap: () {
        vm.setJobApplicantsFilter(status);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.scale(14),
          vertical: context.scaleH(7),
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(context.scale(20)),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
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
            SizedBox(width: context.scale(6)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.scale(6),
                vertical: context.scaleH(1),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.scale(10)),
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
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.hMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.scale(80),
              height: context.scale(80),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.peopleCommunitySvg,
                  width: context.scale(36),
                  height: context.scale(36),
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF9CA3AF),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.scaleH(16)),
            Text(
              selectedFilter != null
                  ? 'No ${selectedFilter.displayName.toLowerCase()} applications'
                  : 'No applications yet',
              style: TextStyle(
                fontSize: context.sp(16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
                fontFamily: "Inter",
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.scaleH(8)),
            Text(
              selectedFilter != null
                  ? 'Try changing the filter to see other applications.'
                  : 'Applicants will appear here once they apply to your job.',
              style: TextStyle(
                fontSize: context.sp(13),
                color: const Color(0xFF9CA3AF),
                fontFamily: "Inter",
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantsList(
    BuildContext context,
    List<JobApplicationModel> applications,
    JobsViewModel vm,
  ) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.hMargin,
        context.scaleH(10),
        context.hMargin,
        context.scaleH(24),
      ),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        return _buildApplicantCard(context, app, vm);
      },
    );
  }

  Widget _buildApplicantCard(
    BuildContext context,
    JobApplicationModel app,
    JobsViewModel vm,
  ) {
    final applicant = app.applicant;
    final statusColor = _statusColor(app.status);
    final statusIcon = _statusIcon(app.status, size: context.scale(12), color: statusColor);
    final initials = applicant != null
        ? '${applicant.firstName.isNotEmpty ? applicant.firstName[0] : ''}${applicant.lastName.isNotEmpty ? applicant.lastName[0] : ''}'
        : '?';

    final avatarSize = context.scale(48.0);

    return Container(
      margin: EdgeInsets.only(bottom: context.scaleH(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scale(16)),
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
        children: [
          // Applicant Header
          Padding(
            padding: EdgeInsets.all(context.cardPad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar & Details (Clickable to view Public Profile)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (applicant != null) {
                        final owner = PropertyOwner(
                          id: applicant.id,
                          firstName: applicant.firstName,
                          lastName: applicant.lastName,
                          profilePhotoUrl: applicant.profilePhotoUrl,
                          createdAt: app.createdAt.toIso8601String(),
                          email: applicant.email,
                          phoneNumber: applicant.phoneNumber,
                          coverLetter: app.coverLetter,
                        );
                        Navigator.pushNamed(
                          context,
                          AppRoutes.publicProfile,
                          arguments: owner,
                        );
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                statusColor.withValues(alpha: 0.7),
                                statusColor,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: applicant?.profilePhotoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    applicant!.profilePhotoUrl!,
                                    width: avatarSize,
                                    height: avatarSize,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                          child: Text(
                                            initials.toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: context.sp(16),
                                              fontFamily: "Inter",
                                            ),
                                          ),
                                        ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    initials.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(16),
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                ),
                        ),

                        SizedBox(width: context.scale(12)),

                        // Name & Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      applicant?.fullName ??
                                          'Unknown Applicant',
                                      style: TextStyle(
                                        fontSize: context.sp(15),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF111827),
                                        fontFamily: "Inter",
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: context.scale(4)),
                                  SvgPicture.asset(
                                    AppIcons.OpenLink,
                                    width: context.scale(18),
                                    height: context.scale(18),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.scaleH(2)),
                              if (applicant?.email != null &&
                                  applicant!.email.isNotEmpty)
                                Text(
                                  applicant.email,
                                  style: TextStyle(
                                    fontSize: context.sp(12),
                                    color: const Color(0xFF6B7280),
                                    fontFamily: "Inter",
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (applicant?.phoneNumber != null &&
                                  applicant!.phoneNumber!.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: context.scaleH(2)),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        AppIcons.callSvg,
                                        width: context.scale(13),
                                        height: context.scale(13),
                                      ),
                                      SizedBox(width: context.scale(4)),
                                      Flexible(
                                        child: Text(
                                          applicant.phoneNumber!,
                                          style: TextStyle(
                                            fontSize: context.sp(11),
                                            color: const Color(0xFF9CA3AF),
                                            fontFamily: "Inter",
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(height: context.scaleH(4)),
                              Text(
                                'Applied ${_formatDate(app.createdAt)}',
                                style: TextStyle(
                                  fontSize: context.sp(11),
                                  color: const Color(0xFF9CA3AF),
                                  fontFamily: "Inter",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: context.scale(8)),

                // Status chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(8),
                    vertical: context.scaleH(4),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(12)),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      statusIcon,
                      SizedBox(width: context.scale(4)),
                      Text(
                        app.status.displayName,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: context.sp(11),
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

          // Cover letter section (if present)
          if (app.coverLetter != null && app.coverLetter!.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            Padding(
              padding: EdgeInsets.all(context.cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.dashboardSvg,
                        width: context.scale(14),
                        height: context.scale(14),
                      ),
                      SizedBox(width: context.scale(4)),
                      Text(
                        'Cover Letter',
                        style: TextStyle(
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                          fontFamily: "Inter",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.scaleH(8)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.scale(12)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(context.scale(10)),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Text(
                      app.coverLetter!,
                      style: TextStyle(
                        fontSize: context.sp(13),
                        color: const Color(0xFF374151),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        fontFamily: "Inter",
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Quick Accept / Reject Action Row
          if (app.status == JobApplicationStatus.pending ||
              app.status == JobApplicationStatus.reviewing) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.scale(12),
                vertical: context.scaleH(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await vm.updateApplicationStatus(
                          app.id,
                          JobApplicationStatus.offered,
                        );
                        if (!context.mounted) return;
                        if (success) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Applicant accepted & offered!'),
                              backgroundColor: Color(0xFF16A34A),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Text('✅', style: TextStyle(fontSize: 12)),
                      label: const Text(
                        'Accept',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          vertical: context.scaleH(8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.scale(8)),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await vm.updateApplicationStatus(
                          app.id,
                          JobApplicationStatus.rejected,
                        );
                        if (!context.mounted) return;
                        if (success) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Applicant rejected.'),
                              backgroundColor: Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Text('❌', style: TextStyle(fontSize: 12)),
                      label: const Text(
                        'Reject',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          vertical: context.scaleH(8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons row
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.scale(12),
              vertical: context.scaleH(10),
            ),
            child: Row(
              children: [
                // Update Status button
                Expanded(
                  child: PopupMenuButton<JobApplicationStatus>(
                    onSelected: (newStatus) async {
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await vm.updateApplicationStatus(
                        app.id,
                        newStatus,
                      );
                      if (!context.mounted) return;
                      if (success) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Status updated to ${newStatus.displayName}',
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(10)),
                            ),
                          ),
                        );
                      } else {
                        _showErrorDialog(
                          context,
                          vm.errorMessage ?? 'Failed to update status',
                        );
                      }
                    },
                    itemBuilder: (ctx) => JobApplicationStatus.values
                        .where((s) => s != app.status)
                        .map(
                          (s) => PopupMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                _statusIcon(
                                  s,
                                  size: context.scale(16),
                                  color: _statusColor(s),
                                ),
                                SizedBox(width: context.scale(8)),
                                Text(
                                  s.displayName,
                                  style: TextStyle(
                                    fontSize: context.sp(13),
                                    fontFamily: "Inter",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(12)),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.scaleH(8),
                        horizontal: context.scale(8),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(context.scale(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.swag,
                            width: context.scale(18),
                            height: context.scale(18),
                          ),
                          SizedBox(width: context.scale(6)),
                          Flexible(
                            child: Text(
                              'Update Status',
                              style: TextStyle(
                                color: const Color(0xFF2563EB),
                                fontSize: context.sp(12),
                                fontWeight: FontWeight.bold,
                                fontFamily: "Inter",
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.scale(8)),
                // Contact button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final applicantId = app.applicant?.id.isNotEmpty == true
                          ? app.applicant!.id
                          : app.applicantId;
                      if (applicantId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Cannot initiate chat: Applicant details missing.',
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(10)),
                            ),
                          ),
                        );
                        return;
                      }

                      final conv = ChatConversationModel(
                        id: 'job_${app.jobId}_$applicantId',
                        otherParticipant: ChatParticipantModel(
                          id: applicantId,
                          firstName: app.applicant?.firstName.isNotEmpty == true
                              ? app.applicant!.firstName
                              : 'Applicant',
                          lastName: app.applicant?.lastName ?? '',
                          profilePhotoUrl: app.applicant?.profilePhotoUrl,
                        ),
                        updatedAt: DateTime.now(),
                        createdAt: DateTime.now(),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailView(conversation: conv),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.scaleH(8),
                        horizontal: context.scale(8),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(context.scale(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.chatRoundSvg,
                            width: context.scale(16),
                            height: context.scale(16),
                          ),
                          SizedBox(width: context.scale(6)),
                          Flexible(
                            child: Text(
                              'Contact',
                              style: TextStyle(
                                color: const Color(0xFF10B981),
                                fontSize: context.sp(12),
                                fontWeight: FontWeight.bold,
                                fontFamily: "Inter",
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(20)),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.scale(24),
              vertical: context.scaleH(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: context.scale(64),
                  height: context.scale(64),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.infoCircularButtonSvg,
                      width: context.scale(32),
                      height: context.scale(32),
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(20)),
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
                SizedBox(height: context.scaleH(8)),
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
                SizedBox(height: context.scaleH(24)),
                SizedBox(
                  width: double.infinity,
                  height: context.scaleH(48),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(12)),
                      ),
                    ),
                    child: Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
  }
}
