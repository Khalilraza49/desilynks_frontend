import 'dart:io';
import 'dart:ui';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/viewmodels/business_listing_viewmodel.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/post_success_dialog.dart';
import 'package:desilynks/widgets/custom_time_picker_dialog.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/services/permissions/permission_service.dart';

class PostBusinessListingView extends StatelessWidget {
  const PostBusinessListingView({super.key});

  static final ImagePicker _picker = ImagePicker();

  Future<void> _pickCoverPhoto(
    BuildContext context,
    BusinessListingViewModel vm,
  ) async {
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        vm.setCoverPhoto(image);
      }
    } catch (e) {
      debugPrint('Error picking cover photo: $e');
    }
  }

  Future<void> _pickGalleryPhotos(
    BuildContext context,
    BusinessListingViewModel vm,
  ) async {
    if (vm.galleryPhotos.length >= 10) {
      _showSnackBar(context, 'Maximum 10 gallery photos allowed');
      return;
    }
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
      if (images.isNotEmpty) {
        vm.addGalleryPhotos(images);
      }
    } catch (e) {
      debugPrint('Error picking gallery photos: $e');
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minute $period';
  }

  Future<void> _selectTime(
    BuildContext context,
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

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatTime24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submitBusiness(
    BuildContext context,
    BusinessListingViewModel viewModel,
  ) async {
    FocusScope.of(context).unfocus();

    if (viewModel.businessNameController.text.trim().isEmpty) {
      _showSnackBar(context, 'Please enter your business name');
      return;
    }
    if (viewModel.selectedCategory.isEmpty) {
      _showSnackBar(context, 'Please select a business category');
      return;
    }
    if (viewModel.addressController.text.trim().isEmpty) {
      _showSnackBar(context, 'Please enter business address');
      return;
    }
    if (viewModel.phoneController.text.trim().isEmpty) {
      _showSnackBar(context, 'Please enter a phone number');
      return;
    }
    if (viewModel.descriptionController.text.trim().isEmpty) {
      _showSnackBar(context, 'Please enter business description');
      return;
    }

    final coverFile = viewModel.coverPhoto != null
        ? File(viewModel.coverPhoto!.path)
        : null;
    final galleryFiles = viewModel.galleryPhotos
        .map((x) => File(x.path))
        .toList();

    String? categoryId = viewModel.selectedCategoryId;
    if (categoryId == null || categoryId.isEmpty) {
      final catVM = Provider.of<CategoriesViewModel>(context, listen: false);
      for (final c in catVM.businessCategories) {
        if (c.title.toLowerCase() == viewModel.selectedCategory.toLowerCase() ||
            c.id == viewModel.selectedCategory) {
          categoryId = c.id;
          break;
        }
      }
    }

    if (categoryId == null || categoryId.isEmpty) {
      _showSnackBar(context, 'Please select a valid business category');
      return;
    }

    final success = await viewModel.createBusinessListing(
      name: viewModel.businessNameController.text.trim(),
      category: categoryId,
      address: viewModel.addressController.text.trim(),
      phone: viewModel.phoneController.text.trim(),
      whatsApp: null,
      website: null,
      description: viewModel.descriptionController.text.trim(),
      monToFriStartTime: _formatTime24(viewModel.monFriStart),
      monToFriEndTime: _formatTime24(viewModel.monFriEnd),
      saturdayStartTime: _formatTime24(viewModel.satStart),
      saturdayEndTime: _formatTime24(viewModel.satEnd),
      sundayStartTime: viewModel.isSundayOpen
          ? _formatTime24(viewModel.sunStart)
          : null,
      sundayEndTime: viewModel.isSundayOpen
          ? _formatTime24(viewModel.sunEnd)
          : null,
      isClosedOnSunday: !viewModel.isSundayOpen,
      logo: null,
      coverPhoto: coverFile,
      gallery: galleryFiles.isNotEmpty ? galleryFiles : null,
    );

    if (!context.mounted) return;

    if (success) {
      viewModel.resetForm();
      PostSuccessFadeDialog.show(
        context,
        title: 'Business Listed!',
        message:
            'Your local business listing has been submitted successfully and will be visible to nearby customers.',
        onContinue: () {
          Navigator.pop(context); // Close dialog
          Navigator.pushReplacementNamed(context, AppRoutes.localBusiness);
        },
      );
    } else if (viewModel.errorMessage != null) {
      _showSnackBar(context, viewModel.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<CategoriesViewModel>().fetchAll();
      }
    });

    final viewModel = context.watch<BusinessListingViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0.5,
      //   leading: GestureDetector(
      //     onTap: () => Navigator.pop(context),
      //     child: Container(
      //       padding: const EdgeInsets.all(8),
      //       decoration: const BoxDecoration(
      //         color: AppColors.slate100,
      //         shape: BoxShape.circle,
      //       ),
      //       child: SvgPicture.asset(
      //         AppIcons.arrowBackSvg,
      //         width: 18,
      //         height: 18,
      //         colorFilter: const ColorFilter.mode(
      //           AppColors.slate500,
      //           BlendMode.srcIn,
      //         ),
      //       ),
      //     ),
      //   ),
      //   centerTitle: true,
      //   title: const Text(
      //     'Business Listing',
      //     style: TextStyle(
      //       color: AppColors.slate900,
      //       fontSize: 18,
      //       fontWeight: FontWeight.bold,
      //       fontFamily: AppStrings.fontInter,
      //     ),
      //   ),
      // actions: [
      //   TextButton(
      //     onPressed: _saveDraft,
      //     child: const Text(
      //       'Draft',
      //       style: TextStyle(
      //         color: AppColors.vibrantBlue,
      //         fontSize: 15,
      //         fontWeight: FontWeight.w600,
      //         fontFamily: AppStrings.fontInter,
      //       ),
      //     ),
      //   ),
      // ],
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  const Spacer(),
                  const Text(
                    'Local Business',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeXXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 34),
                  // Draft button
                  // GestureDetector(
                  //   onTap: () async {
                  //     final success = await postRoomViewModel.saveDraft();
                  //     if (success && context.mounted) {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(
                  //           content: Text(postRoomViewModel.successMessage ?? 'Draft saved!'),
                  //           behavior: SnackBarBehavior.floating,
                  //           backgroundColor: Colors.green,
                  //         ),
                  //       );
                  //       _titleController.clear();
                  //       _descriptionController.clear();
                  //       _rentController.clear();
                  //       _locationController.clear();
                  //       Navigator.pushReplacementNamed(
                  //         context,
                  //         AppRoutes.myRooms,
                  //       );
                  //     }
                  //   },
                  //   child: const Text(
                  //     'Draft',
                  //     style: TextStyle(
                  //       fontSize: 14,
                  //       color: AppColors.vibrantBlue,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            // Step progress indicator sub-header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step 1 of 2 — Local Business Info',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate600,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      Text(
                        '50%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF43F5E),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 50% pink/red progress line
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Business Photos
                      const Text(
                        'Business Photos',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Add Cover Photo Card
                      GestureDetector(
                        onTap: () => _pickCoverPhoto(context, viewModel),
                        child: CustomPaint(
                          painter: DashedBorderPainter(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: 14,
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF1F5F9,
                              ).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: viewModel.coverPhoto != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      File(viewModel.coverPhoto!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AppIcons.gallerySvg,
                                        height: 25,
                                        width: 25,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.slate900,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Add Cover Photo',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.slate700,
                                          fontFamily: AppStrings.fontInter,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Recommended: 1200×400',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.slate400,
                                          fontFamily: AppStrings.fontInter,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Section 2: Business Name *
                      _buildRequiredLabel('Business Name'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: viewModel.businessNameController,
                        hintText: 'e.g. Desi Mart Barcelona',
                      ),

                      const SizedBox(height: 20),

                      // Section 3: Business Category *
                      _buildRequiredLabel('Business Category'),
                      const SizedBox(height: 8),
                      Consumer<CategoriesViewModel>(
                        builder: (context, catVM, _) {
                          final items = catVM.businessCategories;
                          final isValidValue = items.any(
                            (c) => c.id == viewModel.selectedCategoryId,
                          );
                          return DropdownButtonFormField<String>(
                            initialValue: isValidValue
                                ? viewModel.selectedCategoryId
                                : null,
                            isExpanded: true,
                            menuMaxHeight: 380,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            hint: Text(
                              catVM.isLoading
                                  ? 'Loading categories…'
                                  : 'Select category',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.slate400,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                            icon: SvgPicture.asset(
                              AppIcons.arrowDropDownSvg,
                              height: 20,
                              width: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate400,
                                BlendMode.srcIn,
                              ),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: AppColors.vibrantBlue,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            items: items.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat.id,
                                child: Text(
                                  cat.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.slate800,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final match = items.firstWhere(
                                  (c) => c.id == val,
                                  orElse: () => items.first,
                                );
                                viewModel.setSelectedCategory(
                                  match.title,
                                  categoryId: val,
                                );
                              }
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Section 4: Address * & Pin on Map
                      _buildRequiredLabel('Address'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: viewModel.addressController,
                        hintText: 'Street address, city',
                        prefixIcon: Container(
                          height: 15,
                          width: 15,
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            AppIcons.locationSvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.textLightGray,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section 5: Phone
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRequiredLabel('Phone'),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: viewModel.phoneController,
                            hintText: '+34 612...',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Container(
                              height: 15,
                              width: 15,
                              padding: const EdgeInsets.all(12),
                              child: SvgPicture.asset(
                                AppIcons.callSvg,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.textLightGray,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Section 7: Description *
                      _buildRequiredLabel('Description'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: viewModel.descriptionController,
                        hintText:
                            'Tell customers about your business, products and services...',
                        maxLines: 4,
                      ),

                      const SizedBox(height: 24),

                      // Section 8: Opening Hours
                      const Text(
                        'Opening Hours',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            // Mon–Fri Row
                            Row(
                              children: [
                                const SizedBox(
                                  width: 70,
                                  child: Text(
                                    'Mon–Fri',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate800,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        _buildTimeBox(
                                          _formatTime(viewModel.monFriStart),
                                          () {
                                            _selectTime(
                                              context,
                                              viewModel.monFriStart,
                                              (t) =>
                                                  viewModel.setMonFriStart(t),
                                            );
                                          },
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(
                                            '–',
                                            style: TextStyle(
                                              color: AppColors.slate400,
                                            ),
                                          ),
                                        ),
                                        _buildTimeBox(
                                          _formatTime(viewModel.monFriEnd),
                                          () {
                                            _selectTime(
                                              context,
                                              viewModel.monFriEnd,
                                              (t) => viewModel.setMonFriEnd(t),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Saturday Row
                            Row(
                              children: [
                                const SizedBox(
                                  width: 70,
                                  child: Text(
                                    'Saturday',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate800,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        _buildTimeBox(
                                          _formatTime(viewModel.satStart),
                                          () {
                                            _selectTime(
                                              context,
                                              viewModel.satStart,
                                              (t) => viewModel.setSatStart(t),
                                            );
                                          },
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(
                                            '–',
                                            style: TextStyle(
                                              color: AppColors.slate400,
                                            ),
                                          ),
                                        ),
                                        _buildTimeBox(
                                          _formatTime(viewModel.satEnd),
                                          () {
                                            _selectTime(
                                              context,
                                              viewModel.satEnd,
                                              (t) => viewModel.setSatEnd(t),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Sunday Row
                            Row(
                              children: [
                                const SizedBox(
                                  width: 70,
                                  child: Text(
                                    'Sunday',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate800,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: viewModel.isSundayOpen
                                      ? FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildTimeBox(
                                                _formatTime(viewModel.sunStart),
                                                () {
                                                  _selectTime(
                                                    context,
                                                    viewModel.sunStart,
                                                    (t) => viewModel
                                                        .setSunStart(t),
                                                  );
                                                },
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                ),
                                                child: Text(
                                                  '–',
                                                  style: TextStyle(
                                                    color: AppColors.slate400,
                                                  ),
                                                ),
                                              ),
                                              _buildTimeBox(
                                                _formatTime(viewModel.sunEnd),
                                                () {
                                                  _selectTime(
                                                    context,
                                                    viewModel.sunEnd,
                                                    (t) =>
                                                        viewModel.setSunEnd(t),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      : const Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'Closed',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFF43F5E),
                                              fontFamily: AppStrings.fontInter,
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 4),
                                Transform.scale(
                                  scale: 0.85,
                                  child: Switch(
                                    value: viewModel.isSundayOpen,
                                    onChanged: (val) =>
                                        viewModel.setIsSundayOpen(val),
                                    activeThumbColor: AppColors.vibrantBlue,
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: const Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section 9: Gallery Photos (up to 10)
                      const Row(
                        children: [
                          Text(
                            'Gallery Photos',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '(up to 10)',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.slate400,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // ADD Button (Pink box)
                            GestureDetector(
                              onTap: () =>
                                  _pickGalleryPhotos(context, viewModel),
                              child: CustomPaint(
                                painter: DashedBorderPainter(
                                  color: const Color(0xFFFDA4AF),
                                  borderRadius: 14,
                                ),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1F2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AppIcons.plusCircleSvg,
                                        height: 24,
                                        width: 24,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.rose500,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'ADD',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFF43F5E),
                                          fontFamily: AppStrings.fontInter,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Render picked gallery photos
                            ...List.generate(viewModel.galleryPhotos.length, (
                              index,
                            ) {
                              final xFile = viewModel.galleryPhotos[index];
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
                                        onTap: () =>
                                            viewModel.removeGalleryPhoto(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: SvgPicture.asset(
                                            AppIcons.crossSmallSvg,
                                            height: 14,
                                            width: 14,
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

                            // Placeholder boxes to match screenshot if 0 or few photos
                            if (viewModel.galleryPhotos.length < 3)
                              ...List.generate(
                                3 - viewModel.galleryPhotos.length,
                                (idx) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF1F5F9,
                                        ).withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: SvgPicture.asset(
                                          AppIcons.gallerySvg,
                                          height: 25,
                                          width: 25,
                                          colorFilter: const ColorFilter.mode(
                                            AppColors.textLightGray,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section 10: Promote Your Business Banner Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEFCE8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFEF08A)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEF9C3),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                AppIcons.starFavoriteSvg,
                                height: 18,
                                width: 18,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.accentYellow,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Promote Your Business',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF854D0E),
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Get 10x more customers',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFA16207),
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showSnackBar(
                                  context,
                                  'Promote feature selected!',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEAB308),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Promote',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Section 11: List My Business Primary Button
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
                          borderRadius: BorderRadius.circular(14),
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
                                onPressed: () =>
                                    _submitBusiness(context, viewModel),
                                icon: SvgPicture.asset(
                                  AppIcons.businessSvg,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                  width: 18,
                                  height: 18,
                                ),
                                label: const Text(
                                  'List My Business',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
                fontFamily: AppStrings.fontInter,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                AppIcons.TimerSvg,
                height: 15,
                width: 15,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate800,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              color: Color(0xFFF43F5E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for dashed borders
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  DashedBorderPainter({
    required this.color,
    this.borderRadius = 14,
    this.strokeWidth = 1.2,
    this.dashWidth = 5,
    this.dashGap = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashGap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
