import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/support/help_center_viewmodel.dart';

class HelpTopicDetailView extends StatefulWidget {
  final HelpTopicItem topic;

  const HelpTopicDetailView({
    super.key,
    required this.topic,
  });

  @override
  State<HelpTopicDetailView> createState() => _HelpTopicDetailViewState();
}

class _HelpTopicDetailViewState extends State<HelpTopicDetailView> {
  // Store expanded article indices (first article expanded by default matching UI)
  final Set<int> _expandedIndices = {0};

  void _toggleArticle(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate800,
              BlendMode.srcIn,
            ),
            width: (context.scale(20)).clamp(18.0, 22.0),
            height: (context.scale(20)).clamp(18.0, 22.0),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          topic.title,
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: (context.scale(18)).clamp(14.0, 20.0),
              vertical: (context.scaleH(16)).clamp(12.0, 20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Topic Card
                _buildHeroCard(context, topic),

                SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),

                // 2. FAQ Accordion Cards List
                ...List.generate(topic.articles.length, (index) {
                  final article = topic.articles[index];
                  final isExpanded = _expandedIndices.contains(index);
                  return _buildArticleCard(context, article, index, isExpanded);
                }),

                SizedBox(height: (context.scaleH(14)).clamp(10.0, 18.0)),

                // 3. Still Need Help Bottom Card
                _buildStillNeedHelpCard(context),

                SizedBox(height: (context.scaleH(24)).clamp(16.0, 32.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, HelpTopicItem topic) {
    final double iconBoxSize = (context.scale(52)).clamp(46.0, 56.0);
    final double iconSize = (context.scale(26)).clamp(22.0, 28.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((context.scale(16)).clamp(14.0, 18.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Icon Box
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: topic.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: SvgPicture.asset(
                topic.icon,
                colorFilter: topic.useOriginalColor
                    ? null
                    : ColorFilter.mode(topic.color, BlendMode.srcIn),
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
          SizedBox(width: (context.scale(16)).clamp(12.0, 18.0)),

          // Title & Subtitle Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: TextStyle(
                    fontSize: context.sp(17),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${topic.articles.length} articles',
                  style: TextStyle(
                    fontSize: context.sp(13),
                    color: const Color(0xFF94A3B8),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    HelpArticle article,
    int index,
    bool isExpanded,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: (context.scaleH(12)).clamp(8.0, 14.0)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleArticle(index),
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: EdgeInsets.all((context.scale(16)).clamp(14.0, 18.0)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Question + Animated Chevron)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        article.question,
                        style: TextStyle(
                          fontSize: context.sp(14.5),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: SvgPicture.asset(
                        AppIcons.arrowDropDownSvg,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF94A3B8),
                          BlendMode.srcIn,
                        ),
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ],
                ),

                // Expanded Answer Body
                if (isExpanded) ...[
                  SizedBox(height: (context.scaleH(12)).clamp(8.0, 14.0)),
                  Text(
                    article.answer,
                    style: TextStyle(
                      fontSize: context.sp(13.5),
                      height: 1.55,
                      color: const Color(0xFF64748B),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStillNeedHelpCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: (context.scale(20)).clamp(16.0, 24.0),
        vertical: (context.scaleH(22)).clamp(18.0, 26.0),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Still need help?',
            style: TextStyle(
              fontSize: context.sp(16.5),
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          SizedBox(height: (context.scaleH(5)).clamp(3.0, 8.0)),
          Text(
            'Our support team is always ready to help you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(13),
              color: const Color(0xFF64748B),
              fontFamily: AppStrings.fontInter,
            ),
          ),
          SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.contactUs);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: (context.scale(26)).clamp(20.0, 32.0),
                vertical: (context.scaleH(13)).clamp(11.0, 15.0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppIcons.supportSvg,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contact Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.bold,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
