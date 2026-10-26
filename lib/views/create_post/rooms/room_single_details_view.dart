import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/favourite_ads_viewmodel.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/utils/app_share_helper.dart';

class RoomSingleDetailsView extends StatelessWidget {
  final PropertyModel property;

  const RoomSingleDetailsView({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PostRoomViewModel>(context);
    final favViewModel = Provider.of<FavouriteAdsViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (viewModel.activeSingleProperty?.id != property.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        viewModel.initSingleRoomDetails(property, authViewModel);
      });
    }

    // Check local post_room_viewmodel for live updates to like status
    final indexInPublic = viewModel.publicProperties.indexWhere(
      (p) => p.id == property.id,
    );
    final PropertyModel fallbackProperty =
        viewModel.activeSingleProperty?.id == property.id
            ? viewModel.activeSingleProperty!
            : property;
    final PropertyModel activeProperty = indexInPublic != -1
        ? viewModel.publicProperties[indexInPublic]
        : fallbackProperty;

    final bool isLiked =
        favViewModel.isFavourited(activeProperty.id) ||
        viewModel.isPropertyLiked(activeProperty.id);

    final PropertyOwner? activeOwner = viewModel.resolveActiveOwner(
      activeProperty,
      authViewModel.currentUser,
    );

    final bool hasOwnerDetails =
        activeOwner != null &&
        activeOwner.fullName.trim().isNotEmpty &&
        activeOwner.fullName.trim() != 'User' &&
        activeOwner.fullName.trim() != 'User Name';

    final photos = activeProperty.propertyPhotos;
    final totalPhotos = photos.isNotEmpty ? photos.length : 1;
    final currentPage = viewModel.singlePropertyPageIndex;

