import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/models/worker_profile_model.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/worker_viewmodel.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';

class HireWorkersView extends StatelessWidget {
  const HireWorkersView({super.key});

  void _navigateToFilters(BuildContext context) async {
    final roomViewModel = Provider.of<PostRoomViewModel>(
      context,
      listen: false,
    );
    final workerVM = Provider.of<WorkerViewModel>(
      context,
      listen: false,
    );
    roomViewModel.enterFiltersScreen(
      initialCategory: 'Workers',
      initialWorkerService: workerVM.selectedWorkerCategory,
    );
    final result = await Navigator.pushNamed(context, AppRoutes.filters);
    if (!context.mounted) return;

    if (result == true || roomViewModel.isFilterApplied) {
      if (roomViewModel.appliedWorkerService.isNotEmpty &&
          roomViewModel.appliedWorkerService != 'All') {
        workerVM.setSelectedWorkerCategory(roomViewModel.appliedWorkerService);
      } else if (roomViewModel.appliedWorkerService == 'All' &&
          roomViewModel.isFilterApplied) {
        workerVM.setSelectedWorkerCategory('All');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerVM = Provider.of<WorkerViewModel>(context);
    final roomViewModel = Provider.of<PostRoomViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);

    if (!workerVM.hireWorkersInitialized && !workerVM.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        workerVM.initHireWorkersView();
        context.read<CategoriesViewModel>().fetchAll();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: (workerVM.isLoading && workerVM.publicProfiles.isEmpty)
                ? const WorkersSkeleton()
                : Column(
                    children: [
                      // 1. Top Header Bar
                      _buildHeader(context, authVM, roomViewModel),

                      // 2. Search Bar
                      _buildSearchBar(context, workerVM),

                      // 3. Category Filter Chips
                      _buildCategoryChips(context, workerVM),

                      // 3.5 Active Filters Indicator Bar
                      _buildActiveFiltersBar(context, roomViewModel),

                      // 4. Workers List
                      Expanded(
                        child: workerVM.isLoading
                            ? const WorkersSkeleton()
                            : _buildWorkersList(
                                context,
                                workerVM,
                                roomViewModel,
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Header Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    AuthViewModel authVM,
    PostRoomViewModel roomViewModel,
  ) {
    final workerVM = Provider.of<WorkerViewModel>(context, listen: false);
    final userLocation = workerVM.getUserLocation(authVM.currentUser);
    final hasActiveFilters = roomViewModel.hasActiveWorkerFilters;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.hMargin,
        vertical: context.scaleH(12).clamp(8.0, 16.0),
      ),
      child: Row(
        children: [
          // Back Arrow Button
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Provider.of<NavigationViewModel>(
                  context,
                  listen: false,
                ).setIndex(0);
              }
            },
            child: Container(
              padding: EdgeInsets.all(context.scale(8).clamp(6.0, 10.0)),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.arrowBackSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate800,
                  BlendMode.srcIn,
                ),
                height: context.scale(16).clamp(14.0, 20.0),
                width: context.scale(16).clamp(14.0, 20.0),
              ),
            ),
          ),
          SizedBox(width: context.scale(8).clamp(6.0, 12.0)),

          // Title & Specific User Location Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hire Workers & Services',
                  style: TextStyle(
                    fontSize: context.sp(18).clamp(16.0, 20.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                    fontFamily: AppStrings.fontInter,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.scaleH(2).clamp(1.0, 4.0)),
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.locationSvg,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate400,
                        BlendMode.srcIn,
                      ),
                      height: context.scale(14).clamp(12.0, 16.0),
                      width: context.scale(14).clamp(12.0, 16.0),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        userLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.sp(12).clamp(11.0, 13.0),
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate500,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Button
          InkWell(
            onTap: () => _navigateToFilters(context),
            child: Container(
              padding: EdgeInsets.all(context.scale(10).clamp(8.0, 12.0)),
              decoration: BoxDecoration(
                color: hasActiveFilters
                    ? AppColors.vibrantBlue.withValues(alpha: 0.12)
                    : AppColors.slate100,
                shape: BoxShape.circle,
                border: hasActiveFilters
                    ? Border.all(color: AppColors.vibrantBlue, width: 1.5)
                    : null,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    AppIcons.filterSvg,
                    colorFilter: ColorFilter.mode(
                      hasActiveFilters
                          ? AppColors.vibrantBlue
                          : AppColors.slate700,
                      BlendMode.srcIn,
                    ),
                    height: context.scale(16).clamp(14.0, 18.0),
                    width: context.scale(16).clamp(14.0, 18.0),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.vibrantBlue,
                          shape: BoxShape.circle,
                        ),
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
  // Active Filters Indicator Bar
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildActiveFiltersBar(
    BuildContext context,
    PostRoomViewModel roomViewModel,
  ) {
    if (!roomViewModel.hasActiveWorkerFilters) return const SizedBox.shrink();

    final List<String> badges = [];
    if (roomViewModel.appliedWorkerService != 'All') {
      badges.add(roomViewModel.appliedWorkerService);
    }
    if (roomViewModel.appliedMaxWorkerRate < 150.0) {
      badges.add('≤ €${roomViewModel.appliedMaxWorkerRate.round()}/hr');
    }
    if (roomViewModel.appliedAvailableTodayOnly) {
      badges.add('Available Today');
    }
    if (roomViewModel.appliedHasVehicleOnly) {
      badges.add('Has Vehicle');
    }
    if (roomViewModel.appliedHasToolsOnly) {
      badges.add('Has Tools');
    }
    if (roomViewModel.appliedMinExperience > 0) {
      badges.add('${roomViewModel.appliedMinExperience}+ yrs exp');
    }
    if (roomViewModel.appliedSortBy != 'Newest First') {
      badges.add(roomViewModel.appliedSortBy);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.hMargin,
        vertical: context.scaleH(4).clamp(2.0, 6.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: badges.map((badge) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(10).clamp(8.0, 12.0),
                      vertical: context.scaleH(4).clamp(3.0, 6.0),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vibrantBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.vibrantBlue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: context.sp(11).clamp(10.0, 12.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.vibrantBlue,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<WorkerViewModel>().resetWorkerFilters(roomViewModel);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Clear all',
                style: TextStyle(
                  fontSize: context.sp(12).clamp(11.0, 13.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryRed,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Search Bar Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, WorkerViewModel workerVM) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.hMargin,
        vertical: context.scaleH(6).clamp(4.0, 8.0),
      ),
      child: CustomTextField(
        controller: workerVM.workerSearchController,
        prefixIcon: Padding(
          padding: EdgeInsets.all(context.scale(12).clamp(10.0, 14.0)),
          child: SvgPicture.asset(
            AppIcons.searchSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate400,
              BlendMode.srcIn,
            ),
            width: context.scale(18).clamp(16.0, 20.0),
            height: context.scale(18).clamp(16.0, 20.0),
          ),
        ),
        hintText: 'Search workers or services...',
        fillColor: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Category Chips Horizontal Scroll
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCategoryChips(BuildContext context, WorkerViewModel workerVM) {
    return Consumer<CategoriesViewModel>(
      builder: (context, catVM, _) {
        // Prepend 'All' to the live API worker types
        final categories = [
          'All',
          ...catVM.needWorkerTypes.map((t) => t.title),
        ];
        return Container(
          height: context.scaleH(46).clamp(40.0, 50.0),
          margin: EdgeInsets.only(
            top: context.scaleH(8).clamp(4.0, 10.0),
            bottom: context.scaleH(8).clamp(4.0, 10.0),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected =
                  category.toLowerCase() ==
                  workerVM.selectedWorkerCategory.toLowerCase();

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      workerVM.setSelectedWorkerCategory(category);
                    }
                  },
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.white,
                  labelStyle: TextStyle(
                    fontSize: context.sp(AppConstants.fontSizeMD).clamp(12.0, 14.0),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.slate700,
                    fontFamily: AppStrings.fontInter,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius20,
                    ),
                    side: BorderSide(
                      color:
                          isSelected ? AppColors.slate900 : AppColors.slate200,
                      width: AppConstants.borderWidth,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(12).clamp(10.0, 14.0),
                    vertical: context.scaleH(6).clamp(4.0, 8.0),
                  ),
                  elevation: 0,
                  pressElevation: 0,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Workers List Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWorkersList(
    BuildContext context,
    WorkerViewModel workerVM,
    PostRoomViewModel roomViewModel,
  ) {
    final filtered = workerVM.getFilteredWorkers(roomViewModel);

    if (filtered.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.scale(32).clamp(24.0, 40.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.searchSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate300,
                  BlendMode.srcIn,
                ),
                width: context.scale(48).clamp(40.0, 56.0),
                height: context.scale(48).clamp(40.0, 56.0),
              ),
              SizedBox(height: context.scaleH(12).clamp(8.0, 16.0)),
              Text(
                'No workers found matching your filters',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.sp(AppConstants.fontSizeXL).clamp(15.0, 18.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate600,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              Text(
                'Try adjusting your search query, hourly rate, or category filter.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.sp(13).clamp(12.0, 14.0),
                  color: AppColors.slate400,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              if (roomViewModel.hasActiveWorkerFilters ||
                  workerVM.selectedWorkerCategory != 'All' ||
                  workerVM.workerSearchQuery.isNotEmpty) ...[
                SizedBox(height: context.scaleH(16).clamp(12.0, 20.0)),
                OutlinedButton(
                  onPressed: () {
                    workerVM.resetWorkerFilters(roomViewModel);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.vibrantBlue,
                    side: const BorderSide(color: AppColors.vibrantBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(20).clamp(16.0, 24.0),
                      vertical: context.scaleH(10).clamp(8.0, 12.0),
                    ),
                  ),
                  child: Text(
                    'Reset All Filters',
                    style: TextStyle(
                      fontSize: context.sp(14).clamp(13.0, 15.0),
                      fontWeight: FontWeight.w600,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: context.hMargin,
        vertical: context.scaleH(8).clamp(6.0, 10.0),
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildWorkerCard(context, filtered[index]);
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Single Worker Card Widget
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWorkerCard(BuildContext context, WorkerProfileModel worker) {
    final String avatarUrl = worker.profilePhotoUrl ?? '';
    final String name = worker.name.isNotEmpty
        ? worker.name
        : worker.profession;
    final String profession = worker.profession;
    const double rating = 4.8;
    const int reviewsCount = 12;
    final String hourlyRate = worker.hourlyRate;
    final String distance = worker.areaCovered.isNotEmpty
        ? worker.areaCovered
        : 'Nearby';
    final List<String> tags = worker.languages;
    final bool isOnline = worker.isAvailableToday;
    final double avatarSize = context.scale(56).clamp(48.0, 60.0);

    return Container(
      margin: EdgeInsets.only(bottom: context.scaleH(14).clamp(10.0, 16.0)),
      padding: EdgeInsets.all(context.cardPad),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate500.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.slate100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Circle with Green Online Dot
              Stack(
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.slate200,
                      image: avatarUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: avatarUrl.isEmpty
                        ? Center(
                            child: SvgPicture.asset(
                              AppIcons.personSvg,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate400,
                                BlendMode.srcIn,
                              ),
                              width: context.scale(28).clamp(24.0, 32.0),
                              height: context.scale(28).clamp(24.0, 32.0),
                            ),
                          )
                        : null,
                  ),
                  if (isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: context.scale(13).clamp(11.0, 14.0),
                        height: context.scale(13).clamp(11.0, 14.0),
                        decoration: BoxDecoration(
                          color: AppColors.green500, // Vibrant Green Online dot
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: context.scale(14).clamp(10.0, 16.0)),

              // Name, Profession, Rating Row
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: context.sp(AppConstants.fontSizeLG).clamp(15.0, 18.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.scaleH(2).clamp(1.0, 3.0)),
                    Text(
                      profession,
                      style: TextStyle(
                        fontSize: context.sp(AppConstants.fontSizeSM).clamp(12.0, 14.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate500,
                        fontFamily: AppStrings.fontInter,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.scaleH(6).clamp(4.0, 8.0)),

                    // Rating & Price & Distance Row - wrapped to be 100% overflow-safe on small screens
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppIcons.starFavoriteSvg,
                              colorFilter: const ColorFilter.mode(
                                AppColors.amber500,
                                BlendMode.srcIn,
                              ),
                              width: context.scale(14).clamp(12.0, 15.0),
                              height: context.scale(14).clamp(12.0, 15.0),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$rating',
                              style: TextStyle(
                                fontSize: context.sp(AppConstants.fontSizeXS).clamp(11.0, 13.0),
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                            Text(
                              ' ($reviewsCount)',
                              style: TextStyle(
                                fontSize: context.sp(AppConstants.fontSizeXS).clamp(11.0, 13.0),
                                color: AppColors.slate400,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: AppColors.slate300,
                            fontSize: context.sp(11).clamp(10.0, 12.0),
                          ),
                        ),
                        Text(
                          '€$hourlyRate/hr',
                          style: TextStyle(
                            fontSize: context.sp(AppConstants.fontSizeXS).clamp(11.0, 13.0),
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue600,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: AppColors.slate300,
                            fontSize: context.sp(11).clamp(10.0, 12.0),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppIcons.locationSvg,
                              colorFilter: const ColorFilter.mode(
                                AppColors.slate400,
                                BlendMode.srcIn,
                              ),
                              width: context.scale(13).clamp(11.0, 14.0),
                              height: context.scale(13).clamp(11.0, 14.0),
                            ),
                            const SizedBox(width: 2),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: context.scale(110).clamp(70.0, 160.0),
                              ),
                              child: Text(
                                distance,
                                style: TextStyle(
                                  fontSize: context.sp(AppConstants.fontSizeXS11).clamp(10.0, 12.0),
                                  color: AppColors.slate400,
                                  fontFamily: AppStrings.fontInter,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
          SizedBox(height: context.scaleH(12).clamp(8.0, 14.0)),

          // Skill Tags Wrap
          if (tags.isNotEmpty)
            Wrap(
              spacing: context.scale(6).clamp(4.0, 8.0),
              runSpacing: context.scale(6).clamp(4.0, 8.0),
              children: tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(AppConstants.paddingSmall).clamp(6.0, 10.0),
                    vertical: context.scaleH(AppConstants.padding2).clamp(2.0, 4.0),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: context.sp(AppConstants.fontSizeXS11).clamp(10.0, 12.0),
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate600,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: context.scaleH(14).clamp(10.0, 16.0)),

          // Vibrant Purple "Hire Now" Button
          SizedBox(
            width: double.infinity,
            height: context.scaleH(AppConstants.buttonHeight).clamp(44.0, 52.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.indigo, // Bright Indigo/Purple
                    AppColors.indigo700, // Deep Indigo/Purple
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.indigo.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.hireWorkerForm,
                    arguments: {
                      'id': worker.id,
                      'name': name,
                      'profession': profession,
                      'hourlyRate': hourlyRate,
                      'avatar': avatarUrl,
                      'location': distance,
                      'workerTypeId': worker.workerTypeId,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Hire Now',
                  style: TextStyle(
                    fontSize: context.sp(15).clamp(14.0, 16.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
