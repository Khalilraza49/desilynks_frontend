import 'package:flutter/material.dart';
import '../../core/constants/app_icons.dart';

class WeeklyBreakdownData {
  final String weekLabel;
  final String amount;
  final double percentage;
  final Color color;

  const WeeklyBreakdownData({
    required this.weekLabel,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class TopPerformingData {
  final String title;
  final String subtitle;
  final String earnings;
  final String growth;
  final String icon;
  final Color iconColor;
  final Color iconBgColor;

  const TopPerformingData({
    required this.title,
    required this.subtitle,
    required this.earnings,
    required this.growth,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class MyRevenueStatsViewModel extends ChangeNotifier {
  String _selectedPeriod = 'This Month';
  String get selectedPeriod => _selectedPeriod;

  final List<String> periods = const [
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
  ];

  static const List<WeeklyBreakdownData> _weeklyItems = [
    WeeklyBreakdownData(
      weekLabel: 'Week 1',
      amount: '€280',
      percentage: 0.45,
      color: Color(0xFF2563EB),
    ),
    WeeklyBreakdownData(
      weekLabel: 'Week 2',
      amount: '€320',
      percentage: 0.55,
      color: Color(0xFF8B5CF6),
    ),
    WeeklyBreakdownData(
      weekLabel: 'Week 3',
      amount: '€295',
      percentage: 0.48,
      color: Color(0xFF2563EB),
    ),
    WeeklyBreakdownData(
      weekLabel: 'Week 4',
      amount: '€350',
      percentage: 0.62,
      color: Color(0xFF10B981),
    ),
  ];

  List<WeeklyBreakdownData> get weeklyItems => _weeklyItems;

  static const List<TopPerformingData> _topPerformingList = [
    TopPerformingData(
      title: 'Desi Mart Promotion',
      subtitle: 'Business Promo · 30 Days',
      earnings: '€580',
      growth: '+46%',
      icon: AppIcons.store,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFEFF6FF),
    ),
    TopPerformingData(
      title: 'Home Banner Ad',
      subtitle: 'Banner · Home Screen',
      earnings: '€420',
      growth: '+34%',
      icon: AppIcons.gallerySvg,
      iconColor: Color(0xFFD97706),
      iconBgColor: Color(0xFFFFFBEB),
    ),
    TopPerformingData(
      title: 'Job Boost',
      subtitle: 'Sponsored · Gold',
      earnings: '€245',
      growth: '+22%',
      icon: AppIcons.boostRocketSvg,
      iconColor: Color(0xFF8B5CF6),
      iconBgColor: Color(0xFFF5F3FF),
    ),
  ];

  List<TopPerformingData> get topPerformingList => _topPerformingList;

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }
}
