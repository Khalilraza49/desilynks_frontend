import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/services/api/api_endpoints.dart';

/// Fullscreen, responsive Video Player Viewer that works with both local files and network URLs.
class AppVideoPlayerView extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;
  final String? title;
  final String? postTimeAgo;
  final bool isLiked;
  final VoidCallback? onLikeToggle;
  final VoidCallback? onShare;
  final bool showActions;

  const AppVideoPlayerView({
    super.key,
    this.videoFile,
    this.videoUrl,
    this.title,
    this.postTimeAgo,
    this.isLiked = false,
    this.onLikeToggle,
    this.onShare,
    this.showActions = true,
  });

  /// Convenient helper to push this viewer onto the navigation stack.
  static Future<void> open(
    BuildContext context, {
    File? videoFile,
    String? videoUrl,
    String? title,
    String? postTimeAgo,
    bool isLiked = false,
    VoidCallback? onLikeToggle,
    VoidCallback? onShare,
    bool showActions = true,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppVideoPlayerView(
          videoFile: videoFile,
          videoUrl: videoUrl,
          title: title,
          postTimeAgo: postTimeAgo,
          isLiked: isLiked,
          onLikeToggle: onLikeToggle,
          onShare: onShare,
          showActions: showActions,
        ),
      ),
    );
  }

  @override
  State<AppVideoPlayerView> createState() => _AppVideoPlayerViewState();
}

class _AppVideoPlayerViewState extends State<AppVideoPlayerView> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _initPlayer();
  }

  String _resolveUrl(String url) {
    var resolved = url.trim();
    if (resolved.isEmpty) return resolved;
    if (!resolved.startsWith('http')) {
      final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = resolved.startsWith('/') ? resolved : '/$resolved';
      resolved = '$baseUrl$path';
    }
    return resolved;
  }

  Future<void> _initPlayer() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      if (widget.videoFile != null && widget.videoFile!.existsSync()) {
        _controller = VideoPlayerController.file(widget.videoFile!);
      } else if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
        final fullUrl = _resolveUrl(widget.videoUrl!);
        _controller = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
      } else {
        throw Exception('No valid video source provided');
      }

      await _controller!.initialize();
      _controller!.addListener(_playerListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
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

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() => _showControls = true);
    } else {
      if (_controller!.value.position >= _controller!.value.duration) {
        _controller!.seekTo(Duration.zero);
      }
      _controller!.play();
      setState(() => _showControls = true);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Center Video Surface or Loading/Error State
          Center(
            child: _isInitialized && controller != null
                ? GestureDetector(
                    onTap: () {
                      setState(() => _showControls = !_showControls);
                    },
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio > 0
                          ? controller.value.aspectRatio
                          : 16 / 9,
                      child: VideoPlayer(controller),
                    ),
                  )
                : _hasError
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppIcons.videoCameraSvg,
                              width: 52,
                              height: 52,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFFEF4444),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _errorMessage ?? 'Failed to load video',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _initPlayer,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.vibrantBlue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Loading video...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
          ),

          // 2. Dim Gradient Overlays when controls are visible
          if (_isInitialized && controller != null && _showControls)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),

          // 3. Center Play / Pause Floating Action Button
          if (_isInitialized && controller != null && _showControls)
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      controller.value.isPlaying
                          ? AppIcons.pauseSvg
                          : AppIcons.play_arrow,
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

          // 4. Back Button (Top Left)
          Positioned(
            left: 20,
            top: MediaQuery.of(context).padding.top + 10,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppIcons.arrowBackSvg,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),

          // 5. Title (Top, beside back button)
          if (widget.title != null && widget.title!.isNotEmpty)
            Positioned(
              left: 70,
              right: widget.showActions ? 120 : 60,
              top: MediaQuery.of(context).padding.top + 16,
              child: Text(
                widget.title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // 6. Top Right Action Buttons (Heart and Share)
          if (widget.showActions)
            Positioned(
              right: 20,
              top: MediaQuery.of(context).padding.top + 10,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                      widget.onLikeToggle?.call();

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isLiked
                                ? 'Added to Favourite Ads'
                                : 'Removed from Favourite Ads',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.favSvg,
                        colorFilter: ColorFilter.mode(
                          _isLiked
                              ? AppColors.primaryRed
                              : AppColors.white,
                          BlendMode.srcIn,
                        ),
                        height: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Share Button
                  GestureDetector(
                    onTap: () {
                      if (widget.onShare != null) {
                        widget.onShare!();
                      } else {
                        Clipboard.setData(
                          ClipboardData(
                            text: widget.videoUrl ??
                                widget.title ??
                                'Community Video',
                          ),
                        );
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Video link copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.shareSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 7. Blue Tag Overlay (Bottom Left): "Posted X hours ago"
          if (widget.postTimeAgo != null && widget.postTimeAgo!.isNotEmpty)
            Positioned(
              left: 20,
              bottom: MediaQuery.of(context).padding.bottom + 68,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.vibrantBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.postTimeAgo!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: AppConstants.fontSizeSM,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // 8. Photo/Video Counter Overlay (Bottom Right)
          if (_isInitialized && controller != null)
            Positioned(
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 68,
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

          // 6. Bottom Controls: Progress Bar & Timestamps
          if (_isInitialized && controller != null && _showControls)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 14,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(controller.value.position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatDuration(controller.value.duration),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        colors: const VideoProgressColors(
                          playedColor: AppColors.vibrantBlue,
                          bufferedColor: Colors.white30,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
