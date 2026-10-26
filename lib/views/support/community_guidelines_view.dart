import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/support/community_guidelines_viewmodel.dart';

class CommunityGuidelinesView extends StatelessWidget {
  const CommunityGuidelinesView({super.key});

  Widget _buildSectionCard(BuildContext context, GuidelineSection section) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
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
          // Header banner
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.scale(16),
              vertical: context.scaleH(12),
            ),
            decoration: BoxDecoration(
              color: section.lightBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.borderRadius16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: context.scale(28),
                  height: context.scale(28),
                  decoration: BoxDecoration(
                    color: section.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      section.iconSvg,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                      width: context.scale(15),
                      height: context.scale(15),
                    ),
                  ),
                ),
                SizedBox(width: context.scale(10)),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.bold,
                      color: section.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(context.scale(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (section.subtitle != null) ...[
                  Text(
                    section.subtitle!,
                    style: TextStyle(
                      fontSize: context.sp(13),
                      color: AppColors.slate600,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: context.scaleH(10)),
                ],
                ...section.bullets.map(
                  (bullet) => _buildBullet(context, bullet),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(BuildContext context, GuidelineBullet bullet) {
    final Color bulletColor =
        bullet.dotColor ??
        (bullet.isWarning ? AppColors.primaryRed : AppColors.emerald);

    return Padding(
      padding: EdgeInsets.only(bottom: context.scaleH(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: context.scaleH(5)),
            child: Container(
              width: context.scale(6),
              height: context.scale(6),
              decoration: BoxDecoration(
                color: bulletColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: context.scale(10)),
          Expanded(
            child: Text(
              bullet.text,
              style: TextStyle(
                fontSize: context.sp(13),
                height: 1.45,
                color: AppColors.slate700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch viewmodel for MVVM pattern
    final viewModel = context.watch<CommunityGuidelinesViewModel>();

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
            width: 20,
            height: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Community Guidelines',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.hMargin),
            child: Column(
              children: [
                // Top Green Gradient Header Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: context.scaleH(24),
                    horizontal: context.scale(20),
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.green600, AppColors.emerald],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius20,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: context.scale(54),
                        height: context.scale(54),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.pcommunitySvg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                            width: context.scale(26),
                            height: context.scale(26),
                          ),
                        ),
                      ),
                      SizedBox(height: context.scaleH(12)),
                      Text(
                        'Community Guidelines',
                        style: TextStyle(
                          fontSize: context.sp(22),
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: context.scaleH(4)),
                      Text(
                        'Rules for a safe & respectful community',
                        style: TextStyle(
                          fontSize: context.sp(12),
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.scaleH(16)),

                // Intro Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.scale(16)),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius16,
                    ),
                    border: Border.all(color: AppColors.slate100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'DesiConnect is built on respect, trust and community. These guidelines help keep our platform safe and welcoming for everyone. Violations may result in account suspension or permanent ban.',
                    style: TextStyle(
                      fontSize: context.sp(13),
                      height: 1.5,
                      color: AppColors.slate600,
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(16)),

                // Section Cards dynamically rendered from ViewModel
                ...viewModel.sections.map(
                  (section) => Padding(
                    padding: EdgeInsets.only(bottom: context.scaleH(16)),
                    child: _buildSectionCard(context, section),
                  ),
                ),
                SizedBox(height: context.scaleH(4)),

                // See something wrong? Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.scale(18)),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius16,
                    ),
                    border: Border.all(
                      color: AppColors.emerald.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'See something wrong?',
                        style: TextStyle(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.bold,
                          color: AppColors.green700,
                        ),
                      ),
                      SizedBox(height: context.scaleH(4)),
                      Text(
                        'Help keep our community safe by reporting violations',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.sp(12),
                          color: AppColors.slate600,
                        ),
                      ),
                      SizedBox(height: context.scaleH(14)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Report violation dialogue opened...',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: context.scaleH(14),
                            ),
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
                                AppIcons.errorSvg,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                                width: context.scale(18),
                                height: context.scale(18),
                              ),
                              SizedBox(width: context.scale(8)),
                              Text(
                                'Report a Violation',
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
                SizedBox(height: context.scaleH(30)),

                // Footer
                Text(
                  '© 2024 DesiConnect. All rights reserved.',
                  style: TextStyle(
                    fontSize: context.sp(12),
                    color: AppColors.slate400,
                  ),
                ),
                SizedBox(height: context.scaleH(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
