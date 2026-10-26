import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  const ResetPasswordView({super.key, required this.email});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleResetPassword(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await authViewModel.resetPassword(
      email: widget.email,
      otp: authViewModel.resetOtpController.text.trim(),
      newPassword: authViewModel.resetPasswordController.text,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authViewModel.successMessage ?? 'Password reset successfully!',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } else if (context.mounted && authViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleResendOtp(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authViewModel.resendOtp(
      email: widget.email,
      purpose: 'reset-password',
    );
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authViewModel.successMessage ?? 'OTP resent successfully!',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else if (context.mounted && authViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Header navigation
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    customBorder: const CircleBorder(),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          AppIcons.assetBackArrow,
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate800,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppStrings.resetPassword,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ],
              ),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.lightBlue,
                        ),
                        child: SvgPicture.asset(
                          AppIcons.reset_password,
                          width: 48,
                          height: 48,
                          colorFilter: const ColorFilter.mode(
                            AppTheme.primaryBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "${AppStrings.resetPasswordInstructionsPrefix}${widget.email}${AppStrings.resetPasswordInstructionsSuffix}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray500,
                            height: 1.5,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // OTP field label
                    const Text(
                      AppStrings.verificationCodeLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textGray,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // OTP Input
                    CustomTextField(
                      controller: authViewModel.resetOtpController,
                      borderRadius: BorderRadius.circular(
                        AppConstants.padding6,
                      ),
                      hintText: AppStrings.hintOtp,
                      keyboardType: TextInputType.number,
                      prefixIconAsset: AppIcons.assetVerify,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.valOtpRequired;
                        }
                        if (value.trim().length != 6) {
                          return AppStrings.valOtpInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: authViewModel.isLoading
                            ? null
                            : () => _handleResendOtp(context),
                        child: const Text(
                          AppStrings.resendCode,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password label
                    const Text(
                      AppStrings.newPasswordLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textGray,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Password Input
                    CustomTextField(
                      controller: authViewModel.resetPasswordController,
                      obscureText: authViewModel.resetObscurePassword,
                      borderRadius: BorderRadius.circular(
                        AppConstants.padding6,
                      ),
                      hintText: AppStrings.hintPasswordMin,
                      prefixIconAsset: AppIcons.assetLock,
                      suffixIcon: IconButton(
                        icon: SvgPicture.asset(
                          authViewModel.resetObscurePassword
                              ? AppIcons.assetEye
                              : AppIcons.assetEye,
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate400,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                        ),
                        onPressed: () {
                          authViewModel.toggleResetObscurePassword();
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.valNewPasswordRequired;
                        }
                        if (value.length < 8) {
                          return AppStrings.valPasswordMinLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password label
                    const Text(
                      AppStrings.confirmNewPasswordLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textGray,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Confirm Password Input
                    CustomTextField(
                      controller: authViewModel.resetConfirmPasswordController,
                      obscureText: authViewModel.resetObscureConfirmPassword,
                      borderRadius: BorderRadius.circular(
                        AppConstants.padding6,
                      ),
                      hintText: AppStrings.hintConfirmNewPassword,
                      prefixIconAsset: AppIcons.assetLock,
                      suffixIcon: IconButton(
                        icon: SvgPicture.asset(
                          authViewModel.resetObscureConfirmPassword
                              ? AppIcons.assetEye
                              : AppIcons.assetEye,
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate400,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                        ),
                        onPressed: () {
                          authViewModel.toggleResetObscureConfirmPassword();
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.valConfirmNewPasswordRequired;
                        }
                        if (value !=
                            authViewModel.resetPasswordController.text) {
                          return AppStrings.valPasswordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: authViewModel.isLoading
                            ? null
                            : () => _handleResetPassword(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authViewModel.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                AppStrings.resetPassword,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: AppStrings.fontInter,
                                ),
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
      ),
    );
  }
}
