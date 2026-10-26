import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/field_label.dart';

class EditJobView extends StatelessWidget {
  final dynamic job;

  const EditJobView({super.key, this.job});

  Future<void> _saveChanges(BuildContext context, JobsViewModel jobsVM) async {
    if (jobsVM.postTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a job title'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final bool success = await jobsVM.saveJobChanges();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job updated successfully!'),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jobsVM.errorMessage ?? 'Failed to update job.'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final dynamic arg = job ?? ModalRoute.of(context)?.settings.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<JobsViewModel>().initEditJob(arg);
      }
    });

    final jobsViewModel = context.watch<JobsViewModel>();
    final effectiveJob = jobsViewModel.resolvedEditJob ??
        jobsViewModel.editingJob ??
        jobsViewModel.selectedJob;

    final String initialImageUrl =
        (effectiveJob?.posterUrl != null && effectiveJob!.posterUrl!.isNotEmpty)
            ? effectiveJob.posterUrl!
            : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80';

    final String postedDate = effectiveJob != null
        ? 'Posted on: ${effectiveJob.createdAt.day} ${_getMonthName(effectiveJob.createdAt.month)} ${effectiveJob.createdAt.year}'
        : 'Posted on: 20 May 2024';

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackBasicSvg,
            height: context.scale(20),
            width: context.scale(20),
            colorFilter: const ColorFilter.mode(
              AppColors.slate800,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Job',
          style: TextStyle(
            color: AppColors.slate800,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: jobsViewModel.isSavingJob
                ? null
                : () => _saveChanges(context, jobsViewModel),
            child: jobsViewModel.isSavingJob
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.vibrantBlue,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.vibrantBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: context.sp(15),
                      fontFamily: 'Inter',
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
              vertical: context.scaleH(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Media Image Banner (With Change Photo overlay)
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.scale(16)),
                  child: Stack(
                    children: [
                      if (jobsViewModel.postPosterFile != null)
                        Image.file(
                          jobsViewModel.postPosterFile!,
                          height: context.scaleH(180).clamp(160.0, 240.0),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      else
                        Image.network(
                          initialImageUrl,
                          height: context.scaleH(180).clamp(160.0, 240.0),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: context.scaleH(180).clamp(160.0, 240.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.slate200,
                                borderRadius:
                                    BorderRadius.circular(context.scale(16)),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                AppIcons.businessSvg,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.slate400,
                                  BlendMode.srcIn,
                                ),
                              ),
                            );
                          },
                        ),
                      // Overlay button to pick/change banner
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => jobsViewModel.pickPosterImage(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.scale(12),
                              vertical: context.scaleH(7),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.65),
                              borderRadius:
                                  BorderRadius.circular(context.scale(20)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  AppIcons.cameraSvg,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                  width: context.scale(14),
                                  height: context.scale(14),
                                ),
                                SizedBox(width: context.scale(6)),
                                Text(
                                  'Change Photo',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: context.sp(12),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
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
                SizedBox(height: context.scaleH(16)),

                // 2. Job Title Field
                FieldLabel(
                  label: 'Job Title',
                  isRequired: true,
                  bottomPadding: context.scaleH(6),
                ),
                CustomTextField(
                  controller: jobsViewModel.postTitleController,
                  hintText: 'e.g. Waiter Required',
                  fillColor: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.vibrantBlue,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.slate200.withValues(alpha: 0.8),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Job title is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.scaleH(12)),

                // 2b. Company / Business Name
                FieldLabel(
                  label: 'Company / Business Name',
                  bottomPadding: context.scaleH(6),
                ),
                CustomTextField(
                  controller: jobsViewModel.postCompanyController,
                  hintText: 'Company / Restaurant name',
                  prefixIconAsset: AppIcons.businessSvg,
                  prefixIconColor: AppColors.slate400,
                  fillColor: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.vibrantBlue,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.slate200.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(12)),

                // 3. Salary Field
                FieldLabel(
                  label: 'Salary',
                  bottomPadding: context.scaleH(6),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: jobsViewModel.postSalaryController,
                        keyboardType: TextInputType.text,
                        hintText: '1,200 - 1,500',
                        fillColor: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        prefix: const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Text(
                            '€',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.vibrantBlue,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.vibrantBlue,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.slate200.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.scale(8)),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 48,
                        padding:
                            EdgeInsets.symmetric(horizontal: context.scale(10)),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.slate200.withValues(alpha: 0.8),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: jobsViewModel.postSalaryPeriods.contains(
                              jobsViewModel.postSalaryPeriod,
                            )
                                ? jobsViewModel.postSalaryPeriod
                                : jobsViewModel.postSalaryPeriods.first,
                            isExpanded: true,
                            icon: SvgPicture.asset(
                              AppIcons.arrowDropDownSvg,
                              colorFilter: const ColorFilter.mode(
                                AppColors.vibrantBlue,
                                BlendMode.srcIn,
                              ),
                              width: 16,
                              height: 16,
                            ),
                            items: jobsViewModel.postSalaryPeriods
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      '/${p.toLowerCase()}',
                                      style: TextStyle(
                                        fontSize: context.sp(13),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.vibrantBlue,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                jobsViewModel.setPostSalaryPeriod(val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scaleH(12)),

                // 4. Job Type Chip Selection & Location Row
                FieldLabel(
                  label: 'Job Type',
                  bottomPadding: context.scaleH(6),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: jobsViewModel.postJobTypes.map((type) {
                      final bool isSelected =
                          jobsViewModel.postJobType == type;
                      return Padding(
                        padding: EdgeInsets.only(right: context.scale(8)),
                        child: InkWell(
                          onTap: () => jobsViewModel.setPostJobType(type),
                          borderRadius:
                              BorderRadius.circular(context.scale(12)),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.scale(12),
                              vertical: context.scaleH(6),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.greenLight
                                  : AppColors.slate100,
                              borderRadius:
                                  BorderRadius.circular(context.scale(12)),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.emerald.withValues(
                                        alpha: 0.3,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.emerald
                                    : AppColors.slate600,
                                fontSize: context.sp(12),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: context.scaleH(12)),

                // Location Input
                FieldLabel(
                  label: 'Location',
                  bottomPadding: context.scaleH(6),
                ),
                CustomTextField(
                  controller: jobsViewModel.postLocationController,
                  hintText: 'Location (e.g. Barcelona, Spain)',
                  prefixIconAsset: AppIcons.locationSvg,
                  prefixIconColor: AppColors.slate500,
                  fillColor: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.vibrantBlue,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.slate200.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(16)),

                // 5. Job Description & Requirements Card
                Container(
                  padding: EdgeInsets.all(context.cardPad),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(context.scale(16)),
                    border: Border.all(
                      color: AppColors.slate200.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Description Heading
                      FieldLabel(
                        label: 'Job Description',
                        bottomPadding: context.scaleH(8),
                      ),
                      CustomTextField(
                        controller: jobsViewModel.postDescriptionController,
                        maxLines: 4,
                        hintText:
                            'We need an experienced waiter for our desi restaurant...',
                        fillColor: AppColors.backgroundOffWhite,
                        borderRadius: BorderRadius.circular(12),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.vibrantBlue,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.slate200,
                          ),
                        ),
                      ),
                      SizedBox(height: context.scaleH(16)),

                      // Requirements Heading
                      FieldLabel(
                        label: 'Requirements',
                        bottomPadding: context.scaleH(8),
                      ),

                      // List of current requirements with tick icons
                      ...jobsViewModel.editJobRequirements.asMap().entries.map((entry) {
                        final index = entry.key;
                        final req = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: context.scaleH(8)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppIcons.tickSvg,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.emerald,
                                  BlendMode.srcIn,
                                ),
                                width: context.scale(16),
                                height: context.scale(16),
                              ),
                              SizedBox(width: context.scale(8)),
                              Expanded(
                                child: Text(
                                  req,
                                  style: TextStyle(
                                    fontSize: context.sp(13),
                                    color: AppColors.slate700,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => jobsViewModel.removeEditJobRequirement(index),
                                borderRadius:
                                    BorderRadius.circular(context.scale(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: SvgPicture.asset(
                                    AppIcons.crossSmallSvg,
                                    width: context.scale(14),
                                    height: context.scale(14),
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.slate400,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      SizedBox(height: context.scaleH(6)),
                      // Add new requirement input with CustomButton
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: jobsViewModel.editJobAddRequirementController,
                              hintText: 'Add requirement (e.g. Team player)',
                              fillColor: AppColors.backgroundOffWhite,
                              borderRadius: BorderRadius.circular(10),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.vibrantBlue,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.slate200,
                                ),
                              ),
                              onFieldSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  jobsViewModel.addEditJobRequirement(val.trim());
                                  jobsViewModel.editJobAddRequirementController.clear();
                                }
                              },
                            ),
                          ),
                          SizedBox(width: context.scale(8)),
                          CustomButton(
                            text: 'Add',
                            width: context.scale(68),
                            height: 48,
                            borderRadius: 10,
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.bold,
                            backgroundColor: AppColors.vibrantBlue,
                            textColor: AppColors.white,
                            onPressed: () {
                              if (jobsViewModel.editJobAddRequirementController
                                  .text
                                  .trim()
                                  .isNotEmpty) {
                                jobsViewModel.addEditJobRequirement(
                                  jobsViewModel.editJobAddRequirementController.text.trim(),
                                );
                                jobsViewModel.editJobAddRequirementController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: context.scaleH(16)),

                      // Listing Status Selector
                      FieldLabel(
                        label: 'Listing Status',
                        bottomPadding: context.scaleH(6),
                      ),
                      Row(
                        children: [
                          JobStatus.open,
                          JobStatus.closed,
                          JobStatus.archived,
                        ].map((status) {
                          final isSel = jobsViewModel.postStatus == status;
                          String label = 'Open';
                          Color activeColor = AppColors.emerald;
                          if (status == JobStatus.closed) {
                            label = 'Closed';
                            activeColor = AppColors.primaryRed;
                          } else if (status == JobStatus.archived) {
                            label = 'Archived';
                            activeColor = AppColors.slate500;
                          }
                          return Padding(
                            padding: EdgeInsets.only(right: context.scale(8)),
                            child: ChoiceChip(
                              label: Text(
                                label,
                                style: TextStyle(
                                  fontSize: context.sp(12),
                                  color: isSel
                                      ? AppColors.white
                                      : AppColors.slate700,
                                  fontWeight: isSel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSel,
                              selectedColor: activeColor,
                              backgroundColor: AppColors.slate100,
                              onSelected: (_) =>
                                  jobsViewModel.setPostStatus(status),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: context.scaleH(12)),

                      // Posted date at the bottom of the card
                      Text(
                        postedDate,
                        style: TextStyle(
                          fontSize: context.sp(12),
                          color: AppColors.slate400,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.scaleH(24)),
              ],
            ),
          ),
        ),
      ),

      // Fixed Bottom Action Bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.hMargin,
            vertical: context.scaleH(12),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    flex: 1,
                    child: CustomButton(
                      text: 'Cancel',
                      isOutlined: true,
                      borderColor: AppColors.slate300,
                      textColor: AppColors.slate700,
                      backgroundColor: AppColors.transparent,
                      height: context.scaleH(48),
                      borderRadius: 12,
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.bold,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: context.scale(12)),
                  // Save Changes Button
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Save Changes',
                      isLoading: jobsViewModel.isSavingJob,
                      backgroundColor: AppColors.vibrantBlue,
                      textColor: AppColors.white,
                      height: context.scaleH(48),
                      borderRadius: 12,
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.bold,
                      onPressed: () => _saveChanges(context, jobsViewModel),
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
}
