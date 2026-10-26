import 'package:desilynks/app/theme.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/viewmodels/community/community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/my_ads_viewmodel.dart';
import 'package:desilynks/viewmodels/marketplace/marketplace_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/need_worker_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/favourite_ads_viewmodel.dart';
import 'package:desilynks/viewmodels/events/events_viewmodel.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/widgets/user_avatar.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';

class ProfileView extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const ProfileView({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final communityViewModel = Provider.of<CommunityViewModel>(context);
    final jobsViewModel = Provider.of<JobsViewModel>(context);
    final myAdsViewModel = Provider.of<MyAdsViewModel>(context);
    final marketplaceViewModel = Provider.of<MarketplaceViewModel>(context);
    final needWorkerViewModel = Provider.of<NeedWorkerViewModel>(context);
    final favouriteViewModel = Provider.of<FavouriteAdsViewModel>(context);
    final eventsViewModel = Provider.of<EventsViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (authViewModel.isAuthenticated &&
          !communityViewModel.hasFetchedMyPosts &&
          !communityViewModel.isLoading) {
        communityViewModel.fetchMyPosts();
      }
      if (authViewModel.isAuthenticated &&
          !eventsViewModel.hasFetchedMyEvents &&
          !eventsViewModel.isLoadingMyEvents) {
        eventsViewModel.fetchMyEvents();
      }
    });

    final user = authViewModel.currentUser;
    final bool isLoggedIn = authViewModel.isAuthenticated;
    final int postedPostsCount = communityViewModel.myPostsTotalCount;
    final int postedJobsCount = jobsViewModel.userJobs.length;
    final int roomAdsCount = myAdsViewModel.userAds.length;
    final int productAdsCount = marketplaceViewModel.myAds.length;
    final int workerPostsCount = needWorkerViewModel.myPosts.length;
    final int eventsPostsCount = eventsViewModel.myEvents.length;
    final int totalMyAdsCount =
        roomAdsCount + productAdsCount + workerPostsCount + eventsPostsCount;
    final int savedFavsCount = favouriteViewModel.favouritedIds.length;
    final int myApplicationsCount = jobsViewModel.applicantApplications.length;

    // Resolve name and details
    final String welcomeName = isLoggedIn && user?.firstName != null
        ? '${user!.firstName} ${user.lastName ?? ''}'.trim()
        : 'User Name';

    final String userCity = user?.address?.city ?? 'Madrid';
    final String userCountry = user?.address?.country ?? 'Spain';
    final String userEmail = user?.email ?? 'alikhan@gmail.com';
    final String userPhone = user?.phoneNumber ?? '+34 612 345 678';

    if ((authViewModel.isLoading && user == null) ||
        (authViewModel.isAuthenticated && user == null)) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(child: ProfileSkeleton()),
      );
    }

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double headerBgHeight =
        statusBarHeight +
        (isLandscape ? 125.0 : (context.scaleH(190.0)).clamp(170.0, 220.0));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Blue/Purple Gradient Header Container (background spans full screen width)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerBgHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF014EF3), // Vibrant blue matching gradientStart
                      AppColors
                          .secondaryPurple, // Rich purple matching gradientEnd
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // 2. Main Content Column (expands as screen expands)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Text Container
                Padding(
                  padding: EdgeInsets.only(
                    top:
                        statusBarHeight +
                        (isLandscape
                            ? 6.0
                            : (context.scaleH(16.0)).clamp(12.0, 20.0)),
                    left: context.hMargin,
                    right: context.hMargin,
                    bottom: isLandscape
                        ? 8.0
                        : (context.scaleH(16.0)).clamp(12.0, 20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row (Title + Menu + Settings)
                      Row(
                        children: [
                          Text(
                            'My Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(18),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          // Hamburger Menu Button
                          GestureDetector(
                            onTap: onMenuPressed,
                            child: Container(
                              width: (context.scale(36.0)).clamp(32.0, 40.0),
                              height: (context.scale(36.0)).clamp(32.0, 40.0),
                              padding: EdgeInsets.all(
                                (context.scale(8.0)).clamp(6.0, 10.0),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SvgPicture.asset(
                                AppIcons.menuSvg,
                                width: (context.scale(18.0)).clamp(16.0, 22.0),
                                height: (context.scale(18.0)).clamp(16.0, 22.0),
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: (context.scale(10.0)).clamp(8.0, 14.0),
                          ),
                          // Settings Button
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.settingsRoute,
                            ),
                            child: Container(
                              width: (context.scale(36.0)).clamp(32.0, 40.0),
                              height: (context.scale(36.0)).clamp(32.0, 40.0),
                              padding: EdgeInsets.all(
                                (context.scale(8.0)).clamp(6.0, 10.0),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SvgPicture.asset(
                                AppIcons.settingsSvg,
                                width: (context.scale(18.0)).clamp(16.0, 22.0),
                                height: (context.scale(18.0)).clamp(16.0, 22.0),
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: isLandscape
                            ? 4.0
                            : (context.scaleH(12.0)).clamp(8.0, 16.0),
                      ),
                      // Greeting & Name
                      if (isLandscape)
                        Row(
                          children: [
                            Text(
                              'Welcome Back 👋, ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: context.sp(13),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                welcomeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.sp(18),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: context.sp(13),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  width: (context.scale(4.0)).clamp(3.0, 6.0),
                                ),
                                Text(
                                  '👋',
                                  style: TextStyle(fontSize: context.sp(13)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: (context.scaleH(4.0)).clamp(2.0, 6.0),
                            ),
                            Text(
                              welcomeName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(24),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // 2. Overlapping User Info Card & Body Sections
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.hMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(
                          isLandscape ? 12.0 : context.cardPad,
                        ),
                        child: Column(
                          children: [
                            // Top Part (Avatar, Rating, Location, Edit Button)
                            Row(
                              children: [
                                // Avatar with camera badge
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      AppRoutes.editProfile,
                                    );
                                    if (result != null &&
                                        result is int &&
                                        context.mounted) {
                                      context
                                          .read<NavigationViewModel>()
                                          .handleTabSelected(context, result);
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      UserAvatar(
                                        photoUrl: isLoggedIn
                                            ? user?.profilePhotoUrl
                                            : null,
                                        size: isLandscape
                                            ? 56.0
                                            : (context.scale(
                                                72.0,
                                              )).clamp(56.0, 76.0),
                                        fallbackBgColor: Colors.blue.shade50,
                                        fallbackIconColor: Colors.blue.shade400,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(
                                            isLandscape
                                                ? 3.0
                                                : context.scale(4.0),
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBlue,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: SvgPicture.asset(
                                            AppIcons.cameraSvg,
                                            width: isLandscape
                                                ? 10.0
                                                : (context.scale(
                                                    11.0,
                                                  )).clamp(10.0, 14.0),
                                            height: isLandscape
                                                ? 10.0
                                                : (context.scale(
                                                    11.0,
                                                  )).clamp(10.0, 14.0),
                                            colorFilter: const ColorFilter.mode(
                                              Colors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Middle details column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Basic badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightOrange,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              AppIcons.crownSvg,
                                              width: 11,
                                              height: 11,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    AppColors.amberOrange,
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Basic',
                                              style: TextStyle(
                                                color: AppColors.amberOrange,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Star Rating
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppIcons.starFavoriteSvg,
                                            width: 15,
                                            height: 15,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.accentYellow,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            '4.8',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.slate800,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            '(124 Reviews)',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.slate400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Location Pin
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppIcons.locationSvg,
                                            width: 13,
                                            height: 13,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.slate400,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$userCity, $userCountry',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.slate400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.pushNamed(
                                          context,
                                          AppRoutes.editProfile,
                                        );
                                        if (result != null &&
                                            result is int &&
                                            context.mounted) {
                                          context
                                              .read<NavigationViewModel>()
                                              .handleTabSelected(context, result);
                                        }
                                      },
                                      icon: SvgPicture.asset(
                                        AppIcons.editSvg,
                                        width: 13,
                                        height: 13,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.primaryBlue,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      label: const Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: AppColors.lightBlue,
                                        side: BorderSide.none,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () {
                                        final currentUserId = user?.id;
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.publicProfile,
                                          arguments: currentUserId,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.remove_red_eye_outlined,
                                              size: 13,
                                              color: AppColors.slate600,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Public View',
                                              style: TextStyle(
                                                color: AppColors.slate700,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: isLandscape ? 8.0 : 16.0),
                            // Stats row container
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isLandscape ? 6.0 : 12.0,
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: _buildStatColumn(
                                      context,
                                      '$postedJobsCount',
                                      'Jobs',
                                      AppColors.primaryBlue,
                                    ),
                                  ),
                                  _buildDivider(context),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: _buildStatColumn(
                                      context,
                                      '$roomAdsCount',
                                      'Rooms',
                                      AppColors.orangeAccent,
                                    ),
                                  ),
                                  _buildDivider(context),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: _buildStatColumn(
                                      context,
                                      '$productAdsCount',
                                      'Ads',
                                      AppColors.primaryPurple,
                                    ),
                                  ),
                                  _buildDivider(context),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: _buildStatColumn(
                                      context,
                                      '$workerPostsCount',
                                      'Posts',
                                      AppColors.emerald,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: isLandscape ? 8.0 : 20.0),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isLandscape ? 6.0 : 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.softGreen,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.greenLight200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.successGreen,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Available For Hire',
                                    style: TextStyle(
                                      color: AppColors.green700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Switch(
                                    value: authViewModel.isAvailableForHire,
                                    onChanged: (val) {
                                      authViewModel.setAvailableForHire(val);
                                    },
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: AppColors.emerald,
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: AppColors.slate200,
                                    trackOutlineColor: WidgetStateProperty.all(
                                      Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isLandscape ? 8.0 : 20.0),
                          ],
                        ),
                      ),

                      // 3. Availability Banner
                      SizedBox(height: isLandscape ? 10.0 : 14.0),

                      // 4. Contact Details Badges
                      Row(
                        children: [
                          Flexible(
                            child: _buildContactBadge(
                              context: context,
                              svgIcon: AppIcons.emailSvg,
                              iconColor: AppColors.primaryBlue,
                              text: userEmail,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _buildContactBadge(
                              context: context,
                              svgIcon: AppIcons.callSvg,
                              iconColor: AppColors.emerald,
                              text: userPhone,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _buildContactBadge(
                              context: context,
                              svgIcon: AppIcons.calendarSvg,
                              iconColor: AppColors.orangeAccent,
                              text: 'Since Jan 2026',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isLandscape ? 10.0 : 14.0),

                      // 5. Current Plan Banner
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.membershipPlans,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 88),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.secondaryPurple,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryPurple.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'CURRENT: BASIC PLAN',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Upgrade to Premium',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Post more ads · Reach more people',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  AppIcons.crownSvg,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.accentYellow,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 6. Activity Buttons Row
                      Row(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.myActivity,
                                );
                              },
                              icon: SvgPicture.asset(
                                AppIcons.trackbookSvg,
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.slate600,
                                  BlendMode.srcIn,
                                ),
                              ),
                              label: const Text(
                                'My Activity',
                                style: TextStyle(
                                  color: AppColors.slate600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.slate200,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            fit: FlexFit.tight,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                AppIcons.blockShieldSvg,
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primaryRed,
                                  BlendMode.srcIn,
                                ),
                              ),
                              label: const Text(
                                'Admin Panel',
                                style: TextStyle(
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.softRed,
                                side: const BorderSide(
                                  color: AppColors.redLight300,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 7. Grid of Feature Cards (2x2)
                      Row(
                        children: [
                          _buildGridCard(
                            context: context,
                            svgIcon: AppIcons.shopingSvg,
                            iconColor: AppColors.primaryPurple,
                            iconBgColor: AppColors.lightPurple,
                            title: 'My Ads',
                            subtitle: '$totalMyAdsCount Posted Ads',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.myAds,
                                arguments: 'My Ads',
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildGridCard(
                            context: context,
                            svgIcon: AppIcons.favSvg,
                            iconColor: AppColors.primaryRed,
                            iconBgColor: AppColors.softRed,
                            title: 'Favourites',
                            subtitle: '$savedFavsCount Saved Items',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.favouriteAds,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildGridCard(
                            context: context,
                            svgIcon: AppIcons.briefcaseSvg,
                            iconColor: AppColors.primaryBlue,
                            iconBgColor: AppColors.lightBlue,
                            title: 'My Jobs',
                            subtitle: '$postedJobsCount Posted Jobs',
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.myJobs).then((_) {
                                if (context.mounted) {
                                  jobsViewModel.initUserJobs(force: true);
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildGridCard(
                            context: context,
                            svgIcon: AppIcons.messageSvg,
                            iconColor: AppColors.emerald,
                            iconBgColor: AppColors.softGreen,
                            title: 'My Posts',
                            subtitle: '$postedPostsCount Posts',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.myCommunityPosts,
                              ).then((_) {
                                if (context.mounted) {
                                  communityViewModel.fetchMyPosts(force: true);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildGridCard(
                            context: context,
                            svgIcon: AppIcons.trackbookSvg,
                            iconColor: AppColors.primaryPurple,
                            iconBgColor: AppColors.lightPurple,
                            title: 'My Applications',
                            subtitle: '$myApplicationsCount Applied Jobs',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.myApplications,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildGridCard(
                            context: context,
                            svgIcon: AppIcons.workerSvg,
                            iconColor: const Color(0xFFF97316),
                            iconBgColor: const Color(0xFFFFF7ED),
                            title: 'Worker Requests',
                            subtitle: 'Incoming Hire Requests',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.workerRequests,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 8. Account List Items Group
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          children: [
                            _buildListRow(
                              context: context,
                              svgIcon: AppIcons.settingsSvg,
                              iconColor: AppColors.slate500,
                              iconBgColor: AppColors.slate100,
                              title: 'Settings',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.settingsRoute,
                              ),
                            ),
                            const Divider(
                              height: 1,
                              indent: 64,
                              color: AppColors.slate100,
                            ),
                            _buildListRow(
                              context: context,
                              svgIcon: AppIcons.crownSvg,
                              iconColor: AppColors.amberOrange,
                              iconBgColor: AppColors.lightYellow,
                              title: 'Membership Plans',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.membershipPlans,
                                );
                              },
                            ),
                            const Divider(
                              height: 1,
                              indent: 64,
                              color: AppColors.slate100,
                            ),
                            _buildListRow(
                              context: context,
                              svgIcon: AppIcons.logoutSvg,
                              iconColor: AppColors.primaryRed,
                              iconBgColor: AppColors.softRed,
                              title: 'Logout',
                              titleColor: AppColors.primaryRed,
                              onTap: () async {
                                await authViewModel.logout();
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 9. Version & Footer Text
                      Center(
                        child: Text(
                          'DesiConnect v1.0.0 · Made with ❤️',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).padding.bottom +
                            (isLandscape ? 80.0 : 40.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String count,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            count,
            style: TextStyle(
              fontSize: context.sp(18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: context.scaleH(2)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: context.sp(12),
              color: AppColors.slate400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1.5,
      height: context.scaleH(30),
      color: AppColors.slate100,
    );
  }

  Widget _buildContactBadge({
    required BuildContext context,
    required String svgIcon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: (context.scale(10.0)).clamp(6.0, 14.0),
        vertical: (context.scaleH(8.0)).clamp(6.0, 10.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgIcon,
            width: (context.scale(14.0)).clamp(12.0, 16.0),
            height: (context.scale(14.0)).clamp(12.0, 16.0),
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          SizedBox(width: (context.scale(4.0)).clamp(3.0, 6.0)),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: context.sp(11),
                color: AppColors.slate600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard({
    required BuildContext context,
    required String svgIcon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Flexible(
      fit: FlexFit.tight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(context.cardPad),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.scale(36),
                height: context.scale(36),
                padding: EdgeInsets.all(context.scale(8)),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    svgIcon,
                    width: context.scale(20),
                    height: context.scale(20),
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(height: context.scaleH(12)),
              Text(
                title,
                style: TextStyle(
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate800,
                ),
              ),
              SizedBox(height: context.scaleH(2)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: context.sp(12),
                  color: AppColors.slate400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListRow({
    required BuildContext context,
    required String svgIcon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.cardPad,
          vertical: context.scaleH(12),
        ),
        child: Row(
          children: [
            Container(
              width: context.scale(36),
              height: context.scale(36),
              padding: EdgeInsets.all(context.scale(8)),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgIcon,
                  width: context.scale(20),
                  height: context.scale(20),
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(width: context.scale(12)),
            Text(
              title,
              style: TextStyle(
                fontSize: context.sp(15),
                fontWeight: FontWeight.w600,
                color: titleColor ?? AppColors.slate800,
              ),
            ),
            const Spacer(),
            SvgPicture.asset(
              AppIcons.More_arrow,
              width: context.scale(20),
              height: context.scale(20),
              colorFilter: const ColorFilter.mode(
                AppColors.slate400,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
