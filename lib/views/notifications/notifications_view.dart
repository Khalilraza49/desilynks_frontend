import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/core/utils/notification_router.dart';
import 'package:desilynks/models/notification_model.dart';
import 'package:desilynks/viewmodels/notifications/notifications_viewmodel.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel item,
    NotificationsViewModel vm,
  ) {
    NotificationRouter.routeNotification(context, item, vm: vm);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<NotificationsViewModel>().ensureInitialized();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Consumer<NotificationsViewModel>(
              builder: (context, viewModel, _) {
                final filtered = viewModel.filteredNotifications;

                return Column(
                  children: [
                    // ── Header ──────────────────────────────────────────
                    _buildHeader(context, viewModel),

                    // ── Tab Bar ─────────────────────────────────────────
                    _buildTabBar(context, viewModel),

                    // ── Body ────────────────────────────────────────────
                    Expanded(
                      child: _buildBody(context, viewModel, filtered),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, NotificationsViewModel viewModel) {
    final closeIconSize = context.scale(18).clamp(16.0, 22.0);

    return SizedBox(
      height: context.scaleH(48).clamp(44.0, 56.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered Title
          Center(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: context.sp(17),
                fontFamily: AppStrings.fontInter,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            ),
          ),
          // Left Close button
          Positioned(
            left: context.hMargin - 8,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: context.scale(40),
                minHeight: context.scale(40),
              ),
              icon: SvgPicture.asset(
                AppIcons.crossSmallAltSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate800,
                  BlendMode.srcIn,
                ),
                height: closeIconSize,
                width: closeIconSize,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Right "Mark all read" button
          Positioned(
            right: context.hMargin - 4,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(6),
                  vertical: context.scaleH(4),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: viewModel.isLoading
                  ? null
                  : () => viewModel.markAllAsRead(),
              child: Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: context.sp(13.5),
                  fontFamily: AppStrings.fontInter,
                  color: viewModel.isLoading
                      ? AppColors.slate400
                      : AppColors.vibrantBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ─────────────────────────────────────────────────────────────────
  Widget _buildTabBar(BuildContext context, NotificationsViewModel viewModel) {
    final barHeight = context.scaleH(42).clamp(38.0, 46.0);
    final tabSpacing = context.scale(22).clamp(16.0, 32.0);

    return Container(
      height: barHeight,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.slate100,
            width: 1.0,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.hMargin),
        itemCount: viewModel.tabs.length,
        itemBuilder: (context, index) {
          final tab = viewModel.tabs[index];
          final bool isActive = viewModel.activeTab == tab;

          return GestureDetector(
            onTap: () => viewModel.setActiveTab(tab),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: EdgeInsets.only(
                right: index == viewModel.tabs.length - 1 ? 0 : tabSpacing,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 2),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(4),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: context.sp(14.5),
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        fontFamily: AppStrings.fontInter,
                        color: isActive
                            ? AppColors.vibrantBlue
                            : AppColors.slate500,
                      ),
                    ),
                  ),
                  Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.vibrantBlue
                          : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────
  Widget _buildBody(
    BuildContext context,
    NotificationsViewModel viewModel,
    List<NotificationModel> filtered,
  ) {
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return _buildShimmer(context);
    }
    if (viewModel.hasError && viewModel.notifications.isEmpty) {
      return _buildError(context, viewModel);
    }
    if (filtered.isEmpty) {
      return _buildEmpty(context, viewModel);
    }

    return RefreshIndicator(
      color: AppColors.vibrantBlue,
      onRefresh: () => viewModel.fetchNotifications(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 150) {
            viewModel.fetchMore();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.zero,
          itemCount: filtered.length + (viewModel.isFetchingMore ? 1 : 0),
          separatorBuilder: (context, index) => const Divider(
            color: AppColors.slate100,
            height: 1,
            thickness: 1,
          ),
          itemBuilder: (context, index) {
            if (index == filtered.length) {
              return Padding(
                padding: EdgeInsets.all(context.scale(16)),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.vibrantBlue,
                  ),
                ),
              );
            }
            return _buildNotificationTile(
              context,
              filtered[index],
              viewModel,
            );
          },
        ),
      ),
    );
  }

  // ── Notification Tile ───────────────────────────────────────────────────────
  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel item,
    NotificationsViewModel vm,
  ) {
    final iconBoxSize = context.scale(44).clamp(40.0, 48.0);
    final iconSize = context.scale(20).clamp(18.0, 24.0);
    final deleteIconSize = context.scale(22).clamp(18.0, 26.0);
    final horizontalPad = context.hMargin;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: context.scale(20)),
        color: AppColors.softRed,
        child: SvgPicture.asset(
          AppIcons.deleteSvg,
          colorFilter: const ColorFilter.mode(
            AppColors.primaryRed,
            BlendMode.srcIn,
          ),
          width: deleteIconSize,
          height: deleteIconSize,
        ),
      ),
      onDismissed: (_) => vm.deleteNotification(item.id),
      child: InkWell(
        onTap: () => _handleNotificationTap(context, item, vm),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: context.scaleH(13).clamp(10.0, 16.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left icon box
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: vm.getNotificationIconBgColor(item.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    vm.getNotificationIcon(item.type),
                    colorFilter: ColorFilter.mode(
                      vm.getNotificationIconColor(item.type),
                      BlendMode.srcIn,
                    ),
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
              ),
              SizedBox(width: context.scale(14).clamp(12.0, 16.0)),

              // Content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: context.sp(14.5),
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    SizedBox(height: context.scaleH(3)),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: context.sp(13),
                        color: AppColors.slate500,
                        height: 1.35,
                        fontFamily: AppStrings.fontInter,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.scaleH(5)),
                    Text(
                      item.relativeTime,
                      style: TextStyle(
                        fontSize: context.sp(11.5),
                        color: AppColors.slate400,
                        fontWeight: FontWeight.w400,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shimmer Loading Skeleton ────────────────────────────────────────────────
  Widget _buildShimmer(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 7,
      separatorBuilder: (context, index) => const Divider(
        color: AppColors.slate100,
        height: 1,
        thickness: 1,
      ),
      itemBuilder: (context, index) => const _ShimmerTile(),
    );
  }

  // ── Error State ─────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, NotificationsViewModel vm) {
    final iconSize = context.scale(56).clamp(44.0, 64.0);
    final retryIconSize = context.scale(18).clamp(16.0, 22.0);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.scale(32).clamp(20.0, 40.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppIcons.wifiSvg,
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(Colors.grey[300]!, BlendMode.srcIn),
            ),
            SizedBox(height: context.scaleH(16)),
            Text(
              vm.errorMessage.isNotEmpty
                  ? vm.errorMessage
                  : 'Could not load notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.sp(14),
                color: Colors.grey[500],
                fontFamily: AppStrings.fontInter,
              ),
            ),
            SizedBox(height: context.scaleH(20)),
            ElevatedButton.icon(
              onPressed: () => vm.fetchNotifications(refresh: true),
              icon: SvgPicture.asset(
                AppIcons.restartSvg,
                width: retryIconSize,
                height: retryIconSize,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              label: Text(
                'Retry',
                style: TextStyle(
                  fontSize: context.sp(14),
                  fontFamily: AppStrings.fontInter,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantBlue,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(20),
                  vertical: context.scaleH(10),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmpty(BuildContext context, NotificationsViewModel vm) {
    final iconSize = context.scale(64).clamp(48.0, 72.0);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.scale(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppIcons.bellOff,
              width: iconSize,
              height: iconSize,
            ),
            SizedBox(height: context.scaleH(16)),
            Text(
              vm.activeTab == 'All'
                  ? 'No notifications yet'
                  : 'No ${vm.activeTab} notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.sp(15),
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer Tile Widget ─────────────────────────────────────────────────────
class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    final iconBoxSize = context.scale(46).clamp(42.0, 50.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.4, end: 0.9),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final bg = Colors.grey.withValues(alpha: value * 0.3);
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.hMargin,
            vertical: context.scaleH(14).clamp(10.0, 18.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon placeholder
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(width: context.scale(14).clamp(12.0, 16.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: context.scaleH(14).clamp(12.0, 16.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: context.scaleH(8)),
                    Container(
                      height: context.scaleH(12).clamp(10.0, 14.0),
                      width: context.widthPct(0.55).clamp(140.0, 240.0),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: context.scaleH(8)),
                    Container(
                      height: context.scaleH(10).clamp(8.0, 12.0),
                      width: context.widthPct(0.25).clamp(60.0, 100.0),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
