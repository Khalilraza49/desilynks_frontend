import 'package:flutter/material.dart';
import 'skeleton_shimmer.dart';

/// Animated looping skeleton view for JobsView.
class JobsSkeleton extends StatelessWidget {
  const JobsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          // Top controls container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              bottom: 12,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: Column(
              children: [
                // Mode Toggle Skeleton
                const Row(
                  children: [
                    Expanded(child: SkeletonBox(height: 38, borderRadius: 10)),
                    SizedBox(width: 8),
                    Expanded(child: SkeletonBox(height: 38, borderRadius: 10)),
                  ],
                ),
                const SizedBox(height: 12),

                // Search Bar Skeleton
                const Row(
                  children: [
                    Expanded(child: SkeletonBox(height: 46, borderRadius: 12)),
                    SizedBox(width: 10),
                    SkeletonBox(width: 46, height: 46, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter Pills Skeleton
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SkeletonBox(
                          width: index == 0 ? 50 : 80,
                          height: 32,
                          borderRadius: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Job Cards List Skeleton
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonLine(width: 160, height: 16),
                                SizedBox(height: 6),
                                SkeletonLine(width: 100, height: 12),
                              ],
                            ),
                          ),
                          SkeletonBox(
                            width: 32,
                            height: 32,
                            borderRadius: 8,
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      Row(
                        children: [
                          SkeletonBox(width: 75, height: 24, borderRadius: 6),
                          SizedBox(width: 8),
                          SkeletonBox(width: 90, height: 24, borderRadius: 6),
                          SizedBox(width: 8),
                          SkeletonBox(width: 65, height: 24, borderRadius: 6),
                        ],
                      ),
                      SizedBox(height: 12),
                      SkeletonLine(width: 120, height: 18),
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
