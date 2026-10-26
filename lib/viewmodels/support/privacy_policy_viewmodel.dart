import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';

class PrivacyPolicySection {
  final String number;
  final String title;
  final Color color;
  final Color lightBg;
  final String? iconSvg;
  final String? introText;
  final bool hasHighlightedIntro;
  final List<PrivacyBullet> bullets;
  final String? bodyText;
  final bool hasContactAction;

  const PrivacyPolicySection({
    required this.number,
    required this.title,
    required this.color,
    required this.lightBg,
    this.iconSvg,
    this.introText,
    this.hasHighlightedIntro = false,
    this.bullets = const [],
    this.bodyText,
    this.hasContactAction = false,
  });
}

class PrivacyBullet {
  final String text;
  final bool isCheck;

  const PrivacyBullet({
    required this.text,
    this.isCheck = false,
  });
}

class PrivacyPolicyViewModel extends ChangeNotifier {
  List<PrivacyPolicySection> get sections => _sections;

  static const List<PrivacyPolicySection> _sections = [
    PrivacyPolicySection(
      number: '1',
      title: 'Information We Collect',
      color: AppColors.primaryBlue,
      lightBg: AppColors.lightBlue,
      introText:
          'We collect the following types of information when you use DesiConnect:',
      bullets: [
        PrivacyBullet(text: 'Personal info (name, email, phone number)'),
        PrivacyBullet(text: 'Profile data (photos, listings, preferences)'),
        PrivacyBullet(text: 'Device & usage data (IP address, browser type)'),
        PrivacyBullet(text: 'Location data (only when you permit)'),
      ],
    ),
    PrivacyPolicySection(
      number: '2',
      title: 'How We Use Your Data',
      color: AppColors.emerald,
      lightBg: AppColors.softGreen,
      bullets: [
        PrivacyBullet(
          text: 'To provide and improve our services',
          isCheck: true,
        ),
        PrivacyBullet(
          text: 'To verify your identity and prevent fraud',
          isCheck: true,
        ),
        PrivacyBullet(
          text: 'To send important updates and notifications',
          isCheck: true,
        ),
        PrivacyBullet(
          text: 'To personalize your experience',
          isCheck: true,
        ),
      ],
    ),
    PrivacyPolicySection(
      number: '3',
      title: 'Data Sharing',
      color: AppColors.amber700,
      lightBg: AppColors.amber100,
      hasHighlightedIntro: true,
      bullets: [
        PrivacyBullet(
          text: 'Payment processors (Stripe) — for secure transactions',
        ),
        PrivacyBullet(
          text: 'Legal authorities — only when required by law',
        ),
      ],
    ),
    PrivacyPolicySection(
      number: '4',
      title: 'Your Rights',
      color: AppColors.pink700,
      lightBg: AppColors.pinkBg,
      bullets: [
        PrivacyBullet(text: 'Access and download your data anytime'),
        PrivacyBullet(text: 'Request correction of inaccurate data'),
        PrivacyBullet(text: 'Request deletion of your account and data'),
        PrivacyBullet(text: 'Opt out of marketing communications'),
      ],
    ),
    PrivacyPolicySection(
      number: '5',
      title: 'Data Security',
      color: AppColors.primaryPurple,
      lightBg: AppColors.purpleLight100,
      bodyText:
          'We protect your data using 256-bit SSL encryption, secure servers, and regular security audits. Payment data is handled exclusively by Stripe — we never store your card details.',
    ),
    PrivacyPolicySection(
      number: '6',
      title: 'Contact Us',
      color: AppColors.primaryRed,
      lightBg: AppColors.softRed,
      iconSvg: AppIcons.emailSvg,
      introText:
          'If you have any questions about this Privacy Policy, please contact us:',
      hasContactAction: true,
    ),
  ];
}
