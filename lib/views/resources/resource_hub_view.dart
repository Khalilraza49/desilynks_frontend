import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/models/resource_hub_model.dart';
import 'package:desilynks/services/permissions/app_toast.dart';
import 'package:desilynks/viewmodels/resources/resource_hub_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';

class ResourceHubView extends StatelessWidget {
  const ResourceHubView({super.key});

  static const List<Map<String, dynamic>> _usefulLinks = [
    {
      'title': 'Spanish Immigration Ministry',
      'url': 'inclusion.gob.es',
      'fullUrl': 'https://www.inclusion.gob.es',
      'icon': AppIcons.planeSvg,
      'iconColor': Color(0xFF2563EB),
      'bgColor': Color(0xFFEFF6FF),
      'description':
          'Official portal for visas, residence renewals, and foreign national regulations in Spain.',
    },
    {
      'title': 'SEPE — Employment Office',
      'url': 'sepe.es',
      'fullUrl': 'https://www.sepe.es',
      'icon': AppIcons.briefcaseSvg,
      'iconColor': Color(0xFF059669),
      'bgColor': Color(0xFFECFDF5),
      'description':
          'State public employment service for job listings, benefits, and unemployment registration.',
    },
    {
      'title': 'Tax Agency Spain (AEAT)',
      'url': 'agenciatributaria.es',
      'fullUrl': 'https://sede.agenciatributaria.gob.es',
      'icon': AppIcons.newspaperSvg,
      'iconColor': Color(0xFFEA580C),
      'bgColor': Color(0xFFFFF7ED),
      'description':
          'Official portal for tax declarations, NIE tax status, and digital certificates.',
    },
  ];

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _openArticleDetail(BuildContext context, ResourceHubArticle article) {
    Navigator.pushNamed(
      context,
      AppRoutes.resourceHubDetail,
      arguments: article,
    );
  }

