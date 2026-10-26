import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';

class FaqCategoryItem {
  final String title;
  final String icon;
  final Color color;
  final Color bgColor;

  const FaqCategoryItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });
}

class FaqViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  int? _expandedIndex;
  String _searchQuery = '';

  int? get expandedIndex => _expandedIndex;
  String get searchQuery => _searchQuery;

  FaqViewModel() {
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    notifyListeners();
  }

  void toggleExpanded(int index, bool expanded) {
    _expandedIndex = expanded ? index : null;
    notifyListeners();
  }

  static const List<FaqItem> popularQuestions = [
    FaqItem(
      question: 'How do I post a job?',
      answer:
          'To post a job, tap the "+" button in the bottom navigation bar or visit the Jobs section. Select "Post a Job", fill in the job title, category, description, salary, and requirements, then submit your posting.',
    ),
    FaqItem(
      question: 'How can I rent a room?',
      answer:
          'Browse the "Rooms" section to view available room listings in your city. Filter by price, amenities, and location. When you find a suitable room, contact the owner directly via chat or call.',
    ),
    FaqItem(
      question: 'How do payments work?',
      answer:
          'All premium transactions and memberships are securely processed using Stripe. We support major debit/credit cards. Your financial details are 256-bit encrypted and never stored on our servers.',
    ),
    FaqItem(
      question: 'Is my personal information safe?',
      answer:
          'Yes, we take privacy very seriously. Your data is encrypted and protected following strict GDPR standards. We never sell your personal data to third parties. You can read our Privacy Policy for more details.',
    ),
    FaqItem(
      question: 'How can I contact a worker?',
      answer:
          'Go to the "Workers" section, select a category, and browse verified worker profiles. On their profile page, tap "Chat" to send an instant message or "Call" to speak with them directly.',
    ),
  ];

  static const List<FaqCategoryItem> categories = [
    FaqCategoryItem(
      title: 'Account & Profile',
      icon: AppIcons.personSvg,
      color: AppColors.primaryBlue,
      bgColor: AppColors.lightBlue,
    ),
    FaqCategoryItem(
      title: 'Jobs',
      icon: AppIcons.briefcaseSvg,
      color: AppColors.emerald,
      bgColor: AppColors.softGreen,
    ),
    FaqCategoryItem(
      title: 'Rooms',
      icon: AppIcons.roomSvg,
      color: AppColors.orange,
      bgColor: AppColors.lightOrange,
    ),
    FaqCategoryItem(
      title: 'Payments',
      icon: AppIcons.couponSvg,
      color: AppColors.primaryPurple,
      bgColor: AppColors.purpleLight100,
    ),
    FaqCategoryItem(
      title: 'General',
      icon: AppIcons.infoSvg,
      color: AppColors.slate500,
      bgColor: AppColors.slate100,
    ),
  ];

  List<FaqItem> get filteredQuestions {
    if (_searchQuery.isEmpty) return popularQuestions;
    final query = _searchQuery.toLowerCase();
    return popularQuestions.where((q) {
      return q.question.toLowerCase().contains(query) ||
          q.answer.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