    // Format post date
    final String postTimeAgo = viewModel.getTimeAgo(activeProperty.createdAt);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Slider Carousel with PageView
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: photos.isNotEmpty
                      ? PageView.builder(
                          controller: viewModel.singlePropertyPageController,
                          onPageChanged: (int page) {
                            viewModel.setSinglePropertyPageIndex(page);
                          },
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            final imageUrl = viewModel.resolvePropertyImageUrl(
                              photos[index].url,
                              fallback:
                                  'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
                            );
                            return GestureDetector(
                              onTap: () => _openFullScreenImageViewer(
                                context,
                                photos,
                                index,
                                viewModel,
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: AppColors.slate100,
                                  child: SvgPicture.asset(
                                    AppIcons.gallerySvg,
                                    width: 60,
                                    height: 60,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.gray500,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.slate100,
                          child: SvgPicture.asset(
                            AppIcons.gallerySvg,
                            width: 60,
                            height: 60,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gray500,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                ),

                // Back Button (Top Left)
                Positioned(
                  left: 20,
                  top: MediaQuery.of(context).padding.top + 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.arrowBackSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),

                // Top Right Action Buttons (Heart and Share)
                Positioned(
                  right: 20,
                  top: MediaQuery.of(context).padding.top + 10,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final newStatus =
                              await viewModel.toggleSinglePropertyLike(
                            activeProperty,
                            favViewModel,
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
                              action: newStatus
                                  ? SnackBarAction(
                                      label: 'View',
                                      textColor: AppColors.accentYellow,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.favouriteAds,
                                        );
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.favSvg,
                            colorFilter: ColorFilter.mode(
                              isLiked
                                  ? AppColors.primaryRed
                                  : AppColors.white,
                              BlendMode.srcIn,
                            ),
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Share Button
                      GestureDetector(
                        onTap: () {
                          AppShareHelper.shareAsLink(
                            context: context,
                            type: ShareItemType.room,
                            id: activeProperty.id,
                            title: activeProperty.title,
                            subtitle:
                                '${activeProperty.location} · €${activeProperty.monthlyRent}/month',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.shareSvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Blue Tag Overlay (Bottom Left): "Posted X hours ago"
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vibrantBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      postTimeAgo,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: AppConstants.fontSizeSM,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Photo Counter Overlay (Bottom Right): "1/6"
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => _openFullScreenImageViewer(
                      context,
                      photos,
                      currentPage,
                      viewModel,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${currentPage + 1}/$totalPhotos',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: AppConstants.fontSizeXS11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Title, Price, Views & Location Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    activeProperty.title,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price Row and Views
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '€ ${double.tryParse(activeProperty.monthlyRent)?.toStringAsFixed(0) ?? activeProperty.monthlyRent}',
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeHeading,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '/ month',
                            style: TextStyle(
                              fontSize: AppConstants.fontSize,
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.eyeSvg,
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate500,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${activeProperty.viewsCount} views',
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeMD,
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Location Row
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.locationSvg,
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryRed,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activeProperty.location.trim().isNotEmpty
                              ? activeProperty.location
                              : 'Location not specified',
                          style: const TextStyle(
                            fontSize: AppConstants.fontSizeMD,
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Grid of Main Specs (Property Type, Guests, Bathrooms, Wifi)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate100, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildGridItem(
                            svgAsset: AppIcons.bedSvg,
                            iconColor: AppColors.vibrantBlue,
                            bgColor: AppColors.lightBlue,
                            title: activeProperty.type.toLowerCase() == 'room'
                                ? 'Room'
                                : activeProperty.type,
                            subtitle: 'Private Room',
                          ),
                        ),
                        Expanded(
                          child: _buildGridItem(
                            svgAsset: AppIcons.guestSvg,
                            iconColor: AppColors.emerald,
                            bgColor: AppColors.softGreen,
                            title: '${activeProperty.noOfBedRooms} Guests',
                            subtitle: '${activeProperty.noOfBedRooms} Bedrooms',
                          ),
                        ),
                        Expanded(
                          child: _buildGridItem(
                            svgAsset: AppIcons.bathTubSvg,
                            iconColor: AppColors.amberOrange,
                            bgColor: AppColors.lightYellow,
                            title: '${activeProperty.noOfBathRooms} Bathroom',
                            subtitle:
                                '${activeProperty.noOfBathRooms} Bathroom',
                          ),
                        ),
                        Expanded(
                          child: _buildGridItem(
                            svgAsset: AppIcons.wifiSvg,
                            iconColor: AppColors.orangeAccent,
                            bgColor: AppColors.lightOrange,
                            title: 'WiFi',
                            subtitle: viewModel.hasWifi(activeProperty)
                                ? 'Available'
                                : 'Unavailable',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Additional Amenities Pill Tags
                  if (activeProperty.featuresAndAmenities.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.slate100,
                          width: 1.5,
                        ),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: activeProperty.featuresAndAmenities.map((
                          amenity,
                        ) {
                          return _buildAmenityPill(amenity);
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 5. About Room Description Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate100, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Room',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeXL,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeProperty.description,
                          style: const TextStyle(
                            fontSize: AppConstants.fontSize,
                            height: 1.5,
                            color: AppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 6. Owner Profile Section Card
                  GestureDetector(
                    onTap: () {
                      final PropertyOwner owner = hasOwnerDetails
                          ? activeOwner
                          : PropertyOwner(
                                  id: activeProperty.ownerId,
                                  firstName: '',
                                  lastName: '',
                                  profilePhotoUrl: null,
                                  createdAt: '',
                                );
                      Navigator.pushNamed(
                        context,
                        AppRoutes.publicProfile,
                        arguments: owner,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.slate100,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar Photo
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.slate100,
                              image: (hasOwnerDetails &&
                                      activeOwner.profilePhotoUrl != null &&
                                      activeOwner
                                          .profilePhotoUrl!.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        viewModel.resolvePropertyImageUrl(
                                          activeOwner.profilePhotoUrl,
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (!hasOwnerDetails ||
                                    activeOwner.profilePhotoUrl == null ||
                                    activeOwner.profilePhotoUrl!.isEmpty)
                                ? Center(
                                    child: SvgPicture.asset(
                                      AppIcons.personSvg,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.slate400,
                                        BlendMode.srcIn,
                                      ),
                                      height: 28,
                                      width: 28,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),

                          // Owner Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasOwnerDetails
                                      ? activeOwner.fullName.trim()
                                      : 'User Name',
                                  style: const TextStyle(
                                    fontSize: AppConstants.fontSizeLG,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hasOwnerDetails
                                      ? (activeOwner.createdAt.isNotEmpty ==
                                              true
                                          ? 'Member since ${viewModel.getMemberYear(activeOwner.createdAt)}'
                                          : 'Member since ${viewModel.getMemberYear(activeProperty.createdAt.toIso8601String())}')
                                      : 'No History found',
                                  style: const TextStyle(
                                    fontSize: AppConstants.fontSizeSM,
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Chevron Action
                          SvgPicture.asset(
                            AppIcons.arrowForwardSvg,
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate400,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required String svgAsset,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: SvgPicture.asset(
            svgAsset,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeXS11,
            fontWeight: FontWeight.bold,
            color: AppColors.slate800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeXXS,
            color: AppColors.slate500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAmenityPill(String amenity) {
    String svgAsset = AppIcons.tickSvg;
    Color bgColor = AppColors.slate100;
    Color textColor = AppColors.slate500;

    if (amenity.toLowerCase().contains('wifi')) {
      svgAsset = AppIcons.wifiSvg;
      bgColor = AppColors.lightYellow;
      textColor = AppColors.amberOrange;
    } else if (amenity.toLowerCase().contains('heating')) {
      svgAsset = AppIcons.hotSvg;
      bgColor = AppColors.lightOrange;
      textColor = AppColors.orangeAccent;
    } else if (amenity.toLowerCase().contains('wash')) {
      svgAsset = AppIcons.washingMachineSvg;
      bgColor = AppColors.lightGreen;
      textColor = AppColors.successGreen;
    } else if (amenity.toLowerCase().contains('furnish')) {
      svgAsset = AppIcons.furnishedSvg;
      bgColor = AppColors.lightPurple;
      textColor = AppColors.primaryPurple;
    } else if (amenity.toLowerCase().contains('pet')) {
      svgAsset = AppIcons.petsSvg;
      bgColor = AppColors.softRed;
      textColor = AppColors.primaryRed;
    } else if (amenity.toLowerCase().contains('ac') ||
        amenity.toLowerCase().contains('a/c')) {
      svgAsset = AppIcons.acSvg;
      bgColor = AppColors.lightBlue;
      textColor = AppColors.cyan;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgAsset,
            width: 12,
            height: 12,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 4),
          Text(
            amenity,
            style: TextStyle(
              fontSize: AppConstants.fontSizeXS11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreenImageViewer(
    BuildContext context,
    List<PropertyPhoto> photos,
    int initialIndex,
    PostRoomViewModel viewModel,
  ) {
    if (photos.isEmpty) return;

    final pageController = PageController(initialPage: initialIndex);
    final ValueNotifier<int> currentIndexNotifier =
        ValueNotifier<int>(initialIndex);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Zoomable & Swipeable PageView
              PageView.builder(
                controller: pageController,
                itemCount: photos.length,
                onPageChanged: (idx) {
                  currentIndexNotifier.value = idx;
                  viewModel.setSinglePropertyPageIndex(idx);
                  if (viewModel.singlePropertyPageController.hasClients) {
                    viewModel.singlePropertyPageController.jumpToPage(idx);
                  }
                },
                itemBuilder: (context, idx) {
                  final imageUrl = viewModel.resolvePropertyImageUrl(
                    photos[idx].url,
                    fallback:
                        'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
                  );
                  return InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.slate900,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Top Bar with Back Button and Counter Badge
              Positioned(
                top: MediaQuery.of(ctx).padding.top + 10,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          AppIcons.arrowBackSvg,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    if (photos.length > 1)
                      ValueListenableBuilder<int>(
                        valueListenable: currentIndexNotifier,
                        builder: (ctx, currentIdx, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${currentIdx + 1} / ${photos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
