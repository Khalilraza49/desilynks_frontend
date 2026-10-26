import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:flutter_svg/svg.dart';
import 'package:desilynks/viewmodels/promotions/banner_advertisements_viewmodel.dart';
import 'package:desilynks/viewmodels/promotions/create_banner_viewmodel.dart';

class BannerAdvertisementsView extends StatelessWidget {
  const BannerAdvertisementsView({super.key});

  void _onSelectPosition(BuildContext context, BannerPositionItem item) {
    context.read<BannerAdvertisementsViewModel>().selectPosition(item);
    context.read<CreateBannerViewModel>().resetForm(position: item.position);
    Navigator.pushNamed(
      context,
      AppRoutes.createBanner,
      arguments: item.position,
    );
  }

  void _onCreateBanner(BuildContext context) {
    context.read<CreateBannerViewModel>().resetForm();
    Navigator.pushNamed(context, AppRoutes.createBanner);
  }

  void _onManageMyBanners(BuildContext context) {
    final vm = context.read<BannerAdvertisementsViewModel>();
    if (vm.myBanners.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have no active banner ads yet.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _showMyBannersBottomSheet(context, vm);
    }
  }

  void _showMyBannersBottomSheet(
    BuildContext context,
    BannerAdvertisementsViewModel vm,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Banner Ads (${vm.myBanners.length})',
                    style: TextStyle(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _onCreateBanner(context);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Banner'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: vm.myBanners.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, index) {
                    final banner = vm.myBanners[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              banner.photoUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                color: const Color(0xFFE2E8F0),
                                child: const Icon(Icons.image, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  banner.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${banner.position.label} · ${banner.views} views · ${banner.clicks} clicks',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: banner.isRunning
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              banner.status.value,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: banner.isRunning
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BannerAdvertisementsViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackBasicSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate900,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Banner Advertisements',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.hMargin,
                vertical: context.scaleH(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero Promo Card ("Get More Visibility")
                  _buildHeroCard(context),

                  SizedBox(height: context.scaleH(22)),

                  // 2. Section Header
                  Text(
                    'Banner Positions',
                    style: TextStyle(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),

                  SizedBox(height: context.scaleH(12)),

                  // 3. Banner Position Cards List
                  ...viewModel.positions.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: context.scaleH(12)),
                      child: _buildPositionCard(context, item),
                    ),
                  ),

                  SizedBox(height: context.scaleH(4)),

                  // 4. "My Banner Ads" Card
                  _buildMyBannersCard(context),

                  SizedBox(height: context.scaleH(16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scale(20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get More Visibility',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.bold,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                SizedBox(height: context.scaleH(4)),
                Text(
                  'Promote your brand with Banner Ads',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: context.sp(13),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                SizedBox(height: context.scaleH(18)),
                GestureDetector(
                  onTap: () => _onCreateBanner(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(18),
                      vertical: context.scaleH(10),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '+ Create Banner',
                      style: TextStyle(
                        color: const Color(0xFF2563EB),
                        fontSize: context.sp(14),
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

          // Right Decorative Box
          Container(
            width: context.scale(72),
            height: context.scale(72),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.gallerySvg,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                height: context.scale(38),
                width: context.scale(38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCard(BuildContext context, BannerPositionItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () => _onSelectPosition(context, item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.scale(16),
            vertical: context.scaleH(14),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          ),
          child: Row(
            children: [
              // Colored Icon Box
              Container(
                width: context.scale(46),
                height: context.scale(46),
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    item.icon,
                    colorFilter: ColorFilter.mode(
                      item.iconColor,
                      BlendMode.srcIn,
                    ),
                    height: context.scale(22),
                    width: context.scale(22),
                  ),
                ),
              ),

              SizedBox(width: context.scale(14)),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: context.sp(14.5),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    SizedBox(height: context.scaleH(3)),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: context.sp(12),
                        color: const Color(0xFF64748B),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: context.scale(8)),

              // Price & Duration Trailing
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.priceText,
                        style: TextStyle(
                          fontSize: context.sp(13.5),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: context.scaleH(2)),
                      Text(
                        '${item.durationText} >',
                        style: TextStyle(
                          fontSize: context.sp(11),
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
      ),
    );
  }

  Widget _buildMyBannersCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () => _onManageMyBanners(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.scale(16),
            vertical: context.scaleH(14),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          ),
          child: Row(
            children: [
              // Icon Box
              Container(
                width: context.scale(46),
                height: context.scale(46),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.filterSvg,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF7C3AED),
                      BlendMode.srcIn,
                    ),
                    height: context.scale(22),
                    width: context.scale(22),
                  ),
                ),
              ),

              SizedBox(width: context.scale(14)),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Banner Ads',
                      style: TextStyle(
                        fontSize: context.sp(14.5),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    SizedBox(height: context.scaleH(3)),
                    Text(
                      'Manage your banners',
                      style: TextStyle(
                        fontSize: context.sp(12),
                        color: const Color(0xFF64748B),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),

              SvgPicture.asset(
                AppIcons.arrowForwardSvg,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF94A3B8),
                  BlendMode.srcIn,
                ),
                height: context.scale(22),
                width: context.scale(22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
