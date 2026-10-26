import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desilynks/viewmodels/promotions/my_revenue_stats_viewmodel.dart';

class MyRevenueStatsView extends StatelessWidget {
  const MyRevenueStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyRevenueStatsViewModel>();

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
          'My Revenue Stats',
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
                    width: context.scale(20),
                    height: context.scale(20),
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
                // 1. Total Revenue Card with Timeline Axis
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
                        '€1,245',
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
                            width: context.scale(15),
                            height: context.scale(15),
                          ),
                          SizedBox(width: context.scale(2)),
                          Text(
                            '+22% vs last month',
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

                      // Mini Bar Chart Graphic
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildMiniBar(context, 20, false),
                          _buildMiniBar(context, 26, false),
                          _buildMiniBar(context, 22, false),
                          _buildMiniBar(context, 38, false),
                          _buildMiniBar(context, 28, false),
                          _buildMiniBar(context, 36, false),
                          _buildMiniBar(context, 48, true), // Active highlighted bar
                        ],
                      ),

                      SizedBox(height: context.scaleH(8)),

                      // Timeline Labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '01 Jun',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: context.sp(10.5),
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          Text(
                            '15 Jun',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: context.sp(10.5),
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          Text(
                            '30 Jun',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: context.sp(10.5),
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.scaleH(16)),

                // 2. Stats Row (3 Cards with Growth indicators)
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, '12.5K', 'Views', '↑ +18%')),
                    SizedBox(width: context.scale(10)),
                    Expanded(child: _buildStatCard(context, '842', 'Clicks', '↑ +12%')),
                    SizedBox(width: context.scale(10)),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '€1,245',
                        'Earnings',
                        '↑ +22%',
                        valColor: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.scaleH(16)),

                // 3. Weekly Breakdown Card
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
                        'Weekly Breakdown',
                        style: TextStyle(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: context.scaleH(18)),
                      ...viewModel.weeklyItems.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: context.scaleH(14.0)),
                          child: _buildWeeklyRow(context, item),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.scaleH(16)),

                // 4. Top Performing Section
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
                        'Top Performing',
                        style: TextStyle(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: context.scaleH(16)),
                      ...viewModel.topPerformingList.map(
                        (perf) => Padding(
                          padding: EdgeInsets.only(bottom: context.scaleH(14.0)),
                          child: _buildTopPerformingItem(context, perf),
                        ),
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

  Widget _buildStatCard(
    BuildContext context,
    String val,
    String label,
    String growth, {
    Color valColor = AppColors.slate900,
  }) {
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
              fontSize: context.sp(19),
              fontWeight: FontWeight.w800,
              color: valColor,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          SizedBox(height: context.scaleH(2)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(11),
              color: const Color(0xFF64748B),
              fontFamily: AppStrings.fontInter,
            ),
          ),
          SizedBox(height: context.scaleH(4)),
          Text(
            growth,
            style: TextStyle(
              fontSize: context.sp(11),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRow(BuildContext context, WeeklyBreakdownData item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.weekLabel,
              style: TextStyle(
                fontSize: context.sp(13.5),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
                fontFamily: AppStrings.fontInter,
              ),
            ),
            Text(
              item.amount,
              style: TextStyle(
                fontSize: context.sp(14),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ],
        ),
        SizedBox(height: context.scaleH(8)),
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

  Widget _buildTopPerformingItem(BuildContext context, TopPerformingData item) {
    return Row(
      children: [
        // Left Icon Box
        Container(
          width: context.scale(44),
          height: context.scale(44),
          decoration: BoxDecoration(
            color: item.iconBgColor,
            borderRadius: BorderRadius.circular(12),
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
        SizedBox(width: context.scale(12)),

        // Center Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(2)),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: context.sp(11.5),
                  color: const Color(0xFF64748B),
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: context.scale(8)),

        // Right Earnings & Growth
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.earnings,
              style: TextStyle(
                fontSize: context.sp(14),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
                fontFamily: AppStrings.fontInter,
              ),
            ),
            SizedBox(height: context.scaleH(1)),
            Text(
              item.growth,
              style: TextStyle(
                fontSize: context.sp(11),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
