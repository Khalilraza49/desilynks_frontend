import 'package:desilynks/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';
import 'package:desilynks/viewmodels/home/home_viewmodel.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.read<HomeViewModel>();

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Provider.of<NavigationViewModel>(context, listen: false).openSearch();
            },
            child: AbsorbPointer(
              child: Container(
                height: AppConstants.searchBarHeight,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
                ),
                child: CustomTextField(
                  hintText: AppStrings.searchHintText,
                  controller: homeViewModel.searchController,
                  readOnly: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      AppIcons.searchSvg,
                      width: AppConstants.iconSize,
                      height: AppConstants.iconSize,
                      fit: BoxFit.scaleDown,
                      colorFilter: const ColorFilter.mode(
                        AppColors.svgDefault,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Container(
          width: AppConstants.searchBarHeight,
          height: AppConstants.searchBarHeight,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              AppIcons.filterSvg,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
              width: AppConstants.iconSize,
              height: AppConstants.iconSize,
            ),
            onPressed: () {
              // Navigate to the filters view
              Navigator.pushNamed(context, AppRoutes.filters);
            },
          ),
        ),
      ],
    );
  }
}
