import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/home/home_viewmodel.dart';

class HomePromoBanner extends StatelessWidget {
  final List<Map<String, dynamic>> bannerPromos;

  const HomePromoBanner({super.key, required this.bannerPromos});

  static const int _loopFactor = 1000;
  static const Duration _scrollDuration = Duration(milliseconds: 600);

  int get _initialPage {
    if (bannerPromos.length <= 1) return 0;
    final total = bannerPromos.length * _loopFactor;
    return (total ~/ 2) - ((total ~/ 2) % bannerPromos.length);
  }

  void _onBannerTap(BuildContext context, Map<String, dynamic> promo) {
    final buttonText = (promo['buttonText'] as String? ?? '').toLowerCase();
    if (buttonText.contains('explore')) {
      Navigator.pushNamed(context, AppRoutes.exploreSpain);
    } else if (buttonText.contains('deal') || buttonText.contains('discount')) {
      Navigator.pushNamed(context, AppRoutes.dealsDiscounts);
    } else if (buttonText.contains('book') ||
        buttonText.contains('worker') ||
        buttonText.contains('service')) {
      Navigator.pushNamed(context, AppRoutes.hireWorkers);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bannerPromos.isEmpty) return const SizedBox.shrink();

    final homeViewModel = context.watch<HomeViewModel>();
    final int bannerCount = bannerPromos.length;
    final int itemCount = bannerCount > 1
        ? bannerCount * _loopFactor
        : bannerCount;

    return Column(
      children: [
        SizedBox(
          height: 156,
          child: PageView.builder(
            controller: homeViewModel.bannerController,
            onPageChanged: (index) {
              if (bannerCount == 0) return;
              homeViewModel.setBannerIndex(index % bannerCount);
              // Reset timer on manual scroll so user has full interval to view
              homeViewModel.startAutoScroll();
            },
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final promo = bannerPromos[index % bannerCount];
              final Color promoColor =
                  promo['color'] as Color? ?? AppColors.primaryBlue;

              return GestureDetector(
                onTap: () => _onBannerTap(context, promo),
                child: Container(
                  margin: const EdgeInsets.only(right: AppConstants.padding4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [promoColor, promoColor.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: AppColors.white.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingLarge,
                          vertical: AppConstants.paddingMedium,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              promo['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppConstants.fontSize,
                                color: AppColors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppConstants.padding2),
                            Text(
                              promo['subtitle'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: AppConstants.fontSizeTitle,
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            ElevatedButton(
                              onPressed: () => _onBannerTap(context, promo),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: promoColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingLarge,
                                  vertical: AppConstants.padding6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadius8,
                                  ),
                                ),
                              ),
                              child: Text(
                                promo['buttonText'],
                                style: const TextStyle(
                                  fontSize: AppConstants.fontSizeSM,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (bannerCount > 1) ...[
          const SizedBox(height: AppConstants.padding10),
          // Banner Dots Indicator with smooth animated transitions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(bannerCount, (index) {
              final bool isSelected = homeViewModel.currentBannerIndex == index;
              return GestureDetector(
                onTap: () {
                  if (!homeViewModel.bannerController.hasClients || bannerCount <= 1) return;
                  final current =
                      homeViewModel.bannerController.page?.round() ?? _initialPage;
                  final currentMod = current % bannerCount;
                  final diff = index - currentMod;
                  homeViewModel.bannerController.animateToPage(
                    current + diff,
                    duration: _scrollDuration,
                    curve: Curves.easeInOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isSelected
                      ? AppConstants.borderRadius24
                      : AppConstants.borderRadius8,
                  height: AppConstants.borderRadius8,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.slate300,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusExtraSmall,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
