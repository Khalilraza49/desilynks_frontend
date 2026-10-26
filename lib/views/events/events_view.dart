import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/models/event_model.dart';
import 'package:desilynks/viewmodels/events/events_viewmodel.dart';
import 'package:desilynks/widgets/sidebar_drawer.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';

class EventsView extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const EventsView({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsViewModel>(
      builder: (context, vm, _) {
        if (!vm.hasFetched && !vm.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.fetchEvents();
          });
        }

        final filteredEvents = vm.filteredEvents;

        return Scaffold(
          drawer: const SidebarDrawer(),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Custom Header Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isSmall ? 12 : 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Builder(
                        builder: (ctx) {
                          final canPop = Navigator.canPop(ctx);
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                canPop
                                    ? AppIcons.assetBackArrowSvg
                                    : AppIcons.menuSvg,
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.slate700,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (canPop) {
                                Navigator.pop(ctx);
                              } else if (onMenuPressed != null) {
                                onMenuPressed!();
                              } else {
                                Scaffold.of(ctx).openDrawer();
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Events',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.sp(22),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Post Event Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.postEvent);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.isSmall ? 10 : 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppIcons.assetaddSvg,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Post Event',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.sp(13),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Horizontal Category Filter Pills
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isSmall ? 12 : 16,
                    ),
                    itemCount: EventsViewModel.eventFilters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = EventsViewModel.eventFilters[index];
                      final isSelected = vm.selectedFilter == filter;
                      return GestureDetector(
                        onTap: () => vm.setSelectedFilter(filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              filter,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: context.sp(13),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Events List View
                Expanded(
                  child: vm.isLoading && filteredEvents.isEmpty
                      ? const ListSkeleton(showTabs: false)
                      : filteredEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppIcons.calendarSvg,
                                height: 48,
                                width: 48,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No events found',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.slate600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.isSmall ? 12 : 16,
                            vertical: 4,
                          ),
                          itemCount: filteredEvents.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildEventCard(
                              context,
                              filteredEvents[index],
                              index,
                              vm,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventImage(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imageFallback(),
      );
    }
    if (imageUrl.isNotEmpty) {
      try {
        final file = File(imageUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _imageFallback(),
          );
        }
      } catch (_) {}
    }
    return _imageFallback();
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.slate100,
      child: Center(
        child: SvgPicture.asset(AppIcons.gallerySvg),
      ),
    );
  }

  // Event Card Widget
  Widget _buildEventCard(
    BuildContext context,
    EventModel event,
    int index,
    EventsViewModel vm,
  ) {
    // Tinted date container color based on index
    const List<Color> bgTintColors = [
      Color(0xFFEFF6FF), // Light Blue
      Color(0xFFFEF3C7), // Light Amber
      Color(0xFFECFDF5), // Light Emerald
      Color(0xFFF3E8FF), // Light Purple
    ];
    const List<Color> textTintColors = [
      Color(0xFF2563EB), // Blue
      Color(0xFFD97706), // Amber
      Color(0xFF059669), // Emerald
      Color(0xFF9333EA), // Purple
    ];

    final bgColor = bgTintColors[index % bgTintColors.length];
    final textColor = textTintColors[index % textTintColors.length];

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.eventDetail,
          arguments: event,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image & Badges
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: SizedBox(
                height: 155,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildEventImage(event.imageUrl),
                    ),
                    // Category Badge on Top-Left
                    if (event.category.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ),
                      ),
                    // Price Badge on Top-Right
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: event.isFree
                              ? const Color(0xFF059669)
                              : const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          event.displayPrice,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Details Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Box
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          event.month,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                        Text(
                          event.day,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Event Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.sp(16),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${event.fullDate} · ${event.displayTime}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.sp(12),
                            color: AppColors.slate500,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.locationSvg,
                              height: 15,
                              width: 15,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                event.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: context.sp(12),
                                  color: AppColors.slate500,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Text('💃 🕺', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            Text(
                              '${event.interestedCount} Interested',
                              style: TextStyle(
                                fontSize: context.sp(12),
                                color: AppColors.slate500,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                            if (event.organizerName.isNotEmpty &&
                                event.organizerName != 'Community Organizer' &&
                                event.organizerName != 'Personal Event') ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '· 👤 ${event.organizerName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: context.sp(11.5),
                                    color: AppColors.slate500,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
