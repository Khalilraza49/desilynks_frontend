import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/onboarding/onboarding_viewmodel.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final navigator = Navigator.of(context);
    await authViewModel.completeOnboarding();
    if (context.mounted) {
      navigator.pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = context.isSmall
        ? AppConstants.paddingLarge
        : (context.scale(AppConstants.paddingExtraLarge)).clamp(20.0, 36.0);

    return Consumer<OnboardingViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: vm.pageController,
                        itemCount: vm.slides.length,
                        onPageChanged: vm.setPage,
                        itemBuilder: (context, index) {
                          final slide = vm.slides[index];
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final bool isShort = constraints.maxHeight < 520;
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Spacer(flex: isShort ? 1 : 2),

                                    Text(
                                      slide.title,
                                      style: TextStyle(
                                        fontSize: context.sp(
                                          AppConstants.fontSizeLargeDisplay,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryBlue,
                                        fontFamily: AppStrings.fontInter,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: (context.scaleH(
                                        AppConstants.paddingMedium,
                                      )).clamp(6.0, 16.0),
                                    ),

                                    Text(
                                      slide.subtitle,
                                      style: TextStyle(
                                        fontSize: context.sp(
                                          AppConstants.fontSize,
                                        ),
                                        color: AppColors.gradientStartOpacity,
                                        height: 1.5,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: AppStrings.fontInter,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const Spacer(flex: 1),

                                    Flexible(
                                      flex: isShort ? 6 : 8,
                                      child: Image.asset(
                                        slide.imagePath,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Spacer(flex: isShort ? 1 : 2),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: (context.scaleH(
                          AppConstants.padding20,
                        )).clamp(10.0, 24.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(vm.slides.length, (index) {
                              final isSelected = vm.currentPage == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(
                                  horizontal: (context.scale(
                                    AppConstants.padding4,
                                  )).clamp(3.0, 6.0),
                                ),
                                height: (context.scale(
                                  AppConstants.padding10,
                                )).clamp(8.0, 12.0),
                                width: isSelected
                                    ? (context.scale(28.0)).clamp(22.0, 36.0)
                                    : (context.scale(
                                        AppConstants.padding10,
                                      )).clamp(8.0, 12.0),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : AppColors.grayOpacity40,
                                  borderRadius: BorderRadius.circular(
                                    (context.scale(
                                      AppConstants.paddingSmall,
                                    )).clamp(6.0, 10.0),
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(
                            height: (context.scaleH(
                              AppConstants.paddingExtraLarge,
                            )).clamp(12.0, 28.0),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => _completeOnboarding(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryBlue,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: (context.scale(
                                      AppConstants.paddingMedium,
                                    )).clamp(8.0, 16.0),
                                    vertical: (context.scaleH(
                                      AppConstants.paddingSmall,
                                    )).clamp(4.0, 10.0),
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: context.sp(
                                      AppConstants.fontSizeXL,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppStrings.fontRoboto,
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: (context.scale(96.0)).clamp(84.0, 120.0),
                                height: (context.scaleH(
                                  42.0,
                                )).clamp(38.0, 50.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    final moved = vm.goToNextPage();
                                    if (!moved) {
                                      _completeOnboarding(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryBlue,
                                    foregroundColor: AppColors.white,
                                    elevation: AppConstants.elevationNone,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius8,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: context.sp(
                                        AppConstants.fontSizeXL,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppStrings.fontRoboto,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
