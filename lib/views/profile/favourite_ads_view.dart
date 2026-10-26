import 'package:desilynks/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/viewmodels/profile/favourite_ads_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/models/marketplace_item_model.dart';
import 'package:desilynks/models/job_model.dart';
import 'package:desilynks/viewmodels/marketplace/marketplace_viewmodel.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';

class FavouriteAdsView extends StatelessWidget {
  const FavouriteAdsView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final viewModel = Provider.of<FavouriteAdsViewModel>(context, listen: false);
      if (!viewModel.hasFetched && !viewModel.isLoading) {
        viewModel.fetchFavourites();
      }
    });

    final viewModel = Provider.of<FavouriteAdsViewModel>(context);
    final filteredList = viewModel.filteredItems;
    final int totalSavedCount = viewModel.favouritedIds.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 12),
          icon: SvgPicture.asset(AppIcons.arrowBackBasicSvg),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 8,
        title: Text(
          'Favourite Ads',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: context.sp(17),
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '$totalSavedCount Saved',
                style: TextStyle(
                  color: AppColors.gray400,
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.slate200, height: 1.0),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Horizontal Category Chips
              _buildCategoryFilters(context, viewModel),

              // 2. Saved Items List
              Expanded(
                child: viewModel.isLoading && viewModel.savedItems.isEmpty
                    ? const ListSkeleton(showTabs: false)
                    : RefreshIndicator(
                        onRefresh: viewModel.fetchFavourites,
                        color: AppColors.gradientStart,
                        child: filteredList.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: (context.heightPct(
                                    0.55,
                                  )).clamp(280.0, 520.0),
                                  child: _buildEmptyState(context),
                                ),
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.hMargin,
                                  vertical: (context.scaleH(
                                    8,
                                  )).clamp(6.0, 12.0),
                                ),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final item = filteredList[index];
                                  return _buildAdCard(context, item, viewModel);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(
    BuildContext context,
    FavouriteAdsViewModel viewModel,
  ) {
    final categories = ['All', 'Jobs', 'Rooms', 'Ads', 'Workers'];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: (context.scaleH(12)).clamp(8.0, 14.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.hMargin),
        child: Row(
          children: categories.map((category) {
            final bool isActive = viewModel.selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  viewModel.setCategory(category);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (context.scale(9)).clamp(8.0, 12.0),
                    vertical: (context.scaleH(5)).clamp(4.0, 7.0),
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.gradientStart : Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge + 2,
                    ),
                    border: isActive
                        ? null
                        : Border.all(
                            color: const Color(
                              0xFF000000,
                            ).withValues(alpha: 0.16),
                            width: 1,
                          ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.gray700,
                      fontSize: context.sp(14),
                      fontFamily: "Inter",
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAdCard(
    BuildContext context,
    Map<String, dynamic> item,
    FavouriteAdsViewModel viewModel,
  ) {
    final String category = item['category'];
    Color tagBgColor;
    Color tagTextColor;

    switch (category) {
      case 'Room':
      case 'Apartment':
      case 'House':
      case 'Studio':
        tagBgColor = AppColors.lightOrange;
        tagTextColor = AppColors.orangeAccent;
        break;
      case 'Job':
        tagBgColor = AppColors.lightBlue;
        tagTextColor = AppColors.primaryBlue;
        break;
      case 'Ads':
        tagBgColor = AppColors.lightPurple;
        tagTextColor = AppColors.primaryPurple;
        break;
      case 'Worker':
        tagBgColor = AppColors.softGreen;
        tagTextColor = AppColors.emerald;
        break;
      default:
        tagBgColor = AppColors.slate100;
        tagTextColor = AppColors.slate500;
    }

    final bool isWorker = category == 'Worker';
    final double imgSize = (context.scale(72)).clamp(64.0, 80.0);
    final double favBtnSize = (context.scale(36)).clamp(32.0, 40.0);

    return GestureDetector(
      onTap: () {
        if (category == 'Room' ||
            category == 'Apartment' ||
            category == 'House' ||
            category == 'Studio') {
          final property = item['propertyModel'] as PropertyModel?;
          if (property != null) {
            Navigator.pushNamed(
              context,
              AppRoutes.roomSingleDetails,
              arguments: property,
            );
          }
        } else if (category == 'Ads' || item['productModel'] != null) {
          final product = item['productModel'] as MarketplaceItemModel?;
          if (product != null) {
            Navigator.pushNamed(
              context,
              AppRoutes.marketplaceDetail,
              arguments: product,
            );
          }
        } else if (category == 'Job' || item['jobModel'] != null) {
          final job = item['jobModel'] as JobModel?;
          if (job != null) {
            Navigator.pushNamed(
              context,
              AppRoutes.jobDetail,
              arguments: job,
            );
          } else {
            Navigator.pushNamed(
              context,
              AppRoutes.jobDetail,
              arguments: item['id'],
            );
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: (context.scaleH(12)).clamp(8.0, 14.0)),
        padding: EdgeInsets.all(context.cardPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200, width: 1.0),
        ),
        child: Row(
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['imageUrl'],
                width: imgSize,
                height: imgSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: imgSize,
                  height: imgSize,
                  color: AppColors.slate100,
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.galleryRoundSvg,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate400,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: (context.scale(14)).clamp(10.0, 16.0)),

            // Details column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tagBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: tagTextColor,
                        fontSize: context.sp(10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: (context.scaleH(6)).clamp(4.0, 8.0)),

                  // Title
                  Text(
                    item['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: (context.scaleH(4)).clamp(2.0, 6.0)),

                  // Location
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.locationSvg,
                        width: 12,
                        height: 12,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate400,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['location'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: (context.scaleH(4)).clamp(2.0, 6.0)),

                  // Bottom row: Price or Rating/Rate
                  if (isWorker)
                    Row(
                      children: [
                        SvgPicture.asset(AppIcons.favSvg),
                        const SizedBox(width: 4),
                        Text(
                          item['rating'],
                          style: TextStyle(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '·',
                          style: TextStyle(
                            color: AppColors.slate400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item['rate'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: context.sp(12),
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray400,
                              fontFamily: "Inter",
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      item['price'],
                      style: TextStyle(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w600,
                        color: AppColors.gradientStart,
                      ),
                    ),
                ],
              ),
            ),

            // Trailing Heart Button
            InkWell(
              onTap: () {
                final String itemId = item['id'];
                viewModel.toggleFavourite(itemId);
                Provider.of<PostRoomViewModel>(
                  context,
                  listen: false,
                ).syncLikedStatus(itemId, false);
                try {
                  Provider.of<JobsViewModel>(
                    context,
                    listen: false,
                  ).syncBookmarkStatus(itemId, false);
                } catch (_) {}
                try {
                  Provider.of<MarketplaceViewModel>(
                    context,
                    listen: false,
                  ).unsaveAd(itemId);
                } catch (_) {}
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed "${item['title']}" from Favourites'),
                    action: SnackBarAction(
                       label: 'Undo',
                      textColor: AppColors.accentYellow,
                      onPressed: () {
                        viewModel.toggleFavourite(itemId);
                        Provider.of<PostRoomViewModel>(
                          context,
                          listen: false,
                        ).syncLikedStatus(itemId, true);
                        try {
                          Provider.of<JobsViewModel>(
                            context,
                            listen: false,
                          ).syncBookmarkStatus(itemId, true);
                        } catch (_) {}
                        try {
                          Provider.of<MarketplaceViewModel>(
                            context,
                            listen: false,
                          ).saveAd(itemId);
                        } catch (_) {}
                      },
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: favBtnSize,
                height: favBtnSize,
                decoration: BoxDecoration(
                  color: AppColors.redLight100,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusExtraSmall,
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.assetFav,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryRed,
                      BlendMode.srcIn,
                    ),
                    height: (context.scale(20)).clamp(16.0, 22.0),
                    width: (context.scale(20)).clamp(16.0, 22.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.softRed,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.favSvg,
                  height: 48,
                  width: 48,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryRed,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Saved Favourites',
              style: TextStyle(
                fontSize: context.sp(16),
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go explore listings and tap the heart icon to save them here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.sp(13),
                color: AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
