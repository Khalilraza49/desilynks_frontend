import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/models/need_worker_enums.dart';
import 'package:desilynks/models/need_worker_model.dart';
import 'package:desilynks/viewmodels/create_post/need_worker_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/worker_viewmodel.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/widgets/custom_text_field.dart';

class ApplyWorkRequestView extends StatelessWidget {
  final NeedWorkerModel post;

  const ApplyWorkRequestView({
    super.key,
    required this.post,
  });

  void _initForm(NeedWorkerViewModel vm) {
    if (vm.applyPriceController.text.isEmpty) {
      vm.initApplyForm(post.budget);
    }
  }

  Future<void> _submitRequest(BuildContext context) async {
    final needWorkerVM = context.read<NeedWorkerViewModel>();
    if (needWorkerVM.isApplying) return;

    final proposedPrice = needWorkerVM.applyPriceController.text.trim();
    final coverLetter = needWorkerVM.applyCoverLetterController.text.trim();

    if (proposedPrice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your proposed price'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    needWorkerVM.setIsApplying(true);

    final workerVM = context.read<WorkerViewModel>();

    final success = await needWorkerVM.applyToPost(
      post.id,
      coverLetter: coverLetter.isEmpty ? null : coverLetter,
      proposedPrice: proposedPrice,
    );

    needWorkerVM.setIsApplying(false);

    if (!context.mounted) return;

    if (success) {
      final tradeName =
          WorkerTypeX.fromString(post.workerType).displayName;
      workerVM.setLastHireRequestData({
        'workerName': post.requester?.fullName.isNotEmpty == true
            ? post.requester!.fullName
            : tradeName.toUpperCase(),
        'profession': tradeName.toUpperCase(),
        'hourlyRate': proposedPrice,
        'avatar': post.referencePhotos.isNotEmpty
            ? post.referencePhotos.first.url
            : (post.requester?.profilePhotoUrl ?? ''),
        'service': tradeName,
        'location': post.location,
        'budget': proposedPrice,
      });

      needWorkerVM.clearApplyForm();
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.hireWorkerSuccess,
        arguments: workerVM.lastHireRequestData,
      );
    } else {
      final error = needWorkerVM.errorMessage ??
          'Failed to submit application. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildAvatarFallback(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        AppIcons.personSvg,
        colorFilter: const ColorFilter.mode(
          Color(0xFF2563EB),
          BlendMode.srcIn,
        ),
        width: context.scale(28).clamp(24.0, 32.0),
        height: context.scale(28).clamp(24.0, 32.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final needWorkerVM = context.watch<NeedWorkerViewModel>();
    _initForm(needWorkerVM);

    final tradeName =
        WorkerTypeX.fromString(post.workerType).displayName;
    final workerName = tradeName.toUpperCase();
    final profession = tradeName.toUpperCase();
    final hourlyRate = post.budget;
    final avatar = post.referencePhotos.isNotEmpty
        ? post.referencePhotos.first.url
        : (post.requester?.profilePhotoUrl ?? '');
    final isOneTime = post.budgetType.toUpperCase() != 'HOURLY';
    final isBusy = needWorkerVM.isApplying || needWorkerVM.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate900,
              BlendMode.srcIn,
            ),
            height: context.scaleH(18).clamp(15.0, 22.0),
            width: context.scale(18).clamp(15.0, 22.0),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hire $workerName',
          style: TextStyle(
            fontSize: context.sp(18).clamp(16.0, 21.0),
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.hMargin,
            vertical: context.scaleH(12).clamp(8.0, 16.0),
          ),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.scaleH(8).clamp(4.0, 12.0)),

              // 1. Worker / Request Summary Header Card
              Container(
                padding: EdgeInsets.all(context.scale(16).clamp(12.0, 18.0)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    context.scale(16).clamp(12.0, 18.0),
                  ),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.blackOpacity4,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar Thumbnail (Square with rounded corners)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        context.scale(12).clamp(10.0, 14.0),
                      ),
                      child: Container(
                        width: context.scale(56).clamp(48.0, 64.0),
                        height: context.scale(56).clamp(48.0, 64.0),
                        color: const Color(0xFFEFF6FF),
                        child: avatar.isNotEmpty
                            ? Image.network(
                                avatar,
                                width: context.scale(56).clamp(48.0, 64.0),
                                height: context.scale(56).clamp(48.0, 64.0),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarFallback(context),
                              )
                            : _buildAvatarFallback(context),
                      ),
                    ),
                    SizedBox(width: context.scale(14).clamp(10.0, 16.0)),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workerName,
                            style: TextStyle(
                              fontSize: context.sp(16).clamp(14.0, 18.0),
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          SizedBox(height: context.scaleH(2).clamp(1.0, 4.0)),
                          Text(
                            profession,
                            style: TextStyle(
                              fontSize: context.sp(13).clamp(11.0, 14.0),
                              color: AppColors.slate500,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          SizedBox(height: context.scaleH(6).clamp(4.0, 8.0)),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.starFavoriteSvg,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFF59E0B),
                                  BlendMode.srcIn,
                                ),
                                width: context.scale(15).clamp(13.0, 17.0),
                                height: context.scale(15).clamp(13.0, 17.0),
                              ),
                              SizedBox(width: context.scale(4).clamp(2.0, 5.0)),
                              Text(
                                '4.9',
                                style: TextStyle(
                                  fontSize: context.sp(13).clamp(11.0, 14.0),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.slate800,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              Text(
                                ' (128)',
                                style: TextStyle(
                                  fontSize: context.sp(12).clamp(10.0, 13.0),
                                  color: AppColors.slate400,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              const Text(
                                '  •  ',
                                style: TextStyle(color: AppColors.slate300),
                              ),
                              Text(
                                '€$hourlyRate/hour',
                                style: TextStyle(
                                  fontSize: context.sp(13).clamp(11.0, 14.0),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2563EB),
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.scaleH(20).clamp(16.0, 24.0)),

              // 2. Select Service (Displaying the requested service)
              Text(
                'Select Service',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(16).clamp(12.0, 18.0),
                  vertical: context.scaleH(12).clamp(10.0, 14.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  border: Border.all(
                    color: const Color(0xFF2563EB),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.blackOpacity4,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tradeName,
                      style: TextStyle(
                        fontSize: context.sp(14).clamp(12.0, 15.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    SvgPicture.asset(
                      AppIcons.arrowDropDownSvg,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF2563EB),
                        BlendMode.srcIn,
                      ),
                      width: context.scale(18).clamp(16.0, 20.0),
                      height: context.scale(18).clamp(16.0, 20.0),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.scaleH(18).clamp(14.0, 22.0)),

              // 3. Describe Your Job (Showing the description posted by requester)
              Text(
                'Describe Your Job',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: context.scaleH(80).clamp(70.0, 100.0),
                ),
                padding: EdgeInsets.all(
                  context.scale(14).clamp(11.0, 16.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  post.description.isNotEmpty
                      ? post.description
                      : 'I need an $profession to fix the wiring issue in my apartment',
                  style: TextStyle(
                    fontSize: context.sp(14).clamp(12.0, 15.0),
                    color: AppColors.slate800,
                    height: 1.4,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),

              SizedBox(height: context.scaleH(18).clamp(14.0, 22.0)),

              // 4. Location (Showing the location posted by requester)
              Text(
                'Location',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(14).clamp(11.0, 16.0),
                  vertical: context.scaleH(12).clamp(10.0, 14.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.locationSvg,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate400,
                        BlendMode.srcIn,
                      ),
                      width: context.scale(18).clamp(16.0, 20.0),
                      height: context.scale(18).clamp(16.0, 20.0),
                    ),
                    SizedBox(width: context.scale(10).clamp(8.0, 12.0)),
                    Expanded(
                      child: Text(
                        post.location.isNotEmpty ? post.location : 'dhjdjd',
                        style: TextStyle(
                          fontSize: context.sp(14).clamp(12.0, 15.0),
                          color: AppColors.slate800,
                          fontFamily: AppStrings.fontInter,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.scaleH(18).clamp(14.0, 22.0)),

              // 5. Budget (Posted budget amount)
              Text(
                'Budget',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(16).clamp(12.0, 18.0),
                  vertical: context.scaleH(12).clamp(10.0, 14.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '€ ',
                      style: TextStyle(
                        fontSize: context.sp(16).clamp(14.0, 18.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    Text(
                      post.budget.isNotEmpty ? post.budget : '100',
                      style: TextStyle(
                        fontSize: context.sp(15).clamp(13.0, 16.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate800,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.scaleH(18).clamp(14.0, 22.0)),

              // 6. Job Type (Posted job type)
              Text(
                'Job Type',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.scaleH(14).clamp(11.0, 16.0),
                      ),
                      decoration: BoxDecoration(
                        color: isOneTime
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(
                          context.scale(12).clamp(10.0, 14.0),
                        ),
                        border: Border.all(
                          color: isOneTime
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'One Time',
                        style: TextStyle(
                          fontSize: context.sp(14).clamp(12.0, 15.0),
                          fontWeight: FontWeight.bold,
                          color: isOneTime
                              ? Colors.white
                              : AppColors.slate700,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.scale(12).clamp(8.0, 14.0)),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.scaleH(14).clamp(11.0, 16.0),
                      ),
                      decoration: BoxDecoration(
                        color: !isOneTime
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(
                          context.scale(12).clamp(10.0, 14.0),
                        ),
                        border: Border.all(
                          color: !isOneTime
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Recurring',
                        style: TextStyle(
                          fontSize: context.sp(14).clamp(12.0, 15.0),
                          fontWeight: FontWeight.bold,
                          color: !isOneTime
                              ? Colors.white
                              : AppColors.slate700,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.scaleH(24).clamp(18.0, 28.0)),

              // 7. APPLICANT INPUT FORM (The other person fills this to submit to requester)
              Container(
                padding: EdgeInsets.all(context.scale(16).clamp(12.0, 18.0)),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(
                    context.scale(16).clamp(12.0, 18.0),
                  ),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.briefcaseSvg,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF2563EB),
                            BlendMode.srcIn,
                          ),
                          width: context.scale(18).clamp(16.0, 20.0),
                          height: context.scale(18).clamp(16.0, 20.0),
                        ),
                        SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                        Text(
                          'Your Offer to Requester',
                          style: TextStyle(
                            fontSize: context.sp(15).clamp(13.0, 17.0),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.scaleH(4).clamp(2.0, 6.0)),
                    Text(
                      'The requester will review your proposed price and message.',
                      style: TextStyle(
                        fontSize: context.sp(12).clamp(11.0, 13.0),
                        color: AppColors.slate500,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),

                    SizedBox(height: context.scaleH(14).clamp(10.0, 18.0)),

                    // Proposed Price Input
                    Text(
                      'Your Proposed Price (€) *',
                      style: TextStyle(
                        fontSize: context.sp(13).clamp(12.0, 15.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    SizedBox(height: context.scaleH(6).clamp(4.0, 8.0)),
                    CustomTextField(
                      controller: needWorkerVM.applyPriceController,
                      keyboardType: TextInputType.number,
                      hintText: 'e.g. 100',
                      fontSize: context.sp(14).clamp(12.0, 15.0),
                      prefix: Padding(
                        padding: EdgeInsets.only(
                          left: context.scale(16).clamp(12.0, 18.0),
                          right: context.scale(8).clamp(6.0, 10.0),
                        ),
                        child: Text(
                          '€',
                          style: TextStyle(
                            fontSize: context.sp(16).clamp(14.0, 18.0),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                      fillColor: Colors.white,
                      borderRadius: BorderRadius.circular(
                        context.scale(12).clamp(10.0, 14.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.scale(12).clamp(10.0, 14.0),
                        ),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.scale(12).clamp(10.0, 14.0),
                        ),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.8,
                        ),
                      ),
                    ),

                    SizedBox(height: context.scaleH(14).clamp(10.0, 18.0)),

                    // Cover Letter / Message to Requester
                    Text(
                      'Message / Cover Letter to Client',
                      style: TextStyle(
                        fontSize: context.sp(13).clamp(12.0, 15.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    SizedBox(height: context.scaleH(6).clamp(4.0, 8.0)),
                    CustomTextField(
                      controller: needWorkerVM.applyCoverLetterController,
                      hintText:
                          'Explain your experience, availability, or send a proposal...',
                      maxLines: 4,
                      fontSize: context.sp(14).clamp(12.0, 15.0),
                      fillColor: Colors.white,
                      borderRadius: BorderRadius.circular(
                        context.scale(12).clamp(10.0, 14.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.scale(12).clamp(10.0, 14.0),
                        ),
                        borderSide: const BorderSide(
                          color: Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.scale(12).clamp(10.0, 14.0),
                        ),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.scaleH(28).clamp(20.0, 32.0)),

              // 8. Bottom CTA Button - Send Request
              CustomButton(
                text: 'Send Request',
                onPressed: () => _submitRequest(context),
                isLoading: isBusy,
                backgroundColor: const Color(0xFF6366F1),
                height: context.scaleH(50).clamp(46.0, 54.0),
                borderRadius: context.scale(14).clamp(12.0, 16.0),
                fontSize: context.sp(16).clamp(14.0, 18.0),
                fontWeight: FontWeight.bold,
              ),

              SizedBox(height: context.scaleH(20).clamp(14.0, 24.0)),
            ],
          ),
        ),
      ),
    );
  }
}
