import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/support/terms_conditions_viewmodel.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  Widget _buildSectionCard(BuildContext context, TermsSection section) {
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
                  width: context.scale(26),
                  height: context.scale(26),
                  decoration: BoxDecoration(
                    color: section.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      section.number,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.bold,
                      ),
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
            child: _buildSectionContent(context, section),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, TermsSection section) {
    if (section.bullets.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.hasHighlightedText) ...[
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: context.sp(13),
                  color: AppColors.slate600,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: section.prefixText ?? ''),
                  TextSpan(
                    text: section.highlightedWord ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: section.highlightColor ?? section.color,
                    ),
                  ),
                  TextSpan(text: section.suffixText ?? ''),
                ],
              ),
            ),
            SizedBox(height: context.scaleH(10)),
          ] else if (section.introText != null) ...[
            Text(
              section.introText!,
              style: TextStyle(
                fontSize: context.sp(13),
                color: AppColors.slate600,
                height: 1.4,
              ),
            ),
            SizedBox(height: context.scaleH(10)),
          ],
          ...section.bullets.map(
            (bullet) => _buildBulletItem(context, bullet, section.color),
          ),
        ],
      );
    }

    if (section.hasHighlightedText) {
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: context.sp(13),
            color: AppColors.slate600,
            height: 1.5,
          ),
          children: [
            TextSpan(text: section.prefixText ?? ''),
            TextSpan(
              text: section.highlightedWord ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: section.highlightColor ?? AppColors.slate900,
              ),
            ),
            TextSpan(text: section.suffixText ?? ''),
          ],
        ),
      );
    }

    return Text(
      section.bodyText ?? '',
      style: TextStyle(
        fontSize: context.sp(13),
        height: 1.5,
        color: AppColors.slate600,
      ),
    );
  }

  Widget _buildBulletItem(
    BuildContext context,
    TermsBullet bullet,
    Color bulletColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.scaleH(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: context.scaleH(4)),
            child: bullet.isProhibited
                ? Container(
                    width: context.scale(14),
                    height: context.scale(14),
                    decoration: const BoxDecoration(
                      color: AppColors.softRed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        size: context.scale(10),
                        color: AppColors.primaryRed,
                      ),
                    ),
                  )
                : Container(
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
    final viewModel = context.watch<TermsConditionsViewModel>();

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
          'Terms & Conditions',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppIcons.downloadSvg,
              colorFilter: const ColorFilter.mode(
                AppColors.slate800,
                BlendMode.srcIn,
              ),
              width: 20,
              height: 20,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloading Terms & Conditions copy...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.hMargin),
            child: Column(
              children: [
                // Header Gradient Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: context.scaleH(24),
                    horizontal: context.scale(20),
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.blue700, AppColors.primaryBlue],
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
                        width: context.scale(54),
                        height: context.scale(54),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.newspaperSvg,
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
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: context.sp(22),
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: context.scaleH(4)),
                      Text(
                        'Last updated: January 2024',
                        style: TextStyle(
                          fontSize: context.sp(12),
                          color: AppColors.white.withValues(alpha: 0.8),
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
                    'Welcome to DesiConnect. By using our platform, you agree to these Terms & Conditions. Please read them carefully before using the app.',
                    style: TextStyle(
                      fontSize: context.sp(13),
                      height: 1.5,
                      color: AppColors.slate600,
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(16)),

                // Sections dynamically rendered from ViewModel
                ...viewModel.sections.map(
                  (section) => Padding(
                    padding: EdgeInsets.only(bottom: context.scaleH(16)),
                    child: _buildSectionCard(context, section),
                  ),
                ),
                SizedBox(height: context.scaleH(4)),

                // Questions about our Terms? Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.scale(18)),
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
                    children: [
                      Text(
                        'Questions about our Terms?',
                        style: TextStyle(
                          fontSize: context.sp(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate700,
                        ),
                      ),
                      SizedBox(height: context.scaleH(12)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.contactUs);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
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
                                AppIcons.emailSvg,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                                width: context.scale(18),
                                height: context.scale(18),
                              ),
                              SizedBox(width: context.scale(8)),
                              Text(
                                'Contact Us',
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
