import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/models/chat_model.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/models/job_model.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/favourite_ads_viewmodel.dart';
import 'package:desilynks/views/chat/chat_detail_view.dart';
import 'package:desilynks/core/utils/app_share_helper.dart';

class JobDetailView extends StatelessWidget {
  final dynamic job;

  const JobDetailView({super.key, this.job});

  void _showApplyDialog(
    BuildContext context,
    JobModel jobModel,
    JobsViewModel viewModel,
  ) {
    viewModel.clearCoverLetter();
    bool isSubmitting = false;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final String text = viewModel.coverLetterController.text;
            final int charCount = text.length;
            final bool isTooShort = text.isNotEmpty && charCount < 100;
            final bool isTooLong = charCount > 750;
            final bool isValidCoverLetter =
                text.isEmpty || (charCount >= 100 && charCount <= 750);

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  context.scale(20).clamp(16.0, 24.0),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 8,
              insetPadding: EdgeInsets.symmetric(
                horizontal: context.scale(20).clamp(16.0, 28.0),
                vertical: context.scale(20).clamp(16.0, 28.0),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.scale(460).clamp(320.0, 480.0),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.cardPad,
                      vertical: context.scale(20).clamp(16.0, 24.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          'Apply for ${jobModel.title}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(18).clamp(16.0, 21.0),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: context.scale(4).clamp(3.0, 6.0)),
                        Text(
                          jobModel.companyName.isNotEmpty
                              ? jobModel.companyName
                              : 'Submit your application',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(13).clamp(12.0, 15.0),
                            color: AppColors.slate500,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: context.scale(16).clamp(12.0, 20.0)),

                        // Cover Letter Label & Info
                        Text(
                          'Cover Letter (Optional)',
                          style: TextStyle(
                            fontSize: context.sp(13).clamp(12.0, 15.0),
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: context.scale(4).clamp(3.0, 6.0)),
                        Text(
                          'Leave empty, or provide 100-750 characters.',
                          style: TextStyle(
                            fontSize: context.sp(11).clamp(10.0, 13.0),
                            color: AppColors.slate500,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: context.scale(8).clamp(6.0, 10.0)),

                        // TextField
                        TextField(
                          controller: viewModel.coverLetterController,
                          maxLines: 4,
                          enabled: !isSubmitting,
                          onChanged: (_) => setDialogState(() {}),
                          style: TextStyle(
                            fontSize: context.sp(13).clamp(12.0, 15.0),
                            color: AppColors.slate800,
                            fontFamily: 'Inter',
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Describe why you are a good fit for this role...',
                            hintStyle: TextStyle(
                              color: AppColors.gray400,
                              fontSize: context.sp(12).clamp(11.0, 14.0),
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundOffWhite,
                            contentPadding: EdgeInsets.all(
                              context.scale(12).clamp(10.0, 14.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                context.scale(12).clamp(10.0, 14.0),
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.slate200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                context.scale(12).clamp(10.0, 14.0),
                              ),
                              borderSide: BorderSide(
                                color: (isTooShort || isTooLong)
                                    ? AppColors.primaryRed
                                    : AppColors.slate200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                context.scale(12).clamp(10.0, 14.0),
                              ),
                              borderSide: BorderSide(
                                color: (isTooShort || isTooLong)
                                    ? AppColors.primaryRed
                                    : AppColors.vibrantBlue,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        if (isTooShort || isTooLong) ...[
                          SizedBox(height: context.scale(6).clamp(4.0, 8.0)),
                          Text(
                            isTooShort
                                ? 'Cover letter must be at least 100 characters (or leave blank).'
                                : 'Cover letter cannot exceed 750 characters.',
                            style: TextStyle(
                              fontSize: context.sp(11).clamp(10.0, 13.0),
                              color: AppColors.primaryRed,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                        SizedBox(height: context.scale(20).clamp(16.0, 24.0)),

                        // Action Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: context.scale(48).clamp(44.0, 52.0),
                                child: OutlinedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => Navigator.pop(dialogContext),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.slate200,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        context.scale(12).clamp(10.0, 14.0),
                                      ),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AppColors.slate700,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            context.sp(14).clamp(13.0, 16.0),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: context.scale(10).clamp(8.0, 12.0)),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: context.scale(48).clamp(44.0, 52.0),
                                child: ElevatedButton(
                                  onPressed:
                                      (!isValidCoverLetter || isSubmitting)
                                      ? null
                                      : () async {
                                          setDialogState(() {
                                            isSubmitting = true;
                                          });
                                          final coverLetter = viewModel
                                              .coverLetterController
                                              .text
                                              .trim();
                                          final success = await viewModel
                                              .applyForJob(
                                                jobModel.id,
                                                coverLetter:
                                                    coverLetter.isNotEmpty
                                                    ? coverLetter
                                                    : null,
                                              );
                                          if (dialogContext.mounted) {
                                            Navigator.pop(dialogContext);
                                          }
                                          if (context.mounted) {
                                            if (success) {
                                              _showSuccessDialog(context);
                                            } else {
                                              _showErrorDialog(
                                                context,
                                                viewModel.errorMessage ??
                                                    'Failed to submit application.',
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.vibrantBlue,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        context.scale(12).clamp(10.0, 14.0),
                                      ),
                                    ),
                                  ),
                                  child: isSubmitting
                                      ? SizedBox(
                                          width: context
                                              .scale(20)
                                              .clamp(18.0, 24.0),
                                          height: context
                                              .scale(20)
                                              .clamp(18.0, 24.0),
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                        )
                                      : FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Submit',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: context
                                                  .sp(15)
                                                  .clamp(14.0, 17.0),
                                              fontFamily: 'Inter',
                                            ),
                                          ),
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
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      routeSettings: const RouteSettings(name: '/my-applications'),
      builder: (ctx) {
        final double circleSize = context.scale(76).clamp(64.0, 84.0);
        final double iconSize = context.scale(32).clamp(26.0, 38.0);

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              context.scale(24).clamp(20.0, 28.0),
            ),
          ),
          elevation: 8,
          insetPadding: EdgeInsets.symmetric(
            horizontal: context.scale(24).clamp(16.0, 32.0),
            vertical: context.scale(24).clamp(16.0, 32.0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.scale(340).clamp(290.0, 360.0),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(24).clamp(20.0, 30.0),
                  vertical: context.scale(28).clamp(24.0, 34.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Light Green Circle with Green Checkmark Icon
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppIcons.tickSvg,
                        width: iconSize,
                        height: iconSize,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF16A34A),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: context.scale(20).clamp(16.0, 24.0)),

                    // Title Text
                    Text(
                      'Application Submitted!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.sp(19).clamp(17.0, 22.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: context.scale(8).clamp(6.0, 10.0)),

                    // Subtitle Text
                    Text(
                      'Your application has been sent.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.sp(14).clamp(13.0, 16.0),
                        color: AppColors.slate500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: context.scale(24).clamp(20.0, 28.0)),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: context.scale(48).clamp(44.0, 52.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vibrantBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              context.scale(12).clamp(10.0, 14.0),
                            ),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: context.sp(15).clamp(14.0, 17.0),
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
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        final double circleSize = context.scale(76).clamp(64.0, 84.0);
        final double iconSize = context.scale(32).clamp(26.0, 38.0);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              context.scale(24).clamp(20.0, 28.0),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          insetPadding: EdgeInsets.symmetric(
            horizontal: context.scale(24).clamp(16.0, 32.0),
            vertical: context.scale(24).clamp(16.0, 32.0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.scale(340).clamp(290.0, 360.0),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(24).clamp(20.0, 30.0),
                  vertical: context.scale(28).clamp(24.0, 34.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: const BoxDecoration(
                        color: AppColors.softRed,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppIcons.infoSvg,
                        width: iconSize,
                        height: iconSize,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryRed,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: context.scale(20).clamp(16.0, 24.0)),
                    Text(
                      'Application Notice',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.sp(18).clamp(16.0, 21.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: context.scale(8).clamp(6.0, 10.0)),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.sp(14).clamp(13.0, 16.0),
                        color: AppColors.slate600,
                        fontFamily: 'Inter',
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: context.scale(24).clamp(20.0, 28.0)),
                    SizedBox(
                      width: double.infinity,
                      height: context.scale(48).clamp(44.0, 52.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vibrantBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              context.scale(12).clamp(10.0, 14.0),
                            ),
                          ),
                        ),
                        child: Text(
                          'Got it',
                          style: TextStyle(
                            fontSize: context.sp(15).clamp(14.0, 17.0),
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
            ),
          ),
        );
      },
    );
  }

  void _handleContactEmployer(BuildContext context, JobModel? jobModel) {
    if (jobModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employer information not available.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final employerId = jobModel.employerId.isNotEmpty
        ? jobModel.employerId
        : (jobModel.employer?.id ?? '');

    if (employerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot initiate chat: Employer ID is missing.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final conv = ChatConversationModel(
      id: 'job_${jobModel.id}_$employerId',
      otherParticipant: ChatParticipantModel(
        id: employerId,
        firstName: jobModel.employer?.firstName.isNotEmpty == true
            ? jobModel.employer!.firstName
            : (jobModel.companyName.isNotEmpty
                  ? jobModel.companyName
                  : 'Employer'),
        lastName: jobModel.employer?.lastName ?? '',
        profilePhotoUrl: jobModel.employer?.profilePhotoUrl,
      ),
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatDetailView(conversation: conv)),
    );
  }

  void _shareJob(
    BuildContext context,
    String id,
    String title,
    String company,
    String salary,
    String location,
  ) {
    AppShareHelper.shareAsLink(
      context: context,
      type: ShareItemType.job,
      id: id,
      title: title.isNotEmpty ? '$title at $company' : company,
      description: '$location • $salary',
    );
  }

  void _openFullScreenImageViewer(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Zoomable & Pannable Image
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.slate900,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Top Bar with Back / Close Button
              Positioned(
                top: MediaQuery.of(ctx).padding.top + 10,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      AppIcons.arrowBackSvg,
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<JobsViewModel>();
    final authVM = context.watch<AuthViewModel>();

    final dynamic effectiveJobArg =
        job ?? ModalRoute.of(context)?.settings.arguments;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (effectiveJobArg is String) {
        final vm = context.read<JobsViewModel>();
        if (vm.selectedJob?.id != effectiveJobArg && !vm.isLoading) {
          vm.fetchJobDetails(effectiveJobArg);
        }
      }
    });

    final jobModel = viewModel.getJobModel(effectiveJobArg);

    if (effectiveJobArg is String && viewModel.isLoading && jobModel == null) {
      return Scaffold(
        backgroundColor: AppColors.slate50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              AppIcons.assetBackArrowSvg,
              height: context.scale(20).clamp(18.0, 24.0),
              width: context.scale(20).clamp(18.0, 24.0),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Job Details',
            style: TextStyle(
              color: AppColors.slate800,
              fontSize: context.sp(18).clamp(16.0, 21.0),
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.vibrantBlue),
        ),
      );
    }

    // Dynamic extraction with fallbacks for raw maps
    final Map<String, dynamic>? rawMap = effectiveJobArg is Map<String, dynamic>
        ? effectiveJobArg as Map<String, dynamic>?
        : null;

    final String title =
        jobModel?.title ?? rawMap?['title'] ?? 'Waiter Required';
    final String company =
        jobModel?.companyName ?? rawMap?['companyName'] ?? '';
    final String location =
        jobModel?.location ?? rawMap?['location'] ?? 'Barcelona, Spain';
    final String type =
        jobModel?.type.displayName ?? rawMap?['type'] ?? 'Full Time';
    final String salary = jobModel != null
        ? '€${jobModel.salary} / ${jobModel.salaryPeriod.displayName}'
        : (rawMap?['salary'] ?? '€1,200/month');
    final String imageUrl =
        (jobModel?.posterUrl != null && jobModel!.posterUrl!.isNotEmpty)
        ? jobModel.posterUrl!
        : (rawMap?['imageUrl'] ??
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80');
    final String description =
        jobModel?.description ??
        rawMap?['description'] ??
        'We need an experienced waiter for our desi restaurant.';

    // Construct requirements list from job model fields or fallback
    List<String> requirements = [];
    if (jobModel != null) {
      if (jobModel.requiredSkills.isNotEmpty) {
        requirements.addAll(
          jobModel.requiredSkills
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty),
        );
      }
      if (jobModel.experience != Experience.noExperience) {
        requirements.add('Experience: ${jobModel.experience.displayName}');
      }
      if (jobModel.languages.isNotEmpty) {
        requirements.add(
          'Languages: ${jobModel.languages.map((l) => l.displayName).join(", ")}',
        );
      }
    }
    if (requirements.isEmpty) {
      requirements =
          (rawMap?['requirements'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [
            'Experience in cooking',
            'Must be hardworking',
            'Able to work in team',
          ];
    }

    final String postedDate = jobModel != null
        ? 'Posted on: ${jobModel.createdAt.day} ${_getMonthName(jobModel.createdAt.month)} ${jobModel.createdAt.year}'
        : (rawMap?['postedDate'] ?? 'Posted on: 20 May 2024');

    final String currentJobId =
        jobModel?.id ?? (effectiveJobArg is String ? effectiveJobArg : '');
    final bool isApplied = currentJobId.isNotEmpty
        ? viewModel.isUserAppliedToJob(currentJobId)
        : (jobModel?.isApplied ?? false);

    final currentUserId = authVM.currentUser?.id;
    final bool isOwner =
        currentUserId != null &&
        currentUserId.isNotEmpty &&
        (jobModel?.employerId == currentUserId ||
            jobModel?.employer?.id == currentUserId ||
            rawMap?['employerId'] == currentUserId ||
            rawMap?['userId'] == currentUserId);

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.assetBackArrowSvg,
            height: context.scale(20).clamp(18.0, 24.0),
            width: context.scale(20).clamp(18.0, 24.0),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Details',
          style: TextStyle(
            color: AppColors.slate800,
            fontSize: context.sp(18).clamp(16.0, 21.0),
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        actions: [
          // Bookmark Button
          Consumer<JobsViewModel>(
            builder: (context, jobsVM, _) {
              final jobId = jobModel?.id ?? currentJobId;
              final bool isBookmarked = jobsVM.isJobBookmarked(jobId);
              final double btnSize = context.scale(36).clamp(32.0, 42.0);
              final double iconSize = context.scale(18).clamp(16.0, 22.0);

              return GestureDetector(
                onTap: () {
                  final resolvedJob = jobModel ?? jobsVM.getJobModel(jobId);
                  final favVM = Provider.of<FavouriteAdsViewModel>(
                    context,
                    listen: false,
                  );
                  final bool nowBookmarked = jobsVM.toggleBookmarkJob(
                    jobId,
                    job: resolvedJob,
                    favViewModel: favVM,
                  );
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        nowBookmarked
                            ? 'Job bookmarked successfully!'
                            : 'Bookmark removed.',
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  height: btnSize,
                  width: btnSize,
                  margin: EdgeInsets.only(
                    right: context.scale(8).clamp(6.0, 10.0),
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.slate100,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AppIcons.bookmark,
                    colorFilter: ColorFilter.mode(
                      isBookmarked ? AppColors.vibrantBlue : AppColors.slate800,
                      BlendMode.srcIn,
                    ),
                    height: iconSize,
                    width: iconSize,
                  ),
                ),
              );
            },
          ),
          // Share Button
          GestureDetector(
            onTap: () => _shareJob(context, currentJobId, title, company, salary, location),
            child: Container(
              height: context.scale(36).clamp(32.0, 42.0),
              width: context.scale(36).clamp(32.0, 42.0),
              margin: EdgeInsets.only(
                right: context.scale(16).clamp(12.0, 20.0),
              ),
              decoration: const BoxDecoration(
                color: AppColors.slate100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppIcons.shareSvg,
                height: context.scale(18).clamp(16.0, 22.0),
                width: context.scale(18).clamp(16.0, 22.0),
                colorFilter: const ColorFilter.mode(
                  AppColors.slate800,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
              vertical: context.scale(16).clamp(12.0, 20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Media Image Banner
                GestureDetector(
                  onTap: () => _openFullScreenImageViewer(context, imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      context.scale(16).clamp(12.0, 18.0),
                    ),
                    child: Image.network(
                      imageUrl,
                      height: context.scaleH(180).clamp(160.0, 240.0),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: context.scaleH(180).clamp(160.0, 240.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.slate200,
                            borderRadius: BorderRadius.circular(
                              context.scale(16).clamp(12.0, 18.0),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            AppIcons.businessSvg,
                            width: context.scale(48).clamp(40.0, 56.0),
                            height: context.scale(48).clamp(40.0, 56.0),
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate400,
                              BlendMode.srcIn,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: context.scale(16).clamp(12.0, 20.0)),

                // Job Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.sp(20).clamp(18.0, 24.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: context.scale(4).clamp(3.0, 6.0)),

                // Salary Text
                Text(
                  salary,
                  style: TextStyle(
                    fontSize: context.sp(16).clamp(14.0, 18.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.vibrantBlue,
                    fontFamily: 'Inter',
                  ),
                ),
                if (company.isNotEmpty) ...[
                  SizedBox(height: context.scale(6).clamp(4.0, 8.0)),
                  GestureDetector(
                    onTap: () {
                      final employerId = jobModel?.employerId.isNotEmpty == true
                          ? jobModel!.employerId
                          : (jobModel?.employer?.id ?? '');
                      if (employerId.isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.publicProfile,
                          arguments: employerId,
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business_center_outlined,
                          size: context.scale(16).clamp(14.0, 18.0),
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(width: context.scale(6).clamp(4.0, 8.0)),
                        Text(
                          company,
                          style: TextStyle(
                            fontSize: context.sp(14).clamp(12.0, 15.0),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                            fontFamily: 'Inter',
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: context.scale(8).clamp(6.0, 12.0)),

                // Job Type Chip & Location Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scale(10).clamp(8.0, 14.0),
                        vertical: context.scale(4).clamp(3.0, 6.0),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(
                          context.scale(12).clamp(10.0, 14.0),
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: AppColors.emerald,
                          fontSize: context.sp(12).clamp(11.0, 13.0),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    SizedBox(width: context.scale(12).clamp(8.0, 14.0)),
                    Expanded(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.locationSvg,
                            width: context.scale(16).clamp(14.0, 20.0),
                            height: context.scale(16).clamp(14.0, 20.0),
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate500,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: context.scale(4).clamp(3.0, 6.0)),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(
                                fontSize: context.sp(13).clamp(12.0, 15.0),
                                color: AppColors.slate500,
                                fontFamily: 'Inter',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scale(16).clamp(12.0, 20.0)),

                // Job Description & Requirements Card (Matching Mockup)
                Container(
                  padding: EdgeInsets.all(context.cardPad),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      context.scale(16).clamp(12.0, 18.0),
                    ),
                    border: Border.all(
                      color: AppColors.slate200.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Description',
                        style: TextStyle(
                          fontSize: context.sp(16).clamp(14.0, 18.0),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: context.scale(8).clamp(6.0, 10.0)),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: context.sp(14).clamp(13.0, 16.0),
                          color: AppColors.slate700,
                          fontFamily: 'Inter',
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: context.scale(16).clamp(12.0, 20.0)),
                      Text(
                        'Requirements',
                        style: TextStyle(
                          fontSize: context.sp(16).clamp(14.0, 18.0),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: context.scale(8).clamp(6.0, 10.0)),
                      ...requirements.map(
                        (req) => Padding(
                          padding: EdgeInsets.only(
                            bottom: context.scale(6).clamp(4.0, 8.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: context.scale(2).clamp(1.0, 3.0),
                                ),
                                child: SvgPicture.asset(
                                  AppIcons.tickSvg,
                                  width: context.scale(16).clamp(14.0, 20.0),
                                  height: context.scale(16).clamp(14.0, 20.0),
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.emerald,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                              Expanded(
                                child: Text(
                                  req,
                                  style: TextStyle(
                                    fontSize: context.sp(13).clamp(12.0, 15.0),
                                    color: AppColors.slate700,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: context.scale(12).clamp(8.0, 14.0)),
                      Text(
                        postedDate,
                        style: TextStyle(
                          fontSize: context.sp(12).clamp(11.0, 13.0),
                          color: AppColors.slate400,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.scale(16).clamp(12.0, 20.0)),

                // Contact Card
                Container(
                  padding: EdgeInsets.all(context.cardPad),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      context.scale(16).clamp(12.0, 18.0),
                    ),
                    border: Border.all(
                      color: AppColors.slate200.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact',
                        style: TextStyle(
                          fontSize: context.sp(16).clamp(14.0, 18.0),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: context.scale(12).clamp(8.0, 16.0)),
                      Row(
                        children: [
                          // Chat Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final resolvedJob =
                                    jobModel ?? viewModel.getJobModel(currentJobId);
                                _handleContactEmployer(context, resolvedJob);
                              },
                              icon: SvgPicture.asset(
                                AppIcons.chatRoundSvg,
                                width: context.scale(18).clamp(16.0, 22.0),
                                height: context.scale(18).clamp(16.0, 22.0),
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Chat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.sp(14).clamp(12.0, 16.0),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  vertical: context.scale(12).clamp(10.0, 16.0),
                                  horizontal: context.scale(8).clamp(6.0, 12.0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    context.scale(12).clamp(10.0, 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: context.scale(12).clamp(8.0, 14.0)),
                          // Call Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Dialing employer...'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: SvgPicture.asset(
                                AppIcons.callSvg,
                                width: context.scale(18).clamp(16.0, 22.0),
                                height: context.scale(18).clamp(16.0, 22.0),
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Call',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.sp(14).clamp(12.0, 16.0),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.vibrantBlue,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  vertical: context.scale(12).clamp(10.0, 16.0),
                                  horizontal: context.scale(8).clamp(6.0, 12.0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    context.scale(12).clamp(10.0, 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.scale(20).clamp(16.0, 24.0)),
              ],
            ),
          ),
        ),
      ),

      // Fixed Bottom Action Bar with heightFactor: 1.0 (Guarantees no full-screen stretch)
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.hMargin,
            vertical: context.scale(12).clamp(10.0, 16.0),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: isOwner
                  ? Row(
                      children: [
                        // Edit Job Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.editJob,
                                arguments: jobModel ?? effectiveJobArg,
                              );
                            },
                            icon: SvgPicture.asset(
                              AppIcons.editSvg,
                              width: context.scale(16).clamp(14.0, 20.0),
                              height: context.scale(16).clamp(14.0, 20.0),
                              colorFilter: const ColorFilter.mode(
                                AppColors.vibrantBlue,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Edit Job',
                                style: TextStyle(
                                  color: AppColors.vibrantBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.sp(14).clamp(12.0, 16.0),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: context.scale(14).clamp(12.0, 16.0),
                              ),
                              side: const BorderSide(
                                color: AppColors.vibrantBlue,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  context.scale(12).clamp(10.0, 14.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.scale(12).clamp(8.0, 14.0)),
                        // View Applicants Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.applicants,
                                arguments: jobModel?.id ?? currentJobId,
                              );
                            },
                            icon: SvgPicture.asset(
                              AppIcons.personSvg,
                              width: context.scale(18).clamp(16.0, 22.0),
                              height: context.scale(18).clamp(16.0, 22.0),
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Applicants',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.sp(14).clamp(12.0, 16.0),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.vibrantBlue,
                              padding: EdgeInsets.symmetric(
                                vertical: context.scale(14).clamp(12.0, 16.0),
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  context.scale(12).clamp(10.0, 14.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // Contact Outlined Button
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _handleContactEmployer(context, jobModel),
                            icon: SvgPicture.asset(
                              AppIcons.chatRoundSvg,
                              width: context.scale(18).clamp(16.0, 22.0),
                              height: context.scale(18).clamp(16.0, 22.0),
                              colorFilter: const ColorFilter.mode(
                                AppColors.vibrantBlue,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Contact',
                                style: TextStyle(
                                  color: AppColors.vibrantBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.sp(14).clamp(12.0, 16.0),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: context.scale(14).clamp(12.0, 16.0),
                                horizontal: context.scale(8).clamp(6.0, 10.0),
                              ),
                              side: const BorderSide(
                                color: AppColors.vibrantBlue,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  context.scale(12).clamp(10.0, 14.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.scale(12).clamp(8.0, 14.0)),
                        // Apply Now Button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : () {
                                    if (isApplied) {
                                      _showErrorDialog(
                                        context,
                                        'You have already applied for this job',
                                      );
                                    } else if (jobModel != null) {
                                      _showApplyDialog(
                                        context,
                                        jobModel,
                                        viewModel,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isApplied
                                  ? AppColors.slate300
                                  : AppColors.secondaryPurple,
                              padding: EdgeInsets.symmetric(
                                vertical: context.scale(14).clamp(12.0, 16.0),
                                horizontal: context.scale(8).clamp(6.0, 10.0),
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  context.scale(12).clamp(10.0, 14.0),
                                ),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isApplied ? 'Applied' : 'Apply Now',
                                style: TextStyle(
                                  fontSize: context.sp(15).clamp(13.0, 17.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
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
    if (month >= 1 && month <= 12) return months[month - 1];
    return 'May';
  }
}
