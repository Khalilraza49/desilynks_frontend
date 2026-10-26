import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/models/category_item.dart';
import 'package:desilynks/models/need_worker_model.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/need_worker_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/custom_date_picker_field.dart';
import 'package:desilynks/widgets/post_success_dialog.dart';

class PostNeedWorkerView extends StatelessWidget {
  final NeedWorkerModel? needWorkerPost;

  const PostNeedWorkerView({super.key, this.needWorkerPost});

  Future<void> _submitRequest(
    BuildContext context,
    NeedWorkerViewModel viewModel,
  ) async {
    FocusScope.of(context).unfocus();

    final validationError = viewModel.validateForm();
    if (validationError != null) {
      _showErrorSnackBar(context, validationError);
      return;
    }

    final isEdit = needWorkerPost != null;
    final success = await viewModel.submitNeedWorkerPost(
      needWorkerPost,
      categoriesVM: context.read<CategoriesViewModel>(),
    );

    if (!context.mounted) return;

    if (success) {
      PostSuccessFadeDialog.show(
        context,
        title: isEdit ? 'Worker Request Updated!' : 'Worker Request Posted!',
        message: isEdit
            ? 'Your worker request details have been updated successfully.'
            : 'Your worker request has been broadcasted. Nearby available workers have been notified and will contact you shortly.',
        onContinue: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Close screen
        },
      );
    } else if (viewModel.errorMessage != null) {
      _showErrorSnackBar(context, viewModel.errorMessage!);
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

  void _showBudgetTypeMenu(BuildContext context, NeedWorkerViewModel vm) {
    vm.needWorkerBudgetFocusNode.unfocus();
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => overlayEntry.remove(),
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            CompositedTransformFollower(
              link: vm.budgetTypeLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 56),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF666666),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: NeedWorkerViewModel.budgetTypes.map((type) {
                      final isSelected = type == vm.selectedBudgetType;
                      return GestureDetector(
                        onTap: () {
                          vm.setSelectedBudgetType(type);
                          overlayEntry.remove();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          color: isSelected
                              ? const Color(0xFF666666)
                              : Colors.white,
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0055CC),
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(overlayEntry);
  }

  Future<void> _handlePickPhoto(
    BuildContext context,
    NeedWorkerViewModel vm,
  ) async {
    final error = await vm.pickPhoto(context);
    if (error != null && context.mounted) {
      _showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NeedWorkerViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NeedWorkerViewModel>().initPostNeedWorkerForm(
        needWorkerPost,
      );
      context.read<CategoriesViewModel>().fetchAll();
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

            // Sub-header Banner Indicator
            _buildSubHeader(),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.marginHorizontal,
                  vertical: 16,
                ),
                child: Form(
                  key: viewModel.postNeedWorkerFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. What do you need? * (3x3 Category Grid)
                      _buildRequiredLabel('What do you need?'),
                      const SizedBox(height: 12),
                      _buildCategoryGrid(viewModel),
                      const SizedBox(height: 22),

                      // 2. Location *
                      _buildRequiredLabel('Location'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: viewModel.needWorkerLocationController,
                        hintText: 'Your address or area',
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

                      // 3. Date Needed *
                      _buildRequiredLabel('Date Needed'),
                      const SizedBox(height: 8),
                      _buildDatePickerBox(viewModel),
                      const SizedBox(height: 20),

                      // 5. Budget *
                      _buildRequiredLabel('Budget'),
                      const SizedBox(height: 8),
                      _buildBudgetRow(context, viewModel),
                      const SizedBox(height: 22),

                      // 6. Urgent Request Switch Card
                      _buildUrgentCard(viewModel),
                      const SizedBox(height: 22),

                      // 7. Description *
                      _buildRequiredLabel('Description'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: viewModel.needWorkerDescriptionController,
                        hintText:
                            'Describe exactly what work needs to be done, any specific requirements...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 22),

                      // 8. Reference Photos (optional)
                      _buildOptionalLabel('Reference Photos', '(optional)'),
                      const SizedBox(height: 10),
                      _buildReferencePhotosRow(context, viewModel),
                      const SizedBox(height: 22),

                      // 9. Workers Nearby Notification Blue Card
                      _buildWorkerNotificationCard(),
                      const SizedBox(height: 28),

                      // 10. Submit Request Button
                      _buildSubmitButton(context, viewModel),
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
          // Back Arrow Button
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
          Text(
            needWorkerPost != null ? 'Edit Worker Request' : 'Need a Worker',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Sub-header Banner Indicator
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSubHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.marginHorizontal,
        vertical: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Fill in your requirements',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate600,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Nearby workers will be notified ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orangeAccent,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                        Text('🔔', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Horizontal Full Orange Indicator Line
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.orangeAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  String _getWorkerCategorySvg(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('electric')) return AppIcons.electricianSvg;
    if (lower.contains('plumb')) return AppIcons.plumberSvg;
    if (lower.contains('paint')) return AppIcons.PainterSvg;
    if (lower.contains('clean')) return AppIcons.cleanerSvg;
    if (lower.contains('driv')) return AppIcons.driverSvg;
    if (lower.contains('cook') || lower.contains('chef')) {
      return AppIcons.cookSvg;
    }
    if (lower.contains('labour') || lower.contains('labor')) {
      return AppIcons.labourSvg;
    }
    if (lower.contains('garden')) return AppIcons.GardernerSvg;
    return AppIcons.briefcaseSvg;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Category Grid (Dynamic API worker types with graceful fallback)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCategoryGrid(NeedWorkerViewModel viewModel) {
    return Consumer<CategoriesViewModel>(
      builder: (context, catVM, _) {
        final List<CategoryItem> apiCategories = catVM.needWorkerTypes;
        final bool useApi = apiCategories.isNotEmpty;

        if (useApi && viewModel.selectedCategoryId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.selectedCategoryId == null &&
                apiCategories.isNotEmpty) {
              final match = apiCategories.firstWhere(
                (c) =>
                    c.title.toLowerCase() ==
                    viewModel.selectedCategory.toLowerCase(),
                orElse: () => apiCategories.first,
              );
              viewModel.setSelectedCategory(match.title, categoryId: match.id);
            }
          });
        }

        final int itemCount = useApi
            ? apiCategories.length
            : NeedWorkerViewModel.categories.length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final int columns = width >= 600 ? 4 : (width < 340 ? 2 : 3);
            final double aspectRatio = width < 340 ? 1.55 : 1.35;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final String name;
                final String svg;
                final String? id;

                if (useApi) {
                  final cat = apiCategories[index];
                  name = cat.title;
                  id = cat.id;
                  svg = _getWorkerCategorySvg(name);
                } else {
                  final cat = NeedWorkerViewModel.categories[index];
                  name = cat['name'] as String;
                  id = null;
                  svg = cat['svg'] as String;
                }

                final bool isSelected =
                    name.toLowerCase() ==
                    viewModel.selectedCategory.toLowerCase();

                return GestureDetector(
                  onTap: () =>
                      viewModel.setSelectedCategory(name, categoryId: id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.orangeAccent
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.orangeAccent
                            : AppColors.slate200,
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.orangeAccent.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          svg,
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            isSelected ? AppColors.white : AppColors.slate600,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.slate700,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Date Picker Box Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildDatePickerBox(NeedWorkerViewModel viewModel) {
    return CustomDatePickerField(
      controller: viewModel.needWorkerDateController,
      hintText: 'mm/dd/yyyy',
      firstDate: DateTime.now(),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset(
          AppIcons.calendarSvg,
          colorFilter: const ColorFilter.mode(
            AppColors.slate400,
            BlendMode.srcIn,
          ),
          width: 18,
          height: 18,
        ),
      ),
      onDateSelected: (date) {
        viewModel.setSelectedDate(date);
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Budget Row Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildBudgetRow(BuildContext context, NeedWorkerViewModel viewModel) {
    return Row(
      children: [
        // Budget Amount Field
        Expanded(
          child: CustomTextField(
            hintText: '50',
            controller: viewModel.needWorkerBudgetController,
            focusNode: viewModel.needWorkerBudgetFocusNode,
            keyboardType: TextInputType.number,
            prefix: const Text(
              '€  ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Budget Type Dropdown
        Expanded(
          child: CompositedTransformTarget(
            link: viewModel.budgetTypeLayerLink,
            child: GestureDetector(
              onTap: () => _showBudgetTypeMenu(context, viewModel),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      viewModel.selectedBudgetType,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate800,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    SvgPicture.asset(
                      AppIcons.arrowDropDownSvg,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate400,
                        BlendMode.srcIn,
                      ),
                      width: 18,
                      height: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Urgent Request Card Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildUrgentCard(NeedWorkerViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Light Peach / Orange
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🚨 ', style: TextStyle(fontSize: 15)),
                    Text(
                      'Urgent Request',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9A3412),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  'Nearby workers get instant notification',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC2410C),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: viewModel.isUrgent,
            onChanged: (val) => viewModel.setIsUrgent(val),
            activeThumbColor: AppColors.orangeAccent,
            activeTrackColor: AppColors.orangeAccent.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.slate400,
            inactiveTrackColor: AppColors.slate200,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Reference Photos Row Widget (4 Dashed Boxes)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildReferencePhotosRow(
    BuildContext context,
    NeedWorkerViewModel viewModel,
  ) {
    final int totalCount =
        viewModel.existingPhotos.length + viewModel.selectedPhotoFiles.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 1. Add Photo Button (if less than 6 photos)
          if (totalCount < 6)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => _handlePickPhoto(context, viewModel),
                child: CustomPaint(
                  painter: DashedRectPainter(
                    color: AppColors.slate300,
                    borderRadius: 14,
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.add_cameraSvg,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryBlue,
                            BlendMode.srcIn,
                          ),
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 2. Existing Photos (from network when editing)
          ...List.generate(viewModel.existingPhotos.length, (index) {
            final photo = viewModel.existingPhotos[index];
            String url = photo.url;
            if (url.startsWith('/')) {
              url = '${ApiEndpoints.baseUrl}$url';
            }

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      url,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.slate200,
                        alignment: Alignment.center,
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
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => viewModel.removeExistingPhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          AppIcons.crossSmallSvg,
                          width: 14,
                          height: 14,
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
          }),

          // 3. Newly Picked Photos (from file)
          ...List.generate(viewModel.selectedPhotoFiles.length, (index) {
            final xFile = viewModel.selectedPhotoFiles[index];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(xFile.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => viewModel.removeSelectedPhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          AppIcons.crossSmallSvg,
                          width: 14,
                          height: 14,
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
          }),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Workers Nearby Notification Blue Card Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWorkerNotificationCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Light Blue
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppIcons.notificationSvg,
              height: 20,
              width: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF2563EB),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF1E3A8A),
                  fontFamily: AppStrings.fontInter,
                ),
                children: [
                  TextSpan(
                    text: 'Workers nearby will be notified ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        'when you post this request. You\'ll receive applications from available workers in your area.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Submit Request Golden-Orange Button Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSubmitButton(
    BuildContext context,
    NeedWorkerViewModel viewModel,
  ) {
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
      child: viewModel.isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            )
          : ElevatedButton.icon(
              onPressed: () => _submitRequest(context, viewModel),
              icon: SvgPicture.asset(
                needWorkerPost != null ? AppIcons.savedSvg : AppIcons.send2,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
                width: 18,
                height: 18,
              ),
              label: Text(
                needWorkerPost != null ? 'Update Request' : 'Post Request',
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

  Widget _buildOptionalLabel(String title, String optionalText) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.slate800,
          fontFamily: AppStrings.fontInter,
        ),
        children: [
          TextSpan(
            text: ' $optionalText',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.slate400,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Dashed Rectangle Painter for Reference Photos
// ──────────────────────────────────────────────────────────────────────────
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double borderRadius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.dash = 5,
    this.gap = 4,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path metricsPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        metricsPath.addPath(
          metric.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(metricsPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────────────────────────────────
// Time Picker Popover Content Widget (matching user screenshot popover)
// ──────────────────────────────────────────────────────────────────────────
class TimePickerPopoverViewModel extends ChangeNotifier {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  late int selectedHour;
  late int selectedMinute;
  late String selectedPeriod;

  late final FixedExtentScrollController hourController;
  late final FixedExtentScrollController minuteController;
  late final FixedExtentScrollController periodController;

  final List<int> hours = List.generate(12, (i) => i + 1);
  final List<int> minutes = List.generate(60, (i) => i);
  final List<String> periods = const ['PM', 'AM'];

  TimePickerPopoverViewModel({
    required this.initialTime,
    required this.onTimeChanged,
  }) {
    final hourOfPeriod = initialTime.hourOfPeriod == 0
        ? 12
        : initialTime.hourOfPeriod;
    selectedHour = hourOfPeriod;
    selectedMinute = initialTime.minute;
    selectedPeriod = initialTime.period == DayPeriod.am ? 'AM' : 'PM';

    hourController = FixedExtentScrollController(
      initialItem: hours.indexOf(selectedHour),
    );
    minuteController = FixedExtentScrollController(
      initialItem: minutes.indexOf(selectedMinute),
    );
    periodController = FixedExtentScrollController(
      initialItem: periods.indexOf(selectedPeriod),
    );
  }

  void onHourChanged(int index) {
    selectedHour = hours[index];
    notifyListeners();
    _notifyTimeChanged();
  }

  void onMinuteChanged(int index) {
    selectedMinute = minutes[index];
    notifyListeners();
    _notifyTimeChanged();
  }

  void onPeriodChanged(int index) {
    selectedPeriod = periods[index];
    notifyListeners();
    _notifyTimeChanged();
  }

  void _notifyTimeChanged() {
    int hour = selectedHour;
    if (selectedPeriod == 'PM' && hour < 12) hour += 12;
    if (selectedPeriod == 'AM' && hour == 12) hour = 0;
    onTimeChanged(TimeOfDay(hour: hour, minute: selectedMinute));
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    periodController.dispose();
    super.dispose();
  }
}

class TimePickerPopoverContent extends StatelessWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const TimePickerPopoverContent({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimePickerPopoverViewModel(
        initialTime: initialTime,
        onTimeChanged: onTimeChanged,
      ),
      child: const _TimePickerPopoverBody(),
    );
  }
}

class _TimePickerPopoverBody extends StatelessWidget {
  const _TimePickerPopoverBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimePickerPopoverViewModel>();
    return Container(
      width: 175,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          // Top Header Row (Selection Boxes)
          SizedBox(
            height: 34,
            child: Row(
              children: [
                // Hour selection box
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: Text(
                      vm.selectedHour.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Minute selection box
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: Color(0xFFD1D5DB)),
                    child: Text(
                      vm.selectedMinute.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // AM/PM selection box
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: Color(0xFFD1D5DB)),
                    child: Text(
                      vm.selectedPeriod,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Scrollable Wheels
          Expanded(
            child: Row(
              children: [
                // Hours Wheel
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: vm.hourController,
                    itemExtent: 32,
                    perspective: 0.001,
                    diameterRatio: 3.0,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: vm.onHourChanged,
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: vm.hours.length,
                      builder: (context, index) {
                        final h = vm.hours[index];
                        return Center(
                          child: Text(
                            h.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Minutes Wheel
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: vm.minuteController,
                    itemExtent: 32,
                    perspective: 0.001,
                    diameterRatio: 3.0,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: vm.onMinuteChanged,
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: vm.minutes.length,
                      builder: (context, index) {
                        final m = vm.minutes[index];
                        return Center(
                          child: Text(
                            m.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Period Wheel (AM/PM)
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: vm.periodController,
                    itemExtent: 32,
                    perspective: 0.001,
                    diameterRatio: 3.0,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: vm.onPeriodChanged,
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: vm.periods.length,
                      builder: (context, index) {
                        final p = vm.periods[index];
                        return Center(
                          child: Text(
                            p,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        );
                      },
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
}
