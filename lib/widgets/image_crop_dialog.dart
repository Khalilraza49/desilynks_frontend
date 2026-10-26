import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/theme.dart';

class ImageCropDialog extends StatefulWidget {
  final File imageFile;

  const ImageCropDialog({super.key, required this.imageFile});

  @override
  State<ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<ImageCropDialog> {
  final TransformationController _transformationController =
      TransformationController();
  ui.Image? _decodedImage;
  bool _isLoading = true;
  bool _isSaving = false;

  double get _displayBoxSize =>
      math.min(300.0, MediaQuery.sizeOf(context).width - 32.0);

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _decodedImage = frame.image;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error decoding image for crop: $e');
      if (mounted) {
        Navigator.pop(context, widget.imageFile);
      }
    }
  }

  Future<void> _cropAndSave() async {
    if (_decodedImage == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const double targetSize = 500.0;
      final double displayBoxSize = _displayBoxSize;

      final paint = Paint()..filterQuality = FilterQuality.high;

      // Map transformation controller scale/translation from display box (300px) to target image (500px)
      final Matrix4 matrix = _transformationController.value;

      canvas.save();
      final scaleFactor = targetSize / displayBoxSize;
      canvas.scale(scaleFactor, scaleFactor);
      canvas.transform(matrix.storage);

      // Center the raw image inside the display box
      final double imgWidth = _decodedImage!.width.toDouble();
      final double imgHeight = _decodedImage!.height.toDouble();

      double initialScale = 1.0;
      if (imgWidth > 0 && imgHeight > 0) {
        initialScale =
            displayBoxSize / (imgWidth > imgHeight ? imgHeight : imgWidth);
      }

      canvas.scale(initialScale, initialScale);
      canvas.drawImage(_decodedImage!, Offset.zero, paint);
      canvas.restore();

      final picture = recorder.endRecording();
      final croppedUiImage = await picture.toImage(
        targetSize.toInt(),
        targetSize.toInt(),
      );
      final byteData = await croppedUiImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final tempDir = Directory.systemTemp;
        final croppedPath =
            '${tempDir.path}/cropped_profile_${DateTime.now().millisecondsSinceEpoch}.png';
        final croppedFile = File(croppedPath);
        await croppedFile.writeAsBytes(byteData.buffer.asUint8List());
        if (mounted) {
          Navigator.pop(context, croppedFile);
        }
      } else if (mounted) {
        Navigator.pop(context, widget.imageFile);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      if (mounted) {
        Navigator.pop(context, widget.imageFile);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.crossSmallSvg,
            colorFilter: const ColorFilter.mode(
              AppTheme.primaryBlue,
              BlendMode.srcIn,
            ),
            height: 28,
            width: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crop Profile Photo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          _isSaving
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: SvgPicture.asset(
                    AppIcons.tickAltSvg,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.primaryBlue,
                      BlendMode.srcIn,
                    ),
                    height: 28,
                    width: 28,
                  ),
                  onPressed: _isLoading ? null : _cropAndSave,
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          width: _displayBoxSize,
                          height: _displayBoxSize,
                          child: ClipRect(
                            child: InteractiveViewer(
                              transformationController:
                                  _transformationController,
                              boundaryMargin: const EdgeInsets.all(200),
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Image.file(
                                widget.imageFile,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Circular crop mask
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _CropOverlayPainter(_displayBoxSize / 2),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black87,
                  child: const Text(
                    'Pinch to zoom and drag to position your photo',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final double radius;
  const _CropOverlayPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final center = Offset(size.width / 2, size.height / 2);
    final cropCirclePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cropCirclePath,
    );

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(overlayPath, paint);
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
