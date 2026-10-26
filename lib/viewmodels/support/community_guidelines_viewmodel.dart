import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';

class GuidelineSection {
  final String title;
  final String iconSvg;
  final Color color;
  final Color lightBg;
  final String? subtitle;
  final List<GuidelineBullet> bullets;

  const GuidelineSection({
    required this.title,
    required this.iconSvg,
    required this.color,
    required this.lightBg,
    this.subtitle,
    required this.bullets,
  });
}

class GuidelineBullet {
  final String text;
  final Color? dotColor;
  final bool isWarning;

  const GuidelineBullet({
    required this.text,
    this.dotColor,
    this.isWarning = false,
  });
}

class CommunityGuidelinesViewModel extends ChangeNotifier {
  List<GuidelineSection> get sections => _sections;

  static const List<GuidelineSection> _sections = [
    GuidelineSection(
      title: 'Be Respectful',
      iconSvg: AppIcons.favSvg,
      color: AppColors.primaryBlue,
      lightBg: AppColors.lightBlue,
      bullets: [
        GuidelineBullet(
          text: 'Treat all members with kindness and respect',
          dotColor: AppColors.emerald,
        ),
        GuidelineBullet(
          text: 'No hate speech, racism or discrimination',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'No bullying, harassment or threats',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'Respect cultural and religious differences',
          dotColor: AppColors.emerald,
        ),
      ],
    ),
    GuidelineSection(
      title: 'Honest Listings',
      iconSvg: AppIcons.couponSvg,
      color: AppColors.amber700,
      lightBg: AppColors.amber100,
      bullets: [
        GuidelineBullet(
          text: 'Post only genuine jobs, rooms and items',
          dotColor: AppColors.emerald,
        ),
        GuidelineBullet(
          text: 'Use accurate descriptions and real photos',
          dotColor: AppColors.emerald,
        ),
        GuidelineBullet(
          text: 'No false or misleading pricing',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'No duplicate or spam posts',
          dotColor: AppColors.primaryRed,
        ),
      ],
    ),
    GuidelineSection(
      title: 'Prohibited Content',
      iconSvg: AppIcons.errorSvg,
      color: AppColors.primaryRed,
      lightBg: AppColors.softRed,
      bullets: [
        GuidelineBullet(
          text: 'Weapons, drugs or illegal items',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'Adult or sexually explicit content',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'Stolen or counterfeit goods',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'Scams, threat or phishing attempts',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'Misinformation or fake news',
          dotColor: AppColors.primaryRed,
        ),
      ],
    ),
    GuidelineSection(
      title: 'Protect Privacy',
      iconSvg: AppIcons.lockSvg,
      color: AppColors.primaryPurple,
      lightBg: AppColors.purpleLight100,
      bullets: [
        GuidelineBullet(
          text: "Do not share others' personal information",
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'No recording or screenshots of private chats',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'Report suspicious activity immediately',
          dotColor: AppColors.emerald,
        ),
      ],
    ),
    GuidelineSection(
      title: 'Safe Meetings',
      iconSvg: AppIcons.shakeHandSvg,
      color: AppColors.emerald,
      lightBg: AppColors.softGreen,
      bullets: [
        GuidelineBullet(
          text: 'Meet in public places (cafes, malls)',
          dotColor: AppColors.emerald,
        ),
        GuidelineBullet(
          text: 'Verify items before paying',
          dotColor: AppColors.emerald,
        ),
        GuidelineBullet(
          text: 'Use in-app payment for security',
          dotColor: AppColors.emerald,
        ),
        GuidelineBullet(
          text: 'Never share bank details or passwords',
          dotColor: AppColors.primaryRed,
        ),
      ],
    ),
    GuidelineSection(
      title: 'Enforcement',
      iconSvg: AppIcons.blockShieldSvg,
      color: AppColors.pink700,
      lightBg: AppColors.pinkBg,
      subtitle: 'Violations of these guidelines may result in:',
      bullets: [
        GuidelineBullet(
          text: 'Content removal',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'Temporary account suspension',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'Permanent account ban',
          dotColor: AppColors.primaryRed,
        ),
        GuidelineBullet(
          text: 'Legal action where applicable',
          dotColor: AppColors.primaryRed,
        ),
      ],
    ),
  ];
}
