import 'package:flutter/material.dart';

/// Onboarding slide model.
class OnboardingSlide {
  final String title;
  final String subtitle;
  final String imagePath;

  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

/// ViewModel for the Onboarding screen.
///
/// Manages:
/// - Slide data (content)
/// - Current page index
/// - Page transition logic (next / skip)
/// - Onboarding completion callback
class OnboardingViewModel extends ChangeNotifier {
  // ──────────────────────────────────────────────────────────────────────────
  // Slides Data
  // ──────────────────────────────────────────────────────────────────────────
  final List<OnboardingSlide> slides = const [
    OnboardingSlide(
      title: 'Find What You Need',
      subtitle: 'Jobs, Rooms, Workers Everything in\none place',
      imagePath: 'assets/png/onboard1.png',
    ),
    OnboardingSlide(
      title: 'Buy, Sell & Connect',
      subtitle: 'Marketplace, Community, Group &\nEvents',
      imagePath: 'assets/png/onboard2.png',
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // Current Page State
  // ──────────────────────────────────────────────────────────────────────────
  int _currentPage = 0;
  int get currentPage => _currentPage;
  int get totalPages => slides.length;

  bool get isLastPage => _currentPage == slides.length - 1;

  final PageController pageController = PageController();

  void setPage(int index) {
    if (_currentPage == index) return;
    _currentPage = index;
    notifyListeners();
  }

  /// Advances to the next page. Returns true if navigation moved forward,
  /// false if the user is already on the last page (caller should complete).
  bool goToNextPage([PageController? controller]) {
    if (isLastPage) return false;
    final ctrl = controller ?? pageController;
    ctrl.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    return true;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
