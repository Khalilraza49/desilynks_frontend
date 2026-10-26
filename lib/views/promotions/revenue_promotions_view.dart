import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/promotions/revenue_promotions_viewmodel.dart';

class RevenuePromotionsView extends StatelessWidget {
  const RevenuePromotionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RevenuePromotionsViewModel>();

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
          'Revenue & Promotions',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppIcons.searchSvg,
              colorFilter: const ColorFilter.mode(
                AppColors.slate900,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search promotions...')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
              vertical: context.scaleH(16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Grid of Promotion Action Cards (3 columns)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.gridActions.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: context.scale(10),
                    mainAxisSpacing: context.scaleH(10),
                    childAspectRatio: 0.88,
                  ),
                  itemBuilder: (ctx, index) {
                    final action = viewModel.gridActions[index];
                    return _buildGridCard(context, action);
                  },
                ),

                SizedBox(height: context.scaleH(18)),

                // 2. Membership Plans Banner Card
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.membershipPlans);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.all(context.scale(14)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.2,
                        ),
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
                          // Gradient Crown Container
                          Container(
                            width: context.scale(46),
                            height: context.scale(46),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                AppIcons.Badge,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                height: context.scale(24),
                                width: context.scale(24),
                              ),
                            ),
                          ),
                          SizedBox(width: context.scale(14)),

                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Membership Plans',
                                  style: TextStyle(
                                    fontSize: context.sp(14.5),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate900,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                                SizedBox(height: context.scaleH(2)),
                                Text(
                                  'Upgrade your account',
                                  style: TextStyle(
                                    fontSize: context.sp(12),
                                    color: const Color(0xFF64748B),
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Premium Badge Tag
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.scale(10),
                              vertical: context.scaleH(4),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: context.sp(11),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2563EB),
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.scaleH(20)),

                // 3. Your Stats Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Stats',
                      style: TextStyle(
                        fontSize: context.sp(16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.revenueDashboard);
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.scaleH(12)),

                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.revenueDashboard);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.scaleH(18),
                        horizontal: context.scale(12),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.2,
                        ),
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
                          Expanded(
                            child: _buildStatCol(
                              context,
                              '12.5K',
                              'Total Views',
                              AppColors.slate900,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: context.scaleH(32),
                            color: const Color(0xFFF1F5F9),
                          ),
                          Expanded(
                            child: _buildStatCol(
                              context,
                              '842',
                              'Total Clicks',
                              AppColors.slate900,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: context.scaleH(32),
                            color: const Color(0xFFF1F5F9),
                          ),
                          Expanded(
                            child: _buildStatCol(
                              context,
                              '3',
                              'Active Promos',
                              const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.scaleH(22)),

                // 4. Featured Businesses Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Businesses',
                      style: TextStyle(
                        fontSize: context.sp(16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Viewing all featured businesses'),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.scaleH(12)),

                // Carousel Row of Featured Businesses
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildBusinessCard(
                        context,
                        name: 'Desi Mart',
                        subtitle: 'Best Prices',
                        badge: 'Premium',
                        badgeBg: const Color(0xFFDBEAFE),
                        badgeText: const Color(0xFF2563EB),
                        headerBg: const Color(0xFF047857),
                        icon: AppIcons.shopSvg,
                      ),
                      SizedBox(width: context.scale(12)),
                      _buildBusinessCard(
                        context,
                        name: 'Lahore Grill',
                        subtitle: 'Desi Nihari',
                        badge: 'Golden',
                        badgeBg: const Color(0xFFFEF3C7),
                        badgeText: const Color(0xFFD97706),
                        headerBg: const Color(0xFF78350F),
                        icon: AppIcons.spoonForkSvg,
                      ),
                      SizedBox(width: context.scale(12)),
                      _buildBusinessCard(
                        context,
                        name: 'Pak Travel',
                        subtitle: 'Coromandel',
                        badge: 'Premium',
                        badgeBg: const Color(0xFFDBEAFE),
                        badgeText: const Color(0xFF2563EB),
                        headerBg: const Color(0xFF1D4ED8),
                        icon: AppIcons.planeSvg,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.scaleH(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, PromotionGridAction action) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, action.routeName);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.scale(8),
            vertical: context.scaleH(10),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: context.scale(40),
                height: context.scale(40),
                decoration: BoxDecoration(
                  color: action.iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    action.icon,
                    colorFilter: ColorFilter.mode(
                      action.iconColor,
                      BlendMode.srcIn,
                    ),
                    height: context.scale(20),
                    width: context.scale(20),
                  ),
                ),
              ),
              SizedBox(height: context.scaleH(8)),
              Text(
                action.title,
                style: TextStyle(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(1)),
              Text(
                action.subtitle1,
                style: TextStyle(
                  fontSize: context.sp(10),
                  color: const Color(0xFF64748B),
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              Text(
                action.subtitle2,
                style: TextStyle(
                  fontSize: context.sp(9.5),
                  color: const Color(0xFF94A3B8),
                  fontFamily: AppStrings.fontInter,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(
    BuildContext context,
    String val,
    String label,
    Color valColor,
  ) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            color: valColor,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        SizedBox(height: context.scaleH(2)),
        Text(
          label,
          style: TextStyle(
            fontSize: context.sp(11),
            color: const Color(0xFF64748B),
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCard(
    BuildContext context, {
    required String name,
    required String subtitle,
    required String badge,
    required Color badgeBg,
    required Color badgeText,
    required Color headerBg,
    required String icon,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.dealsDiscounts);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: context.scale(125),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Colored Header Box
              Container(
                height: context.scaleH(60),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: headerBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    icon,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    height: context.scale(26),
                    width: context.scale(26),
                  ),
                ),
              ),

              // Bottom Content Padding
              Padding(
                padding: EdgeInsets.all(context.scale(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: context.sp(12.5),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.scaleH(1)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: context.sp(10.5),
                        color: const Color(0xFF64748B),
                        fontFamily: AppStrings.fontInter,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.scaleH(8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scale(6),
                        vertical: context.scaleH(2),
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: context.sp(9.5),
                          fontWeight: FontWeight.bold,
                          color: badgeText,
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
    );
  }
}
