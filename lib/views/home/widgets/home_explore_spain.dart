import 'package:flutter/material.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/app/routes.dart';

class HomeExploreSpain extends StatelessWidget {
  final List<Map<String, dynamic>> exploreCities;

  const HomeExploreSpain({super.key, required this.exploreCities});

  @override
  Widget build(BuildContext context) {
    if (exploreCities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppConstants.padding20),
          child: Text(
            AppStrings.noDataAvailable,
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              color: AppColors.slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: exploreCities.map((explore) {
          final String imageUrl = explore['imageUrl'] as String? ?? '';
          final bool hasImage =
              imageUrl.isNotEmpty && imageUrl.startsWith('http');

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.exploreSpain);
            },
            child: Container(
              width: AppConstants.exploreCardWidth,
              height: AppConstants.exploreCardHeight,
              margin: const EdgeInsets.only(right: AppConstants.paddingMedium),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadius16,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadius16,
                ),
                child: Stack(
                  children: [
                    hasImage
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: AppColors.slate200),
                          )
                        : Container(color: AppColors.slate200),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.padding10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            explore['name'] as String? ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: AppConstants.fontSizeMD,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            explore['desc'] as String? ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.8),
                              fontSize: AppConstants.fontSizeXXS,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
