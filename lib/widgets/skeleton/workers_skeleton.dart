import 'package:flutter/material.dart';
import 'skeleton_shimmer.dart';

/// Animated looping skeleton view for HireWorkersView.
class WorkersSkeleton extends StatelessWidget {
  const WorkersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Search Bar Skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SkeletonBox(
              height: 48,
              borderRadius: 12,
              width: double.infinity,
            ),
          ),

          // Category Chips Skeleton
          Container(
            height: 46,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SkeletonBox(
                    width: index == 0 ? 55 : (index.isEven ? 85 : 100),
                    height: 34,
                    borderRadius: 24,
                  ),
                );
              },
            ),
          ),

          // Worker Cards Skeleton
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      SkeletonCircle(size: 56),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLine(width: 140, height: 16),
                            SizedBox(height: 6),
                            SkeletonBox(width: 80, height: 20, borderRadius: 4),
                            SizedBox(height: 6),
                            SkeletonLine(width: 100, height: 12),
                          ],
                        ),
                      ),
                      SkeletonBox(
                        width: 38,
                        height: 38,
                        borderRadius: 19,
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
