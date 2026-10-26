import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_viewmodel.dart';
import '../home/home_viewmodel.dart';
import '../chat/chat_viewmodel.dart';
import '../notifications/notifications_viewmodel.dart';
import '../jobs/jobs_viewmodel.dart';
import '../profile/my_ads_viewmodel.dart';
import '../marketplace/marketplace_viewmodel.dart';
import '../create_post/need_worker_viewmodel.dart';
import '../business_listing_viewmodel.dart';
import '../profile/favourite_ads_viewmodel.dart';
import '../community/community_viewmodel.dart';

class NavigationViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  String _activeCategory =
      'dashboard'; // 'dashboard', 'marketplace', 'rooms', 'jobs', 'workers', 'events'
  bool _isMarketplaceActive =
      false; // true when browsing any category (marketplace, rooms, jobs, workers, events)
  bool _isSearchActive = false;

  bool _isCommunityActive = false;
  bool _isBottomBarInitialized = false;

  int get currentIndex => _currentIndex;
  String get activeCategory => _activeCategory;
  bool get isMarketplaceActive => _isMarketplaceActive;
  bool get isSearchActive => _isSearchActive;
  bool get isCommunityActive => _isCommunityActive;

  void resetBottomBarInitialization() {
    _isBottomBarInitialized = false;
  }

  void initBottomBar(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (authVM.isAuthenticated) {
        Provider.of<NotificationsViewModel>(
          context,
          listen: false,
        ).refreshUnreadCount();
        Provider.of<ChatViewModel>(context, listen: false).fetchUnreadCount();
      }
    });

    if (!_isBottomBarInitialized) {
      _isBottomBarInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final authVM = Provider.of<AuthViewModel>(context, listen: false);
        if (authVM.isAuthenticated) {
          if (authVM.currentUser == null) {
            authVM.fetchUserProfile();
          }
          Provider.of<JobsViewModel>(context, listen: false).fetchUserJobs();
          Provider.of<MyAdsViewModel>(context, listen: false).fetchUserAds();
          Provider.of<FavouriteAdsViewModel>(
            context,
            listen: false,
          ).fetchFavourites();
        }
        Provider.of<HomeViewModel>(context, listen: false).fetchHomeData();
      });
    }
  }

  void handleTabSelected(BuildContext context, int index) {
    setIndex(index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (index == 0) {
        Provider.of<HomeViewModel>(context, listen: false).fetchHomeData();
        if (authVM.isAuthenticated) {
          Provider.of<NotificationsViewModel>(
            context,
            listen: false,
          ).refreshUnreadCount();
          Provider.of<ChatViewModel>(context, listen: false).fetchUnreadCount();
        }
      } else if (index == 1) {
        if (authVM.isAuthenticated) {
          Provider.of<MarketplaceViewModel>(context, listen: false).fetchMyAds();
        }
      } else if (index == 2) {
        if (authVM.isAuthenticated) {
          Provider.of<ChatViewModel>(context, listen: false).fetchConversations();
        }
      } else if (index == 3) {
        if (authVM.isAuthenticated) {
          authVM.fetchUserProfile();
          Provider.of<JobsViewModel>(context, listen: false).fetchUserJobs();
          Provider.of<MyAdsViewModel>(context, listen: false).fetchUserAds();
          Provider.of<MarketplaceViewModel>(
            context,
            listen: false,
          ).fetchMyAds();
          Provider.of<NeedWorkerViewModel>(
            context,
            listen: false,
          ).fetchMyPosts();
          Provider.of<BusinessListingViewModel>(
            context,
            listen: false,
          ).fetchMyListings();
          Provider.of<FavouriteAdsViewModel>(
            context,
            listen: false,
          ).fetchFavourites();
          Provider.of<CommunityViewModel>(
            context,
            listen: false,
          ).fetchMyPosts();
        }
      }
    });
  }

  void setIndex(int index) {
    if (index != 2) {
      _isCommunityActive = false;
    }
    if (index == 1) {
      if (_currentIndex == 0) {
        // Tapping tab 1 from Home opens Dashboard
        _isMarketplaceActive = false;
        _isSearchActive = false;
        _activeCategory = 'dashboard';
        _currentIndex = 1;
      } else if (_currentIndex == 1 && !_isMarketplaceActive) {
        // Tapping active Dashboard tab switches to Search
        _isMarketplaceActive = true;
        _isSearchActive = true;
      } else {
        // Tapping tab 1 from Chat (2), Profile (3), or category screen opens Search
        _isMarketplaceActive = true;
        _isSearchActive = true;
        _currentIndex = 1;
      }
    } else {
      _currentIndex = index;
    }
    notifyListeners();
  }

  void resetToHome() {
    _currentIndex = 0;
    _activeCategory = 'dashboard';
    _isMarketplaceActive = false;
    _isSearchActive = false;
    _isCommunityActive = false;
    notifyListeners();
  }

  void openCommunity() {
    _isCommunityActive = true;
    _isMarketplaceActive = false;
    _isSearchActive = false;
    _activeCategory = 'community';
    _currentIndex = 2;
    notifyListeners();
  }

  void openChat() {
    _isCommunityActive = false;
    _isMarketplaceActive = false;
    _isSearchActive = false;
    _currentIndex = 2;
    notifyListeners();
  }

  void openDashboard() {
    _isCommunityActive = false;
    _activeCategory = 'dashboard';
    _isMarketplaceActive = false;
    _isSearchActive = false;
    _currentIndex = 1;
    notifyListeners();
  }

  void openMarketplace() {
    _isCommunityActive = false;
    _activeCategory = 'marketplace';
    _isMarketplaceActive = true;
    _isSearchActive = false;
    _currentIndex = 1;
    notifyListeners();
  }

  void openRooms() {
    _isCommunityActive = false;
    _activeCategory = 'rooms';
    _isMarketplaceActive = true;
    _isSearchActive = false;
    _currentIndex = 1;
    notifyListeners();
  }

  void openJobs() {
    _isCommunityActive = false;
    _activeCategory = 'jobs';
    _isMarketplaceActive = true;
    _isSearchActive = false;
    _currentIndex = 1;
    notifyListeners();
  }

  void openWorkers() {
    _isCommunityActive = false;
    _activeCategory = 'workers';
    _isMarketplaceActive = true;
    _isSearchActive = false;
    _currentIndex = 1;
    notifyListeners();
  }

  void openEvents() {
    _isCommunityActive = false;
    _activeCategory = 'events';
    _isMarketplaceActive = true;
    _isSearchActive = false;
    _currentIndex = 1;
    notifyListeners();
  }

  void openSearch() {
    _isCommunityActive = false;
    _isMarketplaceActive = true;
    _isSearchActive = true;
    _currentIndex = 1;
    notifyListeners();
  }
}
