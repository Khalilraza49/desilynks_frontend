import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/models/business_listing_model.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/services/permissions/permission_service.dart';
import 'package:desilynks/viewmodels/profile/my_ads_viewmodel.dart';
import 'package:desilynks/viewmodels/business_listing_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/viewmodels/home/home_viewmodel.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/widgets/custom_date_picker_field.dart';
import 'package:desilynks/widgets/custom_time_picker_dialog.dart';

class EditAdView extends StatelessWidget {
  final PropertyModel? property;
  final BusinessListingModel? business;

  const EditAdView({super.key, this.property, this.business})
    : assert(property != null || business != null);

  @override
  Widget build(BuildContext context) {
    if (business != null) {
      return _BusinessEditAdContent(business: business!);
    }
    return _PropertyEditAdContent(property: property!);
  }
}

class _PropertyEditAdContent extends StatelessWidget {
  final PropertyModel property;

  const _PropertyEditAdContent({required this.property});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyAdsViewModel>(context);

    if (viewModel.currentEditingPropertyId != property.id) {
      viewModel.initEditProperty(property, notify: false);
    }

    // Fetch categories for features/amenities
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesViewModel>().fetchAll();
    });

    // Resolve main display image
    String resolvedMainImageUrl = '';
    if (viewModel.editExistingPhotos.isNotEmpty) {
      resolvedMainImageUrl = viewModel.editExistingPhotos.first.url;
    }
    if (resolvedMainImageUrl.startsWith('/')) {
      resolvedMainImageUrl = '${ApiEndpoints.baseUrl}$resolvedMainImageUrl';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackBasicSvg,
            width: context.scale(20),
            height: context.scale(20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Ad',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppIcons.crossSmallAltSvg,
              width: context.scale(20),
              height: context.scale(20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.slate100, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.hMargin,
                vertical: context.scaleH(16),
              ),
              child: Form(
                key: viewModel.editFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Photo Section Header Card
                    Container(
                      height: context.scaleH(180),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.slate50,
                        image: resolvedMainImageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(resolvedMainImageUrl),
                                fit: BoxFit.cover,
                              )
                            : (viewModel.editNewPhotos.isNotEmpty
                                  ? DecorationImage(
                                      image: FileImage(
                                        viewModel.editNewPhotos.first,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                      ),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () => viewModel.pickEditPhotos(context),
                          icon: SvgPicture.asset(
                            AppIcons.cameraSvg,
                            width: context.scale(18),
                            height: context.scale(18),
                            colorFilter: const ColorFilter.mode(
                              AppColors.primaryBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: Text(
                            'Change Photos',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: context.sp(13),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 2,
                            padding: EdgeInsets.symmetric(
                              horizontal: context.scale(16),
                              vertical: context.scaleH(10),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.scaleH(16)),

                    // Horizontal Photo List / Manager
                    _buildPhotoManagerList(context, viewModel),
                    const SizedBox(height: 24),

                    // Property Status Section
                    _buildStatusSection(context, viewModel),
                    const SizedBox(height: 24),

                    // 2. AD DETAILS Section
                    _buildSectionHeader(context, 'AD DETAILS'),
                    const SizedBox(height: 12),

                    // Title Input
                    _buildLabel(
                      context,
                      viewModel,
                      'Title *',
                      showCounter: true,
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: viewModel.editTitleController,
                      hintText: 'Enter title (e.g. Double room bahawalpur)',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        if (value.length > 100) {
                          return 'Title must be <= 100 characters';
                        }
                        return null;
                      },
                      onChanged: (val) => viewModel.notifyFormUpdate(),
                    ),
                    const SizedBox(height: 16),

                    // Description Input
                    _buildLabel(context, viewModel, 'Description *'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: viewModel.editDescController,
                      hintText: 'Describe your ad in detail...',
                      maxLines: 4,
                      fillColor: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.slate200,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.slate200,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.5,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        if (value.length > 500) {
                          return 'Description must be <= 500 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    _buildLabel(context, viewModel, 'Category'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: viewModel.editSelectedCategory,
                      decoration: _buildInputDecoration(context),
                      items: const [
                        DropdownMenuItem(value: 'ROOM', child: Text('Room')),
                        DropdownMenuItem(
                          value: 'APARTMENT',
                          child: Text('Apartment'),
                        ),
                        DropdownMenuItem(value: 'HOUSE', child: Text('House')),
                        DropdownMenuItem(
                          value: 'STUDIO',
                          child: Text('Studio'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.setEditCategory(value);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // 3. PRICING Section
                    _buildSectionHeader(context, 'PRICING'),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(context, viewModel, 'Price (€)'),
                              const SizedBox(height: 6),
                              CustomTextField(
                                controller: viewModel.editPriceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                hintText: '600',
                                fillColor: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.slate200,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.slate200,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 1.5,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Price is required';
                                  }
                                  final val = double.tryParse(value);
                                  if (val == null || val <= 0) {
                                    return 'Enter positive amount';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: context.scale(12)),
                        // Type
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(context, viewModel, 'Type'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: viewModel.editSelectedPricingType,
                                decoration: _buildInputDecoration(context),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Fixed Price',
                                    child: Text('Fixed Price'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Negotiable',
                                    child: Text('Negotiable'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    viewModel.setEditPricingType(value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 4. LOCATION Section
                    _buildSectionHeader(context, 'LOCATION'),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // City
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(context, viewModel, 'City *'),
                              const SizedBox(height: 6),
                              CustomTextField(
                                controller: viewModel.editCityController,
                                hintText: 'e.g. Barcelona',
                                fillColor: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.slate200,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.slate200,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 1.5,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: context.scale(12)),
                        // Postal Code
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(context, viewModel, 'Postal Code'),
                              const SizedBox(height: 6),
                              CustomTextField(
                                controller: viewModel.editPostalController,
                                hintText: 'e.g. 08001',
                                fillColor: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.slate200,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.slate200,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Country
                    _buildLabel(context, viewModel, 'Country *'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: viewModel.editCountryController,
                      hintText: 'e.g. Spain',
                      fillColor: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.slate200,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.slate200,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.5,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 5. ROOM DETAILS Section
                    _buildSectionHeader(context, 'ROOM DETAILS'),
                    const SizedBox(height: 12),

                    // Available From Date
                    _buildLabel(context, viewModel, 'Available From'),
                    const SizedBox(height: 6),
                    CustomDatePickerField(
                      controller: TextEditingController(
                        text:
                            '${property.availableFrom.month.toString().padLeft(2, '0')}/${property.availableFrom.day.toString().padLeft(2, '0')}/${property.availableFrom.year}',
                      ),
                      hintText: 'mm/dd/yyyy',
                      fontSize: context.isSmall ? 13 : 14,
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
                      onDateSelected: (date) {},
                    ),
                    const SizedBox(height: 16),

                    // Bedrooms & Bathrooms
                    Row(
                      children: [
                        Expanded(
                          child: _buildCounterField(
                            context: context,
                            label: 'Bedrooms',
                            count: property.noOfBedRooms,
                            onIncrement: () {},
                            onDecrement: () {},
                          ),
                        ),
                        SizedBox(width: context.scale(12)),
                        Expanded(
                          child: _buildCounterField(
                            context: context,
                            label: 'Bathrooms',
                            count: property.noOfBathRooms,
                            onIncrement: () {},
                            onDecrement: () {},
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
                                    fontSize: context.isSmall
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
                                spacing: context.isSmall ? 6 : 8,
                                runSpacing: context.isSmall ? 6 : 8,
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  'No features available.',
                                  style: TextStyle(
                                    color: AppColors.slate400,
                                    fontSize: context.isSmall ? 12 : 13,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contact Preference
                    Text(
                      'Contact Preference',
                      style: TextStyle(
                        fontSize: context.isSmall ? 13 : AppConstants.fontSize,
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
                          isSelected:
                              (property.contactPreference ?? 'CHAT')
                                  .toUpperCase() ==
                              'CHAT',
                        ),
                        SizedBox(width: context.isSmall ? 6 : 8),
                        _buildContactPrefCard(
                          context: context,
                          type: 'Call',
                          svg: AppIcons.callSvg,
                          isSelected:
                              (property.contactPreference ?? 'CHAT')
                                  .toUpperCase() ==
                              'CALL',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 6. Make Premium Banner
                    Container(
                      padding: EdgeInsets.all(context.cardPad),
                      decoration: BoxDecoration(
                        color: AppColors.amber100.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.amber200,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(context.scale(8)),
                            decoration: BoxDecoration(
                              color: AppColors.orangeAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              AppIcons.Badge,
                              width: context.scale(20),
                              height: context.scale(20),
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          SizedBox(width: context.scale(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Make this a Premium Ad',
                                  style: TextStyle(
                                    fontSize: context.sp(14),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.orange900,
                                  ),
                                ),
                                SizedBox(height: context.scaleH(2)),
                                Text(
                                  'Reach 10x more people · Top of search',
                                  style: TextStyle(
                                    fontSize: context.sp(12),
                                    color: AppColors.orange700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: context.scale(8)),
                          SvgPicture.asset(
                            AppIcons.More_arrow,
                            width: context.scale(16),
                            height: context.scale(16),
                            colorFilter: const ColorFilter.mode(
                              AppColors.orange700,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.scaleH(32)),

                    // 7. Action Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                            isOutlined: true,
                            borderColor: AppColors.slate200,
                            textColor: AppColors.slate800,
                            fontWeight: FontWeight.bold,
                            fontSize: context.sp(14),
                            borderRadius: 10,
                            height: context.scaleH(48),
                          ),
                        ),
                        SizedBox(width: context.scale(12)),
                        // Save Changes Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: viewModel.isLoading
                                ? null
                                : () async {
                                    if (viewModel.editFormKey.currentState!
                                        .validate()) {
                                      // Verify total photos limits: Max 8, Min 1
                                      final totalPhotosCount =
                                          viewModel.editTotalPhotosCount;
                                      if (totalPhotosCount > 8) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'A property can have at most 8 photos total.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                      if (totalPhotosCount < 1) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'A property must retain at least 1 photo.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      // Location formulation
                                      final city = viewModel
                                          .editCityController
                                          .text
                                          .trim();
                                      final postal = viewModel
                                          .editPostalController
                                          .text
                                          .trim();
                                      final country = viewModel
                                          .editCountryController
                                          .text
                                          .trim();
                                      final String fullLocation =
                                          "$city, $postal, $country";

                                      final double rentVal = double.parse(
                                        viewModel.editPriceController.text,
                                      );
                                      final String rentStr = rentVal
                                          .toStringAsFixed(2);

                                      final double depVal =
                                          double.tryParse(property.deposit) ??
                                          0.0;
                                      final String depStr = depVal
                                          .toStringAsFixed(2);

                                      final String dateIso = property
                                          .availableFrom
                                          .toIso8601String()
                                          .split('T')[0];

                                      // 1. Update text metadata details
                                      final successText = await viewModel
                                          .updateAd(
                                            property.id,
                                            type:
                                                viewModel.editSelectedCategory,
                                            title: viewModel
                                                .editTitleController
                                                .text
                                                .trim(),
                                            description: viewModel
                                                .editDescController
                                                .text
                                                .trim(),
                                            monthlyRent: rentStr,
                                            deposit: depStr,
                                            billsIncluded:
                                                property.billsIncluded,
                                            availableFrom: dateIso,
                                            location: fullLocation,
                                            noOfBedRooms: property.noOfBedRooms,
                                            noOfBathRooms:
                                                property.noOfBathRooms,
                                            featureIds: viewModel
                                                .editSelectedFeatureIds
                                                .toList(),
                                            contactPreference:
                                                property.contactPreference,
                                          );

                                      if (!successText) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                viewModel.errorMessage ??
                                                    'Failed to update text details',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      // 2. Update photos if changed
                                      if (viewModel.editNewPhotos.isNotEmpty ||
                                          viewModel
                                              .editPhotosToRemove
                                              .isNotEmpty) {
                                        final successPhotos = await viewModel
                                            .updateAdPhotos(
                                              property.id,
                                              newPhotos:
                                                  viewModel.editNewPhotos,
                                              photosToRemove:
                                                  viewModel.editPhotosToRemove,
                                            );
                                        if (!successPhotos) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  viewModel.errorMessage ??
                                                      'Failed to update photos',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                          return;
                                        }
                                      }

                                      // 3. Update video if changed
                                      if (viewModel.editNewVideoTour != null ||
                                          viewModel.editRemoveVideo) {
                                        final successVideo = await viewModel
                                            .updateAdVideo(
                                              property.id,
                                              videoTour:
                                                  viewModel.editNewVideoTour,
                                              removeVideo:
                                                  viewModel.editRemoveVideo,
                                            );
                                        if (!successVideo) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  viewModel.errorMessage ??
                                                      'Failed to update video tour',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                          return;
                                        }
                                      }

                                      // Success exit
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Property updated successfully!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: viewModel.isLoading
                                ? SizedBox(
                                    height: context.scale(16),
                                    width: context.scale(16),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : SvgPicture.asset(
                                    AppIcons.tickAltSvg,
                                    width: context.scale(18),
                                    height: context.scale(18),
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                            label: Text(
                              'Save Changes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(14),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreen,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: context.scaleH(14),
                                horizontal: context.scale(8),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
        ),
      ),
    );
  }

  Widget _buildPhotoManagerList(
    BuildContext context,
    MyAdsViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo Gallery (Max 8)',
          style: TextStyle(
            fontSize: context.sp(13),
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
            fontFamily: "Inter",
          ),
        ),
        SizedBox(height: context.scaleH(8)),
        SizedBox(
          height: context.scaleH(80),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Existing photos
              ...viewModel.editExistingPhotos.map((photo) {
                String url = photo.url;
                if (url.startsWith('/')) {
                  url = '${ApiEndpoints.baseUrl}$url';
                }
                return _buildPhotoTile(
                  context,
                  imageProvider: NetworkImage(url),
                  onDelete: () => viewModel.removeEditExistingPhoto(photo),
                );
              }),

              // New photos picked
              ...viewModel.editNewPhotos.map((file) {
                return _buildPhotoTile(
                  context,
                  imageProvider: FileImage(file),
                  onDelete: () => viewModel.removeEditNewPhoto(file),
                );
              }),

              // Pick button
              if (viewModel.editTotalPhotosCount < 8)
                GestureDetector(
                  onTap: () => viewModel.pickEditPhotos(context),
                  child: Container(
                    width: context.scale(80),
                    margin: EdgeInsets.only(right: context.scale(8)),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.slate300,
                        style: BorderStyle.solid,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.assetaddSvg,
                        width: context.scale(24),
                        height: context.scale(24),
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate400,
                          BlendMode.srcIn,
                        ),
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

  Widget _buildPhotoTile(
    BuildContext context, {
    required ImageProvider imageProvider,
    required VoidCallback onDelete,
  }) {
    return Container(
      width: context.scale(80),
      margin: EdgeInsets.only(right: context.scale(8)),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppIcons.crossSmallAltSvg,
                  width: context.scale(12),
                  height: context.scale(12),
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
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: context.sp(12),
        fontWeight: FontWeight.bold,
        color: AppColors.slate400,
        letterSpacing: 0.8,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, MyAdsViewModel viewModel) {
    final status = viewModel.editStatus.toUpperCase();
    final bool isActive = status == 'PUBLISHED';
    final bool isInactive = status == 'INACTIVE';
    final bool isRented = status == 'RENTED';

    final Color badgeBg;
    final Color badgeBorder;
    final Color badgeDot;
    final Color badgeTextColor;
    final String badgeText;
    final String statusHint;

    if (isActive) {
      badgeBg = const Color(0xFFECFDF5);
      badgeBorder = const Color(0xFFA7F3D0);
      badgeDot = const Color(0xFF10B981);
      badgeTextColor = const Color(0xFF065F46);
      badgeText = 'Active / Published';
      statusHint =
          'Your listing is live and discoverable in public search results.';
    } else if (isRented) {
      badgeBg = const Color(0xFFFFFBEB);
      badgeBorder = const Color(0xFFFDE68A);
      badgeDot = const Color(0xFFF59E0B);
      badgeTextColor = const Color(0xFF92400E);
      badgeText = 'Rented';
      statusHint =
          'Property is marked as rented. Public listing shows it as occupied.';
    } else {
      badgeBg = const Color(0xFFFEF2F2);
      badgeBorder = const Color(0xFFFECACA);
      badgeDot = const Color(0xFFEF4444);
      badgeTextColor = const Color(0xFF991B1B);
      badgeText = 'Inactive / Hidden';
      statusHint =
          'Your listing is hidden from public search results and recommendations.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'PROPERTY STATUS'),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(context.scale(14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: "Status" label & current Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate700,
                      fontFamily: "Inter",
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: badgeDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                            fontFamily: "Inter",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                statusHint,
                style: TextStyle(
                  fontSize: context.sp(12),
                  color: AppColors.slate500,
                  fontFamily: "Inter",
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.slate100, height: 1),
              const SizedBox(height: 14),
              Text(
                'Change Status:',
                style: TextStyle(
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate700,
                  fontFamily: "Inter",
                ),
              ),
              const SizedBox(height: 10),
              // Segmented Status Selector Buttons
              Row(
                children: [
                  // 1. Active Option
                  Expanded(
                    child: _buildStatusOptionButton(
                      context: context,
                      title: 'Active',
                      subtitle: 'Public',
                      svgIcon: AppIcons.tickCircleSvg,
                      isSelected: isActive,
                      selectedColor: const Color(0xFF10B981),
                      selectedBg: const Color(0xFFECFDF5),
                      isLoading:
                          viewModel.isLoading &&
                          viewModel.editStatus != 'PUBLISHED',
                      onTap: () => _showStatusConfirmationDialog(
                        context,
                        viewModel,
                        'PUBLISHED',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 2. Inactive Option
                  Expanded(
                    child: _buildStatusOptionButton(
                      context: context,
                      title: 'Inactive',
                      subtitle: 'Hidden',
                      svgIcon: AppIcons.pauseSvg,
                      isSelected: isInactive,
                      selectedColor: const Color(0xFFEF4444),
                      selectedBg: const Color(0xFFFEF2F2),
                      isLoading:
                          viewModel.isLoading &&
                          viewModel.editStatus != 'INACTIVE',
                      onTap: () => _showStatusConfirmationDialog(
                        context,
                        viewModel,
                        'INACTIVE',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 3. Rented Option
                  Expanded(
                    child: _buildStatusOptionButton(
                      context: context,
                      title: 'Rented',
                      subtitle: 'Occupied',
                      svgIcon: AppIcons.TagSvg,
                      isSelected: isRented,
                      selectedColor: const Color(0xFFF59E0B),
                      selectedBg: const Color(0xFFFFFBEB),
                      isLoading:
                          viewModel.isLoading &&
                          viewModel.editStatus != 'RENTED',
                      onTap: () => _showStatusConfirmationDialog(
                        context,
                        viewModel,
                        'RENTED',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOptionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String svgIcon,
    required bool isSelected,
    required Color selectedColor,
    required Color selectedBg,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isSelected ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.slate200,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              svgIcon,
              width: context.scale(18),
              height: context.scale(18),
              colorFilter: ColorFilter.mode(
                isSelected ? selectedColor : AppColors.slate400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: context.sp(12),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? selectedColor : AppColors.slate700,
                fontFamily: "Inter",
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: context.sp(10),
                color: isSelected
                    ? selectedColor.withValues(alpha: 0.8)
                    : AppColors.slate400,
                fontFamily: "Inter",
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusConfirmationDialog(
    BuildContext context,
    MyAdsViewModel viewModel,
    String targetStatus,
  ) {
    final String currentStatus = viewModel.editStatus;
    if (currentStatus == targetStatus) return;

    String title = '';
    String description = '';
    Color themeColor = AppColors.primaryBlue;
    String confirmLabel = '';

    if (targetStatus == 'PUBLISHED') {
      title = 'Set Listing as Active?';
      description =
          'Your property will be published and visible in public search results and room listings. Prospective tenants will be able to contact you.';
      themeColor = const Color(0xFF10B981);
      confirmLabel = 'Activate Listing';
    } else if (targetStatus == 'INACTIVE') {
      title = 'Set Listing as Inactive?';
      description =
          'Your property will be hidden from public searches and new inquiries. You can reactivate it at any time.';
      themeColor = const Color(0xFFEF4444);
      confirmLabel = 'Set Inactive';
    } else if (targetStatus == 'RENTED') {
      title = 'Mark Property as Rented?';
      description =
          'This will indicate the property is no longer available. It will remain in your records with a Rented badge.';
      themeColor = const Color(0xFFF59E0B);
      confirmLabel = 'Mark Rented';
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                targetStatus == 'PUBLISHED'
                    ? AppIcons.tickCircleSvg
                    : (targetStatus == 'INACTIVE'
                          ? AppIcons.pauseSvg
                          : AppIcons.TagSvg),
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: TextStyle(
            fontSize: context.sp(13),
            color: AppColors.slate600,
            height: 1.4,
            fontFamily: 'Inter',
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.slate600,
                fontWeight: FontWeight.w600,
                fontSize: context.sp(13),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await viewModel.setEditPropertyStatus(
                property.id,
                targetStatus,
              );
              if (!context.mounted) return;
              if (success) {
                try {
                  context.read<PostRoomViewModel>().syncPropertyStatus(
                    property.id,
                    targetStatus,
                  );
                } catch (_) {}
                try {
                  context.read<HomeViewModel>().fetchRooms();
                } catch (_) {}
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.tickCircleSvg,
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            targetStatus == 'PUBLISHED'
                                ? 'Property is now Active and visible to users!'
                                : (targetStatus == 'INACTIVE'
                                      ? 'Property is now Inactive and hidden.'
                                      : 'Property successfully marked as Rented.'),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      viewModel.errorMessage ??
                          'Failed to update property status.',
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: Text(
              confirmLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.sp(13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(
    BuildContext context,
    MyAdsViewModel viewModel,
    String text, {
    bool showCounter = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w600,
              color: AppColors.gray800,
              fontFamily: "Inter",
            ),
          ),
        ),
        if (showCounter)
          Text(
            '${viewModel.editTitleController.text.length}/100',
            style: TextStyle(
              fontSize: context.sp(11),
              color: AppColors.slate400,
              fontFamily: "Inter",
            ),
          ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.scale(14),
        vertical: context.scaleH(12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.slate200, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.slate200, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
      ),
      counterText: "",
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
  }) {
    const activeColor = AppColors.vibrantBlue;
    final isSmall = context.isSmall;

    return Expanded(
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
    );
  }

  String? _getAmenitySvg(String title) {
    final t = title.toLowerCase();
    if (t.contains('wifi')) return AppIcons.wifiSvg;
    if (t.contains('furnish')) return AppIcons.furnishedSvg;
    if (t.contains('heat')) return AppIcons.hotSvg;
    if (t.contains('a/c') || t.contains('ac') || t.contains('air')) {
      return AppIcons.acSvg;
    }
    if (t.contains('wash')) return AppIcons.washingMachineSvg;
    if (t.contains('pet')) return AppIcons.petsSvg;
    if (t.contains('bath') || t.contains('tub')) return AppIcons.bathTubSvg;
    return null;
  }

  Widget _buildAmenityChip({
    required BuildContext context,
    required MyAdsViewModel viewModel,
    required String id,
    required String title,
  }) {
    final isSmall = context.isSmall;
    final isSelected = viewModel.editSelectedFeatureIds.contains(id);
    final svg = _getAmenitySvg(title);

    return GestureDetector(
      onTap: () => viewModel.toggleEditFeature(id),
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

// ─────────────────────────────────────────────────────────────────────────────
// Business Listing Edit Ad Content
// ─────────────────────────────────────────────────────────────────────────────
class _BusinessEditAdContent extends StatefulWidget {
  final BusinessListingModel business;

  const _BusinessEditAdContent({required this.business});

  @override
  State<_BusinessEditAdContent> createState() => _BusinessEditAdContentState();
}

class _BusinessEditAdContentState extends State<_BusinessEditAdContent> {
  final _formKey = GlobalKey<FormState>();
  static final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _websiteController;

  String? _selectedCategoryId;
  String? _selectedCategoryTitle;
  late String _currentStatus;

  File? _newCoverPhoto;
  late List<BusinessPhotoModel> _existingGalleries;
  final List<String> _photosToRemove = [];
  final List<File> _newGalleryPhotos = [];

  late TimeOfDay _monFriStart;
  late TimeOfDay _monFriEnd;
  late TimeOfDay _satStart;
  late TimeOfDay _satEnd;
  late TimeOfDay _sunStart;
  late TimeOfDay _sunEnd;
  late bool _isClosedOnSunday;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final biz = widget.business;
    _nameController = TextEditingController(text: biz.name);
    _descController = TextEditingController(text: biz.description);
    _addressController = TextEditingController(text: biz.address);
    _phoneController = TextEditingController(text: biz.phone);
    _whatsappController = TextEditingController(text: biz.whatsApp ?? '');
    _websiteController = TextEditingController(text: biz.website ?? '');

    _selectedCategoryId = biz.categoryId;
    _selectedCategoryTitle = biz.category;
    _currentStatus = biz.status.toUpperCase();

    _existingGalleries = List<BusinessPhotoModel>.from(biz.businessGalleries);

    final hours = biz.businessHours;
    _monFriStart = _parseTime(
      hours?.monToFriStartTime,
      fallback: const TimeOfDay(hour: 9, minute: 0),
    );
    _monFriEnd = _parseTime(
      hours?.monToFriEndTime,
      fallback: const TimeOfDay(hour: 21, minute: 0),
    );
    _satStart = _parseTime(
      hours?.saturdayStartTime,
      fallback: const TimeOfDay(hour: 10, minute: 0),
    );
    _satEnd = _parseTime(
      hours?.saturdayEndTime,
      fallback: const TimeOfDay(hour: 20, minute: 0),
    );
    _sunStart = _parseTime(
      hours?.sundayStartTime,
      fallback: const TimeOfDay(hour: 10, minute: 0),
    );
    _sunEnd = _parseTime(
      hours?.sundayEndTime,
      fallback: const TimeOfDay(hour: 18, minute: 0),
    );
    _isClosedOnSunday = hours?.isClosedOnSunday ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesViewModel>().fetchAll();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String? timeStr, {required TimeOfDay fallback}) {
    if (timeStr == null || timeStr.trim().isEmpty) return fallback;
    try {
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1].split(' ')[0]);
        return TimeOfDay(hour: h, minute: m);
      }
    } catch (_) {}
    return fallback;
  }

  String _formatTimeDisplay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minute $period';
  }

  String _formatTime24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onSelected,
  ) async {
    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => CustomTimePickerDialog(initialTime: initial),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _pickCoverPhoto() async {
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _newCoverPhoto = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking cover photo: $e');
    }
  }

  Future<void> _pickGalleryPhotos() async {
    final total = _existingGalleries.length + _newGalleryPhotos.length;
    if (total >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 gallery photos allowed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
      if (images.isNotEmpty) {
        setState(() {
          final remaining =
              10 - (_existingGalleries.length + _newGalleryPhotos.length);
          for (final img in images.take(remaining)) {
            _newGalleryPhotos.add(File(img.path));
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking gallery photos: $e');
    }
  }

  void _removeExistingGalleryPhoto(BusinessPhotoModel photo) {
    setState(() {
      _existingGalleries.removeWhere((p) => p.id == photo.id);
      _photosToRemove.add(photo.id);
    });
  }

  void _removeNewGalleryPhoto(File file) {
    setState(() {
      _newGalleryPhotos.remove(file);
    });
  }

  void _showStatusConfirmationDialog(String targetStatus) {
    if (_currentStatus == targetStatus) return;

    final isActivating = targetStatus == 'ACTIVE';
    final title = isActivating
        ? 'Set Business as Active?'
        : 'Set Business as Inactive?';
    final description = isActivating
        ? 'Your business listing will be public and discoverable by community members in Local Businesses.'
        : 'Your business listing will be hidden from public discovery. You can reactivate it at any time.';
    final themeColor = isActivating
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final confirmLabel = isActivating ? 'Activate Business' : 'Set Inactive';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                isActivating ? AppIcons.tickCircleSvg : AppIcons.pauseSvg,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: TextStyle(
            fontSize: context.sp(13),
            color: AppColors.slate600,
            height: 1.4,
            fontFamily: 'Inter',
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.slate600,
                fontWeight: FontWeight.w600,
                fontSize: context.sp(13),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              setState(() {
                _currentStatus = targetStatus;
              });
            },
            child: Text(
              confirmLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.sp(13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a business category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final bizVM = context.read<BusinessListingViewModel>();

    try {
      // 1. Status update if changed
      if (_currentStatus != widget.business.status.toUpperCase()) {
        final statusSuccess = await bizVM.updateListingStatus(
          widget.business.id,
          _currentStatus,
        );
        if (!statusSuccess && bizVM.errorMessage != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(bizVM.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // 2. Cover photo update if picked
      if (_newCoverPhoto != null) {
        final coverSuccess = await bizVM.updateCoverPhoto(
          widget.business.id,
          _newCoverPhoto!,
        );
        if (!coverSuccess && bizVM.errorMessage != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(bizVM.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // 3. Gallery update if changed
      if (_photosToRemove.isNotEmpty || _newGalleryPhotos.isNotEmpty) {
        final gallerySuccess = await bizVM.updateGallery(
          widget.business.id,
          photosToRemove: _photosToRemove,
          newPhotos: _newGalleryPhotos,
        );
        if (!gallerySuccess && bizVM.errorMessage != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(bizVM.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // 4. Update details
      final detailsSuccess = await bizVM.updateListingDetails(
        widget.business.id,
        name: _nameController.text.trim(),
        category: _selectedCategoryId,
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        whatsApp: _whatsappController.text.trim().isEmpty
            ? null
            : _whatsappController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        description: _descController.text.trim(),
        monToFriStartTime: _formatTime24(_monFriStart),
        monToFriEndTime: _formatTime24(_monFriEnd),
        saturdayStartTime: _formatTime24(_satStart),
        saturdayEndTime: _formatTime24(_satEnd),
        sundayStartTime: _isClosedOnSunday ? null : _formatTime24(_sunStart),
        sundayEndTime: _isClosedOnSunday ? null : _formatTime24(_sunEnd),
        isClosedOnSunday: _isClosedOnSunday,
      );

      if (!detailsSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                bizVM.errorMessage ?? 'Failed to update business details',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Refresh listings
      await bizVM.fetchMyListings(force: true);
      await bizVM.fetchAllListings(force: true);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business listing updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating business: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve cover photo display
    String resolvedCoverUrl = '';
    if (widget.business.coverPhoto?.url != null &&
        widget.business.coverPhoto!.url.isNotEmpty) {
      resolvedCoverUrl = widget.business.coverPhoto!.url;
      if (resolvedCoverUrl.startsWith('/')) {
        resolvedCoverUrl = '${ApiEndpoints.baseUrl}$resolvedCoverUrl';
      }
    }

    final ImageProvider? coverProvider = _newCoverPhoto != null
        ? FileImage(_newCoverPhoto!)
        : (resolvedCoverUrl.isNotEmpty ? NetworkImage(resolvedCoverUrl) : null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackBasicSvg,
            width: context.scale(20),
            height: context.scale(20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Business',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppIcons.crossSmallAltSvg,
              width: context.scale(20),
              height: context.scale(20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.slate100, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.hMargin,
                vertical: context.scaleH(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Cover Photo Card
                    Container(
                      height: context.scaleH(180),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.slate100,
                        image: coverProvider != null
                            ? DecorationImage(
                                image: coverProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: _pickCoverPhoto,
                          icon: SvgPicture.asset(
                            AppIcons.cameraSvg,
                            width: context.scale(18),
                            height: context.scale(18),
                            colorFilter: const ColorFilter.mode(
                              AppColors.primaryBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: Text(
                            'Change Cover Photo',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: context.sp(13),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 2,
                            padding: EdgeInsets.symmetric(
                              horizontal: context.scale(16),
                              vertical: context.scaleH(10),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.scaleH(16)),

                    // 2. Photo Gallery Manager
                    _buildGalleryManager(context),
                    const SizedBox(height: 24),

                    // 3. Status Section
                    _buildStatusSection(context),
                    const SizedBox(height: 24),

                    // 4. BUSINESS DETAILS
                    _buildSectionHeader('BUSINESS DETAILS'),
                    const SizedBox(height: 12),

                    // Business Name
                    _buildLabel('Business Name *'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'e.g. Desi Spice Restaurant',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Business name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    _buildLabel('Category *'),
                    const SizedBox(height: 6),
                    Consumer<CategoriesViewModel>(
                      builder: (context, catVM, _) {
                        final categories = catVM.businessCategories;
                        final String? effectiveVal;
                        if (categories.any(
                          (c) => c.id == _selectedCategoryId,
                        )) {
                          effectiveVal = _selectedCategoryId;
                        } else if (_selectedCategoryTitle != null &&
                            categories.any(
                              (c) =>
                                  c.title.toLowerCase() ==
                                  _selectedCategoryTitle!.toLowerCase(),
                            )) {
                          final match = categories.firstWhere(
                            (c) =>
                                c.title.toLowerCase() ==
                                _selectedCategoryTitle!.toLowerCase(),
                          );
                          effectiveVal = match.id;
                          _selectedCategoryId = match.id;
                        } else if (categories.isNotEmpty) {
                          effectiveVal = categories.first.id;
                          _selectedCategoryId = categories.first.id;
                        } else {
                          effectiveVal = null;
                        }

                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: effectiveVal,
                          decoration: _buildInputDecoration(
                            hint: 'Select business category',
                          ),
                          items: categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat.id,
                              child: Text(cat.title),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Category is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildLabel('Description *'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _descController,
                      hintText: 'Describe your business, services, menu, etc.',
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 5. CONTACT INFORMATION
                    _buildSectionHeader('CONTACT INFORMATION'),
                    const SizedBox(height: 12),

                    // Phone
                    _buildLabel('Phone Number *'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _phoneController,
                      hintText: '+34 123 456 789',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Website (Optional)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Website (Optional)'),
                        const SizedBox(height: 6),
                        CustomTextField(
                          controller: _websiteController,
                          hintText: 'https://example.com',
                          keyboardType: TextInputType.url,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 6. LOCATION
                    _buildSectionHeader('LOCATION'),
                    const SizedBox(height: 12),

                    // Address
                    _buildLabel('Address *'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _addressController,
                      hintText: 'Full business address, street, city...',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 7. OPERATING HOURS
                    _buildSectionHeader('OPERATING HOURS'),
                    const SizedBox(height: 12),

                    // Monday - Friday Hours
                    _buildHoursCard(
                      context,
                      title: 'Monday - Friday',
                      startTime: _monFriStart,
                      endTime: _monFriEnd,
                      onSelectStart: (t) => setState(() => _monFriStart = t),
                      onSelectEnd: (t) => setState(() => _monFriEnd = t),
                    ),
                    const SizedBox(height: 12),

                    // Saturday Hours
                    _buildHoursCard(
                      context,
                      title: 'Saturday',
                      startTime: _satStart,
                      endTime: _satEnd,
                      onSelectStart: (t) => setState(() => _satStart = t),
                      onSelectEnd: (t) => setState(() => _satEnd = t),
                    ),
                    const SizedBox(height: 12),

                    // Sunday Hours & Closed Switch
                    Container(
                      padding: EdgeInsets.all(context.scale(12)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.slate200,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sunday',
                                style: TextStyle(
                                  fontSize: context.sp(13),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.slate800,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Closed on Sunday',
                                    style: TextStyle(
                                      fontSize: context.sp(12),
                                      color: AppColors.slate600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch.adaptive(
                                    value: _isClosedOnSunday,
                                    activeTrackColor: AppColors.primaryBlue,
                                    onChanged: (val) {
                                      setState(() {
                                        _isClosedOnSunday = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (!_isClosedOnSunday) ...[
                            const SizedBox(height: 10),
                            const Divider(color: AppColors.slate100, height: 1),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePickerBox(
                                    label: 'Opens at',
                                    time: _sunStart,
                                    onTap: () => _selectTime(
                                      _sunStart,
                                      (t) => setState(() => _sunStart = t),
                                    ),
                                  ),
                                ),
                                SizedBox(width: context.scale(12)),
                                Expanded(
                                  child: _buildTimePickerBox(
                                    label: 'Closes at',
                                    time: _sunEnd,
                                    onTap: () => _selectTime(
                                      _sunEnd,
                                      (t) => setState(() => _sunEnd = t),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: context.scaleH(32)),

                    // 8. Action Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                            isOutlined: true,
                            borderColor: AppColors.slate200,
                            textColor: AppColors.slate800,
                            fontWeight: FontWeight.bold,
                            fontSize: context.sp(14),
                            borderRadius: 10,
                            height: context.scaleH(48),
                          ),
                        ),
                        SizedBox(width: context.scale(12)),
                        // Save Changes Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveChanges,
                            icon: _isSaving
                                ? SizedBox(
                                    height: context.scale(16),
                                    width: context.scale(16),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : SvgPicture.asset(
                                    AppIcons.tickAltSvg,
                                    width: context.scale(18),
                                    height: context.scale(18),
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                            label: Text(
                              'Save Changes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(14),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreen,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: context.scaleH(14),
                                horizontal: context.scale(8),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
        ),
      ),
    );
  }

  Widget _buildGalleryManager(BuildContext context) {
    final totalPhotos = _existingGalleries.length + _newGalleryPhotos.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photo Gallery (Max 10)',
              style: TextStyle(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
                fontFamily: "Inter",
              ),
            ),
            Text(
              '$totalPhotos/10',
              style: TextStyle(
                fontSize: context.sp(11),
                color: AppColors.slate400,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
        SizedBox(height: context.scaleH(8)),
        SizedBox(
          height: context.scaleH(80),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Existing photos
              ..._existingGalleries.map((photo) {
                String url = photo.url;
                if (url.startsWith('/')) {
                  url = '${ApiEndpoints.baseUrl}$url';
                }
                return _buildPhotoTile(
                  context,
                  imageProvider: NetworkImage(url),
                  onDelete: () => _removeExistingGalleryPhoto(photo),
                );
              }),

              // New photos picked
              ..._newGalleryPhotos.map((file) {
                return _buildPhotoTile(
                  context,
                  imageProvider: FileImage(file),
                  onDelete: () => _removeNewGalleryPhoto(file),
                );
              }),

              // Add photos button
              if (totalPhotos < 10)
                GestureDetector(
                  onTap: _pickGalleryPhotos,
                  child: Container(
                    width: context.scale(80),
                    margin: EdgeInsets.only(right: context.scale(8)),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.slate300, width: 1.0),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.assetaddSvg,
                        width: context.scale(24),
                        height: context.scale(24),
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate400,
                          BlendMode.srcIn,
                        ),
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

  Widget _buildPhotoTile(
    BuildContext context, {
    required ImageProvider imageProvider,
    required VoidCallback onDelete,
  }) {
    return Container(
      width: context.scale(80),
      margin: EdgeInsets.only(right: context.scale(8)),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppIcons.crossSmallAltSvg,
                  width: context.scale(12),
                  height: context.scale(12),
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
  }

  Widget _buildStatusSection(BuildContext context) {
    final bool isActive = _currentStatus == 'ACTIVE';

    final Color badgeBg = isActive
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFEF2F2);
    final Color badgeBorder = isActive
        ? const Color(0xFFA7F3D0)
        : const Color(0xFFFECACA);
    final Color badgeDot = isActive
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final Color badgeTextColor = isActive
        ? const Color(0xFF065F46)
        : const Color(0xFF991B1B);
    final String badgeText = isActive
        ? 'Active / Published'
        : 'Inactive / Hidden';
    final String statusHint = isActive
        ? 'Your business is live and discoverable in Local Businesses.'
        : 'Your business is hidden from public discovery and search.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('BUSINESS STATUS'),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(context.scale(14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate700,
                      fontFamily: "Inter",
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: badgeDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                            fontFamily: "Inter",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                statusHint,
                style: TextStyle(
                  fontSize: context.sp(12),
                  color: AppColors.slate500,
                  fontFamily: "Inter",
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.slate100, height: 1),
              const SizedBox(height: 14),
              Text(
                'Change Status:',
                style: TextStyle(
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate700,
                  fontFamily: "Inter",
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusOptionButton(
                      title: 'Active',
                      subtitle: 'Public',
                      svgIcon: AppIcons.tickCircleSvg,
                      isSelected: isActive,
                      selectedColor: const Color(0xFF10B981),
                      selectedBg: const Color(0xFFECFDF5),
                      onTap: () => _showStatusConfirmationDialog('ACTIVE'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusOptionButton(
                      title: 'Inactive',
                      subtitle: 'Hidden',
                      svgIcon: AppIcons.pauseSvg,
                      isSelected: !isActive,
                      selectedColor: const Color(0xFFEF4444),
                      selectedBg: const Color(0xFFFEF2F2),
                      onTap: () => _showStatusConfirmationDialog('INACTIVE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOptionButton({
    required String title,
    required String subtitle,
    required String svgIcon,
    required bool isSelected,
    required Color selectedColor,
    required Color selectedBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isSelected ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.slate200,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              svgIcon,
              width: context.scale(18),
              height: context.scale(18),
              colorFilter: ColorFilter.mode(
                isSelected ? selectedColor : AppColors.slate400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: context.sp(12),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? selectedColor : AppColors.slate700,
                fontFamily: "Inter",
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: context.sp(10),
                color: isSelected
                    ? selectedColor.withValues(alpha: 0.8)
                    : AppColors.slate400,
                fontFamily: "Inter",
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursCard(
    BuildContext context, {
    required String title,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required ValueChanged<TimeOfDay> onSelectStart,
    required ValueChanged<TimeOfDay> onSelectEnd,
  }) {
    return Container(
      padding: EdgeInsets.all(context.scale(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: context.sp(13),
              fontWeight: FontWeight.bold,
              color: AppColors.slate800,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTimePickerBox(
                  label: 'Opens at',
                  time: startTime,
                  onTap: () => _selectTime(startTime, onSelectStart),
                ),
              ),
              SizedBox(width: context.scale(12)),
              Expanded(
                child: _buildTimePickerBox(
                  label: 'Closes at',
                  time: endTime,
                  onTap: () => _selectTime(endTime, onSelectEnd),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerBox({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.scale(12),
          vertical: context.scaleH(10),
        ),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.slate200, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(10.5),
                color: AppColors.slate500,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTimeDisplay(time),
                  style: TextStyle(
                    fontSize: context.sp(12.5),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: context.sp(12),
        fontWeight: FontWeight.bold,
        color: AppColors.slate400,
        letterSpacing: 0.8,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.sp(13),
        fontWeight: FontWeight.w600,
        color: AppColors.gray800,
        fontFamily: "Inter",
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.scale(14),
        vertical: context.scaleH(12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.slate200, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.slate200, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
      ),
    );
  }
}
