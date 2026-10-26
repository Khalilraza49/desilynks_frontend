import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  final double bottomPadding;

  const FieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.bottomPadding = AppConstants.padding10,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeMD,
            fontWeight: FontWeight.w600,
            color: AppColors.gray500,
            fontFamily: AppStrings.fontInter,
          ),
          children: isRequired
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.primaryRed),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