  void _onUsefulLinkTap(BuildContext context, Map<String, dynamic> link) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: link['bgColor'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      link['icon'] as String,
                      colorFilter: ColorFilter.mode(
                        link['iconColor'] as Color,
                        BlendMode.srcIn,
                      ),
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link['title'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      Text(
                        link['url'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              link['description'] as String,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.slate600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: link['fullUrl'] as String),
                      );
                      Navigator.pop(ctx);
                      AppToast.show('Copied link: ${link['fullUrl']}');
                    },
                    icon: SvgPicture.asset(
                      AppIcons.Copy,
                      height: 16,
                      width: 16,
                    ),
                    label: const Text('Copy Link'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.slate800,
                      side: const BorderSide(color: AppColors.slate300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final uri = Uri.parse(link['fullUrl'] as String);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        AppToast.showError('Could not open link');
                      }
                    },
                    icon: SvgPicture.asset(
                      AppIcons.OpenLink,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text('Visit Site'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResourceHubViewModel>().initHub();
    });

    return Consumer<ResourceHubViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundOffWhite,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: SvgPicture.asset(
                AppIcons.arrowBackSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate900,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Resource Hub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            centerTitle: false,
            titleSpacing: 0,
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  vm.selectedTab == 1 || vm.savedArticles.isNotEmpty
                      ? AppIcons.bookmark_filled
                      : AppIcons.bookmark,
                  colorFilter: ColorFilter.mode(
                    vm.selectedTab == 1
                        ? AppColors.primaryBlue
                        : AppColors.slate700,
                    BlendMode.srcIn,
                  ),
                  width: 22,
                  height: 22,
                ),
                tooltip: 'Saved Guides',
                onPressed: () {
                  vm.setSelectedTab(vm.selectedTab == 1 ? 0 : 1);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryBlue,
              onRefresh: () async {
                if (vm.selectedTab == 0) {
                  await vm.fetchArticles(refresh: true);
                } else {
                  await vm.fetchSavedArticles(refresh: true);
                }
              },
              child: SingleChildScrollView(
                controller: vm.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Tabs: Explore vs Saved
                    _buildTabSelector(vm),
                    const SizedBox(height: 14),

                    // Search Bar
                    _buildSearchBar(vm),
                    const SizedBox(height: 16),

                    if (vm.selectedTab == 0) ...[
                      // Explore Guides Tab
                      // Featured Guide Card (if not searching and no category selected)
                      if (vm.searchQuery.isEmpty &&
                          vm.selectedCategory == null &&
                          vm.articles.isNotEmpty) ...[
                        _buildFeaturedGuideCard(context, vm.articles.first),
                        const SizedBox(height: 20),
                      ],

                      // Categories Section
                      _buildBrowseCategoriesSection(vm),
                      const SizedBox(height: 24),

                      // Articles List Section
                      _buildArticlesListSection(context, vm),
                      const SizedBox(height: 24),

                      // Useful Links Section
                      _buildUsefulLinksSection(context),
                      const SizedBox(height: 20),
                    ] else ...[
                      // Saved Guides Tab
                      _buildSavedArticlesSection(context, vm),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabSelector(ResourceHubViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => vm.setSelectedTab(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: vm.selectedTab == 0
                      ? AppColors.white
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: vm.selectedTab == 0
                      ? [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.resourceSvg,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        vm.selectedTab == 0
                            ? AppColors.primaryBlue
                            : AppColors.slate600,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Explore Guides',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: vm.selectedTab == 0
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: vm.selectedTab == 0
                            ? AppColors.primaryBlue
                            : AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => vm.setSelectedTab(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: vm.selectedTab == 1
                      ? AppColors.white
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: vm.selectedTab == 1
                      ? [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.bookmark_filled,
                      width: 15,
                      height: 15,
                      colorFilter: ColorFilter.mode(
                        vm.selectedTab == 1
                            ? AppColors.primaryBlue
                            : AppColors.slate600,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Saved Guides',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: vm.selectedTab == 1
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: vm.selectedTab == 1
                            ? AppColors.primaryBlue
                            : AppColors.slate600,
                      ),
                    ),
                    if (vm.savedArticles.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${vm.savedArticles.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ResourceHubViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomTextField(
        controller: vm.searchController,
        hintText: 'Search guide titles...',
        onChanged: (val) => vm.onSearchChanged(val),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: SvgPicture.asset(
            AppIcons.searchSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate400,
              BlendMode.srcIn,
            ),
            width: 20,
            height: 20,
          ),
        ),
        suffixIcon: vm.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.slate400,
                ),
                onPressed: () {
                  vm.clearSearch();
                },
              )
            : null,
      ),
    );
  }

  Widget _buildFeaturedGuideCard(BuildContext context, ResourceHubArticle featuredArticle) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF194FE6), Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: CircleAvatar(
              radius: 75,
              backgroundColor: AppColors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        featuredArticle.category.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: AppColors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(featuredArticle.createdAt),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  featuredArticle.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By ${featuredArticle.authorName}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _openArticleDetail(context, featuredArticle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: const Color(0xFF1D4ED8),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Read Guide',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SvgPicture.asset(
                        AppIcons.arrowForwardSvg,
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF1D4ED8),
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseCategoriesSection(ResourceHubViewModel vm) {
    const categories = [
      ResourceHubCategory.immigration,
      ResourceHubCategory.housing,
      ResourceHubCategory.jobAndWork,
      ResourceHubCategory.healthcare,
      ResourceHubCategory.legalAdvice,
      ResourceHubCategory.education,
      ResourceHubCategory.business,
      ResourceHubCategory.taxes,
      ResourceHubCategory.transport,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Browse Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            if (vm.selectedCategory != null)
              GestureDetector(
                onTap: () => vm.selectCategory(null),
                child: const Text(
                  'Clear Filter',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Category Pill Filters (Quick All + Categories)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryPill(
                label: 'All Guides',
                isSelected: vm.selectedCategory == null,
                iconSvg: AppIcons.resourceSvg,
                iconColor: AppColors.primaryBlue,
                bgColor: AppColors.slate100,
                onTap: () => vm.selectCategory(null),
              ),
              ...categories.map((cat) {
                final isSelected = vm.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildCategoryPill(
                    label: cat.label,
                    isSelected: isSelected,
                    iconSvg: cat.iconSvg,
                    iconColor: cat.iconColor,
                    bgColor: cat.bgColor,
                    onTap: () => vm.selectCategory(cat),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPill({
    required String label,
    required bool isSelected,
    required String iconSvg,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.slate200.withValues(alpha: 0.8),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryBlue.withValues(alpha: 0.15)
                  : AppColors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconSvg,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.white : iconColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.slate800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesListSection(BuildContext context, ResourceHubViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              vm.selectedCategory != null
                  ? '${vm.selectedCategory!.label} Guides'
                  : 'Latest Articles',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            if (vm.meta.total > 0)
              Text(
                '${vm.meta.total} ${vm.meta.total == 1 ? 'article' : 'articles'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.slate500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (vm.isLoading && vm.articles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            ),
          )
        else if (vm.errorMessage != null && vm.articles.isEmpty)
          _buildErrorState(
            message: vm.errorMessage!,
            onRetry: () => vm.fetchArticles(refresh: true),
          )
        else if (vm.articles.isEmpty)
          _buildEmptyArticlesState(vm)
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: vm.articles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final article = vm.articles[index];
              return _buildArticleCard(context, article, vm);
            },
          ),

        if (vm.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildArticleCard(BuildContext context, ResourceHubArticle article, ResourceHubViewModel vm) {
    return GestureDetector(
      onTap: () => _openArticleDetail(context, article),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.slate200.withValues(alpha: 0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: article.category.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  article.category.iconSvg,
                  colorFilter: ColorFilter.mode(
                    article.category.iconColor,
                    BlendMode.srcIn,
                  ),
                  width: 22,
                  height: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Article Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: article.category.bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.category.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: article.category.tagColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(article.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'By ${article.authorName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.slate500,
                          ),
                        ),
                      ),
                      if (article.isUpdated) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '• Edited',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Save / Bookmark Action
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: SvgPicture.asset(
                article.isSaved
                    ? AppIcons.bookmark_filled
                    : AppIcons.bookmark,
                colorFilter: ColorFilter.mode(
                  article.isSaved
                    ? AppColors.primaryBlue
                    : AppColors.slate400,
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
              ),
              onPressed: () => vm.toggleSaveArticle(article),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedArticlesSection(BuildContext context, ResourceHubViewModel vm) {
    if (!vm.isLoggedIn) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.bookmark_filled,
                  width: 26,
                  height: 26,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryBlue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign In to Save Guides',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Keep important immigration, housing, and legal guides handy for quick offline reference.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.slate500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Log In / Register',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    if (vm.isLoadingSaved && vm.savedArticles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
          ),
        ),
      );
    }

    if (vm.savedErrorMessage != null && vm.savedArticles.isEmpty) {
      return _buildErrorState(
        message: vm.savedErrorMessage!,
        onRetry: () => vm.fetchSavedArticles(refresh: true),
      );
    }

    if (vm.savedArticles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.slate100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.bookmark,
                  width: 26,
                  height: 26,
                  colorFilter: const ColorFilter.mode(
                    AppColors.slate400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Saved Guides Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap the bookmark icon on any guide or article to save it here for fast access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.slate500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => vm.setSelectedTab(0),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Browse Guides'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Saved Guides',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            Text(
              '${vm.savedArticles.length} saved',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.slate500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: vm.savedArticles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final article = vm.savedArticles[index];
            return _buildArticleCard(context, article, vm);
          },
        ),
        if (vm.isLoadingMoreSaved)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyArticlesState(ResourceHubViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            AppIcons.searchSvg,
            height: 40,
            width: 40,
            colorFilter: const ColorFilter.mode(
              AppColors.slate300,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No articles found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.slate800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try adjusting your search or category filter.',
            style: TextStyle(fontSize: 12.5, color: AppColors.slate500),
          ),
          if (vm.searchQuery.isNotEmpty || vm.selectedCategory != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                vm.clearSearch();
                vm.selectCategory(null);
              },
              child: const Text('Reset All Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 36,
            color: AppColors.slate400,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.slate600),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsefulLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Official Helpful Portals',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _usefulLinks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final link = _usefulLinks[index];

            return GestureDetector(
              onTap: () => _onUsefulLinkTap(context, link),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.slate200.withValues(alpha: 0.7),
                  ),
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: link['bgColor'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          link['icon'] as String,
                          colorFilter: ColorFilter.mode(
                            link['iconColor'] as Color,
                            BlendMode.srcIn,
                          ),
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            link['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            link['url'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SvgPicture.asset(
                      AppIcons.OpenLink,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate400,
                        BlendMode.srcIn,
                      ),
                      width: 18,
                      height: 18,
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
}
