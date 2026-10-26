import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';

class VerifyView extends StatelessWidget {
  final String phoneNumber;
  final Map<String, dynamic>? registrationData;
  const VerifyView({
    super.key,
    required this.phoneNumber,
    this.registrationData,
  });

  Future<void> _handleVerify(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final code = authViewModel.verifyOtpControllers
        .map((c) => c.text.trim())
        .join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.valEnterCompleteCode)),
      );
      return;
    }

    final email = registrationData?['email'] as String?;
    final password = registrationData?['password'] as String?;
    final success = await authViewModel.verifyOtp(
      code,
      email: email,
      password: password,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.verificationSuccessful)),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.createProfile,
        (route) => false,
        arguments: registrationData,
      );
    } else if (context.mounted && authViewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authViewModel.errorMessage!)));
    }
  }

  Future<void> _handleResendOtp(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final email = registrationData?['email'] as String?;
    final success = await authViewModel.resendOtp(
      email: email,
      purpose: 'register',
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authViewModel.successMessage ?? AppStrings.verificationCodeResent,
          ),
        ),
      );
    } else if (context.mounted && authViewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authViewModel.errorMessage!)));
    }
  }

  Widget _buildOtpBox(
    BuildContext context,
    int index, {
    required double width,
    required double height,
    required double fontSize,
    required AuthViewModel authViewModel,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: authViewModel.verifyOtpControllers[index],
        focusNode: authViewModel.verifyOtpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
          fontFamily: AppStrings.fontInter,
        ),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.slate200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.slate200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              authViewModel.verifyOtpFocusNodes[index + 1].requestFocus();
            } else {
              authViewModel.verifyOtpFocusNodes[index].unfocus();
            }
          } else {
            if (index > 0) {
              authViewModel.verifyOtpFocusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    authViewModel.initVerifyScreen();

    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final bool isSmall = screenWidth < 360.0;
    final bool isLarge = screenWidth >= 420.0;
    final bool isShortScreen = screenHeight < 700.0;

    final double horizontalPadding = isSmall ? 16.0 : 24.0;
    final double availableWidth = screenWidth - (horizontalPadding * 2);
    final double otpGap = (availableWidth * 0.03).clamp(6.0, 12.0);
    final double otpBoxWidth = ((availableWidth - (5 * otpGap)) / 6).clamp(
      38.0,
      52.0,
    );
    final double otpBoxHeight = (otpBoxWidth * 1.18).clamp(46.0, 60.0);
    final double otpFontSize = (otpBoxWidth * 0.45).clamp(17.0, 22.0);

    final double shieldSize = isSmall ? 68.0 : (isLarge ? 88.0 : 80.0);
    final double shieldIconSize = shieldSize * 0.5;
    final double buttonHeight = isSmall ? 52.0 : 58.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 12.0,
          ),
          child: SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: authViewModel.isLoading
                  ? null
                  : () => _handleVerify(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: authViewModel.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      AppStrings.verify,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isShortScreen ? 6 : 10),
              // App Bar back arrow and title
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SvgPicture.asset(
                        AppIcons.assetBackArrow,
                        width: 25,
                        height: 25,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate800,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      AppStrings.verifyYourAccount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isShortScreen ? 16 : 24),

              // Shield Icon inside circular background
              Container(
                width: shieldSize,
                height: shieldSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightBlue,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.shield,
                    width: shieldIconSize,
                    height: shieldIconSize,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryBlue,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: isShortScreen ? 14 : 20),

              // Text descriptions
              const Text(
                AppStrings.verifyInstructions,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.slate500,
                  height: 1.5,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                (registrationData?['email'] as String?)?.isNotEmpty == true
                    ? (registrationData!['email'] as String)
                    : phoneNumber,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: isShortScreen ? 20 : 28),

              // 6-digit OTP fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => _buildOtpBox(
                    context,
                    index,
                    width: otpBoxWidth,
                    height: otpBoxHeight,
                    fontSize: otpFontSize,
                    authViewModel: authViewModel,
                  ),
                ),
              ),
              SizedBox(height: isShortScreen ? 18 : 24),

              // Resend code timer or button
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    AppStrings.didNotReceiveCode,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.slate500,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(width: 4),
                  authViewModel.verifyResendCountdown > 0
                      ? Text(
                          "${AppStrings.resendIn}00:${authViewModel.verifyResendCountdown.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppStrings.fontInter,
                          ),
                        )
                      : GestureDetector(
                          onTap: authViewModel.isLoading
                              ? null
                              : () => _handleResendOtp(context),
                          child: const Text(
                            AppStrings.resendCode,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppStrings.fontInter,
                              decoration: TextDecoration.underline,
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
    );
  }
}
