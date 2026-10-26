import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/models/explore_country_model.dart';
import 'package:desilynks/services/permissions/app_toast.dart';
import 'package:desilynks/viewmodels/explore_country/explore_country_viewmodel.dart';

class CountryDetailView extends StatelessWidget {
  final String countryId;
  final ExploreCountry? initialCountry;

  const CountryDetailView({
    super.key,
    required this.countryId,
    this.initialCountry,
  });

  void _loadDetail(BuildContext context) {
    final vm = context.read<ExploreCountryViewModel>();
    vm.fetchCountryDetail(
      countryId,
      initialCountry: initialCountry,
    );
  }

  Future<void> _makeCall(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) {
      AppToast.showWarning('Invalid phone number: $number');
      return;
    }
    final uri = Uri.parse('tel:$clean');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        AppToast.showError('Could not open dialer for $number');
      }
    } catch (e) {
      AppToast.showError('Could not launch call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmall;

    final vm = context.read<ExploreCountryViewModel>();
    if (vm.selectedCountry?.id != countryId && !vm.isLoadingDetail) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        _loadDetail(context);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: Consumer<ExploreCountryViewModel>(
        builder: (context, vm, child) {
          final country = vm.selectedCountry ?? initialCountry;

          if (vm.isLoadingDetail && country == null) {
            return _buildLoadingState(context);
          }

          if (vm.detailErrorMessage != null && country == null) {
            return _buildErrorState(context, vm.detailErrorMessage!);
          }

          if (country == null) {
            return _buildNotFoundState(context);
          }

          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: () async {
              await vm.fetchCountryDetail(countryId);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context, country),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.hMargin,
                      vertical: isSmall ? 12.0 : 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country name & capital header
                        _buildHeaderCard(context, country),
                        SizedBox(height: isSmall ? 12.0 : 16.0),

                        // Quick info stats (Capital, Population, Currency, Language)
                        _buildStatsGrid(context, country),
                        SizedBox(height: isSmall ? 20.0 : 26.0),

                        // Emergency Numbers section
                        _buildEmergencySection(context, country),
                        SizedBox(height: isSmall ? 20.0 : 26.0),

                        // Popular Cities section
                        _buildPopularCitiesSection(context, country),
                        SizedBox(height: isSmall ? 24.0 : 36.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ExploreCountry country) {
    final isSmall = context.isSmall;
    final hasBanner = country.bannerUrl != null && country.bannerUrl!.isNotEmpty;
    final double bannerHeight = isSmall ? 200.0 : (context.isTablet ? 300.0 : 230.0);

    return SliverAppBar(
      expandedHeight: bannerHeight,
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              AppIcons.arrowBackSvg,
              colorFilter: const ColorFilter.mode(
                AppColors.slate800,
                BlendMode.srcIn,
              ),
              width: isSmall ? 18.0 : 20.0,
              height: isSmall ? 18.0 : 20.0,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (hasBanner)
              Image.network(
                country.bannerUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildBannerFallback(context, country),
              )
            else
              _buildBannerFallback(context, country),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                    AppColors.black.withValues(alpha: 0.35),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: isSmall ? 14.0 : 18.0,
              left: context.hMargin,
              right: context.hMargin,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country.name,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: context.sp(isSmall ? 20.0 : 24.0),
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: AppColors.black.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        if (country.capital.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.pinSvg,
                                width: isSmall ? 12.0 : 14.0,
                                height: isSmall ? 12.0 : 14.0,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                country.capital,
                                style: TextStyle(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  fontSize: context.sp(isSmall ? 12.0 : 13.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildBannerFallback(BuildContext context, ExploreCountry country) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          AppIcons.worldSvg,
          width: 64,
          height: 64,
          colorFilter: ColorFilter.mode(
            AppColors.white.withValues(alpha: 0.35),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ExploreCountry country) {
    final isSmall = context.isSmall;

    return Container(
      padding: EdgeInsets.all(isSmall ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 44.0 : 52.0,
            height: isSmall ? 44.0 : 52.0,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.worldSvg,
                width: isSmall ? 22.0 : 26.0,
                height: isSmall ? 22.0 : 26.0,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryBlue,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(width: isSmall ? 10.0 : 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country.name,
                  style: TextStyle(
                    fontSize: context.sp(isSmall ? 16.0 : 18.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  country.capital.isNotEmpty
                      ? 'Capital: ${country.capital}'
                      : 'Explore Country Guide',
                  style: TextStyle(
                    fontSize: context.sp(isSmall ? 11.5 : 13.0),
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppIcons.verifySvg,
                  width: 13,
                  height: 13,
                  colorFilter: const ColorFilter.mode(
                    AppColors.emerald,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Public Guide',
                  style: TextStyle(
                    color: AppColors.emerald,
                    fontSize: context.sp(isSmall ? 10.0 : 11.0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, ExploreCountry country) {
    final isTablet = context.isTablet;
    final isSmall = context.isSmall;

    final stats = [
      {
        'title': 'Capital',
        'value': country.capital.isNotEmpty ? country.capital : 'N/A',
        'icon': AppIcons.pinSvg,
        'color': AppColors.primaryRed,
        'bg': AppColors.softRed,
      },
      {
        'title': 'Population',
        'value': country.formattedPopulation,
        'icon': AppIcons.personSvg,
        'color': AppColors.primaryBlue,
        'bg': AppColors.lightBlue,
      },
      {
        'title': 'Currency',
        'value': country.currency.isNotEmpty ? country.currency : 'N/A',
        'icon': AppIcons.euroSvg,
        'color': AppColors.emerald,
        'bg': AppColors.softGreen,
      },
      {
        'title': 'Language',
        'value': country.language.isNotEmpty ? country.language : 'N/A',
        'icon': AppIcons.translate,
        'color': AppColors.primaryPurple,
        'bg': AppColors.purpleLight100,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: isSmall ? 8.0 : 12.0,
        mainAxisSpacing: isSmall ? 8.0 : 12.0,
        childAspectRatio: isSmall ? 1.7 : 1.85,
      ),
      itemBuilder: (context, index) {
        final item = stats[index];
        return Container(
          padding: EdgeInsets.all(isSmall ? 10.0 : 12.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius14),
            border: Border.all(color: AppColors.slate100),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isSmall ? 34.0 : 38.0,
                height: isSmall ? 34.0 : 38.0,
                decoration: BoxDecoration(
                  color: item['bg'] as Color,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius10),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    item['icon'] as String,
                    width: isSmall ? 16.0 : 18.0,
                    height: isSmall ? 16.0 : 18.0,
                    colorFilter: ColorFilter.mode(
                      item['color'] as Color,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmall ? 8.0 : 10.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 10.5 : 11.5),
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['value'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 12.5 : 14.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
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

  Widget _buildEmergencySection(BuildContext context, ExploreCountry country) {
    final isSmall = context.isSmall;
    final numbers = country.emergencyNumbers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.softRed,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
              ),
              child: SvgPicture.asset(
                AppIcons.shield,
                width: isSmall ? 14.0 : 16.0,
                height: isSmall ? 14.0 : 16.0,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryRed,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Emergency Numbers',
              style: TextStyle(
                fontSize: context.sp(isSmall ? 15.0 : 17.0),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius10),
              ),
              child: Text(
                '${numbers.length}',
                style: TextStyle(
                  fontSize: context.sp(isSmall ? 11.0 : 12.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isSmall ? 10.0 : 14.0),
        if (numbers.isEmpty)
          _buildEmptySectionBox(
            context,
            iconSvg: AppIcons.shield,
            message: 'No emergency numbers registered for this country yet.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: numbers.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: isSmall ? 8.0 : 10.0),
            itemBuilder: (context, index) {
              final em = numbers[index];
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 12.0 : 16.0,
                  vertical: isSmall ? 10.0 : 12.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius14),
                  border: Border.all(color: AppColors.slate100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: isSmall ? 36.0 : 42.0,
                      height: isSmall ? 36.0 : 42.0,
                      decoration: BoxDecoration(
                        color: AppColors.softRed,
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius10),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppIcons.callReceiveSvg,
                          width: isSmall ? 16.0 : 20.0,
                          height: isSmall ? 16.0 : 20.0,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryRed,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isSmall ? 10.0 : 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            em.title,
                            style: TextStyle(
                              fontSize: context.sp(isSmall ? 13.5 : 14.5),
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            em.number,
                            style: TextStyle(
                              fontSize: context.sp(isSmall ? 12.0 : 13.0),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _makeCall(em.number),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius10),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 10.0 : 14.0,
                          vertical: isSmall ? 7.0 : 9.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius:
                              BorderRadius.circular(AppConstants.borderRadius10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppIcons.callSvg,
                              width: isSmall ? 13.0 : 15.0,
                              height: isSmall ? 13.0 : 15.0,
                              colorFilter: const ColorFilter.mode(
                                AppColors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Call',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: context.sp(isSmall ? 11.5 : 12.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPopularCitiesSection(BuildContext context, ExploreCountry country) {
    final isSmall = context.isSmall;
    final isTablet = context.isTablet;
    final cities = country.popularCities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
              ),
              child: SvgPicture.asset(
                AppIcons.apartmentSvg,
                width: isSmall ? 14.0 : 16.0,
                height: isSmall ? 14.0 : 16.0,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryBlue,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Popular Cities',
              style: TextStyle(
                fontSize: context.sp(isSmall ? 15.0 : 17.0),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius10),
              ),
              child: Text(
                '${cities.length}',
                style: TextStyle(
                  fontSize: context.sp(isSmall ? 11.0 : 12.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isSmall ? 10.0 : 14.0),
        if (cities.isEmpty)
          _buildEmptySectionBox(
            context,
            iconSvg: AppIcons.apartmentSvg,
            message: 'No popular cities listed for this country yet.',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cities.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : (isSmall ? 1 : 2),
              crossAxisSpacing: isSmall ? 8.0 : 12.0,
              mainAxisSpacing: isSmall ? 8.0 : 12.0,
              childAspectRatio: isSmall ? 2.4 : 1.35,
            ),
            itemBuilder: (context, index) {
              final city = cities[index];
              final hasBanner = city.bannerUrl != null && city.bannerUrl!.isNotEmpty;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius16),
                  border: Border.all(color: AppColors.slate100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasBanner)
                        Image.network(
                          city.bannerUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildCityBannerPlaceholder(context, city.name),
                        )
                      else
                        _buildCityBannerPlaceholder(context, city.name),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: isSmall ? 10.0 : 12.0,
                        left: isSmall ? 10.0 : 12.0,
                        right: isSmall ? 10.0 : 12.0,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.locationSvg,
                              width: isSmall ? 12.0 : 14.0,
                              height: isSmall ? 12.0 : 14.0,
                              colorFilter: const ColorFilter.mode(
                                AppColors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                city.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: context.sp(isSmall ? 13.0 : 14.5),
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.black.withValues(alpha: 0.6),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCityBannerPlaceholder(BuildContext context, String cityName) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF64748B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          AppIcons.apartmentSvg,
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(
            AppColors.white.withValues(alpha: 0.3),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySectionBox(
    BuildContext context, {
    required String iconSvg,
    required String message,
  }) {
    final isSmall = context.isSmall;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 14.0 : 20.0,
        vertical: isSmall ? 16.0 : 22.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius14),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            iconSvg,
            width: isSmall ? 28.0 : 34.0,
            height: isSmall ? 28.0 : 34.0,
            colorFilter: const ColorFilter.mode(
              AppColors.slate400,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(isSmall ? 12.0 : 13.0),
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isSmall = context.isSmall;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 52.0 : 60.0,
            height: isSmall ? 52.0 : 60.0,
            decoration: const BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.worldSvg,
                width: isSmall ? 26.0 : 30.0,
                height: isSmall ? 26.0 : 30.0,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryBlue,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading country details...',
            style: TextStyle(
              fontSize: context.sp(isSmall ? 12.5 : 14.0),
              color: AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final isSmall = context.isSmall;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 20.0 : 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSmall ? 56.0 : 64.0,
              height: isSmall ? 56.0 : 64.0,
              decoration: const BoxDecoration(
                color: AppColors.softRed,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.errorSvg,
                  width: isSmall ? 28.0 : 32.0,
                  height: isSmall ? 28.0 : 32.0,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryRed,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmall ? 14.0 : 18.0),
            Text(
              'Failed to load details',
              style: TextStyle(
                fontSize: context.sp(isSmall ? 16.0 : 18.0),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.sp(isSmall ? 12.0 : 13.0),
                color: AppColors.slate500,
              ),
            ),
            SizedBox(height: isSmall ? 16.0 : 22.0),
            ElevatedButton.icon(
              onPressed: () => _loadDetail(context),
              icon: SvgPicture.asset(
                AppIcons.restartSvg,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 18.0 : 24.0,
                  vertical: isSmall ? 10.0 : 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    final isSmall = context.isSmall;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppIcons.infoSvg,
              width: isSmall ? 40.0 : 48.0,
              height: isSmall ? 40.0 : 48.0,
              colorFilter: const ColorFilter.mode(
                AppColors.slate400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Country Not Found',
              style: TextStyle(
                fontSize: context.sp(isSmall ? 16.0 : 18.0),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
