import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_strings.dart';

/// Reusable multi-step form progress bar widget.
class FormProgressBar extends StatelessWidget {
  final double progress;
  final String stepText;
  final Color activeColor;
  final Color trackColor;
  final double height;
  final EdgeInsetsGeometry padding;
  final bool showPercentage;
  final String fontFamily;

  const FormProgressBar({
    super.key,
    required this.progress,
    required this.stepText,
    this.activeColor = AppColors.primaryBlue,
    this.trackColor = AppColors.slate200,
    this.height = AppConstants.paddingSmall - 2,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppConstants.marginHorizontal,
      vertical: AppConstants.paddingStandard,
    ),
    this.showPercentage = true,
    this.fontFamily = AppStrings.fontInter,
  });

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.clamp(0.0, 1.0);
    final int percentage = (clampedProgress * 100).round();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stepText,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSM,
                  color: AppColors.slate500,
                  fontWeight: FontWeight.w500,
                  fontFamily: fontFamily,
                ),
              ),
              if (showPercentage)
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSM,
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusExtraSmall,
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: height,
                  color: trackColor,
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: clampedProgress == 0.0 ? 0.01 : clampedProgress,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusExtraSmall,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
