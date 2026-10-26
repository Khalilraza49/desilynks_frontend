import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/marketplace/marketplace_viewmodel.dart';
import 'package:desilynks/models/product_ad_offer_model.dart';
import 'package:desilynks/views/chat/chat_detail_view.dart';
import 'package:desilynks/models/chat_model.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/coming_soon_dialog.dart';

class OfferItemData {
  final String id;
  final String storeName;
  final String discountDesc;
  final String validUntil;
  final String code;
  final String status;
  final String svgIcon;
  final Color iconColor;
  final Color iconBgColor;
  final Color statusBgColor;
  final Color statusTextColor;

  const OfferItemData({
    required this.id,
    required this.storeName,
    required this.discountDesc,
    required this.validUntil,
    required this.code,
    required this.status,
    required this.svgIcon,
    required this.iconColor,
    required this.iconBgColor,
    required this.statusBgColor,
    required this.statusTextColor,
  });
}

class MyOffersView extends StatefulWidget {
  const MyOffersView({super.key});

  @override
  State<MyOffersView> createState() => _MyOffersViewState();
}

class _MyOffersViewState extends State<MyOffersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showComingSoon(context);
      final marketplaceVM = Provider.of<MarketplaceViewModel>(context, listen: false);
      if (!marketplaceVM.hasFetchedMySentOffers && !marketplaceVM.isLoading) {
        marketplaceVM.fetchMySentOffers();
      }
    });
  }

  static const List<OfferItemData> _activeOffers = [
    OfferItemData(
      id: 'o1',
      storeName: 'Desi Mart Barcelona',
      discountDesc: '10% OFF on all groceries',
      validUntil: 'Valid till 31 Dec 2025',
      code: 'DESI-4F8K9P',
      status: 'Active',
      svgIcon: AppIcons.shopingSvg,
      iconColor: Colors.white,
      iconBgColor: Color(0xFF047857),
      statusBgColor: Color(0xFFDCFCE7),
      statusTextColor: Color(0xFF10B981),
    ),
    OfferItemData(
      id: 'o2',
      storeName: 'Punjabi Restaurant',
      discountDesc: '15% OFF on food orders',
      validUntil: 'Valid till 20 Dec 2025',
      code: 'PUNJ-509K2M',
      status: 'Active',
      svgIcon: AppIcons.spoonForkSvg,
      iconColor: Colors.white,
      iconBgColor: Color(0xFF78350F),
      statusBgColor: Color(0xFFDCFCE7),
      statusTextColor: Color(0xFF10B981),
    ),
    OfferItemData(
      id: 'o3',
      storeName: 'ABC Travel Agency',
      discountDesc: '5% OFF on tour packages',
      validUntil: 'Valid till 15 Dec 2025',
      code: 'TRVL-3H7J1N',
      status: 'Active',
      svgIcon: AppIcons.planeSvg,
      iconColor: Colors.white,
      iconBgColor: Color(0xFF1D4ED8),
      statusBgColor: Color(0xFFDCFCE7),
      statusTextColor: Color(0xFF10B981),
    ),
  ];

  static const List<OfferItemData> _usedOffers = [
    OfferItemData(
      id: 'o4',
      storeName: 'Spain Village Restaurant',
      discountDesc: '20% OFF on total bill',
      validUntil: 'Used on 12 Jan 2025',
      code: 'SPAIN-99X21',
      status: 'Used',
      svgIcon: AppIcons.spoonForkSvg,
      iconColor: Colors.white,
      iconBgColor: Color(0xFF64748B),
      statusBgColor: Color(0xFFF1F5F9),
      statusTextColor: Color(0xFF64748B),
    ),
    OfferItemData(
      id: 'o5',
      storeName: 'Kashmir Electronics',
      discountDesc: '10% OFF on accessories',
      validUntil: 'Used on 05 Jan 2025',
      code: 'KASH-7711B',
      status: 'Used',
      svgIcon: AppIcons.mobile,
      iconColor: Colors.white,
      iconBgColor: Color(0xFF64748B),
      statusBgColor: Color(0xFFF1F5F9),
      statusTextColor: Color(0xFF64748B),
    ),
  ];

  static const List<OfferItemData> _expiredOffers = [
    OfferItemData(
      id: 'o6',
      storeName: 'Super Store Madrid',
      discountDesc: '12% OFF on electronics',
      validUntil: 'Expired on 01 Jan 2025',
      code: 'EXPIRE-001',
      status: 'Expired',
      svgIcon: AppIcons.shopSvg,
      iconColor: Colors.white,
      iconBgColor: Color(0xFF94A3B8),
      statusBgColor: Color(0xFFFEE2E2),
      statusTextColor: Color(0xFFEF4444),
    ),
    OfferItemData(
      id: 'o7',
      storeName: 'Karachi Sweets',
      discountDesc: '25% OFF on sweets box',
      validUntil: 'Expired on 15 Dec 2024',
      code: 'EXPIRE-002',
      status: 'Expired',
      svgIcon: AppIcons.spoonForkSvg,
      iconColor: Colors.white,
      iconBgColor: Color(0xFF94A3B8),
      statusBgColor: Color(0xFFFEE2E2),
      statusTextColor: Color(0xFFEF4444),
    ),
  ];

  List<OfferItemData> _getCurrentList(int selectedTabIndex) {
    if (selectedTabIndex == 1) return _usedOffers;
    if (selectedTabIndex == 2) return _expiredOffers;
    return _activeOffers;
  }

  void _showComingSoon(BuildContext context) {
    ComingSoonDialog.show(
      context,
      title: 'Coming Soon',
      featureName: 'My Offers',
      message:
          'My Offers & personalized discounts are currently under development. Soon you will be able to access, apply, and manage exclusive brand offers and vouchers!',
    );
  }

  @override
  Widget build(BuildContext context) {

    final marketplaceVM = Provider.of<MarketplaceViewModel>(context);

    final selectedTabIndex = marketplaceVM.myOffersTabIndex;
    final sentOffers = marketplaceVM.mySentOffers;
    final currentList = _getCurrentList(selectedTabIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppColors.slate900,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'My Offers',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: 18,
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
              // 1. Top Tab Selection Bar
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: context.hMargin),
                child: Row(
                  children: [
                    _buildTabItem(
                      context,
                      marketplaceVM,
                      0,
                      'Active (${_activeOffers.length + sentOffers.length})',
                    ),
                    _buildTabItem(
                      context,
                      marketplaceVM,
                      1,
                      'Used (${_usedOffers.length})',
                    ),
                    _buildTabItem(
                      context,
                      marketplaceVM,
                      2,
                      'Expired (${_expiredOffers.length})',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // 2. Scrollable Offers List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.hMargin,
                    vertical: context.scaleH(16),
                  ),
                  children: [
                    if (selectedTabIndex == 0 &&
                        sentOffers.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Your Sent Purchase Offers',
                          style: TextStyle(
                            fontSize: context.sp(16),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      ...sentOffers.map(
                        (offer) => _buildSentOfferCard(context, offer),
                      ),
                      SizedBox(height: context.scaleH(16)),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Available Deals & Coupons',
                          style: TextStyle(
                            fontSize: context.sp(16),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                    ...currentList.map((offer) => _buildOfferCard(context, offer)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentOfferCard(BuildContext context, ProductAdOfferModel offer) {
    Color statusBgColor = const Color(0xFFFEF3C7);
    Color statusTextColor = const Color(0xFFD97706);

    if (offer.isAccepted) {
      statusBgColor = const Color(0xFFDCFCE7);
      statusTextColor = const Color(0xFF10B981);
    } else if (offer.isRejected) {
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFEF4444);
    }

    final avatarRadius = context.scale(22.0);

    return Padding(
      padding: EdgeInsets.only(bottom: context.scaleH(14)),
      child: Container(
        padding: EdgeInsets.all(context.cardPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: offer.isRejected
                ? const Color(0xFFFCA5A5)
                : const Color(0xFFF1F5F9),
            width: offer.isRejected ? 1.5 : 1.2,
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
            Row(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: offer.sellerAvatar.isNotEmpty
                      ? NetworkImage(offer.sellerAvatar)
                      : null,
                  child: offer.sellerAvatar.isEmpty
                      ? SvgPicture.asset(
                          AppIcons.shopSvg,
                          width: avatarRadius,
                          height: avatarRadius,
                          colorFilter: const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.srcIn,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: context.scale(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.adTitle.isNotEmpty
                            ? offer.adTitle
                            : 'Product Ad Offer',
                        style: TextStyle(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Seller: ${offer.sellerName}',
                        style: TextStyle(
                          fontSize: context.sp(12.5),
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(10),
                    vertical: context.scaleH(4),
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    offer.statusDisplay,
                    style: TextStyle(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.bold,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.scaleH(12)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.scale(12)),
              decoration: BoxDecoration(
                color: offer.isRejected
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offered Price:',
                        style: TextStyle(
                          fontSize: context.sp(12),
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        offer.offerPrice,
                        style: TextStyle(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final conv = ChatConversationModel(
                        id: '',
                        otherParticipant: ChatParticipantModel(
                          id: offer.sellerId,
                          firstName: offer.sellerName,
                          lastName: '',
                          profilePhotoUrl: offer.sellerAvatar.isNotEmpty
                              ? offer.sellerAvatar
                              : null,
                        ),
                        updatedAt: DateTime.now(),
                        createdAt: DateTime.now(),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailView(conversation: conv),
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      AppIcons.chatRoundSvg,
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      'Chat with Seller',
                      style: TextStyle(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scale(12),
                        vertical: context.scaleH(8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    MarketplaceViewModel vm,
    int index,
    String label,
  ) {
    final isSelected = vm.myOffersTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          vm.setMyOffersTabIndex(index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.scaleH(14)),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(14),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, OfferItemData offer) {
    final bool isActionable = offer.status == 'Active';
    final iconBoxSize = context.scale(48.0);
    final iconSize = context.scale(24.0);
    final buttonHeight = context.scaleH(40.0);

    return Padding(
      padding: EdgeInsets.only(bottom: context.scaleH(14)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section (Logo, Store Name, Subtitle, Status Badge)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Icon Box
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: offer.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      offer.svgIcon,
                      width: iconSize,
                      height: iconSize,
                      colorFilter: ColorFilter.mode(
                        offer.iconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.scale(12)),

                // Store Title & Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.storeName,
                        style: TextStyle(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        offer.discountDesc,
                        style: TextStyle(
                          fontSize: context.sp(12.5),
                          color: const Color(0xFF64748B),
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.TimerSvg,
                            width: 13,
                            height: 13,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF94A3B8),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            offer.validUntil,
                            style: TextStyle(
                              fontSize: context.sp(11.5),
                              color: const Color(0xFF94A3B8),
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Status Badge Tag
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(10),
                    vertical: context.scaleH(4),
                  ),
                  decoration: BoxDecoration(
                    color: offer.statusBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    offer.status,
                    style: TextStyle(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.bold,
                      color: offer.statusTextColor,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: context.scaleH(14)),

            // Bottom Section (Dashed Coupon Code + Copy + Use Buttons)
            Row(
              children: [
                // Dashed Code Container
                Expanded(
                  child: CustomPaint(
                    painter: DashedRectPainter(
                      color: const Color(0xFFCBD5E1),
                      strokeWidth: 1.2,
                      gap: 4,
                    ),
                    child: Container(
                      height: buttonHeight,
                      alignment: Alignment.center,
                      child: Text(
                        offer.code,
                        style: TextStyle(
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.bold,
                          color: isActionable
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF94A3B8),
                          letterSpacing: 1.2,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: context.scale(10)),

                // Copy Button
                SizedBox(
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: isActionable
                        ? () {
                            _showComingSoon(context);
                          }
                        : null,
                    icon: SvgPicture.asset(
                      AppIcons.restartSvg,
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      'Copy',
                      style: TextStyle(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scale(14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: context.scale(8)),

                // Use Button
                SizedBox(
                  height: buttonHeight,
                  child: OutlinedButton(
                    onPressed: isActionable
                        ? () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.dealDetails,
                              arguments: {
                                'storeName': offer.storeName,
                                'discountTitle': offer.discountDesc,
                                'discountTag': offer.discountDesc.contains('%')
                                    ? offer.discountDesc.split(' ').first
                                    : 'OFFER',
                              },
                            );
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scale(16),
                      ),
                      side: BorderSide(
                        color: isActionable
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFCBD5E1),
                        width: 1.3,
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
                        color: isActionable
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                        fontFamily: AppStrings.fontInter,
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
}

// Custom Painter for Dashed Rectangle Border
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(10),
        ),
      );

    final Path dashPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
