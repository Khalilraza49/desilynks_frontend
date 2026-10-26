import 'dart:io';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/models/marketplace_item_model.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/viewmodels/marketplace/marketplace_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/widgets/login_required_dialog.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/profile/favourite_ads_viewmodel.dart';

class MarketplaceView extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const MarketplaceView({super.key, this.onMenuPressed});

  static const List<String> _categories = [
    'All',
    'Phones',
    'Cars',
    'Electronics',
    'Furniture',
    'Clothes',
    'Books',
    'Kids',
    'Other',
    'Services',
  ];

  void _navigateToFilters(BuildContext context, String userLocation) async {
    final roomViewModel = Provider.of<PostRoomViewModel>(
      context,
      listen: false,
    );
    final marketViewModel = Provider.of<MarketplaceViewModel>(
      context,
      listen: false,
    );

    roomViewModel.enterFiltersScreen(
      initialCategory: 'Marketplace',
      defaultLocation: marketViewModel.locationFilter.isNotEmpty
          ? marketViewModel.locationFilter
          : userLocation,
    );
    final result = await Navigator.pushNamed(context, AppRoutes.filters);
    if (!context.mounted) return;

    if (result == true || roomViewModel.isFilterApplied) {
      marketViewModel.setShowAllLocations(false);
      marketViewModel.updateFilters(
        category: roomViewModel.appliedCategory,
        location: roomViewModel.appliedLocation,
        maxPrice: roomViewModel.appliedMaxPrice,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final vm = Provider.of<MarketplaceViewModel>(context, listen: false);
      if (!vm.hasFetched && !vm.isLoading) {
        vm.fetchPublicProducts();
      }
    });

    final viewModel = Provider.of<MarketplaceViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.currentUser;
    final userLocation = viewModel.getUserLocation(user);
    final userCity = viewModel.getUserCity(user);

    List<MarketplaceItemModel> filteredItems = viewModel.filteredItems;

    // Filter by location:
    // If filter is explicitly applied in viewModel, filteredItems already matches viewModel.locationFilter.
    // Otherwise, filter by user city/location unless user toggled "View all locations".
    if (viewModel.locationFilter.trim().isNotEmpty) {
      final locQ = viewModel.locationFilter.trim().toLowerCase();
      filteredItems = filteredItems
          .where((i) => i.location.toLowerCase().contains(locQ))
          .toList();
    } else if (!viewModel.showAllLocations && userCity.isNotEmpty) {
      final cityQ = userCity.toLowerCase();
      filteredItems = filteredItems
          .where((i) => i.location.toLowerCase().contains(cityQ))
          .toList();
    }

    final String displayLocation = viewModel.locationFilter.trim().isNotEmpty
        ? viewModel.locationFilter
        : (viewModel.showAllLocations ? 'All Locations' : userLocation);

    final bool isFilterActive =
        viewModel.locationFilter.isNotEmpty ||
        (viewModel.selectedCategory != 'All') ||
        viewModel.maxPrice < 1000.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackBasicSvg,
            height: context.scaleH(24).clamp(20.0, 28.0),
            width: context.scale(24).clamp(20.0, 28.0),
            colorFilter: ColorFilter.mode(
              Colors.grey.shade500,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            Provider.of<NavigationViewModel>(
              context,
              listen: false,
            ).setIndex(0);
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Marketplace',
              style: TextStyle(
                color: AppColors.slate900,
                fontSize: context.sp(20),
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => _navigateToFilters(context, userLocation),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppIcons.locationSvg,
                    height: context.scaleH(16).clamp(13.0, 20.0),
                    width: context.scale(16).clamp(13.0, 20.0),
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate400,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      displayLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.slate500,
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _CircleIconButton(
            icon: AppIcons.filterSvg,
            backgroundColor: isFilterActive
                ? AppColors.vibrantBlue.withValues(alpha: 0.12)
                : const Color(0xFFE5E7EB),
            iconColor: isFilterActive
                ? AppColors.vibrantBlue
                : AppColors.slate800,
            iconSize: 18,
            onTap: () => _navigateToFilters(context, userLocation),
          ),
          const SizedBox(width: 10),
          _CircleIconButton(
            icon: AppIcons.plusSvg,
            backgroundColor: AppColors.vibrantBlue,
            iconColor: Colors.white,
            iconSize: 20,
            onTap: () {
              final authVM = Provider.of<AuthViewModel>(context, listen: false);
              if (!authVM.isAuthenticated) {
                LoginRequiredDialog.show(context);
                return;
              }
              Navigator.pushNamed(context, AppRoutes.postProduct);
            },
          ),
          SizedBox(width: context.hMargin > 16 ? context.hMargin - 4 : 12),
        ],
      ),
      body: SafeArea(
        child: (viewModel.isLoading && viewModel.items.isEmpty)
            ? const MarketplaceSkeleton()
            : Column(
                children: [
                  const SizedBox(height: 8),

                  // 1. Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.hMargin,
                      vertical: 6,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        final navVM = Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        );
                        if (navVM.isMarketplaceActive) {
                          navVM.openSearch();
                        } else {
                          Navigator.pushNamed(context, AppRoutes.search);
                        }
                      },
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: viewModel.marketplaceSearchController,
                          hintText: 'Search Items....',
                          fillColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFF1F5F9),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFF1F5F9),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.vibrantBlue,
                              width: 1.5,
                            ),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                              AppIcons.searchSvg,
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate500,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 2. Horizontal Category Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.hMargin,
                      vertical: 6,
                    ),
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = viewModel.selectedCategory == cat;
                        return Padding(
                          padding: EdgeInsets.only(
                            right: (context.scale(10.0)).clamp(6.0, 12.0),
                          ),
                          child: GestureDetector(
                            onTap: () => viewModel.setSelectedCategory(cat),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: (context.scale(
                                  20.0,
                                )).clamp(14.0, 24.0),
                                vertical: (context.scaleH(
                                  9.0,
                                )).clamp(7.0, 12.0),
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF334155),
                                  fontSize: context.sp(14),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Active location filter chip bar
                  if (viewModel.locationFilter.isNotEmpty ||
                      (!viewModel.showAllLocations && userCity.isNotEmpty))
                    Padding(
                      padding: EdgeInsets.only(
                        left: context.hMargin,
                        right: context.hMargin,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  AppIcons.locationSvg,
                                  width: 10,
                                  height: 10,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.vibrantBlue,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  displayLocation,
                                  style: const TextStyle(
                                    fontSize: AppConstants.fontSizeXS11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.vibrantBlue,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    viewModel.setShowAllLocations(true);
                                    if (viewModel.locationFilter.isNotEmpty) {
                                      viewModel.updateFilters(location: '');
                                    }
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppColors.slate400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (viewModel.showAllLocations)
                            TextButton(
                              onPressed: () {
                                viewModel.setShowAllLocations(false);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Show nearby only',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeXS11,
                                  color: AppColors.vibrantBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: () {
                                viewModel.setShowAllLocations(true);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'View all locations',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeXS11,
                                  color: AppColors.slate500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // 3. Marketplace Cards List with Pull-To-Refresh
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.vibrantBlue,
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        await viewModel.refreshData();
                      },
                      child: filteredItems.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      AppIcons.shopingSvg,
                                      width: 48,
                                      height: 48,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.slate300,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No items available in $displayLocation',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.slate600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Try adjusting your filters or browse all locations.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.slate400,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        viewModel.setShowAllLocations(true);
                                        if (viewModel
                                            .locationFilter
                                            .isNotEmpty) {
                                          viewModel.updateFilters(location: '');
                                        }
                                      },
                                      icon: SvgPicture.asset(
                                        AppIcons.restartSvg,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      label: const Text('View All Locations'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(10),
                                        backgroundColor: AppColors.vibrantBlue,
                                        foregroundColor: AppColors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        final authVM =
                                            Provider.of<AuthViewModel>(
                                              context,
                                              listen: false,
                                            );
                                        if (!authVM.isAuthenticated) {
                                          LoginRequiredDialog.show(context);
                                          return;
                                        }
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.postProduct,
                                        );
                                      },
                                      icon: SvgPicture.asset(
                                        AppIcons.plusSvg,
                                        width: 14,
                                        height: 14,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.vibrantBlue,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      label: const Text('Sell an Item'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.vibrantBlue,
                                        side: const BorderSide(
                                          color: AppColors.vibrantBlue,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.hMargin,
                                vertical: 8,
                              ),
                              itemCount: filteredItems.length,
                              separatorBuilder: (_, index) => SizedBox(
                                height: (context.scaleH(
                                  14.0,
                                )).clamp(10.0, 18.0),
                              ),
                              itemBuilder: (context, index) {
                                return MarketplaceCard(
                                  item: filteredItems[index],
                                  userLocation: userLocation,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final String icon;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          icon,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const _BadgePill({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 9.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MarketplaceCard extends StatelessWidget {
  final MarketplaceItemModel item;
  final String userLocation;

  const MarketplaceCard({
    super.key,
    required this.item,
    this.userLocation = 'Barcelona, Spain',
  });

  @override
  Widget build(BuildContext context) {
    final favViewModel = Provider.of<FavouriteAdsViewModel>(context);
    final marketViewModel = Provider.of<MarketplaceViewModel>(
      context,
      listen: false,
    );

    final bool isLiked =
        favViewModel.isFavourited(item.id) ||
        marketViewModel.isPropertyLiked(item.id);

    final bool isGolden = item.isGolden;

    final Color badgeBgColor = isGolden
        ? const Color(0xFFFBBF24)
        : AppColors.vibrantBlue;

    final double imageHeight = context.scaleH(180).clamp(160.0, 220.0);

    // Resolved photo list
    final photos = item.photos.isNotEmpty
        ? item.photos.map((p) => p.url).toList()
        : (item.photoUrls.isNotEmpty
              ? item.photoUrls
              : (item.imageUrl.isNotEmpty ? [item.imageUrl] : <String>[]));

    final String displayImage = photos.isNotEmpty
        ? photos.first
        : item.imageUrl;
    final int totalPhotos = photos.length;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.marketplaceDetail,
          arguments: item,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: context.scaleH(16).clamp(12.0, 20.0)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Stack Header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: _buildCardImage(displayImage),
                  ),
                ),

                // Top-Left Favorite Button
                Positioned(
                  left: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: () async {
                      final newStatus = await marketViewModel.toggleSaveAd(
                        item.id,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            newStatus
                                ? 'Added to Favourite Ads'
                                : 'Removed from Favourite Ads',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.favSvg,
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                          isLiked ? AppColors.primaryRed : AppColors.slate400,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),

                // Top-Right Price Tag
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      item.price,
                      style: TextStyle(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                ),

                // Bottom-Left Badge (e.g. Premium / Golden)
                if (item.badgeType.isNotEmpty)
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _BadgePill(
                      label: item.badgeType,
                      backgroundColor: badgeBgColor,
                      textColor: Colors.white,
                      fontSize: context.sp(10.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    ),
                  ),

                // Bottom-Right Photo Counter ("1/5" or "5 Photos")
                if (totalPhotos > 1)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppIcons.gallerySvg,
                            width: 12,
                            height: 12,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalPhotos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 2. Card Content Below
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Location Row
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.locationSvg,
                        height: 14,
                        width: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate400,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location.trim().isNotEmpty
                              ? item.location
                              : userLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.sp(12.5),
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Category & Condition Tags
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: context.sp(11.5),
                            color: AppColors.slate600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (item.condition != null &&
                          item.condition!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _BadgePill(
                          label: item.condition!,
                          backgroundColor: const Color(0xFFDCFCE7),
                          textColor: const Color(0xFF15803D),
                          fontSize: context.sp(11),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                        ),
                      ],
                      if (item.isNegotiable) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Negotiable',
                          style: TextStyle(
                            fontSize: context.sp(11),
                            color: AppColors.slate400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderImage(),
      );
    } else if (imageUrl.startsWith('/uploads/')) {
      return Image.network(
        '${ApiEndpoints.baseUrl}$imageUrl',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderImage(),
      );
    } else if (imageUrl.isNotEmpty && File(imageUrl).existsSync()) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderImage(),
      );
    } else {
      return _placeholderImage();
    }
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.slate100,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppIcons.shopingSvg,
        height: 24,
        width: 24,
        colorFilter: const ColorFilter.mode(
          AppColors.slate400,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
