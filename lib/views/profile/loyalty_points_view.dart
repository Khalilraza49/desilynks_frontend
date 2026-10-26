import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/widgets/coming_soon_dialog.dart';

class EarnPointRule {
  final String title;
  final String points;
  final String icon;
  final Color iconColor;
  final Color iconBgColor;

  const EarnPointRule({
    required this.title,
    required this.points,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class RedeemRewardItem {
  final String title;
  final String pointsRequired;
  final String icon;
  final Color iconColor;
  final Color iconBgColor;
  final int pointsCost;

  const RedeemRewardItem({
    required this.title,
    required this.pointsRequired,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.pointsCost,
  });
}

class LoyaltyPointsView extends StatelessWidget {
  const LoyaltyPointsView({super.key});

  static const List<EarnPointRule> _earnRules = [
    EarnPointRule(
      title: 'Create a Post',
      points: '+10 Points',
      icon: AppIcons.assetaddSvg,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFEFF6FF),
    ),
    EarnPointRule(
      title: 'Someone contacts you',
      points: '+20 Points',
      icon: AppIcons.chatRoundSvg,
      iconColor: Color(0xFF8B5CF6),
      iconBgColor: Color(0xFFF5F3FF),
    ),
    EarnPointRule(
      title: 'Successful Hire',
      points: '+50 Points',
      icon: AppIcons.tickCircleSvg,
      iconColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFECFDF5),
    ),
    EarnPointRule(
      title: 'Refer a Friend',
      points: '+100 Points',
      icon: AppIcons.assetaddSvg,
      iconColor: Color(0xFFF59E0B),
      iconBgColor: Color(0xFFFFFBEB),
    ),
    EarnPointRule(
      title: 'Daily Login',
      points: '+5 Points',
      icon: AppIcons.calendarSvg,
      iconColor: Color(0xFFEF4444),
      iconBgColor: Color(0xFFFEF2F2),
    ),
  ];

  static const List<RedeemRewardItem> _rewards = [
    RedeemRewardItem(
      title: '10€ Wallet Credit',
      pointsRequired: '1000 Points',
      pointsCost: 1000,
      icon: AppIcons.walletSvg,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFEFF6FF),
    ),
    RedeemRewardItem(
      title: 'Premium Plan (7 Days)',
      pointsRequired: '1500 Points',
      pointsCost: 1500,
      icon: AppIcons.Badge,
      iconColor: Color(0xFFF59E0B),
      iconBgColor: Color(0xFFFFFBEB),
    ),
    RedeemRewardItem(
      title: 'Featured Listing (7 Days)',
      pointsRequired: '800 Points',
      pointsCost: 800,
      icon: AppIcons.starFavoriteSvg,
      iconColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFECFDF5),
    ),
  ];

  void _showComingSoon(BuildContext context) {
    ComingSoonDialog.show(
      context,
      title: 'Coming Soon',
      featureName: 'Loyalty Points',
      message:
          'Loyalty Points redemption and earning systems are currently under development. Soon you will be able to collect points and redeem them for exclusive benefits!',
    );
  }

  void _redeemReward(
    BuildContext context,
    AuthViewModel authVM,
    RedeemRewardItem reward,
  ) {
    _showComingSoon(context);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        _showComingSoon(context);
      }
    });

    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackBasicSvg,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.slate900,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Loyalty Points',
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
              vertical: (context.scaleH(16)).clamp(12.0, 20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Your Balance Card
                Container(
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
                        Color(0xFF2563EB),
                        Color(0xFF3B82F6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: context.sp(13.5),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: (context.scaleH(6)).clamp(4.0, 8.0)),
                      Text(
                        '${authVM.loyaltyPoints}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(38),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: (context.scaleH(4)).clamp(2.0, 6.0)),
                      Text(
                        'Available Points',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: context.sp(13),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: (context.scaleH(20)).clamp(14.0, 24.0)),

                // 2. How to Earn Points Section
                Text(
                  'How to earn points',
                  style: TextStyle(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),

                SizedBox(height: (context.scaleH(12)).clamp(8.0, 16.0)),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Column(
                    children: _earnRules.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final rule = entry.value;
                      final isLast = idx == _earnRules.length - 1;
                      final double ruleIconBoxSize = (context.scale(
                        36,
                      )).clamp(30.0, 40.0);
                      final double ruleSvgSize = (context.scale(
                        18,
                      )).clamp(16.0, 20.0);

                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.cardPad,
                              vertical: (context.scaleH(13)).clamp(10.0, 16.0),
                            ),
                            child: Row(
                              children: [
                                // Icon Container
                                Container(
                                  width: ruleIconBoxSize,
                                  height: ruleIconBoxSize,
                                  decoration: BoxDecoration(
                                    color: rule.iconBgColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      rule.icon,
                                      colorFilter: ColorFilter.mode(
                                        rule.iconColor,
                                        BlendMode.srcIn,
                                      ),
                                      height: ruleSvgSize,
                                      width: ruleSvgSize,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: (context.scale(14)).clamp(10.0, 16.0),
                                ),

                                // Rule Title
                                Expanded(
                                  child: Text(
                                    rule.title,
                                    style: TextStyle(
                                      fontSize: context.sp(14),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate900,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ),

                                // Points Tag
                                Text(
                                  rule.points,
                                  style: TextStyle(
                                    fontSize: context.sp(13.5),
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: (context.scaleH(24)).clamp(16.0, 28.0)),

                // 3. Redeem Rewards Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Redeem Rewards',
                      style: TextStyle(
                        fontSize: context.sp(16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showComingSoon(context);
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

                SizedBox(height: (context.scaleH(12)).clamp(8.0, 16.0)),

                // 4. Redeem Reward Cards
                ..._rewards.map((reward) => _buildRewardCard(context, authVM, reward)),

                SizedBox(height: (context.scaleH(20)).clamp(14.0, 24.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard(
    BuildContext context,
    AuthViewModel authVM,
    RedeemRewardItem reward,
  ) {
    final double iconBoxSize = (context.scale(48)).clamp(40.0, 52.0);
    final double svgSize = (context.scale(22)).clamp(18.0, 24.0);

    return Padding(
      padding: EdgeInsets.only(bottom: (context.scaleH(12.0)).clamp(8.0, 14.0)),
      child: Container(
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
            // Left Icon Container
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: reward.iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: SvgPicture.asset(
                  reward.icon,
                  colorFilter: ColorFilter.mode(
                    reward.iconColor,
                    BlendMode.srcIn,
                  ),
                  height: svgSize,
                  width: svgSize,
                ),
              ),
            ),
            SizedBox(width: (context.scale(14)).clamp(10.0, 16.0)),

            // Title & Points Cost
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: TextStyle(
                      fontSize: context.sp(14.5),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reward.pointsRequired,
                    style: TextStyle(
                      fontSize: context.sp(12),
                      color: const Color(0xFF94A3B8),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Redeem Button
            OutlinedButton(
              onPressed: () => _redeemReward(context, authVM, reward),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: (context.scale(16)).clamp(10.0, 20.0),
                  vertical: (context.scaleH(8)).clamp(6.0, 10.0),
                ),
                side: const BorderSide(color: Color(0xFF2563EB), width: 1.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Redeem',
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
      ),
    );
  }
}
