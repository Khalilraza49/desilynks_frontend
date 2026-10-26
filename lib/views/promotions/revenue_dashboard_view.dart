import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:flutter_svg/svg.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/promotions/revenue_dashboard_viewmodel.dart';

class RevenueDashboardView extends StatelessWidget {
  const RevenueDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RevenueDashboardViewModel>();

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
          'Revenue Dashboard',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: context.scale(12.0)),
            child: PopupMenuButton<String>(
              onSelected: (val) => viewModel.setPeriod(val),
              itemBuilder: (ctx) => viewModel.periods
                  .map(
                    (p) => PopupMenuItem(
                      value: p,
                      child: Text(
                        p,
                        style: TextStyle(fontSize: context.sp(13)),
                      ),
                    ),
                  )
                  .toList(),
              child: Row(
                children: [
                  Text(
                    viewModel.selectedPeriod,
                    style: TextStyle(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2563EB),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  SizedBox(width: context.scale(4)),
                  SvgPicture.asset(
                    AppIcons.arrowDropDownSvg,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2563EB),
                      BlendMode.srcIn,
                    ),
                    height: context.scale(20),
                    width: context.scale(20),
                  ),
                ],
              ),
            ),
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
                // 1. Total Revenue Gradient Card with Mini Bar Chart
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.scale(20)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1D4ED8),
                        Color(0xFF3B82F6),
                        Color(0xFF6366F1),
                      ],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Revenue',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: context.sp(13),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: context.scaleH(6)),
                      Text(
                        '€5,420.50',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(34),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: context.scaleH(4)),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.up_arrow,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF4ADE80),
                              BlendMode.srcIn,
                            ),
                            height: context.scale(15),
                            width: context.scale(15),
                          ),
                          SizedBox(width: context.scale(2)),
                          Text(
                            '+18.6% vs last month',
                            style: TextStyle(
                              color: const Color(0xFF4ADE80),
                              fontSize: context.sp(12.5),
                              fontWeight: FontWeight.bold,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.scaleH(24)),

                      // Mini Bar Chart Graphic at bottom of card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildMiniBar(context, 20, false),
                          _buildMiniBar(context, 28, false),
                          _buildMiniBar(context, 22, false),
                          _buildMiniBar(context, 36, false),
                          _buildMiniBar(context, 26, false),
                          _buildMiniBar(context, 34, false),
                          _buildMiniBar(context, 48, true), // Active highlighted bar
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.scaleH(16)),

                // 2. Stats Grid (3 Cards)
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, '08', 'Active Promos')),
                    SizedBox(width: context.scale(10)),
                    Expanded(child: _buildStatCard(context, '12.4K', 'Total Views')),
                    SizedBox(width: context.scale(10)),
                    Expanded(child: _buildStatCard(context, '1.8K', 'Total Clicks')),
                  ],
                ),

                SizedBox(height: context.scaleH(14)),

                // 3. Total Orders Banner Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(18),
                    vertical: context.scaleH(16),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Orders',
                        style: TextStyle(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      Text(
                        '245',
                        style: TextStyle(
                          fontSize: context.sp(22),
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.scaleH(16)),

                // 4. Revenue Breakdown Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.scale(18)),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenue Breakdown',
                        style: TextStyle(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: context.scaleH(18)),
                      ...viewModel.breakdownItems.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: context.scaleH(16.0)),
                          child: _buildBreakdownRow(context, item),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.scaleH(20)),

                // 5. Action Buttons (My Revenue Stats & View Transaction History)
                SizedBox(
                  width: double.infinity,
                  height: context.scaleH(48),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.myRevenueStats);
                      },
                      icon: SvgPicture.asset(
                        AppIcons.barSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        height: context.scale(20),
                        width: context.scale(20),
                      ),
                      label: Text(
                        'My Revenue Stats',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.bold,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.scaleH(12)),

                SizedBox(
                  width: double.infinity,
                  height: context.scaleH(48),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.transactionHistory);
                    },
                    icon: SvgPicture.asset(
                      AppIcons.history,
                      height: context.scale(20),
                      width: context.scale(20),
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF2563EB),
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      'View Transaction History',
                      style: TextStyle(
                        color: const Color(0xFF2563EB),
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.bold,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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

  Widget _buildMiniBar(BuildContext context, double height, bool isHighlighted) {
    return Container(
      width: context.scale(32),
      height: context.scaleH(height),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.white
            : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String val, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.scaleH(14),
        horizontal: context.scale(8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              fontSize: context.sp(20),
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          SizedBox(height: context.scaleH(4)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(11),
              color: const Color(0xFF64748B),
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(BuildContext context, RevenueBreakdownItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title with Color Dot
            Row(
              children: [
                Container(
                  width: context.scale(10),
                  height: context.scale(10),
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: context.scale(8)),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: context.sp(13.5),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
            // Amount & Percentage
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.amount,
                  style: TextStyle(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                Text(
                  item.percentageText,
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
        SizedBox(height: context.scaleH(8)),
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: item.percentage,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
            minHeight: context.scaleH(5),
          ),
        ),
      ],
    );
  }
}
