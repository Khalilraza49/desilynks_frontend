import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final bool isMarketplaceActive;
  final bool isCommunityActive;
  final ValueChanged<int> onTap;
  final double? centerGap;
  final int chatBadgeCount;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    this.isMarketplaceActive = false,
    this.isCommunityActive = false,
    required this.onTap,
    this.centerGap,
    this.chatBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    const Color activeColor = AppColors.vibrantBlue;
    const Color inactiveColor = AppColors.svgDefault;

    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double bottomPadding = mediaQuery.padding.bottom;
    final bool isSmall = screenWidth < 360.0;
    final bool isLarge = screenWidth >= 420.0;

    final double baseBarHeight = isSmall ? 48.0 : (isLarge ? 54.0 : 50.0);
    final double barHeight = baseBarHeight + bottomPadding;
    final double effectiveCenterGap =
        centerGap ?? (isSmall ? 52.0 : (isLarge ? 64.0 : 58.0));

    return BottomAppBar(
      color: AppColors.white,
      elevation: AppConstants.elevationLG,
      padding: EdgeInsets.zero,
      height: barHeight,
      child: Container(
        height: barHeight,
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppConstants.borderRadius30),
            bottomRight: Radius.circular(AppConstants.borderRadius30),
          ),
          border: Border(
            top: BorderSide(
              color: AppColors.slate200,
              width: AppConstants.borderWidthMedium,
            ),
          ),
        ),
        child: SizedBox(
          height: baseBarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Home Nav Item (Index 0)
              _buildNavItem(
                context: context,
                svgIcons: AppIcons.homeSvg,
                label: 'Home',
                index: 0,
                isActive: currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                isSmall: isSmall,
                isLarge: isLarge,
              ),
              // Nav Item 1:
              // - Show 'Dashboard' when on Home screen (currentIndex == 0) or Dashboard view is active
              // - Show 'Search' when on any other screen (Chat, Profile, Search/Marketplace categories)
              (currentIndex == 0 || (currentIndex == 1 && !isMarketplaceActive))
                  ? _buildNavItem(
                      context: context,
                      svgIcons: AppIcons.dashboardSvg,
                      label: 'Dashboard',
                      index: 1,
                      isActive: currentIndex == 1,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      isSmall: isSmall,
                      isLarge: isLarge,
                    )
                  : _buildNavItem(
                      context: context,
                      svgIcons: AppIcons.searchSvg,
                      label: 'Search',
                      index: 1,
                      isActive: currentIndex == 1,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      isSmall: isSmall,
                      isLarge: isLarge,
                    ),
              // Space placeholder for floating center FAB
              SizedBox(width: effectiveCenterGap),
              // Chat / Community Nav Item (Index 2)
              isCommunityActive
                  ? _buildNavItem(
                      context: context,
                      svgIcons: AppIcons.pcommunitySvg,
                      label: 'Community',
                      index: 2,
                      isActive: currentIndex == 2,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      isSmall: isSmall,
                      isLarge: isLarge,
                    )
                  : _buildNavItem(
                      context: context,
                      svgIcons: AppIcons.chatRoundSvg,
                      label: 'Chat',
                      index: 2,
                      isActive: currentIndex == 2,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      isSmall: isSmall,
                      isLarge: isLarge,
                      badgeCount: chatBadgeCount,
                    ),
              // Profile Nav Item (Index 3)
              _buildNavItem(
                context: context,
                svgIcons: AppIcons.profileSvg,
                label: 'Profile',
                index: 3,
                isActive: currentIndex == 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                isSmall: isSmall,
                isLarge: isLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    String? svgIcons,
    String? pngIcons,
    IconData? iconData,
    required String label,
    required int index,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required bool isSmall,
    required bool isLarge,
    int badgeCount = 0,
  }) {
    final Color color = isActive ? activeColor : inactiveColor;
    final double iconSize = isSmall ? 18.0 : (isLarge ? 21.0 : 19.0);
    final double fontSize = isSmall ? 10.0 : (isLarge ? 11.5 : 10.5);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: Center(
                        child: iconData != null
                            ? Icon(iconData, color: color, size: iconSize)
                            : pngIcons != null
                            ? Image.asset(
                                pngIcons,
                                width: iconSize,
                                height: iconSize,
                              )
                            : svgIcons != null
                            ? SvgPicture.asset(
                                svgIcons,
                                colorFilter: ColorFilter.mode(
                                  color,
                                  BlendMode.srcIn,
                                ),
                                width: iconSize,
                                height: iconSize,
                                fit: BoxFit.contain,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        top: -5,
                        right: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.white,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              badgeCount > 99 ? '99+' : '$badgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: SizedBox(
                    height: fontSize * 1.3,
                    child: Center(
                      child: Text(
                        label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: color,
                          height: 1.0,
                        ),
                      ),
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
}
