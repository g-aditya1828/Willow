import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ingredient_scanner_service.dart';
import '../model/scan_model.dart';
import '../theme/app_theme.dart';
import 'results_screen.dart';

class ScanScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const ScanScreen({super.key, this.onBackToHome});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  final _scanner = IngredientScannerService();
  final _manualCtrl = TextEditingController();
  final _productNameCtrl = TextEditingController();

  File? _selectedImage;
  Uint8List? _imageBytes;
  bool _isScanning = false;
  bool _showManualEntry = false;
  String _statusText = '';
  ProductAnalysis? _detectedProduct;

  late AnimationController _scanAnimCtrl;
  late Animation<double> _scanLineAnim;

  @override
  void initState() {
    super.initState();
    _scanAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanAnimCtrl.dispose();
    _manualCtrl.dispose();
    _productNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 92,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      File? file;
      if (!kIsWeb) file = File(picked.path);

      setState(() {
        _imageBytes = bytes;
        _selectedImage = file;
        _isScanning = true;
        _detectedProduct = null;
        _statusText = 'Analyzing ingredient label...';
      });

      // Call backend scan-and-analyze API
      final analysis = await _scanner.scanAndAnalyze(picked);

      if (!mounted) return;
      setState(() => _isScanning = false);

      if (analysis != null) {
        // Backend returned real result!
        setState(() {
          _detectedProduct = analysis;
        });
      } else {
        _showError('No ingredients could be detected. Try a clearer photo or enter manually.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isScanning = false);
      _showError('Could not process image: $e');
    }
  }

  Future<void> _handleManualAnalyze() async {
    final text = _manualCtrl.text.trim();
    if (text.isEmpty) {
      _showError('Please enter at least one ingredient');
      return;
    }

    final pName = _productNameCtrl.text.trim().isNotEmpty
        ? _productNameCtrl.text.trim()
        : 'Food Product';

    final ingredients = text
        .split(RegExp(r'[,;\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    setState(() {
      _isScanning = true;
      _statusText = 'Analyzing ingredients against FSSAI database...';
    });

    final analysis = await _scanner.analyze(
      productName: pName,
      ingredients: ingredients,
    );

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _showManualEntry = false;
    });

    if (analysis != null) {
      setState(() {
        _detectedProduct = analysis;
      });
    } else {
      _showError('Could not analyze product. Check backend connection.');
    }
  }

  void _navigateToResults(ProductAnalysis analysis) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          analysis: analysis,
          imageFile: _selectedImage,
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.redDanger,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // ── Camera Feed Simulated Viewport ────────────────────────
          Positioned.fill(
            child: _imageBytes != null
                ? Image.memory(
                    _imageBytes!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: const Color(0xFF0F1A2E),
                  ),
          ),

          // ── Camera Shading Gradient Overlay (Figma #2:1950) ───────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.cameraOverlayGradient,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Camera Header (Figma #2:1957) ─────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close / Back button
                      GestureDetector(
                        onTap: widget.onBackToHome,
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        'Scan a product',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      // Gallery button
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Colors.white,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Instructions (Figma #2:1962)
                        Text(
                          'Scan the product',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Place the ingredient list inside the frame.\nWillow will take it from here.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: const Color(0xFFC8D8FF),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Viewfinder with Corner Brackets & Scan Line ────────
                        Center(
                          child: SizedBox(
                            width: 294,
                            height: 168,
                            child: Stack(
                              children: [
                                // Custom Corner Brackets Frame (Figma #2:1966)
                                CustomPaint(
                                  size: const Size(294, 168),
                                  painter: ViewfinderPainter(),
                                ),

                                // Animated Scanning Line
                                AnimatedBuilder(
                                  animation: _scanLineAnim,
                                  builder: (context, _) {
                                    return Positioned(
                                      top: _scanLineAnim.value * 160,
                                      left: 12,
                                      right: 12,
                                      child: Container(
                                        height: 2,
                                        decoration: const BoxDecoration(
                                          gradient: AppTheme.scanLineGradient,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.cyanAccent,
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                if (_isScanning)
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: AppTheme.cyanAccent,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _statusText,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
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
                        const SizedBox(height: 22),

                        // Capture / Flash Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Flash icon button (Figma #2:1971)
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFA855F7).withValues(alpha: 0.25),
                                    const Color(0xFF06B6D4).withValues(alpha: 0.25),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Icon(
                                Icons.flash_off_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Camera Shutter Button
                            GestureDetector(
                              onTap: _isScanning ? null : () => _pickImage(ImageSource.camera),
                              child: Container(
                                width: 70,
                                height: 70,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppTheme.primaryButtonGradient,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Gallery icon button
                            GestureDetector(
                              onTap: () => _pickImage(ImageSource.gallery),
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFA855F7).withValues(alpha: 0.25),
                                      const Color(0xFF06B6D4).withValues(alpha: 0.25),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.white,
                                  size: 21,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Detected Product Card (Figma #2:1973) ──────────────
                        // Only arrives from backend when actually scanned!
                        if (_detectedProduct != null) ...[
                          _buildDetectedProductCard(_detectedProduct!),
                          const SizedBox(height: 16),
                        ],

                        // Manual entry toggle (Figma #2:1983)
                        GestureDetector(
                          onTap: () => setState(() => _showManualEntry = !_showManualEntry),
                          child: Text(
                            _showManualEntry
                                ? 'Hide manual entry'
                                : "Can't scan? Enter barcode / text manually",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFC8D8FF),
                            ),
                          ),
                        ),

                        // Manual Entry Form
                        if (_showManualEntry) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Manual Ingredient Analysis',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _productNameCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'Product Name (e.g. Masala Oats)',
                                    fillColor: AppTheme.primaryPurpleSoft,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _manualCtrl,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'Paste ingredients list separated by commas...',
                                    fillColor: AppTheme.primaryPurpleSoft,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _handleManualAnalyze,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  child: Text(
                                    'Analyze Ingredients',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedProductCard(ProductAnalysis product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172E).withValues(alpha: 0.22),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Accent Line (Figma #12:33)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: AppTheme.detectedCardAccentGradient,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Product image wrap (Figma #12:34)
                      Container(
                        width: 58,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurpleSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE9D5FF), width: 1.5),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: AppTheme.primaryPurple,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Identification details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Eyebrow pill (Figma #12:35)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFEDE9FE), Color(0xFFCFFAFE)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'READY TO EXPLORE',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.category.isNotEmpty
                                  ? product.category
                                  : 'Scanned Food Product',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Button "See product rating" (Figma #2:1980)
                  GestureDetector(
                    onTap: () => _navigateToResults(product),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppTheme.seeRatingBtnGradient,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'See product rating',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Willow badge (Figma #12:37)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurpleSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF00C0E8),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Powered by Willow',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Score: ${product.displayScore}/100',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Viewfinder Custom Painter for Corner Brackets ──────────────
class ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA78BFA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    // Top-left corner
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-left corner
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
