import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/user_model.dart';
import '../../widgets/image_crop_dialog.dart';
import '../auth/auth_viewmodel.dart';
import '../../services/permissions/permission_service.dart';

class EditProfileViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  bool _showOnPost = true;
  bool get showOnPost => _showOnPost;

  File? _pickedPhoto;
  File? get pickedPhoto => _pickedPhoto;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _initialized = false;
  bool get initialized => _initialized;

  final ImagePicker _picker = ImagePicker();

  void setShowOnPost(bool value) {
    if (_showOnPost == value) return;
    _showOnPost = value;
    notifyListeners();
  }

  void setPickedPhoto(File? photo) {
    _pickedPhoto = photo;
    notifyListeners();
  }

  String formatDobForDisplay(String? dob) {
    if (dob == null || dob.trim().isEmpty || dob == 'dd/mm/yy') return '';
    final trimmed = dob.trim();
    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) {
          int fullYear = y;
          if (fullYear < 100) {
            fullYear += (fullYear > (DateTime.now().year % 100)) ? 1900 : 2000;
          }
          return "${d.toString().padLeft(2, '0')}/${m.toString().padLeft(2, '0')}/$fullYear";
        }
      }
    }
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    }
    return trimmed;
  }

  void initFromUser(UserModel? user, {bool force = false}) {
    if (_initialized && !force) return;
    _initialized = true;

    firstNameController.text = user?.firstName ?? 'Ali';
    lastNameController.text = user?.lastName ?? 'Khan';
    genderController.text = user?.gender ?? 'Male';
    dobController.text = formatDobForDisplay(user?.dateOfBirth);
    phoneController.text = user?.phoneNumber ?? '+34 612 345 420';
    emailController.text = user?.email ?? 'alikhan@gmail.com';

    final addr = user?.address;
    addressController.text = addr?.streetAddress ?? '';
    postalCodeController.text = addr?.postalCode ?? '280001';
    cityController.text = addr?.city ?? 'Madrid';
    provinceController.text = addr?.province ?? 'Community of madrid';
    countryController.text = addr?.country ?? 'Spain';
    _pickedPhoto = null;
    notifyListeners();
  }

  Future<void> pickImage(BuildContext context) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        final isSmall = ctx.isSmall;
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: SvgPicture.asset(
                  AppIcons.cameraSvg,
                  width: isSmall ? 20 : 24,
                  height: isSmall ? 20 : 24,
                ),
                title: Text(
                  'Take Photo from Camera',
                  style: TextStyle(fontSize: ctx.sp(isSmall ? 13.5 : 15)),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: SvgPicture.asset(
                  AppIcons.gallerySvg,
                  width: isSmall ? 20 : 24,
                  height: isSmall ? 20 : 24,
                ),
                title: Text(
                  'Upload from Photos / Gallery',
                  style: TextStyle(fontSize: ctx.sp(isSmall ? 13.5 : 15)),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    if (!context.mounted) return;
    final bool hasPermission;
    if (source == ImageSource.camera) {
      hasPermission = await PermissionService.requestCamera(context);
    } else {
      hasPermission = await PermissionService.requestGallery(context);
    }
    if (!hasPermission || !context.mounted) return;

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Profile Photo',
              toolbarColor: AppColors.vibrantBlue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
              ],
            ),
            IOSUiSettings(
              title: 'Crop Profile Photo',
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
              ],
            ),
          ],
        );
        if (croppedFile != null) {
          _pickedPhoto = File(croppedFile.path);
          notifyListeners();
        }
      } catch (cropError) {
        debugPrint(
          'Native cropper unavailable/error ($cropError), opening Flutter Crop Dialog',
        );
        if (context.mounted) {
          final File? customCropped = await Navigator.push<File>(
            context,
            MaterialPageRoute(
              builder: (ctx) =>
                  ImageCropDialog(imageFile: File(pickedFile.path)),
            ),
          );
          if (customCropped != null) {
            _pickedPhoto = customCropped;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<bool> saveChanges(
    BuildContext context,
    AuthViewModel authViewModel,
  ) async {
    if (!formKey.currentState!.validate()) return false;

    _isSaving = true;
    notifyListeners();

    try {
      final success = await authViewModel.updateProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        gender: genderController.text,
        dob: dobController.text.trim(),
        location: addressController.text.trim(),
        postalCode: postalCodeController.text.trim(),
        city: cityController.text.trim(),
        province: provinceController.text.trim(),
        country: countryController.text.trim(),
        profilePhoto: _pickedPhoto,
      );
      return success;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    dobController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    provinceController.dispose();
    countryController.dispose();
    super.dispose();
  }
}
