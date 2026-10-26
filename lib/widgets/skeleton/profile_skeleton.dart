import 'package:flutter/material.dart';
import 'skeleton_shimmer.dart';

/// Animated looping skeleton view for ProfileView.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header Card Skeleton
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 36, height: 36, borderRadius: 8),
                      SkeletonLine(width: 80, height: 18),
                      SkeletonBox(width: 36, height: 36, borderRadius: 8),
                    ],
                  ),
                  SizedBox(height: 20),
                  SkeletonCircle(size: 76),
                  SizedBox(height: 14),
                  SkeletonLine(width: 150, height: 20),
                  SizedBox(height: 8),
                  SkeletonLine(width: 100, height: 13),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonBox(width: 100, height: 32, borderRadius: 16),
                      SizedBox(width: 10),
                      SkeletonBox(width: 100, height: 32, borderRadius: 16),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Statistics 4-Box Grid Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        children: [
                          SkeletonLine(width: 28, height: 18),
                          SizedBox(height: 6),
                          SkeletonLine(width: 44, height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Membership Banner Skeleton
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SkeletonBox(
                height: 70,
                width: double.infinity,
                borderRadius: 16,
              ),
            ),

            const SizedBox(height: 16),

            // Menu Items Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: List.generate(
                    4,
                    (index) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          SkeletonCircle(size: 34),
                          SizedBox(width: 14),
                          Expanded(child: SkeletonLine(width: 120, height: 15)),
                          SkeletonBox(width: 16, height: 16, borderRadius: 4),
                        ],
                      ),
                    ),
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
