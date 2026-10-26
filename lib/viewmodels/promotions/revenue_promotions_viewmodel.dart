import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/constants/app_icons.dart';

class PromotionGridAction {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String icon;
  final Color iconColor;
  final Color iconBgColor;
  final String routeName;

  const PromotionGridAction({
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.routeName,
  });
}

class RevenuePromotionsViewModel extends ChangeNotifier {
  static const List<PromotionGridAction> _gridActions = [
    PromotionGridAction(
      title: 'Business',
      subtitle1: 'Promotions',
      subtitle2: 'Promote your business',
      icon: AppIcons.store,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFEFF6FF),
      routeName: AppRoutes.postBusiness,
    ),
    PromotionGridAction(
      title: 'Boost',
      subtitle1: 'Listings',
      subtitle2: 'Increase visibility',
      icon: AppIcons.boostRocketSvg,
      iconColor: Color(0xFF8B5CF6),
      iconBgColor: Color(0xFFF5F3FF),
      routeName: AppRoutes.selectAdToPromote,
    ),
    PromotionGridAction(
      title: 'Banner',
      subtitle1: 'Advertisements',
      subtitle2: 'Run banner ads',
      icon: AppIcons.galleryRoundSvg,
      iconColor: Color(0xFFD97706),
      iconBgColor: Color(0xFFFEF3C7),
      routeName: AppRoutes.bannerAdvertisements,
    ),
    PromotionGridAction(
      title: 'Community',
      subtitle1: 'Spotlight',
      subtitle2: 'Get featured',
      icon: AppIcons.starFavoriteSvg,
      iconColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFECFDF5),
      routeName: AppRoutes.community,
    ),
    PromotionGridAction(
      title: 'My',
      subtitle1: 'Promotions',
      subtitle2: 'Manage all',
      icon: AppIcons.menuHorizontalSvg,
      iconColor: Color(0xFF059669),
      iconBgColor: Color(0xFFD1FAE5),
      routeName: AppRoutes.myAds,
    ),
  ];

  List<PromotionGridAction> get gridActions => _gridActions;

  final String totalEarnings = '€5,360';
  final String availableBalance = '€1,240';
  final int activePromosCount = 4;
}
