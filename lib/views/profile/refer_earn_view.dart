import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/coming_soon_dialog.dart';

class ReferEarnView extends StatelessWidget {
  const ReferEarnView({super.key});

  static const String _referralCode = 'DESI2024';

  void _showComingSoon(BuildContext context) {
    ComingSoonDialog.show(
      context,
      title: 'Coming Soon',
      featureName: 'Refer & Earn',
      message:
          'Refer & Earn is currently under development. Soon you will be able to share your referral code, invite friends, and earn exciting cash & credit rewards!',
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        _showComingSoon(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppColors.slate900,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Refer & Earn',
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
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.hMargin,
              vertical: (context.scaleH(16)).clamp(12.0, 20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Hero Card with Referral Code & Invite Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.cardPad),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1D4ED8),
                        Color(0xFF3B82F6),
                        Color(0xFF7C3AED),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Gift Icon
                      Container(
                        width: (context.scale(54)).clamp(44.0, 60.0),
                        height: (context.scale(54)).clamp(44.0, 60.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.giftSvg,
                            width: (context.scale(30)).clamp(24.0, 34.0),
                            height: (context.scale(30)).clamp(24.0, 34.0),
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFFBBF24),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: (context.scaleH(12)).clamp(8.0, 14.0)),
                      Text(
                        'Invite Friends\nGet Rewards',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(21),
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: (context.scaleH(6)).clamp(4.0, 8.0)),
                      Text(
                        'Share your code and earn rewards\nwhen your friends join DesiConnect.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: context.sp(12.5),
                          height: 1.35,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),

                      // Referral Code Box
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: (context.scale(16)).clamp(12.0, 20.0),
                          vertical: (context.scaleH(12)).clamp(8.0, 14.0),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Your Referral Code',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: context.sp(11),
                                fontWeight: FontWeight.w500,
                                fontFamily: AppStrings.fontInter,
                              ),
                            ),
                            SizedBox(
                              height: (context.scaleH(6)).clamp(4.0, 8.0),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 48), // Spacer to balance
                                Expanded(
                                  child: Text(
                                    _referralCode,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.sp(20),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2.0,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ),
                                // Copy Button
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                      const ClipboardData(text: _referralCode),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Referral code copied to clipboard!',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: (context.scale(
                                        12,
                                      )).clamp(8.0, 16.0),
                                      vertical: (context.scaleH(
                                        6,
                                      )).clamp(4.0, 8.0),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(
                                          AppIcons.restartSvg,
                                          width: 14,
                                          height: 14,
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFF2563EB),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Copy',
                                          style: TextStyle(
                                            color: const Color(0xFF2563EB),
                                            fontSize: context.sp(12),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppStrings.fontInter,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),

                      // Full-Width White Invite Button
                      SizedBox(
                        width: double.infinity,
                        height: (context.scaleH(48)).clamp(44.0, 52.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showComingSoon(context);
                          },
                          icon: SvgPicture.asset(
                            AppIcons.shareSvg,
                            width: (context.scale(18)).clamp(16.0, 20.0),
                            height: (context.scale(18)).clamp(16.0, 20.0),
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF2563EB),
                              BlendMode.srcIn,
                            ),
                          ),
                          label: Text(
                            'Invite Friends',
                            style: TextStyle(
                              color: const Color(0xFF2563EB),
                              fontSize: context.sp(15),
                              fontWeight: FontWeight.bold,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),

                // 2. Stats Grid (3 Cards)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '12',
                        'Friends Invited',
                        const Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: (context.scale(10)).clamp(6.0, 12.0)),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '8',
                        'Friends Joined',
                        const Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(width: (context.scale(10)).clamp(6.0, 12.0)),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '€40',
                        'Earned',
                        const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),

                // 3. How It Works Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.cardPad),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.2,
                    ),
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
                      Text(
                        'How it works?',
                        style: TextStyle(
                          fontSize: context.sp(15.5),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      SizedBox(height: (context.scaleH(16)).clamp(12.0, 20.0)),
                      _buildStepRow(
                        context,
                        svgIcon: AppIcons.shareSvg,
                        iconColor: const Color(0xFF2563EB),
                        iconBgColor: const Color(0xFFEFF6FF),
                        title: '1. Invite Friend',
                        subtitle: 'Share your code with friends',
                      ),
                      SizedBox(height: (context.scaleH(14)).clamp(10.0, 16.0)),
                      _buildStepRow(
                        context,
                        svgIcon: AppIcons.personSvg,
                        iconColor: const Color(0xFF10B981),
                        iconBgColor: const Color(0xFFECFDF5),
                        title: '2. They Join',
                        subtitle: 'Friend registers with your code',
                      ),
                      SizedBox(height: (context.scaleH(14)).clamp(10.0, 16.0)),
                      _buildStepRow(
                        context,
                        svgIcon: AppIcons.giftSvg,
                        iconColor: const Color(0xFFF59E0B),
                        iconBgColor: const Color(0xFFFFFBEB),
                        title: '3. You Earn',
                        subtitle: 'Get €5 reward for each friend',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: (context.scaleH(20)).clamp(14.0, 24.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: (context.scaleH(16)).clamp(12.0, 18.0),
        horizontal: (context.scale(8)).clamp(4.0, 10.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: context.sp(22),
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          SizedBox(height: (context.scaleH(4)).clamp(2.0, 6.0)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(11),
              color: const Color(0xFF64748B),
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context, {
    required String svgIcon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    final double iconBoxSize = (context.scale(44)).clamp(38.0, 48.0);
    final double svgSize = (context.scale(20)).clamp(18.0, 22.0);

    return Row(
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Center(
            child: SvgPicture.asset(
              svgIcon,
              width: svgSize,
              height: svgSize,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
        ),
        SizedBox(width: (context.scale(14)).clamp(10.0, 16.0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: context.sp(12),
                  color: const Color(0xFF64748B),
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
