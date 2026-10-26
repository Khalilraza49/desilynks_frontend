import 'package:flutter/material.dart';
import '../../core/constants/app_icons.dart';
import '../../models/banner_ad_model.dart';
import '../../repositories/banner_ad_repository.dart';

class BannerPositionItem {
  final String title;
  final String subtitle;
  final String priceText;
  final String durationText;
  final String icon;
  final Color iconColor;
  final Color iconBgColor;
  final BannerAdPosition position;

  const BannerPositionItem({
    required this.title,
    required this.subtitle,
    required this.priceText,
    required this.durationText,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.position,
  });
}

class BannerAdvertisementsViewModel extends ChangeNotifier {
  final BannerAdRepository? _repository;

  BannerAdvertisementsViewModel([this._repository]) {
    fetchMyBanners();
  }

  BannerPositionItem? _selectedPosition;
  BannerPositionItem? get selectedPosition => _selectedPosition;

  List<BannerPositionItem> get positions => _positions;

  static const List<BannerPositionItem> _positions = [
    BannerPositionItem(
      title: 'Home Screen Banner',
      subtitle: 'Max visibility · Top placement',
      priceText: 'from €15',
      durationText: '7 Days',
      icon: AppIcons.homeSvg,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFEFF6FF),
      position: BannerAdPosition.homeScreen,
    ),
    BannerPositionItem(
      title: 'Jobs Screen Banner',
      subtitle: 'Shown in jobs listings',
      priceText: 'from €12',
      durationText: '7 Days',
      icon: AppIcons.businessSvg,
      iconColor: Color(0xFF059669),
      iconBgColor: Color(0xFFECFDF5),
      position: BannerAdPosition.jobsScreen,
    ),
    BannerPositionItem(
      title: 'Rooms Screen Banner',
      subtitle: 'Shown in rooms listings',
      priceText: 'from €12',
      durationText: '7 Days',
      icon: AppIcons.roomSvg,
      iconColor: Color(0xFFEA580C),
      iconBgColor: Color(0xFFFFF7ED),
      position: BannerAdPosition.roomsScreen,
    ),
    BannerPositionItem(
      title: 'Bottom Banner',
      subtitle: 'Shown at bottom of pages',
      priceText: 'from €10',
      durationText: '7 Days',
      icon: AppIcons.swag,
      iconColor: Color(0xFFD97706),
      iconBgColor: Color(0xFFFEF3C7),
      position: BannerAdPosition.bottom,
    ),
    BannerPositionItem(
      title: 'Popup Banner',
      subtitle: 'Full screen popup · High impact',
      priceText: 'from €20',
      durationText: '7 Days',
      icon: AppIcons.popup,
      iconColor: Color(0xFFDB2777),
      iconBgColor: Color(0xFFFDF2F8),
      position: BannerAdPosition.popup,
    ),
  ];

  List<BannerAdModel> _myBanners = [];
  List<BannerAdModel> get myBanners => _myBanners;

  bool _isLoadingMyBanners = false;
  bool get isLoadingMyBanners => _isLoadingMyBanners;

  int get runningCount =>
      _myBanners.where((b) => b.isRunning).length;

  Future<void> fetchMyBanners() async {
    if (_repository == null) return;
    _isLoadingMyBanners = true;
    notifyListeners();

    try {
      final res = await _repository.getMyBannerAds(limit: 50);
      _myBanners = res['data'] as List<BannerAdModel>;
    } catch (e) {
      debugPrint('BannerAdvertisementsViewModel: fetch error: $e');
    } finally {
      _isLoadingMyBanners = false;
      notifyListeners();
    }
  }

  void selectPosition(BannerPositionItem position) {
    _selectedPosition = position;
    notifyListeners();
  }
}
