import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/home/home_viewmodel.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/views/home/widgets/home_header.dart';
import 'package:desilynks/views/home/widgets/home_search_bar.dart';
import 'package:desilynks/views/home/widgets/home_promo_banner.dart';
import 'package:desilynks/views/home/widgets/home_today_stats.dart';
import 'package:desilynks/views/home/widgets/home_categories_grid.dart';
import 'package:desilynks/views/home/widgets/home_location_filters.dart';
import 'package:desilynks/views/home/widgets/home_featured_listings.dart';
import 'package:desilynks/views/home/widgets/home_deals_discounts.dart';
import 'package:desilynks/views/home/widgets/home_revenue_promotions.dart';
import 'package:desilynks/views/home/widgets/home_community_spotlight.dart';
import 'package:desilynks/views/home/widgets/home_featured_jobs.dart';
import 'package:desilynks/views/home/widgets/home_rooms_for_rent.dart';
import 'package:desilynks/views/home/widgets/home_explore_spain.dart';
import 'package:desilynks/views/home/widgets/home_skeleton_view.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/models/marketplace_item_model.dart';
import 'package:desilynks/viewmodels/marketplace/marketplace_viewmodel.dart';
import 'package:desilynks/viewmodels/notifications/notifications_viewmodel.dart';
import 'package:desilynks/viewmodels/chat/chat_viewmodel.dart';

