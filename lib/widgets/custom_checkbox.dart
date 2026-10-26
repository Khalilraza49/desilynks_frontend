import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../app/theme.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color? activeColor;
  final Color? checkColor;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.checkColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.iconSizeLG,
      width: AppConstants.iconSizeLG,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor ?? AppTheme.primaryBlue,
        checkColor: checkColor ?? AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadiusExtraSmall,
          ),
        ),
        side: BorderSide(
          color: value
              ? (activeColor ?? AppTheme.primaryBlue)
              : AppColors.slate300,
          width: AppConstants.borderWidthMedium,
        ),
      ),
    );
  }
}
