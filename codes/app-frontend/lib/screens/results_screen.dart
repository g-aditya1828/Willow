import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/scan_model.dart';
import '../services/ingredient_scanner_service.dart';
import '../theme/app_theme.dart';
import 'alternatives_screen.dart';

class ResultsScreen extends StatefulWidget {
  final ProductAnalysis analysis;
  final File? imageFile;

  const ResultsScreen({
    super.key,
    required this.analysis,
    this.imageFile,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _scanner = IngredientScannerService();
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.analysis.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    if (widget.analysis.scanId == null) {
      setState(() => _isFavorite = !_isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Saved to Bookmarks ⭐' : 'Removed from Bookmarks'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    final res = await _scanner.toggleFavorite(widget.analysis.scanId!);
    if (res != null && mounted) {
      setState(() => _isFavorite = res);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Saved to Bookmarks ⭐' : 'Removed from Bookmarks'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showScoreMethodology() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'How this score is built',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildBreakdownRow(
                'FSSAI Ingredient Safety',
                '60% weight',
                '${widget.analysis.riskScore}/100',
              ),
              const SizedBox(height: 12),
              _buildBreakdownRow(
                'Nutri-Score Grade',
                '30% weight',
                widget.analysis.offData?.nutriscoreGrade?.toUpperCase() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildBreakdownRow(
                'NOVA Processing Group',
                '10% weight',
                widget.analysis.offData?.novaGroup != null
                    ? 'Group ${widget.analysis.offData!.novaGroup}'
                    : 'N/A',
              ),
              const SizedBox(height: 20),
              Text(
                'Willow evaluates raw additives, banned emulsifiers, sugars, and nutritional density deterministically using official FSSAI standards.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownRow(String title, String weight, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              weight,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryPurple,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    final score = a.displayScore;
    final totalIngredients = a.flagged.length + a.clean.length + a.unknown.length;

    // Nutrients from Open Food Facts if available
    final nutrients = a.offData?.nutrients;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header (Figma #2:1993) ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    'Product rating',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: _isFavorite ? AppTheme.primaryPurple : AppTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Product Hero Banner (Figma #2:1999) ──────────────────
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: AppTheme.productHeroGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Badge top-left
                          Positioned(
                            left: 14,
                            top: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                a.isFallback ? 'CATEGORY ESTIMATE' : 'VERIFIED SCAN',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: const Color(0xFF7B5CF0),
                                ),
                              ),
                            ),
                          ),

                          // Center Image or Product Icon
                          Center(
                            child: widget.imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      widget.imageFile!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.inventory_2_rounded,
                                    color: Color(0xFF7B5CF0),
                                    size: 80,
                                  ),
                          ),

                          // Bottom Title & Category
                          Positioned(
                            left: 18,
                            right: 18,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.category.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF7B5CF0),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  a.productName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Health Rating Score Banner (Figma #2:2006) ───────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.scoreHeaderGradient(score),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Score ring 80x80 (Figma #12:45)
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Text(
                                  '$score/100',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'WILLOW SCORE',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Rating explanation
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.scoreLabel.isNotEmpty
                                      ? a.scoreLabel
                                      : AppTheme.scoreLabel(score),
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  a.offData?.aiInsight ??
                                      (score >= 75
                                          ? 'Clean profile with minimal risk additives.'
                                          : (score >= 60
                                              ? 'Moderate processing; balanced nutrient ratio.'
                                              : 'High risk ingredients or sugars detected in label.')),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Nutrition at a Glance (Figma #2:2013) ────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nutrition at a glance',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Per 100 g',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF7B5CF0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Energy row
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Energy',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  nutrients?.energyKcal != null
                                      ? '${nutrients!.energyKcal!.toInt()} kcal'
                                      : 'Label data pending',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xFFEEEEF5), height: 1),
                          const SizedBox(height: 8),

                          // Nutrients Rows with colored vertical marker bars (Figma layout_f316f12d)
                          _buildNutrientRow(
                            name: 'Sugars',
                            amount: nutrients?.sugarsG != null
                                ? '${nutrients!.sugarsG} g'
                                : (a.flagged.any((f) => f.canonical.contains('sugar')) ? 'High' : 'N/A'),
                            markerColor: AppTheme.redDanger,
                            badgeText: nutrients?.sugarsG != null
                                ? (nutrients!.sugarsG! > 10 ? 'High' : 'Low')
                                : 'High',
                            badgeColor: AppTheme.redDanger,
                            badgeBg: AppTheme.redSoftBg,
                          ),
                          _buildNutrientRow(
                            name: 'Saturated fat',
                            amount: nutrients?.saturatedFatG != null
                                ? '${nutrients!.saturatedFatG} g'
                                : 'Moderate',
                            markerColor: AppTheme.amberWarning,
                            badgeText: 'Moderate',
                            badgeColor: AppTheme.amberWarning,
                            badgeBg: AppTheme.amberSoftBg,
                          ),
                          _buildNutrientRow(
                            name: 'Fibre',
                            amount: nutrients?.fiberG != null
                                ? '${nutrients!.fiberG} g'
                                : 'Good',
                            markerColor: AppTheme.greenSuccess,
                            badgeText: 'Good',
                            badgeColor: AppTheme.greenSuccess,
                            badgeBg: AppTheme.greenSoftBg,
                          ),
                          _buildNutrientRow(
                            name: 'Salt',
                            amount: nutrients?.saltG != null
                                ? '${nutrients!.saltG} g'
                                : 'Low',
                            markerColor: AppTheme.saltBlue,
                            badgeText: 'Low',
                            badgeColor: AppTheme.saltBlue,
                            badgeBg: AppTheme.saltSoftBg,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Inside the Ingredients (Figma #2:2041) ────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Inside the ingredients',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '$totalIngredients ingredients',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF7B5CF0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Text with highlighted additives / ingredients
                          if (a.flagged.isNotEmpty) ...[
                            Text(
                              'Flagged Additives & Sugars:',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.redDanger,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...a.flagged.map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: AppTheme.redDanger)),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${f.canonical}: ',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            TextSpan(
                                              text: f.healthEffects,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          if (a.clean.isNotEmpty) ...[
                            Text(
                              'Clean Ingredients Detected:',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.greenDeep,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a.clean.map((c) => c.canonical).join(', '),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Ingredient insight callout (Figma #2:2046)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF5E0), Color(0xFFFFF0D0)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB800),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    a.flagged.isNotEmpty
                                        ? '${a.flagged.length} additives or refined sugars detected. Ingredients are listed from most to least by weight.'
                                        : 'Clean ingredient formulation. Minimal or zero synthetic additives detected.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFFA06000),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Score Methodology Link (Figma #2:2050) ───────────────
                    GestureDetector(
                      onTap: _showScoreMethodology,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE9FF),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.bar_chart_rounded,
                                    color: AppTheme.primaryPurple,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'How this score is built',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Action CTA Button "Explore better-rated swaps" (Figma #2:2055) ──
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AlternativesScreen(
                              originalProduct: a,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.exploreSwapsBtnGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Explore better-rated swaps',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Medical Notice (Figma #2:2058)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.textMuted,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Illustrative products & scores. Not medical advice.',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow({
    required String name,
    required String amount,
    required Color markerColor,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Vertical colored marker bar (Figma layout_f316f12d)
          Container(
            width: 6,
            height: 28,
            decoration: BoxDecoration(
              color: markerColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          // Level badge (Figma layout_d2a5df53)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
