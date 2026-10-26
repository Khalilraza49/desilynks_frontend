import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/coming_soon_dialog.dart';

class BenefitItemData {
  final String title;
  final String subtitle;
  final String icon;
  final Color iconColor;
  final Color iconBgColor;

  const BenefitItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class MembershipBenefitsView extends StatelessWidget {
  const MembershipBenefitsView({super.key});

  final List<BenefitItemData> _benefits = const [
    BenefitItemData(
      title: 'Unlimited Ads & Postings',
      subtitle: 'Post as many ads as you want',
      icon: AppIcons.permium_badge,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFEFF6FF),
    ),
    BenefitItemData(
      title: 'Priority Listing in Search',
      subtitle: 'Show up first in search results',
      icon: AppIcons.searchSvg,
      iconColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFECFDF5),
    ),
    BenefitItemData(
      title: 'Ad Boost (Store Visibility)',
      subtitle: 'Promote ads to more users',
      icon: AppIcons.boostRocketSvg,
      iconColor: Color(0xFFF59E0B),
      iconBgColor: Color(0xFFFFFBEB),
    ),
    BenefitItemData(
      title: 'Advanced Analytics',
      subtitle: 'Track views, clicks & leads',
      icon: AppIcons.barSvg,
      iconColor: Color(0xFF8B5CF6),
      iconBgColor: Color(0xFFF5F3FF),
    ),
    BenefitItemData(
      title: 'Verified Badge',
      subtitle: 'Build trust with a verified profile',
      icon: AppIcons.verifySvg,
      iconColor: Color(0xFF3B82F6),
      iconBgColor: Color(0xFFEFF6FF),
    ),
    BenefitItemData(
      title: 'No Ads',
      subtitle: 'Ad-free browsing experience',
      icon: AppIcons.blockSvg,
      iconColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFECFDF5),
    ),
    BenefitItemData(
      title: 'Priority Support',
      subtitle: '24/7 dedicated customer support',
      icon: AppIcons.supportSvg,
      iconColor: Color(0xFFEC4899),
      iconBgColor: Color(0xFFFDF2F8),
    ),
  ];

  void _showComingSoon(BuildContext context, {String? featureName}) {
    ComingSoonDialog.show(
      context,
      title: 'Coming Soon',
      featureName: featureName ?? 'Premium Membership',
      message: featureName != null
          ? '$featureName is a Premium benefit and is currently under development. Stay tuned for upcoming updates!'
          : 'Premium Membership and its exclusive benefits are currently under development. Stay tuned for upcoming updates!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackBasicSvg,
            width: (context.scale(20)).clamp(18.0, 22.0),
            height: (context.scale(20)).clamp(18.0, 22.0),
            colorFilter: const ColorFilter.mode(
              AppColors.slate900,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Premium Benefits',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.hMargin,
                    vertical: (context.scaleH(16)).clamp(12.0, 20.0),
                  ),
                  child: Column(
                    children: [
                      // 1. Top Hero Card
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showComingSoon(context),
                          child: Ink(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: (context.scaleH(24)).clamp(18.0, 28.0),
                              horizontal: (context.scale(20)).clamp(16.0, 24.0),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1D4ED8),
                                  Color(0xFF3B82F6),
                                  Color(0xFF7C3AED),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Gold Crown Icon Circle
                                Container(
                                  width: (context.scale(56)).clamp(48.0, 64.0),
                                  height: (context.scale(56)).clamp(48.0, 64.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      AppIcons.crownSvg,
                                      width: (context.scale(
                                        28,
                                      )).clamp(24.0, 32.0),
                                      height: (context.scale(
                                        28,
                                      )).clamp(24.0, 32.0),
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xFFFBBF24),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: (context.scaleH(12)).clamp(8.0, 14.0),
                                ),
                                Text(
                                  'Premium Benefits',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.sp(22),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                                SizedBox(
                                  height: (context.scaleH(4)).clamp(2.0, 6.0),
                                ),
                                Text(
                                  'Everything you get with Premium',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: context.sp(13.5),
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),

                      // 2. Benefits List Items
                      ..._benefits.map(
                        (benefit) => _buildBenefitCard(context, benefit),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Full-Width Upgrade Button
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.hMargin,
                    vertical: (context.scaleH(12)).clamp(8.0, 16.0),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: (context.scaleH(50)).clamp(44.0, 56.0),
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
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _showComingSoon(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.crownSvg,
                              width: (context.scale(18)).clamp(16.0, 20.0),
                              height: (context.scale(18)).clamp(16.0, 20.0),
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(
                              width: (context.scale(8)).clamp(6.0, 10.0),
                            ),
                            Text(
                              'Upgrade Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(16),
                                fontWeight: FontWeight.bold,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard(BuildContext context, BenefitItemData benefit) {
    final double iconBoxSize = (context.scale(44)).clamp(38.0, 48.0);
    final double svgSize = (context.scale(22)).clamp(18.0, 24.0);

    return Padding(
      padding: EdgeInsets.only(bottom: (context.scaleH(10.0)).clamp(6.0, 12.0)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showComingSoon(context, featureName: benefit.title),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: EdgeInsets.all(context.cardPad),
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
              children: [
                // Left Feature Icon Container
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: benefit.iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      benefit.icon,
                      colorFilter: ColorFilter.mode(
                        benefit.iconColor,
                        BlendMode.srcIn,
                      ),
                      height: svgSize,
                      width: svgSize,
                    ),
                  ),
                ),
                SizedBox(width: (context.scale(14)).clamp(10.0, 16.0)),

                // Title & Subtitle Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit.title,
                        style: TextStyle(
                          fontSize: context.sp(14.5),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        benefit.subtitle,
                        style: TextStyle(
                          fontSize: context.sp(12.5),
                          color: const Color(0xFF64748B),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Green Checkmark Badge Icon
                SvgPicture.asset(
                  AppIcons.tickCircleSvg,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF10B981),
                    BlendMode.srcIn,
                  ),
                  height: (context.scale(22)).clamp(18.0, 24.0),
                  width: (context.scale(22)).clamp(18.0, 24.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
