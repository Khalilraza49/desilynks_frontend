import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/support/faq_viewmodel.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FaqViewModel>();
    final filteredQuestions = viewModel.filteredQuestions;
    const categories = FaqViewModel.categories;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
            width: context.scale(20).clamp(18.0, 24.0),
            height: context.scale(20).clamp(18.0, 24.0),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'FAQ',
          style: TextStyle(
            color: AppColors.white,
            fontSize: context.sp(20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
              vertical: (context.scaleH(16.0)).clamp(12.0, 20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Box
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius12,
                    ),
                    border: Border.all(color: AppColors.slate200),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: viewModel.searchController,
                    hintText: 'Search questions...',
                    fontSize: context.sp(14),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        AppIcons.searchSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate400,
                          BlendMode.srcIn,
                        ),
                        width: 18,
                        height: 18,
                      ),
                    ),
                    suffixIcon: viewModel.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: AppColors.slate400,
                            ),
                            onPressed: viewModel.clearSearch,
                          )
                        : null,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                SizedBox(height: (context.scaleH(24.0)).clamp(16.0, 28.0)),

                // Popular Questions Header
                Text(
                  'Popular Questions',
                  style: TextStyle(
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: (context.scaleH(12.0)).clamp(8.0, 16.0)),

                // Questions List
                if (filteredQuestions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius12,
                      ),
                      border: Border.all(color: AppColors.slate100),
                    ),
                    child: Center(
                      child: Text(
                        'No questions found matching "${viewModel.searchQuery}"',
                        style: TextStyle(
                          fontSize: context.sp(14),
                          color: AppColors.slate500,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredQuestions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredQuestions[index];
                      final isExpanded = viewModel.expandedIndex == index;

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius12,
                          ),
                          border: Border.all(color: AppColors.slate100),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            key: Key('faq_tile_${index}_$isExpanded'),
                            initiallyExpanded: isExpanded,
                            onExpansionChanged: (expanded) {
                              viewModel.toggleExpanded(index, expanded);
                            },
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(
                              item.question,
                              style: TextStyle(
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate800,
                              ),
                            ),
                            trailing: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.slate400,
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Text(
                                  item.answer,
                                  style: TextStyle(
                                    fontSize: context.sp(13),
                                    height: 1.5,
                                    color: AppColors.slate600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                SizedBox(height: (context.scaleH(24.0)).clamp(16.0, 28.0)),

                // Categories Section
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: (context.scaleH(12.0)).clamp(8.0, 16.0)),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius16,
                    ),
                    border: Border.all(color: AppColors.slate100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.slate100,
                    ),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Browsing ${cat.title} questions...',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(
                          index == 0
                              ? AppConstants.borderRadius16
                              : index == categories.length - 1
                              ? AppConstants.borderRadius16
                              : 0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: cat.bgColor,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadius8,
                                  ),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    cat.icon,
                                    colorFilter: ColorFilter.mode(
                                      cat.color,
                                      BlendMode.srcIn,
                                    ),
                                    width: 18,
                                    height: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  cat.title,
                                  style: TextStyle(
                                    fontSize: context.sp(14),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.slate800,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.slate400,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: (context.scaleH(30.0)).clamp(20.0, 36.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
