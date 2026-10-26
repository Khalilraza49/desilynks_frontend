import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';

class FiltersView extends StatelessWidget {
  const FiltersView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catVM = context.read<CategoriesViewModel>();
      if (!catVM.hasFetched && !catVM.isLoading) {
        catVM.fetchAll();
      }
    });

    final viewModel = Provider.of<PostRoomViewModel>(context);
    final isWorkerCategory = viewModel.tempCategory == 'Workers';
    final isJobCategory = viewModel.tempCategory == 'Jobs';
    final isRoomCategory = viewModel.tempCategory == 'Rooms';
    final isAllCategory = viewModel.tempCategory == 'All';

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: AppConstants.elevationNone,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.slate800,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filters',
          style: TextStyle(
            color: AppColors.slate800,
            fontSize: AppConstants.fontSizeXXL,
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              viewModel.resetFilters();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter Removed'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
                fontSize: AppConstants.fontSize,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 1. Category Card
                    _buildFilterSectionCard(
                      title: 'Category',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCapsule(
                            label: 'All',
                            isSelected: viewModel.tempCategory == 'All',
                            onTap: () => viewModel.setTempCategory('All'),
                          ),
                          _buildCapsule(
                            label: 'Jobs',
                            isSelected: viewModel.tempCategory == 'Jobs',
                            onTap: () => viewModel.setTempCategory('Jobs'),
                          ),
                          _buildCapsule(
                            label: 'Rooms',
                            isSelected: viewModel.tempCategory == 'Rooms',
                            onTap: () => viewModel.setTempCategory('Rooms'),
                          ),
                          _buildCapsule(
                            label: 'Workers',
                            isSelected: viewModel.tempCategory == 'Workers',
                            onTap: () => viewModel.setTempCategory('Workers'),
                          ),
                          _buildCapsule(
                            label: 'Marketplace',
                            isSelected: viewModel.tempCategory == 'Marketplace',
                            onTap: () =>
                                viewModel.setTempCategory('Marketplace'),
                          ),
                          _buildCapsule(
                            label: 'Deals',
                            isSelected: viewModel.tempCategory == 'Deals',
                            onTap: () => viewModel.setTempCategory('Deals'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1.5 Worker Profession / Service Card (Workers Only)
                    if (isWorkerCategory) ...[
                      Consumer<CategoriesViewModel>(
                        builder: (context, catVM, _) {
                          final workerServices = [
                            'All',
                            ...catVM.needWorkerTypes.map((t) => t.title),
                          ];
                          return _buildFilterSectionCard(
                            title: 'Service / Profession',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: workerServices.map((service) {
                                final isSelected =
                                    viewModel.tempWorkerService.toLowerCase() ==
                                    service.toLowerCase();
                                return _buildCapsule(
                                  label: service,
                                  isSelected: isSelected,
                                  onTap: () =>
                                      viewModel.setTempWorkerService(service),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 2. Location Card
                    _buildFilterSectionCard(
                      title: 'Location',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: viewModel.filterLocationController,
                            onChanged: viewModel.setTempLocation,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset(
                                  AppIcons.locationSvg,
                                  width: 18,
                                  height: 18,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.slate400,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              hintText: 'Enter location...',
                              filled: true,
                              fillColor: AppColors.slate50,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.slate200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.slate200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.vibrantBlue,
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: AppConstants.fontSize,
                              color: AppColors.slate800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Distance',
                            style: TextStyle(
                              fontSize: AppConstants.fontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildCapsule(
                                label: 'Any',
                                isSelected: viewModel.tempDistance == 'Any',
                                onTap: () => viewModel.setTempDistance('Any'),
                              ),
                              _buildCapsule(
                                label: '5 km',
                                isSelected: viewModel.tempDistance == '5 km',
                                onTap: () => viewModel.setTempDistance('5 km'),
                              ),
                              _buildCapsule(
                                label: '10 km',
                                isSelected: viewModel.tempDistance == '10 km',
                                onTap: () => viewModel.setTempDistance('10 km'),
                              ),
                              _buildCapsule(
                                label: '25 km',
                                isSelected: viewModel.tempDistance == '25 km',
                                onTap: () => viewModel.setTempDistance('25 km'),
                              ),
                              _buildCapsule(
                                label: '50 km',
                                isSelected: viewModel.tempDistance == '50 km',
                                onTap: () => viewModel.setTempDistance('50 km'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Price Range Card (Hourly Rate for Workers, Price Range for others)
                    if (isWorkerCategory)
                      _buildFilterSectionCard(
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Max Hourly Rate',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeLG,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate800,
                              ),
                            ),
                            Text(
                              'Up to €${viewModel.tempMaxWorkerRate.round()}/hr',
                              style: const TextStyle(
                                fontSize: AppConstants.fontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.vibrantBlue,
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: AppColors.vibrantBlue,
                                inactiveTrackColor: AppColors.slate200,
                                thumbColor: AppColors.vibrantBlue,
                                overlayColor: AppColors.vibrantBlue.withValues(
                                  alpha: 0.12,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                min: 10.0,
                                max: 150.0,
                                divisions: 28,
                                value: viewModel.tempMaxWorkerRate.clamp(
                                  10.0,
                                  150.0,
                                ),
                                onChanged: viewModel.setTempMaxWorkerRate,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '€10/hr',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeXS11,
                                      color: AppColors.slate400,
                                    ),
                                  ),
                                  Text(
                                    '€150+/hr',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeXS11,
                                      color: AppColors.slate400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      _buildFilterSectionCard(
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Price Range',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeLG,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate800,
                              ),
                            ),
                            Text(
                              '€0 — €${viewModel.tempMaxPrice.round()}',
                              style: const TextStyle(
                                fontSize: AppConstants.fontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.vibrantBlue,
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: AppColors.vibrantBlue,
                                inactiveTrackColor: AppColors.slate200,
                                thumbColor: AppColors.vibrantBlue,
                                overlayColor: AppColors.vibrantBlue.withValues(
                                  alpha: 0.12,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                min: 0.0,
                                max: 1000.0,
                                value: viewModel.tempMaxPrice,
                                onChanged: viewModel.setTempMaxPrice,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '€0',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeXS11,
                                      color: AppColors.slate400,
                                    ),
                                  ),
                                  Text(
                                    '€1,000+',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeXS11,
                                      color: AppColors.slate400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Worker Availability & Perks Card (Workers Only)
                    if (isWorkerCategory) ...[
                      _buildFilterSectionCard(
                        title: 'Availability & Features',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildMultiSelectCapsule(
                              label: 'Available Today',
                              isSelected: viewModel.tempAvailableTodayOnly,
                              onTap: viewModel.toggleTempAvailableTodayOnly,
                            ),
                            _buildMultiSelectCapsule(
                              label: 'Has Vehicle',
                              isSelected: viewModel.tempHasVehicleOnly,
                              onTap: viewModel.toggleTempHasVehicleOnly,
                            ),
                            _buildMultiSelectCapsule(
                              label: 'Has Tools',
                              isSelected: viewModel.tempHasToolsOnly,
                              onTap: viewModel.toggleTempHasToolsOnly,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFilterSectionCard(
                        title: 'Minimum Experience',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildCapsule(
                              label: 'Any',
                              isSelected: viewModel.tempMinExperience == 0,
                              onTap: () => viewModel.setTempMinExperience(0),
                            ),
                            _buildCapsule(
                              label: '1+ Years',
                              isSelected: viewModel.tempMinExperience == 1,
                              onTap: () => viewModel.setTempMinExperience(1),
                            ),
                            _buildCapsule(
                              label: '3+ Years',
                              isSelected: viewModel.tempMinExperience == 3,
                              onTap: () => viewModel.setTempMinExperience(3),
                            ),
                            _buildCapsule(
                              label: '5+ Years',
                              isSelected: viewModel.tempMinExperience == 5,
                              onTap: () => viewModel.setTempMinExperience(5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 4. Job Type Card (Jobs or All only)
                    if (isJobCategory || isAllCategory) ...[
                      _buildFilterSectionCard(
                        title: 'Job Type',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildMultiSelectCapsule(
                              label: 'Full Time',
                              isSelected: viewModel.tempJobTypes.contains(
                                'Full Time',
                              ),
                              onTap: () =>
                                  viewModel.toggleTempJobType('Full Time'),
                            ),
                            _buildMultiSelectCapsule(
                              label: 'Part Time',
                              isSelected: viewModel.tempJobTypes.contains(
                                'Part Time',
                              ),
                              onTap: () =>
                                  viewModel.toggleTempJobType('Part Time'),
                            ),
                            _buildMultiSelectCapsule(
                              label: 'Remote',
                              isSelected: viewModel.tempJobTypes.contains(
                                'Remote',
                              ),
                              onTap: () =>
                                  viewModel.toggleTempJobType('Remote'),
                            ),
                            _buildMultiSelectCapsule(
                              label: 'Contract',
                              isSelected: viewModel.tempJobTypes.contains(
                                'Contract',
                              ),
                              onTap: () =>
                                  viewModel.toggleTempJobType('Contract'),
                            ),
                            _buildMultiSelectCapsule(
                              label: 'Freelance',
                              isSelected: viewModel.tempJobTypes.contains(
                                'Freelance',
                              ),
                              onTap: () =>
                                  viewModel.toggleTempJobType('Freelance'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 5. Room Type Card (Rooms or All only)
                    if (isRoomCategory || isAllCategory) ...[
                      _buildFilterSectionCard(
                        title: 'Room Type',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildMultiSelectCapsule(
                              label: 'Private Room',
                              isSelected: viewModel.tempRoomTypes.contains(
                                'Private Room',
                              ),
                              onTap: () =>
                                  viewModel.toggleTempRoomType('Private Room'),
                            ),
                            _buildMultiSelectCapsule(
                              label: 'Shared',
                              isSelected: viewModel.tempRoomTypes.contains(
                                'Shared',
                              ),
                              onTap: () =>
                                  viewModel.toggleTempRoomType('Shared'),
                            ),
                            _buildMultiSelectCapsule(
                              label: 'Studio',
                              isSelected: viewModel.tempRoomTypes.contains(
                                'Studio',
                              ),
                              onTap: () =>
                                  viewModel.toggleTempRoomType('Studio'),
                            ),
                            _buildMultiSelectCapsule(
                              label: 'Apartment',
                              isSelected: viewModel.tempRoomTypes.contains(
                                'Apartment',
                              ),
                              onTap: () =>
                                  viewModel.toggleTempRoomType('Apartment'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 6. Sort By Card
                    _buildFilterSectionCard(
                      title: 'Sort By',
                      child: Column(
                        children: isWorkerCategory
                            ? [
                                _buildRadioTile(viewModel, 'Newest First'),
                                _buildRadioTile(
                                  viewModel,
                                  'Price: Low to High',
                                ),
                                _buildRadioTile(
                                  viewModel,
                                  'Price: High to Low',
                                ),
                                _buildRadioTile(viewModel, 'Most Experienced'),
                                _buildRadioTile(viewModel, 'Nearest First'),
                              ]
                            : [
                                _buildRadioTile(viewModel, 'Newest First'),
                                _buildRadioTile(
                                  viewModel,
                                  'Price: Low to High',
                                ),
                                _buildRadioTile(
                                  viewModel,
                                  'Price: High to Low',
                                ),
                                _buildRadioTile(viewModel, 'Most Popular'),
                                _buildRadioTile(viewModel, 'Nearest First'),
                              ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.padding28),

                    // Bottom Buttons Bar
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              viewModel.resetFilters();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Filter Removed'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: AppColors.slate300),
                              backgroundColor: AppColors.white,
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                color: AppColors.slate800,
                                fontSize: AppConstants.fontSizeLG,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.vibrantBlue,
                                  AppColors.secondaryPurple,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                viewModel.applyFilters();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Filter Applied'),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                Navigator.pop(context, true);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: AppColors.transparent,
                                shadowColor: AppColors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: AppConstants.fontSizeLG,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSectionCard({
    String? title,
    Widget? header,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackOpacity4,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            header
          else if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeLG,
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCapsule({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vibrantBlue : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.transparent : AppColors.slate200,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.slate600,
            fontSize: AppConstants.fontSizeMD,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectCapsule({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return _buildCapsule(label: label, isSelected: isSelected, onTap: onTap);
  }

  Widget _buildRadioTile(PostRoomViewModel viewModel, String value) {
    final isSelected = viewModel.tempSortBy == value;
    return InkWell(
      onTap: () => viewModel.setTempSortBy(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                color: isSelected ? AppColors.slate800 : AppColors.slate600,
                fontSize: AppConstants.fontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.vibrantBlue
                      : AppColors.slate300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.vibrantBlue,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
