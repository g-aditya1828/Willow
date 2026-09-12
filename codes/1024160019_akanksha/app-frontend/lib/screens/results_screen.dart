import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/ingredient_data.dart';
import '../widgets/common.dart';
import '../widgets/sticker_layer.dart';

class ResultsScreen extends StatelessWidget {
  final AnalysisResult result;
  final String productName;
  final VoidCallback onReset;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.productName,
    required this.onReset,
  });

  Color get _ringColor {
    if (result.riskScore >= 75) return WillowColors.green;
    if (result.riskScore >= 50) return const Color(0xFFA8C24B);
    if (result.riskScore >= 25) return WillowColors.orange;
    return WillowColors.red;
  }

  PillTone get _scoreTone {
    if (result.riskScore >= 75) return PillTone.good;
    if (result.riskScore >= 50) return PillTone.good;
    if (result.riskScore >= 25) return PillTone.watch;
    return PillTone.bad;
  }

  List<Alternative> get _alternatives {
    final pool = alternativesDb[result.category] ?? alternativesDb['Uncategorized']!;
    return pool.where((a) => a.score > result.riskScore).take(2).toList();
  }

  String _summaryText() {
    final buf = StringBuffer()
      ..writeln('$productName — Willow score ${result.riskScore}/100 (${scoreLabelFor(result.riskScore)})')
      ..writeln('Category: ${result.category} · Confidence: ${result.confidence}%');
    if (result.flagged.isNotEmpty) {
      buf.writeln('Flagged: ${result.flagged.map((f) => f.entry.canonical).join(', ')}');
    }
    if (_alternatives.isNotEmpty) {
      buf.writeln('Try instead: ${_alternatives.map((a) => a.name).join(', ')}');
    }
    return buf.toString().trim();
  }

  void _copySummary(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _summaryText()));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Summary copied', style: willowBody(size: 12.5, color: Colors.white)),
        backgroundColor: WillowColors.ink,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final good = result.riskScore >= 50;
    return Stack(
      children: [
        FoodStickerLayer(stickers: good
            ? const [
                StickerSpec(emoji: '🍎', alignment: Alignment(-0.9, -0.85), rotationDeg: -8, phase: 0.1, size: 26),
                StickerSpec(emoji: '🥣', alignment: Alignment(0.9, -0.9), rotationDeg: 10, phase: 0.5, size: 26),
              ]
            : const [
                StickerSpec(emoji: '🌶️', alignment: Alignment(-0.9, -0.85), rotationDeg: -8, phase: 0.1, size: 26),
                StickerSpec(emoji: '🧂', alignment: Alignment(0.9, -0.9), rotationDeg: 10, phase: 0.5, size: 24),
              ]),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: WillowColors.line),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _ringColor, width: 8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${result.riskScore}', style: willowDisplay(size: 26)),
                            Text('/100', style: willowBody(size: 9, color: WillowColors.muted)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('WILLOW ANALYSIS', style: willowBody(size: 10, weight: FontWeight.w700, color: WillowColors.muted)),
                    const SizedBox(height: 4),
                    Text(productName, style: willowDisplay(size: 19), textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Pill(scoreLabelFor(result.riskScore), tone: _scoreTone),
                        Pill(result.category),
                        Pill('Confidence: ${result.confidence}%'),
                        if (result.fssai != null) Pill('FSSAI ${result.fssai}', tone: PillTone.good, icon: Icons.verified_outlined),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (result.isFallback)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCF0DC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEBCB8E)),
                        ),
                        child: Text(
                          'No ingredient list was detected, so this is an estimated, category-level '
                          'profile, not an exact analysis. ${result.fallbackNote ?? ""}',
                          style: willowBody(size: 11.5, color: const Color(0xFF9A6B1E)),
                        ),
                      )
                    else
                      Text(
                        'Based on ${result.flagged.length + result.clean.length} recognized ingredient'
                        '${result.flagged.length + result.clean.length == 1 ? "" : "s"}'
                        '${result.unknown.isNotEmpty ? " and ${result.unknown.length} unrecognized" : ""}.',
                        style: willowBody(size: 11.5, color: WillowColors.muted),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              if (!result.isFallback) ...[
                const SizedBox(height: 16),
                _card(
                  title: 'FLAGGED INGREDIENTS',
                  child: result.flagged.isEmpty
                      ? Row(children: [
                          const Icon(Icons.check_circle, size: 16, color: WillowColors.green),
                          const SizedBox(width: 6),
                          Text('Nothing flagged — nice.', style: willowBody(size: 12.5, color: WillowColors.muted)),
                        ])
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: result.flagged
                              .map((f) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        IconCircle(
                                          icon: f.entry.severity == Severity.high ? Icons.cancel_outlined : Icons.warning_amber_rounded,
                                          background: f.entry.severity == Severity.high ? WillowColors.badBg : WillowColors.watchBg,
                                          foreground: f.entry.severity == Severity.high ? WillowColors.badFg : WillowColors.watchFg,
                                          diameter: 26,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text.rich(TextSpan(children: [
                                                TextSpan(text: f.entry.canonical, style: willowBody(size: 12.5, weight: FontWeight.w600)),
                                                TextSpan(text: '  (${f.raw})', style: willowBody(size: 11, color: WillowColors.muted)),
                                              ])),
                                              Text(f.entry.effect, style: willowBody(size: 11, color: WillowColors.muted)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _card(
                  title: 'CLEAN / RECOGNIZED SAFE',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (result.clean.isEmpty)
                        Text('None of the recognized ingredients are marked clean.',
                            style: willowBody(size: 12, color: WillowColors.muted))
                      else
                        ...result.clean.map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                const IconCircle(icon: Icons.eco_outlined, background: WillowColors.goodBg, foreground: WillowColors.goodFg, diameter: 22),
                                const SizedBox(width: 8),
                                Expanded(child: Text(c.entry.canonical, style: willowBody(size: 12.5))),
                              ]),
                            )),
                      if (result.unknown.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Divider(color: WillowColors.line),
                        const SizedBox(height: 4),
                        Text('NOT RECOGNIZED', style: willowBody(size: 10.5, weight: FontWeight.w700, color: WillowColors.muted)),
                        const SizedBox(height: 4),
                        Text(result.unknown.join(', '), style: willowBody(size: 11.5, color: WillowColors.muted)),
                      ],
                    ],
                  ),
                ),
              ],
              if (_alternatives.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3E0),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFCFE0B6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.auto_awesome, size: 14, color: WillowColors.darkGreen),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('HEALTHIER ALTERNATIVES · SAME CATEGORY & PRICE BAND',
                              style: willowBody(size: 10.5, weight: FontWeight.w700, color: WillowColors.darkGreen)),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      ..._alternatives.map((a) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD9E8C4)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(a.name, style: willowBody(size: 12.5, weight: FontWeight.w600)),
                                      Text(a.price, style: willowBody(size: 11, color: WillowColors.muted)),
                                    ],
                                  ),
                                ),
                                Text('${a.score}/100', style: willowBody(size: 12, weight: FontWeight.w700, color: WillowColors.darkGreen)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _copySummary(context),
                    icon: const Icon(Icons.copy_outlined, size: 14),
                    label: Text('Copy summary', style: willowBody(size: 12, weight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: WillowColors.line),
                      foregroundColor: WillowColors.muted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.replay, size: 15),
                    label: Text('Scan another', style: willowBody(size: 12.5, weight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: WillowColors.line),
                      foregroundColor: WillowColors.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WillowColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: willowBody(size: 10.5, weight: FontWeight.w700, color: WillowColors.muted)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
