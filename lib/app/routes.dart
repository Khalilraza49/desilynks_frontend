import 'package:desilynks/views/auth/login_view.dart';
import 'package:flutter/material.dart';
import '../views/splash/splash_view.dart';
import '../views/bottom_bar/bottom_bar_screen.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/auth/verify_view.dart';
import '../views/auth/create_profile_view.dart';
import '../views/auth/reset_password_view.dart';
import '../views/profile/edit_profile_view.dart';
import '../views/notifications/notifications_view.dart';
import '../views/profile/favourite_ads_view.dart';
import '../views/profile/membership_plans_view.dart';
import '../views/profile/membership_benefits_view.dart';
import '../views/profile/refer_earn_view.dart';
import '../views/profile/loyalty_points_view.dart';
import '../views/profile/coupons_view.dart';
import '../views/profile/my_offers_view.dart';
import '../views/profile/checkout_view.dart';
import '../views/profile/my_activity_view.dart';
import '../views/profile/my_ads_view.dart';
import '../views/profile/my_community_posts_view.dart';
import '../views/profile/edit_ad_view.dart';
import '../views/profile/edit_job_view.dart';
import '../views/create_post/create_post_view.dart';
import '../views/create_post/rooms/post_room_view.dart';
import '../views/create_post/jobs/post_job_view.dart';
import '../views/create_post/rooms/my_rooms_view.dart';
import '../views/create_post/rooms/room_details_view.dart';
import '../views/create_post/rooms/room_single_details_view.dart';
import '../views/create_post/rooms/filters_view.dart';
import '../views/profile/public_profile_view.dart';
import '../views/create_post/jobs/jobs_view.dart';
import '../views/create_post/jobs/job_detail_view.dart';
import '../views/create_post/jobs/apply_work_request_view.dart';
import '../views/profile/my_jobs_view.dart';
import '../views/profile/applicants_view.dart';
import '../views/profile/my_applications_view.dart';
import '../views/profile/worker_requests_view.dart';
import '../views/profile/worker_request_detail_view.dart';
import '../views/create_post/worker_profile/post_worker_profile_view.dart';
import '../views/create_post/worker_profile/hire_workers_view.dart';
import '../views/create_post/worker_profile/hire_worker_form_view.dart';
import '../views/create_post/worker_profile/hire_worker_success_view.dart';
import '../views/create_post/need_worker/post_need_worker_view.dart';
import '../views/create_post/product/post_product_view.dart';
import '../views/create_post/event/post_event_view.dart';
import '../views/create_post/business/post_business_listing_view.dart';
import '../views/events/events_view.dart';
import '../views/events/event_detail_view.dart';
import '../models/event_model.dart';
import '../views/marketplace/marketplace_view.dart';
import '../views/marketplace/marketplace_item_detail_view.dart';
import '../views/search/search_view.dart';
import '../views/promotions/select_ad_to_promote_view.dart';
import '../views/promotions/banner_advertisements_view.dart';
import '../views/promotions/create_banner_view.dart';
import '../models/banner_ad_model.dart';
import '../views/promotions/revenue_promotions_view.dart';
import '../views/promotions/revenue_dashboard_view.dart';
import '../views/promotions/my_revenue_stats_view.dart';
import '../views/promotions/transaction_history_view.dart';
import '../views/promotions/deals_discounts_view.dart';
import '../views/promotions/deal_details_view.dart';
import '../views/settings/settings_view.dart';
import '../views/settings/blocked_users_view.dart';
import '../views/community/community_view.dart';
import '../views/community/group_detail_view.dart';
import '../views/community/group_members_view.dart';
import '../views/community/add_members_view.dart';
import '../views/community/all_groups_view.dart';
import '../views/community/create_group_view.dart';
import '../views/create_post/community/post_community_view.dart';
import '../views/support/faq_view.dart';
import '../views/support/help_center_view.dart';
import '../views/support/privacy_policy_view.dart';
import '../views/support/terms_conditions_view.dart';
import '../views/support/community_guidelines_view.dart';
import '../views/support/contact_us_view.dart';
import '../views/home/widgets/explore_spain_view.dart';
import '../views/resources/resource_hub_view.dart';
import '../views/resources/article_detail_view.dart';
import '../views/explore_country/country_detail_view.dart';
import '../views/explore_country/explore_countries_view.dart';
import '../views/explore_country/local_business_view.dart';
import '../models/resource_hub_model.dart';
import '../models/explore_country_model.dart';
import '../models/marketplace_item_model.dart';
import '../models/worker_profile_model.dart';
import '../models/need_worker_model.dart';
import '../models/need_worker_application_model.dart';
import '../models/property_model.dart';
import '../models/business_listing_model.dart';
import '../models/job_model.dart';

