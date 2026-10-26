import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

class RegisterSectionHeader extends StatelessWidget {
  final String svg;
  final String title;
  final Color iconColor;
  final Color backgroundColor;
  final double? fontSize;
  final FontWeight? thick;
  final String? family;

  const RegisterSectionHeader({
    super.key,
    required this.svg,
    required this.title,
    required this.iconColor,
    required this.backgroundColor,
    this.fontSize,
    this.thick,
    this.family,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingSmall - 2),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
          ),
          child: SvgPicture.asset(
            svg,
            height: AppConstants.iconSizeSM,
            width: AppConstants.iconSizeSM,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: AppConstants.paddingSmall),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? AppConstants.fontSizeSM,
            fontWeight: thick ?? FontWeight.w600,
            color: AppColors.slate800,
            letterSpacing: 0.5,
            fontFamily: family ?? AppStrings.fontInter,
          ),
        ),
      ],
    );
  }
}
