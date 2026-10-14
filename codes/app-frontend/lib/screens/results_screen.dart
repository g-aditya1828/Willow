import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/scan_model.dart';
import '../services/ingredient_scanner_service.dart';
import '../theme/app_theme.dart';

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

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  final _scanner = IngredientScannerService();
  late bool _isFavorite;
  late AnimationController _animCtrl;
  late Animation<double> _gaugeAnim;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.analysis.isFavorite;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _gaugeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _shareProduct() async {
    final a = widget.analysis;
    final lines = <String>[
      '🌿 Willow Food Safety Report',
      '━━━━━━━━━━━━━━━━━━━━━━━━',
      'Product : ${a.productName}',
      'Category: ${a.category}',
      'Score   : ${a.displayScore}/100  (${AppTheme.scoreLabel(a.displayScore)})',
      if (a.fssaiNumber != null) 'FSSAI   : ${a.fssaiNumber}',
      '',
      if (a.flagged.isNotEmpty) '⚠️ Flagged (${a.flagged.length}): ${a.flagged.map((f) => f.canonical).join(', ')}',
      if (a.clean.isNotEmpty) '✅ Clean  (${a.clean.length}): ${a.clean.take(5).map((c) => c.canonical).join(', ')}${a.clean.length > 5 ? '…' : ''}',
      '',
      'Scanned with Willow · willow.app',
    ];
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Report copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (widget.analysis.scanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign in to save this scan to favorites!")),
      );
      return;
    }
    final res = await _scanner.toggleFavorite(widget.analysis.scanId!);
    if (res != null && mounted) {
      setState(() => _isFavorite = res);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? "Saved to Favorites ⭐" : "Removed from Favorites"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    final off = a.offData;
    final score = a.displayScore;
    final scoreColor = AppTheme.scoreColor(score);
    final scoreText = AppTheme.scoreLabel(score);

    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      body: Stack(
        children: [
          // ── Background blobs ─────────────────────────────────────
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryPink.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── App Bar ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.pillSurface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share_rounded, color: AppTheme.textSecondary, size: 22),
                          tooltip: 'Copy report',
                          onPressed: _shareProduct,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Hero Food Image ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Soft green blob behind image
                        Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: scoreColor.withValues(alpha: 0.07),
                          ),
                        ),
                        // Food image
                        SizedBox(
                          height: 200,
                          child: widget.imageFile != null
                              ? Image.file(widget.imageFile!, fit: BoxFit.contain)
                              : off?.offImageUrl != null
                                  ? Image.network(
                                      off!.offImageUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Center(child: Text("🍽️", style: TextStyle(fontSize: 80))),
                                    )
                                  : const Center(child: Text("🍽️", style: TextStyle(fontSize: 90))),
                        ),
                        // Floating green "Excellent Choice" badge
                        Positioned(
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: scoreColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: scoreColor.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  scoreText,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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

                // ── Product Name + Favorite ────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            a.productName.isNotEmpty ? a.productName : "Scanned Product",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.6,
                              height: 1.15,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                            color: _isFavorite ? AppTheme.watchOrange : AppTheme.textMuted,
                            size: 28,
                          ),
                        ),
                        IconButton(
                          onPressed: _shareProduct,
                          icon: const Icon(Icons.share_rounded, color: AppTheme.textMuted, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Animated Score Gauge ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _gaugeAnim,
                        builder: (context, child) {
                          return _ScoreGauge(
                            score: score,
                            progress: _gaugeAnim.value,
                            color: scoreColor,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ── Nutrition Stats Row ────────────────────────────
                if (off?.nutrients != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _NutrientStat(
                              icon: "🔥",
                              value: off!.nutrients!.energyKcal != null
                                  ? "${off.nutrients!.energyKcal!.toInt()} kcal"
                                  : "—",
                              label: "Calories",
                            ),
                            _VertDivider(),
                            _NutrientStat(
                              icon: "🍬",
                              value: off.nutrients!.sugarsG != null
                                  ? "${off.nutrients!.sugarsG}g"
                                  : "—",
                              label: "Sugar",
                            ),
                            _VertDivider(),
                            _NutrientStat(
                              icon: "🌾",
                              value: off.nutrients!.fiberG != null
                                  ? "${off.nutrients!.fiberG}g"
                                  : "—",
                              label: "Fiber",
                            ),
                            _VertDivider(),
                            _NutrientStat(
                              icon: "💪",
                              value: off.nutrients!.proteinsG != null
                                  ? "${off.nutrients!.proteinsG}g"
                                  : "—",
                              label: "Protein",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── NutriScore + NOVA Row ──────────────────────────
                if (off != null &&
                    (off.nutriscoreGrade != null || off.novaGroup != null))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Row(
                        children: [
                          if (off.nutriscoreGrade != null)
                            Expanded(
                              child: _InfoBadge(
                                label: "NutriScore",
                                value: off.nutriscoreGrade!.toUpperCase(),
                                color: AppTheme.nutriscoreColor(off.nutriscoreGrade),
                              ),
                            ),
                          if (off.nutriscoreGrade != null && off.novaGroup != null)
                            const SizedBox(width: 12),
                          if (off.novaGroup != null)
                            Expanded(
                              child: _InfoBadge(
                                label: "NOVA Group",
                                value: "${off.novaGroup} / 4",
                                color: off.novaGroup! <= 2
                                    ? AppTheme.cleanGreen
                                    : off.novaGroup! == 3
                                        ? AppTheme.watchOrange
                                        : AppTheme.highRiskRed,
                                subtitle: _novaLabel(off.novaGroup!),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // ── AI Insight ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPinkBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Text("✨", style: TextStyle(fontSize: 11)),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "AI Insight",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryPink,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryPink,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "Beta",
                                        style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            off?.aiInsight ??
                                (a.flagged.isNotEmpty
                                    ? "Contains ${a.flagged.length} flagged additive(s). ${a.flagged.first.healthEffects}"
                                    : "This product appears safe based on FSSAI ingredient analysis. ${a.clean.length} clean ingredients verified."),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          if (a.fssaiNumber != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.cleanGreenBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "🛡️ FSSAI: ${a.fssaiNumber}",
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.cleanGreen,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Health Benefit + Best Time Tags ────────────────
                if (off?.healthBenefit != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TagButton(
                              icon: Icons.shield_outlined,
                              label: "Health Benefits",
                              sublabel: off!.healthBenefit!,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TagButton(
                              icon: Icons.wb_sunny_outlined,
                              label: "Best Time to Eat",
                              sublabel: off.bestTimeToEat ?? "Any Time",
                              color: AppTheme.watchOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Flagged Additives ──────────────────────────────
                if (a.flagged.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("⚠️", style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              const Text(
                                "Flagged Additives",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.alertRedBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${a.flagged.length}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.highRiskRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...a.flagged.map((f) => _FlaggedCard(ingredient: f)),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                // ── OFF Additives (if any) ─────────────────────────
                if (off != null && off.additives.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Additives (from Open Food Facts)",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: off.additives.map((ad) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.alertOrangeBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                ad,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.watchOrange,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Alternatives ───────────────────────────────────
                if (a.alternatives.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Healthy Alternatives",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...a.alternatives.map(
                            (alt) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.cleanGreenBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${alt.score}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.cleanGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alt.name,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          alt.price,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
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

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _novaLabel(int group) {
    switch (group) {
      case 1: return "Unprocessed";
      case 2: return "Processed Ingredient";
      case 3: return "Processed Food";
      case 4: return "Ultra-Processed";
      default: return "";
    }
  }
}

// ── Score Gauge Widget ─────────────────────────────────────────────────
class _ScoreGauge extends StatelessWidget {
  final int score;
  final double progress;
  final Color color;

  const _ScoreGauge({
    required this.score,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(150, 150),
            painter: _GaugePainter(
              progress: progress * (score / 100.0),
              color: color,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$score",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1,
                ),
              ),
              Text(
                "/100",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Overall Score",
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 10.0;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFFEEF0F5)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.8,
      math.pi * 1.6,
      false,
      bgPaint,
    );

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.8,
      math.pi * 1.6 * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.progress != progress;
}

// ── Nutrient Stat Widget ──────────────────────────────────────────────
class _NutrientStat extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _NutrientStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.dividerColor,
    );
  }
}

// ── Info Badge (NutriScore / NOVA) ────────────────────────────────────
class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  const _InfoBadge({
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 10.5, color: color),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tag Button (Health Benefit / Best Time) ──────────────────────────
class _TagButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _TagButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Flagged Ingredient Card ───────────────────────────────────────────
class _FlaggedCard extends StatelessWidget {
  final FlaggedIngredient ingredient;

  const _FlaggedCard({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final isHigh = ingredient.riskLevel == 'high';
    final color = isHigh ? AppTheme.highRiskRed : AppTheme.watchOrange;
    final bgColor = isHigh ? AppTheme.alertRedBg : AppTheme.alertOrangeBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ingredient.canonical,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isHigh ? "HIGH" : "WATCH",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  ingredient.healthEffects,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
