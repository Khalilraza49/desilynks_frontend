import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/theme.dart';
import '../core/constants/app_constants.dart';

class SocialLoginButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.borderLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, AppConstants.buttonHeight),
      ),
      onPressed: onPressed,
      child: isSvg
          ? SvgPicture.asset(
              iconPath,
              width: AppConstants.iconSizeLG,
              height: AppConstants.iconSizeLG,
            )
          : Image.asset(
              iconPath,
              width: AppConstants.iconSizeLG,
              height: AppConstants.iconSizeLG,
            ),
    );
  }
}
