import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_strings.dart';

class PostSuccessFadeDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onContinue;
  final VoidCallback? onViewListing;
  final String continueText;
  final String viewListingText;

  const PostSuccessFadeDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onContinue,
    this.onViewListing,
    this.continueText = 'Continue',
    this.viewListingText = 'View Listing',
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onContinue,
    VoidCallback? onViewListing,
    String continueText = 'Continue',
    String viewListingText = 'View Listing',
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'SuccessDialog',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return PostSuccessFadeDialog(
          title: title,
          message: message,
          onContinue: onContinue,
          onViewListing: onViewListing,
          continueText: continueText,
          viewListingText: viewListingText,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final fadeAnimation = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOut,
        );
        final scaleAnimation = Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack));
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius24),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Success Icon Circle
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.softGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.emerald,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeHeading,
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
                fontFamily: AppStrings.fontInter,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: AppConstants.fontSize,
                color: AppColors.slate500,
                fontFamily: AppStrings.fontInter,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Optional "View Listing" Primary Button
            if (onViewListing != null) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.vibrantBlue, AppColors.secondaryPurple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: onViewListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    viewListingText,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Secondary Outline Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onContinue,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.slate700,
                    side: const BorderSide(color: AppColors.slate300),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    continueText,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeMD,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Single Continue Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.vibrantBlue, AppColors.secondaryPurple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    continueText,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
