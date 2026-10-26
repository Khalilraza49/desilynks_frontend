import 'package:flutter/material.dart';
import 'skeleton_shimmer.dart';

/// Animated looping skeleton view for CommunityView.
class CommunitySkeleton extends StatelessWidget {
  const CommunitySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Pills Skeleton
            const Row(
              children: [
                SkeletonBox(width: 60, height: 36, borderRadius: 20),
                SizedBox(width: 8),
                SkeletonBox(width: 95, height: 36, borderRadius: 20),
                SizedBox(width: 8),
                SkeletonBox(width: 75, height: 36, borderRadius: 20),
                SizedBox(width: 8),
                SkeletonBox(width: 75, height: 36, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 16),

            // Create Post Prompt Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  SkeletonCircle(size: 40),
                  SizedBox(width: 12),
                  Expanded(child: SkeletonBox(height: 38, borderRadius: 20)),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Groups Row
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonCircle(size: 28),
                        SizedBox(height: 8),
                        SkeletonLine(width: 65, height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Feed Post Cards
            ...List.generate(
              2,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkeletonCircle(size: 44),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLine(width: 120, height: 14),
                            SizedBox(height: 6),
                            SkeletonLine(width: 70, height: 10),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    SkeletonLine(width: double.infinity, height: 13),
                    SizedBox(height: 6),
                    SkeletonLine(width: 220, height: 13),
                    SizedBox(height: 12),
                    SkeletonBox(
                      height: 140,
                      width: double.infinity,
                      borderRadius: 12,
                    ),
                    SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SkeletonBox(width: 60, height: 20, borderRadius: 6),
                        SkeletonBox(width: 60, height: 20, borderRadius: 6),
                        SkeletonBox(width: 60, height: 20, borderRadius: 6),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
