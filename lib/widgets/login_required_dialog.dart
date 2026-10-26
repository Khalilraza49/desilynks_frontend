import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/routes.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';

class LoginRequiredDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;
  final VoidCallback? onCancel;

  const LoginRequiredDialog({
    super.key,
    this.title = 'Login Required',
    this.message = 'Please register to use posting ads.',
    this.onLogin,
    this.onRegister,
    this.onCancel,
  });

  /// Displays the login required dialog with a subtle fade and scale animation.
  static Future<void> show(
    BuildContext context, {
    String title = 'Login Required',
    String message = 'Please register to use posting ads.',
    VoidCallback? onLogin,
    VoidCallback? onRegister,
    VoidCallback? onCancel,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'LoginRequiredDialog',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return LoginRequiredDialog(
          title: title,
          message: message,
          onLogin: onLogin,
          onRegister: onRegister,
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock icon in yellow circular badge
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.lockSvg,
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFF59E0B),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.slate500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Register Now Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onRegister != null) {
                    onRegister!();
                  } else {
                    Navigator.pushNamed(context, AppRoutes.register);
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
                child: const Text(
                  'Register Now',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onLogin != null) {
                    onLogin!();
                  } else {
                    Navigator.pushNamed(context, AppRoutes.login);
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
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (onCancel != null) {
                  onCancel!();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
