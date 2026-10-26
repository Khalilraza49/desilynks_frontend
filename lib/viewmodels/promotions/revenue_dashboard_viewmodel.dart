import 'package:flutter/material.dart';

class RevenueBreakdownItem {
  final String title;
  final String amount;
  final String percentageText;
  final double percentage;
  final Color color;

  const RevenueBreakdownItem({
    required this.title,
    required this.amount,
    required this.percentageText,
    required this.percentage,
    required this.color,
  });
}

class RevenueDashboardViewModel extends ChangeNotifier {
  String _selectedPeriod = 'Last 3 Months';
  String get selectedPeriod => _selectedPeriod;

  final List<String> periods = const [
    'This Month',
    'Last Month',
    'Last 3 Months',
    'This Year',
  ];

  static const List<RevenueBreakdownItem> _breakdownItems = [
    RevenueBreakdownItem(
      title: 'Business Promotions',
      amount: '€2,150',
      percentageText: '39%',
      percentage: 0.39,
      color: Color(0xFF2563EB),
    ),
    RevenueBreakdownItem(
      title: 'Banner Ads',
      amount: '€1,420',
      percentageText: '26%',
      percentage: 0.26,
      color: Color(0xFFF59E0B),
    ),
    RevenueBreakdownItem(
      title: 'Sponsored Listings',
      amount: '€1,350',
      percentageText: '25%',
      percentage: 0.25,
      color: Color(0xFF8B5CF6),
    ),
    RevenueBreakdownItem(
      title: 'Spotlight',
      amount: '€250',
      percentageText: '5%',
      percentage: 0.05,
      color: Color(0xFF10B981),
    ),
    RevenueBreakdownItem(
      title: 'Deals & Discounts',
      amount: '€190',
      percentageText: '4%',
      percentage: 0.04,
      color: Color(0xFFEF4444),
    ),
  ];

  List<RevenueBreakdownItem> get breakdownItems => _breakdownItems;

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }
}
