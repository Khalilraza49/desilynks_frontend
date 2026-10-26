import 'package:flutter/material.dart';
import 'skeleton_shimmer.dart';

/// General-purpose animated looping skeleton view for list screens
/// (e.g. MyJobsView, MyApplicationsView, MyAdsView, FavouriteAdsView, EventsView).
class ListSkeleton extends StatelessWidget {
  final bool showTabs;
  final int itemCount;

  const ListSkeleton({super.key, this.showTabs = true, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          if (showTabs) ...[
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SkeletonBox(width: 70, height: 34, borderRadius: 20),
                  SizedBox(width: 8),
                  SkeletonBox(width: 80, height: 34, borderRadius: 20),
                  SizedBox(width: 8),
                  SkeletonBox(width: 80, height: 34, borderRadius: 20),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      SkeletonBox(
                        width: 72,
                        height: 72,
                        borderRadius: 12,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLine(width: 150, height: 15),
                            SizedBox(height: 8),
                            SkeletonLine(width: 100, height: 12),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SkeletonBox(
                                  width: 60,
                                  height: 20,
                                  borderRadius: 6,
                                ),
                                SkeletonLine(width: 50, height: 11),
                              ],
                            ),
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
