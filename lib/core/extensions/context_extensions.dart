import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Extension on [BuildContext] for clean, concise responsive syntax
/// across all screens and widgets.
///
/// Reference viewport dimensions (standard mobile: iPhone 13/14/15/16):
///   width  = 390.0
///   height = 844.0
extension ResponsiveContextExtension on BuildContext {
  static const double _refWidth = 390.0;
  static const double _refHeight = 844.0;

  /// Screen width in logical pixels
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height in logical pixels
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// True if device width < 360px (e.g. iPhone SE, compact Androids)
  bool get isSmall => screenWidth < 360.0;

  /// True if device width is between 360px and 419px (standard phones)
  bool get isNormal {
    final w = screenWidth;
    return w >= 360.0 && w < 420.0;
  }

  /// True if device width >= 420px (Plus, Pro Max, Ultra phones)
  bool get isLarge {
    final w = screenWidth;
    return w >= 420.0 && w < 600.0;
  }

  /// True if device width >= 600px (Tablets / Foldables)
  bool get isTablet => screenWidth >= 600.0;

  /// Proportional size scaler clamped for safety (0.8x – 1.25x)
  double scale(double baseSize) {
    final double factor = (screenWidth / _refWidth).clamp(0.8, 1.25);
    return baseSize * factor;
  }

  /// Proportional height scaler (0.85x – 1.2x)
  double scaleH(double baseHeight) {
    final double factor = (screenHeight / _refHeight).clamp(0.85, 1.2);
    return baseHeight * factor;
  }

  /// Responsive font scaler (0.85x – 1.18x)
  double sp(double fontSize) {
    final double factor = (screenWidth / _refWidth).clamp(0.85, 1.18);
    return (fontSize * factor).roundToDouble();
  }

  /// Percentage of screen width (0.0 to 1.0)
  double widthPct(double pct) => screenWidth * pct;

  /// Percentage of screen height (0.0 to 1.0)
  double heightPct(double pct) => screenHeight * pct;

  /// Responsive horizontal page margin (14 on small devices, 20 on standard)
  double get hMargin => isSmall ? 14.0 : 20.0;

  /// Responsive card internal padding (12 on small devices, 16 on standard)
  double get cardPad => isSmall ? 12.0 : 16.0;

  /// Dynamic grid column count based on available width
  int gridColumns({double itemMinWidth = 160.0}) {
    final int count = (screenWidth / itemMinWidth).floor();
    return math.max(1, count);
  }
}
