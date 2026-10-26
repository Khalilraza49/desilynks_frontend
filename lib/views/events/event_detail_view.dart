import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/models/event_model.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/viewmodels/events/events_viewmodel.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/utils/app_share_helper.dart';

/// Responsive, Stateless Event Detail Screen adhering to MVVM with Provider.
/// Uses exclusively SVG icons and matches the design specification.
class EventDetailView extends StatelessWidget {
  final EventModel event;

  const EventDetailView({
    super.key,
    required this.event,
  });

  void _onSharePressed(BuildContext context, EventModel eventItem) {
    AppShareHelper.shareAsLink(
      context: context,
      type: ShareItemType.event,
      id: eventItem.id,
      title: eventItem.title,
      description:
          '${eventItem.fullDate} · ${eventItem.displayTime} · ${eventItem.location}',
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
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: SvgPicture.asset(
          AppIcons.gallerySvg,
          height: 48,
          width: 48,
          colorFilter: const ColorFilter.mode(
            Color(0xFF94A3B8),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventsViewModel>();
    final currentEvent = vm.getEventById(event.id) ?? event;

    final isSmall = context.isSmall;
    final hPadding = isSmall ? 14.0 : 18.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Cover Banner with Floating Back & Share Buttons
              _buildCoverBanner(context, currentEvent),

              // 2. Event Title, Date Badge & Location Section
              Padding(
                padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow(context, currentEvent, isSmall),
                    const SizedBox(height: 12),
                    _buildTagsRow(context, currentEvent, isSmall),
                    const SizedBox(height: 12),
                    _buildLocationRow(context, currentEvent, isSmall),
                    const SizedBox(height: 14),
                    _buildOrganizerCard(context, currentEvent, isSmall),
                  ],
                ),
              ),

              // 3. Action Buttons Row ("I'm Interested" & "Share")
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
                child: _buildActionButtonsRow(context, currentEvent, vm, isSmall),
              ),

              // 4. White Card: "About Event" & "What to Expect"
              Padding(
                padding: EdgeInsets.fromLTRB(hPadding, 14, hPadding, 28),
                child: _buildEventCard(context, currentEvent, isSmall),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. Cover Banner with Floating Navigation & Share Icons
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCoverBanner(BuildContext context, EventModel eventItem) {
    final double bannerHeight = context.scaleH(230).clamp(200.0, 300.0);

    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // Banner Image
          Positioned.fill(
            child: _buildEventImage(eventItem.imageUrl),
          ),

          // Subtle Top Gradient for Contrast
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 90,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black38,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Floating Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.arrowBackSvg,
                    height: 18,
                    width: 18,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate800,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating Share Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () => _onSharePressed(context, eventItem),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.shareSvg,
                    height: 18,
                    width: 18,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate800,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Header Row: Date Badge & Title/Date
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderRow(
    BuildContext context,
    EventModel eventItem,
    bool isSmall,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Badge (JUN / 16)
        Container(
          width: isSmall ? 52 : 56,
          height: isSmall ? 54 : 58,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                eventItem.month.toUpperCase(),
                style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2563EB),
                  letterSpacing: 0.5,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                eventItem.day,
                style: TextStyle(
                  fontSize: isSmall ? 18 : 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2563EB),
                  height: 1.1,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Title and Date/Time Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventItem.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.sp(isSmall ? 18 : 20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  height: 1.25,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${eventItem.fullDate} · ${eventItem.displayTime}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.sp(isSmall ? 12 : 13),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tags Row: Category & Price & Online Pill
  Widget _buildTagsRow(
    BuildContext context,
    EventModel eventItem,
    bool isSmall,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        // Category Pill
        if (eventItem.category.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
            ),
            child: Text(
              eventItem.category,
              style: const TextStyle(
                color: Color(0xFF1D4ED8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ),

        // Ticket Price Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: eventItem.isFree
                ? const Color(0xFFECFDF5)
                : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: eventItem.isFree
                  ? const Color(0xFFA7F3D0)
                  : const Color(0xFFFDE68A),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eventItem.isFree ? '🎟️ Free Entry' : '🎟️ ${eventItem.displayPrice}',
                style: TextStyle(
                  color: eventItem.isFree
                      ? const Color(0xFF047857)
                      : const Color(0xFFB45309),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ],
          ),
        ),

        // Online event badge if applicable
        if (eventItem.isOnline)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
            ),
            child: const Text(
              '🌐 Online Event',
              style: TextStyle(
                color: Color(0xFF6D28D9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Location Row
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildLocationRow(
    BuildContext context,
    EventModel eventItem,
    bool isSmall,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(
            AppIcons.locationSvg,
            height: isSmall ? 15 : 17,
            width: isSmall ? 15 : 17,
            colorFilter: const ColorFilter.mode(
              Color(0xFF64748B),
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            eventItem.location,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: context.sp(isSmall ? 12 : 13),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              height: 1.35,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ),
      ],
    );
  }

  // Organizer / Host Profile Card
  Widget _buildOrganizerCard(
    BuildContext context,
    EventModel eventItem,
    bool isSmall,
  ) {
    final authVM = context.watch<AuthViewModel>();
    final currentUser = authVM.currentUser;

    // Check if event is created by the current user
    final bool isMyEvent = (currentUser != null &&
        ((eventItem.organizerId != null &&
                eventItem.organizerId!.isNotEmpty &&
                eventItem.organizerId == currentUser.id) ||
            (eventItem.organizerName.isNotEmpty &&
                (eventItem.organizerName.toLowerCase() ==
                        currentUser.username.toLowerCase() ||
                    eventItem.organizerName.toLowerCase() ==
                        currentUser.fullName.toLowerCase() ||
                    eventItem.organizerName == 'Personal Event')) ||
            eventItem.id.startsWith('evt_')));

    final String displayName = isMyEvent
        ? (currentUser.fullName.trim().isNotEmpty
            ? currentUser.fullName.trim()
            : (currentUser.username.trim().isNotEmpty
                ? currentUser.username.trim()
                : (eventItem.organizerName.isNotEmpty
                    ? eventItem.organizerName
                    : 'Personal Host')))
        : (eventItem.organizerName.isNotEmpty
            ? eventItem.organizerName
            : 'Community Host');

    final String avatarUrl = isMyEvent
        ? (currentUser.profilePhotoUrl ?? eventItem.organizerAvatar)
        : eventItem.organizerAvatar;

    final String roleTag = isMyEvent
        ? 'Organizer · You'
        : 'Event Host · Verified';

    void openProfile() {
      final PropertyOwner owner =
          eventItem.resolveOwner(currentUser: currentUser);
      Navigator.pushNamed(
        context,
        AppRoutes.publicProfile,
        arguments: owner,
      );
    }

    return GestureDetector(
      onTap: openProfile,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmall ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Host Avatar with Verified Check Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: isSmall ? 48 : 52,
                  height: isSmall ? 48 : 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDBEAFE),
                    border: Border.all(
                      color: const Color(0xFFEFF6FF),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: avatarUrl.isNotEmpty
                        ? _buildEventImage(avatarUrl)
                        : Center(
                            child: SvgPicture.asset(
                              AppIcons.personSvg,
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate400,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Host Name & Verified Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.sp(isSmall ? 14 : 15),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isMyEvent ? 'YOU' : 'HOST',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    roleTag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.sp(isSmall ? 11 : 12),
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.starFavoriteSvg,
                        height: 12,
                        width: 12,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFF59E0B),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '· 15 Reviews',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.slate400,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Profile Button / Arrow Pill
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFBFDBFE),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2563EB),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(width: 3),
                  SvgPicture.asset(
                    AppIcons.arrowForwardSvg,
                    width: 11,
                    height: 11,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2563EB),
                      BlendMode.srcIn,
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

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Action Buttons Row: "I'm Interested" & "Share"
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildActionButtonsRow(
    BuildContext context,
    EventModel eventItem,
    EventsViewModel vm,
    bool isSmall,
  ) {
    final bool isInterested = eventItem.isInterested;

    return Row(
      children: [
        // "I'm Interested" Button
        Expanded(
          child: GestureDetector(
            onTap: () => vm.toggleInterest(eventItem.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: isSmall ? 44 : 46,
              decoration: BoxDecoration(
                color: isInterested
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F2563EB),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppIcons.starFavoriteSvg,
                    height: 16,
                    width: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isInterested ? 'Interested' : "I'm Interested",
                    style: TextStyle(
                      fontSize: context.sp(isSmall ? 13 : 14),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // "Share" Button
        Expanded(
          child: GestureDetector(
            onTap: () => _onSharePressed(context, eventItem),
            child: Container(
              height: isSmall ? 44 : 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppIcons.shareSvg,
                    height: 16,
                    width: 16,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF1E293B),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Share',
                    style: TextStyle(
                      fontSize: context.sp(isSmall ? 13 : 14),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. White Card: "About Event" & "What to Expect"
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildEventCard(
    BuildContext context,
    EventModel eventItem,
    bool isSmall,
  ) {
    final String aboutText = eventItem.description.trim().isNotEmpty
        ? eventItem.description.trim()
        : "Let's come together to celebrate with our community. Enjoy activities, networking, and cultural programs.";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About Event Heading
          Text(
            'About Event',
            style: TextStyle(
              fontSize: context.sp(isSmall ? 16.5 : 18),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
              fontFamily: AppStrings.fontInter,
            ),
          ),
          const SizedBox(height: 10),

          // About Event Body
          Text(
            aboutText,
            style: TextStyle(
              fontSize: context.sp(isSmall ? 13 : 14),
              height: 1.55,
              color: const Color(0xFF475569),
              fontFamily: AppStrings.fontInter,
            ),
          ),

          const SizedBox(height: 24),

          // What to Expect Heading
          Text(
            'What to Expect',
            style: TextStyle(
              fontSize: context.sp(isSmall ? 16.5 : 18),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
              fontFamily: AppStrings.fontInter,
            ),
          ),
          const SizedBox(height: 14),

          // Checklist items with Green Tick SVG
          ...eventItem.whatToExpect.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppIcons.tickSvg,
                    height: 16,
                    width: 16,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF10B981),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 13 : 14),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