enum SlideDirection { rightToLeft, leftToRight, bottomToTop }

class AppRoutes {
  AppRoutes._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verify = '/verify';
  static const String createProfile = '/create-profile';
  static const String home = '/home';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';
  static const String favouriteAds = '/favourite-ads';
  static const String membershipPlans = '/membership-plans';
  static const String membershipBenefits = '/membership-benefits';
  static const String referEarn = '/refer-earn';
  static const String loyaltyPoints = '/loyalty-points';
  static const String coupons = '/coupons';
  static const String myOffers = '/my-offers';
  static const String checkout = '/checkout';
  static const String myActivity = '/my-activity';
  static const String myAds = '/my-ads';
  static const String myCommunityPosts = '/my-community-posts';
  static const String editAd = '/edit-ad';
  static const String createPost = '/create-post';
  static const String postRoom = '/post-room';
  static const String postJob = '/post-job';
  static const String postWorkerProfile = '/post-worker-profile';
  static const String hireWorkers = '/hire-workers';
  static const String hireWorkerForm = '/hire-worker-form';
  static const String applyNeedWorkerForm = '/apply-need-worker-form';
  static const String hireWorkerSuccess = '/hire-worker-success';
  static const String postNeedWorker = '/post-need-worker';
  static const String postProduct = '/post-product';
  static const String postEvent = '/post-event';
  static const String postBusiness = '/post-business';
  static const String events = '/events';
  static const String eventDetail = '/event-detail';
  static const String myRooms = '/my-rooms';
  static const String roomDetails = '/room-details';
  static const String roomSingleDetails = '/room-single-details';
  static const String publicProfile = '/public-profile';
  static const String jobs = '/jobs';
  static const String jobDetail = '/job-detail';
  static const String myJobs = '/my-jobs';
  static const String editJob = '/edit-job';
  static const String applicants = '/applicants';
  static const String myApplications = '/my-applications';
  static const String workerRequests = '/worker-requests';
  static const String workerRequestDetail = '/worker-request-detail';
  static const String filters = '/filters';
  static const String marketplace = '/marketplace';
  static const String marketplaceDetail = '/marketplace-detail';
  static const String search = '/search';
  static const String selectAdToPromote = '/select-ad-to-promote';
  static const String bannerAdvertisements = '/banner-advertisements';
  static const String createBanner = '/create-banner';
  static const String revenuePromotions = '/revenue-promotions';
  static const String revenueDashboard = '/revenue-dashboard';
  static const String myRevenueStats = '/my-revenue-stats';
  static const String transactionHistory = '/transaction-history';
  static const String dealsDiscounts = '/deals-discounts';
  static const String dealDetails = '/deal-details';
  static const String settingsRoute = '/settings';
  static const String blockedUsers = '/blocked-users';
  static const String community = '/community';
  static const String groupDetail = '/group-detail';
  static const String groupMembers = '/group-members';
  static const String addMembers = '/add-members';
  static const String allGroups = '/all-groups';
  static const String createGroup = '/create-group';
  static const String postCommunity = '/post-community';
  static const String faq = '/faq';
  static const String helpCenter = '/help-center';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsConditions = '/terms-conditions';
  static const String communityGuidelines = '/community-guidelines';
  static const String contactUs = '/contact-us';
  static const String exploreSpain = '/explore-spain';
  static const String exploreCountry = '/explore-country';
  static const String exploreCountriesList = '/explore-countries';
  static const String exploreCountryDetail = '/explore-country/detail';
  static const String resourceHub = '/resource-hub';
  static const String resourceHubDetail = '/resource-hub/detail';
  static const String localBusiness = '/local-business';

