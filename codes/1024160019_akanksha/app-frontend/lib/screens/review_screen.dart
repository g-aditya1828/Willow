import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/ingredient_data.dart';
import '../widgets/common.dart';
import '../widgets/sticker_layer.dart';

class ReviewScreen extends StatefulWidget {
  final File? image;
  final String initialProductName;
  final String initialIngredientText;
  final String initialFssai;
  final VoidCallback onBack;
  final void Function({
    required String productName,
    required String ingredientText,
    required String fssai,
    String? manualCategory,
  }) onAnalyze;

  const ReviewScreen({
    super.key,
    required this.image,
    required this.initialProductName,
    required this.initialIngredientText,
    required this.initialFssai,
    required this.onBack,
    required this.onAnalyze,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ingredientsCtrl;
  late final TextEditingController _fssaiCtrl;
  final _fssaiFocus = FocusNode();
  String? _manualCategory;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialProductName);
    _ingredientsCtrl = TextEditingController(text: widget.initialIngredientText)..addListener(() => setState(() {}));
    _fssaiCtrl = TextEditingController(text: widget.initialFssai);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ingredientsCtrl.dispose();
    _fssaiCtrl.dispose();
    _fssaiFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final name = _nameCtrl.text.trim();
    final ingredients = _ingredientsCtrl.text.trim();

    if (name.isEmpty && ingredients.isEmpty) {
      setState(() => _nameError = 'Add a product name or ingredient list to continue');
      HapticFeedback.vibrate();
      return;
    }
    setState(() => _nameError = null);
    widget.onAnalyze(
      productName: name.isEmpty ? 'Unnamed product' : name,
      ingredientText: ingredients,
      fssai: _fssaiCtrl.text.trim(),
      manualCategory: _manualCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final noIngredients = _ingredientsCtrl.text.trim().isEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          const FoodStickerLayer(stickers: [
            StickerSpec(emoji: '🥭', alignment: Alignment(0.92, -0.9), rotationDeg: 10, phase: 0.2, size: 26),
            StickerSpec(emoji: '🌾', alignment: Alignment(-0.9, 0.9), rotationDeg: -10, phase: 0.6, size: 26),
          ]),
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Review what we found', style: willowDisplay(size: 22)),
                const SizedBox(height: 6),
                Text(
                  "This is Willow's OCR review step — confirm or edit the extracted text before "
                  "analysis, or type ingredients here if there's no printed list.",
                  style: willowBody(size: 12.5, color: WillowColors.muted),
                ),
                const SizedBox(height: 16),
                if (widget.image != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(widget.image!, height: 170, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(20)),
                          child: Text('Photo attached', style: willowBody(size: 9.5, color: Colors.white, weight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: WillowColors.line, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_outlined, color: WillowColors.muted, size: 24),
                        const SizedBox(height: 4),
                        Text('No photo attached', style: willowBody(size: 11, color: WillowColors.muted)),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),
                SectionLabel('PRODUCT NAME'),
                _field(_nameCtrl, hint: 'e.g. Masala Oats', errorText: _nameError, onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                }),
                const SizedBox(height: 14),
                SectionLabel('INGREDIENT LIST', hint: 'comma-separated, blank if no printed list'),
                _field(_ingredientsCtrl, hint: 'e.g. Refined Flour, Sugar, Palm Oil, Salt, MSG', maxLines: 4),
                const SizedBox(height: 14),
                SectionLabel('FSSAI NUMBER', hint: 'optional'),
                _field(_fssaiCtrl, hint: '14-digit number, if visible on the pack', focusNode: _fssaiFocus, keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: noIngredients
                      ? Container(
                          key: const ValueKey('fallback'),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: WillowColors.watchBg,
                            border: Border.all(color: const Color(0xFFEBCB8E)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.info_outline, size: 14, color: WillowColors.watchFg),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text('No ingredient list? Pick the closest category (optional).',
                                      style: willowBody(size: 11.5, weight: FontWeight.w600, color: WillowColors.watchFg)),
                                ),
                              ]),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _manualCategory,
                                isExpanded: true,
                                hint: Text('Let Willow guess from the product name', style: willowBody(size: 12)),
                                items: categoryProfiles.keys
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c, style: willowBody(size: 12))))
                                    .toList(),
                                onChanged: (v) => setState(() => _manualCategory = v),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          widget.onBack();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          side: const BorderSide(color: WillowColors.line),
                        ),
                        child: Text('Back', style: willowBody(size: 13, weight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WillowColors.ink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Analyze', style: willowBody(size: 13, weight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c, {
    required String hint,
    int maxLines = 1,
    void Function(String)? onChanged,
    String? errorText,
    FocusNode? focusNode,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      onChanged: onChanged,
      focusNode: focusNode,
      keyboardType: keyboardType,
      style: willowBody(size: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: willowBody(size: 12.5, color: WillowColors.muted),
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WillowColors.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: errorText != null ? WillowColors.red : WillowColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WillowColors.green, width: 1.6)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WillowColors.red)),
      ),
    );
  }
}
