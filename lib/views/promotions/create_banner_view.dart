import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/services/permissions/permission_service.dart';
import 'package:desilynks/models/banner_ad_model.dart';
import 'package:desilynks/widgets/banner_position_dropdown_field.dart';
import 'package:desilynks/viewmodels/home/home_viewmodel.dart';
import 'package:desilynks/viewmodels/promotions/create_banner_viewmodel.dart';
import 'package:desilynks/viewmodels/promotions/deals_discounts_viewmodel.dart';
import 'package:desilynks/viewmodels/promotions/banner_advertisements_viewmodel.dart';

class CreateBannerView extends StatelessWidget {
  final BannerAdPosition? initialPosition;

  const CreateBannerView({super.key, this.initialPosition});

  Future<void> _pickImage(
    BuildContext context,
    CreateBannerViewModel vm,
    ImageSource source,
  ) async {
    final bool hasPermission;
    if (source == ImageSource.camera) {
      hasPermission = await PermissionService.requestCamera(context);
    } else {
      hasPermission = await PermissionService.requestGallery(context);
    }

    if (!hasPermission || !context.mounted) return;

    await vm.pickImage(source);
  }

  void _showImagePickerSheet(BuildContext context, CreateBannerViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Choose Banner Photo',
                style: TextStyle(
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    AppIcons.gallerySvg,
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2563EB),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontSize: context.sp(14.5),
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate800,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                subtitle: Text(
                  'PNG, JPG up to 4 MB',
                  style: TextStyle(
                    fontSize: context.sp(12),
                    color: const Color(0xFF64748B),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, vm, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    AppIcons.cameraSvg,
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF059669),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                title: Text(
                  'Take a Photo',
                  style: TextStyle(
                    fontSize: context.sp(14.5),
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate800,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, vm, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue(
    BuildContext context,
    CreateBannerViewModel vm,
  ) async {
    FocusScope.of(context).unfocus();
    final createdAd = await vm.submitBanner();

    if (!context.mounted) return;

    if (createdAd != null) {
      // Refresh banner ads in other viewmodels if available
      try {
        context.read<DealsDiscountsViewModel>().fetchPublicBanners();
      } catch (_) {}
      try {
        context.read<HomeViewModel>().fetchHomeBanners();
      } catch (_) {}
      try {
        context.read<BannerAdvertisementsViewModel>().fetchMyBanners();
      } catch (_) {}

      vm.resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Banner ad created successfully and is now running!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF16A34A),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context, createdAd);
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateBannerViewModel>();

    // Synchronize initial position if passed and differs
    if (initialPosition != null && vm.selectedPosition != initialPosition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          vm.setSelectedPosition(initialPosition!);
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackBasicSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate900,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Create Banner',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.hMargin,
            vertical: context.scaleH(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Choose Image Box (Dotted border)
              _buildImageBox(context, vm),

              SizedBox(height: context.scaleH(20)),

              // 2. Title Field
              _buildFieldLabel(context, 'Title'),
              SizedBox(height: context.scaleH(6)),
              _buildTextField(
                controller: vm.titleController,
                hintText: 'Desi Mart Special Offer',
                maxLength: 100,
              ),

              SizedBox(height: context.scaleH(16)),

              // 3. Description Field
              _buildFieldLabel(context, 'Description'),
              SizedBox(height: context.scaleH(6)),
              _buildTextField(
                controller: vm.descriptionController,
                hintText: 'Get 10% off on all products',
                maxLines: 3,
                maxLength: 400,
              ),

              SizedBox(height: context.scaleH(16)),

              // 4. CTA Button Text Field
              _buildFieldLabel(context, 'CTA Button Text'),
              SizedBox(height: context.scaleH(6)),
              _buildTextField(
                controller: vm.ctaButtonTextController,
                hintText: 'Shop Now',
                maxLength: 30,
              ),

              SizedBox(height: context.scaleH(16)),

              // 5. Destination Link Field
              _buildFieldLabel(context, 'Destination Link'),
              SizedBox(height: context.scaleH(6)),
              _buildTextField(
                controller: vm.destinationLinkController,
                hintText: 'https://desimart.es/offer',
                keyboardType: TextInputType.url,
              ),

              SizedBox(height: context.scaleH(16)),

              // 6. Select Position Dropdown (White color scheme)
              _buildFieldLabel(context, 'Select Position'),
              SizedBox(height: context.scaleH(6)),
              _buildPositionDropdown(context, vm),

              SizedBox(height: context.scaleH(30)),

              // 7. Continue Button
              _buildContinueButton(context, vm),

              SizedBox(height: context.scaleH(20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.sp(14),
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E293B),
        fontFamily: AppStrings.fontInter,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14.5,
        color: AppColors.slate900,
        fontFamily: AppStrings.fontInter,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        hintStyle: const TextStyle(
          fontSize: 14.5,
          color: Color(0xFF94A3B8),
          fontFamily: AppStrings.fontInter,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildImageBox(BuildContext context, CreateBannerViewModel vm) {
    final imageFile = vm.selectedImage;

    return GestureDetector(
      onTap: () => _showImagePickerSheet(context, vm),
      child: CustomPaint(
        painter: _DottedBorderPainter(
          color: const Color(0xFFCBD5E1),
          strokeWidth: 1.5,
          radius: 16,
        ),
        child: Container(
          width: double.infinity,
          height: context.scaleH(150).clamp(130.0, 180.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: imageFile != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => vm.removeImage(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Change',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppIcons.gallerySvg,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF64748B),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Choose Image',
                      style: TextStyle(
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PNG, JPG up to 5MB',
                      style: TextStyle(
                        fontSize: context.sp(12),
                        color: const Color(0xFF94A3B8),
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPositionDropdown(
    BuildContext context,
    CreateBannerViewModel vm,
  ) {
    return BannerPositionDropdownField(
      selectedPosition: vm.selectedPosition,
      onChanged: (newPosition) {
        vm.setSelectedPosition(newPosition);
      },
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    CreateBannerViewModel vm,
  ) {
    return SizedBox(
      width: double.infinity,
      height: context.scaleH(50).clamp(46.0, 54.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: ElevatedButton(
          onPressed: vm.isSubmitting ? null : () => _handleContinue(context, vm),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: vm.isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
        ),
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  static const double gap = 4.0;
  static const double dash = 6.0;

  _DottedBorderPainter({
    this.color = const Color(0xFFCBD5E1),
    this.strokeWidth = 1.5,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = distance + dash;
        dashPath.addPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