  static Route<dynamic> _buildAnimatedRoute(
    Widget page, {
    RouteSettings? settings,
    SlideDirection direction = SlideDirection.rightToLeft,
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset beginOffset;
        switch (direction) {
          case SlideDirection.rightToLeft:
            beginOffset = const Offset(1.0, 0.0);
            break;
          case SlideDirection.leftToRight:
            beginOffset = const Offset(-1.0, 0.0);
            break;
          case SlideDirection.bottomToTop:
            beginOffset = const Offset(0.0, 1.0);
            break;
        }

        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final slideAnimation = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(curve);

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  static Route<dynamic> _buildFadeRoute(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        final scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildFadeRoute(const SplashView(), settings: settings);
      case onboarding:
        return _buildAnimatedRoute(const OnboardingView(), settings: settings);
      case roomSingleDetails:
        final property = settings.arguments as PropertyModel;
        return _buildAnimatedRoute(
          RoomSingleDetailsView(property: property),
          settings: settings,
        );
      case publicProfile:
        final owner = settings.arguments as PropertyOwner;
        return _buildAnimatedRoute(
          PublicProfileView(owner: owner),
          settings: settings,
        );
      case register:
        return _buildAnimatedRoute(const RegisterView(), settings: settings);
      case login:
        return _buildAnimatedRoute(const LoginView(), settings: settings);
      case forgotPassword:
        return _buildAnimatedRoute(
          const ForgotPasswordView(),
          settings: settings,
        );
      case resetPassword:
        final email = settings.arguments as String? ?? '';
        return _buildAnimatedRoute(
          ResetPasswordView(email: email),
          settings: settings,
        );
      case verify:
        final args = settings.arguments as Map<String, dynamic>?;
        final phone = args?['phone'] as String? ?? '';
        final registrationData =
            args?['registrationData'] as Map<String, dynamic>?;
        return _buildAnimatedRoute(
          VerifyView(phoneNumber: phone, registrationData: registrationData),
          settings: settings,
        );
      case createProfile:
        final registrationData = settings.arguments as Map<String, dynamic>?;
        return _buildAnimatedRoute(
          CreateProfileView(registrationData: registrationData),
          settings: settings,
        );
      case home:
        return _buildFadeRoute(const BottomBarScreen(), settings: settings);
      case editProfile:
        return _buildAnimatedRoute(const EditProfileView(), settings: settings);
      case notifications:
        return _buildAnimatedRoute(
          const NotificationsView(),
          settings: settings,
          direction: SlideDirection.bottomToTop,
        );
      case favouriteAds:
        return _buildAnimatedRoute(
          const FavouriteAdsView(),
          settings: settings,
        );
      case membershipPlans:
        return _buildAnimatedRoute(
          const MembershipPlansView(),
          settings: settings,
        );
      case membershipBenefits:
        return _buildAnimatedRoute(
          const MembershipBenefitsView(),
          settings: settings,
        );
      case referEarn:
        return _buildAnimatedRoute(const ReferEarnView(), settings: settings);
      case loyaltyPoints:
        return _buildAnimatedRoute(
          const LoyaltyPointsView(),
          settings: settings,
        );
      case coupons:
        return _buildAnimatedRoute(const CouponsView(), settings: settings);
      case myOffers:
        return _buildAnimatedRoute(const MyOffersView(), settings: settings);
      case checkout:
        final args = settings.arguments as Map<String, dynamic>?;
        final planName = args?['planName'] as String? ?? 'Premium';
        final planPrice = args?['planPrice'] as String? ?? '€9.99';
        final isYearly = args?['isYearly'] as bool? ?? false;
        return _buildAnimatedRoute(
          CheckoutView(
            planName: planName,
            planPrice: planPrice,
            isYearly: isYearly,
          ),
          settings: settings,
        );
      case myActivity:
        return _buildAnimatedRoute(const MyActivityView(), settings: settings);
      case myAds:
        final title = settings.arguments as String?;
        return _buildAnimatedRoute(MyAdsView(title: title), settings: settings);
      case myCommunityPosts:
        return _buildAnimatedRoute(
          const MyCommunityPostsView(),
          settings: settings,
        );
      case editAd:
        final args = settings.arguments;
        if (args is BusinessListingModel) {
          return _buildAnimatedRoute(
            EditAdView(business: args),
            settings: settings,
          );
        } else if (args is PropertyModel) {
          return _buildAnimatedRoute(
            EditAdView(property: args),
            settings: settings,
          );
        }
        return _buildAnimatedRoute(
          EditAdView(property: args as PropertyModel),
          settings: settings,
        );
      case editJob:
        final job = settings.arguments;
        return _buildAnimatedRoute(EditJobView(job: job), settings: settings);
      case createPost:
        return _buildAnimatedRoute(
          const CreatePostView(),
          settings: settings,
          direction: SlideDirection.bottomToTop,
        );
      case postRoom:
        return _buildAnimatedRoute(const PostRoomView(), settings: settings);
      case postJob:
        final job = settings.arguments as JobModel?;
        return _buildAnimatedRoute(PostJobView(job: job), settings: settings);
      case postWorkerProfile:
        final workerProfile = settings.arguments as WorkerProfileModel?;
        return _buildAnimatedRoute(
          PostWorkerProfileView(workerProfile: workerProfile),
          settings: settings,
        );
      case hireWorkers:
        return _buildAnimatedRoute(const HireWorkersView(), settings: settings);
      case applyNeedWorkerForm:
        if (settings.arguments is NeedWorkerModel) {
          final post = settings.arguments as NeedWorkerModel;
          return _buildAnimatedRoute(
            ApplyWorkRequestView(post: post),
            settings: settings,
          );
        } else if (settings.arguments is Map<String, dynamic>) {
          final map = settings.arguments as Map<String, dynamic>;
          final post = map['post'] as NeedWorkerModel?;
          if (post != null) {
            return _buildAnimatedRoute(
              ApplyWorkRequestView(post: post),
              settings: settings,
            );
          }
        }
        return _buildAnimatedRoute(const JobsView(), settings: settings);
      case hireWorkerForm:
        if (settings.arguments is NeedWorkerModel) {
          final post = settings.arguments as NeedWorkerModel;
          return _buildAnimatedRoute(
            ApplyWorkRequestView(post: post),
            settings: settings,
          );
        }
        final worker = settings.arguments as Map<String, dynamic>?;
        return _buildAnimatedRoute(
          HireWorkerFormView(worker: worker),
          settings: settings,
        );
      case hireWorkerSuccess:
        final requestData = settings.arguments as Map<String, dynamic>?;
        return _buildFadeRoute(
          HireWorkerSuccessView(requestData: requestData),
          settings: settings,
        );
      case postNeedWorker:
        final needWorkerPost = settings.arguments as NeedWorkerModel?;
        return _buildAnimatedRoute(
          PostNeedWorkerView(needWorkerPost: needWorkerPost),
          settings: settings,
        );
      case postProduct:
        return _buildAnimatedRoute(const PostProductView(), settings: settings);
      case myRooms:
        return _buildAnimatedRoute(const MyRoomsView(), settings: settings);
      case roomDetails:
        return _buildAnimatedRoute(const RoomDetailsView(), settings: settings);
      case jobs:
        return _buildAnimatedRoute(const JobsView(), settings: settings);
      case jobDetail:
        final job = settings.arguments;
        return _buildAnimatedRoute(JobDetailView(job: job), settings: settings);
      case myJobs:
        return _buildAnimatedRoute(const MyJobsView(), settings: settings);
      case applicants:
        final job = settings.arguments;
        return _buildAnimatedRoute(
          ApplicantsView(job: job),
          settings: settings,
        );
      case myApplications:
        return _buildAnimatedRoute(
          const MyApplicationsView(),
          settings: settings,
        );
      case workerRequests:
        final args = settings.arguments;
        return _buildAnimatedRoute(
          WorkerRequestsView(
            initialPost: args is NeedWorkerModel ? args : null,
            initialPostId: args is String ? args : null,
          ),
          settings: settings,
        );
      case workerRequestDetail:
        final args = settings.arguments;
        if (args is NeedWorkerApplicationModel) {
          return _buildAnimatedRoute(
            WorkerRequestDetailView(application: args),
            settings: settings,
          );
        } else if (args is Map<String, dynamic>) {
          return _buildAnimatedRoute(
            WorkerRequestDetailView(
              application: args['application'] as NeedWorkerApplicationModel,
              post: args['post'] as NeedWorkerModel?,
            ),
            settings: settings,
          );
        }
        return _buildAnimatedRoute(const SizedBox.shrink(), settings: settings);
      case filters:
        return _buildAnimatedRoute(
          const FiltersView(),
          settings: settings,
          direction: SlideDirection.bottomToTop,
        );
      case marketplace:
        return _buildAnimatedRoute(const MarketplaceView(), settings: settings);
      case marketplaceDetail:
        final item = settings.arguments as MarketplaceItemModel;
        return _buildAnimatedRoute(
          MarketplaceItemDetailView(item: item),
          settings: settings,
        );
      case search:
        return _buildAnimatedRoute(
          const SearchView(),
          settings: settings,
          direction: SlideDirection.bottomToTop,
        );
      case postEvent:
        return _buildAnimatedRoute(const PostEventView(), settings: settings);
      case postBusiness:
        return _buildAnimatedRoute(
          const PostBusinessListingView(),
          settings: settings,
        );
      case events:
        return _buildAnimatedRoute(const EventsView(), settings: settings);
      case eventDetail:
        final event = settings.arguments as EventModel;
        return _buildAnimatedRoute(
          EventDetailView(event: event),
          settings: settings,
        );
      case selectAdToPromote:
        return _buildAnimatedRoute(
          const SelectAdToPromoteView(),
          settings: settings,
        );
      case bannerAdvertisements:
        return _buildAnimatedRoute(
          const BannerAdvertisementsView(),
          settings: settings,
        );
      case createBanner:
        final pos = settings.arguments as BannerAdPosition?;
        return _buildAnimatedRoute(
          CreateBannerView(initialPosition: pos),
          settings: settings,
        );
      case revenuePromotions:
        return _buildAnimatedRoute(
          const RevenuePromotionsView(),
          settings: settings,
        );
      case revenueDashboard:
        return _buildAnimatedRoute(
          const RevenueDashboardView(),
          settings: settings,
        );
      case myRevenueStats:
        return _buildAnimatedRoute(
          const MyRevenueStatsView(),
          settings: settings,
        );
      case transactionHistory:
        return _buildAnimatedRoute(
          const TransactionHistoryView(),
          settings: settings,
        );
      case dealsDiscounts:
        return _buildAnimatedRoute(
          const DealsDiscountsView(),
          settings: settings,
        );
      case dealDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildAnimatedRoute(
          DealDetailsView(
            storeName: args?['storeName'] as String?,
            category: args?['category'] as String?,
            rating: args?['rating'] as String?,
            reviewCount: args?['reviewCount'] as String?,
            discountTitle: args?['discountTitle'] as String?,
            discountTag: args?['discountTag'] as String?,
            membershipEligibility: args?['membershipEligibility'] as String?,
            validUntil: args?['validUntil'] as String?,
            location: args?['location'] as String?,
            minSpend: args?['minSpend'] as String?,
            detailsText: args?['detailsText'] as String?,
            imageUrl: args?['imageUrl'] as String?,
            phoneNumber: args?['phoneNumber'] as String?,
            destinationLink: args?['destinationLink'] as String?,
            bannerAdId: args?['bannerAdId'] as String?,
          ),
          settings: settings,
        );
      case settingsRoute:
        return _buildAnimatedRoute(const SettingsView(), settings: settings);
      case blockedUsers:
        return _buildAnimatedRoute(
          const BlockedUsersView(),
          settings: settings,
        );
      case community:
        return _buildAnimatedRoute(const CommunityView(), settings: settings);
      case groupDetail:
        final group = settings.arguments as Map<String, dynamic>?;
        return _buildAnimatedRoute(
          GroupDetailView(group: group),
          settings: settings,
        );
      case groupMembers:
        final group = settings.arguments as Map<String, dynamic>?;
        return _buildAnimatedRoute(
          GroupMembersView(group: group),
          settings: settings,
        );
      case addMembers:
        final group = settings.arguments as Map<String, dynamic>?;
        return _buildAnimatedRoute(
          AddMembersView(group: group),
          settings: settings,
        );
      case allGroups:
        return _buildAnimatedRoute(const AllGroupsView(), settings: settings);
      case createGroup:
        return _buildAnimatedRoute(const CreateGroupView(), settings: settings);
      case postCommunity:
        final postArgs = settings.arguments as Map<String, dynamic>?;
        return _buildAnimatedRoute(
          PostCommunityView(
            initialGroupId:
                postArgs?['groupId'] as String? ?? postArgs?['id'] as String?,
            initialGroupName:
                postArgs?['groupName'] as String? ??
                postArgs?['title'] as String?,
          ),
          settings: settings,
          direction: SlideDirection.bottomToTop,
        );
      case faq:
        return _buildAnimatedRoute(const FaqView(), settings: settings);
      case helpCenter:
        return _buildAnimatedRoute(const HelpCenterView(), settings: settings);
      case privacyPolicy:
        return _buildAnimatedRoute(
          const PrivacyPolicyView(),
          settings: settings,
        );
      case termsConditions:
        return _buildAnimatedRoute(
          const TermsConditionsView(),
          settings: settings,
        );
      case contactUs:
        return _buildAnimatedRoute(
          const ContactUsView(),
          settings: settings,
        );
      case communityGuidelines:
        return _buildAnimatedRoute(
          const CommunityGuidelinesView(),
          settings: settings,
        );
      case exploreSpain:
        return _buildAnimatedRoute(
          const ExploreSpainView(),
          settings: settings,
        );
      case exploreCountry:
      case exploreCountriesList:
        return _buildAnimatedRoute(
          const ExploreCountriesView(),
          settings: settings,
        );
      case exploreCountryDetail:
        if (settings.arguments is ExploreCountry) {
          final country = settings.arguments as ExploreCountry;
          return _buildAnimatedRoute(
            CountryDetailView(countryId: country.id, initialCountry: country),
            settings: settings,
          );
        } else if (settings.arguments is String) {
          return _buildAnimatedRoute(
            CountryDetailView(countryId: settings.arguments as String),
            settings: settings,
          );
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildAnimatedRoute(
            CountryDetailView(
              countryId: args['id'] as String,
              initialCountry: args['country'] as ExploreCountry?,
            ),
            settings: settings,
          );
        }
        return _buildAnimatedRoute(
          const ExploreCountriesView(),
          settings: settings,
        );
      case resourceHub:
        return _buildAnimatedRoute(const ResourceHubView(), settings: settings);
      case localBusiness:
        return _buildAnimatedRoute(
          const LocalBusinessView(),
          settings: settings,
        );
      case resourceHubDetail:
        if (settings.arguments is ResourceHubArticle) {
          final article = settings.arguments as ResourceHubArticle;
          return _buildAnimatedRoute(
            ArticleDetailView(articleId: article.id, initialArticle: article),
            settings: settings,
          );
        } else if (settings.arguments is String) {
          return _buildAnimatedRoute(
            ArticleDetailView(articleId: settings.arguments as String),
            settings: settings,
          );
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildAnimatedRoute(
            ArticleDetailView(
              articleId: args['id'] as String,
              initialArticle: args['article'] as ResourceHubArticle?,
            ),
            settings: settings,
          );
        }
        return _buildAnimatedRoute(const ResourceHubView(), settings: settings);

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
