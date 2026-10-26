import 'package:flutter/material.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/widgets/skeleton/skeleton_shimmer.dart';

/// Full-screen animated looping skeleton loading view for HomeView.
/// Displays while app initial data, user session, or listings are loading.
class HomeSkeletonView extends StatelessWidget {
  const HomeSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.marginHorizontal,
          vertical: AppConstants.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Skeleton
            const Row(
              children: [
                SkeletonCircle(size: 44),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 120, height: 12, borderRadius: 4),
                      SizedBox(height: 6),
                      SkeletonBox(width: 160, height: 16, borderRadius: 4),
                    ],
                  ),
                ),
                SkeletonCircle(size: 38),
              ],
            ),
            const SizedBox(height: AppConstants.padding20),

            // 2. Search Bar Skeleton
            const SkeletonBox(
              width: double.infinity,
              height: 48,
              borderRadius: AppConstants.borderRadiusLarge,
            ),
            const SizedBox(height: AppConstants.padding20),

            // 3. Featured Promo Banner Carousel Skeleton
            const SkeletonBox(
              width: double.infinity,
              height: 156,
              borderRadius: AppConstants.borderRadiusLarge,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: SkeletonBox(
                    width: index == 0 ? 24 : 8,
                    height: 8,
                    borderRadius: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.padding20),

            // 4. Today's Stats Panel Skeleton
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                border: Border.all(
                  color: AppColors.slate200.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 140, height: 16, borderRadius: 4),
                      SkeletonBox(width: 60, height: 20, borderRadius: 10),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (_) => const Column(
                        children: [
                          SkeletonBox(width: 36, height: 20, borderRadius: 4),
                          SizedBox(height: 6),
                          SkeletonBox(width: 48, height: 10, borderRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingExtraLarge),

            // 5. Categories Grid Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                (_) => const Column(
                  children: [
                    SkeletonCircle(size: 52),
                    SizedBox(height: 8),
                    SkeletonBox(width: 44, height: 10, borderRadius: 4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingExtraLarge),

            // 6. Location Filter Badges Skeleton
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SkeletonBox(
                      width: index == 0 ? 80 : 70,
                      height: 32,
                      borderRadius: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingExtraLarge),

            // 7. Featured Listings Section Skeleton
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 150, height: 18, borderRadius: 4),
                SkeletonBox(width: 60, height: 14, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.slate200.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(
                          width: double.infinity,
                          height: 110,
                          borderRadius: 10,
                        ),
                        SizedBox(height: 8),
                        SkeletonBox(width: 100, height: 12, borderRadius: 4),
                        SizedBox(height: 6),
                        SkeletonBox(width: 60, height: 14, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.slate200.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(
                          width: double.infinity,
                          height: 110,
                          borderRadius: 10,
                        ),
                        SizedBox(height: 8),
                        SkeletonBox(width: 100, height: 12, borderRadius: 4),
                        SizedBox(height: 6),
                        SkeletonBox(width: 60, height: 14, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.padding40),
          ],
        ),
      ),
    );
  }
}
