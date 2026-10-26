import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/models/marketplace_item_model.dart';
import 'package:desilynks/viewmodels/home/home_viewmodel.dart';

class HomeFeaturedListings extends StatelessWidget {
  final List<MarketplaceItemModel> items;

  const HomeFeaturedListings({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // Only top 3 marketplace ads are shown
    final displayList = items.take(3).toList();

    if (displayList.isEmpty) {
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

    final homeViewModel = context.watch<HomeViewModel>();
    final int activeIndex = homeViewModel.featuredListingsIndex.clamp(
      0,
      displayList.length - 1,
    );

    return Column(
      children: [
        SizedBox(
          height: AppConstants.featuredListingScrollHeight,
          child: PageView.builder(
            controller: homeViewModel.featuredListingsController,
            onPageChanged: (index) {
              homeViewModel.setFeaturedListingsIndex(index);
            },
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final item = displayList[index];

              final photos = item.photos.isNotEmpty
                  ? item.photos.map((p) => p.url).toList()
                  : (item.photoUrls.isNotEmpty
                      ? item.photoUrls
                      : (item.imageUrl.isNotEmpty
                          ? [item.imageUrl]
                          : <String>[]));
              final String displayImage =
                  photos.isNotEmpty ? photos.first : item.imageUrl;

              final String formattedPrice = item.price.trim().startsWith('€')
                  ? item.price.trim()
                  : '€${item.price.trim()}';

              final String tagText = item.condition?.isNotEmpty == true
                  ? item.condition!
                  : (item.isNegotiable ? 'Negotiable' : 'Fixed Price');

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.marketplaceDetail,
                    arguments: item,
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: AppConstants.borderRadius10,
                        offset: const Offset(
                          0,
                          AppConstants.borderRadiusExtraSmall,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image section with Golden tag
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(
                                AppConstants.borderRadiusLarge,
                              ),
                            ),
                            child: displayImage.isNotEmpty &&
                                    displayImage.startsWith('http')
                                ? Image.network(
                                    displayImage,
                                    height:
                                        AppConstants.featuredListingImageHeight,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return _buildImagePlaceholder();
                                    },
                                  )
                                : _buildImagePlaceholder(),
                          ),
                          if (item.isGolden)
                            Positioned(
                              top: AppConstants.padding10,
                              left: AppConstants.padding10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.padding10,
                                  vertical: AppConstants.padding4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentYellow,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusSmall,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      AppIcons.starFavoriteSvg,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.white,
                                        BlendMode.srcIn,
                                      ),
                                      width: AppConstants.iconSizeXS,
                                      height: AppConstants.iconSizeXS,
                                    ),
                                    const SizedBox(width: AppConstants.padding2),
                                    const Text(
                                      AppStrings.labelGolden,
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: AppConstants.fontSizeXXS,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Details section
                      Padding(
                        padding:
                            const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: AppConstants.fontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate800,
                              ),
                            ),
                            const SizedBox(height: AppConstants.padding6),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcons.boostRocketSvg,
                                  width: AppConstants.iconSizeSM,
                                  height: AppConstants.iconSizeSM,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.slate400,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.padding4),
                                Flexible(
                                  child: Text(
                                    item.category.isNotEmpty
                                        ? item.category
                                        : 'Marketplace',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppConstants.paddingSmall),
                                SvgPicture.asset(
                                  AppIcons.locationSvg,
                                  width: AppConstants.iconSizeSM,
                                  height: AppConstants.iconSizeSM,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.slate400,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.padding4),
                                Flexible(
                                  child: Text(
                                    item.location.isNotEmpty
                                        ? item.location
                                        : 'Spain',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      AppIcons.starFavoriteSvg,
                                      width: AppConstants.iconSizeSM,
                                      height: AppConstants.iconSizeSM,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.accentYellow,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: AppConstants.padding2),
                                    Text(
                                      item.sellerRating > 0
                                          ? '${item.sellerRating.toStringAsFixed(1)} (${item.sellerReviewCount})'
                                          : '4.8 (36)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  formattedPrice,
                                  style: const TextStyle(
                                    fontSize: AppConstants.fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Text(
                              tagText,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.padding10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            displayList.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: activeIndex == index
                  ? AppConstants.borderRadius24
                  : AppConstants.borderRadius8,
              height: AppConstants.borderRadius8,
              decoration: BoxDecoration(
                color: activeIndex == index
                    ? AppColors.accentYellow
                    : AppColors.slate300,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusExtraSmall,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: AppConstants.featuredListingImageHeight,
      color: AppColors.slate200,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppIcons.gallerySvg,
        width: AppConstants.iconSizeLarge,
        height: AppConstants.iconSizeLarge,
        colorFilter: const ColorFilter.mode(
          AppColors.systemGray,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
