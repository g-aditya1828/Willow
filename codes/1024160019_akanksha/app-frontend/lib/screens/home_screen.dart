import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../data/ingredient_data.dart';
import '../widgets/common.dart';
import '../widgets/sticker_layer.dart';

class HomeScreen extends StatefulWidget {
  final void Function({File? image, required String productName}) onPhotoChosen;
  final VoidCallback onManualEntry;
  final void Function(SampleProduct) onSampleChosen;

  const HomeScreen({
    super.key,
    required this.onPhotoChosen,
    required this.onManualEntry,
    required this.onSampleChosen,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _busy = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.selectionClick();
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1600);
      if (file == null) return; // user cancelled — nothing to report
      final name = file.name
          .replaceAll(RegExp(r'\.[^.]+$'), '')
          .replaceAll(RegExp(r'[-_]+'), ' ')
          .trim();
      widget.onPhotoChosen(image: File(file.path), productName: name);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final message = e.code == 'camera_access_denied' || e.code == 'photo_access_denied'
          ? 'Willow needs camera/photo permission — enable it in Settings and try again.'
          : "Couldn't open ${source == ImageSource.camera ? 'the camera' : 'your gallery'}. Please try again.";
      _showError(message);
    } catch (_) {
      if (!mounted) return;
      _showError('Something went wrong picking that image. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: willowBody(size: 12.5, color: Colors.white)),
        backgroundColor: WillowColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const FoodStickerLayer(stickers: [
          StickerSpec(emoji: '🥨', alignment: Alignment(-0.9, -0.85), rotationDeg: -12, phase: 0.1),
          StickerSpec(emoji: '🌶️', alignment: Alignment(0.9, -0.9), rotationDeg: 14, phase: 0.4),
          StickerSpec(emoji: '🍎', alignment: Alignment(0.95, 0.15), rotationDeg: -8, phase: 0.7),
          StickerSpec(emoji: '🥜', alignment: Alignment(-0.95, 0.2), size: 28, rotationDeg: 10, phase: 0.25),
          StickerSpec(emoji: '🧂', alignment: Alignment(-0.8, 0.9), size: 26, rotationDeg: -6, phase: 0.55),
          StickerSpec(emoji: '🍩', alignment: Alignment(0.85, 0.85), size: 30, rotationDeg: 8, phase: 0.85),
        ]),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Text('THE INDIAN FOOD LABEL SCANNER',
                        style: willowBody(size: 11, weight: FontWeight.w700, color: WillowColors.darkGreen)),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(text: "What's really inside\n", style: willowDisplay(size: 32)),
                        TextSpan(text: 'your food?', style: willowDisplay(size: 32, color: WillowColors.green)),
                      ]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Snap a label photo or paste the ingredient list. Willow flags harmful "
                      "ingredients, explains why, and scores the product from 0–100.",
                      textAlign: TextAlign.center,
                      style: willowBody(size: 13, color: WillowColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _CaptureCard(
                      icon: Icons.photo_camera_outlined,
                      iconBg: const Color(0xFFEAF3DE),
                      iconFg: WillowColors.darkGreen,
                      title: 'Take a photo',
                      subtitle: 'Use your camera',
                      busy: _busy,
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CaptureCard(
                      icon: Icons.image_outlined,
                      iconBg: const Color(0xFFF3EDE1),
                      iconFg: const Color(0xFF8A7A56),
                      title: 'Choose from gallery',
                      subtitle: 'Pick an existing photo',
                      busy: _busy,
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onManualEntry();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  decoration: BoxDecoration(
                    color: WillowColors.paper,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: WillowColors.line, width: 1.4),
                  ),
                  child: Row(
                    children: [
                      const IconCircle(icon: Icons.edit_note, background: WillowColors.neutralBg, foreground: WillowColors.neutralFg),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type ingredients manually', style: willowBody(size: 13, weight: FontWeight.w600)),
                            Text('Good for damaged or missing labels', style: willowBody(size: 11, color: WillowColors.muted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: WillowColors.muted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: WillowColors.paper,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: WillowColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OR TRY A SAMPLE PRODUCT',
                        style: willowBody(size: 11, weight: FontWeight.w700, color: WillowColors.muted)),
                    const SizedBox(height: 10),
                    ...sampleProducts.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onSampleChosen(s);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: WillowColors.line),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.name, style: willowBody(size: 13, weight: FontWeight.w600)),
                                        Text(s.hasLabel ? 'Has printed ingredients' : 'No printed label',
                                            style: willowBody(size: 11, color: WillowColors.muted)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward, size: 14, color: WillowColors.muted),
                                ],
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              if (_busy) ...[
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: WillowColors.darkGreen),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CaptureCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool busy;
  const _CaptureCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: busy ? 0.5 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: busy ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: WillowColors.paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: WillowColors.line, width: 1.4),
          ),
          child: Column(
            children: [
              IconCircle(icon: icon, background: iconBg, foreground: iconFg, diameter: 42),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center, style: willowBody(size: 12.5, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, textAlign: TextAlign.center, style: willowBody(size: 10, color: WillowColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
