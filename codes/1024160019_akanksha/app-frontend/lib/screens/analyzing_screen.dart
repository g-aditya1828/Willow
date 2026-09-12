import 'package:flutter/material.dart';
import '../widgets/common.dart';
import '../widgets/sticker_layer.dart';

class AnalyzingScreen extends StatelessWidget {
  const AnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const FoodStickerLayer(stickers: [
          StickerSpec(emoji: '🥕', alignment: Alignment(-0.8, -0.3), rotationDeg: -8, phase: 0.1, size: 24),
          StickerSpec(emoji: '🫘', alignment: Alignment(0.8, -0.5), rotationDeg: 10, phase: 0.5, size: 22),
          StickerSpec(emoji: '🍯', alignment: Alignment(0.75, 0.5), rotationDeg: -6, phase: 0.8, size: 24),
        ]),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(strokeWidth: 3, color: WillowColors.darkGreen),
              ),
              const SizedBox(height: 18),
              Text('Checking ingredients against harm rules…',
                  style: willowBody(size: 13.5, weight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Normalizing aliases, scoring, finding alternatives',
                  style: willowBody(size: 11.5, color: WillowColors.muted)),
            ],
          ),
        ),
      ],
    );
  }
}
