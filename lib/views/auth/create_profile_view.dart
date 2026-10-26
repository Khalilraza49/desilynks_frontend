import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/field_label.dart';
import '../../widgets/gender_dropdown_field.dart';
import '../../widgets/image_crop_dialog.dart';
import '../../widgets/custom_button.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import '../../services/permissions/permission_service.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class CreateProfileView extends StatefulWidget {
  final Map<String, dynamic>? registrationData;
  const CreateProfileView({super.key, this.registrationData});

  @override
  State<CreateProfileView> createState() => _CreateProfileViewState();
}

class _CreateProfileViewState extends State<CreateProfileView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _pickAndCropImage(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: SvgPicture.asset(
                  AppIcons.cameraSvg,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.primaryBlue,
                    BlendMode.srcIn,
                  ),
                ),
                title: const Text('Take Photo from Camera'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: SvgPicture.asset(
                  AppIcons.gallerySvg,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.primaryBlue,
                    BlendMode.srcIn,
                  ),
                ),
                title: const Text('Upload from Photos / Gallery'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null || !context.mounted) return;

    final bool hasPermission;
    if (source == ImageSource.camera) {
      hasPermission = await PermissionService.requestCamera(context);
    } else {
      hasPermission = await PermissionService.requestGallery(context);
    }
    if (!hasPermission || !context.mounted) return;

    try {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile == null || !context.mounted) return;

      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Profile Photo',
              toolbarColor: AppTheme.primaryBlue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
              ],
            ),
            IOSUiSettings(
              title: 'Crop Profile Photo',
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
              ],
            ),
          ],
        );
        if (croppedFile != null) {
          authViewModel.setProfileSelectedImage(File(croppedFile.path));
        }
      } catch (cropError) {
        debugPrint(
          'Native cropper unavailable/error ($cropError), opening Flutter Crop Dialog',
        );
        if (context.mounted) {
          final File? customCropped = await Navigator.push<File>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ImageCropDialog(imageFile: File(pickedFile.path)),
            ),
          );
          if (customCropped != null) {
            authViewModel.setProfileSelectedImage(customCropped);
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      authViewModel.profileDobController.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  Future<void> _handleSaveChanges(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await authViewModel.updateProfile(
      firstName: authViewModel.profileFirstNameController.text.trim(),
      lastName: authViewModel.profileLastNameController.text.trim(),
      email: authViewModel.profileEmailController.text.trim(),
      phone: authViewModel.profilePhoneController.text.trim(),
      gender: authViewModel.profileGenderController.text,
      dob: authViewModel.profileDobController.text,
      location: authViewModel.profileLocationController.text.trim(),
      postalCode: widget.registrationData?['postalCode'] as String?,
      city: widget.registrationData?['city'] as String?,
      province: widget.registrationData?['province'] as String?,
      country: widget.registrationData?['country'] as String?,
      profilePhoto: authViewModel.profileSelectedImage,
    );

    if (success && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.assetVerifyTick,
                        colorFilter: const ColorFilter.mode(
                          AppTheme.successGreen,
                          BlendMode.srcIn,
                        ),
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.profileCreatedTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDarkSlate,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.profileCreatedDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGray,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: AppStrings.btnContinue,
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    backgroundColor: AppTheme.accentBlue,
                    height: 48,
                    borderRadius: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (context.mounted && authViewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authViewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    authViewModel.initCreateProfile(widget.registrationData);

    // Custom borders to match mockup design
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppTheme.borderGray, width: 1.0),
    );

    final focusedBorderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 46,
        leading: Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                AppIcons.assetBackArrow,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppTheme.textDarkSlate,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Text(
            AppStrings.createProfileTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textBlackNero,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.isSmall ? 16.0 : 24.0,
            vertical: 24.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Change Photo Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _pickAndCropImage(context),
                        child: authViewModel.profileSelectedImage != null
                            ? Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryBlue,
                                    width: 2.5,
                                  ),
                                  image: DecorationImage(
                                    image: FileImage(
                                      authViewModel.profileSelectedImage!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : SvgPicture.asset(
                                AppIcons.personSvg,
                                width: 60,
                                height: 60,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.textGray,
                                  BlendMode.srcIn,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextButton(
                          onPressed: () => _pickAndCropImage(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            AppStrings.changePhoto,
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // First Name field
                const FieldLabel(
                  label: AppStrings.firstNameLabel,
                  bottomPadding: 6,
                ),
                CustomTextField(
                  controller: authViewModel.profileFirstNameController,
                  hintText: AppStrings.hintFirstName,
                  fillColor: AppColors.white,
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  focusedBorder: focusedBorderStyle,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? AppStrings.valFirstName
                      : null,
                ),
                const SizedBox(height: 16),

                // Last Name field
                const FieldLabel(
                  label: AppStrings.lastNameLabel,
                  bottomPadding: 6,
                ),
                CustomTextField(
                  controller: authViewModel.profileLastNameController,
                  hintText: AppStrings.hintLastName,
                  fillColor: AppColors.white,
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  focusedBorder: focusedBorderStyle,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? AppStrings.valLastName
                      : null,
                ),
                const SizedBox(height: 16),

                // Phone Number field
                const FieldLabel(
                  label: AppStrings.phoneLabel,
                  bottomPadding: 6,
                ),
                CustomTextField(
                  controller: authViewModel.profilePhoneController,
                  hintText: AppStrings.hintPhone,
                  keyboardType: TextInputType.phone,
                  fillColor: AppColors.white,
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  focusedBorder: focusedBorderStyle,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.valPhone;
                    }
                    final cleaned = value.trim().replaceAll(
                      RegExp(r'[\s\-\(\)\.]'),
                      '',
                    );
                    if (cleaned.length < 8 ||
                        !RegExp(r'^\+?[0-9]{8,15}$').hasMatch(cleaned)) {
                      return AppStrings.valPhoneInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email field
                const FieldLabel(
                  label: AppStrings.emailLabelText,
                  bottomPadding: 6,
                ),
                CustomTextField(
                  controller: authViewModel.profileEmailController,
                  hintText: AppStrings.hintEmail,
                  keyboardType: TextInputType.emailAddress,
                  fillColor: AppColors.white,
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  focusedBorder: focusedBorderStyle,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.valEmailRequired;
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value.trim())) {
                      return AppStrings.valEmailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gender field
                const FieldLabel(
                  label: AppStrings.genderLabel,
                  bottomPadding: 6,
                ),
                GenderDropdownField(
                  controller: authViewModel.profileGenderController,
                  fillColor: AppColors.white,
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  focusedBorder: focusedBorderStyle,
                  borderRadius: BorderRadius.circular(10),
                  onChanged: (newValue) {},
                ),
                const SizedBox(height: 16),

                // Date of Birth field
                const FieldLabel(label: AppStrings.dobLabel, bottomPadding: 6),
                CustomTextField(
                  controller: authViewModel.profileDobController,
                  hintText: AppStrings.hintDob,
                  readOnly: true,
                  fillColor: AppColors.white,
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  focusedBorder: focusedBorderStyle,
                  suffixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      AppIcons.assetCalendar,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textLabel,
                        BlendMode.srcIn,
                      ),
                      height: 20,
                      width: 20,
                    ),
                  ),
                  onTap: () => _selectDate(context),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? AppStrings.valDob
                      : null,
                ),
                const SizedBox(height: 16),

                // Location field
                const FieldLabel(
                  label: AppStrings.locationLabel,
                  bottomPadding: 6,
                ),
                CustomTextField(
                  controller: authViewModel.profileLocationController,
                  hintText: AppStrings.hintLocation,
                  fillColor: AppColors.white,
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  focusedBorder: focusedBorderStyle,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? AppStrings.valLocation
                      : null,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppTheme.borderGray, width: 1.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SafeArea(
          child: CustomButton(
            text: AppStrings.saveChanges,
            onPressed: () => _handleSaveChanges(context),
            isLoading: authViewModel.isLoading,
            backgroundColor: AppTheme.successGreen,
            height: 50,
            borderRadius: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
