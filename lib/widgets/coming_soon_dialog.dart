import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../core/extensions/context_extensions.dart';

class ComingSoonDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? featureName;
  final String svgIcon;
  final Color badgeColor;
  final Color iconColor;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final VoidCallback? onCancel;

  const ComingSoonDialog({
    super.key,
    this.title = 'Coming Soon',
    this.message =
        'We are working hard to bring this feature to you. Stay tuned for upcoming updates!',
    this.featureName,
    this.svgIcon = AppIcons.partyPopperSvg,
    this.badgeColor = const Color(0xFFFEF3C7),
    this.iconColor = const Color(0xFFF59E0B),
    this.primaryButtonText = 'Got It',
    this.secondaryButtonText = 'Go Back',
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.onCancel,
  });

  /// Displays the Coming Soon dialog matching the exact design language of LoginRequiredDialog
  static Future<void> show(
    BuildContext context, {
    String title = 'Coming Soon',
    String? message,
    String? featureName,
    String? svgIcon,
    Color? badgeColor,
    Color? iconColor,
    String primaryButtonText = 'Got It',
    String secondaryButtonText = 'Go Back',
    VoidCallback? onPrimaryAction,
    VoidCallback? onSecondaryAction,
    VoidCallback? onCancel,
  }) {
    // Customize icon and badge colors based on featureName if not explicitly provided
    String resolvedIcon = svgIcon ?? AppIcons.partyPopperSvg;
    Color resolvedBadgeColor = badgeColor ?? const Color(0xFFFEF3C7);
    Color resolvedIconColor = iconColor ?? const Color(0xFFF59E0B);

    if (featureName != null) {
      final lower = featureName.toLowerCase();
      if (lower.contains('refer')) {
        resolvedIcon = svgIcon ?? AppIcons.giftSvg;
        resolvedBadgeColor = badgeColor ?? const Color(0xFFDCFCE7);
        resolvedIconColor = iconColor ?? const Color(0xFF10B981);
      } else if (lower.contains('loyalty')) {
        resolvedIcon = svgIcon ?? AppIcons.starFavoriteSvg;
        resolvedBadgeColor = badgeColor ?? const Color(0xFFFEF3C7);
        resolvedIconColor = iconColor ?? const Color(0xFFF59E0B);
      } else if (lower.contains('offer')) {
        resolvedIcon = svgIcon ?? AppIcons.sales1Svg;
        resolvedBadgeColor = badgeColor ?? const Color(0xFFEFF6FF);
        resolvedIconColor = iconColor ?? AppColors.primaryBlue;
      } else if (lower.contains('deal') || lower.contains('discount')) {
        resolvedIcon = svgIcon ?? AppIcons.TagSvg;
        resolvedBadgeColor = badgeColor ?? const Color(0xFFFEF3C7);
        resolvedIconColor = iconColor ?? const Color(0xFFD97706);
      }
    }

    final resolvedMessage = message ??
        (featureName != null
            ? '$featureName is currently under development and will be available very soon. Stay tuned!'
            : 'We are working hard to bring this feature to you. Stay tuned for upcoming updates!');

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ComingSoonDialog',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return ComingSoonDialog(
          title: title,
          message: resolvedMessage,
          featureName: featureName,
          svgIcon: resolvedIcon,
          badgeColor: resolvedBadgeColor,
          iconColor: resolvedIconColor,
          primaryButtonText: primaryButtonText,
          secondaryButtonText: secondaryButtonText,
          onPrimaryAction: onPrimaryAction,
          onSecondaryAction: onSecondaryAction,
          onCancel: onCancel,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmall;
    final isTablet = context.isTablet;

    final double iconBoxSize =
        (isSmall ? 58.0 : context.scale(68.0)).clamp(54.0, 72.0);
    final double iconSize =
        (isSmall ? 28.0 : context.scale(32.0)).clamp(26.0, 36.0);
    final double buttonHeight =
        (isSmall ? 44.0 : context.scaleH(48.0)).clamp(44.0, 50.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 80.0 : (isSmall ? 16.0 : 24.0),
        vertical: isSmall ? 16.0 : 24.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 420.0 : 400.0,
            maxHeight: context.screenHeight * 0.9,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal:
                  isSmall ? 18.0 : context.scale(24.0).clamp(20.0, 28.0),
              vertical:
                  isSmall ? 20.0 : context.scale(28.0).clamp(22.0, 32.0),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Circular badge with SVG icon matching LoginRequiredDialog
                  Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        svgIcon,
                        width: iconSize,
                        height: iconSize,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: isSmall
                        ? 12.0
                        : context.scaleH(18.0).clamp(14.0, 20.0),
                  ),

                  // 2. Title matching LoginRequiredDialog
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.sp(isSmall ? 18.0 : 20.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // 3. Feature badge pill (if featureName is provided)
                  if (featureName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        featureName!,
                        style: TextStyle(
                          fontSize: context.sp(isSmall ? 11.0 : 12.0),
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 4. Subtitle / message
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: context.sp(isSmall ? 13.0 : 14.0),
                      color: AppColors.slate500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: isSmall
                        ? 18.0
                        : context.scaleH(24.0).clamp(18.0, 26.0),
                  ),

                  // 5. Primary action button ("Got It") matching LoginRequiredDialog
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (onPrimaryAction != null) {
                          onPrimaryAction!();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        primaryButtonText,
                        style: TextStyle(
                          fontSize: context.sp(isSmall ? 14.0 : 15.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmall ? 8.0 : 10.0),

                  // 6. Secondary action button ("Go Back") matching LoginRequiredDialog
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        if (onSecondaryAction != null) {
                          onSecondaryAction!();
                        } else if (Navigator.canPop(context)) {
                          Navigator.pop(context); // pop screen
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: AppColors.slate800,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        secondaryButtonText,
                        style: TextStyle(
                          fontSize: context.sp(isSmall ? 14.0 : 15.0),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmall ? 10.0 : 12.0),

                  // 7. Cancel text button matching LoginRequiredDialog
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      if (onCancel != null) {
                        onCancel!();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 16,
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: context.sp(isSmall ? 13.0 : 14.0),
                          color: AppColors.slate400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

