import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/services/connectivity_service.dart';

/// A full-screen overlay that appears when the device has no internet.
///
/// It displays an animated "no connection" illustration with a
/// pulsing retry button. When connectivity is restored, the overlay
/// automatically disappears.
class NetworkErrorScreen extends StatefulWidget {
  const NetworkErrorScreen({super.key});

  @override
  State<NetworkErrorScreen> createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends State<NetworkErrorScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the wifi icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Bounce animation for the retry button
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Fade-in for the whole screen
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onRetry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);
    _bounceController.forward().then((_) => _bounceController.reverse());
    await ConnectivityService.instance.recheckConnectivity();

    // Small delay so the user sees the loading state
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.slate900 : AppColors.slate50,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Animated Icon Container ──
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: size.width * 0.42,
                      height: size.width * 0.42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [AppColors.slate800, AppColors.slate700]
                              : [AppColors.slate100, AppColors.slate200],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isDark
                                        ? AppColors.indigo
                                        : AppColors.primaryBlue)
                                    .withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Wifi icon
                          SvgPicture.asset(
                            AppIcons.wifiSvg,
                            height: size.width * 0.16,
                            color: isDark
                                ? AppColors.slate400
                                : AppColors.slate500,
                          ),
                          // Diagonal slash overlay
                          Positioned(
                            child: Transform.rotate(
                              angle: -0.6,
                              child: Container(
                                width: size.width * 0.2,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Title ──
                  Text(
                    'No Internet Connection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: isDark ? AppColors.white : AppColors.gray900,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Subtitle ──
                  Text(
                    'Please check your WiFi or mobile data\nand try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Retry Button ──
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isRetrying ? null : _onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: AppColors.primaryBlue
                              .withOpacity(0.6),
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isRetrying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AppIcons.restartSvg,
                                    height: 20,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Try Again',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Hint chips ──
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _HintChip(
                        icon: AppIcons.wifiSvg,
                        label: 'Check WiFi',
                        isDark: isDark,
                      ),
                      _HintChip(
                        icon: AppIcons.wifiSvg,
                        label: 'Mobile Data',
                        isDark: isDark,
                      ),
                      _HintChip(
                        icon: AppIcons.planeSvg,
                        label: 'Airplane Mode',
                        isDark: isDark,
                      ),
                    ],
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

/// A small informational chip shown below the retry button.
class _HintChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool isDark;

  const _HintChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800.withOpacity(0.6) : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            height: 15,
            width: 15,
            color: isDark ? AppColors.slate400 : AppColors.slate500,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              color: isDark ? AppColors.slate400 : AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }
}
