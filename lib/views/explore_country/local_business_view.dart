import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/models/business_listing_model.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/services/permissions/app_toast.dart';
import 'package:desilynks/viewmodels/business_listing_viewmodel.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/core/utils/app_share_helper.dart';

/// Screen displaying Local Businesses with full provider-based reactivity.
class LocalBusinessView extends StatefulWidget {
  const LocalBusinessView({super.key});

  @override
  State<LocalBusinessView> createState() => _LocalBusinessViewState();
}

class _LocalBusinessViewState extends State<LocalBusinessView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bizVM = context.read<BusinessListingViewModel>();
      if (!bizVM.hasFetchedAll && !bizVM.isLoading) {
        bizVM.fetchAllListings();
      }
      if (!bizVM.hasFetched && !bizVM.isLoading) {
        bizVM.fetchMyListings();
      }
      final catVM = context.read<CategoriesViewModel>();
      if (!catVM.hasFetched && !catVM.isLoading) {
        catVM.fetchAll();
      }
    });
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
        AppToast.showError('Could not open phone dialer');
      }
    } catch (e) {
      AppToast.showError('Could not launch phone dialer: $e');
    }
  }


  Future<void> _openWebsite(String url) async {
    var formatted = url.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'https://$formatted';
    }
    final uri = Uri.parse(formatted);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppToast.showError('Could not open website');
      }
    } catch (e) {
      AppToast.showError('Could not open website: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmall;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: _buildAppBar(context, isSmall),
      body: Consumer2<BusinessListingViewModel, CategoriesViewModel>(
        builder: (context, bizVM, catVM, _) {
          final listings = bizVM.displayedListings;
          final isLoading = bizVM.isLoading;
          final errorMessage = bizVM.errorMessage;

          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: () async {
              await bizVM.refreshAll();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.hMargin,
                      isSmall ? 12.0 : 16.0,
                      context.hMargin,
                      isSmall ? 8.0 : 10.0,
                    ),
                    child: _buildSearchBar(context, bizVM, isSmall),
                  ),
                ),

                // 2. Category Filter Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 12.0),
                    child: _buildCategoryChips(context, bizVM, catVM, isSmall),
                  ),
                ),

                // 4. Content states
                if (isLoading && listings.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: context.hMargin),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildSkeletonCard(context, isSmall),
                        childCount: 4,
                      ),
                    ),
                  )
                else if (errorMessage != null && listings.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(
                      context,
                      bizVM,
                      errorMessage,
                      isSmall,
                    ),
                  )
                else if (listings.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, bizVM, isSmall),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.hMargin,
                      vertical: 4.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index < listings.length) {
                          final biz = listings[index];
                          final isOwner = bizVM.myListings.any(
                            (l) => l.id == biz.id,
                          );
                          return _buildBusinessCard(
                            context,
                            biz,
                            isOwner,
                            isSmall,
                          );
                        }
                        return null;
                      }, childCount: listings.length),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 36.0)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Top App Bar
  // ──────────────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isSmall) {
    return AppBar(
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
      title: Row(
        children: [
          Text(
            'Local Businesses',
            style: TextStyle(
              color: AppColors.slate900,
              fontSize: context.sp(isSmall ? 16.5 : 18.0),
              fontWeight: FontWeight.bold,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(20.0),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.postBusiness);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 10.0 : 12.0,
                  vertical: isSmall ? 5.0 : 6.5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppIcons.plusSvg,
                      width: isSmall ? 11.0 : 13.0,
                      height: isSmall ? 11.0 : 13.0,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.sp(isSmall ? 12.0 : 13.0),
                        fontWeight: FontWeight.w600,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Search Bar
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar(
    BuildContext context,
    BusinessListingViewModel vm,
    bool isSmall,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomTextField(
        controller: vm.searchController,
        hintText: 'Search business name, address, category...',
        fillColor: AppColors.backgroundOffWhite,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        onChanged: (val) => vm.setSearchQuery(val),
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
                  AppIcons.crossSmallSvg,
                  width: isSmall ? 14.0 : 16.0,
                  height: isSmall ? 14.0 : 16.0,
                  colorFilter: const ColorFilter.mode(
                    AppColors.slate500,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => vm.clearSearch(),
              )
            : null,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Category Chips Filter
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCategoryChips(
    BuildContext context,
    BusinessListingViewModel bizVM,
    CategoriesViewModel catVM,
    bool isSmall,
  ) {
    final categories = catVM.businessCategories;
    final selectedFilter = bizVM.selectedCategoryFilter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: context.hMargin),
      child: Row(
        children: [
          _buildChip(
            context: context,
            label: 'All',
            isSelected:
                selectedFilter == null ||
                selectedFilter.isEmpty ||
                selectedFilter == 'All',
            onTap: () => bizVM.setSelectedCategoryFilter('All'),
            isSmall: isSmall,
          ),
          ...categories.map((cat) {
            final isSelected =
                selectedFilter == cat.title || selectedFilter == cat.id;
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _buildChip(
                context: context,
                label: cat.title,
                isSelected: isSelected,
                onTap: () {
                  if (isSelected) {
                    bizVM.setSelectedCategoryFilter('All');
                  } else {
                    bizVM.setSelectedCategoryFilter(cat.title);
                  }
                },
                isSmall: isSmall,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isSmall,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12.0 : 14.0,
          vertical: isSmall ? 6.0 : 7.5,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.slate200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.22),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.slate700,
            fontSize: context.sp(isSmall ? 12.0 : 13.0),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Business Card
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildBusinessCard(
    BuildContext context,
    BusinessListingModel biz,
    bool isOwner,
    bool isSmall,
  ) {
    final coverUrl = biz.coverPhoto?.url;
    final hours = biz.businessHours;

    return Container(
      margin: EdgeInsets.only(bottom: isSmall ? 14.0 : 16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          onTap: () => _showBusinessDetailModal(context, biz, isOwner, isSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cover Photo Banner
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadius16),
                ),
                child: SizedBox(
                  height: isSmall ? 135.0 : 155.0,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCoverImage(coverUrl),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.2),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),

                      // Category badge (Top-Left)
                      Positioned(
                        top: 10.0,
                        left: 10.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppIcons.shopSvg,
                                width: 12.0,
                                height: 12.0,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                biz.category,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.sp(isSmall ? 11.0 : 12.0),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Active / My Business tag (Top-Right)
                      Positioned(
                        top: 10.0,
                        right: 10.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOwner)
                              Container(
                                margin: const EdgeInsets.only(right: 6.0),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  'Your Business',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.sp(isSmall ? 10.5 : 11.5),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ),
                            _buildOpenClosedBadge(hours, isSmall, context),
                          ],
                        ),
                      ),

                      // Business Name over bottom of image
                      Positioned(
                        bottom: 10.0,
                        left: 12.0,
                        right: 12.0,
                        child: Text(
                          biz.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(isSmall ? 16.5 : 18.0),
                            fontWeight: FontWeight.bold,
                            fontFamily: AppStrings.fontInter,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 4.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Card Body Info
              Padding(
                padding: EdgeInsets.all(isSmall ? 12.0 : 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Row
                    if (biz.address.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.locationSvg,
                            width: 15.0,
                            height: 15.0,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate500,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Expanded(
                            child: Text(
                              biz.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.slate700,
                                fontSize: context.sp(isSmall ? 12.5 : 13.5),
                                fontWeight: FontWeight.w500,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                    ],

                    // Hours summary
                    if (hours != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 15.0,
                            color: AppColors.slate500,
                          ),
                          const SizedBox(width: 6.0),
                          Expanded(
                            child: Text(
                              'Mon-Fri: ${hours.monToFriStartTime} - ${hours.monToFriEndTime} | Sat: ${hours.saturdayStartTime} - ${hours.saturdayEndTime}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.slate600,
                                fontSize: context.sp(isSmall ? 11.5 : 12.5),
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                    ],

                    // Description snippet
                    if (biz.description.isNotEmpty) ...[
                      Text(
                        biz.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.slate600,
                          fontSize: context.sp(isSmall ? 12.0 : 13.0),
                          height: 1.35,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                    ],

                    // Action Buttons Row (Call, WhatsApp, Details)
                    Row(
                      children: [
                        // Call button
                        Expanded(
                          child: _buildActionBtn(
                            context: context,
                            label: 'Call',
                            iconSvg: AppIcons.callSvg,
                            color: AppColors.primaryBlue,
                            bgColor: AppColors.lightBlue,
                            onTap: () => _makeCall(biz.phone),
                            isSmall: isSmall,
                          ),
                        ),
                        const SizedBox(width: 8.0),

                        // Share button
                        Expanded(
                          child: _buildActionBtn(
                            context: context,
                            label: 'Share',
                            iconSvg: AppIcons.shareSvg,
                            color: const Color(0xFF6366F1),
                            bgColor: const Color(0xFFEEF2FF),
                            onTap: () => AppShareHelper.shareAsLink(
                              context: context,
                              type: ShareItemType.business,
                              id: biz.id,
                              title: biz.title,
                              description: biz.description,
                            ),
                            isSmall: isSmall,
                          ),
                        ),
                        const SizedBox(width: 8.0),

                        // Details / View button
                        InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () => _showBusinessDetailModal(
                            context,
                            biz,
                            isOwner,
                            isSmall,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 9.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Details',
                                  style: TextStyle(
                                    color: AppColors.slate700,
                                    fontSize: context.sp(isSmall ? 11.5 : 12.5),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                SvgPicture.asset(
                                  AppIcons.rightarrow,
                                  width: 10.0,
                                  height: 10.0,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.slate600,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // If owner, show edit & delete buttons
                        if (isOwner) ...[
                          const SizedBox(width: 6.0),
                          InkWell(
                            borderRadius: BorderRadius.circular(10.0),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.editAd,
                                arguments: biz,
                              ).then((_) {
                                if (context.mounted) {
                                  context
                                      .read<BusinessListingViewModel>()
                                      .refreshAll();
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(9.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: SvgPicture.asset(
                                AppIcons.editSvg,
                                width: 15.0,
                                height: 15.0,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF10B981),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          InkWell(
                            borderRadius: BorderRadius.circular(10.0),
                            onTap: () => _confirmDeleteBusiness(context, biz),
                            child: Container(
                              padding: const EdgeInsets.all(9.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: SvgPicture.asset(
                                AppIcons.deleteSvg,
                                width: 15.0,
                                height: 15.0,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primaryRed,
                                  BlendMode.srcIn,
                                ),
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
      ),
    );
  }

  Widget _buildActionBtn({
    required BuildContext context,
    required String label,
    required String iconSvg,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    required bool isSmall,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isSmall ? 7.5 : 8.5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconSvg,
                width: 14.0,
                height: 14.0,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: context.sp(isSmall ? 11.5 : 12.5),
                  fontWeight: FontWeight.bold,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpenClosedBadge(
    BusinessHoursModel? hours,
    bool isSmall,
    BuildContext context,
  ) {
    bool isOpen = true;
    if (hours != null) {
      final now = DateTime.now();
      if (now.weekday == DateTime.sunday && hours.isClosedOnSunday) {
        isOpen = false;
      }
    }

    final color = isOpen ? const Color(0xFF16A34A) : AppColors.slate500;
    final bgColor = isOpen
        ? const Color(0xFFDCFCE7).withValues(alpha: 0.95)
        : Colors.black.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 4.5),
          Text(
            isOpen ? 'Open Now' : 'Closed',
            style: TextStyle(
              color: isOpen ? color : Colors.white,
              fontSize: context.sp(isSmall ? 10.5 : 11.5),
              fontWeight: FontWeight.bold,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(String? coverUrl) {
    if (coverUrl != null && coverUrl.isNotEmpty) {
      if (coverUrl.startsWith('http://') || coverUrl.startsWith('https://')) {
        return Image.network(
          coverUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        );
      } else if (coverUrl.startsWith('/uploads/')) {
        return Image.network(
          '${ApiEndpoints.baseUrl}$coverUrl',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        );
      } else if (File(coverUrl).existsSync()) {
        return Image.file(
          File(coverUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        );
      }
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.slate200,
      child: Center(
        child: SvgPicture.asset(
          AppIcons.shopSvg,
          width: 36.0,
          height: 36.0,
          colorFilter: const ColorFilter.mode(
            AppColors.slate400,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Bottom Sheet Detailed Modal
  // ──────────────────────────────────────────────────────────────────────────
  void _showBusinessDetailModal(
    BuildContext context,
    BusinessListingModel biz,
    bool isOwner,
    bool isSmall,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: EdgeInsets.fromLTRB(
            context.hMargin,
            16.0,
            context.hMargin,
            MediaQuery.of(ctx).padding.bottom + 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44.0,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: AppColors.slate300,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
                const SizedBox(height: 18.0),

                // Header with Category and Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              biz.category,
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: context.sp(11.5),
                                fontWeight: FontWeight.bold,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            biz.name,
                            style: TextStyle(
                              color: AppColors.slate900,
                              fontSize: context.sp(isSmall ? 18.0 : 20.0),
                              fontWeight: FontWeight.bold,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),
                const Divider(),
                const SizedBox(height: 12.0),

                // Galleries Carousel if any
                if (biz.businessGalleries.isNotEmpty) ...[
                  Text(
                    'Gallery Photos',
                    style: TextStyle(
                      color: AppColors.slate900,
                      fontSize: context.sp(14.5),
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 95.0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: biz.businessGalleries.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8.0),
                      itemBuilder: (context, index) {
                        final photoUrl = biz.businessGalleries[index].url;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SizedBox(
                            width: 120.0,
                            child: _buildCoverImage(photoUrl),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],

                // Description
                if (biz.description.isNotEmpty) ...[
                  Text(
                    'About Business',
                    style: TextStyle(
                      color: AppColors.slate900,
                      fontSize: context.sp(14.5),
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    biz.description,
                    style: TextStyle(
                      color: AppColors.slate700,
                      fontSize: context.sp(13.0),
                      height: 1.45,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],

                // Operating Hours Section
                if (biz.businessHours != null) ...[
                  Text(
                    'Operating Hours',
                    style: TextStyle(
                      color: AppColors.slate900,
                      fontSize: context.sp(14.5),
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundOffWhite,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      children: [
                        _buildHoursRow(
                          'Monday - Friday',
                          '${biz.businessHours!.monToFriStartTime} - ${biz.businessHours!.monToFriEndTime}',
                          context,
                        ),
                        const Divider(height: 14.0),
                        _buildHoursRow(
                          'Saturday',
                          '${biz.businessHours!.saturdayStartTime} - ${biz.businessHours!.saturdayEndTime}',
                          context,
                        ),
                        const Divider(height: 14.0),
                        _buildHoursRow(
                          'Sunday',
                          biz.businessHours!.isClosedOnSunday
                              ? 'Closed'
                              : '${biz.businessHours!.sundayStartTime ?? '10:00'} - ${biz.businessHours!.sundayEndTime ?? '18:00'}',
                          context,
                          isSundayClosed: biz.businessHours!.isClosedOnSunday,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],

                // Location info
                if (biz.address.isNotEmpty) ...[
                  Text(
                    'Address',
                    style: TextStyle(
                      color: AppColors.slate900,
                      fontSize: context.sp(14.5),
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.locationSvg,
                        width: 16.0,
                        height: 16.0,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryBlue,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          biz.address,
                          style: TextStyle(
                            color: AppColors.slate700,
                            fontSize: context.sp(13.0),
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                ],

                // Action Call & WhatsApp Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _makeCall(biz.phone);
                        },
                        icon: SvgPicture.asset(
                          AppIcons.callSvg,
                          width: 16.0,
                          height: 16.0,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: Text(
                          'Call ${biz.phone}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          AppShareHelper.shareAsLink(
                            context: context,
                            type: ShareItemType.business,
                            id: biz.id,
                            title: biz.title,
                            description: biz.description,
                          );
                        },
                        icon: SvgPicture.asset(
                          AppIcons.shareSvg,
                          width: 16.0,
                          height: 16.0,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: const Text('Share Link'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (biz.website != null && biz.website!.isNotEmpty) ...[
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openWebsite(biz.website!);
                      },
                      icon: SvgPicture.asset(
                        AppIcons.globeSvg,
                        width: 16.0,
                        height: 16.0,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate700,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: Text('Visit Website (${biz.website})'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.slate800,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ],
                if (isOwner) ...[
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editAd,
                          arguments: biz,
                        ).then((_) {
                          if (context.mounted) {
                            context
                                .read<BusinessListingViewModel>()
                                .refreshAll();
                          }
                        });
                      },
                      icon: SvgPicture.asset(
                        AppIcons.editSvg,
                        width: 16.0,
                        height: 16.0,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text('Edit Business Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHoursRow(
    String day,
    String time,
    BuildContext context, {
    bool isSundayClosed = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: TextStyle(
            color: AppColors.slate700,
            fontSize: context.sp(12.5),
            fontWeight: FontWeight.w500,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: isSundayClosed ? AppColors.primaryRed : AppColors.slate900,
            fontSize: context.sp(12.5),
            fontWeight: isSundayClosed ? FontWeight.bold : FontWeight.w600,
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Delete Business Confirmation
  // ──────────────────────────────────────────────────────────────────────────
  void _confirmDeleteBusiness(BuildContext context, BusinessListingModel biz) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Delete Business Listing?'),
          content: Text(
            'Are you sure you want to delete "${biz.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final vm = context.read<BusinessListingViewModel>();
                final deleted = await vm.deleteListing(biz.id);
                if (deleted) {
                  AppToast.showSuccess('Business listing deleted successfully');
                } else if (vm.errorMessage != null) {
                  AppToast.showError(vm.errorMessage!);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Skeleton, Error & Empty States
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSkeletonCard(BuildContext context, bool isSmall) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmall ? 12.0 : 14.0),
      height: isSmall ? 220.0 : 240.0,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadius16),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150.0,
                    height: 14.0,
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(4.0),
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

  Widget _buildEmptyState(
    BuildContext context,
    BusinessListingViewModel vm,
    bool isSmall,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.hMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22.0),
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.shopSvg,
                width: 44.0,
                height: 44.0,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryBlue,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 18.0),
            Text(
              'No Local Businesses Found',
              style: TextStyle(
                color: AppColors.slate900,
                fontSize: context.sp(isSmall ? 16.5 : 18.0),
                fontWeight: FontWeight.bold,
                fontFamily: AppStrings.fontInter,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Try searching with another keyword or explore other categories.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.slate600,
                fontSize: context.sp(isSmall ? 12.5 : 13.5),
                fontFamily: AppStrings.fontInter,
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.postBusiness);
              },
              icon: SvgPicture.asset(
                AppIcons.plusSvg,
                width: 14.0,
                height: 14.0,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text('List Your Business'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            if (vm.searchQuery.isNotEmpty ||
                (vm.selectedCategoryFilter != null &&
                    vm.selectedCategoryFilter != 'All')) ...[
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () => vm.clearFilters(),
                child: const Text('Reset Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    BusinessListingViewModel vm,
    String errorMessage,
    bool isSmall,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.hMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppIcons.errorSvg,
              width: 44.0,
              height: 44.0,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryRed,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              'Failed to load businesses',
              style: TextStyle(
                color: AppColors.slate900,
                fontSize: context.sp(isSmall ? 16.0 : 17.5),
                fontWeight: FontWeight.bold,
                fontFamily: AppStrings.fontInter,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.slate600,
                fontSize: context.sp(isSmall ? 12.0 : 13.0),
                fontFamily: AppStrings.fontInter,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () => vm.refreshAll(),
              icon: SvgPicture.asset(
                AppIcons.restartSvg,
                width: 14.0,
                height: 14.0,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
