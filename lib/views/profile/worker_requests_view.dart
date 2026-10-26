import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/models/need_worker_model.dart';
import 'package:desilynks/models/need_worker_application_model.dart';
import 'package:desilynks/models/need_worker_enums.dart';
import 'package:desilynks/viewmodels/create_post/need_worker_viewmodel.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/widgets/user_avatar.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class WorkerRequestsView extends StatelessWidget {
  final NeedWorkerModel? initialPost;
  final String? initialPostId;

  const WorkerRequestsView({
    super.key,
    this.initialPost,
    this.initialPostId,
  });

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

  Color _statusColor(NeedAWorkerApplicationStatus status) {
    switch (status) {
      case NeedAWorkerApplicationStatus.pending:
        return const Color(0xFFF59E0B);
      case NeedAWorkerApplicationStatus.accepted:
        return const Color(0xFF10B981);
      case NeedAWorkerApplicationStatus.rejected:
        return const Color(0xFFEF4444);
      case NeedAWorkerApplicationStatus.withdrawn:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBgColor(NeedAWorkerApplicationStatus status) {
    switch (status) {
      case NeedAWorkerApplicationStatus.pending:
        return const Color(0xFFFEF3C7);
      case NeedAWorkerApplicationStatus.accepted:
        return const Color(0xFFD1FAE5);
      case NeedAWorkerApplicationStatus.rejected:
        return const Color(0xFFFEE2E2);
      case NeedAWorkerApplicationStatus.withdrawn:
        return const Color(0xFFF3F4F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final needWorkerVm =
          Provider.of<NeedWorkerViewModel>(context, listen: false);
      needWorkerVm.initWorkerRequests(
        initialPost: initialPost,
        initialPostId: initialPostId,
      );
    });

    final vm = Provider.of<NeedWorkerViewModel>(context);

    final selectedPost = vm.selectedWorkerPost ?? initialPost;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Worker Requests',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: "Inter",
              ),
            ),
            if (selectedPost != null)
              Text(
                'Need ${WorkerTypeX.fromString(selectedPost.workerType).displayName} • ${selectedPost.location}',
                style: const TextStyle(
                  color: AppColors.slate500,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
          child: Consumer<NeedWorkerViewModel>(
            builder: (context, vm, child) {
              final allApplications = vm.postApplications;
              final filteredApplications = vm.filteredPostApplications;

              // Compute counts
              final int totalCount = allApplications.length;
              final int pendingCount = allApplications
                  .where((a) =>
                      NeedAWorkerApplicationStatusX.fromString(a.status) ==
                      NeedAWorkerApplicationStatus.pending)
                  .length;
              final int acceptedCount = allApplications
                  .where((a) =>
                      NeedAWorkerApplicationStatusX.fromString(a.status) ==
                      NeedAWorkerApplicationStatus.accepted)
                  .length;
              final int rejectedCount = allApplications
                  .where((a) =>
                      NeedAWorkerApplicationStatusX.fromString(a.status) ==
                      NeedAWorkerApplicationStatus.rejected)
                  .length;
              return RefreshIndicator(
                color: AppColors.vibrantBlue,
                onRefresh: () async {
                  await vm.initWorkerRequests(
                    initialPost: initialPost,
                    initialPostId: initialPostId,
                    force: true,
                  );
                },
                child: Column(
                  children: [
                    // Application Stats Card (matching my_applications_view.dart)
                    _buildStatsCard(
                      context,
                      totalCount: totalCount,
                      pendingCount: pendingCount,
                      acceptedCount: acceptedCount,
                      rejectedCount: rejectedCount,
                    ),

                    // Status Filter Chips
                    _buildFilterChips(
                      context,
                      vm,
                      allApplications,
                      pendingCount: pendingCount,
                      acceptedCount: acceptedCount,
                      rejectedCount: rejectedCount,
                    ),

                    SizedBox(height: context.scaleH(8)),

                    // Applications / Requests List
                    Expanded(
                      child: vm.isLoading && allApplications.isEmpty
                          ? const ListSkeleton(showTabs: false)
                          : filteredApplications.isEmpty
                              ? _buildEmptyState(context, vm)
                              : _buildRequestsList(context, filteredApplications, vm),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required int totalCount,
    required int pendingCount,
    required int acceptedCount,
    required int rejectedCount,
  }) {
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
                  AppIcons.workerSvg,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: context.scale(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(24),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Inter",
                    ),
                  ),
                  Text(
                    'Total Incoming Requests',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: context.sp(12),
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: context.scaleH(16)),

          // Mini stats grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric(context, 'Pending', pendingCount, const Color(0xFFF59E0B)),
              _buildStatMetric(context, 'Accepted', acceptedCount, const Color(0xFF10B981)),
              _buildStatMetric(context, 'Declined', rejectedCount, const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.scale(14),
            vertical: context.scaleH(4),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: context.sp(15),
              fontWeight: FontWeight.bold,
              fontFamily: "Inter",
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: context.sp(11),
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    NeedWorkerViewModel vm,
    List<NeedWorkerApplicationModel> applications, {
    required int pendingCount,
    required int acceptedCount,
    required int rejectedCount,
  }) {
    return SizedBox(
      height: context.scaleH(40),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.hMargin),
        children: [
          _buildFilterChip(
            context,
            vm,
            'All',
            null,
            applications.length,
            const Color(0xFF374151),
          ),
          SizedBox(width: context.scale(8)),
          _buildFilterChip(
            context,
            vm,
            'Pending',
            NeedAWorkerApplicationStatus.pending,
            pendingCount,
            const Color(0xFFF59E0B),
          ),
          SizedBox(width: context.scale(8)),
          _buildFilterChip(
            context,
            vm,
            'Accepted',
            NeedAWorkerApplicationStatus.accepted,
            acceptedCount,
            const Color(0xFF10B981),
          ),
          SizedBox(width: context.scale(8)),
          _buildFilterChip(
            context,
            vm,
            'Declined',
            NeedAWorkerApplicationStatus.rejected,
            rejectedCount,
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    NeedWorkerViewModel vm,
    String label,
    NeedAWorkerApplicationStatus? status,
    int count,
    Color color,
  ) {
    final isSelected = vm.workerRequestsFilter == status;
    return GestureDetector(
      onTap: () {
        vm.setWorkerRequestsFilter(status);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.scale(14),
          vertical: context.scaleH(6),
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

  Widget _buildEmptyState(BuildContext context, NeedWorkerViewModel vm) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 350,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: SvgPicture.asset(
                AppIcons.workerSvg,
                width: 40,
                height: 40,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF9CA3AF),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              vm.workerRequestsFilter != null
                  ? 'No ${vm.workerRequestsFilter!.displayName.toLowerCase()} requests'
                  : 'No incoming worker requests yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vm.workerRequestsFilter != null
                  ? 'Try selecting a different filter.'
                  : 'When someone requests to hire you or applies for your post, they will appear here.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
                fontFamily: "Inter",
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    List<NeedWorkerApplicationModel> applications,
    NeedWorkerViewModel vm,
  ) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.hMargin,
        context.scaleH(12),
        context.hMargin,
        context.scaleH(24),
      ),
      itemCount: applications.length,
      itemBuilder: (ctx, index) {
        final app = applications[index];
        return _buildRequestCard(context, app, vm);
      },
    );
  }

  /// Request Card exactly matching the user's provided UI specification
  Widget _buildRequestCard(
    BuildContext context,
    NeedWorkerApplicationModel app,
    NeedWorkerViewModel vm,
  ) {
    final status = NeedAWorkerApplicationStatusX.fromString(app.status);
    final statusColor = _statusColor(status);
    final statusBg = _statusBgColor(status);

    final worker = app.worker;
    final workRequest = app.workRequest ?? vm.selectedWorkerPost ?? initialPost;

    // Resolve displayed person who is hiring or applying
    final name = worker != null && worker.fullName.isNotEmpty
        ? worker.fullName
        : (workRequest?.requester?.fullName.isNotEmpty == true
            ? workRequest!.requester!.fullName
            : 'Worker Applicant');

    final photoUrl = worker?.profilePhotoUrl ?? workRequest?.requester?.profilePhotoUrl;

    // Service & profession subtitle
    final service = workRequest != null
        ? '${WorkerTypeX.fromString(workRequest.workerType).displayName} Repair'
        : 'Worker Service';
    final profession = workRequest != null
        ? WorkerTypeX.fromString(workRequest.workerType).displayName
        : 'Worker';
    final req = workRequest;
    final rateSubtitle = req != null && req.budget.isNotEmpty && req.budgetType.isNotEmpty
        ? '$profession · €${req.budget}/${req.budgetType == 'PERHOUR' ? 'hr' : 'task'}'
        : '$profession · €18/hr';

    final location = workRequest?.location.isNotEmpty == true
        ? workRequest!.location
        : 'Madrid, Spain';

    final budgetDisplay = app.proposedPrice != null && app.proposedPrice!.isNotEmpty
        ? '€${app.proposedPrice}'
        : (workRequest?.budget != null ? '€${workRequest!.budget}' : '€100');

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.workerRequestDetail,
          arguments: {
            'application': app,
            'post': workRequest,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: context.scaleH(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Avatar, Name/Profession, Status Pill
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  UserAvatar(
                    photoUrl: photoUrl,
                    size: 46,
                    fallbackSvg: AppIcons.personSvg,
                    fallbackBgColor: const Color(0xFFEFF6FF),
                    fallbackIconColor: const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 14),

                  // Name & Profession/Rate
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            fontFamily: 'Inter',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rateSubtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status Pill (Yellow for Pending matching screenshot)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status.displayName,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            // Details Rows (Service, Location, Budget) exactly matching screenshot
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'Service',
                    value: service,
                    valueColor: const Color(0xFF111827),
                    valueBold: true,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    label: 'Location',
                    value: location,
                    valueColor: const Color(0xFF111827),
                    valueBold: true,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    label: 'Budget',
                    value: budgetDisplay,
                    valueColor: const Color(0xFF2563EB), // Blue bold as in screenshot
                    valueBold: true,
                  ),
                ],
              ),
            ),

            // Optional Cover Letter note
            if (app.coverLetter != null && app.coverLetter!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    app.coverLetter!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            // Bottom "Simulate Worker Response:" Action Section (from screenshot)
            if (status == NeedAWorkerApplicationStatus.pending)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF4), // Light green tint container
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Respond to Request:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D), // Forest green
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Accept Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmAccept(context, app, vm),
                            icon: const Text(
                              '✅',
                              style: TextStyle(fontSize: 14),
                            ),
                            label: const Text(
                              'Accept',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A), // Solid green
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Decline Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmDecline(context, app, vm),
                            icon: const Text(
                              '❌',
                              style: TextStyle(fontSize: 14),
                            ),
                            label: const Text(
                              'Decline',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444), // Solid red
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              // Footer for non-pending requests
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Applied ${_formatDate(app.createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'Inter',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.workerRequestDetail,
                          arguments: {
                            'application': app,
                            'post': workRequest,
                          },
                        );
                      },
                      icon: SvgPicture.asset(
                        AppIcons.eyeSvg,
                        width: 15,
                        height: 15,
                        colorFilter: const ColorFilter.mode(
                          AppColors.vibrantBlue,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text(
                        'View Details',
                        style: TextStyle(
                          color: AppColors.vibrantBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required Color valueColor,
    required bool valueBold,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  void _confirmAccept(
    BuildContext context,
    NeedWorkerApplicationModel app,
    NeedWorkerViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Accept Worker Request',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Inter',
          ),
        ),
        content: const Text(
          'Are you sure you want to accept this request?\n\nAccepting this application will automatically decline other pending requests for this post.',
          style: TextStyle(fontSize: 14, height: 1.4, fontFamily: 'Inter'),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, top: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.slate600,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
          CustomButton(
            text: 'Accept',
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await vm.acceptApplication(app.id);
              if (!context.mounted) return;
              if (success) {
                _showSuccessDialog(
                  context,
                  title: 'Request Accepted',
                  message:
                      'You have successfully accepted this worker request. You can now coordinate with them directly.',
                  isAccept: true,
                );
              } else {
                _showErrorDialog(
                  context,
                  vm.errorMessage ?? 'Failed to accept application',
                );
              }
            },
            backgroundColor: const Color(0xFF16A34A),
            borderRadius: 12,
            fontWeight: FontWeight.bold,
            width: 110,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _confirmDecline(
    BuildContext context,
    NeedWorkerApplicationModel app,
    NeedWorkerViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Decline Worker Request',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Inter',
          ),
        ),
        content: const Text(
          'Are you sure you want to decline this request?\nThis action will notify the applicant.',
          style: TextStyle(fontSize: 14, height: 1.4, fontFamily: 'Inter'),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, top: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.slate600,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
          CustomButton(
            text: 'Decline',
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await vm.rejectApplication(app.id);
              if (!context.mounted) return;
              if (success) {
                _showSuccessDialog(
                  context,
                  title: 'Request Declined',
                  message: 'You have declined this worker request.',
                  isAccept: false,
                );
              } else {
                _showErrorDialog(
                  context,
                  vm.errorMessage ?? 'Failed to decline application',
                );
              }
            },
            backgroundColor: const Color(0xFFEF4444),
            borderRadius: 12,
            fontWeight: FontWeight.bold,
            width: 110,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    required bool isAccept,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isAccept
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isAccept ? '✅' : '❌',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.slate500,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Continue',
                  onPressed: () => Navigator.pop(ctx),
                  backgroundColor: isAccept
                      ? const Color(0xFF16A34A)
                      : AppColors.primaryRed,
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppIcons.infoSvg,
                    width: 38,
                    height: 38,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryRed,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Notice',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.slate600,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Got it',
                  onPressed: () => Navigator.pop(ctx),
                  backgroundColor: AppColors.vibrantBlue,
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
