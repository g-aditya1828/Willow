import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Brand Colors from Figma ──────────────────────────────
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryPurpleDark = Color(0xFF5B21B6);
  static const Color primaryPurpleLight = Color(0xFFEDE9FE);
  static const Color primaryPurpleSoft = Color(0xFFF5F3FF);
  static const Color purpleBorder = Color(0xFFDDD6FE);

  static const Color textHeading = Color(0xFF090E21);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF5F3FF);
  static const Color bgDark = Color(0xFF0F1A2E);

  // Accents & Nutrition colors from Figma
  static const Color tealAccent = Color(0xFF4ECDC4);
  static const Color blueAccent = Color(0xFF4E8BFF);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color greenSuccess = Color(0xFF22C55E);
  static const Color greenDeep = Color(0xFF16A34A);
  static const Color greenSoftBg = Color(0xFFDFFFEE);
  static const Color amberWarning = Color(0xFFFF9500);
  static const Color amberSoftBg = Color(0xFFFFF3E0);
  static const Color redDanger = Color(0xFFFF4D6D);
  static const Color redSoftBg = Color(0xFFFFE8EC);
  static const Color saltBlue = Color(0xFF00B4D8);
  static const Color saltSoftBg = Color(0xFFE0F7FF);

  // Score colors & backgrounds
  static const Color scoreHighColor = Color(0xFF22C55E);
  static const Color scoreHighBg = Color(0xFFDFFFEE);
  static const Color scoreMidColor = Color(0xFFFF9500);
  static const Color scoreMidBg = Color(0xFFFFF3E0);
  static const Color scoreLowColor = Color(0xFFFF4D6D);
  static const Color scoreLowBg = Color(0xFFFFE8EC);

  // ── Exact Figma Gradients ─────────────────────────────────────
  // 1. Welcome / Login Screen Background
  static const LinearGradient welcomeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6B4EFF), Color(0xFF4E8BFF), Color(0xFF4ECDC4)],
    stops: [0.0, 0.55, 1.0],
  );

  // 2. Home Top Header Ambient Gradient
  static const LinearGradient homeTopGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6B4EFF), Color(0xFF4E8BFF), Color(0xFFB8E0F7)],
    stops: [0.0, 0.50, 1.0],
  );

  // 3. Scan History Top Gradient
  static const LinearGradient historyTopGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF6B4EFF),
      Color(0xFF4E8BFF),
      Color(0xFFB8E0F7),
      Color(0xFFF0F4FF),
    ],
    stops: [0.0, 0.45, 0.75, 1.0],
  );

  // 4. Alternatives Top Gradient
  static const LinearGradient alternativesTopGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6B4EFF), Color(0xFF4E8BFF), Color(0xFFB8E0F7)],
    stops: [0.0, 0.45, 1.0],
  );

  // 5. Camera Viewport Shading
  static const LinearGradient cameraOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xE86C3FD4),
      Color(0xE61A3A5C),
      Color(0x000B2A18),
      Color(0xCC1A0A3B),
      Color(0xF50F0826),
    ],
    stops: [0.0, 0.38, 0.60, 0.82, 1.0],
  );

  // 6. Action Button Gradient
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7C3AED), Color(0xFF4E8BFF), Color(0xFF4ECDC4)],
    stops: [0.0, 0.60, 1.0],
  );

  // 7. Home Scan Invitation Banner
  static const LinearGradient scanHeroBannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
  );

  // 8. Dynamic Score Pill Gradients
  static const LinearGradient scoreLowGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
  );

  static const LinearGradient scoreMidGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF9500), Color(0xFFFFB800)],
  );

  static const LinearGradient scoreHighGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4ECDC4), Color(0xFF44CF6C)],
  );

  static LinearGradient scoreGradient(int score) {
    if (score >= 75) return scoreHighGradient;
    if (score >= 60) return scoreMidGradient;
    return scoreLowGradient;
  }

  // 9. Navigation Pill Highlight
  static const LinearGradient navActivePillGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
  );

  // 10. Filter Active Pill
  static const LinearGradient filterActiveGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6B4EFF), Color(0xFF4E8BFF)],
  );

  // 11. Cyan Scan Line
  static const LinearGradient scanLineGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0x0006B6D4), Color(0xFF22D3EE), Color(0x0006B6D4)],
    stops: [0.0, 0.5, 1.0],
  );

  // 12. Detected Card Top Accent Line
  static const LinearGradient detectedCardAccentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFEDE9FE), Color(0xFF06B6D4), Color(0xFF10B981)],
    stops: [0.0, 0.5, 1.0],
  );

  // 13. See Product Rating Button
  static const LinearGradient seeRatingBtnGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF4E8BFF),
      Color(0xFF24A4E6),
      Color(0xFF28A2E8),
      Color(0xFF06B6D4),
    ],
    stops: [0.0, 0.25, 0.65, 1.0],
  );

  // 14. Product Rating Hero Image Background
  static const LinearGradient productHeroGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE8E0FF), Color(0xFFC7DCFF), Color(0xFFD4F5F0)],
    stops: [0.0, 0.5, 1.0],
  );

  // 15. Product Rating Score Header
  static const LinearGradient scoreHeaderLowGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFA07A)],
    stops: [0.0, 0.60, 1.0],
  );

  static const LinearGradient scoreHeaderMidGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF9500), Color(0xFFFFB800)],
  );

  static const LinearGradient scoreHeaderHighGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4ECDC4), Color(0xFF44CF6C)],
  );

  static LinearGradient scoreHeaderGradient(int score) {
    if (score >= 75) return scoreHeaderHighGradient;
    if (score >= 60) return scoreHeaderMidGradient;
    return scoreHeaderLowGradient;
  }

  // 16. Swaps Explore CTA Button
  static const LinearGradient exploreSwapsBtnGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7B5CF0), Color(0xFF5E8EFF)],
  );

  // ── Helper Getters ───────────────────────────────────────────
  static Color scoreColor(int score) {
    if (score >= 75) return scoreHighColor;
    if (score >= 60) return scoreMidColor;
    return scoreLowColor;
  }

  static Color scoreBgColor(int score) {
    if (score >= 75) return scoreHighBg;
    if (score >= 60) return scoreMidBg;
    return scoreLowBg;
  }

  static String scoreLabel(int score) {
    if (score >= 75) return 'Great choice';
    if (score >= 60) return 'Decent choice';
    if (score >= 40) return 'Room to improve';
    return 'Poor choice';
  }

  static Color nutriscoreColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return const Color(0xFF038141);
      case 'b':
        return const Color(0xFF85BB2F);
      case 'c':
        return const Color(0xFFFECC00);
      case 'd':
        return const Color(0xFFEE8100);
      case 'e':
        return const Color(0xFFE63E11);
      default:
        return textMuted;
    }
  }

  // Aliases for compatibility
  static const Color cardSurface = bgWhite;
  static const Color cardBorder = borderLight;
  static const Color scoreRedColor = redDanger;
  static const Color scoreRedBg = redSoftBg;
  static const Color highRiskRed = redDanger;
  static const Color cleanGreen = greenDeep;
  static const Color cleanGreenBg = greenSoftBg;
  static const Color dividerColor = Color(0xFFF0F0F5);
  static const Color bgOffWhite = bgLight;
  static const Color alertOrangeBg = amberSoftBg;
  static const Color watchOrange = amberWarning;
  static const Color primaryOrange = primaryPurple;
  static const Color tagHighRisk = redDanger;
  static const Color tagHighRiskBg = redSoftBg;
  static const Color tagModerate = amberWarning;
  static const Color tagModerateBg = amberSoftBg;
  static const Color tagGood = greenSuccess;
  static const Color tagGoodBg = greenSoftBg;
  static const Color tagLow = saltBlue;
  static const Color tagLowBg = saltSoftBg;

  static const LinearGradient loginGradient = welcomeGradient;
  static const LinearGradient purpleGradient = primaryButtonGradient;

  // ── ThemeData ────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.light,
        primary: primaryPurple,
        surface: bgWhite,
      ),
      scaffoldBackgroundColor: bgLight,
      textTheme: GoogleFonts.interTextTheme(),
      cardTheme: CardThemeData(
        color: bgWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryPurpleSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: purpleBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: purpleBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      ),
    );
  }
}
