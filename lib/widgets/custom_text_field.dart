import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/theme.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_strings.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final String? prefixIconAsset;
  final Widget? prefixIcon;
  final Color? prefixIconColor;
  final Widget? suffix;
  final Widget? prefix;
  final Widget? suffixIcon;
  final Color? suffixIconColor;
  final bool obscureText;
  final Color? focusColor;
  final double? borderWidth;
  final FormFieldValidator<String>? validator;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? textColor;
  final bool readOnly;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final FocusNode? focusNode;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.prefixIconAsset,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffix,
    this.prefix,
    this.suffixIcon,
    this.suffixIconColor,
    this.obscureText = false,
    this.focusColor,
    this.borderWidth,
    this.validator,
    this.fontFamily,
    this.fontWeight,
    this.fontSize,
    this.textColor,
    this.readOnly = false,
    this.onTap,
    this.padding,
    this.focusNode,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.borderRadius,
    this.fillColor,
    this.maxLines = 1,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      style: TextStyle(
        fontSize: fontSize ?? AppConstants.fontSizeLG,
        fontFamily: fontFamily ?? AppStrings.fontInter,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: textColor ?? AppColors.textDark,
      ),
      decoration: InputDecoration(
        focusColor: focusColor,
        hintText: hintText,
        prefixIconColor: prefixIconColor,
        suffixIconColor: suffixIconColor,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        prefixIcon:
            prefixIcon ??
            (prefixIconAsset != null
                ? (prefixIconAsset!.toLowerCase().endsWith('.svg')
                      ? SvgPicture.asset(
                          prefixIconAsset!,
                          width: AppConstants.iconSize,
                          height: AppConstants.iconSize,
                          fit: BoxFit.scaleDown,
                          colorFilter: ColorFilter.mode(
                            prefixIconColor ?? AppColors.svgDefault,
                            BlendMode.srcIn,
                          ),
                        )
                      : Image.asset(
                          prefixIconAsset!,
                          width: AppConstants.iconSize,
                          height: AppConstants.iconSize,
                          fit: BoxFit.scaleDown,
                          color: prefixIconColor,
                        ))
                : null),

        suffix: suffix,
        prefix: prefix,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? AppTheme.inputFill,
        contentPadding:
            padding ??
            const EdgeInsets.symmetric(
              vertical: AppConstants.paddingStandard,
              horizontal: AppConstants.padding10,
            ),
        border:
            border ??
            OutlineInputBorder(
              borderRadius:
                  borderRadius ??
                  BorderRadius.circular(AppConstants.borderRadiusSmall),
              borderSide: const BorderSide(color: AppTheme.borderLight),
            ),
        enabledBorder:
            enabledBorder ??
            OutlineInputBorder(
              borderRadius:
                  borderRadius ??
                  BorderRadius.circular(AppConstants.borderRadiusSmall),
              borderSide: BorderSide(
                color: AppTheme.borderLight,
                width: borderWidth ?? AppConstants.borderWidth,
              ),
            ),
        focusedBorder: focusedBorder,
      ),
      validator: validator,
    );
  }
}
