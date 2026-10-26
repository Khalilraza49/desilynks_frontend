import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:desilynks/app/routes.dart';

class DashboardView extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const DashboardView({super.key, this.onMenuPressed});

  void _showLocationPicker(BuildContext context, DashboardViewModel vm) {
    final locations = vm.availableLocations;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select City / Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final loc = locations[index];
                      final isSelected = loc == vm.selectedLocation;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        leading: SvgPicture.asset(
                          AppIcons.locationSvg,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            isSelected
                                ? AppColors.vibrantBlue
                                : AppColors.slate400,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: Text(
                          loc,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.vibrantBlue
                                : AppColors.slate800,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                        trailing: isSelected
                            ? SvgPicture.asset(
                                AppIcons.tickSvg,
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.vibrantBlue,
                                  BlendMode.srcIn,
                                ),
                              )
                            : null,
                        onTap: () {
                          vm.setSelectedLocation(loc);
                          Navigator.pop(ctx);
                        },
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

  void _showPrayerTimesSheet(BuildContext context, DashboardViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('🕌 ', style: TextStyle(fontSize: 20)),
                    Text(
                      'Prayer Schedule (${vm.selectedCity})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: vm.prayerSchedule
                          .map(
                            (prayer) => _buildPrayerRow(
                              prayer.name,
                              prayer.time,
                              isNext: prayer.isNext,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrayerRow(String name, String time, {bool isNext = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNext ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNext ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
              color: isNext ? const Color(0xFF1D4ED8) : AppColors.slate800,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isNext ? const Color(0xFF1D4ED8) : AppColors.slate800,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyNumbersSheet(BuildContext context, DashboardViewModel vm) {
    final services = vm.emergencyServices;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.callSvg,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFEF4444),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Emergency Services (Spain)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: AppStrings.fontInter,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: services.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = services[index];
                      final color = item['color'] as Color;
                      final number = item['number'] as String;
                      final title = item['title'] as String;

                      return InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dialing $title ($number)...'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    item['icon'] as String,
                                    width: 18,
                                    height: 18,
                                    colorFilter: ColorFilter.mode(
                                      color,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                        fontFamily: AppStrings.fontInter,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['desc'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        fontFamily: AppStrings.fontInter,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  number,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: color,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        final hMargin = context.isSmall ? 12.0 : 16.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: hMargin, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Area (Date, Location & Refresh Button)
                  _buildHeaderRow(context, vm),

                  const SizedBox(height: 16),

                  // 2. Weather Gradient Card
                  _buildWeatherCard(context, vm),

                  const SizedBox(height: 16),

                  // 3. Prayer Times Section Card
                  _buildPrayerTimesCard(context, vm),

                  const SizedBox(height: 16),

                  // 4. Currency Exchange Card
                  _buildCurrencyExchangeCard(context, vm),

                  const SizedBox(height: 16),

                  // 5. Community Update Section Card
                  _buildCommunityUpdateCard(context, vm),

                  const SizedBox(height: 16),

                  // 6. Emergency Numbers Section Card
                  _buildEmergencyNumbersCard(context, vm),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. Header Row (Date, City Location Selector & Refresh Button)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderRow(BuildContext context, DashboardViewModel vm) {
    final isSmall = context.isSmall;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vm.currentFormattedDate,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                  fontFamily: AppStrings.fontInter,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: () => _showLocationPicker(context, vm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppIcons.locationSvg,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        AppColors.vibrantBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        vm.selectedLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmall ? 15 : 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      AppIcons.arrowDropDownSvg,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF64748B),
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Action Buttons Row (Menu Drawer & Refresh)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onMenuPressed != null) ...[
              GestureDetector(
                onTap: onMenuPressed,
                child: Container(
                  width: isSmall ? 36 : 38,
                  height: isSmall ? 36 : 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.menuSvg,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF475569),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            GestureDetector(
              onTap: () {
                vm.refreshDashboard();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.restartSvg,
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Dashboard refreshed!'),
                      ],
                    ),
                    duration: const Duration(milliseconds: 1500),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Container(
                width: isSmall ? 36 : 38,
                height: isSmall ? 36 : 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.restartSvg,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF475569),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Weather Gradient Card Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWeatherCard(BuildContext context, DashboardViewModel vm) {
    final isSmall = context.isSmall;
    final city = vm.selectedCity;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : 20,
        vertical: isSmall ? 18 : 22,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Temperature and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.weatherTemperature,
                  style: TextStyle(
                    fontSize: isSmall ? 36 : 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${vm.weatherCondition} · $city',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmall ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vm.weatherHighLow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Sunny Icon Illustration
          Container(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppIcons.starMoonSvg,
              width: isSmall ? 44 : 52,
              height: isSmall ? 44 : 52,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFACC15),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Prayer Times Section Card Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPrayerTimesCard(BuildContext context, DashboardViewModel vm) {
    final isSmall = context.isSmall;
    final pillGap = isSmall ? 5.0 : 8.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Title + View All)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🕌 ', style: TextStyle(fontSize: 16)),
                  Text(
                    'Prayer Times',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showPrayerTimesSheet(context, vm),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.vibrantBlue,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5 Prayer Time Boxes Row
          Row(
            children: [
              for (int i = 0; i < vm.prayerPills.length; i++) ...[
                if (i > 0) SizedBox(width: pillGap),
                _buildPrayerPill(
                  context,
                  vm.prayerPills[i].name,
                  vm.prayerPills[i].time,
                  isHighlighted: vm.prayerPills[i].isHighlighted,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerPill(
    BuildContext context,
    String name,
    String time, {
    bool isHighlighted = false,
  }) {
    final isSmall = context.isSmall;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 8 : 10,
          horizontal: 2,
        ),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFFEFF6FF)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFFBFDBFE)
                : const Color(0xFFF1F5F9),
          ),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                name,
                style: TextStyle(
                  fontSize: isSmall ? 10 : 11,
                  fontWeight: FontWeight.w500,
                  color: isHighlighted
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                time,
                style: TextStyle(
                  fontSize: isSmall ? 12 : 13,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF1E293B),
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Currency Exchange Card Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCurrencyExchangeCard(
    BuildContext context,
    DashboardViewModel vm,
  ) {
    final isSmall = context.isSmall;
    final curr = vm.currentCurrency;
    final isPositive = curr['positive'] == 'true';

    return GestureDetector(
      onTap: vm.nextCurrency,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmall ? 14 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Euro Badge Icon
            Container(
              width: isSmall ? 40 : 44,
              height: isSmall ? 40 : 44,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '€',
                  style: TextStyle(
                    fontSize: isSmall ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF16A34A),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Main Rate Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        curr['pair']!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '⇄',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      curr['rate']!,
                      style: TextStyle(
                        fontSize: isSmall ? 15 : 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Increase Percentage & Today
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    curr['change']!,
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: isPositive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. Community Update Section Card Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCommunityUpdateCard(
    BuildContext context,
    DashboardViewModel vm,
  ) {
    final isSmall = context.isSmall;
    final city = vm.selectedCity;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Community Update',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.events);
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.vibrantBlue,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Inner Banner Item (Light Green Tint)
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.events);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Row(
                children: [
                  // Event Image Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      vm.communityEventImageUrl,
                      width: isSmall ? 46 : 52,
                      height: isSmall ? 46 : 52,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: isSmall ? 46 : 52,
                        height: isSmall ? 46 : 52,
                        color: const Color(0xFFDCFCE7),
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.eventSvg,
                            width: 22,
                            height: 22,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF16A34A),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Eid Festival Event in $city',
                          style: TextStyle(
                            fontSize: isSmall ? 13 : 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                            fontFamily: AppStrings.fontInter,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Parque del Retiro, $city',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontFamily: AppStrings.fontInter,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  SvgPicture.asset(
                    AppIcons.arrowForwardSvg,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF64748B),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 6. Emergency Numbers Section Card Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildEmergencyNumbersCard(
    BuildContext context,
    DashboardViewModel vm,
  ) {
    final isSmall = context.isSmall;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Emergency Numbers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              GestureDetector(
                onTap: () => _showEmergencyNumbersSheet(context, vm),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.vibrantBlue,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row of 2 Cards (Police & Ambulance)
          Row(
            children: [
              _buildEmergencyItem(
                title: 'Police',
                number: '091',
                iconAsset: AppIcons.blockShieldSvg,
                onTap: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Dialing Police (091)...'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildEmergencyItem(
                title: 'Ambulance',
                number: '112',
                iconAsset: AppIcons.callSvg,
                onTap: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Dialing Emergency 112...'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyItem({
    required String title,
    required String number,
    required String iconAsset,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE4E6),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    iconAsset,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFEF4444),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          number,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEF4444),
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
