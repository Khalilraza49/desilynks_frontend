import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // App details
  // static const String appName = 'Desi Lynks';
  static String get baseUrl => dotenv.env['BASE_URL']!;
  static String get adminBaseUrl => dotenv.env['ADMIN_BASE_URL']!;

  // Weather APIs
  static String get openMeteoUrl => dotenv.env['OPEN_METEO_URL']!;
  static String get openWeatherMapUrl => dotenv.env['OPEN_WEATHER_MAP_URL']!;
  static String get openWeatherMapApiKey =>
      dotenv.env['OPEN_WEATHER_MAP_API_KEY']!;

  // Prayer Times API (Aladhan)
  static String get aladhanUrl => dotenv.env['ALADHAN_URL']!;

  // Currency Exchange Rates API (ExchangeRate-API)
  static String get exchangeRateUrl => dotenv.env['EXCHANGE_RATE_URL']!;

  static const String registerEndpoint = '/auth/register';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String resendOtpEndpoint = '/auth/resend-otp';
  static const String loginEndpoint = '/auth/login';
  static const String googleLoginEndpoint = '/auth/google-login';
  static const String appleLoginEndpoint = '/auth/apple-login';
  static const String facebookLoginEndpoint = '/auth/facebook-login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String logoutEndpoint = '/auth/logout';

  // User Module Endpoints
  static const String userProfileEndpoint = '/user';
  static const String userProfilePhotoEndpoint = '/user/profile-photo';
  static const String deleteAccountEndpoint = '/user';
  static String userProfileByIdEndpoint(String id) => '/user/$id';

  // Support Module Endpoints
  static const String supportFormEndpoint = '/support-form';

  // Moderation Module Endpoints
  static const String reportEndpoint = '/report';
  static const String blockListEndpoint = '/block';
  static String blockUserEndpoint(String userId) => '/block/$userId';
  static String unblockUserEndpoint(String userId) => '/block/$userId';

  // Property Module Endpoints
  static const String propertyEndpoint = '/property';
  static const String userPropertiesEndpoint = '/property/user';

  static String propertyDetailsEndpoint(String id) => '/property/$id';
  static String propertyPhotosEndpoint(String id) => '/property/$id/photos';
  static String propertyVideoEndpoint(String id) => '/property/$id/video';
  static String propertyMarkRentedEndpoint(String id) =>
      '/property/$id/mark-rented';
  static String propertyMarkInactiveEndpoint(String id) =>
      '/property/$id/mark-inactive';
  static String propertyMarkActiveEndpoint(String id) =>
      '/property/$id/mark-active';
  static String propertyLikeEndpoint(String id) => '/property/$id/like';

  // Job Module Endpoints
  static const String jobEndpoint = '/job'; // Create New Job
  static const String userJobsEndpoint =
      '/job/user'; //Get User's Own Posted Jobs
  static String jobDetailsEndpoint(String id) => '/job/$id'; //Get Job by ID
  static String jobMarkClosedEndpoint(String id) => '/job/$id/mark-closed';
  static String jobMarkArchivedEndpoint(String id) => '/job/$id/mark-archived';

  // Application Endpoints
  static String jobApplyEndpoint(String id) => '/job/$id/apply';
  static const String userApplicationsEndpoint = '/job/applications/me';
  static String applicationDetailsEndpoint(String id) => '/job/application/$id';
  static String withdrawApplicationEndpoint(String id) =>
      '/job/application/$id/withdraw';
  static String updateApplicationStatusEndpoint(String id) =>
      '/job/application/$id/status';
  static const String bulkUpdateApplicationStatusEndpoint =
      '/job/applications/bulk-status';
  static const String employerApplicationStatsEndpoint =
      '/job/applications/stats/employer';
  static const String applicantApplicationStatsEndpoint =
      '/job/applications/stats/me';
  static String jobApplicationsEndpoint(String id) => '/job/$id/applications';

  // Worker Profile Module Endpoints
  static const String workerProfileEndpoint = '/worker-profile';
  static const String userWorkerProfileEndpoint = '/worker-profile/me';
  static String workerProfileDetailsEndpoint(String id) =>
      '/worker-profile/$id';
  static String workerProfileWorkPhotosEndpoint(String id) =>
      '/worker-profile/$id/work-photos';
  static String workerProfileCertificatesEndpoint(String id) =>
      '/worker-profile/$id/certificates';

  // Need-a-Worker Module Endpoints
  static const String needWorkerEndpoint = '/need-worker';
  static const String needWorkerMyPostsEndpoint = '/need-worker/me';
  static String needWorkerByIdEndpoint(String id) => '/need-worker/$id';
  static String needWorkerUpdateEndpoint(String id) => '/need-worker/$id';
  static String needWorkerDeleteEndpoint(String id) => '/need-worker/$id';
  static String needWorkerReferencePhotosEndpoint(String id) =>
      '/need-worker/$id/reference-photos';
  static String needWorkerApplyEndpoint(String id) => '/need-worker/$id/apply';
  static const String needWorkerMyApplicationsEndpoint =
      '/need-worker/applications/me';
  static String needWorkerWithdrawEndpoint(String id) =>
      '/need-worker/application/$id/withdraw';
  static String needWorkerPostApplicationsEndpoint(String id) =>
      '/need-worker/$id/applications';
  static String needWorkerAcceptEndpoint(String id) =>
      '/need-worker/application/$id/accept';
  static String needWorkerRejectEndpoint(String id) =>
      '/need-worker/application/$id/reject';

  // Hire Worker Endpoint
  static String hireWorkerEndpoint(String workerId) =>
      '/worker-profile/$workerId/hire';

  // Search Module Endpoints
  static const String searchPropertiesEndpoint = '/search/properties';
  static const String searchJobsEndpoint = '/search/jobs';
  static const String searchWorkerProfilesEndpoint = '/search/worker-profiles';
  static const String searchSuggestEndpoint = '/search/suggest';
  static const String searchHealthEndpoint = '/search-health';

  // Product Ad Module Endpoints
  static const String productAdEndpoint = '/product-ad';
  static const String myProductAdsEndpoint = '/product-ad/my-ads';
  static String productAdByIdEndpoint(String id) => '/product-ad/$id';
  static String productAdPhotosEndpoint(String id) => '/product-ad/$id/photos';
  static String productAdSendOfferEndpoint(String id) =>
      '/product-ad/$id/send-offer';
  static const String myProductOffersEndpoint = '/product-ad/my-offers';
  static String productAdOffersOnMyAdEndpoint(String id) =>
      '/product-ad/$id/offers';
  static String acceptProductOfferEndpoint(String offerId) =>
      '/product-ad/offers/$offerId/accept';
  static String rejectProductOfferEndpoint(String offerId) =>
      '/product-ad/offers/$offerId/reject';
  static String cancelProductOfferEndpoint(String adId) =>
      '/product-ad/$adId/cancel-offer';
  static String productAdStatusEndpoint(String id) => '/product-ad/$id/status';
  static String saveProductAdEndpoint(String id) => '/product-ad/$id/save';

  // Business Listing Module Endpoints
  static const String businessListingEndpoint = '/business-listing';
  static const String businessListingMyListingsEndpoint =
      '/business-listing/my-listings';
  static String businessListingByIdEndpoint(String id) =>
      '/business-listing/$id';
  static String businessListingAnalyticsEndpoint(String id) =>
      '/business-listing/$id/analytics';
  static String businessListingUpdateEndpoint(String id) =>
      '/business-listing/$id';
  static String businessListingStatusEndpoint(String id) =>
      '/business-listing/$id/status';
  static String businessListingLogoEndpoint(String id) =>
      '/business-listing/$id/logo';
  static String businessListingCoverPhotoEndpoint(String id) =>
      '/business-listing/$id/cover-photo';
  static String businessListingGalleryEndpoint(String id) =>
      '/business-listing/$id/gallery';
  static String businessListingClickEndpoint(String id) =>
      '/business-listing/$id/click';
  static String businessListingDeleteEndpoint(String id) =>
      '/business-listing/$id';

  // Events Module Endpoints
  static const String eventsEndpoint = '/community/event';
  static const String myEventsEndpoint = '/community/event/me';
  static String eventByIdEndpoint(String id) => '/community/event/$id';

  // Subscriptions & Promotions Endpoints
  static const String subscriptionsEndpoint = '/subscriptions';
  static const String checkoutEndpoint = '/checkout';
  static const String promoteAdEndpoint = '/promotions/boost';

  // Chat Module Endpoints
  static const String chatSocketNamespace = '/chat';
  static const String chatConversationsEndpoint = '/chat/conversations';
  static String chatMessagesEndpoint(String conversationId) =>
      '/chat/conversations/$conversationId/messages';
  static String chatMarkReadEndpoint(String conversationId) =>
      '/chat/conversations/$conversationId/read';
  static String chatDeleteConversationEndpoint(String conversationId) =>
      '/chat/conversations/$conversationId';
  static const String chatUnreadCountEndpoint = '/chat/unread-count';

  // FCM Token Endpoints
  static const String fcmRegisterTokenEndpoint = '/fcm-token/register';
  static const String fcmRemoveTokenEndpoint = '/fcm-token/remove';

  // ──────────────────────────────────────────────────────────────────────────
  // Notification Module Endpoints
  static const String notificationsEndpoint = '/notifications';
  static const String notificationsUnreadCountEndpoint =
      '/notifications/unread-count';
  static const String notificationsReadAllEndpoint = '/notifications/read-all';
  static String notificationByIdEndpoint(String id) => '/notifications/$id';
  static String notificationMarkReadEndpoint(String id) =>
      '/notifications/$id/read';
  static String notificationDeleteEndpoint(String id) => '/notifications/$id';

  // ──────────────────────────────────────────────────────────────────────────
  // Community Module Endpoints
  // ──────────────────────────────────────────────────────────────────────────
  // Post Controller Endpoints
  static const String communityPostEndpoint = '/community/post';
  static const String communityMyPostsEndpoint = '/community/post/me';
  static String communityGroupPostsEndpoint(String groupId) =>
      '/community/post/group/$groupId';
  static String communityPostByIdEndpoint(String id) => '/community/post/$id';

  // Post Interaction Endpoints
  static String communityPostLikeEndpoint(String postId) =>
      '/community/post/$postId/interaction/like';
  static String communityPostShareEndpoint(String postId) =>
      '/community/post/$postId/interaction/share';

  // Poll Endpoints
  static String communityPollVoteEndpoint(String postId) =>
      '/community/post/$postId/poll/vote';
  static String communityPollResultsEndpoint(String postId) =>
      '/community/post/$postId/poll';

  // Comment Endpoints
  static const String communityCommentEndpoint = '/community/post/comment';
  static const String communityMyCommentsEndpoint =
      '/community/post/comment/me';
  static String communityPostCommentsEndpoint(String postId) =>
      '/community/post/comment/$postId';
  static String communityCommentByIdEndpoint(String id) =>
      '/community/post/comment/$id';

  // ──────────────────────────────────────────────────────────────────────────
  // Community Group Endpoints
  // ──────────────────────────────────────────────────────────────────────────
  static const String communityGroupEndpoint = '/community/group';
  static const String communityGroupMeEndpoint = '/community/group/me';
  static String communityGroupByIdEndpoint(String id) => '/community/group/$id';
  static String communityGroupCoverPhotoEndpoint(String id) =>
      '/community/group/$id/cover-photo';
  static String communityGroupToggleArchiveEndpoint(String id) =>
      '/community/group/$id/toggle-archive';

  // ──────────────────────────────────────────────────────────────────────────
  // Community Group Member Endpoints
  // ──────────────────────────────────────────────────────────────────────────
  static String communityGroupMemberEndpoint(String groupId) =>
      '/community/group/$groupId/member';
  static String communityGroupMemberAdminEndpoint(String groupId) =>
      '/community/group/$groupId/member/admin';
  static String communityGroupMemberMeEndpoint(String groupId) =>
      '/community/group/$groupId/member/me';
  static String communityGroupMemberJoinEndpoint(String groupId) =>
      '/community/group/$groupId/member/join';
  static String communityGroupMemberLeaveEndpoint(String groupId) =>
      '/community/group/$groupId/member/leave';
  static String communityGroupMemberByIdEndpoint(
    String groupId,
    String userId,
  ) => '/community/group/$groupId/member/$userId';
  static String communityGroupMemberStatusEndpoint(
    String groupId,
    String userId,
  ) => '/community/group/$groupId/member/$userId/status';
  static String communityGroupMemberRoleEndpoint(
    String groupId,
    String userId,
  ) => '/community/group/$groupId/member/$userId/role';

  // ──────────────────────────────────────────────────────────────────────────
  // Categories & Types Module Endpoints (public, no auth required)
  // ──────────────────────────────────────────────────────────────────────────
  static const String businessCategoriesEndpoint =
      '/categories-and-types/business-categories';
  static const String jobCategoriesEndpoint =
      '/categories-and-types/job-categories';
  static const String needWorkerTypesEndpoint =
      '/categories-and-types/need-worker-types';
  static const String propertyFeaturesEndpoint =
      '/categories-and-types/property-features-and-amenities';

  // ──────────────────────────────────────────────────────────────────────────
  // Resource Hub Module Endpoints
  // ──────────────────────────────────────────────────────────────────────────
  static const String resourceHubEndpoint = '/resource-hub';
  static const String resourceHubSavedEndpoint = '/resource-hub/saved';
  static String resourceHubDetailEndpoint(String id) => '/resource-hub/$id';
  static String resourceHubSaveEndpoint(String id) => '/resource-hub/$id/save';

  // ──────────────────────────────────────────────────────────────────────────
  // Explore Country Module Endpoints (public, no auth required)
  // ──────────────────────────────────────────────────────────────────────────
  static const String exploreCountryEndpoint = '/explore-country';
  static String exploreCountryDetailEndpoint(String id) =>
      '/explore-country/$id';

  // ──────────────────────────────────────────────────────────────────────────
  // Banner Ad Module Endpoints
  // ──────────────────────────────────────────────────────────────────────────
  static const String bannerAdEndpoint = '/banner-ad';
  static const String myBannerAdsEndpoint = '/banner-ad/my-ads';
  static String bannerAdByIdEndpoint(String id) => '/banner-ad/$id';
  static String bannerAdPhotoEndpoint(String id) => '/banner-ad/$id/photo';
  static String bannerAdStatusEndpoint(String id) => '/banner-ad/$id/status';
  static String bannerAdRenewEndpoint(String id) => '/banner-ad/$id/renew';
  static String bannerAdViewEndpoint(String id) => '/banner-ad/$id/view';
  static String bannerAdClickEndpoint(String id) => '/banner-ad/$id/click';
}
