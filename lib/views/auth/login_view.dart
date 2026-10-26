import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/home/home_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_checkbox.dart';
import '../../widgets/social_login_button.dart';
import '../../widgets/custom_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await authViewModel.login(
      authViewModel.loginEmailController.text.trim(),
      authViewModel.loginPasswordController.text,
    );

    if (success && context.mounted) {
      _navigateToHome(context);
    }
  }

  void _navigateToHome(BuildContext context) {
    Provider.of<HomeViewModel>(context, listen: false).setInitialLoading(true);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    developer.log('Starting Google Sign-In flow...', name: 'GoogleSignIn');
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      developer.log('Calling GoogleSignIn.signIn()...', name: 'GoogleSignIn');
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        developer.log(
          'GoogleSignIn.signIn() success. Account email: ${account.email}, id: ${account.id}, displayName: ${account.displayName}',
          name: 'GoogleSignIn',
        );
        developer.log(
          'Retrieving GoogleSignInAuthentication...',
          name: 'GoogleSignIn',
        );
        final GoogleSignInAuthentication auth = await account.authentication;
        final String? idToken = auth.idToken;
        developer.log(
          'GoogleSignInAuthentication idToken: ${idToken != null ? "Not null (length: ${idToken.length})" : "Null"}, accessToken: ${auth.accessToken != null ? "Not null (length: ${auth.accessToken!.length})" : "Null"}',
          name: 'GoogleSignIn',
        );
        if (idToken != null) {
          developer.log(
            'Initiating viewmodel googleLogin with idToken...',
            name: 'GoogleSignIn',
          );
          final success = await authViewModel.googleLogin(idToken);
          developer.log(
            'Viewmodel googleLogin success status: $success',
            name: 'GoogleSignIn',
          );
          if (success && context.mounted) {
            developer.log('Navigating to Home route...', name: 'GoogleSignIn');
            _navigateToHome(context);
          } else if (context.mounted &&
              (authViewModel.errorMessage?.contains('No account found') ??
                  false)) {
            authViewModel.registerEmailController.text = account.email;
            if (account.displayName != null &&
                account.displayName!.isNotEmpty) {
              final parts = account.displayName!.split(' ');
              authViewModel.registerFirstNameController.text = parts.first;
              if (parts.length > 1) {
                authViewModel.registerLastNameController.text =
                    parts.sublist(1).join(' ');
              }
            }
            Navigator.pushNamed(context, AppRoutes.register);
          }
        } else {
          developer.log(
            'Error: Google Sign-In failed because idToken is null.',
            name: 'GoogleSignIn',
          );
          throw Exception("Google Sign-In failed: idToken is null.");
        }
      } else {
        developer.log(
          'GoogleSignIn.signIn() returned null (user likely cancelled or configuration issue).',
          name: 'GoogleSignIn',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Exception in Google Sign-In: $e',
        name: 'GoogleSignIn',
        error: e,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final String? idToken = credential.identityToken;
      if (idToken != null) {
        final success = await authViewModel.appleLogin(idToken);
        if (success && context.mounted) {
          _navigateToHome(context);
        } else if (context.mounted &&
            (authViewModel.errorMessage?.contains('No account found') ??
                false)) {
          if (credential.email != null && credential.email!.isNotEmpty) {
            authViewModel.registerEmailController.text = credential.email!;
          }
          if (credential.givenName != null &&
              credential.givenName!.isNotEmpty) {
            authViewModel.registerFirstNameController.text =
                credential.givenName!;
          }
          if (credential.familyName != null &&
              credential.familyName!.isNotEmpty) {
            authViewModel.registerLastNameController.text =
                credential.familyName!;
          }
          Navigator.pushNamed(context, AppRoutes.register);
        }
      } else {
        throw Exception("Apple Sign-In failed: identityToken is null.");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _handleFacebookSignIn(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );
      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        if (accessToken != null) {
          final success =
              await authViewModel.facebookLogin(accessToken.tokenString);
          if (success && context.mounted) {
            _navigateToHome(context);
          }
        } else {
          throw Exception("Facebook Login failed: accessToken is null.");
        }
      } else if (result.status == LoginStatus.cancelled) {
        // User cancelled login
      } else {
        throw Exception("Facebook Login failed: ${result.message}");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isSmall = context.isSmall;
    final headerHeight = isSmall ? 220.0 : 260.0;
    final cardOverlapPush = isSmall ? 180.0 : 210.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // 1. Blue Top Header Area
            Container(
              height: headerHeight,
              color: AppTheme.primaryBlue,
              child: Stack(
                children: [
                  // Decorative circle (top right)
                  Positioned(
                    top: -40,
                    right: -30,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  // Decorative circle (bottom left)
                  Positioned(
                    bottom: 40,
                    left: -40,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  // Header content (Logo, DesiConnect, Subtitle)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isSmall ? 20 : 36),
                        // App Logo
                        Container(
                          height: isSmall ? 48 : 56,
                          width: isSmall ? 48 : 56,
                          alignment: Alignment.center,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: AppColors.mediumBlue,
                            borderRadius: BorderRadius.circular(
                              isSmall ? 10 : 16,
                            ),
                            image: DecorationImage(
                              image: AssetImage(AppIcons.assetLoginHeader),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmall ? 10 : 14),
                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: isSmall ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.yourCommunityInSpain,
                          style: TextStyle(
                            fontSize: isSmall ? 12 : 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Floating Form card & content scroll view
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: cardOverlapPush),
                  SizedBox(height: isSmall ? 20 : 35),

                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isSmall
                          ? 14.0
                          : AppConstants.marginHorizontal,
                    ),
                    padding: EdgeInsets.all(
                      isSmall ? 18.0 : AppConstants.paddingExtraLarge,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusLarge,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Back title
                          const Row(
                            children: [
                              Text(
                                AppStrings.welcomeBack,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text('👋', style: TextStyle(fontSize: 22)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.loginSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray900.withValues(alpha: 0.66),
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Error banner if authViewModel has an error
                          if (authViewModel.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(
                                AppConstants.paddingMedium,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMedium,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    AppIcons.errorSvg,
                                    width: AppConstants.iconSize,
                                    height: AppConstants.iconSize,
                                    colorFilter: ColorFilter.mode(
                                      theme.colorScheme.onErrorContainer,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      authViewModel.errorMessage!,
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppStrings.fontInter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email or Phone input label
                          const Text(
                            AppStrings.emailOrPhoneLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textLabel,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Email input field
                          CustomTextField(
                            controller: authViewModel.loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                            focusColor: AppColors.backgroundOffWhite,
                            hintText: AppStrings.emailHint,
                            prefixIconAsset: AppIcons.assetPerson,
                            fontFamily: AppStrings.fontInter,
                            fontWeight: FontWeight.w400,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppStrings.valEmailOrPhoneRequired;
                              }
                              final trimmed = value.trim();
                              final isEmail = trimmed.contains('@');
                              if (isEmail) {
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(trimmed)) {
                                  return AppStrings.valEmailInvalid;
                                }
                              } else {
                                if (!RegExp(
                                  r'^\+?[1-9]\d{1,14}$',
                                ).hasMatch(trimmed)) {
                                  return AppStrings.valPhoneInvalid;
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password input label
                          const Text(
                            AppStrings.passwordLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textGray,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Password input field
                          CustomTextField(
                            controller: authViewModel.loginPasswordController,
                            obscureText: authViewModel.loginObscurePassword,
                            hintText: AppStrings.passwordHint,
                            prefixIconAsset: AppIcons.lockClosedSvg,
                            suffixIcon: IconButton(
                              icon: SvgPicture.asset(
                                authViewModel.loginObscurePassword
                                    ? AppIcons.eyeSvg
                                    : AppIcons.eyeSvg,
                                width: 20,
                                height: 20,
                                fit: BoxFit.scaleDown,
                              ),
                              onPressed: () {
                                authViewModel.toggleLoginObscurePassword();
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.valPasswordRequired;
                              }
                              if (value.length < 6) {
                                return AppStrings.valPasswordMinLength6;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Remember Me & Forgot Password Row
                          Row(
                            children: [
                              CustomCheckbox(
                                value: authViewModel.loginRememberMe,
                                onChanged: (value) {
                                  authViewModel.toggleLoginRememberMe();
                                },
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                AppStrings.rememberMe,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textGray,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPassword,
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  AppStrings.forgotPassword,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Login Button (Gradient blue-to-purple)
                          CustomButton(
                            text: AppStrings.login,
                            onPressed: () => _handleLogin(context),
                            isLoading: authViewModel.isLoading,
                            height: 50,
                            fontWeight: FontWeight.bold,
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.gradientStart,
                                AppTheme.gradientEnd,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Dotted divider "or continue with"
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AppTheme.borderLight),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Text(
                                  AppStrings.orContinueWith,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.black.withValues(
                                      alpha: 0.56,
                                    ),
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppTheme.borderLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Social login row
                          Row(
                            children: [
                              // Google Button
                              Expanded(
                                child: SocialLoginButton(
                                  iconPath: AppIcons.googleSvg,
                                  onPressed: () => _handleGoogleSignIn(context),
                                ),
                              ),
                              SizedBox(width: isSmall ? 8 : 12),
                              // Apple Button
                              Expanded(
                                child: SocialLoginButton(
                                  iconPath: AppIcons.appleBrandSvg,
                                  onPressed: () => _handleAppleSignIn(context),
                                ),
                              ),
                              SizedBox(width: isSmall ? 8 : 12),
                              // Facebook Button
                              Expanded(
                                child: SocialLoginButton(
                                  iconPath: AppIcons.facebookSvg,
                                  onPressed: () =>
                                      _handleFacebookSignIn(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Register navigation footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                AppStrings.dontHaveAccount,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textGray,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.register,
                                  );
                                },
                                child: const Text(
                                  AppStrings.register,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dotted guest button
                          CustomPaint(
                            painter: DashedRoundedBorderPainter(
                              color: AppTheme.borderDashed,
                              borderRadius: AppConstants.borderRadiusMedium,
                              dashWidth: 4,
                              dashGap: 3,
                            ),
                            child: SizedBox(
                              height: 48,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMedium,
                                ),
                                onTap: () {
                                  // Bypass to Home screen directly
                                  _navigateToHome(context);
                                },
                                child: const Center(
                                  child: Text(
                                    AppStrings.continueAsGuest,
                                    style: TextStyle(
                                      color: AppTheme.textGray,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to draw a dashed/dotted rounded border
class DashedRoundedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double borderRadius;

  DashedRoundedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.borderRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final Path dashedPath = Path();
    double distance = 0.0;
    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashGap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
