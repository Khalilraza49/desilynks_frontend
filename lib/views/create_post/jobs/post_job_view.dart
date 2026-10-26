import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/models/job_model.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/post_success_dialog.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/form_progress_bar.dart';
import 'package:desilynks/widgets/coming_soon_dialog.dart';

class PostJobView extends StatelessWidget {
  final JobModel? job;

  const PostJobView({super.key, this.job});

  @override
  Widget build(BuildContext context) {
    final jobsViewModel = context.watch<JobsViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesViewModel>().fetchAll();
      final vm = context.read<JobsViewModel>();
      if (vm.currentEditingJobId != (job?.id ?? 'NEW_JOB')) {
        vm.initPostJobForm(job);
      }
    });

    final formProgress = jobsViewModel.formProgress;
    final isBoosted = jobsViewModel.postIsBoosted;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.hMargin,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.slate100,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.arrowBackSvg,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate500,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  // Title
                  Expanded(
                    child: Text(
                      job != null ? 'Edit Job Post' : 'Post A Job',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.sp(20).clamp(18.0, 22.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate800,
                      ),
                    ),
                  ),
                  // Symmetrical placeholder for centering the title
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const Divider(color: AppColors.slate200, thickness: 1.0, height: 1),

            // 1. Step Progress Bar
            FormProgressBar(
              progress: formProgress,
              stepText: formProgress >= 1.0
                  ? 'Form Complete — Ready to Post!'
                  : 'Step 1 of 3 — Job Details',
              activeColor: AppColors.emerald,
            ),
            const Divider(color: AppColors.slate200, thickness: 1.0, height: 1),

            // 2. Form Fields Scrollable Area
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.hMargin,
                      vertical: 20.0,
                    ),
                    child: Form(
                      key: jobsViewModel.postJobFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Job Poster Image Upload Field
                          _buildPosterSection(context, jobsViewModel),

                          // Job Title
                          _buildLabel('Job Title'),
                          CustomTextField(
                            controller: jobsViewModel.postTitleController,
                            hintText: 'e.g waiter required, Delivery driver',
                            fillColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.vibrantBlue,
                                width: 1.5,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Job title is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Company / Business Name
                          _buildLabel(
                            'Company / Business Name',
                            isRequired: false,
                          ),
                          CustomTextField(
                            controller: jobsViewModel.postCompanyController,
                            hintText: 'e.g Lahore grill restaurant',
                            fillColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.vibrantBlue,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Job Category Dropdown
                          _buildLabel('Job Category'),
                          Consumer<CategoriesViewModel>(
                            builder: (context, catVM, _) {
                              final items = catVM.jobCategories;
                              final isValidValue = items.any(
                                (c) => c.id == jobsViewModel.postCategoryId,
                              );

                              return DropdownButtonFormField<String>(
                                initialValue: isValidValue
                                    ? jobsViewModel.postCategoryId
                                    : null,
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                decoration: _getInputDecoration(
                                  catVM.isLoading
                                      ? 'Loading categories…'
                                      : 'Select category',
                                ),
                                hint: Text(
                                  catVM.isLoading
                                      ? 'Loading categories…'
                                      : 'Select category',
                                  style: const TextStyle(
                                    color: AppColors.slate400,
                                    fontSize: 14,
                                  ),
                                ),
                                items: items.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat.id,
                                    child: Text(
                                      cat.title,
                                      style: const TextStyle(
                                        color: AppColors.slate800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    jobsViewModel.setPostCategoryId(value);
                                    final match = items.firstWhere(
                                      (c) => c.id == value,
                                      orElse: () => items.first,
                                    );
                                    jobsViewModel.postCategoryController.text =
                                        match.title;
                                  }
                                },
                                validator: (_) {
                                  if (jobsViewModel.postCategoryId == null ||
                                      jobsViewModel.postCategoryId!.isEmpty) {
                                    return 'Job category is required';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Salary
                          _buildLabel('Salary'),
                          Row(
                            children: [
                              // Salary Input
                              Expanded(
                                flex: 2,
                                child: CustomTextField(
                                  controller:
                                      jobsViewModel.postSalaryController,
                                  keyboardType: TextInputType.number,
                                  hintText: 'Enter salary',
                                  fillColor: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.vibrantBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    child: Text(
                                      '€',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.slate800,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Salary Period Dropdown
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  initialValue:
                                      jobsViewModel.postSalaryPeriods.contains(
                                        jobsViewModel.postSalaryPeriod,
                                      )
                                      ? jobsViewModel.postSalaryPeriod
                                      : jobsViewModel.postSalaryPeriods.first,
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  decoration: _getInputDecoration(''),
                                  items: jobsViewModel.postSalaryPeriods.map((
                                    period,
                                  ) {
                                    return DropdownMenuItem(
                                      value: period,
                                      child: Text(
                                        period,
                                        style: const TextStyle(
                                          color: AppColors.slate800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      jobsViewModel.setPostSalaryPeriod(value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Job Type
                          _buildLabel('Job Type'),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: jobsViewModel.postJobTypes.map((type) {
                              final bool isSelected =
                                  jobsViewModel.postJobType == type;
                              return GestureDetector(
                                onTap: () => jobsViewModel.setPostJobType(type),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.emerald
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.emerald
                                          : AppColors.slate500,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.slate800,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Experience
                          _buildLabel('Experience', isRequired: false),
                          DropdownButtonFormField<String>(
                            initialValue:
                                jobsViewModel.postExperienceOptions.contains(
                                  jobsViewModel.postExperience,
                                )
                                ? jobsViewModel.postExperience
                                : jobsViewModel.postExperienceOptions.first,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            decoration: _getInputDecoration(''),
                            items: jobsViewModel.postExperienceOptions.map((
                              exp,
                            ) {
                              return DropdownMenuItem(
                                value: exp,
                                child: Text(
                                  exp,
                                  style: const TextStyle(
                                    color: AppColors.slate800,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                jobsViewModel.setPostExperience(value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Languages Required
                          _buildLabel('Languages Required', isRequired: false),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildLanguageChip(
                                jobsViewModel,
                                'English',
                                'GB',
                              ),
                              _buildLanguageChip(
                                jobsViewModel,
                                'Spanish',
                                'ES',
                              ),
                              _buildLanguageChip(jobsViewModel, 'Urdu', 'PK'),
                              _buildLanguageChip(jobsViewModel, 'Hindi', 'IN'),
                              _buildLanguageChip(jobsViewModel, 'Arabic', 'AR'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Location
                          _buildLabel('Location'),
                          CustomTextField(
                            controller: jobsViewModel.postLocationController,
                            hintText: 'Barcelona, Spain',
                            fillColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.vibrantBlue,
                                width: 1.5,
                              ),
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: SvgPicture.asset(
                                AppIcons.locationSvg,
                                height: 10,
                                width: 10,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.slate500,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Location is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildWorkLocationChip(
                                jobsViewModel,
                                'Remote',
                                '🏠',
                              ),
                              _buildWorkLocationChip(
                                jobsViewModel,
                                'On-Site',
                                '🏢',
                              ),
                              _buildWorkLocationChip(
                                jobsViewModel,
                                'Hybrid',
                                '🏡',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Job Description
                          _buildLabel('Job Description'),
                          CustomTextField(
                            controller: jobsViewModel.postDescriptionController,
                            maxLines: 4,
                            hintText:
                                'Describe role responsibilities and requiremnts......',
                            textColor: AppColors.slate800,
                            fontSize: 14,
                            fillColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.slate200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.slate200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.vibrantBlue,
                                width: 1.5,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Required Skills
                          _buildLabel('Required Skills'),
                          CustomTextField(
                            controller: jobsViewModel.postSkillsController,
                            hintText:
                                'e.g. cooking, driving, customer service...',
                            fillColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.vibrantBlue,
                                width: 1.5,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required skills cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          if (job != null) ...[
                            _buildLabel('Job Status'),
                            Row(
                              children: [
                                _buildStatusChip(
                                  jobsViewModel,
                                  'Open',
                                  JobStatus.open,
                                  AppColors.emerald,
                                ),
                                const SizedBox(width: 8),
                                _buildStatusChip(
                                  jobsViewModel,
                                  'Closed',
                                  JobStatus.closed,
                                  AppColors.slate500,
                                ),
                                const SizedBox(width: 8),
                                _buildStatusChip(
                                  jobsViewModel,
                                  'Archived',
                                  JobStatus.archived,
                                  AppColors.orangeAccent,
                                ),
                              ],
                            ),
                            if (job!.status == JobStatus.closed ||
                                job!.status == JobStatus.archived) ...[
                              const SizedBox(height: 6),
                              const Text(
                                'Status cannot be changed once closed or archived.',
                                style: TextStyle(
                                  color: AppColors.slate500,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],

                          // Boost this Job Banner
                          GestureDetector(
                            onTap: () => _showBoostComingSoon(context),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.lightYellow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.amber100,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightYellow,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: SvgPicture.asset(
                                      AppIcons.starFavoriteSvg,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.accentYellow,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Boost this Job',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.orangeAccent,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isBoosted
                                              ? 'Job boosted successfully!'
                                              : 'Get 5x more applications',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.amber700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _showBoostComingSoon(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isBoosted
                                          ? AppColors.emerald
                                          : AppColors.orange,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context
                                            .scale(16)
                                            .clamp(10.0, 16.0),
                                        vertical: 10,
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        isBoosted ? 'Boosted' : 'Boost',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Gradient Publish/Next Button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.vibrantBlue,
                                  AppColors.secondaryPurple,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: jobsViewModel.isLoading
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () async {
                                      if (jobsViewModel
                                          .postJobFormKey
                                          .currentState!
                                          .validate()) {
                                        final success = await jobsViewModel
                                            .submitJobForm(initialJob: job);

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success
                                                    ? (job != null
                                                          ? 'Job updated successfully!'
                                                          : 'Job posted successfully!')
                                                    : (jobsViewModel.errorMessage ??
                                                          'Failed to process job'),
                                              ),
                                              backgroundColor: success
                                                  ? Colors.green
                                                  : Colors.red,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                          if (success) {
                                            jobsViewModel.resetPostJobForm();
                                            PostSuccessFadeDialog.show(
                                              context,
                                              title: job != null
                                                  ? 'Job Updated!'
                                                  : 'Job Published!',
                                              message: job != null
                                                  ? 'Your job listing details have been updated.'
                                                  : 'Your job post is now live and visible to applicants.',
                                              onContinue: () {
                                                Navigator.pop(
                                                  context,
                                                ); // close dialog
                                                Navigator.pop(
                                                  context,
                                                ); // return to previous screen
                                              },
                                            );
                                          }
                                        }
                                      }
                                    },
                                    icon: SvgPicture.asset(
                                      job != null
                                          ? AppIcons.savedSvg
                                          : AppIcons.send2,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                      height: 24,
                                      width: 24,
                                    ),
                                    label: Text(
                                      job != null ? 'Update Job' : 'Publish Job',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),
                        ],
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

  Widget _buildLabel(String text, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.slate800,
            fontFamily: "Inter",
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    JobsViewModel jobsViewModel,
    String label,
    JobStatus status,
    Color color,
  ) {
    final bool isSelected = jobsViewModel.postStatus == status;
    final bool isEditable =
        job == null ||
        (job!.status != JobStatus.closed && job!.status != JobStatus.archived);

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : (isEditable ? AppColors.slate600 : AppColors.slate300),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      selectedColor: isSelected ? color : Colors.transparent,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? color
              : (isEditable ? AppColors.slate300 : AppColors.slate200),
          width: 1.0,
        ),
      ),
      showCheckmark: false,
      onSelected: isEditable
          ? (selected) {
              if (selected) {
                jobsViewModel.setPostStatus(status);
              }
            }
          : null,
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.vibrantBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _buildLanguageChip(
    JobsViewModel jobsViewModel,
    String label,
    String code,
  ) {
    final bool isSelected = jobsViewModel.postLanguages.contains(label);
    const activeBgColor = AppColors.emerald;
    return ChoiceChip(
      avatar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : AppColors.slate100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          code,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.slate500,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.slate600,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      selectedColor: activeBgColor,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? activeBgColor : AppColors.slate300,
          width: 1.0,
        ),
      ),
      showCheckmark: false,
      onSelected: (selected) {
        jobsViewModel.togglePostLanguage(label);
      },
    );
  }

  Widget _buildWorkLocationChip(
    JobsViewModel jobsViewModel,
    String label,
    String emoji,
  ) {
    final bool isSelected = jobsViewModel.postWorkLocation == label;
    const activeColor = AppColors.emerald;
    return ChoiceChip(
      avatar: Text(emoji, style: const TextStyle(fontSize: 14)),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.slate600,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      selectedColor: activeColor,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? activeColor : AppColors.slate300,
          width: 1.0,
        ),
      ),
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          jobsViewModel.setPostWorkLocation(label);
        }
      },
    );
  }

  Widget _buildPosterSection(
    BuildContext context,
    JobsViewModel jobsViewModel,
  ) {
    final bool hasExistingPoster =
        job?.posterUrl != null && job!.posterUrl!.isNotEmpty;
    final posterFile = jobsViewModel.postPosterFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Job Poster / Photo', isRequired: false),
        GestureDetector(
          onTap: () => jobsViewModel.pickPosterImage(context),
          child: Container(
            height: context.scaleH(160).clamp(140.0, 220.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.slate300, width: 1),
            ),
            child: posterFile != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          posterFile,
                          height: context.scaleH(160).clamp(140.0, 220.0),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            jobsViewModel.setPostPosterFile(null);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              AppIcons.crossSmallSvg,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : hasExistingPoster
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          job!.posterUrl!,
                          height: context.scaleH(160).clamp(140.0, 220.0),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildUploadPlaceholder(),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppIcons.editSvg,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                height: 14,
                                width: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Change Photo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildUploadPlaceholder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppIcons.upload2,
          colorFilter: const ColorFilter.mode(
            AppColors.vibrantBlue,
            BlendMode.srcIn,
          ),
          height: 36,
          width: 36,
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload Job Poster / Photo',
          style: TextStyle(
            color: AppColors.slate700,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'JPG, PNG, JPEG, WEBP (Max: 5MB)',
          style: TextStyle(
            color: AppColors.slate400,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  void _showBoostComingSoon(BuildContext context) {
    ComingSoonDialog.show(
      context,
      title: 'Coming Soon',
      featureName: 'Job Boost',
      svgIcon: AppIcons.starFavoriteSvg,
      badgeColor: AppColors.lightYellow,
      iconColor: AppColors.accentYellow,
      message:
          'Job Boost is currently under development. Soon you will be able to boost your job listings to gain 5x more applications and reach top candidates!',
    );
  }
}
