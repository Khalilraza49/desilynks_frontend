import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/app/routes.dart';

class HomeRevenuePromotions extends StatelessWidget {
  final List<Map<String, dynamic>> revPromos;

  const HomeRevenuePromotions({super.key, required this.revPromos});

  @override
  Widget build(BuildContext context) {
    if (revPromos.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackOpacity4,
            blurRadius: AppConstants.borderRadius10,
            offset: Offset(0, AppConstants.borderRadiusExtraSmall),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Flexible(
                      child: Text(
                        AppStrings.titleRevenuePromotions,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeXXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingSmall,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius10,
                        ),
                      ),
                      child: const Text(
                        AppStrings.labelNew,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: AppConstants.fontSizeXS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.revenuePromotions);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  AppStrings.btnViewAll,
                  style: TextStyle(
                    fontSize: AppConstants.fontSize,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Row(
            children: revPromos.map((promo) {
              final label = promo['label'] as String? ?? '';
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    final l = label.toLowerCase();
                    if (l.contains('banner')) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.bannerAdvertisements,
                      );
                    } else if (l.contains('deal') ||
                        l.contains('discount') ||
                        l.contains('offer')) {
                      Navigator.pushNamed(context, AppRoutes.dealsDiscounts);
                    } else {
                      Navigator.pushNamed(context, AppRoutes.selectAdToPromote);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: AppConstants.avatarSizeMedium,
                        height: AppConstants.avatarSizeMedium,
                        decoration: BoxDecoration(
                          color: promo['bgColor'],
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusExtraSmall,
                          ),
                        ),
                        child: Center(
                          child: promo['icon'] is String
                              ? SvgPicture.asset(
                                  promo['icon'] as String,
                                  colorFilter: ColorFilter.mode(
                                    promo['iconColor'] as Color,
                                    BlendMode.srcIn,
                                  ),
                                  width: AppConstants.iconSizeLG,
                                  height: AppConstants.iconSizeLG,
                                )
                              : Icon(
                                  promo['icon'] as IconData,
                                  color: promo['iconColor'] as Color,
                                  size: AppConstants.iconSizeLG,
                                ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        promo['label'],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate800,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
