import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_strings.dart';

/// Reusable full-width action button with loading spinner support.
///
/// Supports solid, outlined, and gradient styles via [isOutlined] and
/// [gradient]. When [gradient] is provided, the button renders inside a
/// gradient-decorated container with a transparent elevated button on top.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final String? svgAsset;
  final double height;
  final double borderRadius;
  final bool isOutlined;
  final Color? borderColor;
  final double fontSize;
  final FontWeight fontWeight;

  /// Optional gradient background. When set, [backgroundColor] is ignored.
  final Gradient? gradient;

  /// Optional explicit width. Defaults to full-width (`double.infinity`).
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppColors.primaryBlue,
    this.textColor = AppColors.white,
    this.icon,
    this.svgAsset,
    this.height = AppConstants.buttonHeight,
    this.borderRadius = AppConstants.borderRadiusMedium,
    this.isOutlined = false,
    this.borderColor,
    this.fontSize = AppConstants.fontSizeXL,
    this.fontWeight = FontWeight.w600,
    this.gradient,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? double.infinity;

    if (isOutlined) {
      final effectiveBorderColor = borderColor ?? backgroundColor;
      return SizedBox(
        width: effectiveWidth,
        height: height,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: effectiveBorderColor,
              width: AppConstants.borderWidthMedium,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(effectiveBorderColor),
        ),
      );
    }

    // Gradient variant: wrap a transparent ElevatedButton in a gradient box.
    if (gradient != null) {
      return Container(
        width: effectiveWidth,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: gradient,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: _buildChild(textColor),
        ),
      );
    }

    return SizedBox(
      width: effectiveWidth,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: AppConstants.elevationNone,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(textColor),
      ),
    );
  }

  Widget _buildChild(Color effectiveTextColor) {
    if (isLoading) {
      return SizedBox(
        width: AppConstants.iconSize,
        height: AppConstants.iconSize,
        child: CircularProgressIndicator(
          color: effectiveTextColor,
          strokeWidth: AppConstants.borderWidthThick,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (svgAsset != null) ...[
          SvgPicture.asset(
            svgAsset!,
            colorFilter: ColorFilter.mode(effectiveTextColor, BlendMode.srcIn),
            width: AppConstants.iconSize,
            height: AppConstants.iconSize,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
        ] else if (icon != null) ...[
          Icon(icon, color: effectiveTextColor, size: AppConstants.iconSize),
          const SizedBox(width: AppConstants.paddingSmall),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: effectiveTextColor,
              fontWeight: fontWeight,
              fontSize: fontSize,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ),
      ],
    );
  }
}
