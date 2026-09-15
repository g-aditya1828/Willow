import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand palette — cream/green, matching the existing Willow website.
class WillowColors {
  static const cream = Color(0xFFFAF2E7);
  static const paper = Color(0xFFFFFDF9);
  static const ink = Color(0xFF242424);
  static const green = Color(0xFF7D9D52);
  static const darkGreen = Color(0xFF4C6B2F);
  static const orange = Color(0xFFF39B22);
  static const yellow = Color(0xFFF5CA55);
  static const red = Color(0xFFED4A4A);
  static const line = Color(0xFFECDFCD);
  static const muted = Color(0xFFA39C8C);
  static const watchBg = Color(0xFFFCF0DC);
  static const watchFg = Color(0xFF8A5A12);
  static const goodBg = Color(0xFFEAF3DE);
  static const goodFg = Color(0xFF4C6B2F);
  static const badBg = Color(0xFFFBE7E7);
  static const badFg = Color(0xFFB23A3A);
  static const neutralBg = Color(0xFFF2EEE6);
  static const neutralFg = Color(0xFF726C5C);
}

TextStyle willowDisplay({double size = 28, FontWeight weight = FontWeight.w700, Color? color}) {
  return GoogleFonts.playfairDisplay(fontSize: size, fontWeight: weight, color: color ?? WillowColors.ink, height: 1.08);
}

TextStyle willowBody({double size = 14, FontWeight weight = FontWeight.w400, Color? color}) {
  return GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color ?? WillowColors.ink);
}

/// Small uppercase-ish section label used above form fields and cards.
class SectionLabel extends StatelessWidget {
  final String text;
  final String? hint;
  const SectionLabel(this.text, {super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(text: text, style: willowBody(size: 11, weight: FontWeight.w700, color: WillowColors.muted)),
          if (hint != null)
            TextSpan(text: '  ·  $hint', style: willowBody(size: 11, weight: FontWeight.w400, color: WillowColors.muted.withOpacity(0.7))),
        ]),
      ),
    );
  }
}

/// A colored circular badge behind an icon — used on capture options and
/// flagged-ingredient rows so the icon reads as a deliberate design choice
/// rather than a bare Material icon.
class IconCircle extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final double diameter;
  const IconCircle({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.diameter = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: diameter * 0.46, color: foreground),
    );
  }
}

enum PillTone { neutral, good, watch, bad }

Color _pillBg(PillTone t) => switch (t) {
      PillTone.neutral => WillowColors.neutralBg,
      PillTone.good => WillowColors.goodBg,
      PillTone.watch => WillowColors.watchBg,
      PillTone.bad => WillowColors.badBg,
    };

Color _pillFg(PillTone t) => switch (t) {
      PillTone.neutral => WillowColors.neutralFg,
      PillTone.good => WillowColors.goodFg,
      PillTone.watch => WillowColors.watchFg,
      PillTone.bad => WillowColors.badFg,
    };

class Pill extends StatelessWidget {
  final String text;
  final PillTone tone;
  final IconData? icon;
  const Pill(this.text, {super.key, this.tone = PillTone.neutral, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _pillBg(tone), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: _pillFg(tone)),
            const SizedBox(width: 4),
          ],
          Text(text, style: willowBody(size: 11, weight: FontWeight.w600, color: _pillFg(tone))),
        ],
      ),
    );
  }
}

const kSteps = ['Capture', 'Review', 'Analyze', 'Results'];

/// Top-of-screen step tracker: filled dot + label for the current step,
/// checkmarks for completed ones, hollow dots ahead. Tapping a completed
/// step's dot jumps back to it (a small but real usability win — nobody
/// likes being stuck going only forward).
class ProgressRail extends StatelessWidget {
  final int stepIndex;
  final void Function(int)? onStepTap;
  const ProgressRail({super.key, required this.stepIndex, this.onStepTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < kSteps.length; i++) ...[
          GestureDetector(
            onTap: (i < stepIndex && onStepTap != null) ? () => onStepTap!(i) : null,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < stepIndex
                        ? WillowColors.darkGreen
                        : i == stepIndex
                            ? Colors.white
                            : WillowColors.neutralBg,
                    border: Border.all(color: i <= stepIndex ? WillowColors.darkGreen : WillowColors.line, width: 1.4),
                  ),
                  alignment: Alignment.center,
                  child: i < stepIndex
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : Text('${i + 1}',
                          style: willowBody(
                              size: 11,
                              weight: FontWeight.w700,
                              color: i == stepIndex ? WillowColors.darkGreen : WillowColors.muted)),
                ),
                const SizedBox(height: 4),
                Text(kSteps[i],
                    style: willowBody(
                        size: 9.5,
                        weight: FontWeight.w600,
                        color: i <= stepIndex ? WillowColors.darkGreen : WillowColors.muted)),
              ],
            ),
          ),
          if (i < kSteps.length - 1)
            Container(
              width: 28,
              height: 1.4,
              margin: const EdgeInsets.only(bottom: 14),
              color: i < stepIndex ? WillowColors.darkGreen : WillowColors.line,
            ),
        ],
      ],
    );
  }
}
