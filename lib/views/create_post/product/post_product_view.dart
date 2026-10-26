import 'dart:io';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/models/marketplace_item_model.dart';
import 'package:desilynks/viewmodels/marketplace/marketplace_viewmodel.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/post_success_dialog.dart';

class PostProductView extends StatelessWidget {
  final MarketplaceItemModel? productToEdit;

  const PostProductView({super.key, this.productToEdit});

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Phones', 'icon': AppIcons.mobile},
    {'name': 'Cars', 'icon': AppIcons.Car2},
    {'name': 'Electronics', 'icon': AppIcons.electricianSvg},
    {'name': 'Furniture', 'icon': AppIcons.furnishedSvg},
    {'name': 'Clothes', 'icon': AppIcons.Clothes},
    {'name': 'Books', 'icon': AppIcons.closedBookSvg},
    {'name': 'Kids', 'icon': AppIcons.child},
    {'name': 'Other', 'icon': AppIcons.moreVerticalSvg},
  ];

  static const List<String> _conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'For Parts',
  ];

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

  Future<void> _publishListing(
    BuildContext context,
    MarketplaceViewModel viewModel,
  ) async {
    if (viewModel.isSubmittingProduct) return;
    FocusScope.of(context).unfocus();

    final validationError = viewModel.validateProductForm();
    if (validationError != null) {
      _showErrorSnackBar(context, validationError);
      return;
    }

    try {
      final success = await viewModel.publishProductListing(
        productToEdit: productToEdit,
      );

      if (!context.mounted) return;

      if (success) {
        if (productToEdit != null) {
          PostSuccessFadeDialog.show(
            context,
            title: 'Listing Updated!',
            message: 'Your product ad has been successfully updated.',
            onContinue: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Close screen
            },
          );
        } else {
          PostSuccessFadeDialog.show(
            context,
            title: 'Listing Published!',
            message:
                'Your product has been published to the Marketplace. Buyers can now see and contact you for this item.',
            onContinue: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar(
        context,
        e
            .toString()
            .replaceAll('Exception:', '')
            .replaceAll('HttpException:', '')
            .trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MarketplaceViewModel>(context);

    // Initialize product form data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<MarketplaceViewModel>(context, listen: false);
      vm.initPostProductForm(productToEdit);
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  const Expanded(
                    child: Text(
                      'Sell a Product',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.slate200, height: 1, thickness: 1),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Indicator (Isolated ListenableBuilder for zero-lag progress updates)
                    ListenableBuilder(
                      listenable: viewModel.productProgressListenable,
                      builder: (context, _) => _buildAnimatedProgressBar(
                        viewModel.postProductProgress,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category *
                    _buildFieldLabel('Category', isRequired: true),
                    const SizedBox(height: 10),
                    _buildCategoryGrid(viewModel),

                    const SizedBox(height: 20),

                    // Title *
                    _buildFieldLabel('Title', isRequired: true),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: viewModel.productTitleController,
                      hintText: 'e.g. iPhone 13 128GB – Like New',
                    ),

                    const SizedBox(height: 20),

                    // Brand
                    _buildFieldLabel('Brand', isRequired: false),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: viewModel.productBrandController,
                      hintText: 'e.g. Apple, Samsung, IKEA...',
                    ),

                    const SizedBox(height: 20),

                    // Condition *
                    _buildFieldLabel('Condition', isRequired: true),
                    const SizedBox(height: 10),
                    _buildConditionChips(viewModel),

                    const SizedBox(height: 20),

                    // Price *
                    _buildFieldLabel('Price', isRequired: true),
                    const SizedBox(height: 8),
                    _buildPriceRow(viewModel),

                    const SizedBox(height: 20),

                    // Description *
                    _buildFieldLabel('Description', isRequired: true),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: viewModel.productDescriptionController,
                      maxLines: 4,
                      hintText:
                          'Describe your product — condition details, what\'s included, why selling...',
                    ),

                    const SizedBox(height: 20),

                    // Photos (up to 8 — first photo = cover)
                    _buildPhotosSectionHeader(context, viewModel),
                    const SizedBox(height: 10),
                    _buildPhotoSlots(viewModel),

                    const SizedBox(height: 20),

                    // Location *
                    _buildFieldLabel('Location', isRequired: true),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: viewModel.productLocationController,
                      hintText: 'Your city or area',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          AppIcons.locationSvg,
                          height: 22,
                          width: 22,
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate400,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Publish Listing Button
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: viewModel.isSubmittingProduct
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                ),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () =>
                                  _publishListing(context, viewModel),
                              icon: SvgPicture.asset(
                                AppIcons.send2,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                                width: 18,
                                height: 18,
                              ),
                              label: const Text(
                                'Publish Listing',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: AppConstants.fontSizeXL,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.transparent,
                                shadowColor: AppColors.transparent,
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
          ],
        ),
      ),
    );
  }

  // Helper Widget for Field Labels
  Widget _buildFieldLabel(String text, {required bool isRequired}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeLG,
              fontWeight: FontWeight.w600,
              color: AppColors.slate800,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLG,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
        ],
      ),
    );
  }

  // Category Grid Widget (Responsive columns based on available width)
  Widget _buildCategoryGrid(MarketplaceViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int columns = width >= 600 ? 6 : (width < 340 ? 3 : 4);
        final double aspectRatio = width < 340 ? 1.05 : 0.95;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: aspectRatio,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final String name = category['name'] as String? ?? '';
            final String icon =
                (category['icon'] ?? category['svgIcon'] ?? '') as String;
            final bool isSelected = viewModel.selectedProductCategory == name;

            return GestureDetector(
              onTap: () => viewModel.setSelectedProductCategory(name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondaryPurple : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondaryPurple
                        : AppColors.slate200,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon.isNotEmpty)
                      SvgPicture.asset(
                        icon,
                        width: 24,
                        height: 24,
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
                        fontSize: AppConstants.fontSizeXS11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.white : AppColors.slate700,
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
  }

  // Condition Chips Widget
  Widget _buildConditionChips(MarketplaceViewModel viewModel) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: _conditions.map((condition) {
        final bool isSelected = viewModel.selectedProductCondition == condition;
        return GestureDetector(
          onTap: () => viewModel.setSelectedProductCondition(condition),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondaryPurple : AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected
                    ? AppColors.secondaryPurple
                    : AppColors.slate200,
                width: 1.2,
              ),
            ),
            child: Text(
              condition,
              style: TextStyle(
                fontSize: AppConstants.fontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.slate800,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Price & Negotiable Row
  Widget _buildPriceRow(MarketplaceViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: viewModel.productPriceController,
            keyboardType: TextInputType.number,
            hintText: 'e.g. 550',
            prefix: const Text(
              '€  ',
              style: TextStyle(
                fontSize: AppConstants.fontSizeXL,
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Negotiable',
          style: TextStyle(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.slate800,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        const SizedBox(width: 6),
        Switch.adaptive(
          value: viewModel.isProductNegotiable,
          activeThumbColor: AppColors.emerald,
          onChanged: (val) => viewModel.setIsProductNegotiable(val),
        ),
      ],
    );
  }

  // Photo Section Header with count and direct "+ Add Photos" button
  Widget _buildPhotosSectionHeader(
    BuildContext context,
    MarketplaceViewModel viewModel,
  ) {
    final count = viewModel.totalProductPhotosCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Photos',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLG,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate800,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              TextSpan(
                text: ' ($count/8 — first photo is cover)',
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeSM,
                  color: AppColors.slate400,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ],
          ),
        ),
        if (count < 8)
          InkWell(
            onTap: () => viewModel.pickProductPhotos(context),
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                '+ Add Photos',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryPurple,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoSlots(MarketplaceViewModel viewModel) {
    final existingPhotos = viewModel.existingProductPhotos;
    final newPhotos = viewModel.selectedProductPhotos;
    final totalCount = existingPhotos.length + newPhotos.length;

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: (totalCount + 1).clamp(1, 8),
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          // 1. Existing Network Photos
          if (index < existingPhotos.length) {
            final photoUrl = existingPhotos[index];
            final resolvedUrl = photoUrl.startsWith('http')
                ? photoUrl
                : '${ApiEndpoints.baseUrl}$photoUrl';
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    resolvedUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.slate200,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.slate400,
                        size: 26,
                      ),
                    ),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.slate100,
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (index == 0)
                  Positioned(
                    left: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPurple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'COVER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: GestureDetector(
                    onTap: () => viewModel.removeExistingProductPhoto(index),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.black54,
                      child: SvgPicture.asset(
                        AppIcons.crossSmallSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // 2. Newly Picked Local Photos
          final newIndex = index - existingPhotos.length;
          if (newIndex < newPhotos.length) {
            final photo = newPhotos[newIndex];
            final isCover = index == 0;
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => viewModel.pickProductPhoto(newIndex, context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(photo.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isCover)
                  Positioned(
                    left: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPurple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'COVER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: GestureDetector(
                    onTap: () => viewModel.removeProductPhoto(newIndex),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.black54,
                      child: SvgPicture.asset(
                        AppIcons.crossSmallSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // 3. Add Photo Button
          return GestureDetector(
            onTap: () => viewModel.pickProductPhotos(context),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.slate300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppIcons.gallerySvg,
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate400,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '+ Add',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeXS11,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Isolated Animated Progress Bar Widget
  Widget _buildAnimatedProgressBar(double targetProgress) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetProgress),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        final int percentage = (animatedValue * 100).round();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Step 1 of 2 — Product Details',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMD,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate600,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeMD,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryPurple,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: animatedValue,
                minHeight: 6,
                backgroundColor: AppColors.slate100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.secondaryPurple,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
