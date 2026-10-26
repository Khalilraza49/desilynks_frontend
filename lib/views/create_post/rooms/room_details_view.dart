import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/favourite_ads_viewmodel.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class RoomDetailsView extends StatelessWidget {
  const RoomDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PostRoomViewModel>(context);
    if (!viewModel.hasFetchedPublic && !viewModel.isLoadingPublic) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        viewModel.fetchPublicProperties(force: true);
      });
    }
    final authViewModel = Provider.of<AuthViewModel>(context);
    final favViewModel = Provider.of<FavouriteAdsViewModel>(context);
    final user = authViewModel.currentUser;
    final userLocation = viewModel.getUserLocation(user);

    final List<PropertyModel> rooms =
        viewModel.filteredPublicPropertiesForRoomDetails;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.hMargin,
                    vertical: context.scaleH(10.0).clamp(8.0, 14.0),
                  ),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Provider.of<NavigationViewModel>(
                              context,
                              listen: false,
                            ).setIndex(0);
                          }
                        },
                        child: SvgPicture.asset(
                          AppIcons.arrowBackBasicSvg,
                          height: context.scale(24).clamp(20.0, 28.0),
                          width: context.scale(24).clamp(20.0, 28.0),
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate800,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(width: context.scale(14).clamp(10.0, 16.0)),
                      // Title and Location Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Room Details',
                              style: TextStyle(
                                fontSize: context.sp(20).clamp(18.0, 24.0),
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcons.locationSvg,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.slate400,
                                    BlendMode.srcIn,
                                  ),
                                  height: context.scale(14).clamp(12.0, 16.0),
                                  width: context.scale(14).clamp(12.0, 16.0),
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    userLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize:
                                          context.sp(12).clamp(11.0, 14.0),
                                      color: AppColors.slate500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: context.scale(8).clamp(6.0, 12.0)),
                      // Plus Button (Blue circle with white plus)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.postRoom);
                        },
                        child: Container(
                          width: context.scale(38).clamp(34.0, 44.0),
                          height: context.scale(38).clamp(34.0, 44.0),
                          decoration: const BoxDecoration(
                            color: AppColors.vibrantBlue,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            AppIcons.plusSvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                            height: context.scale(16).clamp(14.0, 20.0),
                            width: context.scale(16).clamp(14.0, 20.0),
                          ),
                        ),
                      ),
                      SizedBox(width: context.scale(10).clamp(8.0, 12.0)),
                      // Filter Tune Button (Light grey circle with tune sliders icon)
                      GestureDetector(
                        onTap: () {
                          viewModel.enterFiltersScreen(
                            initialCategory: 'Rooms',
                            defaultLocation: userLocation,
                          );
                          Navigator.pushNamed(context, AppRoutes.filters);
                        },
                        child: Container(
                          width: context.scale(38).clamp(34.0, 44.0),
                          height: context.scale(38).clamp(34.0, 44.0),
                          decoration: const BoxDecoration(
                            color: AppColors.slate100,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            AppIcons.filterSvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate700,
                              BlendMode.srcIn,
                            ),
                            height: context.scale(18).clamp(15.0, 22.0),
                            width: context.scale(18).clamp(15.0, 22.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Horizontal Filter Capsules
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.scaleH(10.0).clamp(8.0, 14.0),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: context.hMargin),
                    child: Row(
                      children: [
                        _buildFilterCapsule(context, 'All', viewModel),
                        SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                        _buildFilterCapsule(context, 'Private Room', viewModel),
                        SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                        _buildFilterCapsule(context, 'Shared', viewModel),
                        SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                        _buildFilterCapsule(context, 'Studio', viewModel),
                        SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                        _buildFilterCapsule(context, 'Apartment', viewModel),
                      ],
                    ),
                  ),
                ),

                // Rooms List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Provider.of<PostRoomViewModel>(
                        context,
                        listen: false,
                      ).fetchPublicProperties(force: true);
                      if (context.mounted) {
                        await Provider.of<FavouriteAdsViewModel>(
                          context,
                          listen: false,
                        ).fetchFavourites();
                      }
                    },
                    color: AppColors.vibrantBlue,
                    backgroundColor: AppColors.backgroundOffWhite,
                    child: viewModel.isLoadingPublic
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.hMargin,
                              vertical: context.scaleH(6.0).clamp(4.0, 10.0),
                            ),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return _buildSkeletonCard(context);
                            },
                          )
                        : rooms.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: context.screenHeight * 0.55,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      AppIcons.bedSvg,
                                      width:
                                          context.scale(60).clamp(48.0, 72.0),
                                      height:
                                          context.scale(60).clamp(48.0, 72.0),
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.gray300,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          context.scaleH(12).clamp(8.0, 16.0),
                                    ),
                                    Text(
                                      'No rooms available',
                                      style: TextStyle(
                                        fontSize:
                                            context.sp(16).clamp(14.0, 18.0),
                                        color: AppColors.slate600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: context.scaleH(4).clamp(2.0, 6.0),
                                    ),
                                    Text(
                                      'Try clearing filters or check back later.',
                                      style: TextStyle(
                                        fontSize:
                                            context.sp(12).clamp(11.0, 14.0),
                                        color: AppColors.gray400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.hMargin,
                              vertical: context.scaleH(6.0).clamp(4.0, 10.0),
                            ),
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              return _buildRoomCard(
                                context,
                                rooms[index],
                                viewModel,
                                favViewModel,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCapsule(
    BuildContext context,
    String title,
    PostRoomViewModel viewModel,
  ) {
    final bool isSelected =
        viewModel.selectedFilter.toLowerCase() == title.toLowerCase();

    return GestureDetector(
      onTap: () {
        viewModel.setSelectedFilter(title);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.scale(18).clamp(14.0, 22.0),
          vertical: context.scaleH(8).clamp(6.0, 10.0),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gray900 : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.gray900 : AppColors.slate200,
            width: 1.2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.slate700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: context.sp(13).clamp(12.0, 15.0),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    PropertyModel p,
    PostRoomViewModel viewModel,
    FavouriteAdsViewModel favViewModel,
  ) {
    String photoUrl = p.propertyPhotos.isNotEmpty
        ? p.propertyPhotos.first.url
        : 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80';

    if (photoUrl.startsWith('/')) {
      photoUrl = '${ApiEndpoints.baseUrl}$photoUrl';
    }

    final String cleanRent = p.monthlyRent
        .replaceAll('/month', '')
        .replaceAll('/mo', '')
        .trim();
    final double? parsedPrice = double.tryParse(cleanRent);
    final String formattedPrice = parsedPrice != null
        ? parsedPrice.toStringAsFixed(0)
        : cleanRent;

    final List<String> computedAmenities = [
      '${p.noOfBedRooms} Bed',
      '${p.noOfBathRooms} Bath',
    ];
    if (p.billsIncluded) {
      computedAmenities.add('Bills Inc.');
    }
    computedAmenities.addAll(p.featuresAndAmenities);

    final bool isLiked =
        favViewModel.isFavourited(p.id) || viewModel.isPropertyLiked(p.id);

    final double imageHeight = context.scaleH(180).clamp(160.0, 240.0);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.roomSingleDetails, arguments: p);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: context.scaleH(20).clamp(16.0, 24.0)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
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
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Image.network(
                    photoUrl,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        width: double.infinity,
                        color: AppColors.slate100,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          AppIcons.error_imageSvg,
                          width: context.scale(40).clamp(32.0, 48.0),
                          height: context.scale(40).clamp(32.0, 48.0),
                          colorFilter: const ColorFilter.mode(
                            AppColors.gray400,
                            BlendMode.srcIn,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Top-Left Heart Button
                Positioned(
                  left: context.scale(12).clamp(10.0, 16.0),
                  top: context.scale(12).clamp(10.0, 16.0),
                  child: GestureDetector(
                    onTap: () {
                      final bool newStatus = !isLiked;
                      favViewModel.syncPropertyLike(p, newStatus);
                      viewModel.toggleLikeProperty(
                        p,
                        explicitStatus: newStatus,
                        favViewModel: favViewModel,
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.all(context.scale(8).clamp(6.0, 10.0)),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppIcons.favSvg,
                        width: context.scale(18).clamp(16.0, 22.0),
                        height: context.scale(18).clamp(16.0, 22.0),
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
                  right: context.scale(12).clamp(10.0, 16.0),
                  top: context.scale(12).clamp(10.0, 16.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(14).clamp(10.0, 16.0),
                      vertical: context.scaleH(6).clamp(4.0, 8.0),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '€$formattedPrice',
                            style: TextStyle(
                              fontSize: context.sp(13).clamp(12.0, 15.0),
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                            ),
                          ),
                          TextSpan(
                            text: '/mo',
                            style: TextStyle(
                              fontSize: context.sp(11).clamp(10.0, 13.0),
                              color: AppColors.slate500,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Card Content
            Padding(
              padding: EdgeInsets.all(context.cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    style: TextStyle(
                      fontSize: context.sp(18).clamp(16.0, 20.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  SizedBox(height: context.scaleH(4).clamp(2.0, 6.0)),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.locationSvg,
                        width: context.scale(14).clamp(12.0, 16.0),
                        height: context.scale(14).clamp(12.0, 16.0),
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate400,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: context.scale(4).clamp(3.0, 6.0)),
                      Expanded(
                        child: Text(
                          p.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.sp(13).clamp(12.0, 15.0),
                            color: AppColors.slate500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.scaleH(12).clamp(8.0, 16.0)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: computedAmenities
                          .map((amenity) => _buildAmenityTag(context, amenity))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityTag(BuildContext context, String amenity) {
    String svgAsset = AppIcons.starFavoriteSvg;
    Color bgColor = AppColors.slate100;
    Color textColor = AppColors.slate500;

    if (amenity.contains('Bed')) {
      svgAsset = AppIcons.bedSvg;
      bgColor = AppColors.lightBlue;
      textColor = AppColors.primaryBlue;
    } else if (amenity.contains('Bath')) {
      svgAsset = AppIcons.bathtubSvg;
      bgColor = AppColors.softGreen;
      textColor = AppColors.green600;
    } else if (amenity.toLowerCase().contains('wifi')) {
      svgAsset = AppIcons.wifiSvg;
      bgColor = AppColors.amber100;
      textColor = AppColors.amber700;
    } else if (amenity.toLowerCase().contains('furnish')) {
      svgAsset = AppIcons.furnishedSvg;
      bgColor = AppColors.purpleBg;
      textColor = AppColors.purple700;
    } else if (amenity.toLowerCase().contains('heating')) {
      svgAsset = AppIcons.hotSvg;
      bgColor = AppColors.lightOrange;
      textColor = AppColors.orangeAccent;
    } else if (amenity.toLowerCase().contains('a/c') ||
        amenity.toLowerCase().contains('ac')) {
      svgAsset = AppIcons.acSvg;
      bgColor = AppColors.lightBlue;
      textColor = AppColors.cyan;
    } else if (amenity.toLowerCase().contains('wash')) {
      svgAsset = AppIcons.washingMachineSvg;
      bgColor = AppColors.lightGreen;
      textColor = AppColors.successGreen;
    } else if (amenity.toLowerCase().contains('pet')) {
      svgAsset = AppIcons.petsSvg;
      bgColor = AppColors.softRed;
      textColor = AppColors.primaryRed;
    }

    return Container(
      margin: EdgeInsets.only(right: context.scale(8).clamp(6.0, 10.0)),
      padding: EdgeInsets.symmetric(
        horizontal: context.scale(10).clamp(8.0, 12.0),
        vertical: context.scaleH(6).clamp(4.0, 8.0),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgAsset,
            width: context.scale(13).clamp(11.0, 15.0),
            height: context.scale(13).clamp(11.0, 15.0),
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
          SizedBox(width: context.scale(4).clamp(3.0, 6.0)),
          Text(
            amenity,
            style: TextStyle(
              fontSize: context.sp(11).clamp(10.0, 13.0),
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    final double imageHeight = context.scaleH(180).clamp(160.0, 240.0);
    return Container(
      margin: EdgeInsets.only(bottom: context.scaleH(20).clamp(16.0, 24.0)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.scale(220).clamp(160.0, 260.0),
                  height: context.scaleH(18).clamp(16.0, 20.0),
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(height: context.scaleH(10).clamp(8.0, 12.0)),
                Container(
                  width: context.scale(140).clamp(100.0, 180.0),
                  height: context.scaleH(12).clamp(10.0, 14.0),
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: context.scaleH(16).clamp(12.0, 20.0)),
                Row(
                  children: [
                    Container(
                      width: context.scale(65).clamp(50.0, 80.0),
                      height: context.scaleH(24).clamp(20.0, 28.0),
                      decoration: BoxDecoration(
                        color: AppColors.slate200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                    Container(
                      width: context.scale(65).clamp(50.0, 80.0),
                      height: context.scaleH(24).clamp(20.0, 28.0),
                      decoration: BoxDecoration(
                        color: AppColors.slate200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(width: context.scale(8).clamp(6.0, 10.0)),
                    Container(
                      width: context.scale(65).clamp(50.0, 80.0),
                      height: context.scaleH(24).clamp(20.0, 28.0),
                      decoration: BoxDecoration(
                        color: AppColors.slate200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
