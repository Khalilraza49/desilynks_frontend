import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../app/routes.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import '../viewmodels/navigation/navigation_viewmodel.dart';
import '../viewmodels/chat/chat_viewmodel.dart';
import '../viewmodels/notifications/notifications_viewmodel.dart';
import 'user_avatar.dart';
import 'login_required_dialog.dart';

class SidebarDrawer extends StatelessWidget {
  final ValueChanged<int>? onTabSelected;

  const SidebarDrawer({super.key, this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.currentUser;
    final bool isLoggedIn = authViewModel.isAuthenticated;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false, // Allow gradient to go under status bar
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card with Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors
                          .gradientStart, // Vibrant blue matching gradientStart
                      AppColors
                          .secondaryPurple, // Rich purple matching gradientEnd
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                AppIcons.crossSmallSvg,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Profile Image / Avatar
                      UserAvatar(
                        photoUrl: isLoggedIn ? user?.profilePhotoUrl : null,
                        size: 72,
                        fallbackSvg: isLoggedIn
                            ? AppIcons.personSvg
                            : AppIcons.guestSvg,
                        fallbackBgColor: Colors.white.withValues(alpha: 0.2),
                        fallbackIconColor: Colors.white,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Username / Title
                      Text(
                        isLoggedIn
                            ? '${user?.firstName} ${user?.lastName ?? ''}'
                                  .trim()
                            : 'Guest User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Subtitle
                      Text(
                        isLoggedIn
                            ? (user?.email ?? 'Logged In')
                            : 'Login to access all features',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons (Row)
                      Row(
                        children: [
                          if (!isLoggedIn) ...[
                            // Login Button for Guest
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, AppRoutes.login);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primaryBlue,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Register Button for Guest
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.register,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // Profile Button for Logged-In User
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (onTabSelected != null) {
                                    onTabSelected!(3); // Switch to Profile tab
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primaryBlue,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Logout Button for Logged-In User
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await authViewModel.logout();
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Menu Sections & Items
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- BROWSE Section ---
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 8.0,
                        top: 4.0,
                        bottom: 12.0,
                      ),
                      child: Text(
                        'BROWSE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate400,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.homeSvg,
                      label: 'Home',
                      iconColor: AppColors.primaryBlue,
                      iconBgColor: AppColors.lightBlue,
                      onTap: () {
                        Navigator.pop(context);
                        if (onTabSelected != null) {
                          onTabSelected!(0); // Switch to Home tab
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.searchSvg,
                      label: 'Search',
                      iconColor: AppColors.slate500,
                      iconBgColor: AppColors.slate100,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Search feature is coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.briefcaseSvg,
                      label: 'Jobs',
                      iconColor: AppColors.primaryBlue,
                      iconBgColor: AppColors.lightBlue,
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        ).openJobs();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.roomSvg,
                      label: 'Rooms',
                      iconColor: AppColors.orangeAccent,
                      iconBgColor: AppColors.lightOrange,
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        ).openRooms();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.shopingSvg,
                      label: 'Marketplace',
                      iconColor: AppColors.primaryPurple,
                      iconBgColor: AppColors.lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        ).openMarketplace();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.workerSvg,
                      label: 'Workers',
                      iconColor: AppColors.successGreen,
                      iconBgColor: AppColors.lightGreen,
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        ).openWorkers();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.pcommunitySvg,
                      label: 'Community',
                      iconColor: AppColors.primaryBlue,
                      iconBgColor: AppColors.lightBlue,
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        ).openCommunity();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.eventSvg,
                      label: 'Events',
                      iconColor: AppColors.amber700,
                      iconBgColor: AppColors.lightYellow,
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<NavigationViewModel>(
                          context,
                          listen: false,
                        ).openEvents();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.resourceSvg,
                      label: 'Resource Hub',
                      iconColor: AppColors.green600,
                      iconBgColor: AppColors.softGreen,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.resourceHub);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.globeSvg,
                      label: 'Explore Spain',
                      iconColor: AppColors.primaryRed,
                      iconBgColor: AppColors.softRed,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.exploreSpain);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.businessSvg,
                      label: 'Local Business',
                      iconColor: AppColors.primaryRed,
                      iconBgColor: AppColors.softRed,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.localBusiness);
                      },
                    ),
                    const SizedBox(height: 24),

