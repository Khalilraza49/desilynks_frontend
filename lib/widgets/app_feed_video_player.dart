import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/widgets/app_video_player_view.dart';

/// Interactive, responsive inline Video Player component for Community feed cards.
/// Displays the actual video content directly in the post with inline controls
/// and seamless expansion to full-screen viewer.
class AppFeedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? postTimeAgo;
  final String? authorName;
  final String? postContent;
  final bool isLiked;
  final VoidCallback? onLikeToggle;
  final VoidCallback? onShare;
  final double? preferredHeight;

  const AppFeedVideoPlayer({
    super.key,
    required this.videoUrl,
    this.postTimeAgo,
    this.authorName,
    this.postContent,
    this.isLiked = false,
    this.onLikeToggle,
    this.onShare,
    this.preferredHeight,
  });

  @override
  State<AppFeedVideoPlayer> createState() => _AppFeedVideoPlayerState();
}

class _AppFeedVideoPlayerState extends State<AppFeedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant AppFeedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeCurrentController();
      _initPlayer();
    }
  }

  String _resolveUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$baseUrl$path';
  }

  Future<void> _initPlayer() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final raw = widget.videoUrl.trim();
      if (raw.isEmpty) {
        throw Exception('Empty video URL');
      }

      if (!raw.startsWith('http') && File(raw).existsSync()) {
        _controller = VideoPlayerController.file(File(raw));
      } else {
        final fullUrl = _resolveUrl(raw);
        _controller = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
      }

      await _controller!.initialize();
      _controller!.addListener(_playerListener);
      _controller!.setLooping(true);
      await _controller!.setVolume(_isMuted ? 0.0 : 1.0);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _playerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _disposeCurrentController() {
    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeCurrentController();
    super.dispose();
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      if (controller.value.position >= controller.value.duration) {
        controller.seekTo(Duration.zero);
      }
      controller.play();
    }
    setState(() {});
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _openFullScreen() {
    final controller = _controller;
    if (controller != null && controller.value.isPlaying) {
      controller.pause();
    }

    AppVideoPlayerView.open(
      context,
      videoUrl: widget.videoUrl,
      title: widget.authorName,
      postTimeAgo: widget.postTimeAgo,
      isLiked: widget.isLiked,
      onLikeToggle: widget.onLikeToggle,
      onShare: widget.onShare,
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    // Responsive height calculation based on video aspect ratio
    double containerHeight = widget.preferredHeight ?? context.scaleH(260);
    if (_isInitialized && controller != null) {
      final ar = controller.value.aspectRatio;
      if (ar > 0) {
        final screenW = MediaQuery.sizeOf(context).width -
            (context.scale(AppConstants.paddingLarge) * 2);
        final idealHeight = screenW / ar;
        containerHeight = widget.preferredHeight ??
            idealHeight.clamp(context.scaleH(200), context.scaleH(320));
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        context.scale(AppConstants.borderRadius12),
      ),
      child: Container(
        width: double.infinity,
        height: containerHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(
            context.scale(AppConstants.borderRadius12),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Video Surface or Fallback State
            if (_isInitialized && controller != null)
              GestureDetector(
                onTap: _togglePlayPause,
                onDoubleTap: _openFullScreen,
                behavior: HitTestBehavior.opaque,
                child: SizedBox.expand(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio > 0
                          ? controller.value.aspectRatio
                          : 16 / 9,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              )
            else if (_hasError)
              _buildErrorState(context)
            else
              _buildLoadingState(context),

            // 2. Play / Pause Action Button in Center
            if (_isInitialized && controller != null && !controller.value.isPlaying)
              Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: context.scale(56),
                    height: context.scale(56),
                    decoration: BoxDecoration(
                      color: AppColors.vibrantBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.vibrantBlue.withValues(alpha: 0.45),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.play_arrow,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        width: context.scale(32),
                        height: context.scale(32),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. Top-Left Badge: "Community Video"
            Positioned(
              top: context.scaleH(10),
              left: context.scale(10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(10),
                  vertical: context.scaleH(4),
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(context.scale(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppIcons.videocamSvg,
                      height: context.scale(13),
                      width: context.scale(13),
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFBBF24),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: context.scale(4)),
                    Text(
                      'Community Video',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Top-Right Fullscreen / Expand Button
            Positioned(
              top: context.scaleH(10),
              right: context.scale(10),
              child: GestureDetector(
                onTap: _openFullScreen,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.all(context.scale(7)),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: context.scale(20),
                  ),
                ),
              ),
            ),

            // 5. Bottom-Left Mute / Unmute Button
            if (_isInitialized && controller != null)
              Positioned(
                bottom: context.scaleH(10),
                left: context.scale(10),
                child: GestureDetector(
                  onTap: _toggleMute,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(context.scale(7)),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: context.scale(17),
                    ),
                  ),
                ),
              ),

            // 6. Bottom-Right Duration / Position Counter Pill
            if (_isInitialized && controller != null)
              Positioned(
                bottom: context.scaleH(10),
                right: context.scale(10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(8),
                    vertical: context.scaleH(3),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: Text(
                    controller.value.isPlaying
                        ? '${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}'
                        : _formatDuration(controller.value.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(10.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // 7. Bottom Linear Progress Bar (while playing)
            if (_isInitialized && controller != null && controller.value.isPlaying)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  padding: EdgeInsets.zero,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.vibrantBlue,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: -context.scale(20),
          bottom: -context.scaleH(20),
          child: SvgPicture.asset(
            AppIcons.videoCameraSvg,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.04),
              BlendMode.srcIn,
            ),
            width: context.scale(130),
            height: context.scale(130),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: context.scale(28),
              height: context.scale(28),
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantBlue),
              ),
            ),
            SizedBox(height: context.scaleH(10)),
            Text(
              'Loading video...',
              style: TextStyle(
                color: AppColors.slate400,
                fontSize: context.sp(AppConstants.fontSizeXS + 1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.scale(AppConstants.paddingLarge)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppIcons.videoCameraSvg,
            width: context.scale(38),
            height: context.scale(38),
            colorFilter: const ColorFilter.mode(
              Color(0xFFEF4444),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: context.scaleH(8)),
          Text(
            _errorMessage ?? 'Unable to play video',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(AppConstants.fontSizeSM),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.scaleH(10)),
          ElevatedButton.icon(
            onPressed: _initPlayer,
            icon: Icon(Icons.refresh, size: context.scale(16)),
            label: Text(
              'Retry',
              style: TextStyle(fontSize: context.sp(AppConstants.fontSizeXS)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vibrantBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: context.scale(14),
                vertical: context.scaleH(6),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
