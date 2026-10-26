import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/theme.dart';

class RegisterHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const RegisterHeader({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlue,
      child: Stack(
        children: [
          // Decorative circle (top right)
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          // Decorative circle (bottom left)
          Positioned(
            bottom: 40,
            left: -40,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          // Header content (Avatar image, Create Account, Subtitle)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 55),
                Image.asset(
                  AppIcons.assetRegisterHeader,
                  height: 57,
                  width: 70,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLargeDisplay - 2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall - 2),
                Text(
                  'Join DesiConnect Today',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSM,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                const SizedBox(height: AppConstants.padding28),
              ],
            ),
          ),
          // Back button
          Positioned(
            top: 50,
            left: AppConstants.marginHorizontal,
            child: InkWell(
              onTap: onBackPressed,
              child: CircleAvatar(
                backgroundColor: AppColors.white.withValues(alpha: 0.15),
                child: SvgPicture.asset(
                  AppIcons.assetBackArrow,
                  height: AppConstants.iconSizeMD,
                  width: AppConstants.iconSizeMD,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
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
}
