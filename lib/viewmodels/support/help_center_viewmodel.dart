import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/constants/app_icons.dart';

class HelpArticle {
  final String question;
  final String answer;

  const HelpArticle({
    required this.question,
    required this.answer,
  });
}

class HelpTopicItem {
  final String title;
  final String icon;
  final Color color;
  final Color bgColor;
  final String desc;
  final bool useOriginalColor;
  final List<HelpArticle> articles;

  const HelpTopicItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.desc,
    this.useOriginalColor = false,
    this.articles = const [],
  });
}

class HelpCenterViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  HelpCenterViewModel() {
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    notifyListeners();
  }

  void onContactSupport(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.contactUs);
  }

  static const List<HelpTopicItem> popularTopics = [
    HelpTopicItem(
      title: 'How to post an ad',
      icon: AppIcons.adBadgeSvg,
      color: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
      useOriginalColor: true,
      desc:
          'Learn how to post room listings, jobs, marketplace products, or services easily.',
      articles: [
        HelpArticle(
          question: 'How do I post a new ad?',
          answer:
              'Go to Marketplace \u2192 tap the + button \u2192 fill in details (title, price, photos, description, location) \u2192 tap Post. Your ad will be live immediately.',
        ),
        HelpArticle(
          question: 'How many photos can I add?',
          answer:
              'Free members can upload up to 5 photos per listing. Upgrading to a Premium or Golden plan increases your limit up to 15 high-definition images.',
        ),
        HelpArticle(
          question: 'Can I edit my ad after posting?',
          answer:
              'Yes, navigate to Profile \u2192 My Ads, select the listing you wish to modify, and tap "Edit Ad" to update details, pricing, photos, or description at any time.',
        ),
        HelpArticle(
          question: 'How long does my ad stay active?',
          answer:
              'Standard ads stay active for 30 days. You can easily bump, renew, or extend your ad duration directly from your My Ads dashboard.',
        ),
        HelpArticle(
          question: 'Why was my ad removed?',
          answer:
              'Ads may be removed if they violate our safety guidelines, contain prohibited items or services, or receive multiple community violation flags.',
        ),
      ],
    ),
    HelpTopicItem(
      title: 'Membership & Plans',
      icon: AppIcons.crownSvg,
      color: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
      desc:
          'Upgrade to VIP/Golden membership, check benefits, pricing, and billing cycles.',
      articles: [
        HelpArticle(
          question: 'What benefits do Golden members receive?',
          answer:
              'Golden members enjoy top priority ranking in search results, featured golden badges, unlimited ad listings, direct contact links, and 24/7 dedicated support.',
        ),
        HelpArticle(
          question: 'How do I upgrade or change my plan?',
          answer:
              'Navigate to Profile \u2192 Membership Benefits, review the plan tiers, and tap "Upgrade Now". Choose monthly or annual billing to activate immediately.',
        ),
        HelpArticle(
          question: 'Can I cancel my subscription anytime?',
          answer:
              'Yes, you can cancel renewal anytime from Account Settings without cancellation fees. You retain all member perks until the billing period concludes.',
        ),
        HelpArticle(
          question: 'Do membership plans auto-renew?',
          answer:
              'Yes, memberships automatically renew on your cycle date. You will receive an email reminder prior to any upcoming charge.',
        ),
        HelpArticle(
          question: 'Are annual memberships discounted?',
          answer:
              'Yes, choosing annual billing offers savings of up to 20% compared to monthly subscriptions across all tiers.',
        ),
      ],
    ),
    HelpTopicItem(
      title: 'Payments & Refunds',
      icon: AppIcons.cardSvg,
      color: Color(0xFF10B981),
      bgColor: Color(0xFFDCFCE7),
      desc:
          'Manage Stripe payments, refund policies, receipts, and currency conversions.',
      articles: [
        HelpArticle(
          question: 'What payment methods are supported?',
          answer:
              'We accept Visa, MasterCard, American Express, Apple Pay, Google Pay, and Stripe secure online payments.',
        ),
        HelpArticle(
          question: 'Is my payment information secure?',
          answer:
              'Yes, all payment transactions are protected by end-to-end 256-bit SSL encryption processed directly through Stripe PCI-compliant infrastructure.',
        ),
        HelpArticle(
          question: 'How do I request a refund?',
          answer:
              'If you experienced an accidental charge or service issue, contact support within 14 days via the Contact Support button to submit a refund claim.',
        ),
        HelpArticle(
          question: 'Where can I find my invoice or receipt?',
          answer:
              'Payment invoices and VAT receipts are automatically emailed upon payment confirmation and can also be downloaded under Profile \u2192 Payments.',
        ),
      ],
    ),
    HelpTopicItem(
      title: 'Account & Verification',
      icon: AppIcons.shieldSvg,
      color: Color(0xFF8B5CF6),
      bgColor: Color(0xFFF3E8FF),
      desc:
          'Verify your phone number, identity documents, and protect account credentials.',
      articles: [
        HelpArticle(
          question: 'How do I verify my account?',
          answer:
              'Go to Profile \u2192 Verification. Upload a government-issued photo ID and complete the SMS phone number confirmation to earn your verified badge.',
        ),
        HelpArticle(
          question: 'What are the advantages of verification?',
          answer:
              'Verified users gain higher buyer trust, enjoy faster responses, and receive elevated placement across search listings.',
        ),
        HelpArticle(
          question: 'How can I reset my password?',
          answer:
              'On the login screen, tap "Forgot Password", enter your email, and follow the secure link sent to your inbox to set a new password.',
        ),
        HelpArticle(
          question: 'Can I change my registered phone or email?',
          answer:
              'Yes, visit Account Settings \u2192 Personal Info to update your contact details with two-factor authentication.',
        ),
      ],
    ),
    HelpTopicItem(
      title: 'Chat & Messages',
      icon: AppIcons.chatRoundSvg,
      color: Color(0xFFEC4899),
      bgColor: Color(0xFFFFE4E6),
      desc:
          'Instant messaging with buyers, sellers, landlords, and workers in real time.',
      articles: [
        HelpArticle(
          question: 'How do I message an advertiser or worker?',
          answer:
              'Open any ad listing and tap the "Chat" button at the bottom of the screen to begin an instant real-time conversation.',
        ),
        HelpArticle(
          question: 'Can I send photos and attachments in chat?',
          answer:
              'Yes, tap the camera or attachment icon in the chat composer to send product photos, receipts, or condition snapshots.',
        ),
        HelpArticle(
          question: 'How do I block or report a user in chat?',
          answer:
              'Tap the three-dots menu (\u22ee) at the top right of any chat screen and select "Report User" or "Block User" immediately.',
        ),
        HelpArticle(
          question: 'Why am I not receiving notifications for new messages?',
          answer:
              'Please check your phone system notification permissions and verify that in-app alerts are enabled in Profile \u2192 Notifications.',
        ),
      ],
    ),
    HelpTopicItem(
      title: 'Safety & Security',
      icon: AppIcons.warningTriangleSvg,
      color: Color(0xFFEF4444),
      bgColor: Color(0xFFFEE2E2),
      useOriginalColor: true,
      desc:
          'Guidelines for safe meetings, scam prevention, reporting violations, and blocking users.',
      articles: [
        HelpArticle(
          question: 'What safety precautions should I take when meeting?',
          answer:
              'Always meet in a public, well-lit place during daylight hours (e.g. coffee shop, mall). Inspect the product thoroughly before making payment, and never go alone if possible.',
        ),
        HelpArticle(
          question: 'How do I spot common marketplace scams?',
          answer:
              'Be cautious of buyers offering overpayment, checks by mail, or requests to move communications off-platform or to pay via wire transfer.',
        ),
        HelpArticle(
          question: 'How do I report a fraudulent listing or profile?',
          answer:
              'Click the "Report" flag on any suspicious listing or profile. Our moderation team investigates and takes immediate action 24/7.',
        ),
        HelpArticle(
          question: 'How is my personal data protected?',
          answer:
              'We adhere to strict data privacy standards and never sell your personal information. Refer to our Privacy Policy for full details.',
        ),
      ],
    ),
  ];

  List<HelpTopicItem> get filteredTopics {
    if (_searchQuery.isEmpty) return popularTopics;
    final query = _searchQuery.toLowerCase();
    return popularTopics.where((t) {
      return t.title.toLowerCase().contains(query) ||
          t.desc.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
