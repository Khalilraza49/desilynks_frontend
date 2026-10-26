import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/explore_country/explore_country_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';

class ExploreSpainView extends StatefulWidget {
  const ExploreSpainView({super.key});

  @override
  State<ExploreSpainView> createState() => _ExploreSpainViewState();
}

class _ExploreSpainViewState extends State<ExploreSpainView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<ExploreCountryViewModel>();
      if (!vm.hasFetched && !vm.isLoading) {
        vm.fetchCountries();
      }
    });
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String iconSvg,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final isSmall = context.isSmall;
    final double iconBoxSize = isSmall ? 38.0 : 44.0;
    final double iconSize = isSmall ? 18.0 : 22.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius14),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 12.0 : 16.0,
              vertical: isSmall ? 10.0 : 14.0,
            ),
            child: Row(
              children: [
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius10,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconSvg,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                      width: iconSize,
                      height: iconSize,
                    ),
                  ),
                ),
                SizedBox(width: isSmall ? 10.0 : 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: context.sp(isSmall ? 13.5 : 14.5),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: context.sp(isSmall ? 10.5 : 11.5),
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[trailing, const SizedBox(width: 8)],
                SvgPicture.asset(
                  AppIcons.More_arrow,
                  width: isSmall ? 16.0 : 18.0,
                  height: isSmall ? 16.0 : 18.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountriesSection(
    BuildContext context,
    ExploreCountryViewModel vm,
  ) {
    final isSmall = context.isSmall;
    final totalCount = vm.meta.total > 0 ? vm.meta.total : vm.countries.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Countries',
                  style: TextStyle(
                    fontSize: context.sp(isSmall ? 15.5 : 17.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                if (totalCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius10,
                      ),
                    ),
                    child: Text(
                      '$totalCount',
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 10.5 : 11.5),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.exploreCountriesList);
              },
              borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 11.5 : 12.5),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      AppIcons.More_arrow,
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isSmall ? 8.0 : 10.0),
        _buildSectionCard(
          context,
          title: 'Explore Countries',
          subtitle: totalCount > 0
              ? 'Browse $totalCount countries, capitals, cities & emergency info'
              : 'Browse countries, capitals, cities & emergency info',
          iconSvg: AppIcons.worldSvg,
          iconColor: AppColors.primaryBlue,
          iconBgColor: AppColors.lightBlue,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.exploreCountriesList);
          },
        ),
        if (vm.countries.isNotEmpty) ...[
          SizedBox(height: isSmall ? 10.0 : 12.0),
          SizedBox(
            height: isSmall ? 76.0 : 84.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: vm.countries.length > 6 ? 6 : vm.countries.length,
              separatorBuilder: (context, index) =>
                  SizedBox(width: isSmall ? 8.0 : 10.0),
              itemBuilder: (context, index) {
                final country = vm.countries[index];
                final hasBanner =
                    country.bannerUrl != null && country.bannerUrl!.isNotEmpty;
                final double thumbSize = isSmall ? 36.0 : 40.0;

                return Container(
                  width: isSmall ? 140.0 : 155.0,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius12,
                    ),
                    border: Border.all(color: AppColors.slate100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.exploreCountryDetail,
                          arguments: country,
                        );
                      },
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius12,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 8.0 : 10.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: thumbSize,
                                height: thumbSize,
                                color: AppColors.lightBlue,
                                child: hasBanner
                                    ? Image.network(
                                        country.bannerUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Center(
                                              child: Text(
                                                country.name.isNotEmpty
                                                    ? country.name[0]
                                                          .toUpperCase()
                                                    : 'C',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                      )
                                    : Center(
                                        child: Text(
                                          country.name.isNotEmpty
                                              ? country.name[0].toUpperCase()
                                              : 'C',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    country.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: context.sp(
                                        isSmall ? 12.0 : 13.0,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    country.capital.isNotEmpty
                                        ? country.capital
                                        : (country.currency.isNotEmpty
                                              ? country.currency
                                              : 'Explore'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: context.sp(
                                        isSmall ? 10.0 : 11.0,
                                      ),
                                      color: AppColors.slate500,
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
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmall;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
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
        title: Text(
          'Explore',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(isSmall ? 16.5 : 18.0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ExploreCountryViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: () => vm.refreshCountries(),
            child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
              vertical: isSmall ? 12.0 : AppConstants.marginHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius12,
                    ),
                    border: Border.all(color: AppColors.slate200),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: vm.searchController,
                    hintText: "Search Here",
                    fillColor: AppColors.backgroundOffWhite,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    onChanged: (val) {
                      vm.onSearchChanged(val.trim());
                    },
                    onFieldSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.exploreCountriesList,
                        );
                      }
                    },
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        AppIcons.searchSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textLightGray,
                          BlendMode.srcIn,
                        ),
                        height: isSmall ? 18.0 : 20.0,
                        width: isSmall ? 18.0 : 20.0,
                      ),
                    ),
                    suffixIcon: vm.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: SvgPicture.asset(
                              AppIcons.crossSmallAltSvg,
                              width: isSmall ? 14.0 : 16.0,
                              height: isSmall ? 14.0 : 16.0,
                            ),
                            onPressed: () {
                              vm.clearSearch();
                            },
                          )
                        : null,
                  ),
                ),
                SizedBox(height: isSmall ? 16.0 : 22.0),

                // Countries Section (Tapping opens ExploreCountriesView with API data)
                _buildCountriesSection(context, vm),
                SizedBox(height: isSmall ? 16.0 : 22.0),

                // Community Groups
                Text(
                  'Community Groups',
                  style: TextStyle(
                    fontSize: context.sp(isSmall ? 15.5 : 17.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: isSmall ? 8.0 : 10.0),
                _buildSectionCard(
                  context,
                  title: 'Community Groups',
                  subtitle: 'Join groups and connect with people',
                  iconSvg: AppIcons.pcommunitySvg,
                  iconColor: AppColors.primaryBlue,
                  iconBgColor: AppColors.lightBlue,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.community);
                  },
                ),
                SizedBox(height: isSmall ? 16.0 : 22.0),

                // Events
                Text(
                  'Events',
                  style: TextStyle(
                    fontSize: context.sp(isSmall ? 15.5 : 17.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: isSmall ? 8.0 : 10.0),
                _buildSectionCard(
                  context,
                  title: 'Events',
                  subtitle: 'Discover and join community events',
                  iconSvg: AppIcons.calendarSvg,
                  iconColor: AppColors.emerald,
                  iconBgColor: AppColors.softGreen,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.events);
                  },
                ),
                SizedBox(height: isSmall ? 16.0 : 22.0),

                // Local Businesses
                Text(
                  'Local Businesses',
                  style: TextStyle(
                    fontSize: context.sp(isSmall ? 15.5 : 17.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: isSmall ? 8.0 : 10.0),
                _buildSectionCard(
                  context,
                  title: 'Local Businesses',
                  subtitle: 'Find Pakistani & Indian businesses',
                  iconSvg: AppIcons.shopSvg,
                  iconColor: AppColors.orange,
                  iconBgColor: AppColors.lightOrange,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.localBusiness);
                  },
                ),
                SizedBox(height: isSmall ? 16.0 : 22.0),

                // Resource Hub
                Text(
                  'Resource Hub',
                  style: TextStyle(
                    fontSize: context.sp(isSmall ? 15.5 : 17.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: isSmall ? 8.0 : 10.0),
                _buildSectionCard(
                  context,
                  title: 'Resource Hub',
                  subtitle: 'Guides, articles & legal documents',
                  iconSvg: AppIcons.closedBookSvg,
                  iconColor: AppColors.primaryPurple,
                  iconBgColor: AppColors.purpleLight100,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.resourceHub);
                  },
                ),

                SizedBox(height: isSmall ? 20.0 : 30.0),
              ],
            ),
          ),
          );
        },
      ),
    );
  }
}
