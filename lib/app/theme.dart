import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // Core App Colors — aliased from AppColors for backward compatibility
  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color secondaryPurple = AppColors.secondaryPurple;
  static const Color gradientStart = AppColors.gradientStart;
  static const Color gradientEnd = AppColors.secondaryPurple;
  static const Color backgroundLight = AppColors.slate50;
  static const Color textDark = AppColors.gray900;
  static const Color textGray = AppColors.slate500;
  static const Color textLightGray = AppColors.slate400;
  static const Color textLabel = AppColors.gray500;
  static const Color inputFill = AppColors.slate50;
  static const Color borderLight = Color.fromARGB(24, 0, 0, 0);
  static const Color borderDashed = AppColors.slate300;
  static const Color svgDefault = AppColors.svgDefault;
  static const Color iconInactive = AppColors.iconInactive;
  static const Color black8c = AppColors.black8c;

  // TextField Color
  static const Color textFieldBgColor = AppColors.textFieldBg;

  // App Theme Design Tokens
  static const Color successGreen = AppColors.successGreen;
  static const Color accentBlue = AppColors.vibrantBlue;
  static const Color backgroundOffWhite = AppColors.backgroundOffWhite;
  static const Color borderGray = AppColors.slate200;
  static const Color textBlackNero = AppColors.gray900;
  static const Color textDarkSlate = AppColors.slate800;

  // Dashboard Specific Accent Colors
  static const Color orangeAccent = AppColors.orangeAccent;
  static const Color primaryPurple = AppColors.primaryPurple;
  static const Color accentYellow = AppColors.accentYellow;
  static const Color sponsoredYellow = AppColors.sponsoredYellow;
  static const Color primaryRed = AppColors.primaryRed;
  static const Color amberOrange = AppColors.amberOrange;
  static const Color tealGreen = AppColors.tealGreen;
  static const Color softTeal = AppColors.emerald;
  static const Color lightBlue = AppColors.lightBlue;
  static const Color lightPurple = AppColors.lightPurple;
  static const Color lightYellow = AppColors.lightYellow;
  static const Color lightOrange = AppColors.lightOrange;
  static const Color softRed = AppColors.softRed;
  static const Color lightGreen = AppColors.lightGreen;
  static const Color softGreen = AppColors.softGreen;
  static const Color softGrey = AppColors.slate100;
  static const Color darkBlueBg = AppColors.slate900;

  // Splash Text Colors
  static const Color splashDesi = AppColors.splashDesi;
  static const Color splashConnect = AppColors.splashConnect;
  static const Color splashGradient = AppColors.splashGradient;

  // Premium Slate/Indigo light color palette
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.slate50,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.indigo,
      brightness: Brightness.light,
      primary: AppColors.indigo,
      secondary: AppColors.cyan,
      surface: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.slate800),
      titleTextStyle: TextStyle(
        color: AppColors.slate800,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.indigo,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.slate100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.indigo, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.slate500),
      hintStyle: const TextStyle(color: AppColors.slate400),
    ),
  );

  // Modern Slate dark color palette
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.slate900,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.indigo,
      brightness: Brightness.dark,
      primary: AppColors.indigoLight400,
      secondary: AppColors.cyanLight400,
      surface: AppColors.slate800,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.indigo,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.slate800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.indigoLight400,
          width: 1.5,
        ),
      ),
      labelStyle: const TextStyle(color: AppColors.slate400),
      hintStyle: const TextStyle(color: AppColors.slate600),
    ),
  );
}
