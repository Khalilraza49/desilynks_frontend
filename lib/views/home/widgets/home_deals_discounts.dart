import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/home/home_viewmodel.dart';

class HomeDealsDiscounts extends StatelessWidget {
  const HomeDealsDiscounts({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();
    final dealsList = homeViewModel.deals;
    final int count = dealsList.isEmpty ? 1 : dealsList.length;
    final int activeIndex = homeViewModel.dealsIndex.clamp(0, count - 1);

    if (dealsList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppConstants.padding20),
          child: Text(
            AppStrings.noDataAvailable,
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              color: AppColors.slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: AppConstants.dealCardHeight,
          child: PageView.builder(
            controller: homeViewModel.dealsPageController,
            onPageChanged: (index) {
              homeViewModel.setDealsIndex(index);
            },
            itemCount: dealsList.length,
            itemBuilder: (context, index) {
              final deal = dealsList[index];
              return _buildPromoCard(
                context,
                deal['desc'] as String,
                deal['discount'] as String,
                deal['accentColor'] as Color? ?? AppColors.emerald,
                deal['svgIcon'] as String? ?? AppIcons.shopingSvg,
                discountTitle: deal['discountTitle'] as String?,
                category: deal['category'] as String?,
                location: deal['location'] as String?,
                imageUrl: deal['imageUrl'] as String?,
                destinationLink: deal['destinationLink'] as String?,
                bannerAdId: deal['id'] as String?,
                detailsText: deal['detailsText'] as String?,
                validUntil: deal['validUntil'] as String?,
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.padding10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            dealsList.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: activeIndex == index
                  ? AppConstants.borderRadius24
                  : AppConstants.borderRadius8,
              height: AppConstants.borderRadius8,
              decoration: BoxDecoration(
                color: activeIndex == index
                    ? AppColors.primaryBlue
                    : AppColors.slate300,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusExtraSmall,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(
    BuildContext context,
    String desc,
    String discount,
    Color accentColor,
    String svgIcon, {
    String? discountTitle,
    String? category,
    String? location,
    String? imageUrl,
    String? destinationLink,
    String? bannerAdId,
    String? detailsText,
    String? validUntil,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (bannerAdId != null) {
            context.read<HomeViewModel>().recordBannerView(bannerAdId);
          }
          Navigator.pushNamed(
            context,
            AppRoutes.dealDetails,
            arguments: {
              'storeName': desc,
              'category': category ?? 'Deals & Discounts',
              'rating': '4.9',
              'reviewCount': '320',
              'discountTitle': discountTitle ?? desc,
              'discountTag': discount,
              'validUntil': validUntil ?? '7 Days',
              'location': location ?? 'Spain',
              'detailsText': detailsText ?? desc,
              'imageUrl': imageUrl,
              'destinationLink': destinationLink,
              'bannerAdId': bannerAdId,
            },
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: Container(
          height: AppConstants.dealCardHeight,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.slate900,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            image: (imageUrl != null && imageUrl.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.6),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius8,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        svgIcon,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        width: AppConstants.iconSize,
                        height: AppConstants.iconSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                discount,
                style: TextStyle(
                  color: accentColor,
                  fontSize: AppConstants.fontSizeHeading,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
