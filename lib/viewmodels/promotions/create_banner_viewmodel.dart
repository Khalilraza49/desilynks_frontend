import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/banner_ad_model.dart';
import '../../repositories/banner_ad_repository.dart';
import '../../services/permissions/permission_service.dart';

class CreateBannerViewModel extends ChangeNotifier {
  final BannerAdRepository? _repository;

  CreateBannerViewModel([this._repository]);

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ctaButtonTextController = TextEditingController();
  final TextEditingController destinationLinkController =
      TextEditingController();

  BannerAdPosition _selectedPosition = BannerAdPosition.homeScreen;
  BannerAdPosition get selectedPosition => _selectedPosition;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setSelectedPosition(BannerAdPosition position) {
    _selectedPosition = position;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source, {BuildContext? context}) async {
    final bool hasPermission;
    if (source == ImageSource.camera) {
      hasPermission = await PermissionService.requestCamera(context);
    } else {
      hasPermission = await PermissionService.requestGallery(context);
    }
    if (!hasPermission) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final length = await file.length();
        // 4 MB maximum limit
        if (length > 4 * 1024 * 1024) {
          _errorMessage = 'Image size must be less than 4 MB';
          notifyListeners();
          return;
        }

        _selectedImage = file;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  void removeImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void resetForm({BannerAdPosition? position}) {
    _selectedImage = null;
    titleController.clear();
    descriptionController.clear();
    ctaButtonTextController.clear();
    destinationLinkController.clear();
    _selectedPosition = position ?? BannerAdPosition.homeScreen;
    _isSubmitting = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<BannerAdModel?> submitBanner() async {
    if (_repository == null) {
      _errorMessage = 'Banner ad service is not available';
      notifyListeners();
      return null;
    }

    if (_selectedImage == null) {
      _errorMessage = 'Please choose an image for your banner';
      notifyListeners();
      return null;
    }

    final title = titleController.text.trim();
    if (title.isEmpty) {
      _errorMessage = 'Please enter a title';
      notifyListeners();
      return null;
    }
    if (title.length > 100) {
      _errorMessage = 'Title must be 100 characters or less';
      notifyListeners();
      return null;
    }

    final description = descriptionController.text.trim();
    if (description.isEmpty) {
      _errorMessage = 'Please enter a description';
      notifyListeners();
      return null;
    }
    if (description.length > 400) {
      _errorMessage = 'Description must be 400 characters or less';
      notifyListeners();
      return null;
    }

    final ctaText = ctaButtonTextController.text.trim();
    if (ctaText.isEmpty) {
      _errorMessage = 'Please enter CTA button text';
      notifyListeners();
      return null;
    }
    if (ctaText.length > 30) {
      _errorMessage = 'CTA button text must be 30 characters or less';
      notifyListeners();
      return null;
    }

    String link = destinationLinkController.text.trim();
    if (link.isEmpty) {
      _errorMessage = 'Please enter a destination link';
      notifyListeners();
      return null;
    }

    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      link = 'https://$link';
      destinationLinkController.text = link;
    }

    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      _errorMessage = 'Please enter a valid URL (e.g. https://example.com)';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final banner = await _repository.createBannerAd(
        photo: _selectedImage!,
        title: title,
        description: description,
        ctaButtonText: ctaText,
        destinationLink: link,
        position: _selectedPosition.value,
      );

      _isSubmitting = false;
      notifyListeners();
      return banner;
    } catch (e) {
      _isSubmitting = false;
      // Extract human-friendly error message
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      _errorMessage = message;
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    ctaButtonTextController.dispose();
    destinationLinkController.dispose();
    super.dispose();
  }
}
