import 'package:flutter/material.dart';
import 'skeleton_shimmer.dart';

/// Animated looping skeleton view for ChatView.
class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Search Bar Skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SkeletonBox(
              height: 44,
              borderRadius: 12,
              width: double.infinity,
            ),
          ),

          const SizedBox(height: 14),

          // Filter Pills Skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SkeletonBox(width: 60, height: 34, borderRadius: 20),
                SizedBox(width: 8),
                SkeletonBox(width: 80, height: 34, borderRadius: 20),
                SizedBox(width: 8),
                SkeletonBox(width: 75, height: 34, borderRadius: 20),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Conversation Items Skeleton
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 7,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return const Row(
                  children: [
                    SkeletonCircle(size: 52),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SkeletonLine(width: 120, height: 16),
                              SkeletonLine(width: 40, height: 12),
                            ],
                          ),
                          SizedBox(height: 8),
                          SkeletonLine(width: 200, height: 13),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
