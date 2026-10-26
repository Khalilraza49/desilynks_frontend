import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';

class HomeLocationFilters extends StatelessWidget {
  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String> onCitySelected;

  const HomeLocationFilters({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cities.map((city) {
          final isSelected = selectedCity == city;
          return GestureDetector(
            onTap: () => onCitySelected(city),
            child: Container(
              margin: const EdgeInsets.only(right: AppConstants.padding10),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingStandard,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.successGreen : AppColors.white,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusLarge,
                ),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.slate200,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    city == AppStrings.labelAllCities
                        ? AppIcons.worldSvg
                        : AppIcons.locationSvg,
                    width: AppConstants.iconSizeSM,
                    height: AppConstants.iconSizeSM,
                    colorFilter: ColorFilter.mode(
                      isSelected ? AppColors.white : AppColors.slate500,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppConstants.padding6),
                  Text(
                    city,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSM,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.white : AppColors.slate800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
