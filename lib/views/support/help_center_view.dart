import 'package:desilynks/views/support/help_topic_detail_view.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/support/help_center_viewmodel.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  void _showTopicDetail(BuildContext context, HelpTopicItem topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpTopicDetailView(topic: topic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HelpCenterViewModel>();
    final filteredTopics = viewModel.filteredTopics;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate800,
              BlendMode.srcIn,
            ),
            width: context.scale(20).clamp(18.0, 24.0),
            height: context.scale(20).clamp(18.0, 24.0),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help Center',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
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
                // Top Gradient Card Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    (context.scale(22.0)).clamp(16.0, 24.0),
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.secondaryPurple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius20,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.supportSvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'How can we help you?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.sp(20),
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find answers to your questions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.sp(13),
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Search Box
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius12,
                          ),
                        ),
                        child: CustomTextField(
                          controller: viewModel.searchController,
                          hintText: 'Search help topics...',
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
                                  icon: SvgPicture.asset(
                                    AppIcons.crossSmallSvg,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.slate400,
                                      BlendMode.srcIn,
                                    ),
                                    width: 16,
                                    height: 16,
                                  ),
                                  onPressed: viewModel.clearSearch,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (context.scaleH(24.0)).clamp(16.0, 28.0)),

                // Popular Topics Heading
                Text(
                  'Popular Topics',
                  style: TextStyle(
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: (context.scaleH(12.0)).clamp(8.0, 16.0)),

                // Topics Card Container
                if (filteredTopics.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius16,
                      ),
                      border: Border.all(color: AppColors.slate100),
                    ),
                    child: Center(
                      child: Text(
                        'No topics found matching "${viewModel.searchQuery}"',
                        style: TextStyle(
                          fontSize: context.sp(14),
                          color: AppColors.slate500,
                        ),
                      ),
                    ),
                  )
                else
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
                      itemCount: filteredTopics.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.slate100,
                      ),
                      itemBuilder: (context, index) {
                        final topic = filteredTopics[index];
                        return InkWell(
                          onTap: () => _showTopicDetail(context, topic),
                          borderRadius: BorderRadius.circular(
                            index == 0
                                ? AppConstants.borderRadius16
                                : index == filteredTopics.length - 1
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
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: topic.bgColor,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadius10,
                                    ),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      topic.icon,
                                      colorFilter: topic.useOriginalColor
                                          ? null
                                          : ColorFilter.mode(
                                              topic.color,
                                              BlendMode.srcIn,
                                            ),
                                      width: (context.scale(22)).clamp(18.0, 24.0),
                                      height: (context.scale(22)).clamp(18.0, 24.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    topic.title,
                                    style: TextStyle(
                                      fontSize: context.sp(14.5),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                ),
                                SvgPicture.asset(
                                  AppIcons.more_arrow,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFCBD5E1),
                                    BlendMode.srcIn,
                                  ),
                                  width: 12,
                                  height: 12,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: (context.scaleH(24.0)).clamp(16.0, 28.0)),

                // Still Need Help? Section
                Text(
                  'Still need help?',
                  style: TextStyle(
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: (context.scaleH(12.0)).clamp(8.0, 16.0)),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact our support team',
                        style: TextStyle(
                          fontSize: context.sp(13),
                          color: AppColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.contactUs);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius12,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppIcons.supportSvg,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Contact Support',
                                style: TextStyle(
                                  fontSize: context.sp(14),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