                    // --- MY ACCOUNT Section ---
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                      child: Text(
                        'MY ACCOUNT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate400,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    if (!isLoggedIn) ...[
                      _buildLockedMenuItem(
                        context: context,
                        svgIcon: AppIcons.personSvg,
                        label: 'My Profile',
                      ),
                      const SizedBox(height: 8),
                      _buildLockedMenuItem(
                        context: context,
                        svgIcon: AppIcons.shopingSvg,
                        label: 'My Ads',
                      ),
                      const SizedBox(height: 8),
                      _buildLockedMenuItem(
                        context: context,
                        svgIcon: AppIcons.briefcaseSvg,
                        label: 'My Applications',
                      ),
                      const SizedBox(height: 8),
                      _buildLockedMenuItem(
                        context: context,
                        svgIcon: AppIcons.favSvg,
                        label: 'Favourites',
                      ),
                      const SizedBox(height: 8),
                      _buildLockedMenuItem(
                        context: context,
                        svgIcon: AppIcons.chatRoundSvg,
                        label: 'Messages',
                      ),
                      const SizedBox(height: 8),
                      _buildLockedMenuItem(
                        context: context,
                        svgIcon: AppIcons.crownSvg,
                        label: 'Membership Plans',
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.giftSvg,
                        label: 'Refer & Earn',
                        iconColor: AppColors.emerald,
                        iconBgColor: AppColors.softGreen,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.referEarn);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildLockedMenuItem(
                        context: context,
                        svgIcon: AppIcons.analyticsSvg,
                        label: 'Revenue & Promotions',
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.TagSvg,
                        label: 'Deals & Discounts',
                        iconColor: const Color(0xFFD97706),
                        iconBgColor: const Color(0xFFFEF3C7),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.dealsDiscounts,
                          );
                        },
                      ),
                    ] else ...[
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.personSvg,
                        label: 'My Profile',
                        iconColor: AppColors.primaryBlue,
                        iconBgColor: AppColors.lightBlue,
                        onTap: () {
                          Navigator.pop(context);
                          if (onTabSelected != null) {
                            onTabSelected!(3); // Switch to Profile tab
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.shopingSvg,
                        label: 'My Ads',
                        iconColor: AppColors.primaryPurple,
                        iconBgColor: AppColors.lightPurple,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.myAds);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.briefcaseSvg,
                        label: 'My Applications',
                        iconColor: AppColors.vibrantBlue,
                        iconBgColor: AppColors.lightBlue,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.myApplications,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.favSvg,
                        label: 'Favourites',
                        iconColor: AppColors.primaryRed,
                        iconBgColor: AppColors.softRed,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.favouriteAds);
                        },
                      ),
                      const SizedBox(height: 8),
                      Consumer<ChatViewModel>(
                        builder: (context, chatVm, _) {
                          final unreadMessages = chatVm.totalUnreadCount;
                          return _buildMenuItem(
                            context: context,
                            svgIcon: AppIcons.chatRoundSvg,
                            label: 'Messages',
                            iconColor: AppColors.green600,
                            iconBgColor: AppColors.softGreen,
                            trailing: unreadMessages > 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryRed,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      unreadMessages > 99
                                          ? '99+'
                                          : '$unreadMessages',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(context);
                              Provider.of<NavigationViewModel>(
                                context,
                                listen: false,
                              ).openChat();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Consumer<NotificationsViewModel>(
                        builder: (context, notifVm, _) {
                          final unreadNotifs = notifVm.unreadCount;
                          return _buildMenuItem(
                            context: context,
                            svgIcon: AppIcons.notificationSvg,
                            label: 'Notifications',
                            iconColor: AppColors.orange,
                            iconBgColor: AppColors.lightOrange,
                            trailing: unreadNotifs > 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.orange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      unreadNotifs > 99
                                          ? '99+'
                                          : '$unreadNotifs',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.notifications,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.crownSvg,
                        label: 'Membership Benefits',
                        iconColor: AppColors.amberOrange,
                        iconBgColor: AppColors.lightYellow,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.membershipBenefits,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.giftSvg,
                        label: 'Refer & Earn',
                        iconColor: AppColors.emerald,
                        iconBgColor: AppColors.softGreen,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.referEarn);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.starFavoriteSvg,
                        label: 'Loyalty Points',
                        iconColor: AppColors.orange,
                        iconBgColor: AppColors.lightOrange,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.loyaltyPoints);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.couponSvg,
                        label: 'Coupons',
                        iconColor: AppColors.primaryPurple,
                        iconBgColor: AppColors.lightPurple,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.coupons);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.analyticsSvg,
                        label: 'Revenue & Promotions',
                        iconColor: AppColors.indigo,
                        iconBgColor: AppColors.indigoLight,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.revenuePromotions,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.sales1Svg,
                        label: 'My Offers',
                        iconColor: AppColors.emerald,
                        iconBgColor: AppColors.softGreen,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.myOffers);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.TagSvg,
                        label: 'Deals & Discounts',
                        iconColor: const Color(0xFFD97706),
                        iconBgColor: const Color(0xFFFEF3C7),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.dealsDiscounts,
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 24),

                    // --- SUPPORT & LEGAL Section ---
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                      child: Text(
                        'SUPPORT & LEGAL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate400,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.questionSvg,
                      label: 'FAQ',
                      iconColor: AppColors.slate500,
                      iconBgColor: AppColors.slate100,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.faq);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.supportSvg,
                      label: 'Help & Support',
                      iconColor: AppColors.cyan,
                      iconBgColor: AppColors.cyanLight,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.helpCenter);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.emailSvg,
                      label: 'Contact Us',
                      iconColor: AppColors.slate500,
                      iconBgColor: AppColors.slate100,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.helpCenter);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.settingsSvg,
                      label: 'Setting',
                      iconColor: AppColors.slate500,
                      iconBgColor: AppColors.slate100,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.settingsRoute);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.blockShieldSvg,
                      label: 'Privacy Policy',
                      iconColor: AppColors.slate500,
                      iconBgColor: AppColors.slate100,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.privacyPolicy);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.newspaperSvg,
                      label: 'Terms & Conditions',
                      iconColor: AppColors.slate500,
                      iconBgColor: AppColors.slate100,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.termsConditions);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      svgIcon: AppIcons.closedBookSvg,
                      label: 'Community Guidelines',
                      iconColor: AppColors.slate500,
                      iconBgColor: AppColors.slate100,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.communityGuidelines,
                        );
                      },
                    ),
                    if (isLoggedIn) ...[
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context: context,
                        svgIcon: AppIcons.logoutSvg,
                        label: 'Logout',
                        iconColor: AppColors.primaryRed,
                        iconBgColor: AppColors.softRed,
                        labelColor: AppColors.primaryRed,
                        onTap: () async {
                          Navigator.pop(context);
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
                    const SizedBox(height: 40),

                    // Centered Footer version info
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
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String svgIcon,
    required String label,
    required Color iconColor,
    required Color iconBgColor,
    Color? labelColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgIcon,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: 22,
                  height: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? AppColors.slate800,
                ),
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedMenuItem({
    required BuildContext context,
    required String svgIcon,
    required String label,
  }) {
    return _buildMenuItem(
      context: context,
      svgIcon: svgIcon,
      label: label,
      iconColor: const Color(0xFF94A3B8), // Muted slate400
      iconBgColor: const Color(0xFFF8FAFC), // Light gray slate50
      labelColor: const Color(0xFF94A3B8), // Muted text
      trailing: SvgPicture.asset(
        AppIcons.lockSvg,
        width: 16,
        height: 16,
        colorFilter: const ColorFilter.mode(
          Color(0xFFCBD5E1), // Light slate300 lock icon
          BlendMode.srcIn,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        LoginRequiredDialog.show(
          context,
          message: label == 'My Ads'
              ? 'Please register to use posting ads.'
              : 'Please register to access $label.',
        );
      },
    );
  }
}
