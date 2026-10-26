import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/models/room_post.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';

class MyRoomsView extends StatelessWidget {
  const MyRoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PostRoomViewModel>(context);
    if (!viewModel.hasFetchedUserProps && !viewModel.isLoadingUserProps) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        viewModel.fetchUserProperties();
      });
    }
    final rooms = viewModel.filteredRooms;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.marginHorizontal,
                vertical: AppConstants.paddingMedium,
              ),
              child: Row(
                children: [
                  // Back Arrow button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingSmall),
                      decoration: const BoxDecoration(
                        color: AppColors.slate100,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.arrowBackSvg,
                        height: AppConstants.iconSize18,
                        width: AppConstants.iconSize18,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate500,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Title
                  const Text(
                    'My Rooms',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeXXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate800,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const Spacer(),
                  // Plus icon button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.postRoom);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingSmall),
                      decoration: const BoxDecoration(
                        color: AppColors.vibrantBlue,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.plusSvg,
                        height: AppConstants.iconSizeMD,
                        width: AppConstants.iconSizeMD,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: AppColors.slate200,
              thickness: AppConstants.borderWidth,
              height: 1,
            ),

            // 2. Filter tabs (Active, Pending, Expired)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.marginHorizontal,
                vertical: AppConstants.paddingLarge,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab(context, viewModel, 'All'),
                    const SizedBox(width: AppConstants.paddingMedium),
                    _buildTab(context, viewModel, 'Active'),
                    const SizedBox(width: AppConstants.paddingMedium),
                    _buildTab(context, viewModel, 'Pending'),
                    const SizedBox(width: AppConstants.paddingMedium),
                    _buildTab(context, viewModel, 'Expired'),
                  ],
                ),
              ),
            ),

            // 3. Scrollable List of Room Cards
            Expanded(
              child: rooms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.bedSvg,
                            height: AppConstants.iconSizeHuge,
                            width: AppConstants.iconSizeHuge,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gray500,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),
                          const Text(
                            'No rooms found',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeXL,
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          const SizedBox(height: AppConstants.padding4),
                          const Text(
                            'Try posting a new room under the Plus button.',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSM,
                              color: AppColors.gray400,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: AppConstants.marginHorizontal,
                        right: AppConstants.marginHorizontal,
                        bottom: AppConstants.padding20,
                      ),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return _buildRoomCard(context, room);
                      },
                    ),
            ),

            // 4. Pinned Bottom "+ Post New Room" button
            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.marginHorizontal,
                right: AppConstants.marginHorizontal,
                bottom: AppConstants.paddingExtraLarge,
                top: AppConstants.paddingSmall,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.vibrantBlue, AppColors.secondaryPurple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.postRoom);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    shadowColor: AppColors.transparent,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.paddingLarge,
                    ),
                  ),
                  child: const Text(
                    '+ Post New Room',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: AppConstants.fontSizeXL,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    PostRoomViewModel viewModel,
    String title,
  ) {
    final isSelected =
        viewModel.selectedFilter.toLowerCase() == title.toLowerCase();
    const activeBgColor = AppColors.vibrantBlue;

    return GestureDetector(
      onTap: () => viewModel.setSelectedFilter(title),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingExtraLarge,
          vertical: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          border: Border.all(
            color: isSelected ? activeBgColor : AppColors.slate200,
            width: 1.2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.slate600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: AppConstants.fontSize,
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomPost room) {
    Color badgeBgColor;
    Color badgeTextColor;

    switch (room.status.toLowerCase()) {
      case 'active':
        badgeBgColor = AppColors.greenBg;
        badgeTextColor = AppColors.darkGreen;
        break;
      case 'pending':
        badgeBgColor = AppColors.orangeLight;
        badgeTextColor = AppColors.deepOrange;
        break;
      case 'expired':
      default:
        badgeBgColor = AppColors.slate100;
        badgeTextColor = AppColors.slate500;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        border: Border.all(
          color: AppColors.slate200,
          width: AppConstants.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  room.title,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeXXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                    fontFamily: AppStrings.fontInter,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingStandard,
                  vertical: AppConstants.padding6,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                child: Text(
                  room.status,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSM,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.padding6),
          // Row 2: Location
          Text(
            room.location,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeMD,
              color: AppColors.slate500,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          // Row 3: Monthly Rent Price
          Text(
            '€${room.price}/month',
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXL,
              fontWeight: FontWeight.bold,
              color: AppColors.vibrantBlue,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          const SizedBox(height: AppConstants.padding6),
          // Row 4: Posted Date
          Text(
            'Posted on: ${room.date}',
            style: const TextStyle(
              fontSize: AppConstants.fontSizeSM,
              color: AppColors.slate400,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ],
      ),
    );
  }
}
