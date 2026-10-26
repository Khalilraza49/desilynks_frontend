import 'package:flutter/material.dart';

/// Centralized color constants for the entire Desi Connect app.
/// All colors used anywhere in the project MUST be defined here.
class AppColors {
  AppColors._();

  // ──────────────────────────────────────────────────────────────────────────
  // Transparent / Pure
  // ──────────────────────────────────────────────────────────────────────────
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ──────────────────────────────────────────────────────────────────────────
  // Core Brand Colors
  // ──────────────────────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryPurple = Color(0xFF7040ED);
  static const Color vibrantBlue = Color(0xFF0052FF);
  static const Color gradientStart = Color(0xFF014EF3);
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoLight400 = Color(0xFF818CF8);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = primaryBlue;
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E3A8A);
  static const Color mediumBlue = Color(0xFF4365ED);
  static const Color darkBlue = Color(0xFF163CC3);
  static const Color navyBlue = Color(0xFF1A1F71);
  static const Color communityBlue = Color(0xFF4353E8);
  static const Color skyBlue = Color(0xFF0284C7);
  static const Color skyLight = Color(0xFFE0F2FE);
  static const Color blueBg = Color(0xFFDBEAFE);
  static const Color blueBg2 = Color(0xFFEBF5FF);
  static const Color indigoBg = Color(0xFFE0E7FF);

  // ──────────────────────────────────────────────────────────────────────────
  // Third-party Brand Colors
  // ──────────────────────────────────────────────────────────────────────────
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color paypalBlue = Color(0xFF003087);
  static const Color mastercardRed = Color(0xFFEB001B);

  // ──────────────────────────────────────────────────────────────────────────
  // Cyan / Teal
  // ──────────────────────────────────────────────────────────────────────────
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanLight400 = Color(0xFF22D3EE);
  static const Color tealGreen = Color(0xFF0D9488);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color teal100 = Color(0xFFCCFBF1);

  // ──────────────────────────────────────────────────────────────────────────
  // Success / Green Palette
  // ──────────────────────────────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF16A34A);
  static const Color emerald = Color(0xFF10B981);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color green600 = Color(0xFF059669);
  static const Color green700 = Color(0xFF047857);
  static const Color green700b = Color(0xFF15803D);
  static const Color green400 = Color(0xFF22C55E);
  static const Color green500 = green400;
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color darkGreen = Color(0xFF2E7D32);

  // ──────────────────────────────────────────────────────────────────────────
  // Warning / Orange / Yellow / Amber Palette
  // ──────────────────────────────────────────────────────────────────────────
  static const Color orangeAccent = Color(0xFFEA580C);
  static const Color orange = Color(0xFFF97316);
  static const Color orange700 = Color(0xFFC2410C);
  static const Color orange900 = Color(0xFF9A3412);
  static const Color amberOrange = Color(0xFFF59E0B);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = amberOrange;
  static const Color amber700 = Color(0xFFD97706);
  static const Color amber800 = Color(0xFFB45309);
  static const Color amber900 = Color(0xFF78350F);
  static const Color amber850 = Color(0xFF854D0E);
  static const Color amber950 = Color(0xFFA16207);
  static const Color accentYellow = amber400;
  static const Color sponsoredYellow = Color(0xFFFABE24);
  static const Color deepOrange = Color(0xFFE65100);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow300 = Color(0xFFFEF08A);
  static const Color yellow200 = Color(0xFFFEF9C3);
  static const Color eab = Color(0xFFEAB308);
  static const Color ca8a = Color(0xFFCA8A04);

  // ──────────────────────────────────────────────────────────────────────────
  // Error / Red Palette
  // ──────────────────────────────────────────────────────────────────────────
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFFE11D48);
  static const Color red400 = Color(0xFFF87171);

  // ──────────────────────────────────────────────────────────────────────────
  // Purple / Violet Palette
  // ──────────────────────────────────────────────────────────────────────────
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color purple700 = Color(0xFF7C3AED);
  static const Color purple800 = Color(0xFF6B21A8);
  static const Color purple900 = Color(0xFF4F46E5);
  static const Color purple950 = Color(0xFF7E22CE);
  static const Color purpleLight100 = Color(0xFFEDE9FE);
  static const Color purple700b = Color(0xFF9333EA);
  static const Color violet700 = Color(0xFF7C3AED);
  static const Color indigo700 = Color(0xFF4F46E5);
  static const Color indigo800 = Color(0xFF1E3A8A);

  // ──────────────────────────────────────────────────────────────────────────
  // Pink / Rose Palette
  // ──────────────────────────────────────────────────────────────────────────
  static const Color pink500 = Color(0xFFEC4899);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose700 = Color(0xFFE11D48);
  static const Color pink700 = Color(0xFFDB2777);
  static const Color pinkBg = Color(0xFFFDF2F8);
  static const Color roseBg = Color(0xFFFFF1F2);
  static const Color roseBg2 = Color(0xFFFFF0F2);
  static const Color roseLight = Color(0xFFFDA4AF);
  static const Color roseLight2 = Color(0xFFFECDD3);
  static const Color roseLight3 = Color(0xFFFFD1D7);
  static const Color roseLight4 = Color(0xFFFFE4E6);

  // ──────────────────────────────────────────────────────────────────────────
  // Text / Neutral Dark Colors
  // ──────────────────────────────────────────────────────────────────────────
  static const Color slate900 = Color(0xFF0F172A);
  static const Color gray900 = Color(0xFF111827);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color darkNavy = Color(0xFF0F2A44);
  static const Color darkNavy2 = Color(0xFF1E3A5F);
  static const Color slate700 = Color(0xFF334155);
  static const Color gray700 = Color(0xFF374151);
  static const Color slate600 = Color(0xFF475569);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color googleGray = Color(0xFF5F6368);
  static const Color gray666 = Color(0xFF666666);
  static const Color slate500 = Color(0xFF64748B);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color blueGray400 = Color(0xFFB0C4DE);

  // ──────────────────────────────────────────────────────────────────────────
  // Icon & SVG Colors
  // ──────────────────────────────────────────────────────────────────────────
  /// Figma/CSS #0000008C (Black with 55% opacity, 0x8C alpha in Flutter ARGB: 0x8C000000)
  static const Color black8c = Color(0x8C000000);
  static const Color svgDefault = Color(0x8C000000);
  static const Color iconInactive = Color(0x8C000000);

  // ──────────────────────────────────────────────────────────────────────────
  // Border / Divider Colors
  // ──────────────────────────────────────────────────────────────────────────
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);

  // ──────────────────────────────────────────────────────────────────────────
  // Background / Surface Colors
  // ──────────────────────────────────────────────────────────────────────────
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color backgroundOffWhite = Color(0xFFF9FAFB);
  static const Color ebef = Color(0xFFEBEFF5);

  // ──────────────────────────────────────────────────────────────────────────
  // Light Accent Backgrounds
  // ──────────────────────────────────────────────────────────────────────────
  // Blue backgrounds
  static const Color lightBlue = Color(0xFFEFF6FF);
  static const Color lightBlue50 = Color(0xFFF0F7FF);
  static const Color indigoLight = Color(0xFFEEF2FF);

  // Purple backgrounds
  static const Color violetLight = Color(0xFFF5F3FF);
  static const Color lightPurple = Color(0xFFFAF5FF);
  static const Color purpleBg = Color(0xFFF3E8FF);

  // Green backgrounds
  static const Color lightGreen = Color(0xFFF0FDF4);
  static const Color softGreen = Color(0xFFECFDF5);
  static const Color greenLight = Color(0xFFE8FDF4);
  static const Color greenBg = Color(0xFFE8F5E9);
  static const Color greenLight200 = Color(0xFFD1FAE5);
  static const Color greenLight100 = Color(0xFFDCFCE7);
  static const Color greenLight300 = Color(0xFFBBF7D0);

  // Cyan backgrounds
  static const Color cyanLight = Color(0xFFECFEFF);

  // Orange / Yellow backgrounds
  static const Color lightOrange = Color(0xFFFFF7ED);
  static const Color lightYellow = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color orangeLight = Color(0xFFFFF3E0);
  static const Color yellowBg = Color(0xFFFEFCE8);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange200 = Color(0xFFFDBA74);
  static const Color orange50 = Color(0xFFFFF7ED);

  // Red / Rose backgrounds
  static const Color softRed = Color(0xFFFEF2F2);
  static const Color redLight100 = Color(0xFFFEE2E2);
  static const Color redLight300 = Color(0xFFFCA5A5);

  // Misc pastel backgrounds

  // ──────────────────────────────────────────────────────────────────────────
  // Semi-transparent / Overlay Colors
  // ──────────────────────────────────────────────────────────────────────────
  static const Color blackOpacity4 = Color(0x0A000000);
  static const Color blackOpacity6 = Color(0x0F000000);
  static const Color blackOpacity22 = Color(0x38000000);
  static const Color grayOpacity40 = Color(0x66808080);
  static const Color gradientStartOpacity = Color(0xC4014EF3);

  // ──────────────────────────────────────────────────────────────────────────
  // Splash Screen
  // ──────────────────────────────────────────────────────────────────────────
  static const Color splashDesi = Color(0xFF0D52FF);
  static const Color splashConnect = Color(0xFFFF5C00);
  static const Color splashGradient = Color(0xFF0052D4);

  // ──────────────────────────────────────────────────────────────────────────
  // TextField
  // ──────────────────────────────────────────────────────────────────────────
  static const Color textFieldBg = Color(0xFFEEF0F4);

  // ──────────────────────────────────────────────────────────────────────────
  // Semantic Aliases (for convenience)
  // ──────────────────────────────────────────────────────────────────────────
  static const Color textDark = gray900;
  static const Color textDarkSlate = slate800;
  static const Color textGray = slate500;
  static const Color textLightGray = slate400;
  static const Color textLabel = gray500;
  static const Color borderLight = slate200;
  static const Color borderDashed = slate300;
  static const Color dividerColor = slate200;
  static const Color scaffoldBg = backgroundOffWhite;
  static const Color cardBg = white;
  static const Color inputFill = slate50;
  static const Color darkBlueBg = slate900;
  static const Color errorColor = primaryRed;
  static const Color successColor = successGreen;
  static const Color warningColor = amberOrange;
}
