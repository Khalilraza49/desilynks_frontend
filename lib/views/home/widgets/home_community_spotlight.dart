import 'package:flutter/material.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';

class HomeCommunitySpotlight extends StatelessWidget {
  final List<Map<String, dynamic>> spotlightUsers;

  const HomeCommunitySpotlight({super.key, required this.spotlightUsers});

  @override
  Widget build(BuildContext context) {
    if (spotlightUsers.isEmpty) {
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
        children: spotlightUsers.map((spotlight) {
          final String imageUrl = spotlight['imageUrl'] as String? ?? '';
          final bool hasValidImage =
              imageUrl.isNotEmpty && imageUrl.startsWith('http');

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.hireWorkers);
            },
            child: Container(
              width: AppConstants.spotlightCardWidth,
              margin: const EdgeInsets.only(right: AppConstants.paddingLarge),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue,
                            width: AppConstants.borderWidthMedium,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.slate200,
                          backgroundImage:
                              hasValidImage ? NetworkImage(imageUrl) : null,
                          onBackgroundImageError: hasValidImage
                              ? (_, __) {}
                              : null,
                          child: !hasValidImage
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.slate500,
                                  size: 28,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: AppConstants.padding2,
                        right: AppConstants.padding2,
                        child: Container(
                          width: AppConstants.iconSizeSM,
                          height: AppConstants.iconSizeSM,
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: AppConstants.borderWidthThick,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    spotlight['name'] as String? ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeMD,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spotlight['role'] as String? ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
