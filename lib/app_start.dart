import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/connectivity_service.dart';
import 'widgets/connectivity_wrapper.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'viewmodels/dashboard/dashboard_viewmodel.dart';
import 'repositories/auth_repository.dart';
import 'repositories/property_repository.dart';
import 'services/local/storage_service.dart';
import 'services/api/api_service.dart';
import 'viewmodels/auth/auth_viewmodel.dart';
import 'viewmodels/home/home_viewmodel.dart';
import 'viewmodels/navigation/navigation_viewmodel.dart';
import 'viewmodels/chat/chat_viewmodel.dart';
import 'viewmodels/profile/favourite_ads_viewmodel.dart';
import 'viewmodels/profile/subscription_viewmodel.dart';
import 'viewmodels/profile/my_activity_viewmodel.dart';
import 'viewmodels/notifications/notifications_viewmodel.dart';
import 'viewmodels/create_post/post_room_viewmodel.dart';
import 'viewmodels/profile/my_ads_viewmodel.dart';
import 'services/local/cache_service.dart';

import 'repositories/job_repository.dart';
import 'repositories/worker_repository.dart';
import 'repositories/need_worker_repository.dart';
import 'repositories/search_repository.dart';
import 'repositories/product_ad_repository.dart';
import 'repositories/business_listing_repository.dart';
import 'repositories/event_repository.dart';
import 'repositories/subscription_repository.dart';
import 'repositories/community_repository.dart';
import 'repositories/categories_repository.dart';
import 'repositories/resource_hub_repository.dart';
import 'repositories/explore_country_repository.dart';
import 'viewmodels/categories/categories_viewmodel.dart';
import 'viewmodels/resources/resource_hub_viewmodel.dart';
import 'viewmodels/explore_country/explore_country_viewmodel.dart';
import 'viewmodels/jobs/jobs_viewmodel.dart';
import 'viewmodels/create_post/worker_viewmodel.dart';
import 'viewmodels/create_post/need_worker_viewmodel.dart';
import 'viewmodels/create_post/create_post_viewmodel.dart';
import 'viewmodels/marketplace/marketplace_viewmodel.dart';
import 'viewmodels/business_listing_viewmodel.dart';
import 'viewmodels/events/events_viewmodel.dart';
import 'viewmodels/promotions/promotions_viewmodel.dart';
import 'repositories/banner_ad_repository.dart';
import 'viewmodels/promotions/create_banner_viewmodel.dart';
import 'viewmodels/promotions/banner_advertisements_viewmodel.dart';
import 'viewmodels/promotions/deals_discounts_viewmodel.dart';
import 'viewmodels/promotions/deal_details_viewmodel.dart';
import 'viewmodels/promotions/my_revenue_stats_viewmodel.dart';
import 'viewmodels/promotions/revenue_dashboard_viewmodel.dart';
import 'viewmodels/promotions/revenue_promotions_viewmodel.dart';
import 'viewmodels/promotions/select_ad_to_promote_viewmodel.dart';
import 'viewmodels/promotions/transaction_history_viewmodel.dart';
import 'viewmodels/search/search_viewmodel.dart';
import 'viewmodels/community/community_viewmodel.dart';
import 'viewmodels/community/my_community_posts_viewmodel.dart';
import 'viewmodels/community/group_members_viewmodel.dart';
import 'viewmodels/settings/settings_viewmodel.dart';
import 'viewmodels/onboarding/onboarding_viewmodel.dart';
import 'viewmodels/profile/edit_profile_viewmodel.dart';
import 'viewmodels/support/faq_viewmodel.dart';
import 'viewmodels/support/help_center_viewmodel.dart';
import 'viewmodels/support/community_guidelines_viewmodel.dart';
import 'viewmodels/support/privacy_policy_viewmodel.dart';
import 'viewmodels/support/terms_conditions_viewmodel.dart';
import 'viewmodels/support/contact_us_viewmodel.dart';
import 'repositories/moderation_repository.dart';
import 'viewmodels/moderation/moderation_viewmodel.dart';

import 'services/api/chat_service.dart';
import 'services/api/notification_service.dart';
import 'services/chat_socket_service.dart';
import 'services/notification_socket_service.dart';
import 'services/awesome_notification_service.dart';
import 'services/background_sync_service.dart';

