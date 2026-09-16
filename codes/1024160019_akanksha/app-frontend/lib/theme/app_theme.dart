import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF15803D);
  static const Color primaryDark = Color(0xFF14532D);
  static const Color bgMint = Color(0xFFF0FDF4);

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  // Card
  static const Color cardBorder = Color(0xFFE5E7EB);

  // Tag colors — alert (red)
  static const Color alertRedBg = Color(0xFFFEE2E2);
  static const Color alertRedText = Color(0xFFB91C1C);

  // Tag colors — clean (green)
  static const Color cleanGreenBg = Color(0xFFDCFCE7);
  static const Color cleanGreenText = Color(0xFF166534);

  // Tag colors — swap (teal)
  static const Color swapTealBg = Color(0xFFCCFBF1);
  static const Color swapTealText = Color(0xFF0D9488);

  // Tag colors — orange (default/fallback)
  static const Color alertOrangeBg = Color(0xFFFFEDD5);
  static const Color alertOrangeText = Color(0xFFC2410C);

  // Misc
  static const Color starYellow = Color(0xFFEAB308);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: bgMint,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        background: bgMint,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textPrimary),
      ),
    );
  }
}
