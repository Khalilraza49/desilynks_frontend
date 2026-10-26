import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../widgets/login_required_dialog.dart';

/// Model representing a single post creation category option.
class CreatePostCategoryItem {
  final String emoji;
  final String title;
  final String subtitle;
  final String svg;
  final Color iconColor;
  final Color bgColor;
  final String? route;

  const CreatePostCategoryItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.svg,
    required this.iconColor,
    required this.bgColor,
    this.route,
  });
}

/// ViewModel for the Create Post Hub screen.
///
/// Manages:
/// - Available post category choices
/// - Navigation and authentication guards for each category
/// - User feedback notifications
class CreatePostViewModel extends ChangeNotifier {
  final List<CreatePostCategoryItem> _categories = const [
    CreatePostCategoryItem(
      emoji: '🏠',
      title: 'Room / Property',
      subtitle: 'Rent a room, apartment or house',
      svg: AppIcons.homeSvg,
      iconColor: AppColors.vibrantBlue,
      bgColor: AppColors.lightBlue,
      route: AppRoutes.postRoom,
    ),
    CreatePostCategoryItem(
      emoji: '💼',
      title: 'Job Vacancy',
      subtitle: 'Post a job for your business',
      svg: AppIcons.briefcaseSvg,
      iconColor: AppColors.emerald,
      bgColor: AppColors.softGreen,
      route: AppRoutes.postJob,
    ),
    CreatePostCategoryItem(
      emoji: '👷',
      title: 'Worker Profile',
      subtitle: 'Offer your services as worker',
      svg: AppIcons.workerSvg,
      iconColor: AppColors.amberOrange,
      bgColor: AppColors.lightYellow,
      route: AppRoutes.postWorkerProfile,
    ),
    CreatePostCategoryItem(
      emoji: '🙋',
      title: 'Need a Worker',
      subtitle: 'Find someone for a task or job',
      svg: AppIcons.raiseHandSvg,
      iconColor: AppColors.orangeAccent,
      bgColor: AppColors.lightOrange,
      route: AppRoutes.postNeedWorker,
    ),
    CreatePostCategoryItem(
      emoji: '🛒',
      title: 'Sell a Product',
      subtitle: 'Buy & sell items in the marketplace',
      svg: AppIcons.shopSvg,
      iconColor: AppColors.primaryPurple,
      bgColor: Color(0xFFF3E8FF),
      route: AppRoutes.postProduct,
    ),
    CreatePostCategoryItem(
      emoji: '🏪',
      title: 'Local Business',
      subtitle: 'List your local business or shop',
      svg: AppIcons.businessSvg,
      iconColor: AppColors.primaryRed,
      bgColor: Color(0xFFFEE2E2),
      route: AppRoutes.postBusiness,
    ),
    CreatePostCategoryItem(
      emoji: '🎉',
      title: 'Event',
      subtitle: 'Organize a community event',
      svg: AppIcons.eventSvg,
      iconColor: Color(0xFF059669),
      bgColor: Color(0xFFDCFCE7),
      route: AppRoutes.postEvent,
    ),
    CreatePostCategoryItem(
      emoji: '📰',
      title: 'Community Post',
      subtitle: 'Share news, updates or stories',
      svg: AppIcons.newspaperSvg,
      iconColor: AppColors.vibrantBlue,
      bgColor: Color(0xFFE0F2FE),
      route: AppRoutes.postCommunity,
    ),
  ];

  List<CreatePostCategoryItem> get categories => _categories;

  /// Handles user tapping a category card.
  /// If unauthenticated, displays the login prompt.
  /// Otherwise, navigates to the category post creation form.
  void handleCategorySelection(
    BuildContext context,
    CreatePostCategoryItem category, {
    required bool isAuthenticated,
  }) {
    if (!isAuthenticated) {
      LoginRequiredDialog.show(context);
      return;
    }

    if (category.route != null) {
      Navigator.pushNamed(context, category.route!);
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.title} selected!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius10),
          ),
        ),
      );
    }
  }
}
