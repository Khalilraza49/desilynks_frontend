import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class HomeCategoriesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const HomeCategoriesGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final bool isSmall = context.isSmall;
    final double iconBoxSize = isSmall ? 32.0 : AppConstants.categoryIconSize;
    final double iconSize = isSmall ? 16.0 : AppConstants.iconSize;
    final double fontSize = isSmall ? 9.5 : 10.5;

    return Row(
      children: categories.asMap().entries.map((entry) {
        final int index = entry.key;
        final cat = entry.value;
        final String label = cat['label'] as String;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < categories.length - 1
                  ? (isSmall ? 4.0 : 6.0)
                  : 0.0,
            ),
            child: GestureDetector(
              onTap: () {
                final navVM = Provider.of<NavigationViewModel>(
                  context,
                  listen: false,
                );
                final labelLower = label.toLowerCase();

                if (label == AppStrings.labelJobs ||
                    labelLower.contains('job')) {
                  navVM.openJobs();
                } else if (label == AppStrings.labelRooms ||
                    labelLower.contains('room')) {
                  navVM.openRooms();
                } else if (labelLower.contains('worker')) {
                  navVM.openWorkers();
                } else if (labelLower.contains('event')) {
                  navVM.openEvents();
                } else if (labelLower.contains('market')) {
                  navVM.openMarketplace();
                } else if (labelLower.contains('cit')) {
                  Navigator.pushNamed(context, AppRoutes.exploreSpain);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: isSmall ? 6.0 : AppConstants.paddingSmall,
                  horizontal: 2.0,
                ),
                constraints: BoxConstraints(
                  minHeight: isSmall ? 78.0 : AppConstants.categoryCardHeight,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.blackOpacity4,
                      blurRadius: AppConstants.borderRadiusExtraSmall,
                      offset: Offset(0, AppConstants.padding2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: iconBoxSize,
                      height: iconBoxSize,
                      decoration: BoxDecoration(
                        color: cat['bgColor'],
                        borderRadius: BorderRadius.circular(
                          isSmall ? 8.0 : AppConstants.borderRadius10,
                        ),
                      ),
                      child: Center(
                        child: cat['icon'] is String
                            ? SvgPicture.asset(
                                cat['icon'] as String,
                                colorFilter: ColorFilter.mode(
                                  cat['iconColor'] as Color,
                                  BlendMode.srcIn,
                                ),
                                width: iconSize,
                                height: iconSize,
                              )
                            : Icon(
                                cat['icon'] as IconData,
                                color: cat['iconColor'] as Color,
                                size: iconSize,
                              ),
                      ),
                    ),
                    SizedBox(height: isSmall ? 4.0 : AppConstants.padding6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
