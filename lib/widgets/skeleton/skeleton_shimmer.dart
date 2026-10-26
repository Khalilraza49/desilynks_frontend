import 'package:flutter/material.dart';

/// Scope widget providing a synchronized, looping shimmer animation
/// across all child skeleton widgets on a screen.
class SkeletonShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const SkeletonShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  static Animation<double>? of(BuildContext context) {
    final _SkeletonShimmerScope? scope = context
        .dependOnInheritedWidgetOfExactType<_SkeletonShimmerScope>();
    return scope?.animation;
  }

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    _animation = Tween<double>(
      begin: -1.5,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SkeletonShimmerScope(animation: _animation, child: widget.child);
  }
}

class _SkeletonShimmerScope extends InheritedWidget {
  final Animation<double> animation;

  const _SkeletonShimmerScope({required this.animation, required super.child});

  @override
  bool updateShouldNotify(_SkeletonShimmerScope oldWidget) =>
      animation != oldWidget.animation;
}

/// A versatile skeleton placeholder box that responds to [SkeletonShimmer].
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;
  final Color baseColor;
  final Color highlightColor;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
    this.margin,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
  });

  @override
  Widget build(BuildContext context) {
    final animation = SkeletonShimmer.of(context);

    Widget box(double animValue) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(borderRadius)
              : null,
          gradient: LinearGradient(
            begin: Alignment(animValue - 1.0, 0),
            end: Alignment(animValue + 1.0, 0),
            colors: [baseColor, highlightColor, baseColor],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      );
    }

    if (animation != null) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) => box(animation.value),
      );
    }

    // Fallback if rendered outside of SkeletonShimmer
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: baseColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
    );
  }
}

/// Helper for rendering line placeholders (text, subtitles, tags).
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = 4,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
      margin: margin,
    );
  }
}

/// Helper for circular placeholders (avatars, icons, badges).
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({super.key, required this.size, this.margin});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      shape: BoxShape.circle,
      margin: margin,
    );
  }
}
