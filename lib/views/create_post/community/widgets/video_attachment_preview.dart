import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/widgets/app_video_player_view.dart';

class VideoAttachmentPreviewViewModel extends ChangeNotifier {
  VideoPlayerController? _controller;
  VideoPlayerController? get controller => _controller;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _hasError = false;
  bool get hasError => _hasError;

  bool _showControls = true;
  bool get showControls => _showControls;

  String? _lastVideoPath;

  Future<void> initVideo(File videoFile) async {
    if (_lastVideoPath == videoFile.path && _controller != null) return;
    _lastVideoPath = videoFile.path;

    final oldController = _controller;
    _isInitialized = false;
    _hasError = false;
    notifyListeners();

    if (oldController != null) {
      oldController.removeListener(_videoListener);
      await oldController.dispose();
    }

    try {
      final controller = VideoPlayerController.file(videoFile);
      _controller = controller;

      await controller.initialize();
      controller.addListener(_videoListener);

      _isInitialized = true;
      notifyListeners();
    } catch (_) {
      _hasError = true;
      _isInitialized = false;
      notifyListeners();
    }
  }

  void _videoListener() {
    notifyListeners();
  }

  void togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      _showControls = true;
    } else {
      if (_controller!.value.position >= _controller!.value.duration) {
        _controller!.seekTo(Duration.zero);
      }
      _controller!.play();
      _showControls = true;
    }
    notifyListeners();
  }

  void setShowControls(bool value) {
    _showControls = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }
}

class VideoAttachmentPreview extends StatelessWidget {
  final File videoFile;
  final VoidCallback onRemove;

  const VideoAttachmentPreview({
    super.key,
    required this.videoFile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoAttachmentPreviewViewModel()..initVideo(videoFile),
      child: _VideoAttachmentPreviewContent(
        videoFile: videoFile,
        onRemove: onRemove,
      ),
    );
  }
}

class _VideoAttachmentPreviewContent extends StatelessWidget {
  final File videoFile;
  final VoidCallback onRemove;

  const _VideoAttachmentPreviewContent({
    required this.videoFile,
    required this.onRemove,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VideoAttachmentPreviewViewModel>();
    final controller = vm.controller;

    // Trigger video initialization if file changed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<VideoAttachmentPreviewViewModel>().initVideo(videoFile);
      }
    });

    final fileName = videoFile.path.split(Platform.pathSeparator).last;

    return Container(
      width: double.infinity,
      height: 300,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Video Player Surface or Loading/Error State
            if (vm.isInitialized && controller != null) ...[
              GestureDetector(
                onTap: () {
                  controller.pause();
                  AppVideoPlayerView.open(
                    context,
                    videoFile: videoFile,
                    title: fileName,
                    postTimeAgo: 'Just now',
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width > 0
                          ? controller.value.size.width
                          : 16,
                      height: controller.value.size.height > 0
                          ? controller.value.size.height
                          : 9,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              ),

              // Soft vignette overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Play / Open central button overlay
              AnimatedOpacity(
                opacity: (!controller.value.isPlaying || vm.showControls) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: () {
                    controller.pause();
                    AppVideoPlayerView.open(
                      context,
                      videoFile: videoFile,
                      title: fileName,
                      postTimeAgo: 'Just now',
                    );
                  },
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.play_arrow,
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Blue Tag Overlay (Bottom Left): "Video Attached"
              Positioned(
                left: 20,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.vibrantBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Video Attached',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: AppConstants.fontSizeSM,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Photo Counter / Duration Overlay (Bottom Right)
              Positioned(
                right: 20,
                bottom: 20,
                child: GestureDetector(
                  onTap: () {
                    controller.pause();
                    AppVideoPlayerView.open(
                      context,
                      videoFile: videoFile,
                      title: fileName,
                      postTimeAgo: 'Just now',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: AppConstants.fontSizeXS11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ] else if (vm.hasError) ...[
              // Error fallback
              GestureDetector(
                onTap: () {
                  AppVideoPlayerView.open(
                    context,
                    videoFile: videoFile,
                    title: fileName,
                    postTimeAgo: 'Just now',
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.videoCameraSvg,
                      width: 36,
                      height: 36,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFEF4444),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap to view video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Loading preview indicator
              GestureDetector(
                onTap: () {
                  AppVideoPlayerView.open(
                    context,
                    videoFile: videoFile,
                    title: fileName,
                    postTimeAgo: 'Just now',
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Loading video preview...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 2. Top-Right Remove/Close Button
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppIcons.crossSmallAltSvg,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
