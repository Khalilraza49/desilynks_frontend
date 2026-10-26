import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/models/chat_model.dart';
import 'package:desilynks/models/need_worker_model.dart';
import 'package:desilynks/models/need_worker_application_model.dart';
import 'package:desilynks/models/need_worker_enums.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/viewmodels/chat/chat_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/need_worker_viewmodel.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/widgets/user_avatar.dart';
import 'package:desilynks/views/chat/chat_detail_view.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class WorkerRequestDetailView extends StatelessWidget {
  final NeedWorkerApplicationModel application;
  final NeedWorkerModel? post;

  const WorkerRequestDetailView({
    super.key,
    required this.application,
    this.post,
  });

  String _resolveTradeTitle(NeedWorkerModel? workRequest) {
    if (workRequest == null || workRequest.workerType.trim().isEmpty) {
      return 'Worker';
    }
    final parsed = WorkerTypeX.fromString(workRequest.workerType);
    if (parsed != WorkerType.other) {
      return parsed.displayName;
    }
    return workRequest.workerType.trim();
  }

  Future<void> _openChatWithWorker({
    required BuildContext context,
    required NeedWorkerApplicationModel currentApp,
    required NeedWorkerModel? workRequest,
    required String name,
    required String? photoUrl,
  }) async {
    final vm = context.read<NeedWorkerViewModel>();
    final worker = currentApp.worker;
    final targetWorkerId = worker?.id.isNotEmpty == true
        ? worker!.id
        : (currentApp.workerId.isNotEmpty
            ? currentApp.workerId
            : (workRequest?.requester?.id ?? ''));

    if (targetWorkerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Unable to find contact information for this worker.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (vm.isChatStarting) return;
    vm.setIsChatStarting(true);

    try {
      final workerFirstName = worker != null && worker.firstName.isNotEmpty
          ? worker.firstName
          : (name.split(' ').first.isNotEmpty ? name.split(' ').first : 'Worker');

      final workerLastName = worker?.lastName ??
          (name.contains(' ') ? name.split(' ').sublist(1).join(' ') : '');

      final tradeTitle = _resolveTradeTitle(workRequest);
      final initialMessage =
          'I have selected you for the $tradeTitle work\nwhen can you join';

      final chatVM = context.read<ChatViewModel>();

      // Check if conversation already exists with this worker
      ChatConversationModel? existingConv;
      for (final c in chatVM.conversations) {
        if (c.otherParticipant.id == targetWorkerId) {
          existingConv = c;
          break;
        }
      }

      final conv = existingConv ??
          ChatConversationModel(
            id: 'worker_${currentApp.id}_$targetWorkerId',
            otherParticipant: ChatParticipantModel(
              id: targetWorkerId,
              firstName: workerFirstName,
              lastName: workerLastName,
              profilePhotoUrl: photoUrl,
            ),
            updatedAt: DateTime.now(),
            createdAt: DateTime.now(),
          );

      // Enter the conversation to connect socket & fetch messages
      await chatVM.enterConversation(conv);

      // Check if greeting message was already sent to avoid duplicate spam
      final existingMessages = chatVM.getMessagesForConversation(
        conv.id,
        participantId: targetWorkerId,
      );
      final hasAlreadySentGreeting = existingMessages.any(
        (m) =>
            m.content.toLowerCase().contains('i have selected you') ||
            m.content.toLowerCase().contains('when can you join'),
      );

      if (!hasAlreadySentGreeting) {
        await chatVM.sendActiveTextMessage(initialMessage);
      }

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailView(conversation: conv),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open chat: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      vm.setIsChatStarting(false);
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
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
    final vm = Provider.of<NeedWorkerViewModel>(context);
    final currentApp = vm.postApplications
            .where((a) => a.id == application.id)
            .firstOrNull ??
        application;

    final status = NeedAWorkerApplicationStatusX.fromString(currentApp.status);
    final statusColor = _statusColor(status);
    final statusBg = _statusBgColor(status);

    final worker = currentApp.worker;
    final workRequest = currentApp.workRequest ?? post;

    // Resolve person hiring or requesting
    final name = worker != null && worker.fullName.isNotEmpty
        ? worker.fullName
        : (workRequest?.requester?.fullName.isNotEmpty == true
            ? workRequest!.requester!.fullName
            : 'Worker Applicant');

    final photoUrl =
        worker?.profilePhotoUrl ?? workRequest?.requester?.profilePhotoUrl;
    final phone = worker?.phoneNumber ?? '';
    final email = worker?.email ?? '';

    // Service & profession
    final serviceName = workRequest != null
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

    final budgetDisplay =
        currentApp.proposedPrice != null &&
            currentApp.proposedPrice!.isNotEmpty
        ? '€${currentApp.proposedPrice}'
        : (workRequest?.budget != null ? '€${workRequest!.budget}' : '€100');

    final originalBudget = workRequest?.budget != null
        ? '€${workRequest!.budget}'
        : '€100';
    final budgetType = workRequest != null
        ? BudgetTypeX.fromString(workRequest.budgetType).displayName
        : 'Fixed';

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
          onPressed: () => Navigator.pop(context, currentApp),
        ),
        titleSpacing: 8,
        title: const Text(
          'Request Details',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
              vertical: context.scaleH(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Card: Person Who Is Hiring / Applicant
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.2,
                    ),
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
                      Row(
                        children: [
                          UserAvatar(
                            photoUrl: photoUrl,
                            size: 60,
                            fallbackSvg: AppIcons.personSvg,
                            fallbackBgColor: const Color(0xFFEFF6FF),
                            fallbackIconColor: const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  rateSubtitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status.displayName,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
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

                      // Contact Actions if available
                      if (phone.isNotEmpty ||
                          email.isNotEmpty ||
                          status == NeedAWorkerApplicationStatus.accepted) ...[
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        Row(
                          children: [
                            if (phone.isNotEmpty) ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Contact: $phone'),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: SvgPicture.asset(
                                    AppIcons.callSvg,
                                    width: 15,
                                    height: 15,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.vibrantBlue,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  label: Text(
                                    phone,
                                    style: const TextStyle(
                                      color: AppColors.vibrantBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFBFDBFE),
                                    ),
                                    backgroundColor: const Color(0xFFEFF6FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            // Quick Chat action button
                            OutlinedButton.icon(
                              onPressed: vm.isChatStarting
                                  ? null
                                  : () => _openChatWithWorker(
                                        context: context,
                                        currentApp: currentApp,
                                        workRequest: workRequest,
                                        name: name,
                                        photoUrl: photoUrl,
                                      ),
                              icon: SvgPicture.asset(
                                AppIcons.chatRoundSvg,
                                width: 15,
                                height: 15,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.successGreen,
                                  BlendMode.srcIn,
                                ),
                              ),
                              label: const Text(
                                'Chat',
                                style: TextStyle(
                                  color: AppColors.successGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFA7F3D0),
                                ),
                                backgroundColor: const Color(0xFFECFDF5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            if (worker != null) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  final owner = PropertyOwner(
                                    id: worker.id,
                                    firstName: worker.firstName,
                                    lastName: worker.lastName,
                                    profilePhotoUrl: worker.profilePhotoUrl,
                                    createdAt: currentApp.createdAt
                                        .toIso8601String(),
                                    email: worker.email,
                                    phoneNumber: worker.phoneNumber,
                                    coverLetter: currentApp.coverLetter,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.publicProfile,
                                    arguments: owner,
                                  );
                                },
                                icon: SvgPicture.asset(
                                  AppIcons.OpenLink,
                                  width: 14,
                                  height: 14,
                                ),
                                label: const Text(
                                  'Profile',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                    color: AppColors.slate700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Status Banner
                _buildStatusBanner(status),

                const SizedBox(height: 16),

                // 3. Work Details & Pricing Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.2,
                    ),
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
                      const Text(
                        'Request Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildInfoRow(
                        icon: AppIcons.workerSvg,
                        label: 'Service',
                        value: serviceName,
                        valueColor: const Color(0xFF111827),
                        isBold: true,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        icon: AppIcons.locationSvg,
                        label: 'Location',
                        value: location,
                        valueColor: const Color(0xFF111827),
                        isBold: true,
                      ),
                      const SizedBox(height: 12),

                      if (workRequest?.dateNeeded != null) ...[
                        _buildInfoRow(
                          icon: AppIcons.calendarSvg,
                          label: 'Date Needed',
                          value: _formatDate(workRequest!.dateNeeded),
                          valueColor: const Color(0xFF111827),
                          isBold: true,
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (workRequest?.startTime.isNotEmpty == true &&
                          workRequest?.endTime.isNotEmpty == true) ...[
                        _buildInfoRow(
                          icon: AppIcons.TimerSvg,
                          label: 'Working Hours',
                          value:
                              '${workRequest!.startTime} - ${workRequest.endTime}',
                          valueColor: const Color(0xFF111827),
                          isBold: true,
                        ),
                        const SizedBox(height: 12),
                      ],

                      _buildInfoRow(
                        icon: AppIcons.TagSvg,
                        label: 'Budget Type',
                        value: budgetType,
                        valueColor: const Color(0xFF111827),
                        isBold: false,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        icon: AppIcons.TagSvg,
                        label: 'Budget Offer',
                        value: originalBudget,
                        valueColor: const Color(0xFF111827),
                        isBold: true,
                      ),

                      if (currentApp.proposedPrice != null &&
                          currentApp.proposedPrice!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: AppIcons.TagSvg,
                          label: 'Proposed Price',
                          value: budgetDisplay,
                          valueColor: const Color(0xFF2563EB),
                          isBold: true,
                        ),
                      ],

                      if (workRequest?.isUrgentRequest == true) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🚨 ', style: TextStyle(fontSize: 14)),
                              Text(
                                'Urgent Request',
                                style: TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 4. Description / Task Details
                if (workRequest?.description.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.2,
                      ),
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
                        const Text(
                          'Task Description',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          workRequest!.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 5. Cover Letter / Worker Proposal (if any)
                if (currentApp.coverLetter != null &&
                    currentApp.coverLetter!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.2,
                      ),
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
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.newspaperSvg,
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                AppColors.vibrantBlue,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Submitted Proposal / Message',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            currentApp.coverLetter!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF334155),
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 6. Reference Photos (if any)
                if (workRequest?.referencePhotos.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reference Photos',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: workRequest!.referencePhotos.length,
                            separatorBuilder: (ctx, idx) =>
                                const SizedBox(width: 10),
                            itemBuilder: (ctx, index) {
                              final photo = workRequest.referencePhotos[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  photo.url,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    width: 90,
                                    height: 90,
                                    color: const Color(0xFFF1F5F9),
                                    child: SvgPicture.asset(
                                      AppIcons.personSvg,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.slate400,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // 7. Action Buttons (Exact UI from user screenshot)
                Builder(
                  builder: (context) {
                    if (status == NeedAWorkerApplicationStatus.pending) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF0FDF4,
                          ), // Light green tint container
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFBBF7D0),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Simulate Worker Response:',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D), // Forest green
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                // Accept Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _confirmAccept(
                                      context,
                                      currentApp,
                                      vm,
                                      workRequest,
                                      name,
                                      photoUrl,
                                    ),
                                    icon: const Text(
                                      '✅',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    label: const Text(
                                      'Accept',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF16A34A),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Decline Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _confirmDecline(context, currentApp, vm),
                                    icon: const Text(
                                      '❌',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    label: const Text(
                                      'Decline',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else if (status ==
                        NeedAWorkerApplicationStatus.accepted) {
                      return CustomButton(
                        text: 'Contact Requester / Worker',
                        svgAsset: AppIcons.chatRoundSvg,
                        isLoading: vm.isChatStarting,
                        onPressed: () => _openChatWithWorker(
                          context: context,
                          currentApp: currentApp,
                          workRequest: workRequest,
                          name: name,
                          photoUrl: photoUrl,
                        ),
                        backgroundColor: const Color(0xFF16A34A),
                        height: 52,
                        borderRadius: 14,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(NeedAWorkerApplicationStatus status) {
    String title;
    String description;
    Color bg;
    Color border;
    Color textCol;
    String emoji;

    switch (status) {
      case NeedAWorkerApplicationStatus.pending:
        title = 'Pending Response';
        description =
            'Review the request details above and choose to accept or decline the hire request.';
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFDE68A);
        textCol = const Color(0xFFD97706);
        emoji = '⏳';
        break;
      case NeedAWorkerApplicationStatus.accepted:
        title = 'Request Accepted';
        description =
            'You have accepted this request! You can now communicate with the person to finalize the job.';
        bg = const Color(0xFFECFDF5);
        border = const Color(0xFFA7F3D0);
        textCol = const Color(0xFF059669);
        emoji = '🎉';
        break;
      case NeedAWorkerApplicationStatus.rejected:
        title = 'Request Declined';
        description = 'This request was declined.';
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFECACA);
        textCol = const Color(0xFFDC2626);
        emoji = '❌';
        break;
      case NeedAWorkerApplicationStatus.withdrawn:
        title = 'Request Withdrawn';
        description = 'The requester or worker has withdrawn this request.';
        bg = const Color(0xFFF1F5F9);
        border = const Color(0xFFCBD5E1);
        textCol = const Color(0xFF64748B);
        emoji = '↩️';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textCol,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: textCol.withValues(alpha: 0.85),
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String icon,
    required String label,
    required String value,
    required Color valueColor,
    required bool isBold,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Color(0xFF6B7280),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  void _confirmAccept(
    BuildContext context,
    NeedWorkerApplicationModel currentApp,
    NeedWorkerViewModel vm,
    NeedWorkerModel? workRequest,
    String name,
    String? photoUrl,
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
              final success = await vm.acceptApplication(currentApp.id);
              if (!context.mounted) return;
              if (success) {
                _showSuccessDialog(
                  context,
                  title: 'Request Accepted',
                  message:
                      'You have successfully accepted this worker request. You can now coordinate with them directly.',
                  isAccept: true,
                  onChatPressed: () => _openChatWithWorker(
                    context: context,
                    currentApp: currentApp,
                    workRequest: workRequest,
                    name: name,
                    photoUrl: photoUrl,
                  ),
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
    NeedWorkerApplicationModel currentApp,
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
              final success = await vm.rejectApplication(currentApp.id);
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
    VoidCallback? onChatPressed,
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
                if (isAccept && onChatPressed != null) ...[
                  CustomButton(
                    text: 'Chat with Worker',
                    svgAsset: AppIcons.chatRoundSvg,
                    onPressed: () {
                      Navigator.pop(ctx);
                      onChatPressed();
                    },
                    backgroundColor: const Color(0xFF16A34A),
                    height: 48,
                    borderRadius: 12,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.slate600,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ] else ...[
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
