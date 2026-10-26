import 'dart:io';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/widgets/post_success_dialog.dart';
import 'package:desilynks/widgets/form_progress_bar.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/my_ads_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/custom_date_picker_field.dart';

class PostRoomView extends StatelessWidget {
  const PostRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesViewModel>().fetchAll();
    });
    final isSmall = context.isSmall;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 20,
                vertical: isSmall ? 10 : 12,
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
                  Expanded(
                    child: Center(
                      child: Text(
                        'Post A Room',
                        style: TextStyle(
                          fontSize: isSmall ? 18 : AppConstants.fontSizeXXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 34),
                ],
              ),
            ),
            const Divider(color: AppColors.slate200, thickness: 1.0, height: 1),

            // 2. Step Progress Bar
            Consumer<PostRoomViewModel>(
              builder: (context, viewModel, child) {
                return FormProgressBar(
                  progress: viewModel.formProgress,
                  stepText: viewModel.currentStepText,
                  activeColor: AppColors.vibrantBlue,
                );
              },
            ),

            // 3. Scrollable Form Fields
            Expanded(
              child: Consumer<PostRoomViewModel>(
                builder: (context, viewModel, child) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 16 : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Property Type Selection
                        Text(
                          'Property Type',
                          style: TextStyle(
                            fontSize: isSmall ? 15 : AppConstants.fontSizeXL,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildPropertyTypeCard(
                              context: context,
                              type: 'Room',
                              svg: AppIcons.roomSvg,
                              isSelected: viewModel.propertyType == 'Room',
                              onTap: () => viewModel.setPropertyType('Room'),
                            ),
                            SizedBox(width: isSmall ? 6 : 8),
                            _buildPropertyTypeCard(
                              context: context,
                              type: 'Apartment',
                              svg: AppIcons.apartmentSvg,
                              isSelected: viewModel.propertyType == 'Apartment',
                              onTap: () =>
                                  viewModel.setPropertyType('Apartment'),
                            ),
                            SizedBox(width: isSmall ? 6 : 8),
                            _buildPropertyTypeCard(
                              context: context,
                              type: 'House',
                              svg: AppIcons.homeSvg,
                              isSelected: viewModel.propertyType == 'House',
                              onTap: () => viewModel.setPropertyType('House'),
                            ),
                            SizedBox(width: isSmall ? 6 : 8),
                            _buildPropertyTypeCard(
                              context: context,
                              type: 'Studio',
                              svg: AppIcons.studioSvg,
                              isSelected: viewModel.propertyType == 'Studio',
                              onTap: () => viewModel.setPropertyType('Studio'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        _buildLabel(context, 'Title'),
                        CustomTextField(
                          controller: viewModel.roomTitleController,
                          onChanged: viewModel.setTitle,
                          fontSize: isSmall ? 13 : 14,
                          hintText: 'e.g private room in share',
                          fillColor: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _buildLabel(context, 'Description'),
                        CustomTextField(
                          controller: viewModel.roomDescriptionController,
                          onChanged: viewModel.setDescription,
                          fontSize: isSmall ? 13 : 14,
                          maxLines: 4,
                          hintText: 'Describe your property.....',
                          fillColor: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 16),

                        // Monthly Rent
                        _buildLabel(context, 'Monthly Rent (€)'),
                        CustomTextField(
                          controller: viewModel.roomRentController,
                          keyboardType: TextInputType.number,
                          onChanged: viewModel.setMonthlyRent,
                          fontSize: isSmall ? 13 : 14,
                          hintText: '',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              AppIcons.euroSvg,
                              height: 10,
                              width: 10,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate400,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          fillColor: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 16),

                        // Available from Date Picker
                        _buildLabel(context, 'Available from'),
                        CustomDatePickerField(
                          controller: viewModel.roomAvailableFromController,
                          hintText: 'mm/dd/yyyy',
                          fontSize: isSmall ? 13 : 14,
                          firstDate: DateTime.now(),
                          showSuffixIcon: false,
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(10),
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
                            viewModel.setAvailableFrom(date);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Location / Address
                        _buildLabel(context, 'Location / Address'),
                        CustomTextField(
                          controller: viewModel.roomLocationController,
                          onChanged: viewModel.setLocationAddress,
                          fontSize: isSmall ? 13 : 14,
                          hintText: 'Call, grain via madrid',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              AppIcons.locationSvg,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate400,
                                BlendMode.srcIn,
                              ),
                              width: 18,
                              height: 18,
                            ),
                          ),
                          fillColor: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 16),

                        // Bedrooms & Bathrooms counters
                        Row(
                          children: [
                            Expanded(
                              child: _buildCounterField(
                                context: context,
                                label: 'Bedrooms',
                                count: viewModel.bedrooms,
                                onIncrement: viewModel.incrementBedrooms,
                                onDecrement: viewModel.decrementBedrooms,
                              ),
                            ),
                            SizedBox(width: isSmall ? 10 : 16),
                            Expanded(
                              child: _buildCounterField(
                                context: context,
                                label: 'Bathrooms',
                                count: viewModel.bathrooms,
                                onIncrement: viewModel.incrementBathrooms,
                                onDecrement: viewModel.decrementBathrooms,
                              ),
                            ),
                          ],
                        ),
                         const SizedBox(height: 16),

                        // Features & Amenities
                        Consumer<CategoriesViewModel>(
                          builder: (context, catVM, _) {
                            final items = catVM.propertyFeatures;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Features & Amenities',
                                      style: TextStyle(
                                        fontSize: isSmall
                                            ? 13
                                            : AppConstants.fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.slate800,
                                      ),
                                    ),
                                    if (catVM.isLoading) ...[
                                      const SizedBox(width: 8),
                                      const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (items.isNotEmpty)
                                  Wrap(
                                    spacing: isSmall ? 6 : 8,
                                    runSpacing: isSmall ? 6 : 8,
                                    children: items.map((item) {
                                      return _buildAmenityChip(
                                        context: context,
                                        viewModel: viewModel,
                                        id: item.id,
                                        title: item.title,
                                      );
                                    }).toList(),
                                  )
                                else if (!catVM.isLoading)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'No features available.',
                                      style: TextStyle(
                                        color: AppColors.slate400,
                                        fontSize: isSmall ? 12 : 13,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Photo row (up to 8)
                        Text(
                          'Photos (${viewModel.photos.length}/8)',
                          style: TextStyle(
                            fontSize: isSmall ? 13 : AppConstants.fontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: isSmall ? 68 : 72,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: viewModel.photos.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // Add button
                                return GestureDetector(
                                  onTap: () => viewModel.pickRoomPhoto(context),
                                  child: Container(
                                    width: isSmall ? 68 : 72,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.slate50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.slate300,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          AppIcons.add_cameraSvg,
                                          colorFilter: const ColorFilter.mode(
                                            AppColors.textLabel,
                                            BlendMode.srcIn,
                                          ),
                                          width: isSmall ? 22 : 24,
                                          height: isSmall ? 22 : 24,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          textAlign: TextAlign.center,
                                          'Upload Images',
                                          style: TextStyle(
                                            fontSize: isSmall
                                                ? 10
                                                : AppConstants.fontSizeXS,
                                            color: AppColors.slate500,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final photoPath = viewModel.photos[index - 1];
                              return Stack(
                                children: [
                                  Container(
                                    width: isSmall ? 68 : 72,
                                    height: isSmall ? 68 : 72,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: photoPath.startsWith('http')
                                            ? NetworkImage(photoPath)
                                            : FileImage(File(photoPath))
                                                  as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 12,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          viewModel.removePhoto(index - 1),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryRed,
                                          shape: BoxShape.circle,
                                        ),
                                        child: SvgPicture.asset(
                                          AppIcons.crossSmallSvg,
                                          height: 10,
                                          width: 10,
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
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Contact Preference
                        Text(
                          'Contact Preference',
                          style: TextStyle(
                            fontSize: isSmall ? 13 : AppConstants.fontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildContactPrefCard(
                              context: context,
                              type: 'Chat',
                              svg: AppIcons.chatRoundSvg,
                              isSelected: viewModel.contactPreference == 'Chat',
                              onTap: () =>
                                  viewModel.setContactPreference('Chat'),
                            ),
                            SizedBox(width: isSmall ? 6 : 8),
                            _buildContactPrefCard(
                              context: context,
                              type: 'Call',
                              svg: AppIcons.callSvg,
                              isSelected: viewModel.contactPreference == 'Call',
                              onTap: () =>
                                  viewModel.setContactPreference('Call'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Publish Room Button
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
                          child: viewModel.isLoading
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
                                    if (viewModel.validate(context)) {
                                      final success = await viewModel
                                          .publishRoom();
                                      if (success && context.mounted) {
                                        viewModel.clearRoomForm();
                                        try {
                                          context
                                              .read<MyAdsViewModel>()
                                              .fetchUserAds(force: true);
                                        } catch (_) {}
                                        final createdProperty = viewModel.lastCreatedProperty;
                                        PostSuccessFadeDialog.show(
                                          context,
                                          title: 'Room Published!',
                                          message:
                                              'Your room listing is now active and visible.',
                                          viewListingText: 'View Room Posting',
                                          continueText: 'Go to My Ads',
                                          onViewListing: createdProperty != null
                                              ? () {
                                                  Navigator.pop(context); // close dialog
                                                  Navigator.pushReplacementNamed(
                                                    context,
                                                    AppRoutes.roomSingleDetails,
                                                    arguments: createdProperty,
                                                  );
                                                }
                                              : null,
                                          onContinue: () {
                                            Navigator.pop(
                                              context,
                                            ); // close dialog
                                            Navigator.pushReplacementNamed(
                                              context,
                                              AppRoutes.myAds,
                                            );
                                          },
                                        );
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              viewModel.errorMessage ??
                                                  'Failed to publish room',
                                            ),
                                            backgroundColor:
                                                AppColors.primaryRed,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: SvgPicture.asset(
                                    AppIcons.send2,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.white,
                                      BlendMode.srcIn,
                                    ),
                                    width: isSmall ? 16 : 18,
                                    height: isSmall ? 16 : 18,
                                  ),
                                  label: Text(
                                    'Publish Room',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: isSmall
                                          ? 15
                                          : AppConstants.fontSizeXL,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.transparent,
                                    shadowColor: AppColors.transparent,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmall ? 13 : 16,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(
    BuildContext context,
    String text, {
    bool isRequired = true,
  }) {
    final isSmall = context.isSmall;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: isSmall ? 13 : AppConstants.fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.slate800,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
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
    );
  }

  Widget _buildPropertyTypeCard({
    required BuildContext context,
    required String type,
    required String svg,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const activeColor = AppColors.vibrantBlue;
    final isSmall = context.isSmall;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.slate200,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                svg,
                width: isSmall ? 20 : 22,
                height: isSmall ? 20 : 22,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.white : AppColors.slate500,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: isSmall ? 10.5 : AppConstants.fontSizeXS11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.slate800,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterField({
    required BuildContext context,
    required String label,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    final isSmall = context.isSmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 13 : AppConstants.fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.slate800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.slate200),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 4 : 6,
            vertical: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onDecrement,
                child: Container(
                  padding: EdgeInsets.all(isSmall ? 4 : 6),
                  child: SvgPicture.asset(
                    AppIcons.minusSvg,
                    width: isSmall ? 14 : 16,
                    height: isSmall ? 14 : 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate500,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: isSmall ? 14 : AppConstants.fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate800,
                ),
              ),
              GestureDetector(
                onTap: onIncrement,
                child: Container(
                  padding: EdgeInsets.all(isSmall ? 4 : 6),
                  child: SvgPicture.asset(
                    AppIcons.plusSvg,
                    width: isSmall ? 14 : 16,
                    height: isSmall ? 14 : 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate500,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactPrefCard({
    required BuildContext context,
    required String type,
    required String svg,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const activeColor = AppColors.vibrantBlue;
    final isSmall = context.isSmall;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.slate200,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svg,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.white : AppColors.slate500,
                  BlendMode.srcIn,
                ),
                width: isSmall ? 15 : 16,
                height: isSmall ? 15 : 16,
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  fontSize: isSmall ? 12.5 : AppConstants.fontSizeSM,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.white : AppColors.slate800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getAmenitySvg(String title) {
    final t = title.toLowerCase();
    if (t.contains('wifi')) return AppIcons.wifiSvg;
    if (t.contains('furnish')) return AppIcons.furnishedSvg;
    if (t.contains('heat')) return AppIcons.hotSvg;
    if (t.contains('a/c') || t.contains('ac') || t.contains('air')) return AppIcons.acSvg;
    if (t.contains('wash')) return AppIcons.washingMachineSvg;
    if (t.contains('pet')) return AppIcons.petsSvg;
    if (t.contains('bath') || t.contains('tub')) return AppIcons.bathTubSvg;
    return null;
  }

  Widget _buildAmenityChip({
    required BuildContext context,
    required PostRoomViewModel viewModel,
    required String id,
    required String title,
  }) {
    final isSmall = context.isSmall;
    final isSelected = viewModel.selectedAmenities.contains(id);
    final svg = _getAmenitySvg(title);

    return GestureDetector(
      onTap: () => viewModel.toggleAmenity(id),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 12,
          vertical: isSmall ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.vibrantBlue : AppColors.slate200,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svg != null) ...[
              SvgPicture.asset(
                svg,
                width: isSmall ? 13 : 14,
                height: isSmall ? 13 : 14,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.vibrantBlue : AppColors.slate500,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: isSmall ? 11 : AppConstants.fontSizeSM,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.vibrantBlue : AppColors.slate700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
