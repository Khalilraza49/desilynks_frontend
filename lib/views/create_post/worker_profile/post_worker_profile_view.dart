import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/models/worker_profile_model.dart';
import 'package:desilynks/models/category_item.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/worker_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/post_success_dialog.dart';
import 'package:desilynks/widgets/form_progress_bar.dart';

class PostWorkerProfileView extends StatelessWidget {
  final WorkerProfileModel? workerProfile;

  const PostWorkerProfileView({super.key, this.workerProfile});

  Future<void> _submitProfile(
    BuildContext context,
    WorkerViewModel workerVM,
  ) async {
    FocusScope.of(context).unfocus();

    final validationError = workerVM.validateWorkerProfileForm(workerProfile);
    if (validationError != null) {
      _showErrorSnackBar(context, validationError);
      return;
    }

    final success = await workerVM.submitWorkerProfile(workerProfile);

    if (!context.mounted) return;

    if (success) {
      PostSuccessFadeDialog.show(
        context,
        title: workerProfile != null
            ? 'Worker Profile Updated!'
            : 'Worker Profile Published!',
        message:
            'Your worker profile has been published successfully. Employers and clients can now view your profile and contact you directly.',
        onContinue: () {
          Navigator.pop(context); // Close dialog
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.hireWorkers,
          ); // Navigate to Hire Workers & Services UI
        },
      );
    } else {
      _showErrorSnackBar(
        context,
        workerVM.errorMessage ?? 'Failed to submit worker profile',
      );
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerVM = Provider.of<WorkerViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerViewModel>().initPostWorkerProfileForm(workerProfile);
      final catVM = context.read<CategoriesViewModel>();
      if (catVM.needWorkerTypes.isEmpty) {
        catVM.fetchNeedWorkerTypes();
      }
      catVM.fetchAll();
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context),

            const Divider(
              color: AppColors.slate200,
              height: 1,
              thickness: AppConstants.borderWidth,
            ),

