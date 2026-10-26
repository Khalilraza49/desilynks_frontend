import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_checkbox.dart';
import '../../widgets/field_label.dart';
import '../../widgets/register_section_header.dart';
import '../../widgets/register_header.dart';
import '../../widgets/gender_dropdown_field.dart';
import '../../widgets/custom_date_picker_field.dart';
import '../../widgets/custom_button.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleRegister(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!authViewModel.registerAcceptedTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.valAgreeToTerms)));
      return;
    }

    final success = await authViewModel.register(
      firstName: authViewModel.registerFirstNameController.text.trim(),
      lastName: authViewModel.registerLastNameController.text.trim(),
      gender: authViewModel.registerGenderController.text,
      dob: authViewModel.registerDobController.text,
      email: authViewModel.registerEmailController.text.trim(),
      phone: authViewModel.registerPhoneController.text.trim(),
      address: authViewModel.registerAddressController.text.trim(),
      postalCode: authViewModel.registerPostalController.text.trim(),
      city: authViewModel.registerCityController.text.trim(),
      province: authViewModel.registerProvinceController.text.trim(),
      country: authViewModel.registerCountryController.text.trim(),
      password: authViewModel.registerPasswordController.text,
    );

    if (success && context.mounted) {
      final registrationData = {
        'firstName': authViewModel.registerFirstNameController.text.trim(),
        'lastName': authViewModel.registerLastNameController.text.trim(),
        'gender': authViewModel.registerGenderController.text,
        'dob': authViewModel.registerDobController.text,
        'email': authViewModel.registerEmailController.text.trim(),
        'phone': authViewModel.registerPhoneController.text.trim(),
        'address': authViewModel.registerAddressController.text.trim(),
        'postalCode': authViewModel.registerPostalController.text.trim(),
        'city': authViewModel.registerCityController.text.trim(),
        'province': authViewModel.registerProvinceController.text.trim(),
        'country': authViewModel.registerCountryController.text.trim(),
        'password': authViewModel.registerPasswordController.text,
      };

      Navigator.pushNamed(
        context,
        AppRoutes.verify,
        arguments: {
          'phone': authViewModel.registerPhoneController.text.trim().isEmpty
              ? '+34 612 345 678'
              : authViewModel.registerPhoneController.text.trim(),
          'registrationData': registrationData,
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // 1. Blue Top Header Area
            RegisterHeader(
              onBackPressed: () =>
                  Navigator.popAndPushNamed(context, AppRoutes.login),
            ),

            // 2. Register Form Card
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 200), // Push down to overlap header

                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: context.hMargin,
                    ),
                    padding: EdgeInsets.all(
                      context.isSmall
                          ? AppConstants.paddingLarge
                          : AppConstants.paddingExtraLarge,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusLarge,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION 1: PERSONAL INFO
                          const RegisterSectionHeader(
                            thick: FontWeight.w600,
                            family: AppStrings.fontRoboto,
                            fontSize: 12,
                            svg: AppIcons.personSvg,
                            title: AppStrings.personalInfo,
                            iconColor: AppColors.blue500,
                            backgroundColor: AppColors.lightBlue,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FieldLabel(
                                      label: AppStrings.firstNameLabel,
                                      isRequired: true,
                                    ),
                                    CustomTextField(
                                      padding: const EdgeInsets.only(
                                        left: AppConstants.padding10,
                                        right: AppConstants.paddingSmall,
                                      ),
                                      controller: authViewModel
                                          .registerFirstNameController,
                                      hintText: 'Ali',
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? AppStrings.valRequired
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FieldLabel(
                                      label: AppStrings.lastNameLabel,
                                      isRequired: true,
                                    ),
                                    CustomTextField(
                                      controller: authViewModel
                                          .registerLastNameController,
                                      hintText: 'Khan',
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? AppStrings.valRequired
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FieldLabel(
                                      label: AppStrings.genderLabel,
                                    ),
                                    GenderDropdownField(
                                      controller: authViewModel
                                          .registerGenderController,
                                      onChanged: (newValue) {},
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FieldLabel(
                                      label: AppStrings.dobLabel,
                                    ),
                                    CustomDatePickerField(
                                      controller:
                                          authViewModel.registerDobController,
                                      hintText: AppStrings.hintDob,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppConstants.marginHorizontal,
                            ),
                            child: Divider(
                              color: AppColors.blackOpacity22, // #00000038
                              thickness: 1.0,
                            ),
                          ),

                          // SECTION 2: CONTACT
                          const RegisterSectionHeader(
                            thick: FontWeight.w600,
                            family: AppStrings.fontRoboto,
                            fontSize: 12,
                            svg: AppIcons.callSvg,
                            title: AppStrings.contact,
                            iconColor: AppColors.emerald,
                            backgroundColor: AppColors.softGreen,
                          ),
                          const SizedBox(height: 16),

                          const FieldLabel(
                            label: AppStrings.emailAddressLabel,
                            isRequired: true,
                          ),
                          CustomTextField(
                            controller: authViewModel.registerEmailController,
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'ali@example.com',
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(
                                AppConstants.borderRadius10,
                              ),
                              child: SvgPicture.asset(
                                AppIcons.email,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.gray500,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
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

                          const FieldLabel(
                            label: AppStrings.phoneLabel,
                            isRequired: true,
                          ),
                          CustomTextField(
                            controller: authViewModel.registerPhoneController,
                            keyboardType: TextInputType.phone,
                            hintText: '+34 612 515 678',
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(
                                AppConstants.borderRadius10,
                              ),
                              child: SvgPicture.asset(
                                AppIcons.callSvg,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.gray500,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppStrings.valPhone;
                              }
                              final cleaned = value.trim().replaceAll(
                                RegExp(r'[\s\-\(\)\.]'),
                                '',
                              );
                              if (cleaned.length < 8 ||
                                  !RegExp(
                                    r'^\+?[0-9]{8,15}$',
                                  ).hasMatch(cleaned)) {
                                return AppStrings.valPhoneInvalid;
                              }
                              return null;
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Divider(
                              color: AppColors.blackOpacity22, // #00000038
                              thickness: 1.0,
                            ),
                          ),

                          // SECTION 3: ADDRESS
                          const RegisterSectionHeader(
                            thick: FontWeight.w600,
                            family: AppStrings.fontRoboto,
                            fontSize: 12,
                            svg: AppIcons.locationSvg,
                            title: AppStrings.address,
                            iconColor: AppColors.amberOrange,
                            backgroundColor: AppColors.amber100,
                          ),
                          const SizedBox(height: 16),

                          const FieldLabel(
                            label: AppStrings.streetAddressLabel,
                          ),
                          CustomTextField(
                            controller: authViewModel.registerAddressController,
                            hintText: AppStrings.hintStreetAddress,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FieldLabel(
                                      label: AppStrings.postalCodeLabel,
                                    ),
                                    CustomTextField(
                                      controller: authViewModel
                                          .registerPostalController,
                                      keyboardType: TextInputType.number,
                                      hintText: AppStrings.hintPostalCode,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FieldLabel(
                                      label: AppStrings.cityLabel,
                                      isRequired: true,
                                    ),
                                    CustomTextField(
                                      controller:
                                          authViewModel.registerCityController,
                                      hintText: AppStrings.hintCity,
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? AppStrings.valRequired
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FieldLabel(
                                      label: AppStrings.provinceLabel,
                                      isRequired: true,
                                    ),
                                    CustomTextField(
                                      controller: authViewModel
                                          .registerProvinceController,
                                      hintText: AppStrings.hintCity,
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? AppStrings.valRequired
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FieldLabel(
                                      label: AppStrings.countryLabel,
                                      isRequired: true,
                                    ),
                                    CustomTextField(
                                      controller: authViewModel
                                          .registerCountryController,
                                      hintText: AppStrings.hintCountry,
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? AppStrings.valRequired
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Divider(
                              color: AppColors.blackOpacity22, // #00000038
                              thickness: 1.0,
                            ),
                          ),

                          // SECTION 4: SECURITY
                          const RegisterSectionHeader(
                            thick: FontWeight.w600,
                            family: AppStrings.fontRoboto,
                            fontSize: 12,
                            svg: AppIcons.blockShieldSvg,
                            title: AppStrings.security,
                            iconColor: AppColors.indigo700,
                            backgroundColor: AppColors.indigoLight,
                          ),
                          const SizedBox(height: 16),

                          const FieldLabel(
                            label: AppStrings.passwordLabel,
                            isRequired: true,
                          ),
                          CustomTextField(
                            controller:
                                authViewModel.registerPasswordController,
                            obscureText: authViewModel.registerObscurePassword,
                            hintText: AppStrings.hintPasswordMin,
                            prefixIconAsset: AppIcons.assetLock,
                            suffixIcon: IconButton(
                              icon: SvgPicture.asset(
                                authViewModel.registerObscurePassword
                                    ? AppIcons.eyeSvg
                                    : AppIcons.eyeSvg,
                                width: 20,
                                height: 20,
                                fit: BoxFit.scaleDown,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.svgDefault,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () {
                                authViewModel.toggleRegisterObscurePassword();
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.valPasswordRequired;
                              }
                              if (value.length < 8) {
                                return AppStrings.valPasswordMinLength;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          const FieldLabel(
                            label: AppStrings.confirmPasswordLabel,
                            isRequired: true,
                          ),
                          CustomTextField(
                            controller:
                                authViewModel.registerConfirmPasswordController,
                            obscureText:
                                authViewModel.registerObscureConfirmPassword,
                            hintText: AppStrings.hintRepeatPassword,
                            prefixIconAsset: AppIcons.assetLock,
                            suffixIcon: IconButton(
                              icon: SvgPicture.asset(
                                authViewModel.registerObscureConfirmPassword
                                    ? AppIcons.eyeSvg
                                    : AppIcons.eyeSvg,
                                width: 20,
                                height: 20,
                                fit: BoxFit.scaleDown,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.svgDefault,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () {
                                authViewModel
                                    .toggleRegisterObscureConfirmPassword();
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.valConfirmPasswordRequired;
                              }
                              if (value !=
                                  authViewModel
                                      .registerPasswordController
                                      .text) {
                                return AppStrings.valPasswordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Terms and Conditions checkbox row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomCheckbox(
                                value: authViewModel.registerAcceptedTerms,
                                onChanged: (value) {
                                  authViewModel.toggleRegisterAcceptedTerms();
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    RichText(
                                      text: const TextSpan(
                                        text: 'I agree to the ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textGray,
                                          fontFamily: AppStrings.fontInter,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Terms & Conditions',
                                            style: TextStyle(
                                              color: AppTheme.primaryBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              color: AppTheme.primaryBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Register button
                          CustomButton(
                            text: AppStrings.createAccount,
                            onPressed: () => _handleRegister(context),
                            isLoading: authViewModel.isLoading,
                            height: 50,
                            fontWeight: FontWeight.bold,
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.gradientStart,
                                AppTheme.gradientEnd,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Already have an account footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                AppStrings.alreadyHaveAccount,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textGray,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                },
                                child: const Text(
                                  AppStrings.login,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
