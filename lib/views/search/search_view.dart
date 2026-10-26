import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/models/job_model.dart';
import 'package:desilynks/models/worker_profile_model.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/viewmodels/search/search_viewmodel.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/my_ads_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/favourite_ads_viewmodel.dart';
import 'package:desilynks/viewmodels/community/community_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';

class SearchView extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const SearchView({super.key, this.onMenuPressed});

  void _performSearch(BuildContext context, String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    FocusScope.of(context).unfocus();
    final searchViewModel = Provider.of<SearchViewModel>(
      context,
      listen: false,
    );
    searchViewModel.performSearch(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewModel>(
      builder: (context, searchVM, _) {
        final navViewModel = Provider.of<NavigationViewModel>(context);
        final authVM = Provider.of<AuthViewModel>(context);
        final jobsVM = Provider.of<JobsViewModel>(context);
        final myAdsVM = Provider.of<MyAdsViewModel>(context);
        final favVM = Provider.of<FavouriteAdsViewModel>(context);
        final communityVM = Provider.of<CommunityViewModel>(context);

        final recentSearches = searchVM.recentSearches;
        final suggestions = searchVM.suggestions;

        final currentUser = authVM.currentUser;
        final currentUserId = currentUser?.id;

        // 1. My Ads Subtitle (Active listings count)
        final int activeAdsCount = currentUserId != null
            ? myAdsVM.userAds
                  .where(
                    (ad) =>
                        (ad.ownerId.isEmpty || ad.ownerId == currentUserId) &&
                        ad.status == 'PUBLISHED',
                  )
                  .length
            : myAdsVM.activeCount;
        final String adsSubtitle = searchVM.formatAdsSubtitle(activeAdsCount);

        // 2. Favourites Subtitle (Saved items count)
        final int favsCount = favVM.favouritedIds.isNotEmpty
            ? favVM.favouritedIds.length
            : favVM.savedItems.length;
        final String favSubtitle = searchVM.formatFavsSubtitle(favsCount);

        // 3. My Jobs Subtitle (Jobs posted by user's own ID)
        final int postedJobsCount = currentUserId != null
            ? (jobsVM.userJobs.isNotEmpty
                  ? jobsVM.userJobs
                        .where(
                          (j) =>
                              j.employerId.isEmpty ||
                              j.employerId == currentUserId ||
                              j.employer?.id == currentUserId,
                        )
                        .length
                  : jobsVM.publicJobs
                        .where(
                          (j) =>
                              j.employerId == currentUserId ||
                              j.employer?.id == currentUserId,
                        )
                        .length)
            : jobsVM.userJobs.length;
        final String jobsSubtitle = searchVM.formatJobsSubtitle(postedJobsCount);

        // 4. My Posts Subtitle (Community posts by the user)
        final int communityPostsCount = currentUserId != null
            ? communityVM.posts
                  .where(
                    (p) =>
                        p.authorId == currentUserId ||
                        p.author?.id == currentUserId ||
                        (currentUser != null &&
                            p.authorName.isNotEmpty &&
                            p.authorName.toLowerCase() ==
                                currentUser.username.toLowerCase()),
                  )
                  .length
            : 0;
        final String postsSubtitle =
            searchVM.formatPostsSubtitle(communityPostsCount);

        // Dynamic hint text based on active category
        String hintText;
        switch (searchVM.selectedTabIndex) {
          case 0:
            hintText = 'Search properties, rooms, rent...';
            break;
          case 1:
            hintText = 'Search jobs, titles, skills...';
            break;
          case 2:
            hintText = 'Search workers, services, trades...';
            break;
          default:
            hintText = 'Search Items...';
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: SvgPicture.asset(
                AppIcons.arrowBackBasicSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate900,
                  BlendMode.srcIn,
                ),
                height: (context.scale(24.0)).clamp(20.0, 26.0),
                width: (context.scale(24.0)).clamp(20.0, 26.0),
              ),
              onPressed: () {
                if (searchVM.hasSearched) {
                  searchVM.clearSearch();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else if (navViewModel.isMarketplaceActive &&
                    navViewModel.isSearchActive) {
                  navViewModel.openMarketplace();
                } else if (onMenuPressed != null) {
                  onMenuPressed!();
                } else {
                  navViewModel.setIndex(0);
                }
              },
            ),
            title: Container(
              height: (context.scaleH(44.0)).clamp(40.0, 48.0),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
              ),
              child: CustomTextField(
                controller: searchVM.searchController,
                textInputAction: TextInputAction.search,
                fontSize: context.sp(14),
                onChanged: (val) {
                  searchVM.fetchSuggestions(val);
                },
                onFieldSubmitted: (val) => _performSearch(context, val),
                hintText: hintText,
                prefixIcon: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      _performSearch(context, searchVM.searchController.text),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      AppIcons.searchSvg,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate400,
                        BlendMode.srcIn,
                      ),
                      height: (context.scale(20.0)).clamp(18.0, 22.0),
                      width: (context.scale(20.0)).clamp(18.0, 22.0),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                suffixIcon: searchVM.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.slate400,
                        ),
                        onPressed: () {
                          searchVM.clearSearch();
                        },
                      )
                    : null,
                fillColor: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  searchVM.cancelSearch();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else if (navViewModel.isMarketplaceActive &&
                      navViewModel.isSearchActive) {
                    navViewModel.openMarketplace();
                  } else {
                    navViewModel.setIndex(0);
                  }
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.vibrantBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: context.sp(14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.hMargin,
                vertical: (context.scaleH(12.0)).clamp(8.0, 16.0),
              ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category Pills (Properties / Jobs / Workers) ──
                  _buildCategorySelector(context, searchVM),

                  // ── Sub-Filters Bar (Rooms, Apartments, Full Time, etc.) ──
                  _buildSubFilterBar(context, searchVM),

                  // ── Autocomplete Suggestions Dropdown ──
                  if (suggestions.isNotEmpty && !searchVM.hasSearched) ...[
                    _buildSuggestionsList(context, searchVM, suggestions),
                  ]
                  // ── Search Results View (When Searched) ──
                  else if (searchVM.hasSearched) ...[
                    _buildSearchResultsSection(context, searchVM),
                  ]
                  // ── Default State (Recent, Popular, Browse) ──
                  else ...[
                    _buildDefaultBrowseSection(
                      context: context,
                      searchVM: searchVM,
                      recentSearches: recentSearches,
                      adsSubtitle: adsSubtitle,
                      favSubtitle: favSubtitle,
                      jobsSubtitle: jobsSubtitle,
                      postsSubtitle: postsSubtitle,
                    ),
                  ],

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
  // 1. Category Selector Pills
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCategorySelector(
    BuildContext context,
    SearchViewModel searchVM,
  ) {
    final categories = [
      {'title': 'Properties', 'icon': AppIcons.apartmentSvg, 'index': 0},
      {'title': 'Jobs', 'icon': AppIcons.briefcaseSvg, 'index': 1},
      {'title': 'Workers', 'icon': AppIcons.personSvg, 'index': 2},
    ];

    return Container(
      height: (context.scaleH(40.0)).clamp(36.0, 44.0),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final isSelected = searchVM.selectedTabIndex == idx;
          final cat = categories[idx];
          final String title = cat['title'] as String;
          final String icon = cat['icon'] as String;

          String? countText;
          if (searchVM.hasSearched && isSelected && searchVM.searchMeta != null) {
            countText = '(${searchVM.searchMeta!.total})';
          }

          return GestureDetector(
            onTap: () => searchVM.setSelectedTab(idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: (context.scale(14.0)).clamp(12.0, 18.0),
                vertical: (context.scaleH(8.0)).clamp(6.0, 10.0),
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.vibrantBlue : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.vibrantBlue : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.vibrantBlue.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    icon,
                    height: 15,
                    width: 15,
                    colorFilter: ColorFilter.mode(
                      isSelected ? Colors.white : AppColors.slate600,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.sp(13),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.slate700,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  if (countText != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      countText,
                      style: TextStyle(
                        fontSize: context.sp(11.5),
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppColors.slate500,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1.1 Sub-Filter Pills (Rooms, Apartments, Houses / Job Types / Worker Services)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSubFilterBar(
    BuildContext context,
    SearchViewModel searchVM,
  ) {
    if (searchVM.selectedTabIndex == 0) {
      // Properties Sub-filters: All, Room, Apartment, House
      final filters = [
        {'label': 'All Properties', 'value': null},
        {'label': 'Rooms', 'value': 'ROOM'},
        {'label': 'Apartments', 'value': 'APARTMENT'},
        {'label': 'Houses', 'value': 'HOUSE'},
      ];

      return Container(
        height: (context.scaleH(34.0)).clamp(30.0, 38.0),
        margin: const EdgeInsets.only(bottom: 14),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, idx) {
            final f = filters[idx];
            final isSelected = searchVM.selectedPropertyType == f['value'];
            return GestureDetector(
              onTap: () => searchVM.setSelectedPropertyType(f['value']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.vibrantBlue.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.vibrantBlue : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: context.sp(12),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.vibrantBlue : AppColors.slate700,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else if (searchVM.selectedTabIndex == 1) {
      // Jobs Sub-filters: All, Full Time, Part Time, Remote
      final filters = [
        {'label': 'All Jobs', 'type': null, 'mode': null},
        {'label': 'Full Time', 'type': 'FULL_TIME', 'mode': null},
        {'label': 'Part Time', 'type': 'PART_TIME', 'mode': null},
        {'label': 'Remote', 'type': null, 'mode': 'REMOTE'},
      ];

      return Container(
        height: (context.scaleH(34.0)).clamp(30.0, 38.0),
        margin: const EdgeInsets.only(bottom: 14),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, idx) {
            final f = filters[idx];
            final bool isSelected = (f['type'] != null && searchVM.selectedJobType == f['type']) ||
                (f['mode'] != null && searchVM.selectedWorkMode == f['mode']) ||
                (f['type'] == null && f['mode'] == null && searchVM.selectedJobType == null && searchVM.selectedWorkMode == null);

            return GestureDetector(
              onTap: () {
                if (f['type'] != null) {
                  searchVM.setSelectedJobType(f['type']);
                } else if (f['mode'] != null) {
                  searchVM.setSelectedWorkMode(f['mode']);
                } else {
                  searchVM.setSelectedJobType(null);
                  searchVM.setSelectedWorkMode(null);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.vibrantBlue.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.vibrantBlue : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: context.sp(12),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.vibrantBlue : AppColors.slate700,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Workers Sub-filters: All, Available Today, Electrician, Plumber, Cleaner, Painter
      final filters = [
        {'label': 'All Workers', 'service': null, 'today': false},
        {'label': 'Available Today', 'service': null, 'today': true},
        {'label': 'Electrician', 'service': 'ELECTRICIAN', 'today': false},
        {'label': 'Plumber', 'service': 'PLUMBER', 'today': false},
        {'label': 'Cleaner', 'service': 'CLEANER', 'today': false},
        {'label': 'Painter', 'service': 'PAINTER', 'today': false},
      ];

      return Container(
        height: (context.scaleH(34.0)).clamp(30.0, 38.0),
        margin: const EdgeInsets.only(bottom: 14),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, idx) {
            final f = filters[idx];
            final bool isTodayFilter = f['today'] == true;
            final bool isSelected = isTodayFilter
                ? searchVM.selectedWorkerAvailableToday
                : (searchVM.selectedWorkerService == f['service'] && !searchVM.selectedWorkerAvailableToday);

            return GestureDetector(
              onTap: () {
                if (isTodayFilter) {
                  searchVM.toggleWorkerAvailableToday();
                } else {
                  if (searchVM.selectedWorkerAvailableToday) {
                    searchVM.toggleWorkerAvailableToday();
                  }
                  searchVM.setSelectedWorkerService(f['service'] as String?);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.vibrantBlue.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.vibrantBlue : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  f['label'] as String,
                  style: TextStyle(
                    fontSize: context.sp(12),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.vibrantBlue : AppColors.slate700,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Suggestions List
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSuggestionsList(
    BuildContext context,
    SearchViewModel searchVM,
    List<String> suggestions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suggestions (${suggestions.length})',
              style: TextStyle(
                fontSize: context.sp(15),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            TextButton(
              onPressed: () => searchVM.clearSuggestions(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Dismiss',
                style: TextStyle(
                  color: AppColors.slate500,
                  fontSize: context.sp(12.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.blackOpacity4,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestions.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                leading: SvgPicture.asset(
                  AppIcons.searchSvg,
                  colorFilter: const ColorFilter.mode(
                    AppColors.slate400,
                    BlendMode.srcIn,
                  ),
                  height: 16,
                  width: 16,
                ),
                title: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate800,
                  ),
                ),
                trailing: const Icon(
                  Icons.north_west_rounded,
                  size: 15,
                  color: AppColors.slate400,
                ),
                onTap: () {
                  _performSearch(context, suggestion);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Search Results Section
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSearchResultsSection(
    BuildContext context,
    SearchViewModel searchVM,
  ) {
    final query = searchVM.currentQuery;
    final totalCount = searchVM.currentResultsCount;

    String categoryLabel;
    switch (searchVM.selectedTabIndex) {
      case 0:
        if (searchVM.selectedPropertyType == 'ROOM') {
          categoryLabel = 'Rooms';
        } else if (searchVM.selectedPropertyType == 'APARTMENT') {
          categoryLabel = 'Apartments';
        } else if (searchVM.selectedPropertyType == 'HOUSE') {
          categoryLabel = 'Houses';
        } else {
          categoryLabel = 'Properties';
        }
        break;
      case 1:
        if (searchVM.selectedJobType != null) {
          categoryLabel = '${searchVM.selectedJobType!.replaceAll('_', ' ')} Jobs';
        } else if (searchVM.selectedWorkMode != null) {
          categoryLabel = '${searchVM.selectedWorkMode} Jobs';
        } else {
          categoryLabel = 'Jobs';
        }
        break;
      case 2:
        if (searchVM.selectedWorkerService != null) {
          categoryLabel = '${searchVM.selectedWorkerService} Workers';
        } else if (searchVM.selectedWorkerAvailableToday) {
          categoryLabel = 'Available Today Workers';
        } else {
          categoryLabel = 'Workers';
        }
        break;
      default:
        categoryLabel = 'Results';
    }

    final String titleText = query.isNotEmpty
        ? '$categoryLabel for "$query" ($totalCount)'
        : '$categoryLabel ($totalCount)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                titleText,
                style: TextStyle(
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => searchVM.clearSearch(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Clear',
                style: TextStyle(
                  color: AppColors.vibrantBlue,
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Loading State
        if (searchVM.isLoading &&
            (searchVM.propertyResults.isEmpty &&
                searchVM.jobResults.isEmpty &&
                searchVM.workerResults.isEmpty)) ...[
          _buildLoadingSkeletons(context),
        ]
        // Error State
        else if (searchVM.errorMessage != null) ...[
          _buildErrorState(context, searchVM),
        ]
        // Empty State
        else if (totalCount == 0 && !searchVM.isLoading) ...[
          _buildEmptyResultsState(context, searchVM, categoryLabel, query),
        ]
        // Results List
        else ...[
          if (searchVM.selectedTabIndex == 0) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchVM.propertyResults.length,
              itemBuilder: (context, i) =>
                  _buildPropertyCard(context, searchVM.propertyResults[i]),
            ),
          ] else if (searchVM.selectedTabIndex == 1) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchVM.jobResults.length,
              itemBuilder: (context, i) =>
                  _buildJobCard(context, searchVM.jobResults[i]),
            ),
          ] else if (searchVM.selectedTabIndex == 2) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchVM.workerResults.length,
              itemBuilder: (context, i) =>
                  _buildWorkerCard(context, searchVM.workerResults[i]),
            ),
          ],

          // Pagination: Load More
          if (searchVM.hasMorePages) ...[
            const SizedBox(height: 12),
            Center(
              child: searchVM.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.vibrantBlue,
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () => searchVM.loadMore(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.vibrantBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: (context.scale(24.0)).clamp(18.0, 30.0),
                          vertical: (context.scaleH(10.0)).clamp(8.0, 14.0),
                        ),
                      ),
                      child: Text(
                        'Load More Results',
                        style: TextStyle(
                          color: AppColors.vibrantBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: context.sp(13.5),
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Relevance Score Badge Helper
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildScoreBadge(double? score) {
    if (score == null || score <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 12, color: AppColors.vibrantBlue),
          const SizedBox(width: 2),
          Text(
            'Score ${score.toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.vibrantBlue,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Property Result Card
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPropertyCard(BuildContext context, PropertyModel property) {
    String photoUrl = property.propertyPhotos.isNotEmpty
        ? property.propertyPhotos.first.url
        : '';
    if (photoUrl.isNotEmpty && photoUrl.startsWith('/')) {
      photoUrl = '${ApiEndpoints.baseUrl}$photoUrl';
    }

    final String cleanRent = property.monthlyRent
        .replaceAll('/month', '')
        .replaceAll('/mo', '')
        .trim();
    final double? parsedPrice = double.tryParse(cleanRent);
    final String formattedPrice = parsedPrice != null
        ? parsedPrice.toStringAsFixed(0)
        : cleanRent;

    final double imageHeight = (context.scaleH(140)).clamp(120.0, 160.0);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.roomSingleDetails,
          arguments: property,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackOpacity4,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: photoUrl.isNotEmpty
                      ? Image.network(
                          photoUrl,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImageFallback(
                            imageHeight,
                          ),
                        )
                      : _buildImageFallback(imageHeight),
                ),
                // Type Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.slate900.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      property.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: context.sp(10.5),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Relevance Score Badge
                if (property.searchScore != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildScoreBadge(property.searchScore),
                  ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: TextStyle(
                            fontSize: context.sp(15),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '€$formattedPrice/mo',
                        style: TextStyle(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.bold,
                          color: AppColors.vibrantBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.slate400,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location.isNotEmpty
                              ? property.location
                              : 'Location not specified',
                          style: TextStyle(
                            fontSize: context.sp(12.5),
                            color: AppColors.slate500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Specs (Bed, Bath)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${property.noOfBedRooms} Bed',
                          style: TextStyle(
                            fontSize: context.sp(11.5),
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${property.noOfBathRooms} Bath',
                          style: TextStyle(
                            fontSize: context.sp(11.5),
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFallback(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: const Icon(
        Icons.apartment_rounded,
        size: 36,
        color: AppColors.slate300,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Job Result Card
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildJobCard(BuildContext context, JobModel job) {
    final String salaryText =
        '€${job.salary} / ${job.salaryPeriod.displayName}';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.jobDetail,
          arguments: job,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackOpacity4,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Score Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: context.sp(15.5),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.companyName.isNotEmpty
                            ? job.companyName
                            : 'Direct Employer',
                        style: TextStyle(
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (job.searchScore != null) ...[
                  const SizedBox(width: 8),
                  _buildScoreBadge(job.searchScore),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.slate400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location.isNotEmpty ? job.location : 'Flexible location',
                    style: TextStyle(
                      fontSize: context.sp(12.5),
                      color: AppColors.slate500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Chips: Type & Work Mode
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.type.displayName,
                    style: TextStyle(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w600,
                      color: AppColors.vibrantBlue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.workMode.displayName,
                    style: TextStyle(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Salary & Apply Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  salaryText,
                  style: TextStyle(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.vibrantBlue,
                  ),
                ),
                Text(
                  'View Details →',
                  style: TextStyle(
                    fontSize: context.sp(12.5),
                    fontWeight: FontWeight.w600,
                    color: AppColors.vibrantBlue,
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
  // Worker Result Card
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWorkerCard(BuildContext context, WorkerProfileModel worker) {
    final String avatarUrl = worker.profilePhotoUrl ?? '';
    final String name =
        worker.name.isNotEmpty ? worker.name : worker.profession;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.hireWorkerForm,
          arguments: {
            'id': worker.id,
            'name': name,
            'profession': worker.profession,
            'hourlyRate': worker.hourlyRate,
            'avatar': avatarUrl,
            'location': worker.areaCovered,
            'workerTypeId': worker.profession,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackOpacity4,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar + Name + Score
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with online dot
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFF1F5F9),
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl.isEmpty
                          ? SvgPicture.asset(
                              AppIcons.personSvg,
                              height: 22,
                              width: 22,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate400,
                                BlendMode.srcIn,
                              ),
                            )
                          : null,
                    ),
                    if (worker.isAvailableToday)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.emerald,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: context.sp(15.5),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        worker.profession,
                        style: TextStyle(
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (worker.searchScore != null) ...[
                  const SizedBox(width: 8),
                  _buildScoreBadge(worker.searchScore),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // Area covered & Experience
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.slate400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    worker.areaCovered.isNotEmpty
                        ? worker.areaCovered
                        : 'Local Area',
                    style: TextStyle(
                      fontSize: context.sp(12.5),
                      color: AppColors.slate500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (worker.yearsOfExperience > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${worker.yearsOfExperience} yrs exp',
                      style: TextStyle(
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Rates & Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  worker.hourlyRate.isNotEmpty
                      ? '€${worker.hourlyRate}/hr'
                      : (worker.dailyRate.isNotEmpty
                          ? '€${worker.dailyRate}/day'
                          : 'Rates on request'),
                  style: TextStyle(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.vibrantBlue,
                  ),
                ),
                Text(
                  'Hire Worker →',
                  style: TextStyle(
                    fontSize: context.sp(12.5),
                    fontWeight: FontWeight.w600,
                    color: AppColors.vibrantBlue,
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
  // Skeletons & Empty & Error States
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildLoadingSkeletons(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.slate400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, SearchViewModel searchVM) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 36,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 8),
          Text(
            'Search Error',
            style: TextStyle(
              fontSize: context.sp(15),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF991B1B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            searchVM.errorMessage ?? 'Failed to retrieve search results.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(13),
              color: const Color(0xFFB91C1C),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => searchVM.search(searchVM.currentQuery),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vibrantBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsState(
    BuildContext context,
    SearchViewModel searchVM,
    String category,
    String query,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: AppColors.slate400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No $category Found',
            style: TextStyle(
              fontSize: context.sp(17),
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            query.isNotEmpty
                ? 'We couldn\'t find any $category matching "$query".\nTry checking the spelling or switch categories.'
                : 'No $category currently available in this filter.\nTry switching to another category or filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(13.5),
              color: AppColors.slate500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => searchVM.clearSearch(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.vibrantBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reset Search',
              style: TextStyle(color: AppColors.vibrantBlue),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Default Browse Section (Recent, Popular, Browse By Grid)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildDefaultBrowseSection({
    required BuildContext context,
    required SearchViewModel searchVM,
    required List<String> recentSearches,
    required String adsSubtitle,
    required String favSubtitle,
    required String jobsSubtitle,
    required String postsSubtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Searches
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: context.sp(17),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              TextButton(
                onPressed: () => searchVM.clearRecentSearches(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: AppColors.vibrantBlue,
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentSearches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final term = recentSearches[index];
              return GestureDetector(
                onTap: () => _performSearch(context, term),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (context.scale(14.0)).clamp(10.0, 16.0),
                    vertical: (context.scaleH(12.0)).clamp(9.0, 14.0),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.blackOpacity4,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.TimerSvg,
                        height: 18,
                        width: 18,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate400,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          term,
                          style: TextStyle(
                            fontSize: context.sp(14),
                            color: AppColors.slate700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        // Popular Searches
        Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: context.sp(17),
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: searchVM.popularSearches.map((item) {
            return GestureDetector(
              onTap: () => _performSearch(context, item['label']!),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (context.scale(14.0)).clamp(10.0, 16.0),
                  vertical: (context.scaleH(9.0)).clamp(7.0, 11.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['emoji']!,
                      style: TextStyle(fontSize: context.sp(14)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['label']!,
                      style: TextStyle(
                        color: AppColors.vibrantBlue,
                        fontSize: context.sp(13.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // Browse By (2x2 Grid)
        Text(
          'Browse By',
          style: TextStyle(
            fontSize: context.sp(17),
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            // My Ads Card
            Expanded(
              child: _buildBrowseCard(
                context: context,
                title: 'My Ads',
                subtitle: adsSubtitle,
                icon: AppIcons.shopSvg,
                iconBgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                route: AppRoutes.myAds,
              ),
            ),
            const SizedBox(width: 12),
            // Favourites Card
            Expanded(
              child: _buildBrowseCard(
                context: context,
                title: 'Favourites',
                subtitle: favSubtitle,
                icon: AppIcons.favSvg,
                iconBgColor: const Color(0xFFFEE2E8),
                iconColor: const Color(0xFFEF4444),
                route: AppRoutes.favouriteAds,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // My Jobs Card
            Expanded(
              child: _buildBrowseCard(
                context: context,
                title: 'My Jobs',
                subtitle: jobsSubtitle,
                icon: AppIcons.briefcaseSvg,
                iconBgColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
                route: AppRoutes.myJobs,
              ),
            ),
            const SizedBox(width: 12),
            // My Posts Card (FIXED ROUTE -> myCommunityPosts)
            Expanded(
              child: _buildBrowseCard(
                context: context,
                title: 'My Posts',
                subtitle: postsSubtitle,
                icon: AppIcons.messageSvg,
                iconBgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF16A34A),
                route: AppRoutes.myCommunityPosts,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Browse Card Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildBrowseCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String icon,
    required Color iconBgColor,
    required Color iconColor,
    required String route,
  }) {
    final double iconBoxSize = (context.scale(42.0)).clamp(36.0, 48.0);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: EdgeInsets.all(context.cardPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackOpacity4,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: (iconBoxSize * 0.52).clamp(20.0, 26.0),
                  height: (iconBoxSize * 0.52).clamp(20.0, 26.0),
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: context.sp(15),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: context.sp(11.5),
                color: AppColors.slate400,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
