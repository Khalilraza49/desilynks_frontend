import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/viewmodels/profile/subscription_viewmodel.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/coming_soon_dialog.dart';
import 'package:desilynks/widgets/custom_button.dart';

class MembershipPlansView extends StatelessWidget {
  const MembershipPlansView({super.key});

  void _showComingSoon(
    BuildContext context, {
    required String planName,
    String? svgIcon,
  }) {
    ComingSoonDialog.show(
      context,
      title: 'Coming Soon',
      featureName: '$planName Membership',
      svgIcon: svgIcon ?? AppIcons.crownSvg,
      badgeColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFD97706),
      message:
          '$planName plan subscription and checkout are currently under development. Stay tuned for upcoming plan upgrades and exclusive perks!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SubscriptionViewModel>(context);
    final bool isYearly = viewModel.isYearly;

    // Dynamic prices
    final String premiumPrice = isYearly ? '€7.99' : '€9.99';
    final String proPrice = isYearly ? '€15.99' : '€19.99';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 12),
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate800,
              BlendMode.srcIn,
            ),
            width: 22,
            height: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 8,
        title: Text(
          'Membership Plans',
          style: TextStyle(
            color: AppColors.slate800,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.slate200, height: 1.0),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
              vertical: (context.scaleH(24.0)).clamp(16.0, 28.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Logo/Crown & Titles
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: (context.scale(56)).clamp(48.0, 64.0),
                        height: (context.scale(56)).clamp(48.0, 64.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.orange, AppColors.accentYellow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.crownSvg,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            width: (context.scale(32)).clamp(26.0, 36.0),
                            height: (context.scale(32)).clamp(26.0, 36.0),
                          ),
                        ),
                      ),
                      SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),
                      Text(
                        'Choose Your Plan',
                        style: TextStyle(
                          color: AppColors.gray900,
                          fontSize: context.sp(22),
                          fontWeight: FontWeight.w800,
                          fontFamily: "Inter",
                        ),
                      ),
                      SizedBox(height: (context.scaleH(6)).clamp(4.0, 8.0)),
                      Text(
                        'Unlock more features and grow faster',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: context.sp(14),
                          fontFamily: "Inter",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (context.scaleH(24)).clamp(16.0, 28.0)),

                // 2. Billing Toggle Switch
                Center(child: _buildBillingToggle(context, viewModel)),
                SizedBox(height: (context.scaleH(28)).clamp(20.0, 32.0)),

                // 3. Plan Tier Cards
                // A. Basic Plan
                _buildPlanCard(
                  context: context,
                  isYearly: isYearly,
                  title: 'Basic',
                  subtitle: 'Free Forever',
                  price: '€0',
                  priceSuffix: '/mo',
                  svgIcon: AppIcons.personSvg,
                  iconColor: AppColors.gray500,
                  iconBgColor: AppColors.gray100,
                  isCurrentPlan: true,
                  benefits: [
                    {'text': '2 Active Ads', 'included': true},
                    {'text': '1 Photo per Ad', 'included': true},
                    {'text': 'Featured Ads', 'included': false},
                    {'text': 'Priority Support', 'included': false},
                  ],
                  buttonText: 'Current Plan',
                  buttonColor: AppColors.gray100,
                ),
                SizedBox(height: (context.scaleH(20)).clamp(14.0, 24.0)),

                // B. Premium Plan (Most Popular)
                _buildPlanCard(
                  context: context,
                  isYearly: isYearly,
                  title: 'Premium',
                  subtitle: 'Most popular choice',
                  price: premiumPrice,
                  priceSuffix: '/mo',
                  svgIcon: AppIcons.starFavoriteSvg,
                  iconColor: AppColors.vibrantBlue,
                  iconBgColor: AppColors.lightBlue,
                  isCurrentPlan: false,
                  benefits: [
                    {'text': '10 Active Ads', 'included': true},
                    {'text': '4 Photos per Ad', 'included': true},
                    {'text': 'Featured Listing', 'included': true},
                    {'text': 'Priority Support', 'included': true},
                  ],
                  buttonText: 'Get Premium',
                  buttonColor: AppColors.vibrantBlue,
                  borderColor: AppColors.vibrantBlue,
                  badgeText: '★ Most Popular',
                  badgeBgColor: AppColors.vibrantBlue,
                ),
                SizedBox(height: (context.scaleH(20)).clamp(14.0, 24.0)),

                // C. Pro Plan
                _buildPlanCard(
                  context: context,
                  isYearly: isYearly,
                  title: 'Pro',
                  subtitle: 'For power users',
                  price: proPrice,
                  priceSuffix: '/mo',
                  svgIcon: AppIcons.crownSvg,
                  iconColor: AppColors.secondaryPurple,
                  iconBgColor: AppColors.violetLight,
                  isCurrentPlan: false,
                  benefits: [
                    {'text': 'Unlimited Active Ads', 'included': true},
                    {'text': '10 Photos per Ad', 'included': true},
                    {'text': 'Featured Listing', 'included': true},
                    {'text': 'Priority Support', 'included': true},
                  ],
                  buttonText: 'Get Pro',
                  buttonColor: AppColors.secondaryPurple,
                  borderColor: AppColors.secondaryPurple,
                  badgeText: '👑 Pro',
                  badgeBgColor: AppColors.secondaryPurple,
                ),
                SizedBox(height: (context.scaleH(32)).clamp(20.0, 36.0)),

                // 4. Footer Icons Row
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: (context.scale(12)).clamp(8.0, 16.0),
                  runSpacing: 8,
                  children: [
                    _buildFooterIndicator(
                      context,
                      AppIcons.shield,
                      'Secure Payment',
                    ),
                    _buildFooterIndicator(
                      context,
                      AppIcons.restartSvg,
                      'Cancel Anytime',
                    ),
                    _buildFooterIndicator(
                      context,
                      AppIcons.supportSvg,
                      '24/7 Support',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingToggle(
    BuildContext context,
    SubscriptionViewModel viewModel,
  ) {
    final bool isYearly = viewModel.isYearly;
    return GestureDetector(
      onTap: () {
        viewModel.toggleBilling(!isYearly);
      },
      child: Container(
        width: (context.scale(240)).clamp(210.0, 280.0),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.slate100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // Monthly tab
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: (context.scaleH(8)).clamp(6.0, 10.0),
                ),
                decoration: BoxDecoration(
                  color: !isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: !isYearly
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Monthly',
                    style: TextStyle(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.bold,
                      color: !isYearly
                          ? AppColors.slate800
                          : AppColors.slate500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
            // Yearly tab
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: (context.scaleH(8)).clamp(6.0, 10.0),
                ),
                decoration: BoxDecoration(
                  color: isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isYearly
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Yearly',
                        style: TextStyle(
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.bold,
                          color: isYearly
                              ? AppColors.slate800
                              : AppColors.slate500,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-20%',
                          style: TextStyle(
                            color: AppColors.emerald,
                            fontSize: context.sp(9),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required bool isYearly,
    required String title,
    required String subtitle,
    required String price,
    required String priceSuffix,
    required String svgIcon,
    required Color iconColor,
    required Color iconBgColor,
    required bool isCurrentPlan,
    required List<Map<String, dynamic>> benefits,
    required String buttonText,
    required Color buttonColor,
    Color? borderColor,
    String badgeText = '',
    Color badgeBgColor = Colors.transparent,
  }) {
    final bool hasBadge = badgeText.isNotEmpty;
    final double iconBoxSize = (context.scale(40)).clamp(34.0, 46.0);
    final double svgSize = (context.scale(20)).clamp(16.0, 22.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isCurrentPlan
                ? null
                : () {
                    _showComingSoon(
                      context,
                      planName: title,
                      svgIcon: svgIcon,
                    );
                  },
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: borderColor != null
                    ? Border.all(color: borderColor, width: 2.0)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(context.cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            svgIcon,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                            width: svgSize,
                            height: svgSize,
                          ),
                        ),
                      ),
                      SizedBox(width: (context.scale(12)).clamp(8.0, 14.0)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: AppColors.gray900,
                                fontSize: context.sp(16),
                                fontWeight: FontWeight.bold,
                                fontFamily: "Inter",
                              ),
                            ),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: AppColors.gray400,
                                fontSize: context.sp(11),
                                fontFamily: "Inter",
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: TextStyle(
                              color: AppColors.gray900,
                              fontSize: context.sp(24),
                              fontWeight: FontWeight.w800,
                              fontFamily: "Inter",
                            ),
                          ),
                          Text(
                            priceSuffix,
                            style: TextStyle(
                              color: AppColors.gray500,
                              fontSize: context.sp(12),
                              fontFamily: "Inter",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),

                  const Divider(color: AppColors.gray100, height: 1),
                  SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),

                  // Benefits list
                  Column(
                    children: benefits.map((benefit) {
                      final bool included = benefit['included'];
                      final Color circleColor = included
                          ? (borderColor != null ? iconBgColor : AppColors.gray100)
                          : AppColors.softRed;
                      final Color itemIconColor = included
                          ? (borderColor ?? AppColors.gray500)
                          : AppColors.primaryRed;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: (context.scaleH(12.0)).clamp(8.0, 14.0),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: (context.scale(20)).clamp(18.0, 22.0),
                              height: (context.scale(20)).clamp(18.0, 22.0),
                              decoration: BoxDecoration(
                                color: circleColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  included
                                      ? AppIcons.tickSvg
                                      : AppIcons.crossSmallSvg,
                                  colorFilter: ColorFilter.mode(
                                    itemIconColor,
                                    BlendMode.srcIn,
                                  ),
                                  width: (context.scale(12)).clamp(10.0, 14.0),
                                  height: (context.scale(12)).clamp(10.0, 14.0),
                                ),
                              ),
                            ),
                            SizedBox(width: (context.scale(12)).clamp(8.0, 14.0)),
                            Expanded(
                              child: Text(
                                benefit['text'],
                                style: TextStyle(
                                  color: AppColors.gray600,
                                  fontSize: context.sp(13),
                                  fontFamily: "Inter",
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),

                  // Button
                  CustomButton(
                    text: buttonText,
                    onPressed: isCurrentPlan
                        ? null
                        : () {
                            _showComingSoon(
                              context,
                              planName: title,
                              svgIcon: svgIcon,
                            );
                          },
                    backgroundColor: isCurrentPlan
                        ? AppColors.slate200
                        : buttonColor,
                    textColor: isCurrentPlan ? AppColors.gray400 : Colors.white,
                    svgAsset: isCurrentPlan ? AppIcons.tickSvg : null,
                    height: (context.scaleH(48)).clamp(44.0, 52.0),
                    borderRadius: 14,
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Badges positioned top center
        if (hasBadge)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (context.scale(14)).clamp(10.0, 18.0),
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: badgeBgColor.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.bold,
                    fontFamily: "Inter",
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooterIndicator(
    BuildContext context,
    String svgIcon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgIcon,
          colorFilter: const ColorFilter.mode(
            AppColors.gray400,
            BlendMode.srcIn,
          ),
          width: 14,
          height: 14,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: AppColors.gray400,
            fontSize: context.sp(11),
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }
}
