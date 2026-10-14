import 'package:flutter/material.dart';

/// Willow AI Food Scanner — Premium Pink/White Theme
/// Matches the "AI Food Scanner" reference design with:
/// - White frosted background
/// - Hot pink primary accent (#FF2D78)
/// - Green for excellent/safe scores
/// - Dark navy text
class AppTheme {
  // ── Primary Brand Colors ──────────────────────────────────────────
  static const Color primaryPink = Color(0xFFFF2D78);
  static const Color primaryPinkLight = Color(0xFFFF6BA3);
  static const Color primaryPinkBg = Color(0xFFFFECF3);

  // Kept for backward compat — maps to primary pink
  static const Color primaryOrange = primaryPink;
  static const Color primaryOrangeLight = primaryPinkBg;

  // ── Score / Status Colors ─────────────────────────────────────────
  static const Color scoreExcellent = Color(0xFF22C55E); // green ≥75
  static const Color scoreGood = Color(0xFF84CC16);       // lime 60-74
  static const Color scoreModerate = Color(0xFFF59E0B);   // amber 40-59
  static const Color scorePoor = Color(0xFFEF4444);        // red <40

  static const Color cleanGreen = Color(0xFF22C55E);
  static const Color cleanGreenBg = Color(0xFFDCFCE7);
  static const Color watchOrange = Color(0xFFF59E0B);
  static const Color alertOrangeBg = Color(0xFFFEF3C7);
  static const Color highRiskRed = Color(0xFFEF4444);
  static const Color alertRedBg = Color(0xFFFEE2E2);

  // ── Backgrounds & Surfaces ────────────────────────────────────────
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgOffWhite = Color(0xFFF8F9FC);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color pillSurface = Color(0xFFF3F4F8);

  // ── Text Colors ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFFCBD5E1);

  // ── Borders & Dividers ────────────────────────────────────────────
  static const Color cardBorder = Color(0xFFE8ECF4);
  static const Color dividerColor = Color(0xFFF1F5F9);

  // ── Gradients ─────────────────────────────────────────────────────
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6BA3), Color(0xFFFF2D78)],
  );

  // Kept for backward compat
  static const LinearGradient orangeGradient = pinkGradient;

  // ── Score Color Helpers ───────────────────────────────────────────
  static Color scoreColor(int score) {
    if (score >= 75) return scoreExcellent;
    if (score >= 60) return scoreGood;
    if (score >= 40) return scoreModerate;
    return scorePoor;
  }

  static String scoreLabel(int score) {
    if (score >= 75) return "Excellent Choice";
    if (score >= 60) return "Good Choice";
    if (score >= 40) return "Moderate";
    return "Caution";
  }

  // ── NutriScore Badge Color ─────────────────────────────────────────
  static Color nutriscoreColor(String? grade) {
    switch (grade?.toLowerCase()) {
      case 'a': return const Color(0xFF038141);
      case 'b': return const Color(0xFF85BB2F);
      case 'c': return const Color(0xFFFECC00);
      case 'd': return const Color(0xFFEE8100);
      case 'e': return const Color(0xFFE63E11);
      default: return const Color(0xFF94A3B8);
    }
  }

  // ── Material Theme ────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgWhite,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryPink,
        onPrimary: Colors.white,
        secondary: primaryPinkLight,
        onSecondary: Colors.white,
        error: highRiskRed,
        onError: Colors.white,
        surface: bgWhite,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPink,
          side: const BorderSide(color: primaryPink, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: cardBorder, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F8FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryPink, width: 1.6),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      ),
    );
  }
}
