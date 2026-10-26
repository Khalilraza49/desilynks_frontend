import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/profile/my_ads_viewmodel.dart';
import 'package:desilynks/viewmodels/marketplace/marketplace_viewmodel.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/need_worker_viewmodel.dart';
import 'package:desilynks/viewmodels/business_listing_viewmodel.dart';
import 'package:desilynks/viewmodels/promotions/select_ad_to_promote_viewmodel.dart';
import 'package:desilynks/widgets/custom_button.dart';

class SelectAdToPromoteView extends StatelessWidget {
  const SelectAdToPromoteView({super.key});

  List<PromotableAdItem> _getCombinedUserAds(
    BuildContext context,
    SelectAdToPromoteViewModel viewModel,
  ) {
    final adsViewModel = context.watch<MyAdsViewModel>();
    final marketplaceViewModel = context.watch<MarketplaceViewModel>();
    final jobsViewModel = context.watch<JobsViewModel>();
    final needWorkerViewModel = context.watch<NeedWorkerViewModel>();
    final businessViewModel = context.watch<BusinessListingViewModel>();

    final List<PromotableAdItem> userAdsList = [];

    // 1. Marketplace Products
    for (var m in marketplaceViewModel.myAds) {
      userAdsList.add(
        PromotableAdItem(
          id: m.id,
          title: m.title,
          price: m.price.startsWith('€') ? m.price : '€${m.price}',
          imageUrl: m.imageUrl.isNotEmpty
              ? m.imageUrl
              : (m.photoUrls.isNotEmpty
                    ? m.photoUrls.first
                    : 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&q=80&w=400'),
          badgeText: m.isGolden ? 'Golden Active' : 'Not Promoted',
          badgeBgColor: m.isGolden
              ? const Color(0xFFFEF3C7)
              : const Color(0xFFF1F5F9),
          badgeTextColor: m.isGolden
              ? const Color(0xFFD97706)
              : const Color(0xFF64748B),
        ),
      );
    }

    // 2. Room/Property Ads
    for (var p in adsViewModel.userAds) {
      userAdsList.add(
        PromotableAdItem(
          id: p.id,
          title: p.title,
          price: p.monthlyRent.startsWith('€')
              ? p.monthlyRent
              : '€${p.monthlyRent}',
          imageUrl: p.propertyPhotos.isNotEmpty
              ? p.propertyPhotos.first.url
              : 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&q=80&w=400',
          badgeText: 'Featured Active',
          badgeBgColor: const Color(0xFFF3E8FF),
          badgeTextColor: const Color(0xFF7E22CE),
        ),
      );
    }

    // 3. Job Posts
    for (var j in jobsViewModel.userJobs) {
      userAdsList.add(
        PromotableAdItem(
          id: j.id,
          title: j.title,
          price: '€${j.salary}',
          imageUrl:
              j.posterUrl ??
              'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=400',
          badgeText: 'Premium Active',
          badgeBgColor: const Color(0xFFE0E7FF),
          badgeTextColor: const Color(0xFF4F46E5),
        ),
      );
    }

    // 4. Need Worker Posts
    for (var w in needWorkerViewModel.myPosts) {
      userAdsList.add(
        PromotableAdItem(
          id: w.id,
          title: 'Need ${w.workerType}',
          price: w.budget.startsWith('€') ? w.budget : '€${w.budget}',
          imageUrl: w.referencePhotos.isNotEmpty
              ? w.referencePhotos.first.url
              : 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&q=80&w=400',
          badgeText: 'Not Promoted',
          badgeBgColor: const Color(0xFFF1F5F9),
          badgeTextColor: const Color(0xFF64748B),
        ),
      );
    }

    // 5. Business Listings
    for (var b in businessViewModel.myListings) {
      userAdsList.add(
        PromotableAdItem(
          id: b.id,
          title: b.name,
          price: b.category,
          imageUrl: b.logo != null
              ? b.logo!.url
              : 'https://images.unsplash.com/photo-1556742049-0a67daf40955?auto=format&fit=crop&q=80&w=400',
          badgeText: 'Golden Active',
          badgeBgColor: const Color(0xFFFEF3C7),
          badgeTextColor: const Color(0xFFD97706),
        ),
      );
    }

    return userAdsList.isNotEmpty ? userAdsList : viewModel.fallbackAds;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SelectAdToPromoteViewModel>();
    final ads = _getCombinedUserAds(context, viewModel);

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
          'Select Ad to Promote',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle Description Text
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.hMargin,
                    context.scaleH(16),
                    context.hMargin,
                    context.scaleH(12),
                  ),
                  child: Text(
                    'Choose which ad you want to promote on the home screen carousel.',
                    style: TextStyle(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),

                // User Specific Ads List
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.hMargin,
                      vertical: context.scaleH(4),
                    ),
                    itemCount: ads.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: context.scaleH(12)),
                    itemBuilder: (ctx, idx) {
                      final item = ads[idx];
                      final isSelected = viewModel.selectedAdId == item.id;

                      return _buildAdCard(context, viewModel, item, isSelected);
                    },
                  ),
                ),

                // Bottom CTA Button Bar
                Container(
                  padding: EdgeInsets.all(context.scale(16)),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: CustomButton(
                    text: viewModel.selectedAdId == null
                        ? 'Select an Ad to Continue'
                        : 'Continue to Select Boost Plan',
                    onPressed: viewModel.selectedAdId == null
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.membershipPlans,
                            );
                          },
                    backgroundColor: viewModel.selectedAdId == null
                        ? AppColors.slate300
                        : AppColors.vibrantBlue,
                    height: context.scaleH(50),
                    borderRadius: 14,
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard(
    BuildContext context,
    SelectAdToPromoteViewModel viewModel,
    PromotableAdItem item,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => viewModel.selectAd(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(context.scale(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.vibrantBlue : const Color(0xFFF1F5F9),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.vibrantBlue.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                width: context.scale(56),
                height: context.scale(56),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: context.scale(56),
                  height: context.scale(56),
                  color: AppColors.slate100,
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.galleryRoundSvg,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate400,
                        BlendMode.srcIn,
                      ),
                      width: context.scale(24),
                      height: context.scale(24),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: context.scale(14)),

            // Middle Column Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                      fontFamily: AppStrings.fontInter,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.scaleH(3)),
                  Text(
                    item.price,
                    style: TextStyle(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2563EB),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  SizedBox(height: context.scaleH(6)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(10),
                      vertical: context.scaleH(3),
                    ),
                    decoration: BoxDecoration(
                      color: item.badgeBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.badgeText,
                      style: TextStyle(
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.bold,
                        color: item.badgeTextColor,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Radio Circle Selection Button
            Container(
              width: context.scale(24),
              height: context.scale(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.vibrantBlue
                      : const Color(0xFFCBD5E1),
                  width: isSelected ? 6.5 : 1.8,
                ),
                color: Colors.white,
              ),
            ),
            SizedBox(width: context.scale(4)),
          ],
        ),
      ),
    );
  }
}
