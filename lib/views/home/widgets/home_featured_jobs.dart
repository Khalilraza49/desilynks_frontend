import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';

class HomeFeaturedJobs extends StatelessWidget {
  final List<Map<String, dynamic>> jobs;

  const HomeFeaturedJobs({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
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

    return Column(
      children: jobs.map((job) {
        final String imageUrl = job['imageUrl'] as String? ?? '';
        final bool hasImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');

        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
          child: GestureDetector(
            onTap: () {
              Provider.of<NavigationViewModel>(
                context,
                listen: false,
              ).openJobs();
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: AppConstants.borderRadiusSmall,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        child: hasImage
                            ? Image.network(
                                imageUrl,
                                width: AppConstants.jobImageSize,
                                height: AppConstants.jobImageSize,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildJobImagePlaceholder(),
                              )
                            : _buildJobImagePlaceholder(),
                      ),
                      const SizedBox(width: AppConstants.paddingLarge),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: AppConstants.fontSizeLG,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate800,
                              ),
                            ),
                            const SizedBox(height: AppConstants.padding6),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcons.briefcaseSvg,
                                  width: AppConstants.fontSizeMD,
                                  height: AppConstants.fontSizeMD,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.slate500,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.padding4),
                                Expanded(
                                  child: Text(
                                    job['company'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: AppConstants.fontSizeSM,
                                      color: AppColors.slate500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.padding4),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcons.locationSvg,
                                  width: AppConstants.fontSizeMD,
                                  height: AppConstants.fontSizeMD,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.slate500,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.padding4),
                                Expanded(
                                  child: Text(
                                    job['location'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: AppConstants.fontSizeSM,
                                      color: AppColors.slate500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppConstants.paddingMedium,
                                      vertical: AppConstants.padding6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: job['typeColor'],
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius10,
                                      ),
                                    ),
                                    child: Text(
                                      job['type'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: job['typeTextColor'],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: AppConstants.paddingSmall,
                                ),
                                Flexible(
                                  child: Text(
                                    job['salary'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: AppConstants.fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (job['isSponsored'] == true)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingStandard,
                        vertical: 5.0,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.sponsoredYellow,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(
                            AppConstants.borderRadius16,
                          ),
                          bottomLeft: Radius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                        ),
                      ),
                      child: const Text(
                        AppStrings.labelSponsored,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: AppConstants.fontSizeXS,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildJobImagePlaceholder() {
    return Container(
      width: AppConstants.jobImageSize,
      height: AppConstants.jobImageSize,
      color: AppColors.slate200,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppIcons.gallerySvg,
        width: AppConstants.iconSizeLG,
        height: AppConstants.iconSizeLG,
        colorFilter: const ColorFilter.mode(
          AppColors.systemGray,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