Future<void> startApp() async {
  // Ensure Flutter engine is initialized before calling asynchronous services
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env: $e");
  }

  // Initialize connectivity monitoring
  await ConnectivityService.instance.init();

  // Initialize OS-level notification channels and listeners
  await AwesomeNotificationService.instance.initialize();
  await AwesomeNotificationService.instance.requestPermission();

  // Initialize background sync service (enables closed/background notifications without Google services)
  await BackgroundSyncService.instance.initialize();

  // Initialize shared preferences locally
  final sharedPreferences = await SharedPreferences.getInstance();

  // Instantiate services
  final storageService = StorageService(sharedPreferences);
  final cacheService = CacheService(sharedPreferences);
  final apiService = ApiService(storageService);
  final chatApiService = ChatApiService(apiService);
  final chatSocketService = ChatSocketService();
  final notificationApiService = NotificationApiService(apiService);
  final notificationSocketService = NotificationSocketService();

  // Forward any notifications emitted on chat socket namespace to notification handler
  chatSocketService.onNotificationReceived = (data) {
    notificationSocketService.handlePayload(data, 'chat_socket');
  };

  // Instantiate repositories
  final authRepository = AuthRepository(storageService, apiService);
  final propertyRepository = PropertyRepository(apiService);
  final jobRepository = JobRepository(apiService);
  final workerRepository = WorkerRepository(apiService);
  final needWorkerRepository = NeedWorkerRepository(apiService);
  final searchRepository = SearchRepository(apiService);
  final productAdRepository = ProductAdRepository(apiService);
  final businessListingRepository = BusinessListingRepository(apiService);
  final eventRepository = EventRepository(apiService, storageService);
  final subscriptionRepository = SubscriptionRepository(apiService);
  final communityRepository = CommunityRepository(apiService);
  final categoriesRepository = CategoriesRepository(apiService);
  final resourceHubRepository = ResourceHubRepository(apiService);
  final exploreCountryRepository = ExploreCountryRepository(apiService);
  final bannerAdRepository = BannerAdRepository(apiService);
  final moderationRepository = ModerationRepository(apiService);

  // Global handler for expired sessions (401)
  ApiService.onSessionExpired = () {
    final context = AppRoutes.navigatorKey.currentContext;
    if (context != null) {
      try {
        Provider.of<AuthViewModel>(context, listen: false).handleSessionExpired();
      } catch (_) {}
    }
    final currentState = AppRoutes.navigatorKey.currentState;
    if (currentState != null) {
      final currentRoute = ModalRoute.of(currentState.context)?.settings.name;
      if (currentRoute != AppRoutes.login &&
          currentRoute != AppRoutes.splash &&
          currentRoute != AppRoutes.onboarding &&
          currentRoute != AppRoutes.register) {
        currentState.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  };

  // Auto-connect sockets if previously authenticated
  final existingToken = storageService.getToken();
  final currentUser = storageService.getUser();
  if (existingToken != null && existingToken.isNotEmpty) {
    chatSocketService.connect(existingToken, currentUserId: currentUser?.id);
    notificationSocketService.connect(
      existingToken,
      currentUserId: currentUser?.id,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        // Inject Services
        Provider<StorageService>.value(value: storageService),
        Provider<CacheService>.value(value: cacheService),
        Provider<ApiService>.value(value: apiService),
        Provider<ChatApiService>.value(value: chatApiService),
        Provider<ChatSocketService>.value(value: chatSocketService),
        Provider<NotificationApiService>.value(value: notificationApiService),
        Provider<NotificationSocketService>.value(
          value: notificationSocketService,
        ),
        Provider<AwesomeNotificationService>.value(
          value: AwesomeNotificationService.instance,
        ),

        // Inject Repositories
        Provider<AuthRepository>.value(value: authRepository),
        Provider<PropertyRepository>.value(value: propertyRepository),
        Provider<JobRepository>.value(value: jobRepository),
        Provider<WorkerRepository>.value(value: workerRepository),
        Provider<NeedWorkerRepository>.value(value: needWorkerRepository),
        Provider<SearchRepository>.value(value: searchRepository),
        Provider<ProductAdRepository>.value(value: productAdRepository),
        Provider<BusinessListingRepository>.value(
          value: businessListingRepository,
        ),
        Provider<EventRepository>.value(value: eventRepository),
        Provider<SubscriptionRepository>.value(value: subscriptionRepository),
        Provider<CommunityRepository>.value(value: communityRepository),
        Provider<CategoriesRepository>.value(value: categoriesRepository),
        Provider<ResourceHubRepository>.value(value: resourceHubRepository),
        Provider<ExploreCountryRepository>.value(
          value: exploreCountryRepository,
        ),
        Provider<BannerAdRepository>.value(value: bannerAdRepository),
        Provider<ModerationRepository>.value(value: moderationRepository),

        // Inject ViewModels
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            authRepository,
            chatSocketService: chatSocketService,
            notificationSocketService: notificationSocketService,
            chatApiService: chatApiService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            propertyRepository,
            jobRepository: jobRepository,
            workerRepository: workerRepository,
            productAdRepository: productAdRepository,
            apiService: apiService,
            bannerAdRepository: bannerAdRepository,
            exploreCountryRepository: exploreCountryRepository,
          ),
        ),
        ChangeNotifierProvider<NavigationViewModel>(
          create: (context) => NavigationViewModel(),
        ),
        ChangeNotifierProvider<ChatViewModel>(
          create: (context) => ChatViewModel(
            chatApiService: chatApiService,
            chatSocketService: chatSocketService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<FavouriteAdsViewModel>(
          create: (context) => FavouriteAdsViewModel(
            propertyRepository,
            productAdRepository: productAdRepository,
          ),
        ),
        ChangeNotifierProvider<SubscriptionViewModel>(
          create: (context) => SubscriptionViewModel(subscriptionRepository),
        ),
        ChangeNotifierProvider<PromotionsViewModel>(
          create: (context) => PromotionsViewModel(subscriptionRepository),
        ),
        ChangeNotifierProvider<EventsViewModel>(
          create: (context) => EventsViewModel(eventRepository),
        ),
        ChangeNotifierProvider<MyActivityViewModel>(
          create: (context) => MyActivityViewModel(communityRepository),
        ),
        ChangeNotifierProvider<MyAdsViewModel>(
          create: (context) => MyAdsViewModel(propertyRepository),
        ),
        ChangeNotifierProvider<NotificationsViewModel>(
          create: (context) => NotificationsViewModel(
            apiService: notificationApiService,
            socketService: notificationSocketService,
          ),
        ),
        ChangeNotifierProxyProvider<FavouriteAdsViewModel, PostRoomViewModel>(
          create: (context) => PostRoomViewModel(propertyRepository),
          update: (context, favVM, postRoomVM) =>
              (postRoomVM ?? PostRoomViewModel(propertyRepository))
                ..bindFavouriteAdsViewModel(favVM),
        ),
        ChangeNotifierProxyProvider<FavouriteAdsViewModel, JobsViewModel>(
          create: (context) => JobsViewModel(jobRepository),
          update: (context, favVM, jobsVM) =>
              (jobsVM ?? JobsViewModel(jobRepository))
                ..bindFavouriteAdsViewModel(favVM),
        ),
        ChangeNotifierProvider<WorkerViewModel>(
          create: (context) => WorkerViewModel(workerRepository),
        ),
        ChangeNotifierProvider<MarketplaceViewModel>(
          create: (context) => MarketplaceViewModel(
            productAdRepository,
            authRepository,
          ),
        ),
        ChangeNotifierProvider<NeedWorkerViewModel>(
          create: (context) => NeedWorkerViewModel(needWorkerRepository),
        ),
        ChangeNotifierProvider<CreatePostViewModel>(
          create: (context) => CreatePostViewModel(),
        ),
        ChangeNotifierProvider<BusinessListingViewModel>(
          create: (context) =>
              BusinessListingViewModel(businessListingRepository),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (context) => SearchViewModel(searchRepository),
        ),
        ChangeNotifierProvider<CategoriesViewModel>(
          create: (context) {
            final vm = CategoriesViewModel(categoriesRepository);
            vm.fetchAll();
            return vm;
          },
        ),
        ChangeNotifierProvider<CommunityViewModel>(
          create: (context) => CommunityViewModel(
            communityRepository,
            storageService,
          ),
        ),
        ChangeNotifierProvider<MyCommunityPostsViewModel>(
          create: (context) => MyCommunityPostsViewModel(communityRepository),
        ),
        ChangeNotifierProvider<GroupMembersViewModel>(
          create: (context) => GroupMembersViewModel(communityRepository),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (context) => SettingsViewModel(),
        ),
        ChangeNotifierProvider<OnboardingViewModel>(
          create: (context) => OnboardingViewModel(),
        ),
        ChangeNotifierProvider<DashboardViewModel>(
          create: (context) => DashboardViewModel(),
        ),
        ChangeNotifierProvider<EditProfileViewModel>(
          create: (context) => EditProfileViewModel(),
        ),
        ChangeNotifierProvider<FaqViewModel>(
          create: (context) => FaqViewModel(),
        ),
        ChangeNotifierProvider<HelpCenterViewModel>(
          create: (context) => HelpCenterViewModel(),
        ),
        ChangeNotifierProvider<CommunityGuidelinesViewModel>(
          create: (context) => CommunityGuidelinesViewModel(),
        ),
        ChangeNotifierProvider<PrivacyPolicyViewModel>(
          create: (context) => PrivacyPolicyViewModel(),
        ),
        ChangeNotifierProvider<TermsConditionsViewModel>(
          create: (context) => TermsConditionsViewModel(),
        ),
        ChangeNotifierProvider<ContactUsViewModel>(
          create: (context) => ContactUsViewModel(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<BannerAdvertisementsViewModel>(
          create: (context) => BannerAdvertisementsViewModel(bannerAdRepository),
        ),
        ChangeNotifierProvider<CreateBannerViewModel>(
          create: (context) => CreateBannerViewModel(bannerAdRepository),
        ),
        ChangeNotifierProvider<DealsDiscountsViewModel>(
          create: (context) => DealsDiscountsViewModel(bannerAdRepository),
        ),
        ChangeNotifierProvider<DealDetailsViewModel>(
          create: (context) => DealDetailsViewModel(),
        ),
        ChangeNotifierProvider<MyRevenueStatsViewModel>(
          create: (context) => MyRevenueStatsViewModel(),
        ),
        ChangeNotifierProvider<RevenueDashboardViewModel>(
          create: (context) => RevenueDashboardViewModel(),
        ),
        ChangeNotifierProvider<RevenuePromotionsViewModel>(
          create: (context) => RevenuePromotionsViewModel(),
        ),
        ChangeNotifierProvider<SelectAdToPromoteViewModel>(
          create: (context) => SelectAdToPromoteViewModel(),
        ),
        ChangeNotifierProvider<TransactionHistoryViewModel>(
          create: (context) => TransactionHistoryViewModel(),
        ),
        ChangeNotifierProvider<ResourceHubViewModel>(
          create: (context) {
            final vm = ResourceHubViewModel(
              resourceHubRepository,
              storageService,
            );
            vm.fetchArticles();
            return vm;
          },
        ),
        ChangeNotifierProvider<ExploreCountryViewModel>(
          create: (context) {
            final vm = ExploreCountryViewModel(exploreCountryRepository);
            vm.fetchCountries();
            return vm;
          },
        ),
        ChangeNotifierProvider<ModerationViewModel>(
          create: (context) => ModerationViewModel(moderationRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRoutes.navigatorKey,
      title: 'Desi Connect',
      debugShowCheckedModeBanner: false,

      // Apply clean theme presets
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.system, // Auto toggle light/dark based on device settings
      // Routing configuration
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,

      // Global Responsive & Accessibility Font Scaler Guard
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedMediaQuery = mediaQuery.copyWith(
          textScaler: mediaQuery.textScaler.clamp(
            minScaleFactor: 0.85,
            maxScaleFactor: 1.15,
          ),
        );
        return MediaQuery(
          data: clampedMediaQuery,
          child: ConnectivityWrapper(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
