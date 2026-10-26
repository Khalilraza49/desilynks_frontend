import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/models/marketplace_item_model.dart';
import 'package:desilynks/viewmodels/marketplace/marketplace_viewmodel.dart';
import 'package:desilynks/viewmodels/chat/chat_viewmodel.dart';
import 'package:desilynks/models/chat_model.dart';
import 'package:desilynks/views/chat/chat_detail_view.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/favourite_ads_viewmodel.dart';
import 'package:desilynks/core/utils/app_share_helper.dart';

class MarketplaceItemDetailView extends StatelessWidget {
  final MarketplaceItemModel item;

  const MarketplaceItemDetailView({super.key, required this.item});

  void _makePhoneCall(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling seller at $phone...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openChatWithSeller(BuildContext context, MarketplaceItemModel activeItem) {
    final sellerId = activeItem.sellerId;
    if (sellerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot initiate chat: Seller details missing.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final conv = ChatConversationModel(
      id: 'market_${activeItem.id}_$sellerId',
      otherParticipant: ChatParticipantModel(
        id: sellerId,
        firstName: activeItem.sellerName.isNotEmpty
            ? activeItem.sellerName
            : 'Seller',
        lastName: '',
        profilePhotoUrl: activeItem.sellerAvatar,
      ),
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatDetailView(conversation: conv)),
    );
  }

  void _showMakeOfferDialog(BuildContext context, MarketplaceItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MakeOfferView(item: item)),
    );
  }

  void _openFullScreenImageViewer(
    BuildContext context,
    List<ProductPhoto> photos,
    int initialIndex,
    MarketplaceViewModel viewModel,
  ) {
    if (photos.isEmpty) return;

    final pageController = PageController(initialPage: initialIndex);
    final ValueNotifier<int> currentIndexNotifier =
        ValueNotifier<int>(initialIndex);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Zoomable & Swipeable PageView
              PageView.builder(
                controller: pageController,
                itemCount: photos.length,
                onPageChanged: (idx) {
                  currentIndexNotifier.value = idx;
                  viewModel.setSinglePropertyPageIndex(idx);
                  if (viewModel.singlePropertyPageController.hasClients) {
                    viewModel.singlePropertyPageController.jumpToPage(idx);
                  }
                },
                itemBuilder: (context, idx) {
                  final imageUrl = viewModel.resolvePropertyImageUrl(
                    photos[idx].url,
                    fallback:
                        'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
                  );
                  return InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.slate900,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Top Bar with Back Button and Counter Badge
              Positioned(
                top: MediaQuery.of(ctx).padding.top + 10,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          AppIcons.arrowBackSvg,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    if (photos.length > 1)
                      ValueListenableBuilder<int>(
                        valueListenable: currentIndexNotifier,
                        builder: (ctx, currentIdx, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${currentIdx + 1} / ${photos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MarketplaceViewModel>(context);
    final favViewModel = Provider.of<FavouriteAdsViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    if (viewModel.activeProduct?.id != item.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        viewModel.initProductDetail(item);
      });
    }

    final activeProperty = viewModel.activeProduct?.id == item.id
        ? viewModel.activeProduct!
        : item;
    final activeItem = activeProperty;

    final bool isLiked = favViewModel.isFavourited(activeProperty.id) ||
        viewModel.isPropertyLiked(activeProperty.id);

    final photos = activeProperty.photos.isNotEmpty
        ? activeProperty.photos
        : (activeProperty.photoUrls.isNotEmpty
            ? activeProperty.photoUrls
                .map((u) => ProductPhoto(id: '', url: u))
                .toList()
            : (activeProperty.imageUrl.isNotEmpty
                ? [ProductPhoto(id: '', url: activeProperty.imageUrl)]
                : <ProductPhoto>[]));
    final totalPhotos = photos.isNotEmpty ? photos.length : 1;
    final currentPage = viewModel.singlePropertyPageIndex;

    // Format post date
    final String postTimeAgo = viewModel.getTimeAgo(activeProperty.createdAt);

    // Fetch seller profile through ViewModel if not already loaded
    if (activeItem.sellerId.isNotEmpty &&
        !viewModel.isSellerChecked(activeItem.sellerId) &&
        !viewModel.isLoadingSeller) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        viewModel.fetchSellerProfile(
          activeItem.sellerId,
          authViewModel: authViewModel,
        );
      });
    }

    final String sellerName = viewModel.resolveSellerName(activeItem);
    final String sellerAvatar = viewModel.resolveSellerAvatar(activeItem);
    final String sellerMemberSince = viewModel.resolveSellerMemberSince(activeItem);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Image Stack Header
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: photos.isNotEmpty
                      ? PageView.builder(
                          controller: viewModel.singlePropertyPageController,
                          onPageChanged: (int page) {
                            viewModel.setSinglePropertyPageIndex(page);
                          },
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            final imageUrl = viewModel.resolvePropertyImageUrl(
                              photos[index].url,
                              fallback:
                                  'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
                            );
                            return GestureDetector(
                              onTap: () => _openFullScreenImageViewer(
                                context,
                                photos,
                                index,
                                viewModel,
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: AppColors.slate100,
                                  child: SvgPicture.asset(
                                    AppIcons.gallerySvg,
                                    width: 60,
                                    height: 60,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.gray500,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.slate100,
                          child: SvgPicture.asset(
                            AppIcons.gallerySvg,
                            width: 60,
                            height: 60,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gray500,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                ),

                // Back Button (Top Left)
                Positioned(
                  left: 20,
                  top: MediaQuery.of(context).padding.top + 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.arrowBackSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),

                // Top Right Action Buttons (Heart and Share)
                Positioned(
                  right: 20,
                  top: MediaQuery.of(context).padding.top + 10,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final newStatus =
                              await viewModel.toggleSinglePropertyLike(
                            activeProperty,
                            favViewModel,
                          );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newStatus
                                    ? 'Added to Favourite Ads'
                                    : 'Removed from Favourite Ads',
                              ),
                              duration: const Duration(seconds: 2),
                              action: newStatus
                                  ? SnackBarAction(
                                      label: 'View',
                                      textColor: AppColors.accentYellow,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.favouriteAds,
                                        );
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.favSvg,
                            colorFilter: ColorFilter.mode(
                              isLiked
                                  ? AppColors.primaryRed
                                  : AppColors.white,
                              BlendMode.srcIn,
                            ),
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Share Button
                      GestureDetector(
                        onTap: () {
                          AppShareHelper.shareAsLink(
                            context: context,
                            type: ShareItemType.marketplace,
                            id: activeItem.id,
                            title: activeItem.title,
                            subtitle: '€${activeItem.price} · ${activeItem.location}',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.shareSvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Blue Tag Overlay (Bottom Left): "Posted X hours ago"
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vibrantBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      postTimeAgo,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: AppConstants.fontSizeSM,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Photo Counter Overlay (Bottom Right): "1/6"
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => _openFullScreenImageViewer(
                      context,
                      photos,
                      currentPage,
                      viewModel,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${currentPage + 1}/$totalPhotos',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: AppConstants.fontSizeXS11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Main Details Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.hMargin,
                vertical: (context.scaleH(18.0)).clamp(14.0, 22.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    activeItem.title,
                    style: TextStyle(
                      fontSize: context.sp(22),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Price Row & Negotiable Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activeItem.price,
                        style: TextStyle(
                          fontSize: context.sp(22),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      if (activeItem.isNegotiable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Negotiable',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 3. Key Specifications Card (2x2 Grid)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.blackOpacity4,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecTile(
                                context,
                                label: 'Condition',
                                value: activeItem.condition ?? 'N/A',
                              ),
                            ),
                            Expanded(
                              child: _buildSpecTile(
                                context,
                                label: 'Category',
                                value: activeItem.category,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecTile(
                                context,
                                label: 'Location',
                                value: activeItem.location,
                              ),
                            ),
                            Expanded(
                              child: _buildSpecTile(
                                context,
                                label: 'Brand',
                                value: activeItem.brand ?? 'Apple',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4. Description Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.blackOpacity4,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeItem.description.isEmpty
                              ? 'No description provided.'
                              : activeItem.description,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.slate600,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 5. Seller Info Card
                  GestureDetector(
                    onTap: () {
                      final owner = viewModel.resolveSellerOwner(activeItem);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.publicProfile,
                        arguments: owner,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.blackOpacity4,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(sellerAvatar),
                            backgroundColor: AppColors.slate200,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sellerName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      AppIcons.starFavoriteSvg,
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xFFF59E0B),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      activeItem.sellerRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.slate800,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${activeItem.sellerReviewCount} reviews · Member since $sellerMemberSince',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.slate500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(AppIcons.arrowDropDownSvg),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),

      // 6. Fixed Bottom Action Buttons Bar ("Call", "WhatsApp", "Make Offer")
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.hMargin,
            vertical: (context.scaleH(12.0)).clamp(8.0, 16.0),
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.blackOpacity4,
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Call Button (Outlined)
              Expanded(
                child: SizedBox(
                  height: (context.scaleH(46.0)).clamp(42.0, 52.0),
                  child: OutlinedButton(
                    onPressed: () => _makePhoneCall(context, activeItem.sellerPhone),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.slate300,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Call',
                        style: TextStyle(
                          color: AppColors.slate900,
                          fontSize: context.sp(14.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Chat Button (Vibrant Indigo)
              Expanded(
                child: SizedBox(
                  height: (context.scaleH(46.0)).clamp(42.0, 52.0),
                  child: ElevatedButton(
                    onPressed: () => _openChatWithSeller(context, activeItem),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(14.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Make Offer Button (Vibrant Blue)
              Expanded(
                child: SizedBox(
                  height: (context.scaleH(46.0)).clamp(42.0, 52.0),
                  child: ElevatedButton(
                    onPressed: () => _showMakeOfferDialog(context, activeItem),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Make Offer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(14.5),
                          fontWeight: FontWeight.bold,
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

  Widget _buildSpecTile(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.sp(12),
            color: AppColors.slate400,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: context.sp(14),
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// Make an Offer — Full Screen View
// ================================================================

class MakeOfferView extends StatelessWidget {
  final MarketplaceItemModel item;

  const MakeOfferView({super.key, required this.item});

  Future<void> _sendOffer(BuildContext context, MarketplaceViewModel vm) async {
    final price = vm.offerPriceController.text.trim();
    if (price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an offer amount'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final success = await vm.submitMakeOffer(item.id);

      if (!context.mounted) return;

      if (success) {
        if (item.sellerId.isNotEmpty) {
          final chatVM = context.read<ChatViewModel>();
          chatVM.sendMessage(
            '',
            item.sellerId,
            "I have sent an offer of € $price for '${item.title}'",
          );
        }
        vm.resetOfferForm();
        if (context.mounted) {
          Navigator.pop(context);
          if (item.sellerId.isNotEmpty) {
            final conv = ChatConversationModel(
              id: '',
              otherParticipant: ChatParticipantModel(
                id: item.sellerId,
                firstName: item.sellerName,
                lastName: '',
                profilePhotoUrl: item.sellerAvatar,
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
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage ?? 'Failed to send offer'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MarketplaceViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Make an Offer',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(17),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.hMargin,
          vertical: (context.scaleH(20.0)).clamp(14.0, 24.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.slate200,
                          child: SvgPicture.asset(
                            AppIcons.gallerySvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate500,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Product Title + Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.title}${item.condition != null ? ' – ${item.condition}' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.price,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.vibrantBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Your Offer Label
            const Text(
              'Your Offer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.slate700,
              ),
            ),
            const SizedBox(height: 8),

            // Offer Price Input
            TextField(
              controller: vm.offerPriceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
              decoration: InputDecoration(
                prefixText: '€ ',
                prefixStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.vibrantBlue,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.vibrantBlue,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.vibrantBlue,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Message Label
            const Text(
              'Message (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.slate700,
              ),
            ),
            const SizedBox(height: 8),

            // Message Input
            TextField(
              controller: vm.offerMessageController,
              maxLines: 4,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.slate700,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText:
                    'Hello! I am interested in this item. Can we deal for €500?',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.slate400,
                  height: 1.4,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.vibrantBlue,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Send Offer Button
            SizedBox(
              width: double.infinity,
              height: (context.scaleH(52.0)).clamp(46.0, 56.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: vm.isSendingOffer ? null : () => _sendOffer(context, vm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: vm.isSendingOffer
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Send Offer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: (context.scaleH(52.0)).clamp(46.0, 56.0),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.slate700,
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
