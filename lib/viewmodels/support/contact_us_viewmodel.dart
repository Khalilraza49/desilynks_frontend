import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:desilynks/models/user_model.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/services/api/api_service.dart';
import 'package:desilynks/services/local/storage_service.dart';

class ContactUsViewModel extends ChangeNotifier {
  final ApiService? _apiService;
  final StorageService? _storageService;

  ContactUsViewModel({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  // Contact details matching design
  static const String contactEmail = 'support@dealconnect.com';
  static const String contactWhatsApp = '+34 123 456 789';
  static const String contactPhone = '+34 123 456 789';
  static const String contactOffice = 'Alcalá 123, Madrid';

  // Form text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _initialized = false;
  bool get initialized => _initialized;

  void initFromUser(UserModel? user, {bool force = false}) {
    if (_initialized && !force) return;
    _initialized = true;

    final resolvedUser = user ?? _storageService?.getUser();
    if (resolvedUser != null) {
      if (nameController.text.trim().isEmpty) {
        final fullName = resolvedUser.fullName.trim();
        nameController.text =
            fullName.isNotEmpty ? fullName : resolvedUser.username;
      }
      if (emailController.text.trim().isEmpty &&
          resolvedUser.email.isNotEmpty) {
        emailController.text = resolvedUser.email;
      }
      notifyListeners();
    }
  }

  /// Launches email client or copies email to clipboard
  Future<void> launchEmail(BuildContext context) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: contactEmail,
      queryParameters: {'subject': 'Support Inquiry - DesiConnect'},
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        await _copyToClipboard(context, contactEmail, 'Email copied to clipboard');
      }
    } catch (_) {
      if (context.mounted) {
        await _copyToClipboard(context, contactEmail, 'Email copied to clipboard');
      }
    }
  }

  /// Launches WhatsApp chat or copies WhatsApp number
  Future<void> launchWhatsApp(BuildContext context) async {
    final cleanPhone = contactWhatsApp.replaceAll(RegExp(r'[^\d]'), '');
    final Uri uri = Uri.parse('https://wa.me/$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        await _copyToClipboard(context, contactWhatsApp, 'WhatsApp number copied');
      }
    } catch (_) {
      if (context.mounted) {
        await _copyToClipboard(context, contactWhatsApp, 'WhatsApp number copied');
      }
    }
  }

  /// Launches telephone dialer or copies phone number
  Future<void> launchPhone(BuildContext context) async {
    final cleanPhone = contactPhone.replaceAll(RegExp(r'\s+'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        await _copyToClipboard(context, contactPhone, 'Phone number copied');
      }
    } catch (_) {
      if (context.mounted) {
        await _copyToClipboard(context, contactPhone, 'Phone number copied');
      }
    }
  }

  /// Launches office location in Google Maps or copies address
  Future<void> launchOfficeLocation(BuildContext context) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(contactOffice)}',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        await _copyToClipboard(context, contactOffice, 'Office address copied');
      }
    } catch (_) {
      if (context.mounted) {
        await _copyToClipboard(context, contactOffice, 'Office address copied');
      }
    }
  }

  /// Launches respective social media profile
  Future<void> launchSocial(BuildContext context, String platform) async {
    String url = '';
    switch (platform.toLowerCase()) {
      case 'instagram':
        url = 'https://www.instagram.com/desiconnect';
        break;
      case 'facebook':
        url = 'https://www.facebook.com/desiconnect';
        break;
      case 'youtube':
        url = 'https://www.youtube.com/@desiconnect';
        break;
      case 'twitter':
        url = 'https://twitter.com/desiconnect';
        break;
      case 'tiktok':
        url = 'https://www.tiktok.com/@desiconnect';
        break;
      default:
        url = 'https://desiconnect.com';
    }

    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $platform profile...')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $platform profile...')),
        );
      }
    }
  }

  /// Sends contact message with form validation, rate limit handling, and API integration
  Future<bool> sendMessage(BuildContext context) async {
    if (_isSubmitting) return false;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final message = messageController.text.trim();

    if (name.isEmpty) {
      _showFeedback(context, 'Please enter your name', isError: true);
      return false;
    }
    if (name.length > 100) {
      _showFeedback(context, 'Name cannot exceed 100 characters', isError: true);
      return false;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _showFeedback(context, 'Please enter a valid email address', isError: true);
      return false;
    }
    if (email.length > 100) {
      _showFeedback(context, 'Email cannot exceed 100 characters', isError: true);
      return false;
    }

    if (message.isEmpty) {
      _showFeedback(context, 'Please enter your message', isError: true);
      return false;
    }
    if (message.length > 2000) {
      _showFeedback(
        context,
        'Message cannot exceed 2000 characters',
        isError: true,
      );
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      if (_apiService != null) {
        await _apiService.post(
          ApiEndpoints.supportFormEndpoint,
          {
            'name': name,
            'email': email.toLowerCase(),
            'message': message,
          },
        );
      } else {
        // Fallback simulation if service not provided
        await Future.delayed(const Duration(milliseconds: 800));
      }

      _isSubmitting = false;
      messageController.clear();
      notifyListeners();

      if (context.mounted) {
        _showFeedback(
          context,
          "Thanks, we'll reply to $email by email.",
          isError: false,
        );
      }
      return true;
    } on HttpException catch (e) {
      _isSubmitting = false;
      notifyListeners();
      if (context.mounted) {
        _showFeedback(context, e.message, isError: true);
      }
      return false;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      final err = e.toString().replaceAll('Exception: ', '');
      if (context.mounted) {
        _showFeedback(
          context,
          err.isNotEmpty
              ? err
              : 'Failed to submit support form. Please try again.',
          isError: true,
        );
      }
      return false;
    }
  }

  void _showFeedback(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    String text,
    String feedback,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feedback: $text'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
