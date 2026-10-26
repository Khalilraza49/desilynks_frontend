import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:desilynks/viewmodels/promotions/deals_discounts_viewmodel.dart';
import 'package:desilynks/core/utils/app_share_helper.dart';

class DealDetailsView extends StatelessWidget {
  final String? storeName;
  final String? category;
  final String? rating;
  final String? reviewCount;
  final String? discountTitle;
  final String? discountTag;
  final String? membershipEligibility;
  final String? validUntil;
  final String? location;
  final String? minSpend;
  final String? detailsText;
  final List<String>? redeemSteps;
  final String? imageUrl;
  final String? phoneNumber;
  final String? destinationLink;
  final String? bannerAdId;

  const DealDetailsView({
    super.key,
    this.storeName,
    this.category,
    this.rating,
    this.reviewCount,
    this.discountTitle,
    this.discountTag,
    this.membershipEligibility,
    this.validUntil,
    this.location,
    this.minSpend,
    this.detailsText,
    this.redeemSteps,
    this.imageUrl,
    this.phoneNumber,
    this.destinationLink,
    this.bannerAdId,
  });

  @override
  Widget build(BuildContext context) {

    // Default values matching the design mock if parameters are omitted
    final displayStoreName = storeName ?? 'Pak Madrid Restaurant';
    final displayCategory = category ?? 'Pakistani & Indian Cuisine';
    final displayRating = rating ?? '4.5';
    final displayReviewCount = reviewCount ?? '220';
    final displayDiscountTitle = discountTitle ?? '20% OFF on All Dishes';
    final displayDiscountTag = discountTag ?? '20% OFF';
    final displayEligibility =
        membershipEligibility ?? 'For Premium & Golden Members';
    final displayValidUntil = validUntil ?? '31 May 2024';
    final displayLocation = location ?? 'Madrid, Spain';
    final displayMinSpend = minSpend ?? 'Min. €20';
    final displayDetailsText =
        detailsText ??
        'Get 20% off on all dishes at Pak Madrid Restaurant. Valid for dine-in and takeaway. Cannot be combined with other promotions.';
    final displayRedeemSteps =
        redeemSteps ??
        const [
          'Visit the restaurant',
          'Show this coupon to staff before payment',
          'Get your discount',
        ];
    final displayImageUrl =
        imageUrl ??
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=800';

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Deal Details',
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
              AppIcons.shareSvg,
              width: context.scale(18),
              height: context.scale(18),
              colorFilter: const ColorFilter.mode(
                AppColors.slate900,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              AppShareHelper.shareAsLink(
                context: context,
                type: ShareItemType.general,
                id: displayStoreName.replaceAll(' ', '-').toLowerCase(),
                title: displayDiscountTitle,
                description: '$displayStoreName • $displayLocation',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Hero Image Header with Tag
                      Stack(
                        children: [
                          Container(
                            height: context.scaleH(210),
                            width: double.infinity,
                            color: const Color(0xFF1E293B),
                            child: Image.network(
                              displayImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                height: context.scaleH(210),
                                color: const Color(0xFF334155),
                                child: Center(
                                  child: SvgPicture.asset(
                                    AppIcons.spoonForkSvg,
                                    width: context.scale(50),
                                    height: context.scale(50),
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white54,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Top Right Discount Badge Tag
                          Positioned(
                            top: context.scaleH(14),
                            right: context.scale(14),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.scale(14),
                                vertical: context.scaleH(7),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                displayDiscountTag,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.sp(12.5),
                                  fontWeight: FontWeight.w800,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 2. Merchant Info Row
                      Padding(
                        padding: EdgeInsets.all(context.scale(16.0)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Store Icon Container
                            Container(
                              width: context.scale(52),
                              height: context.scale(52),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  AppIcons.spoonForkSvg,
                                  width: context.scale(26),
                                  height: context.scale(26),
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF334155),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: context.scale(14)),
                            // Store Title & Meta
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayStoreName,
                                    style: TextStyle(
                                      fontSize: context.sp(17),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate900,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                  SizedBox(height: context.scaleH(2)),
                                  Text(
                                    displayCategory,
                                    style: TextStyle(
                                      fontSize: context.sp(13),
                                      color: const Color(0xFF64748B),
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                  SizedBox(height: context.scaleH(4)),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        AppIcons.starFavorite1499Svg,
                                        width: context.scale(15),
                                        height: context.scale(15),
                                        colorFilter: const ColorFilter.mode(
                                          Colors.amber,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      SizedBox(width: context.scale(4)),
                                      Text(
                                        displayRating,
                                        style: TextStyle(
                                          fontSize: context.sp(13),
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.slate900,
                                          fontFamily: AppStrings.fontInter,
                                        ),
                                      ),
                                      SizedBox(width: context.scale(4)),
                                      Text(
                                        '($displayReviewCount)',
                                        style: TextStyle(
                                          fontSize: context.sp(13),
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

                      // 3. Pink Highlight Coupon Card
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.hMargin,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(context.scale(16)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFD1D7),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayDiscountTitle,
                                style: TextStyle(
                                  fontSize: context.sp(18),
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFDC2626),
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              SizedBox(height: context.scaleH(4)),
                              Text(
                                displayEligibility,
                                style: TextStyle(
                                  fontSize: context.sp(13),
                                  color: const Color(0xFFF43F5E),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              SizedBox(height: context.scaleH(14)),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildInfoChip(
                                      context,
                                      AppIcons.calendarSvg,
                                      displayValidUntil,
                                    ),
                                    SizedBox(width: context.scale(14)),
                                    _buildInfoChip(
                                      context,
                                      AppIcons.locationSvg,
                                      displayLocation,
                                    ),
                                    SizedBox(width: context.scale(14)),
                                    _buildInfoChip(
                                      context,
                                      AppIcons.shopSvg,
                                      displayMinSpend,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: context.scaleH(16)),

                      // 4. Details Section Card
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.hMargin,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(context.scale(16)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Details',
                                style: TextStyle(
                                  fontSize: context.sp(15.5),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.slate900,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              SizedBox(height: context.scaleH(10)),
                              Text(
                                displayDetailsText,
                                style: TextStyle(
                                  fontSize: context.sp(13.5),
                                  color: const Color(0xFF475569),
                                  height: 1.45,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: context.scaleH(14)),

                      // 5. How to Redeem Card
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.hMargin,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(context.scale(16)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How to Redeem',
                                style: TextStyle(
                                  fontSize: context.sp(15.5),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.slate900,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              SizedBox(height: context.scaleH(12)),
                              ...displayRedeemSteps.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key + 1;
                                final step = entry.value;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: context.scaleH(8.0),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$idx.  ',
                                        style: TextStyle(
                                          fontSize: context.sp(13.5),
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2563EB),
                                          fontFamily: AppStrings.fontInter,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          step,
                                          style: TextStyle(
                                            fontSize: context.sp(13.5),
                                            color: const Color(0xFF475569),
                                            height: 1.35,
                                            fontFamily: AppStrings.fontInter,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: context.scaleH(20)),
                    ],
                  ),
                ),
              ),

              // 6. Fixed Bottom Action Buttons
              SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.hMargin,
                    vertical: context.scaleH(12),
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Call Store Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Calling ${phoneNumber ?? displayStoreName}...',
                                ),
                              ),
                            );
                          },
                          icon: SvgPicture.asset(
                            AppIcons.callSvg,
                            width: context.scale(18),
                            height: context.scale(18),
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF334155),
                              BlendMode.srcIn,
                            ),
                          ),
                          label: Text(
                            'Call Store',
                            style: TextStyle(
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: context.scaleH(13),
                            ),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.scale(12)),

                      // Directions / Visit Link Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final hasLink =
                                destinationLink != null &&
                                destinationLink!.trim().isNotEmpty;
                            if (hasLink) {
                              if (bannerAdId != null) {
                                try {
                                  context
                                      .read<DealsDiscountsViewModel>()
                                      .recordClick(bannerAdId!);
                                } catch (_) {}
                              }
                              final uri = Uri.tryParse(destinationLink!);
                              if (uri != null && await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Opening $destinationLink...',
                                      ),
                                    ),
                                  );
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Opening directions to $displayLocation...',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: SvgPicture.asset(
                            destinationLink != null &&
                                    destinationLink!.trim().isNotEmpty
                                ? AppIcons.shareSvg
                                : AppIcons.locationSvg,
                            width: context.scale(18),
                            height: context.scale(18),
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: Text(
                            destinationLink != null &&
                                    destinationLink!.trim().isNotEmpty
                                ? (discountTag ?? 'Visit Store')
                                : 'Directions',
                            style: TextStyle(
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: context.scaleH(13),
                            ),
                            backgroundColor: const Color(0xFF2563EB),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: context.scale(15),
          height: context.scale(15),
          colorFilter: const ColorFilter.mode(
            Color(0xFF64748B),
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: context.scale(4)),
        Text(
          text,
          style: TextStyle(
            fontSize: context.sp(12),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ],
    );
  }
}
