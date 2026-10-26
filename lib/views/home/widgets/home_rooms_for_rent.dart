import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/viewmodels/home/home_viewmodel.dart';

class HomeRoomsForRent extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;

  const HomeRoomsForRent({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
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
    final int activeIndex = homeViewModel.roomsIndex.clamp(0, rooms.length - 1);

    return Column(
      children: [
        SizedBox(
          height: 220.0,
          child: PageView.builder(
            controller: homeViewModel.roomsPageController,
            onPageChanged: (index) {
              homeViewModel.setRoomsIndex(index);
            },
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final String imageUrl = room['imageUrl'] as String? ?? '';
              final bool hasImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');

              return GestureDetector(
                onTap: () {
                  Provider.of<NavigationViewModel>(
                    context,
                    listen: false,
                  ).openRooms();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.02),
                        blurRadius: AppConstants.borderRadiusSmall,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppConstants.borderRadius16),
                            ),
                            child: hasImage
                                ? Image.network(
                                    imageUrl,
                                    height: AppConstants.dealCardHeight,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildRoomImagePlaceholder(),
                                  )
                                : _buildRoomImagePlaceholder(),
                          ),
                          Positioned(
                            top: AppConstants.paddingSmall,
                            right: AppConstants.paddingSmall,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.paddingSmall,
                                vertical: AppConstants.padding4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadius8,
                                ),
                              ),
                              child: Text(
                                room['price'] as String? ?? '',
                                style: const TextStyle(
                                  color: AppColors.slate800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.paddingMedium,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room['title'] as String? ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: AppConstants.fontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate800,
                              ),
                            ),
                            const SizedBox(height: AppConstants.padding4),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcons.locationSvg,
                                  width: AppConstants.iconSizeXS,
                                  height: AppConstants.iconSizeXS,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.slate500,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.padding4),
                                Flexible(
                                  child: Text(
                                    room['location'] as String? ?? '',
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
                            Text(
                              room['specs'] as String? ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.slate500,
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
            rooms.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: activeIndex == index
                  ? AppConstants.borderRadius24
                  : AppConstants.borderRadius8,
              height: AppConstants.borderRadius8,
              decoration: BoxDecoration(
                color: activeIndex == index
                    ? AppColors.primaryBlue
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

  Widget _buildRoomImagePlaceholder() {
    return Container(
      height: AppConstants.dealCardHeight,
      width: double.infinity,
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