class HomeView extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const HomeView({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final marketplaceViewModel = Provider.of<MarketplaceViewModel>(context);

    final List<MarketplaceItemModel> topMarketplaceAds =
        homeViewModel.topMarketplaceAds.isNotEmpty
            ? homeViewModel.topMarketplaceAds
            : (homeViewModel.selectedCity == 'All Cities'
                ? marketplaceViewModel.items
                    .where((i) =>
                        i.status.toUpperCase() == 'ACTIVE' ||
                        i.status.toUpperCase() == 'PUBLISHED')
                    .take(3)
                    .toList()
                : marketplaceViewModel.items
                    .where((i) =>
                        (i.status.toUpperCase() == 'ACTIVE' ||
                            i.status.toUpperCase() == 'PUBLISHED') &&
                        i.location
                            .toLowerCase()
                            .contains(homeViewModel.selectedCity.toLowerCase()))
                    .take(3)
                    .toList());

    // Show skeleton view on loop until user profile and home initial data have finished loading
    final bool isUserLoading =
        authViewModel.isLoading && authViewModel.currentUser == null;
    final bool isHomeLoading = homeViewModel.isInitialLoading;
    if (isUserLoading || isHomeLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundOffWhite,
        body: SafeArea(child: HomeSkeletonView()),
      );
    }

    final user = authViewModel.currentUser;

    final String welcomeName = user != null && user.firstName.isNotEmpty
        ? user.firstName
        : AppStrings.defaultUserName;

    final String userCity = user?.address?.city ?? AppStrings.defaultCity;
    final String userCountry =
        user?.address?.country ?? AppStrings.defaultCountry;
    final String locationText = '$userCity, $userCountry';

    // Proactively refresh real-time badge counts when HomeView mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (authViewModel.isAuthenticated) {
        context.read<NotificationsViewModel>().refreshUnreadCount();
        context.read<ChatViewModel>().fetchUnreadCount();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: AppColors.backgroundOffWhite,
          color: AppColors.primaryBlue,
          onRefresh: () async {
            final authVM = Provider.of<AuthViewModel>(context, listen: false);
            final futures = <Future>[homeViewModel.fetchHomeData()];
            if (authVM.isAuthenticated) {
              futures.add(
                Provider.of<NotificationsViewModel>(
                  context,
                  listen: false,
                ).refreshUnreadCount(),
              );
              futures.add(
                Provider.of<ChatViewModel>(
                  context,
                  listen: false,
                ).fetchUnreadCount(),
              );
            }
            await Future.wait(futures);
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
              vertical: AppConstants.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Section
                HomeHeader(
                  user: user,
                  welcomeName: welcomeName,
                  locationText: locationText,
                  onMenuPressed: onMenuPressed ?? () {},
                ),
                const SizedBox(height: AppConstants.padding20),

                // 2. Search & Filter Bar
                const HomeSearchBar(),
                const SizedBox(height: AppConstants.padding20),

                // 3. Featured Promo Banner Carousel
                if (homeViewModel.bannerPromos.isNotEmpty) ...[
                  HomePromoBanner(bannerPromos: homeViewModel.bannerPromos),
                  const SizedBox(height: AppConstants.padding20),
                ],

                // 4. Today's Stats Panel
                HomeTodayStats(
                  userCity: userCity,
                  jobsCount: homeViewModel.jobsCount,
                  roomsCount: homeViewModel.roomsCount,
                  workersCount: homeViewModel.workersCount,
                  dealsCount: homeViewModel.dealsCount,
                  totalPostings: homeViewModel.totalPostings,
                  isLoading: homeViewModel.isLoadingStats,
                ),
                const SizedBox(height: AppConstants.paddingExtraLarge),

                // 5. Categories Grid
                HomeCategoriesGrid(categories: homeViewModel.categories),
                const SizedBox(height: AppConstants.paddingExtraLarge),

                // 6. Location Filter Badges
                HomeLocationFilters(
                  cities: homeViewModel.cities,
                  selectedCity: homeViewModel.selectedCity,
                  onCitySelected: (city) {
                    homeViewModel.selectCity(city);
                  },
                ),
                const SizedBox(height: AppConstants.paddingExtraLarge),

                // 7. Featured Listings Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        AppStrings.titleFeaturedListings,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeXXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        ).openMarketplace();
                      },
                      child: const Text(
                        AppStrings.btnViewAll,
                        style: TextStyle(
                          fontSize: AppConstants.fontSize,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                HomeFeaturedListings(
                  items: topMarketplaceAds,
                ),
                const SizedBox(height: AppConstants.padding20),

                // 8. Featured Deals & Discounts Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        AppStrings.titleDealsDiscounts,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeXXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.dealsDiscounts);
                      },
                      child: const Text(
                        AppStrings.btnSeeAll,
                        style: TextStyle(
                          fontSize: AppConstants.fontSize,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                const HomeDealsDiscounts(),
                const SizedBox(height: AppConstants.padding28),

                // 9. Revenue & Promotions
                HomeRevenuePromotions(revPromos: homeViewModel.revPromos),
                const SizedBox(height: AppConstants.padding28),

                // 10. Community Spotlight
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        AppStrings.titleCommunitySpotlight,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeXXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        ).openCommunity();
                      },
                      child: const Text(
                        AppStrings.btnViewAll,
                        style: TextStyle(
                          fontSize: AppConstants.fontSize,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                HomeCommunitySpotlight(
                  spotlightUsers: homeViewModel.spotlightUsers,
                ),
                const SizedBox(height: AppConstants.padding28),

                // 12. Featured Jobs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        AppStrings.titleFeaturedJobs,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeXXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        ).openJobs();
                      },
                      child: const Text(
                        AppStrings.btnViewAll,
                        style: TextStyle(
                          fontSize: AppConstants.fontSize,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                HomeFeaturedJobs(jobs: homeViewModel.jobs),
                const SizedBox(height: AppConstants.padding28),

                // 13. Rooms for Rent
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        AppStrings.titleRoomsForRent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeXXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        ).openRooms();
                      },
                      child: const Text(
                        AppStrings.btnViewAll,
                        style: TextStyle(
                          fontSize: AppConstants.fontSize,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                HomeRoomsForRent(rooms: homeViewModel.rooms),
                const SizedBox(height: AppConstants.padding28),

                // 14. Explore Spain
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.exploreSpain);
                        },
                        child: const Text(
                          AppStrings.titleExploreSpain,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeXXL,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.exploreSpain);
                      },
                      child: const Text(
                        AppStrings.btnViewAll,
                        style: TextStyle(
                          fontSize: AppConstants.fontSize,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                HomeExploreSpain(exploreCities: homeViewModel.exploreCities),
                const SizedBox(height: AppConstants.padding40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
