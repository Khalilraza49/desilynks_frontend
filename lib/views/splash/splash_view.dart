import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  Future<void> _checkAuthStatus(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Introduce a minimum splash display duration of 2 seconds for smooth visual transition
    final startTime = DateTime.now();
    final isLoggedIn = await authViewModel.checkSession();
    final elapsedTime = DateTime.now().difference(startTime);

    const minSplashDuration = Duration(seconds: 5);
    if (elapsedTime < minSplashDuration) {
      await Future.delayed(minSplashDuration - elapsedTime);
    }

    if (!context.mounted) return;

    // Navigate to respective route based on auth status
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      if (authViewModel.isOnboarded) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trigger auth check once after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus(context);
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.splashGradient, // Deep vibrant blue
              Colors.white, // Pure white center
              AppTheme.splashGradient, // Deep vibrant blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeIn,
            builder: (context, opacity, child) {
              return Opacity(opacity: opacity, child: child);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Constrained logo asset to keep it perfectly balanced
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Image.asset(
                      AppIcons.assetLogo,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Styled "DesiConnect" logo text
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        fontFamily: 'Inter',
                      ),
                      children: [
                        TextSpan(
                          text: AppStrings.splashDesi,
                          style: TextStyle(color: AppTheme.splashDesi),
                        ),
                        TextSpan(
                          text: AppStrings.splashConnect,
                          style: TextStyle(color: AppTheme.splashConnect),
                        ),
                      ],
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
