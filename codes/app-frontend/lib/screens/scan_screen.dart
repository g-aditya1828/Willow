import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ingredient_scanner_service.dart';
import '../theme/app_theme.dart';
import 'results_screen.dart';

class ScanScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const ScanScreen({super.key, this.onBackToHome});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  final _scanner = IngredientScannerService();
  final _manualCtrl = TextEditingController();
  final _productNameCtrl = TextEditingController();

  File? _selectedImage;
  Uint8List? _imageBytes;
  bool _isScanning = false;
  bool _showManualEntry = false;
  String _statusText = '';
  String? _qualityWarning;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _manualCtrl.dispose();
    _productNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureOrUpload(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 92,
      );
      if (picked == null) return;

      // Read bytes for display (works on both web and native)
      final bytes = await picked.readAsBytes();

      // On native platforms, also keep a File reference for the scanner
      File? file;
      if (!kIsWeb) {
        file = File(picked.path);
      }

      setState(() {
        _imageBytes = bytes;
        _selectedImage = file;
        _isScanning = true;
        _qualityWarning = null;
        _statusText = 'Reading ingredient label...';
      });
      await _runScan(picked);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isScanning = false);
      _showError('Could not access camera/gallery: $e');
    }
  }

  Future<void> _runScan(XFile picked) async {
    setState(() => _statusText = 'Running AI analysis...');
    final analysis = await _scanner.scanAndAnalyze(picked);
    if (!mounted) return;
    setState(() => _isScanning = false);

    if (analysis != null) {
      _goToResults(analysis, _selectedImage);
    } else {
      setState(() {
        _qualityWarning =
            'Could not extract ingredients. Please retake with better '
            'lighting and ensure the full ingredient label is in frame.';
      });
    }
  }

  Future<void> _submitManualIngredients() async {
    final raw = _manualCtrl.text.trim();
    if (raw.isEmpty) {
      _showError('Please type at least one ingredient');
      return;
    }
    final productName = _productNameCtrl.text.trim().isEmpty
        ? 'Manually Entered Product'
        : _productNameCtrl.text.trim();

    final ingredients = raw
        .split(RegExp(r'[,;\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    setState(() {
      _isScanning = true;
      _statusText = 'Analyzing your ingredients...';
    });

    final analysis = await _scanner.analyze(
      productName: productName,
      ingredients: ingredients,
    );

    if (!mounted) return;
    setState(() => _isScanning = false);

    if (analysis != null) {
      _goToResults(analysis, null);
    } else {
      _showError('Analysis failed. Please check your connection and try again.');
    }
  }

  void _goToResults(dynamic analysis, File? file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(analysis: analysis, imageFile: file),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.highRiskRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryPink.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onBackToHome ??
                            () => Navigator.of(context).maybePop(),
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
                      const SizedBox(width: 12),
                      const Text(
                        'Scan Food Label',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showManualEntry = !_showManualEntry),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: _showManualEntry
                                ? AppTheme.primaryPink
                                : AppTheme.pillSurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Manual',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: _showManualEntry
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _showManualEntry
                      ? _buildManualEntryView()
                      : _buildCameraView(),
                ),
              ],
            ),
          ),
          if (_isScanning)
            Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryPink,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: _imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                  )
                : _selectedImage != null && !kIsWeb
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: AppTheme.pinkGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.primaryPink.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.document_scanner_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Point camera at ingredient label',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Works with any packaged food product',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 14),
          if (_qualityWarning != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppTheme.alertOrangeBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.watchOrange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.watchOrange, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _qualityWarning!,
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.textPrimary,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryPinkBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u{1F4F8} Capture Tips',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryPink,
                  ),
                ),
                SizedBox(height: 8),
                _TipRow(
                    icon: '\u{1F4A1}',
                    tip: 'Use natural light — avoid flash on shiny packaging'),
                _TipRow(
                    icon: '\u{1F3AF}',
                    tip: 'Keep the entire ingredient list in frame'),
                _TipRow(
                    icon: '\u{1F4CF}',
                    tip: 'Hold 15–25 cm from the label for best focus'),
                _TipRow(
                    icon: '\u{1F524}',
                    tip: 'English ingredient lists currently work best'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () => _captureOrUpload(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _captureOrUpload(ImageSource.camera),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.pinkGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPink.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Scan Now',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _showManualEntry = true),
            child: const Center(
              child: Text(
                "Can't scan? Type ingredients manually \u2192",
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppTheme.primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildManualEntryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u270D\uFE0F Manual Ingredient Entry',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  'Use this when OCR fails or the label is damaged.',
                  style: TextStyle(
                      fontSize: 12.5, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _productNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Product name (optional)',
              prefixIcon:
                  Icon(Icons.inventory_2_outlined, color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _manualCtrl,
            maxLines: 7,
            decoration: const InputDecoration(
              hintText:
                  'Paste or type ingredient list here...\n\nExample:\nSugar, Refined Wheat Flour, Palm Oil, INS 211, Tartrazine',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: Icon(Icons.list_alt_rounded, color: AppTheme.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Separate ingredients with commas or new lines',
            style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isScanning ? null : _submitManualIngredients,
            child: const Text('Analyze Ingredients'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => setState(() => _showManualEntry = false),
            child: const Text('Back to Camera Scan'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String icon;
  final String tip;

  const _TipRow({required this.icon, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.pillSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}