import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/widgets/sidebar_drawer.dart';
import 'package:desilynks/widgets/custom_bottom_navigation.dart';
import 'package:desilynks/widgets/login_required_dialog.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/views/home/home_view.dart';
import 'package:desilynks/views/dashboard/dashboard_view.dart';
import 'package:desilynks/views/marketplace/marketplace_view.dart';
import 'package:desilynks/views/search/search_view.dart';
import 'package:desilynks/views/events/events_view.dart';
import 'package:desilynks/views/create_post/jobs/jobs_view.dart';
import 'package:desilynks/views/create_post/rooms/room_details_view.dart';
import 'package:desilynks/views/create_post/worker_profile/hire_workers_view.dart';
import 'package:desilynks/views/chat/chat_view.dart';
import 'package:desilynks/views/community/community_view.dart';
import 'package:desilynks/views/profile/profile_view.dart';
import 'package:desilynks/viewmodels/chat/chat_viewmodel.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildTab1Screen(
    NavigationViewModel navViewModel,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    if (navViewModel.isMarketplaceActive) {
      if (navViewModel.isSearchActive) {
        return SearchView(
          onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
        );
      }
      switch (navViewModel.activeCategory) {
        case 'jobs':
          return const JobsView();
        case 'rooms':
          return const RoomDetailsView();
        case 'workers':
          return const HireWorkersView();
        case 'events':
          return EventsView(
            onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
          );
        case 'marketplace':
        default:
          return MarketplaceView(
            onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
          );
      }
    }

    return DashboardView(
      onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navViewModel = Provider.of<NavigationViewModel>(context);
    navViewModel.initBottomBar(context);

    final selectedNavIndex = navViewModel.currentIndex;
    final isMarketplaceActive = navViewModel.isMarketplaceActive;
    final isCommunityActive = navViewModel.isCommunityActive;

    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final bool isSmall = screenWidth < 360.0;
    final bool isLarge = screenWidth >= 420.0;

    // Responsive dimensions for Floating Action Button and bottom bar center gap
    final double fabSize = isSmall ? 46.0 : (isLarge ? 54.0 : 50.0);
    final double fabIconSize = isSmall ? 18.0 : (isLarge ? 22.0 : 20.0);
    final double centerGap = isSmall ? 52.0 : (isLarge ? 64.0 : 58.0);

    final List<Widget> screens = [
      HomeView(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      _buildTab1Screen(navViewModel, _scaffoldKey),
      isCommunityActive
          ? CommunityView(
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
            )
          : ChatView(
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
      ProfileView(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
    ];

    final bool isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: SidebarDrawer(
        onTabSelected: (index) {
          navViewModel.handleTabSelected(context, index);
        },
      ),
      body: IndexedStack(index: selectedNavIndex, children: screens),
      floatingActionButton: isKeyboardOpen
          ? null
          : SizedBox(
              width: fabSize,
              height: fabSize,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  final authVM = Provider.of<AuthViewModel>(
                    context,
                    listen: false,
                  );
                  if (!authVM.isAuthenticated) {
                    LoginRequiredDialog.show(context);
                    return;
                  }
                  Navigator.pushNamed(context, AppRoutes.createPost);
                },
                backgroundColor: AppColors.vibrantBlue,
                shape: const CircleBorder(),
                elevation: 6,
                child: SvgPicture.asset(
                  AppIcons.plusSvg,
                  width: fabIconSize,
                  height: fabIconSize,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Consumer<ChatViewModel>(
        builder: (context, chatVM, _) {
          return CustomBottomNavigation(
            currentIndex: selectedNavIndex,
            isMarketplaceActive: isMarketplaceActive,
            isCommunityActive: isCommunityActive,
            centerGap: centerGap,
            chatBadgeCount: chatVM.totalUnreadCount,
            onTap: (index) {
              navViewModel.handleTabSelected(context, index);
            },
          );
        },
      ),
    );
  }
}
