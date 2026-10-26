import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/models/explore_country_model.dart';
import 'package:desilynks/viewmodels/explore_country/explore_country_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';

class ExploreCountriesView extends StatefulWidget {
  const ExploreCountriesView({super.key});

  @override
  State<ExploreCountriesView> createState() => _ExploreCountriesViewState();
}

class _ExploreCountriesViewState extends State<ExploreCountriesView> {
  final ScrollController _scrollController = ScrollController();

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

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final vm = context.read<ExploreCountryViewModel>();
      if (vm.meta.hasNextPage && !vm.isLoadingMore && !vm.isLoading) {
        vm.loadMoreCountries();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        title: Consumer<ExploreCountryViewModel>(
          builder: (context, vm, _) {
            final total = vm.meta.total > 0 ? vm.meta.total : vm.countries.length;
            return Row(
              children: [
                Text(
                  'Explore Countries',
                  style: TextStyle(
                    color: AppColors.slate900,
                    fontSize: context.sp(isSmall ? 16.5 : 18.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (total > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$total',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: context.sp(isSmall ? 11.0 : 12.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: Consumer<ExploreCountryViewModel>(
        builder: (context, vm, _) {
          final countries = vm.filteredCountries;
          final isLoading = vm.isLoading;
          final errorMessage = vm.errorMessage;

          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: () async {
              await vm.fetchCountries(refresh: true);
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Top Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.hMargin,
                      isSmall ? 12.0 : 16.0,
                      context.hMargin,
                      isSmall ? 10.0 : 12.0,
                    ),
                    child: Container(
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
                        hintText: "Search country, capital, currency...",
                        fillColor: AppColors.backgroundOffWhite,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        onChanged: (val) {
                          vm.onSearchChanged(val.trim());
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
                  ),
                ),

                // Content Slivers
                if (isLoading && vm.countries.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: context.hMargin),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildSkeletonCard(context),
                        childCount: 4,
                      ),
                    ),
                  )
                else if (errorMessage != null && vm.countries.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(context, vm, errorMessage),
                  )
                else if (countries.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, vm),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.hMargin,
                      vertical: 6,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < countries.length) {
                            final country = countries[index];
                            return _buildCountryCard(context, country);
                          }
                          return null;
                        },
                        childCount: countries.length,
                      ),
                    ),
                  ),

                // Pagination Loader Footer
                if (vm.meta.hasNextPage)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: vm.isLoadingMore
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primaryBlue,
                                ),
                              )
                            : TextButton.icon(
                                onPressed: () => vm.loadMoreCountries(),
                                icon: SvgPicture.asset(
                                  AppIcons.restartSvg,
                                  width: 14,
                                  height: 14,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.primaryBlue,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: Text(
                                  'Load more (${countries.length} of ${vm.meta.total})',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: context.sp(isSmall ? 12.0 : 13.0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountryCard(BuildContext context, ExploreCountry country) {
    final isSmall = context.isSmall;
    final hasBanner = country.bannerUrl != null && country.bannerUrl!.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: isSmall ? 12.0 : 14.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image with Gradient and Badges
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadius16),
                ),
                child: SizedBox(
                  height: isSmall ? 130.0 : 155.0,
                  width: double.infinity,
                  child: Stack(
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

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.black.withValues(alpha: 0.65),
                              Colors.transparent,
                              AppColors.black.withValues(alpha: 0.25),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),

                      // Title & Capital over banner bottom
                      Positioned(
                        bottom: isSmall ? 10.0 : 12.0,
                        left: isSmall ? 12.0 : 16.0,
                        right: isSmall ? 12.0 : 16.0,
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.sp(isSmall ? 17.0 : 19.0),
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: AppColors.black.withValues(alpha: 0.6),
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
                                          width: 12,
                                          height: 12,
                                          colorFilter: const ColorFilter.mode(
                                            Colors.white,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Capital: ${country.capital}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.95),
                                            fontSize: context.sp(isSmall ? 11.5 : 12.5),
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
              ),

              // Country Stats & Collection Badges
              Padding(
                padding: EdgeInsets.all(isSmall ? 12.0 : 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row (Population, Language, Currency)
                    Row(
                      children: [
                        if (country.population.isNotEmpty)
                          Expanded(
                            child: _buildInfoItem(
                              context,
                              label: 'Population',
                              value: country.formattedPopulation,
                              iconSvg: AppIcons.personSvg,
                              iconColor: AppColors.primaryBlue,
                            ),
                          ),
                        if (country.language.isNotEmpty)
                          Expanded(
                            child: _buildInfoItem(
                              context,
                              label: 'Language',
                              value: country.language,
                              iconSvg: AppIcons.translate,
                              iconColor: AppColors.primaryPurple,
                            ),
                          ),
                        if (country.currency.isNotEmpty)
                          Expanded(
                            child: _buildInfoItem(
                              context,
                              label: 'Currency',
                              value: country.currency,
                              iconSvg: AppIcons.euroSvg,
                              iconColor: AppColors.emerald,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: isSmall ? 10.0 : 12.0),
                    const Divider(height: 1, color: AppColors.slate100),
                    SizedBox(height: isSmall ? 10.0 : 12.0),

                    // Badges and Explore Arrow Row
                    Row(
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (country.emergencyCount > 0)
                              _buildBadge(
                                context,
                                iconSvg: AppIcons.shield,
                                label: '${country.emergencyCount} Emergency',
                                bgColor: AppColors.softRed,
                                textColor: AppColors.primaryRed,
                              ),
                            if (country.citiesCount > 0)
                              _buildBadge(
                                context,
                                iconSvg: AppIcons.apartmentSvg,
                                label: '${country.citiesCount} Cities',
                                bgColor: AppColors.softGreen,
                                textColor: AppColors.emerald,
                              ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Guide',
                              style: TextStyle(
                                fontSize: context.sp(isSmall ? 11.5 : 12.5),
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              AppIcons.More_arrow,
                              width: 14,
                              height: 14,
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildInfoItem(
    BuildContext context, {
    required String label,
    required String value,
    required String iconSvg,
    required Color iconColor,
  }) {
    final isSmall = context.isSmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              iconSvg,
              width: 11,
              height: 11,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(isSmall ? 10.0 : 11.0),
                color: AppColors.slate500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: context.sp(isSmall ? 12.0 : 13.0),
            color: AppColors.slate900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required String iconSvg,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    final isSmall = context.isSmall;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconSvg,
            width: isSmall ? 10.0 : 11.0,
            height: isSmall ? 10.0 : 11.0,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: context.sp(isSmall ? 9.5 : 10.5),
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
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
        child: Text(
          country.name.isNotEmpty
              ? country.name.substring(0, country.name.length >= 2 ? 2 : 1).toUpperCase()
              : 'CO',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    final isSmall = context.isSmall;

    return Container(
      margin: EdgeInsets.only(bottom: isSmall ? 12.0 : 14.0),
      height: isSmall ? 220.0 : 250.0,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        children: [
          Container(
            height: isSmall ? 130.0 : 155.0,
            decoration: const BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConstants.borderRadius16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ExploreCountryViewModel vm) {
    final isSmall = context.isSmall;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.slate100,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.searchSvg,
                width: 32,
                height: 32,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate400,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No Countries Found',
              style: TextStyle(
                fontSize: context.sp(isSmall ? 16.0 : 18.0),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              vm.searchQuery.isNotEmpty
                  ? 'No countries matched "${vm.searchQuery}". Try a different keyword.'
                  : 'No countries have been added yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.sp(isSmall ? 12.0 : 13.0),
                color: AppColors.slate500,
              ),
            ),
            if (vm.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.clearSearch(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ExploreCountryViewModel vm,
    String error,
  ) {
    final isSmall = context.isSmall;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppIcons.errorSvg,
              width: 44,
              height: 44,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryRed,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load countries',
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => vm.fetchCountries(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: SvgPicture.asset(
                AppIcons.restartSvg,
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
