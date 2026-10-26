import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSendResetLink(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = authViewModel.forgotPasswordEmailController.text.trim();
    final success = await authViewModel.sendResetLink(email);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authViewModel.successMessage ?? 'OTP code sent successfully!',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pushNamed(context, AppRoutes.resetPassword, arguments: email);
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
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final bool isSmall = screenWidth < 360.0;
    final bool isShortScreen = screenHeight < 700.0;

    final double horizontalPadding = isSmall ? 16.0 : 24.0;
    final double iconContainerSize = isShortScreen
        ? 80.0
        : (isSmall ? 84.0 : 96.0);
    final double svgIconSize = (iconContainerSize * 0.48).clamp(38.0, 48.0);

    final double topSpacing = isShortScreen ? 20.0 : (isSmall ? 28.0 : 43.0);
    final double subtitleSpacing = isShortScreen
        ? 18.0
        : (isSmall ? 22.0 : 30.0);
    final double inputSpacing = isShortScreen ? 24.0 : (isSmall ? 30.0 : 40.0);
    final double buttonHeight = isSmall ? 44.0 : 48.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Navigation Row
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isShortScreen ? 6.0 : 10.0,
                horizontalPadding,
                0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        customBorder: const CircleBorder(),
                        child: Align(
                          alignment: Alignment.center,
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
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          AppStrings.forgotPassword,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: topSpacing),

                          // Circle container with responsive key SVG
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  width: iconContainerSize,
                                  height: iconContainerSize,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.lightBlue,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      AppIcons.assetForgotKey,
                                      width: svgIconSize,
                                      height: svgIconSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: subtitleSpacing),

                          // Subtitle Instruction text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    AppStrings.forgotPasswordInstructions,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isSmall ? 13 : 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.gray500,
                                      height: 1.5,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: inputSpacing),

                          // Input field for Email
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: authViewModel
                                      .forgotPasswordEmailController,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.padding6,
                                  ),
                                  hintText: AppStrings.emailHint,
                                  keyboardType: TextInputType.emailAddress,
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Send Reset Link Button
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: AppStrings.sendResetLink,
                                  onPressed: () =>
                                      _handleSendResetLink(context),
                                  isLoading: authViewModel.isLoading,
                                  height: buttonHeight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Back to login button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    AppStrings.backToLogin,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryBlue,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
