import 'package:flutter/material.dart';
import 'skeleton_shimmer.dart';

/// Animated looping skeleton view for MarketplaceView.
class MarketplaceSkeleton extends StatelessWidget {
  const MarketplaceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // 1. Search Bar Skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SkeletonBox(
              height: 48,
              borderRadius: 12,
              width: double.infinity,
            ),
          ),

          const SizedBox(height: 8),

          // 2. Category Pills Row Skeleton
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: List.generate(
                6,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SkeletonBox(
                    width: index == 0 ? 55 : (index.isEven ? 80 : 95),
                    height: 38,
                    borderRadius: 22,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3. Product Cards Skeleton Grid/List
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.68,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: SkeletonBox(
                          height: 130,
                          width: double.infinity,
                          borderRadius: 0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLine(width: 70, height: 16),
                            SizedBox(height: 8),
                            SkeletonLine(width: double.infinity, height: 12),
                            SizedBox(height: 6),
                            SkeletonLine(width: 90, height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
