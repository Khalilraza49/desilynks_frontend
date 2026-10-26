import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/skeleton/skeleton_shimmer.dart';
import 'package:desilynks/viewmodels/promotions/deals_discounts_viewmodel.dart';

class DealsDiscountsView extends StatelessWidget {
  const DealsDiscountsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DealsDiscountsViewModel>();
    final filteredDeals = viewModel.filteredDeals;
    final isTablet = context.isTablet || context.screenWidth >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate900,
              BlendMode.srcIn,
            ),
            width: context.scale(22),
            height: context.scale(22),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Deals & Discounts',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Deal History',
            icon: SvgPicture.asset(
              AppIcons.history,
              colorFilter: const ColorFilter.mode(
                AppColors.slate700,
                BlendMode.srcIn,
              ),
              width: context.scale(20),
              height: context.scale(20),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No previous deal history found.'),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF2563EB),
          backgroundColor: Colors.white,
          onRefresh: () => viewModel.refresh(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: context.hMargin,
                  vertical: context.scaleH(14.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Search Bar & Filter Button Connected to Search API
                    _buildSearchBarRow(context, viewModel),

                    // Subtle searching linear progress indicator
                    if (viewModel.isSearching) ...[
                      SizedBox(height: context.scaleH(4)),
                      const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        child: LinearProgressIndicator(
                          minHeight: 2.5,
                          backgroundColor: Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: context.scaleH(16)),

                    // 2. Exclusive Deals Hero Banner Card (Responsive)
                    _buildHeroCard(context),

                    SizedBox(height: context.scaleH(20)),

                    // 3. Category Filter Chips with SVGs
                    _buildCategoryChips(context, viewModel),

                    SizedBox(height: context.scaleH(22)),

                    // 4. "Top Deals" Section Header with SVG
                    _buildSectionHeader(
                      context,
                      title: 'Top Deals',
                      iconSvg: AppIcons.salesSvg,
                      iconColor: const Color(0xFFEF4444),
                      onSeeAll: () {},
                    ),

                    SizedBox(height: context.scaleH(12)),

                    // 5. Deals List / Skeleton / Empty State (Responsive)
                    if (viewModel.isLoading)
                      _buildSkeletonLoading(context, isTablet)
                    else if (filteredDeals.isEmpty)
                      _buildEmptyState(context, viewModel)
                    else
                      _buildDealsLayout(context, filteredDeals, isTablet),

                    SizedBox(height: context.scaleH(16)),

                    // 6. "Popular Deals" Section Header with SVG
                    _buildSectionHeader(
                      context,
                      title: 'Popular Deals',
                      iconSvg: AppIcons.starFavoriteSvg,
                      iconColor: const Color(0xFFF59E0B),
                      onSeeAll: () {},
                    ),

                    SizedBox(height: context.scaleH(12)),

                    // 7. Popular Deal Item Card (Responsive)
                    _buildPopularDealCard(context),

                    SizedBox(height: context.scaleH(24)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 1. Search Bar Connected to Backend Search API
  Widget _buildSearchBarRow(
    BuildContext context,
    DealsDiscountsViewModel viewModel,
  ) {
    return Row(
      children: [
        // Search Input connected to live API with debounce & keyboard submit
        Expanded(
          child: CustomTextField(
            controller: viewModel.searchController,
            hintText: 'Search stores, deals, discounts...',
            fontSize: context.sp(14),
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (value) => viewModel.submitSearch(value),
            prefixIcon: Center(
              child: SvgPicture.asset(
                AppIcons.searchSvg,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF94A3B8),
                  BlendMode.srcIn,
                ),
                width: context.scale(18),
                height: context.scale(18),
              ),
            ),
            suffixIcon: viewModel.isSearching
                ? Center(
                    child: SizedBox(
                      width: context.scale(18),
                      height: context.scale(18),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  )
                : viewModel.searchQuery.isNotEmpty
                    ? IconButton(
                        splashRadius: 18,
                        icon: SvgPicture.asset(
                          AppIcons.crossSmallSvg,
                          width: context.scale(16),
                          height: context.scale(16),
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate400,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: viewModel.clearSearch,
                      )
                    : null,
            borderRadius: BorderRadius.circular(14),
            fillColor: Colors.white,
          ),
        ),

        SizedBox(width: context.scale(10)),

        // Filter Button Box
        Container(
          width: context.scale(48),
          height: context.scale(48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _showFilterBottomSheet(context, viewModel),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.filterSvg,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF475569),
                    BlendMode.srcIn,
                  ),
                  height: context.scale(20),
                  width: context.scale(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 2. Exclusive Deals Hero Banner Card (Fully Responsive)
  Widget _buildHeroCard(BuildContext context) {
    final isSmall = context.isSmall;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scale(isSmall ? 16 : 20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Exclusive deals for',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(isSmall ? 16 : 18),
                    fontWeight: FontWeight.bold,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                SizedBox(height: context.scaleH(3)),
                Text(
                  'Premium & Golden Members',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: context.sp(isSmall ? 12 : 13),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                SizedBox(height: context.scaleH(isSmall ? 12 : 16)),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.membershipPlans);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(isSmall ? 14 : 18),
                      vertical: context.scaleH(isSmall ? 7 : 9),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Upgrade Now',
                      style: TextStyle(
                        color: const Color(0xFF2563EB),
                        fontSize: context.sp(isSmall ? 12 : 13.5),
                        fontWeight: FontWeight.bold,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: context.scale(12)),

          // Crown / Premium Badge Graphic
          Container(
            padding: EdgeInsets.all(context.scale(isSmall ? 10 : 14)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: SvgPicture.asset(
              AppIcons.Badge,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFBBF24),
                BlendMode.srcIn,
              ),
              height: context.scale(isSmall ? 36 : 46),
              width: context.scale(isSmall ? 36 : 46),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Category Filter Chips with SVGs
  Widget _buildCategoryChips(
    BuildContext context,
    DealsDiscountsViewModel viewModel,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: viewModel.categories.map((cat) {
          final isSelected = viewModel.selectedCategory == cat;

          String iconAsset = AppIcons.salesSvg;
          if (cat == 'Restaurants') iconAsset = AppIcons.spoonForkSvg;
          if (cat == 'Travel') iconAsset = AppIcons.planeSvg;
          if (cat == 'Shopping') iconAsset = AppIcons.shopSvg;
          if (cat == 'Services') iconAsset = AppIcons.plumberSvg;

          return Padding(
            padding: EdgeInsets.only(right: context.scale(10.0)),
            child: GestureDetector(
              onTap: () => viewModel.setCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(14),
                  vertical: context.scaleH(9),
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      iconAsset,
                      height: context.scale(15),
                      width: context.scale(15),
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white : const Color(0xFF475569),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: context.scale(6)),
                    Text(
                      cat,
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
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 4. Section Header with SVG Icon & "See All"
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String iconSvg,
    required Color iconColor,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconSvg,
              height: context.scale(18),
              width: context.scale(18),
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            SizedBox(width: context.scale(6)),
            Text(
              title,
              style: TextStyle(
                fontSize: context.sp(16),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See All',
                style: TextStyle(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2563EB),
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(width: context.scale(3)),
              SvgPicture.asset(
                AppIcons.arrowForwardSvg,
                width: context.scale(12),
                height: context.scale(12),
                colorFilter: const ColorFilter.mode(
                  Color(0xFF2563EB),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 5. Adaptive Layout: Grid on Tablet / Column on Phone
  Widget _buildDealsLayout(
    BuildContext context,
    List<DealItem> deals,
    bool isTablet,
  ) {
    if (isTablet) {
      // 2-column grid layout for wide screens / tablets
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: context.scale(14),
          mainAxisSpacing: context.scaleH(14),
          childAspectRatio: 2.7,
        ),
        itemCount: deals.length,
        itemBuilder: (context, index) => _buildTopDealCard(context, deals[index]),
      );
    }

    // Single column list on phones
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: deals.length,
      separatorBuilder: (_, __) => SizedBox(height: context.scaleH(12)),
      itemBuilder: (context, index) => _buildTopDealCard(context, deals[index]),
    );
  }

  /// 5. Top Deal Card with SVG Icons & Responsive Design
  Widget _buildTopDealCard(BuildContext context, DealItem deal) {
    final isSmall = context.isSmall;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () {
          final vm = context.read<DealsDiscountsViewModel>();
          if (deal.bannerAd != null) {
            vm.recordView(deal.bannerAd!.id);
          }
          Navigator.pushNamed(
            context,
            AppRoutes.dealDetails,
            arguments: {
              'storeName': deal.storeName ?? deal.title,
              'category': deal.category,
              'rating': deal.rating,
              'reviewCount': deal.views,
              'discountTitle': deal.title,
              'discountTag': deal.discountTag,
              'validUntil': deal.validUntil ?? 'Limited Time',
              'detailsText': deal.description ?? deal.title,
              'imageUrl': deal.imageUrl,
              'destinationLink': deal.destinationLink,
              'bannerAdId': deal.bannerAd?.id,
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(context.scale(isSmall ? 10 : 12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Deal Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  deal.imageUrl,
                  width: context.scale(isSmall ? 68 : 78),
                  height: context.scale(isSmall ? 68 : 78),
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: context.scale(isSmall ? 68 : 78),
                    height: context.scale(isSmall ? 68 : 78),
                    color: const Color(0xFFF1F5F9),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.gallerySvg,
                        height: context.scale(32),
                        width: context.scale(32),
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF94A3B8),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: context.scale(12)),

              // Deal Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      deal.title,
                      style: TextStyle(
                        fontSize: context.sp(isSmall ? 13 : 14),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        height: 1.25,
                        fontFamily: AppStrings.fontInter,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: context.scaleH(5)),

                    // Rating & Views Row with SVGs
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.starFavorite1499Svg,
                          height: context.scale(14),
                          width: context.scale(14),
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFF59E0B),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: context.scale(4)),
                        Text(
                          deal.rating,
                          style: TextStyle(
                            fontSize: context.sp(11.5),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate800,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                        SizedBox(width: context.scale(8)),
                        SvgPicture.asset(
                          AppIcons.eyeSvg,
                          height: context.scale(13),
                          width: context.scale(13),
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF94A3B8),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: context.scale(3)),
                        Flexible(
                          child: Text(
                            deal.views,
                            style: TextStyle(
                              fontSize: context.sp(11.5),
                              color: const Color(0xFF94A3B8),
                              fontFamily: AppStrings.fontInter,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.scaleH(7)),

                    // Bottom Row: Discount Pill & Expiry
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Discount Tag Pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scale(9),
                            vertical: context.scaleH(3.5),
                          ),
                          decoration: BoxDecoration(
                            color: deal.tagBgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            deal.discountTag,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(10.5),
                              fontWeight: FontWeight.bold,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ),

                        // Valid until / Expiry
                        if (deal.validUntil != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppIcons.TimerSvg,
                                width: context.scale(12),
                                height: context.scale(12),
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF94A3B8),
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: context.scale(3)),
                              Text(
                                deal.validUntil!,
                                style: TextStyle(
                                  fontSize: context.sp(10.5),
                                  color: const Color(0xFF94A3B8),
                                  fontFamily: AppStrings.fontInter,
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
        ),
      ),
    );
  }

  /// 6. Empty Search State with SVG & Clear Button
  Widget _buildEmptyState(
    BuildContext context,
    DealsDiscountsViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.scale(20),
        vertical: context.scaleH(36),
      ),
      margin: EdgeInsets.symmetric(vertical: context.scaleH(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(context.scale(16)),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppIcons.searchSvg,
              width: context.scale(36),
              height: context.scale(36),
              colorFilter: const ColorFilter.mode(
                Color(0xFF2563EB),
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(height: context.scaleH(16)),
          Text(
            'No deals found',
            style: TextStyle(
              fontSize: context.sp(16),
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          SizedBox(height: context.scaleH(6)),
          Text(
            viewModel.searchQuery.isNotEmpty
                ? 'We couldn\'t find any offers matching "${viewModel.searchQuery}". Try a different keyword or category.'
                : 'No promotions are currently available in this category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(13),
              color: const Color(0xFF64748B),
              height: 1.4,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          SizedBox(height: context.scaleH(16)),
          OutlinedButton.icon(
            onPressed: viewModel.clearSearch,
            icon: SvgPicture.asset(
              AppIcons.crossSmallSvg,
              width: context.scale(14),
              height: context.scale(14),
              colorFilter: const ColorFilter.mode(
                Color(0xFF2563EB),
                BlendMode.srcIn,
              ),
            ),
            label: Text(
              'Reset Search',
              style: TextStyle(
                fontSize: context.sp(13),
                fontWeight: FontWeight.bold,
                fontFamily: AppStrings.fontInter,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFF2563EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: context.scale(18),
                vertical: context.scaleH(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Loading Skeleton Placeholder
  Widget _buildSkeletonLoading(BuildContext context, bool isTablet) {
    return SkeletonShimmer(
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: EdgeInsets.only(bottom: context.scaleH(12)),
            padding: EdgeInsets.all(context.scale(12)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                SkeletonBox(
                  width: context.scale(76),
                  height: context.scale(76),
                  borderRadius: 12,
                ),
                SizedBox(width: context.scale(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLine(
                        width: context.scale(160),
                        height: context.scaleH(14),
                      ),
                      SizedBox(height: context.scaleH(8)),
                      SkeletonLine(
                        width: context.scale(110),
                        height: context.scaleH(12),
                      ),
                      SizedBox(height: context.scaleH(10)),
                      SkeletonBox(
                        width: context.scale(60),
                        height: context.scaleH(20),
                        borderRadius: 10,
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

  /// 7. Popular Deal Card with SVGs & Responsive Design
  Widget _buildPopularDealCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.dealDetails,
            arguments: {
              'storeName': 'Desi Mart Barcelona',
              'category': 'Grocery & Spices',
              'rating': '4.9',
              'reviewCount': '520',
              'discountTitle': '10% OFF on all products',
              'discountTag': '10% OFF',
              'validUntil': '31 Dec 2026',
              'detailsText':
                  'Authentic South Asian groceries, spices, halal meat, and household goods at the heart of Barcelona.',
              'imageUrl':
                  'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=800',
              'location': 'Barcelona, Spain',
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(context.scale(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container with Shop SVG
              Container(
                width: context.scale(48),
                height: context.scale(48),
                decoration: BoxDecoration(
                  color: const Color(0xFF047857),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.shopSvg,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    width: context.scale(24),
                    height: context.scale(24),
                  ),
                ),
              ),

              SizedBox(width: context.scale(14)),

              // Title, Subtitle, Location with SVGs
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Desi Mart Barcelona',
                            style: TextStyle(
                              fontSize: context.sp(14.5),
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                              fontFamily: AppStrings.fontInter,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Premium Tag with SVG Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scale(8),
                            vertical: context.scaleH(3),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppIcons.Verifed_tickSvg,
                                width: context.scale(11),
                                height: context.scale(11),
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF2563EB),
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: context.scale(3)),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  fontSize: context.sp(10.5),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2563EB),
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.scaleH(3)),
                    Text(
                      '10% OFF on all groceries',
                      style: TextStyle(
                        fontSize: context.sp(12.5),
                        color: const Color(0xFF64748B),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    SizedBox(height: context.scaleH(5)),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.locationSvg,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF94A3B8),
                            BlendMode.srcIn,
                          ),
                          height: context.scale(13),
                          width: context.scale(13),
                        ),
                        SizedBox(width: context.scale(3)),
                        Text(
                          'Barcelona, Spain',
                          style: TextStyle(
                            fontSize: context.sp(11.5),
                            color: const Color(0xFF94A3B8),
                            fontFamily: AppStrings.fontInter,
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
      ),
    );
  }

  /// Filter Bottom Sheet
  void _showFilterBottomSheet(
    BuildContext context,
    DealsDiscountsViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
              vertical: context.scaleH(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Deals by Category',
                      style: TextStyle(
                        fontSize: context.sp(16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        AppIcons.crossSmallSvg,
                        width: context.scale(16),
                        height: context.scale(16),
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate600,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                SizedBox(height: context.scaleH(12)),
                Wrap(
                  spacing: context.scale(8),
                  runSpacing: context.scaleH(8),
                  children: viewModel.categories.map((cat) {
                    final isSel = viewModel.selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.slate700,
                        fontWeight:
                            isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: context.sp(13),
                        fontFamily: AppStrings.fontInter,
                      ),
                      backgroundColor: const Color(0xFFF1F5F9),
                      onSelected: (_) {
                        viewModel.setCategory(cat);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: context.scaleH(16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
