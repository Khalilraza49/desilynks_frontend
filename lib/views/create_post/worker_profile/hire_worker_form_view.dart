import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/models/category_item.dart';
import 'package:desilynks/viewmodels/categories/categories_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/need_worker_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/worker_viewmodel.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/widgets/custom_text_field.dart';

class HireWorkerFormView extends StatelessWidget {
  final Map<String, dynamic>? worker;

  const HireWorkerFormView({super.key, this.worker});

  Future<void> _submitRequest(BuildContext context) async {
    final workerVM = context.read<WorkerViewModel>();
    if (workerVM.isHireSubmitting) return;
    workerVM.setIsHireSubmitting(true);

    final needWorkerVM = context.read<NeedWorkerViewModel>();
    final categoriesVM = context.read<CategoriesViewModel>();

    final success = await workerVM.submitHireRequest(
      worker: worker,
      needWorkerVM: needWorkerVM,
      categoriesVM: categoriesVM,
    );

    if (!context.mounted) return;
    workerVM.setIsHireSubmitting(false);

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.hireWorkerSuccess,
        arguments: workerVM.lastHireRequestData,
      );
    } else {
      final error = needWorkerVM.errorMessage ??
          workerVM.errorMessage ??
          'Failed to send request. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildAvatarFallback(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        AppIcons.personSvg,
        colorFilter: const ColorFilter.mode(
          Color(0xFF2563EB),
          BlendMode.srcIn,
        ),
        width: context.scale(28).clamp(24.0, 32.0),
        height: context.scale(28).clamp(24.0, 32.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerVM = context.watch<WorkerViewModel>();
    final needWorkerVM = context.watch<NeedWorkerViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final catVM = context.read<CategoriesViewModel>();
      catVM.fetchAll();
      context.read<WorkerViewModel>().initHireWorkerForm(
        worker,
        categoriesVM: catVM,
      );
    });

    final workerName = worker?['name'] as String? ?? 'Ali Khan';
    final profession = worker?['profession'] as String? ?? 'Electrician';
    final rating = worker?['rating']?.toString() ?? '4.9';
    final reviewsCount =
        worker?['reviewsCount']?.toString() ?? '128';
    final hourlyRate =
        worker?['hourlyRate']?.toString() ?? '18';
    final avatar = worker?['avatar'] as String? ?? '';
    final isOneTime = workerVM.hireIsOneTime;
    final isBusy = workerVM.isHireSubmitting || workerVM.isLoading || needWorkerVM.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate900,
              BlendMode.srcIn,
            ),
            height: context.scaleH(18).clamp(15.0, 22.0),
            width: context.scale(18).clamp(15.0, 22.0),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hire $workerName',
          style: TextStyle(
            fontSize: context.sp(18).clamp(16.0, 21.0),
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.hMargin,
            vertical: context.scaleH(12).clamp(8.0, 16.0),
          ),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.scaleH(8).clamp(4.0, 12.0)),

              // 2. Worker Summary Header Card
              Container(
                padding: EdgeInsets.all(context.scale(16).clamp(12.0, 18.0)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    context.scale(16).clamp(12.0, 18.0),
                  ),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.blackOpacity4,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar Thumbnail (Square with rounded corners)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        context.scale(12).clamp(10.0, 14.0),
                      ),
                      child: Container(
                        width: context.scale(56).clamp(48.0, 64.0),
                        height: context.scale(56).clamp(48.0, 64.0),
                        color: const Color(0xFFEFF6FF),
                        child: avatar.isNotEmpty
                            ? Image.network(
                                avatar,
                                width: context.scale(56).clamp(48.0, 64.0),
                                height: context.scale(56).clamp(48.0, 64.0),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarFallback(context),
                              )
                            : _buildAvatarFallback(context),
                      ),
                    ),
                    SizedBox(width: context.scale(14).clamp(10.0, 16.0)),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workerName,
                            style: TextStyle(
                              fontSize: context.sp(16).clamp(14.0, 18.0),
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          SizedBox(height: context.scaleH(2).clamp(1.0, 4.0)),
                          Text(
                            profession,
                            style: TextStyle(
                              fontSize: context.sp(13).clamp(11.0, 14.0),
                              color: AppColors.slate500,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          SizedBox(height: context.scaleH(6).clamp(4.0, 8.0)),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.starFavoriteSvg,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFF59E0B),
                                  BlendMode.srcIn,
                                ),
                                width: context.scale(15).clamp(13.0, 17.0),
                                height: context.scale(15).clamp(13.0, 17.0),
                              ),
                              SizedBox(width: context.scale(4).clamp(2.0, 5.0)),
                              Text(
                                rating,
                                style: TextStyle(
                                  fontSize: context.sp(13).clamp(11.0, 14.0),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.slate800,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              Text(
                                ' ($reviewsCount)',
                                style: TextStyle(
                                  fontSize: context.sp(12).clamp(10.0, 13.0),
                                  color: AppColors.slate400,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                              const Text(
                                '  •  ',
                                style: TextStyle(color: AppColors.slate300),
                              ),
                              Text(
                                '€$hourlyRate/hour',
                                style: TextStyle(
                                  fontSize: context.sp(13).clamp(11.0, 14.0),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2563EB),
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

              SizedBox(height: context.scaleH(20).clamp(16.0, 24.0)),

              // 3. Select Service Dropdown Field
              Text(
                'Select Service',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              Consumer<CategoriesViewModel>(
                builder: (context, catVM, _) {
                  final services = catVM.needWorkerTypes.isNotEmpty
                      ? catVM.needWorkerTypes.map((t) => t.title).toSet().toList()
                      : [
                          'Cook',
                          'Electrician',
                          'Plumber',
                          'Carpenter',
                          'Painter',
                          'Cleaner',
                        ];

                  if (workerVM.hireSelectedService.isNotEmpty &&
                      !services.contains(workerVM.hireSelectedService)) {
                    services.insert(0, workerVM.hireSelectedService);
                  }

                  if (workerVM.hireSelectedService.isEmpty &&
                      services.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!context.mounted) return;
                      final defaultService = services.first;
                      final matchingCat = catVM.needWorkerTypes
                          .cast<CategoryItem?>()
                          .firstWhere(
                            (c) =>
                                c != null &&
                                c.title.trim().toLowerCase() ==
                                    defaultService.trim().toLowerCase(),
                            orElse: () => null,
                          );
                      workerVM.setHireSelectedService(
                        defaultService,
                        workerTypeId: matchingCat?.id,
                      );
                    });
                  }

                  final currentValue =
                      services.contains(workerVM.hireSelectedService)
                          ? workerVM.hireSelectedService
                          : (services.isNotEmpty ? services.first : null);

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(16).clamp(12.0, 18.0),
                      vertical: context.scaleH(4).clamp(2.0, 6.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        context.scale(12).clamp(10.0, 14.0),
                      ),
                      border: Border.all(
                        color: const Color(0xFF2563EB),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.blackOpacity4,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentValue,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(
                          context.scale(12).clamp(10.0, 14.0),
                        ),
                        elevation: 4,
                        hint: Text(
                          catVM.isLoading ? 'Loading…' : 'Select service',
                          style: TextStyle(
                            fontSize: context.sp(14).clamp(12.0, 15.0),
                            color: AppColors.slate400,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                        icon: SvgPicture.asset(
                          AppIcons.arrowDropDownSvg,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF2563EB),
                            BlendMode.srcIn,
                          ),
                          width: context.scale(18).clamp(16.0, 20.0),
                          height: context.scale(18).clamp(16.0, 20.0),
                        ),
                        style: TextStyle(
                          fontSize: context.sp(14).clamp(12.0, 15.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            final matchingCat = catVM.needWorkerTypes
                                .cast<CategoryItem?>()
                                .firstWhere(
                                  (c) =>
                                      c != null &&
                                      c.title.trim().toLowerCase() ==
                                          newValue.trim().toLowerCase(),
                                  orElse: () => null,
                                );
                            workerVM.setHireSelectedService(
                              newValue,
                              workerTypeId: matchingCat?.id,
                            );
                          }
                        },
                        items: services.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: context.sp(14).clamp(12.0, 15.0),
                                fontWeight: FontWeight.w500,
                                color: AppColors.slate800,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: context.scaleH(18).clamp(14.0, 22.0)),

              // 4. Describe Your Job Text Field
              Text(
                'Describe Your Job',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              CustomTextField(
                controller: workerVM.hireDescriptionController,
                hintText: 'Describe your requirements...',
                maxLines: 4,
                fontSize: context.sp(14).clamp(12.0, 15.0),
                fillColor: Colors.white,
                borderRadius: BorderRadius.circular(
                  context.scale(12).clamp(10.0, 14.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),

              SizedBox(height: context.scaleH(18).clamp(14.0, 22.0)),

              // 5. Location Text Field
              Text(
                'Location',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              CustomTextField(
                controller: workerVM.hireLocationController,
                hintText: 'Location',
                fontSize: context.sp(14).clamp(12.0, 15.0),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  child: SvgPicture.asset(
                    AppIcons.locationSvg,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate400,
                      BlendMode.srcIn,
                    ),
                    width: context.scale(18).clamp(16.0, 20.0),
                    height: context.scale(18).clamp(16.0, 20.0),
                  ),
                ),
                fillColor: Colors.white,
                borderRadius: BorderRadius.circular(
                  context.scale(12).clamp(10.0, 14.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),

              SizedBox(height: context.scaleH(18).clamp(14.0, 22.0)),

              // 6. Budget Text Field
              Text(
                'Budget',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              CustomTextField(
                controller: workerVM.hireBudgetController,
                keyboardType: TextInputType.number,
                hintText: 'Budget amount',
                fontSize: context.sp(14).clamp(12.0, 15.0),
                prefix: Padding(
                  padding: EdgeInsets.only(
                    left: context.scale(16).clamp(12.0, 18.0),
                    right: context.scale(8).clamp(6.0, 10.0),
                  ),
                  child: Text(
                    '€',
                    style: TextStyle(
                      fontSize: context.sp(16).clamp(14.0, 18.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
                fillColor: Colors.white,
                borderRadius: BorderRadius.circular(
                  context.scale(12).clamp(10.0, 14.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    context.scale(12).clamp(10.0, 14.0),
                  ),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),

              SizedBox(height: context.scaleH(18).clamp(14.0, 22.0)),

              // 7. Job Type Selection
              Text(
                'Job Type',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              SizedBox(height: context.scaleH(8).clamp(6.0, 10.0)),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => workerVM.setHireIsOneTime(true),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: context.scaleH(14).clamp(11.0, 16.0),
                        ),
                        decoration: BoxDecoration(
                          color: isOneTime
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(
                            context.scale(12).clamp(10.0, 14.0),
                          ),
                          border: Border.all(
                            color: isOneTime
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'One Time',
                          style: TextStyle(
                            fontSize: context.sp(14).clamp(12.0, 15.0),
                            fontWeight: FontWeight.bold,
                            color: isOneTime
                                ? Colors.white
                                : AppColors.slate700,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.scale(12).clamp(8.0, 14.0)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => workerVM.setHireIsOneTime(false),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: context.scaleH(14).clamp(11.0, 16.0),
                        ),
                        decoration: BoxDecoration(
                          color: !isOneTime
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(
                            context.scale(12).clamp(10.0, 14.0),
                          ),
                          border: Border.all(
                            color: !isOneTime
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Recurring',
                          style: TextStyle(
                            fontSize: context.sp(14).clamp(12.0, 15.0),
                            fontWeight: FontWeight.bold,
                            color: !isOneTime
                                ? Colors.white
                                : AppColors.slate700,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.scaleH(28).clamp(20.0, 32.0)),

              // 8. Bottom CTA Button - Send Request
              CustomButton(
                text: 'Send Request',
                onPressed: () => _submitRequest(context),
                isLoading: isBusy,
                backgroundColor: const Color(0xFF6366F1),
                height: context.scaleH(50).clamp(46.0, 54.0),
                borderRadius: context.scale(14).clamp(12.0, 16.0),
                fontSize: context.sp(16).clamp(14.0, 18.0),
                fontWeight: FontWeight.bold,
              ),

              SizedBox(height: context.scaleH(20).clamp(14.0, 24.0)),
            ],
          ),
        ),
      ),
    );
  }
}
