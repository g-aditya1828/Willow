import 'dart:math' as math;
import 'package:flutter/material.dart';

/// One decorative sticker: an emoji placed at a relative position (0..1
/// alignment space), with its own size, tilt, and animation phase so a
/// whole layer never bobs in unison (that reads as one moving blob instead
/// of a scatter of stickers).
class StickerSpec {
  final String emoji;
  final Alignment alignment;
  final double size;
  final double rotationDeg;
  final double phase; // 0..1, offsets the bob cycle per sticker
  final double opacity;

  const StickerSpec({
    required this.emoji,
    required this.alignment,
    this.size = 34,
    this.rotationDeg = 0,
    this.phase = 0,
    this.opacity = 0.9,
  });
}

/// A pool of food stickers to draw from. Each screen picks a themed subset
/// so the cast of stickers feels intentional rather than random noise.
const kFoodStickers = <String>[
  '🥨', '🌶️', '🥜', '🧂', '🍪', '🥭', '🌾', '🍩', '🥫', '🍎', '🥣', '🍯', '🥕', '🫘'
];

/// Renders a set of stickers behind the page content. Wrapped in
/// IgnorePointer so it never intercepts taps meant for real UI underneath.
class FoodStickerLayer extends StatefulWidget {
  final List<StickerSpec> stickers;
  const FoodStickerLayer({super.key, required this.stickers});

  @override
  State<FoodStickerLayer> createState() => _FoodStickerLayerState();
}

class _FoodStickerLayerState extends State<FoodStickerLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: widget.stickers.map((s) {
              final t = (_controller.value + s.phase) * 2 * math.pi;
              final bob = math.sin(t) * 6; // gentle 6px vertical float
              return Align(
                alignment: s.alignment,
                child: Transform.translate(
                  offset: Offset(0, bob),
                  child: Transform.rotate(
                    angle: s.rotationDeg * math.pi / 180,
                    child: Opacity(
                      opacity: s.opacity,
                      child: Text(s.emoji, style: TextStyle(fontSize: s.size)),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
