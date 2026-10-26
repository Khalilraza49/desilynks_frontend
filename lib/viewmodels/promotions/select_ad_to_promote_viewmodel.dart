import 'package:flutter/material.dart';

class PromotableAdItem {
  final String id;
  final String title;
  final String price;
  final String imageUrl;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;

  const PromotableAdItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
  });
}

class SelectAdToPromoteViewModel extends ChangeNotifier {
  String? _selectedAdId;
  String? get selectedAdId => _selectedAdId;

  static const List<PromotableAdItem> _fallbackAds = [
    PromotableAdItem(
      id: 'f1',
      title: 'iPhone 14 Pro 256GB',
      price: '€600',
      imageUrl:
          'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&q=80&w=400',
      badgeText: 'Golden Active',
      badgeBgColor: Color(0xFFFEF3C7),
      badgeTextColor: Color(0xFFD97706),
    ),
    PromotableAdItem(
      id: 'f2',
      title: 'Washing Machine Bosch',
      price: '€150',
      imageUrl:
          'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?auto=format&fit=crop&q=80&w=400',
      badgeText: 'Premium Active',
      badgeBgColor: Color(0xFFE0E7FF),
      badgeTextColor: Color(0xFF4F46E5),
    ),
    PromotableAdItem(
      id: 'f3',
      title: 'Sofa Set 3+2+1',
      price: '€250',
      imageUrl:
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&q=80&w=400',
      badgeText: 'Featured Active',
      badgeBgColor: Color(0xFFF3E8FF),
      badgeTextColor: Color(0xFF7E22CE),
    ),
    PromotableAdItem(
      id: 'f4',
      title: 'Dining Table Oak',
      price: '€120',
      imageUrl:
          'https://images.unsplash.com/photo-1530018607912-eff2daa1bac4?auto=format&fit=crop&q=80&w=400',
      badgeText: 'Featured Active',
      badgeBgColor: Color(0xFFF3E8FF),
      badgeTextColor: Color(0xFF7E22CE),
    ),
    PromotableAdItem(
      id: 'f5',
      title: 'Samsung Galaxy S24',
      price: '€450',
      imageUrl:
          'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&q=80&w=400',
      badgeText: 'Premium Active',
      badgeBgColor: Color(0xFFE0E7FF),
      badgeTextColor: Color(0xFF4F46E5),
    ),
    PromotableAdItem(
      id: 'f6',
      title: 'Mountain Bike Trek',
      price: '€300',
      imageUrl:
          'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&q=80&w=400',
      badgeText: 'Golden Active',
      badgeBgColor: Color(0xFFFEF3C7),
      badgeTextColor: Color(0xFFD97706),
    ),
  ];

  List<PromotableAdItem> get fallbackAds => _fallbackAds;

  void selectAd(String id) {
    if (_selectedAdId == id) {
      _selectedAdId = null;
    } else {
      _selectedAdId = id;
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedAdId = null;
    notifyListeners();
  }
}
