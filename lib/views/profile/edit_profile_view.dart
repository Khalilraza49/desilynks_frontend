import 'dart:io';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/edit_profile_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/widgets/custom_checkbox.dart';
import 'package:desilynks/widgets/field_label.dart';
import 'package:desilynks/widgets/gender_dropdown_field.dart';
import 'package:desilynks/widgets/custom_date_picker_field.dart';
import 'package:desilynks/widgets/custom_bottom_navigation.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  Future<void> _handleSaveChanges(
    BuildContext context,
    EditProfileViewModel vm,
    AuthViewModel authViewModel,
  ) async {
    final success = await vm.saveChanges(context, authViewModel);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authViewModel.errorMessage ?? 'Failed to update profile',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, EditProfileViewModel>(
      builder: (context, authViewModel, vm, _) {
        final user = authViewModel.currentUser;
        if (!vm.initialized && user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.initFromUser(user);
          });
        }

        final isSmall = context.isSmall;
        final double avatarSize = (context.scale(100.0)).clamp(80.0, 110.0);
        final double cameraIconSize = (context.scale(32.0)).clamp(24.0, 36.0);
        final double fieldSpacing = isSmall ? 12.0 : 16.0;
        final double sectionSpacing = isSmall ? 18.0 : 24.0;
        final File? pickedPhoto = vm.pickedPhoto;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Row with Back Button and Title
                    Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(
                            AppIcons.assetBackArrow,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate800,
                              BlendMode.srcIn,
                            ),
                            height: (context.scale(24.0)).clamp(20.0, 26.0),
                            width: (context.scale(24.0)).clamp(20.0, 26.0),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: context.scale(isSmall ? 4 : 8)),
                        Expanded(
                          child: Text(
                            'Edit Profile',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.slate800,
                              fontSize: context.sp(isSmall ? 18 : 20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.slate200,
                    ),
                    // Scrollable Form content
                    Expanded(
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.hMargin,
                            vertical: context.scaleH(isSmall ? 14 : 20),
                          ),
                          child: Form(
                            key: vm.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Profile Picture with Camera Icon
                                Center(
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () => vm.pickImage(context),
                                        child: Container(
                                          width: avatarSize,
                                          height: avatarSize,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            shape: BoxShape.circle,
                                            image: pickedPhoto != null
                                                ? DecorationImage(
                                                    image: FileImage(pickedPhoto),
                                                    fit: BoxFit.cover,
                                                  )
                                                : (user?.profilePhotoUrl != null &&
                                                          user!
                                                              .profilePhotoUrl!
                                                              .isNotEmpty
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                            user.profilePhotoUrl!,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null),
                                          ),
                                          child:
                                              pickedPhoto != null ||
                                                  (user?.profilePhotoUrl != null &&
                                                      user!
                                                          .profilePhotoUrl!
                                                          .isNotEmpty)
                                              ? null
                                              : Center(
                                                  child: SvgPicture.asset(
                                                    AppIcons.cameraSvg,
                                                    width: cameraIconSize,
                                                    height: cameraIconSize,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                          AppColors.textLightGray,
                                                          BlendMode.srcIn,
                                                        ),
                                                  ),
                                                ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: context.scaleH(isSmall ? 6 : 8),
                                      ),
                                      Text(
                                        'Tap to change photo',
                                        style: TextStyle(
                                          fontSize: context.sp(isSmall ? 11 : 12),
                                          color: AppColors.slate400,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: sectionSpacing),

                                // 2. PERSONAL INFORMATION Section
                                Text(
                                  'PERSONAL INFORMATION',
                                  style: TextStyle(
                                    fontSize: context.sp(isSmall ? 11 : 12),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: fieldSpacing),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const FieldLabel(
                                            label: 'First Name',
                                            isRequired: true,
                                          ),
                                          CustomTextField(
                                            borderRadius: BorderRadius.circular(
                                              AppConstants.borderRadiusSmall,
                                            ),
                                            controller: vm.firstNameController,
                                            hintText: 'First Name',
                                            validator: (val) =>
                                                val == null || val.trim().isEmpty
                                                ? 'Required'
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: context.scale(isSmall ? 10 : 16),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const FieldLabel(label: 'Last Name'),
                                          CustomTextField(
                                            borderRadius: BorderRadius.circular(
                                              AppConstants.borderRadiusSmall,
                                            ),
                                            controller: vm.lastNameController,
                                            hintText: 'Last Name',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: fieldSpacing),

                                const FieldLabel(label: 'Gender'),
                                GenderDropdownField(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusSmall,
                                  ),
                                  controller: vm.genderController,
                                  onChanged: (val) {
                                    if (val != null) {
                                      vm.genderController.text = val;
                                    }
                                  },
                                ),
                                SizedBox(height: fieldSpacing),

                                const FieldLabel(label: 'Date of birth'),
                                CustomDatePickerField(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusSmall,
                                  ),
                                  controller: vm.dobController,
                                  hintText: 'dd/mm/yy',
                                  initialDate: DateTime(2000, 1, 1),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      AppIcons.calendarSvg,
                                      width: isSmall ? 16 : 18,
                                      height: isSmall ? 16 : 18,
                                      fit: BoxFit.scaleDown,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.slate400,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: sectionSpacing),

                                // 3. CONTACT Section
                                Text(
                                  'CONTACT',
                                  style: TextStyle(
                                    fontSize: context.sp(isSmall ? 11 : 12),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: fieldSpacing),

                                const FieldLabel(
                                  label: 'Phone Number',
                                  isRequired: true,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        controller: vm.phoneController,
                                        hintText: 'Phone Number',
                                        keyboardType: TextInputType.phone,
                                        validator: (val) =>
                                            val == null || val.trim().isEmpty
                                            ? 'Required'
                                            : null,
                                      ),
                                    ),
                                    SizedBox(
                                      width: context.scale(isSmall ? 8 : 12),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: InkWell(
                                        onTap: () {
                                          vm.setShowOnPost(!vm.showOnPost);
                                        },
                                        borderRadius: BorderRadius.circular(4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomCheckbox(
                                              value: vm.showOnPost,
                                              onChanged: (val) {
                                                if (val != null) {
                                                  vm.setShowOnPost(val);
                                                }
                                              },
                                            ),
                                            SizedBox(width: isSmall ? 4 : 6),
                                            Text(
                                              'Show on post',
                                              style: TextStyle(
                                                fontSize: context.sp(
                                                  isSmall ? 11.5 : 13,
                                                ),
                                                color: AppColors.slate600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: fieldSpacing),

                                const FieldLabel(label: 'Email'),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppConstants.paddingStandard,
                                    vertical: context.scale(isSmall ? 12.0 : 14.0),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate100,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadiusSmall,
                                    ),
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          vm.emailController.text.isNotEmpty
                                              ? vm.emailController.text
                                              : (user?.email ?? ''),
                                          style: TextStyle(
                                            fontSize: context.sp(isSmall ? 13 : 14),
                                            color: AppColors.slate600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.lock_outline,
                                        size: isSmall ? 16 : 18,
                                        color: AppColors.slate400,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: context.scale(4)),
                                Text(
                                  'Email is read-only and cannot be changed.',
                                  style: TextStyle(
                                    fontSize: context.sp(isSmall ? 10.5 : 11.5),
                                    color: AppColors.slate400,
                                  ),
                                ),
                                SizedBox(height: sectionSpacing),

                                // 4. ADDRESS Section
                                Text(
                                  'ADDRESS',
                                  style: TextStyle(
                                    fontSize: context.sp(isSmall ? 11 : 12),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: fieldSpacing),

                                const FieldLabel(label: 'Address'),
                                CustomTextField(
                                  controller: vm.addressController,
                                  hintText: 'Street address (optional)',
                                ),
                                SizedBox(height: fieldSpacing),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const FieldLabel(label: 'Postal Code'),
                                          CustomTextField(
                                            controller:
                                                vm.postalCodeController,
                                            hintText: 'Postal Code',
                                            keyboardType: TextInputType.number,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: context.scale(isSmall ? 10 : 16),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const FieldLabel(
                                            label: 'City',
                                            isRequired: true,
                                          ),
                                          CustomTextField(
                                            controller: vm.cityController,
                                            hintText: 'City',
                                            validator: (val) =>
                                                val == null || val.trim().isEmpty
                                                ? 'Required'
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: fieldSpacing),

                                const FieldLabel(
                                  label: 'Province',
                                  isRequired: true,
                                ),
                                CustomTextField(
                                  controller: vm.provinceController,
                                  hintText: 'Province',
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                SizedBox(height: fieldSpacing),

                                const FieldLabel(
                                  label: 'Country',
                                  isRequired: true,
                                ),
                                CustomTextField(
                                  controller: vm.countryController,
                                  hintText: 'Country',
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                SizedBox(
                                  height: context.scaleH(isSmall ? 22 : 32),
                                ),

                                // 5. Actions Buttons Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: AppColors.slate300,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: context.scaleH(
                                              isSmall ? 12 : 14,
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppConstants.borderRadius10,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: AppColors.slate600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.sp(
                                              isSmall ? 14 : 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: context.scale(isSmall ? 12 : 16),
                                    ),
                                    Expanded(
                                      child: CustomButton(
                                        text: 'Save Changes',
                                        onPressed: () => _handleSaveChanges(
                                          context,
                                          vm,
                                          authViewModel,
                                        ),
                                        isLoading:
                                            authViewModel.isLoading || vm.isSaving,
                                        backgroundColor:
                                            const Color(0xFF16A34A),
                                        height: context.scaleH(
                                          isSmall ? 44 : 48,
                                        ),
                                        borderRadius:
                                            AppConstants.borderRadius10,
                                        fontSize: context.sp(isSmall ? 14 : 15),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: context.scaleH(isSmall ? 18 : 24),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.pop(context, 3);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add option coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: AppColors.vibrantBlue,
            shape: const CircleBorder(),
            elevation: 6,
            child: SvgPicture.asset(
              AppIcons.plusSvg,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              height: isSmall ? 16 : 22,
              width: isSmall ? 16 : 22,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: 3,
            onTap: (index) {
              Navigator.pop(context, index);
            },
          ),
        );
      },
    );
  }
}