            // Progress Header Section
            _buildProgressHeader(workerVM),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.marginHorizontal,
                  vertical: 16,
                ),
                child: Form(
                  key: workerVM.postWorkerProfileFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Profile Photo Picker
                      _buildProfilePhotoSection(context, workerVM),
                      const SizedBox(height: 22),

                      // 2. Profession / Service *
                      _buildRequiredLabel('Profession / Service'),
                      const SizedBox(height: 8),
                      _buildProfessionDropdown(workerVM),
                      const SizedBox(height: 20),

                      // 3. Years of Experience *
                      _buildRequiredLabel('Years of Experience'),
                      const SizedBox(height: 8),
                      _buildExperienceCounter(workerVM),
                      const SizedBox(height: 20),

                      // 4. Hourly Rate (€) & Daily Rate (€) Side by Side
                      _buildRatesSection(workerVM),
                      const SizedBox(height: 20),

                      // 5. Languages Spoken
                      _buildFieldLabel('Languages Spoken'),
                      const SizedBox(height: 10),
                      _buildLanguagesWrap(workerVM),
                      const SizedBox(height: 22),

                      // 6. Options Switch Card (Available Today, Own Vehicle, Own Tools)
                      _buildOptionsCard(workerVM),
                      const SizedBox(height: 22),

                      // 7. Area Covered *
                      _buildRequiredLabel('Area Covered'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: workerVM.workerAreaCoveredController,
                        hintText: 'e.g. Madrid, Barcelona, Nearby Cities',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            AppIcons.locationSvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate400,
                              BlendMode.srcIn,
                            ),
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // 8. Portfolio / Work Photos
                      _buildFieldLabel('Portfolio / Work Photos'),
                      const SizedBox(height: 10),
                      _buildPortfolioRow(context, workerVM),
                      const SizedBox(height: 22),

                      // 9. Certificates / Documents
                      _buildFieldLabel('Certificates / Documents'),
                      const SizedBox(height: 10),
                      _buildCertificateUploader(context, workerVM),
                      const SizedBox(height: 22),

                      // 10. About Me *
                      _buildRequiredLabel('About Me'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: workerVM.workerAboutMeController,
                        hintText:
                            'Describe your experience, skills and why clients should hire you...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 28),

                      // 11. Publish Profile Golden Button
                      _buildPublishButton(context, workerVM),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Top App Bar Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.marginHorizontal,
        vertical: 12,
      ),
      child: Row(
        children: [
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
          const Spacer(),
          // Title
          const Text(
            'Worker Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Progress Header Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildProgressHeader(WorkerViewModel workerVM) {
    final double progress = workerVM.calculateProfileProgress(workerProfile);
    final String stepText = progress < 0.95
        ? 'Step 1 of 2 — Profile Info'
        : 'Step 2 of 2 — Profile Complete';

    return FormProgressBar(
      progress: progress,
      stepText: stepText,
      activeColor: AppColors.amberOrange,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.marginHorizontal,
        vertical: 14,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Photo Section Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildProfilePhotoSection(
    BuildContext context,
    WorkerViewModel workerVM,
  ) {
    final bool hasPhoto =
        workerVM.profilePhotoFile != null ||
        (workerProfile?.profilePhotoUrl != null &&
            workerProfile!.profilePhotoUrl!.isNotEmpty);

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => workerVM.pickProfilePhoto(context),
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.slate50,
                border: Border.all(color: AppColors.slate300, width: 1.8),
              ),
              child: workerVM.profilePhotoFile != null
                  ? ClipOval(
                      child: Image.file(
                        workerVM.profilePhotoFile!,
                        width: 108,
                        height: 108,
                        fit: BoxFit.cover,
                      ),
                    )
                  : (workerProfile?.profilePhotoUrl != null &&
                        workerProfile!.profilePhotoUrl!.isNotEmpty)
                  ? ClipOval(
                      child: Image.network(
                        workerProfile!.profilePhotoUrl!,
                        width: 108,
                        height: 108,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.cameraSvg,
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate500,
                            BlendMode.srcIn,
                          ),
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PHOTO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate500,
                            letterSpacing: 0.8,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasPhoto ? 'Change profile photo' : 'Add profile photo',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.slate500,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getProfessionVisual(String profession) {
    final lower = profession.toLowerCase();
    if (lower.contains('it') ||
        lower.contains('tech') ||
        lower.contains('expert') ||
        lower.contains('comput') ||
        lower.contains('software')) {
      return {
        'name': profession,
        'svg': AppIcons.supportSvg,
        'color': const Color(0xFF2563EB),
      };
    }
    if (lower.contains('electric')) {
      return {
        'name': profession,
        'svg': AppIcons.electricianSvg,
        'color': const Color(0xFFF59E0B),
      };
    }
    if (lower.contains('plumb')) {
      return {
        'name': profession,
        'svg': AppIcons.plumberSvg,
        'color': const Color(0xFF3B82F6),
      };
    }
    if (lower.contains('cook') || lower.contains('chef')) {
      return {
        'name': profession,
        'svg': AppIcons.cookSvg,
        'color': const Color(0xFFEF4444),
      };
    }
    if (lower.contains('paint')) {
      return {
        'name': profession,
        'svg': AppIcons.PainterSvg,
        'color': const Color(0xFFEC4899),
      };
    }
    if (lower.contains('clean') || lower.contains('maid')) {
      return {
        'name': profession,
        'svg': AppIcons.cleanerSvg,
        'color': const Color(0xFF10B981),
      };
    }
    if (lower.contains('driv') || lower.contains('chauffeur')) {
      return {
        'name': profession,
        'svg': AppIcons.driverSvg,
        'color': const Color(0xFF6366F1),
      };
    }
    if (lower.contains('garden')) {
      return {
        'name': profession,
        'svg': AppIcons.gardnerSvg,
        'color': const Color(0xFF059669),
      };
    }
    if (lower.contains('construct') ||
        lower.contains('labour') ||
        lower.contains('labor') ||
        lower.contains('mason')) {
      return {
        'name': profession,
        'svg': AppIcons.labourSvg,
        'color': const Color(0xFF8B5CF6),
      };
    }
    return {
      'name': profession,
      'svg': AppIcons.briefcaseSvg,
      'color': const Color(0xFF64748B),
    };
  }

  Widget _buildProfessionDropdown(WorkerViewModel workerVM) {
    return Consumer<CategoriesViewModel>(
      builder: (context, catVM, _) {
        final List<CategoryItem> categories = catVM.needWorkerTypes;
        final selected = workerVM.profileSelectedProfession;

        final CategoryItem? matchedItem = categories.cast<CategoryItem?>().firstWhere(
              (c) =>
                  c != null &&
                  (c.title.trim().toLowerCase() ==
                          selected?.trim().toLowerCase() ||
                      c.id == workerVM.profileSelectedProfessionId),
              orElse: () => null,
            );

        final String? dropdownValue = matchedItem != null
            ? matchedItem.title
            : (selected != null && selected.isNotEmpty ? selected : null);

        final bool isDropdownLoading = catVM.isLoading && categories.isEmpty;

        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: dropdownValue != null
                  ? AppColors.amberOrange
                  : AppColors.slate200,
              width: dropdownValue != null ? 1.6 : 1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              value: dropdownValue,
              hint: isDropdownLoading
                  ? const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.amberOrange,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Loading categories...',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.slate400,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Select your profession / service',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.slate400,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
              isExpanded: true,
              icon: SvgPicture.asset(
                AppIcons.arrowDropDownSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate400,
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
              ),
              onChanged: (newValue) {
                if (newValue != null) {
                  final chosen = categories.cast<CategoryItem?>().firstWhere(
                        (c) => c?.title == newValue,
                        orElse: () => null,
                      );
                  workerVM.setProfileSelectedProfession(
                    newValue,
                    professionId: chosen?.id,
                  );
                }
              },
              items: [
                ...categories.map((item) {
                  final name = item.title;
                  final visual = _getProfessionVisual(name);
                  final svg = visual['svg'] as String;
                  final iconColor = visual['color'] as Color;

                  return DropdownMenuItem<String>(
                    value: name,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          svg,
                          colorFilter:
                              ColorFilter.mode(iconColor, BlendMode.srcIn),
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.slate800,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (dropdownValue != null && matchedItem == null)
                  DropdownMenuItem<String>(
                    value: dropdownValue,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          _getProfessionVisual(dropdownValue)['svg'] as String,
                          colorFilter: ColorFilter.mode(
                            _getProfessionVisual(dropdownValue)['color']
                                as Color,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dropdownValue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.slate800,
                              fontFamily: AppStrings.fontInter,
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
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Experience Counter Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildExperienceCounter(WorkerViewModel workerVM) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: workerVM.decrementExperience,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              child: const Text(
                '—',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate800,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Text(
                '${workerVM.profileYearsOfExperience}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              const SizedBox(width: 32),
              const Text(
                'years',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.slate400,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: workerVM.incrementExperience,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppIcons.plusSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate800,
                  BlendMode.srcIn,
                ),
                width: 18,
                height: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Rates Section Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildRatesSection(WorkerViewModel workerVM) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hourly Rate
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Hourly Rate (€)'),
              const SizedBox(height: 8),
              Container(
                height: 52,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Text(
                      '€ ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate800,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: workerVM.workerHourlyRateController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                          fontFamily: AppStrings.fontInter,
                        ),
                        decoration: const InputDecoration(
                          hintText: '15',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Text(
                  'Per hour',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.slate400,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),

        // Daily Rate
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Daily Rate (€)'),
              const SizedBox(height: 8),
              Container(
                height: 52,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Text(
                      '€ ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate800,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: workerVM.workerDailyRateController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                          fontFamily: AppStrings.fontInter,
                        ),
                        decoration: const InputDecoration(
                          hintText: '80',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Text(
                  'Per day',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.slate400,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Languages Spoken Wrap Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildLanguagesWrap(WorkerViewModel workerVM) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: WorkerViewModel.availableLanguages.map((lang) {
        final String name = lang['name']!;
        final String code = lang['code']!;
        final bool isSelected = workerVM.profileSelectedLanguages.contains(
          name,
        );

        return GestureDetector(
          onTap: () => workerVM.toggleWorkerLanguage(name),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.amberOrange : AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? AppColors.amberOrange : AppColors.slate200,
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.amberOrange.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.white.withValues(alpha: 0.25)
                        : AppColors.slate100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.white : AppColors.slate700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.white : AppColors.slate700,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Options Switch Card Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildOptionsCard(WorkerViewModel workerVM) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          _buildSwitchOption(
            title: 'Available Today?',
            subtitle: 'Show as available right now',
            value: workerVM.profileIsAvailableToday,
            onChanged: workerVM.setProfileIsAvailableToday,
          ),
          const Divider(color: AppColors.slate100, height: 1),
          _buildSwitchOption(
            title: 'Own Vehicle?',
            subtitle: 'Car, motorcycle or bicycle',
            value: workerVM.profileHasVehicle,
            onChanged: workerVM.setProfileHasVehicle,
          ),
          const Divider(color: AppColors.slate100, height: 1),
          _buildSwitchOption(
            title: 'Own Tools?',
            subtitle: 'Professional tools & equipment',
            value: workerVM.profileHasTools,
            onChanged: workerVM.setProfileHasTools,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Portfolio Row Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPortfolioRow(BuildContext context, WorkerViewModel workerVM) {
    final List<Widget> photoWidgets = [];

    // Add Photo Button
    photoWidgets.add(
      GestureDetector(
        onTap: () => workerVM.pickWorkPhotos(context),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.slate300, width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.add_cameraSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate500,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 4),
              const Text(
                'Add Photo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate500,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Render picked file thumbnails
    final workPhotos = workerVM.workPhotoFiles;
    for (int i = 0; i < workPhotos.length; i++) {
      final file = workPhotos[i];
      photoWidgets.add(
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                file,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => workerVM.removeWorkPhoto(i),
                child: Container(
                  padding: const EdgeInsets.all(4),
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
                    width: 14,
                    height: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Render existing profile portfolio photos if editing
    if (workerProfile != null) {
      for (final photoUrl in workerProfile!.portfolioPhotos) {
        photoWidgets.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              photoUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                width: 100,
                color: AppColors.slate100,
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.gallerySvg,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate400,
                      BlendMode.srcIn,
                    ),
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: photoWidgets
            .map(
              (w) =>
                  Padding(padding: const EdgeInsets.only(right: 12), child: w),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCertificateUploader(
    BuildContext context,
    WorkerViewModel workerVM,
  ) {
    final int totalCerts =
        workerVM.certificateFiles.length +
        (workerProfile?.certificates.length ?? 0);

    return Column(
      children: [
        GestureDetector(
          onTap: () => workerVM.pickCertificateFiles(context),
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.slate300, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  totalCerts > 0
                      ? AppIcons.tickCircleSvg
                      : AppIcons.closedBookSvg,
                  colorFilter: ColorFilter.mode(
                    totalCerts > 0 ? AppColors.emerald : AppColors.slate400,
                    BlendMode.srcIn,
                  ),
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  totalCerts > 0
                      ? '$totalCerts Certificate(s) Selected'
                      : 'Upload Certificate or License',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: totalCerts > 0
                        ? AppColors.emerald
                        : AppColors.slate500,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (workerVM.certificateFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          Column(
            children: workerVM.certificateFiles.asMap().entries.map((entry) {
              final idx = entry.key;
              final file = entry.value;
              final name = file.path.split(Platform.pathSeparator).last;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.pinSvg,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate500,
                        BlendMode.srcIn,
                      ),
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => workerVM.removeCertificateFile(idx),
                      child: SvgPicture.asset(
                        AppIcons.crossSmallSvg,
                        colorFilter: const ColorFilter.mode(
                          Colors.redAccent,
                          BlendMode.srcIn,
                        ),
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Publish Profile Golden Button Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPublishButton(BuildContext context, WorkerViewModel workerVM) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.vibrantBlue, AppColors.secondaryPurple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: workerVM.isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            )
          : ElevatedButton.icon(
              onPressed: () => _submitProfile(context, workerVM),
              icon: SvgPicture.asset(
                workerProfile != null ? AppIcons.savedSvg : AppIcons.send2,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
                width: 18,
                height: 18,
              ),
              label: Text(
                workerProfile != null ? 'Update Profile' : 'Publish Profile',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.transparent,
                shadowColor: AppColors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
            ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helper UI Components
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildRequiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.slate800,
          fontFamily: AppStrings.fontInter,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.slate800,
        fontFamily: AppStrings.fontInter,
      ),
    );
  }

  Widget _buildSwitchOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slate400,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.emerald,
            activeTrackColor: AppColors.emerald.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.slate400,
            inactiveTrackColor: AppColors.slate200,
          ),
        ],
      ),
    );
  }
}
