import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TermsSection {
  final String number;
  final String title;
  final Color color;
  final Color lightBg;
  final String? introText;
  final List<TermsBullet> bullets;
  final String? bodyText;
  final bool hasHighlightedText;
  final String? prefixText;
  final String? highlightedWord;
  final Color? highlightColor;
  final String? suffixText;

  const TermsSection({
    required this.number,
    required this.title,
    required this.color,
    required this.lightBg,
    this.introText,
    this.bullets = const [],
    this.bodyText,
    this.hasHighlightedText = false,
    this.prefixText,
    this.highlightedWord,
    this.highlightColor,
    this.suffixText,
  });
}

class TermsBullet {
  final String text;
  final bool isProhibited;

  const TermsBullet({required this.text, this.isProhibited = false});
}

class TermsConditionsViewModel extends ChangeNotifier {
  List<TermsSection> get sections => _sections;

  static const List<TermsSection> _sections = [
    TermsSection(
      number: '1',
      title: 'Account Registration',
      color: AppColors.primaryBlue,
      lightBg: AppColors.lightBlue,
      introText: 'To use DesiConnect, you must:',
      bullets: [
        TermsBullet(text: 'Be at least 18 years old'),
        TermsBullet(text: 'Provide accurate and truthful information'),
        TermsBullet(text: 'Keep your account credentials secure'),
        TermsBullet(text: 'Maintain only one account per person'),
      ],
    ),
    TermsSection(
      number: '2',
      title: 'Acceptable Use',
      color: AppColors.emerald,
      lightBg: AppColors.softGreen,
      hasHighlightedText: true,
      prefixText: 'You agree ',
      highlightedWord: 'not',
      highlightColor: AppColors.primaryRed,
      suffixText: ' to use DesiConnect to:',
      bullets: [
        TermsBullet(
          text: 'Post fraudulent or misleading content',
          isProhibited: true,
        ),
        TermsBullet(text: 'Harass or abuse other users', isProhibited: true),
        TermsBullet(
          text: 'Sell prohibited items (weapons, drugs, stolen goods)',
          isProhibited: true,
        ),
        TermsBullet(
          text: 'Spam or send unsolicited messages',
          isProhibited: true,
        ),
        TermsBullet(text: 'Create multiple accounts', isProhibited: true),
      ],
    ),

    TermsSection(
      number: '3',
      title: 'Privacy & Data',
      color: AppColors.pink700,
      lightBg: AppColors.pinkBg,
      bodyText:
          'We collect only data necessary to provide our services. We never sell your personal data to third parties. Your data is stored securely and protected with industry-standard encryption. You can request data deletion at any time.',
      hasHighlightedText: true,
      prefixText: 'We collect only data necessary to provide our services. We ',
      highlightedWord: 'never sell',
      highlightColor: AppColors.slate900,
      suffixText:
          ' your personal data to third parties. Your data is stored securely and protected with industry-standard encryption. You can request data deletion at any time.',
    ),
    TermsSection(
      number: '4',
      title: 'Content & Rights',
      color: AppColors.primaryPurple,
      lightBg: AppColors.purpleLight100,
      bodyText:
          'You own the content you post on DesiConnect. By posting, you grant us a license to display it on our platform. We reserve the right to remove any content that violates these terms without notice.',
    ),
    TermsSection(
      number: '5',
      title: 'Termination',
      color: AppColors.primaryRed,
      lightBg: AppColors.softRed,
      bodyText:
          'We reserve the right to suspend or terminate accounts that violate these terms. You may also delete your account at any time from Settings -> Security -> Delete Account.',
    ),
  ];
}
