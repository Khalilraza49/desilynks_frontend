import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/profile/subscription_viewmodel.dart';
import 'package:desilynks/widgets/coming_soon_dialog.dart';
import 'package:desilynks/widgets/custom_text_field.dart';

class CouponItemData {
  final String code;
  final String discountTag;
  final String description;
  final String validUntil;
  final String icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color badgeBgColor;
  final Color badgeTextColor;

  const CouponItemData({
    required this.code,
    required this.discountTag,
    required this.description,
    required this.validUntil,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.badgeBgColor,
    required this.badgeTextColor,
  });
}

class CouponsView extends StatelessWidget {
  const CouponsView({super.key});

  static const List<CouponItemData> _availableCoupons = [
    CouponItemData(
      code: 'WELCOME20',
      discountTag: '20% OFF',
      description: '20% off on any Premium Plan',
      validUntil: 'Valid till 31 May 2024',
      icon: AppIcons.TagSvg,
      iconColor: Color(0xFF8B5CF6),
      iconBgColor: Color(0xFFF3E8FF),
      badgeBgColor: Color(0xFFD1FAE5),
      badgeTextColor: Color(0xFF059669),
    ),
    CouponItemData(
      code: 'PREMIUM10',
      discountTag: '10% OFF',
      description: '10% off on Premium Plan',
      validUntil: 'Valid till 15 Jun 2024',
      icon: AppIcons.TagSvg,
      iconColor: Color(0xFFF97316),
      iconBgColor: Color(0xFFFFEDD5),
      badgeBgColor: Color(0xFFFEF3C7),
      badgeTextColor: Color(0xFFD97706),
    ),
    CouponItemData(
      code: 'GOLD15',
      discountTag: '15% OFF',
      description: '15% off on Golden Plan',
      validUntil: 'Valid till 30 Jun 2024',
      icon: AppIcons.TagSvg,
      iconColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFDCFCE7),
      badgeBgColor: Color(0xFFDBEAFE),
      badgeTextColor: Color(0xFF2563EB),
    ),
    CouponItemData(
      code: 'FIRST50',
      discountTag: '50% OFF',
      description: '50% off for first time users',
      validUntil: 'Valid till 10 May 2024',
      icon: AppIcons.TagSvg,
      iconColor: Color(0xFFEF4444),
      iconBgColor: Color(0xFFFEE2E2),
      badgeBgColor: Color(0xFFFFE4E6),
      badgeTextColor: Color(0xFFE11D48),
    ),
  ];

  void _showComingSoon(BuildContext context, {String? couponCode}) {
    ComingSoonDialog.show(
      context,
      title: 'Coming Soon',
      featureName: 'Coupons & Discounts',
      message: couponCode != null && couponCode.isNotEmpty
          ? 'Coupon code "${couponCode.toUpperCase()}" is part of our upcoming discount system. Coupon redemptions will be available very soon!'
          : 'Coupons & discounts system is currently under development. Stay tuned for upcoming promotional offers and discounts!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final subViewModel = Provider.of<SubscriptionViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
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
          'Coupons',
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
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: (context.scale(18)).clamp(14.0, 20.0),
              vertical: (context.scaleH(5)).clamp(7.0, 14.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Enter Coupon Code & Apply Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: subViewModel.couponInputController,
                        hintText: 'Enter coupon code',
                        fontSize: context.sp(14),
                        padding: EdgeInsets.symmetric(
                          horizontal: (context.scale(16)).clamp(12.0, 18.0),
                          vertical: (context.scaleH(13.5)).clamp(11.0, 15.0),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: (context.scale(12)).clamp(8.0, 14.0)),
                    SizedBox(
                      height: (context.scaleH(48)).clamp(44.0, 52.0),
                      child: ElevatedButton(
                        onPressed: () {
                          final text = subViewModel.couponInputController.text
                              .trim();
                          _showComingSoon(
                            context,
                            couponCode: text.isNotEmpty ? text : null,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: (context.scale(24)).clamp(18.0, 28.0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Apply',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(14.5),
                            fontWeight: FontWeight.bold,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: (context.scaleH(24)).clamp(18.0, 28.0)),

                // 2. Section Header
                Text(
                  'Available Coupons',
                  style: TextStyle(
                    fontSize: context.sp(16.5),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),

                SizedBox(height: (context.scaleH(16)).clamp(12.0, 18.0)),

                // 3. Available Coupons List
                ..._availableCoupons.map(
                  (coupon) => _buildCouponCard(context, subViewModel, coupon),
                ),

                SizedBox(height: (context.scaleH(24)).clamp(16.0, 32.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponCard(
    BuildContext context,
    SubscriptionViewModel subViewModel,
    CouponItemData coupon,
  ) {
    final double iconBoxSize = (context.scale(48)).clamp(40.0, 52.0);
    final double svgSize = (context.scale(22)).clamp(18.0, 24.0);

    return Padding(
      padding: EdgeInsets.only(
        bottom: (context.scaleH(14.0)).clamp(12.0, 16.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            subViewModel.couponInputController.text = coupon.code;
            _showComingSoon(context, couponCode: coupon.code);
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: EdgeInsets.all(context.cardPad),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
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
                // Left Tag Icon Container
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: coupon.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      coupon.icon,
                      colorFilter: ColorFilter.mode(
                        coupon.iconColor,
                        BlendMode.srcIn,
                      ),
                      height: svgSize,
                      width: svgSize,
                    ),
                  ),
                ),
                SizedBox(width: (context.scale(14)).clamp(12.0, 16.0)),

                // Coupon Code, Badge & Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              coupon.code,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: context.sp(15),
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: (context.scale(8)).clamp(6.0, 10.0),
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: coupon.badgeBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              coupon.discountTag,
                              style: TextStyle(
                                fontSize: context.sp(10.5),
                                fontWeight: FontWeight.bold,
                                color: coupon.badgeTextColor,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.sp(12.5),
                          color: const Color(0xFF64748B),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        coupon.validUntil,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.sp(11.5),
                          color: const Color(0xFF94A3B8),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: (context.scale(10)).clamp(8.0, 14.0)),

                // Use Button
                SizedBox(
                  height: (context.scaleH(36)).clamp(34.0, 40.0),
                  child: ElevatedButton(
                    onPressed: () {
                      subViewModel.couponInputController.text = coupon.code;
                      _showComingSoon(context, couponCode: coupon.code);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: (context.scale(18)).clamp(14.0, 22.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Use',
                      style: TextStyle(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
