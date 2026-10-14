import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ingredient_scanner_service.dart';
import '../theme/app_theme.dart';
import 'results_screen.dart';

class ReviewScreen extends StatefulWidget {
  final File? imageFile;
  final String initialProductName;
  final List<String> extractedIngredients;
  final String? fssaiNumber;
  final int confidence;
  final String provider;
  final String rawOcrText;

  const ReviewScreen({
    super.key,
    this.imageFile,
    required this.initialProductName,
    required this.extractedIngredients,
    this.fssaiNumber,
    required this.confidence,
    required this.provider,
    required this.rawOcrText,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _scanner = IngredientScannerService();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ingredientsCtrl;
  late final TextEditingController _fssaiCtrl;

  String _selectedCategory = "Namkeen / Fried Snacks";
  bool _isAnalyzing = false;

  final List<String> _categories = [
    "Namkeen / Fried Snacks",
    "Bakery / Biscuits",
    "Sweets / Mithai",
    "Packaged Spices / Masala",
    "Beverages",
    "Instant Foods / Ready-to-Eat",
    "Dairy",
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialProductName);
    _ingredientsCtrl = TextEditingController(
      text: widget.extractedIngredients.join(", "),
    );
    _fssaiCtrl = TextEditingController(text: widget.fssaiNumber ?? "");

    // Guess category from title or text
    _autoDetectCategory();
  }

  void _autoDetectCategory() {
    final combined = "${widget.initialProductName} ${widget.rawOcrText}".toLowerCase();
    if (combined.contains("biscuit") || combined.contains("cookie") || combined.contains("rusk")) {
      _selectedCategory = "Bakery / Biscuits";
    } else if (combined.contains("sweet") || combined.contains("mithai") || combined.contains("ladoo")) {
      _selectedCategory = "Sweets / Mithai";
    } else if (combined.contains("masala") || combined.contains("spice") || combined.contains("turmeric")) {
      _selectedCategory = "Packaged Spices / Masala";
    } else if (combined.contains("drink") || combined.contains("juice") || combined.contains("cola")) {
      _selectedCategory = "Beverages";
    } else if (combined.contains("noodle") || combined.contains("maggi") || combined.contains("instant")) {
      _selectedCategory = "Instant Foods / Ready-to-Eat";
    } else if (combined.contains("milk") || combined.contains("curd") || combined.contains("paneer")) {
      _selectedCategory = "Dairy";
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ingredientsCtrl.dispose();
    _fssaiCtrl.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    final ingText = _ingredientsCtrl.text.trim();
    final ingredientsList = ingText.isNotEmpty
        ? ingText.split(RegExp(r'[,•\n]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : <String>[];

    setState(() {
      _isAnalyzing = true;
    });

    final result = await _scanner.analyze(
      productName: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : "Scanned Food",
      ingredients: ingredientsList,
      fssaiNumber: _fssaiCtrl.text.trim().isNotEmpty ? _fssaiCtrl.text.trim() : null,
      category: _selectedCategory,
    );

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
    });

    if (result != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            analysis: result,
            imageFile: widget.imageFile,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Analysis failed. Please check network connection."),
          backgroundColor: AppTheme.highRiskRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnbranded = widget.extractedIngredients.isEmpty;

    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      appBar: AppBar(
        title: const Text("Review & Verify"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top banner with Confidence & Provider info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUnbranded ? AppTheme.alertOrangeBg : AppTheme.cleanGreenBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUnbranded
                        ? AppTheme.watchOrange.withValues(alpha: 0.3)
                        : AppTheme.cleanGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUnbranded ? Icons.info_outline : Icons.check_circle_outline,
                      color: isUnbranded ? AppTheme.watchOrange : AppTheme.cleanGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isUnbranded
                            ? "No label detected. Using category-level risk fallback."
                            : "OCR extracted ${widget.extractedIngredients.length} ingredients (${widget.confidence}% confidence)",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isUnbranded ? AppTheme.watchOrange : AppTheme.cleanGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Product Name
              const Text(
                "Product Name",
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: "e.g. Haldiram's Bhujia or Loose Jalebi",
                  prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppTheme.textMuted),
                ),
              ),

              const SizedBox(height: 18),

              // Category Selector Dropdown
              const Text(
                "Food Category",
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryOrange),
                    items: _categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // FSSAI License Number (14 digits)
              const Row(
                children: [
                  Text(
                    "FSSAI License Number",
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "(Optional)",
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fssaiCtrl,
                keyboardType: TextInputType.number,
                maxLength: 14,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "14-digit FSSAI number (e.g. 10012345006789)",
                  prefixIcon: const Icon(Icons.verified_user_outlined, color: AppTheme.textMuted),
                  suffixIcon: _fssaiCtrl.text.length == 14
                      ? const Icon(Icons.check_circle, color: AppTheme.cleanGreen)
                      : null,
                ),
              ),

              const SizedBox(height: 18),

              // Ingredients Edit Box
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ingredients List",
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  Text(
                    "Comma-separated",
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted.withValues(alpha: 0.9)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ingredientsCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Enter or edit ingredients (e.g. Refined Wheat Flour, Palm Oil, TBHQ, Salt)",
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 28),

              // Submit / Analyze CTA Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _runAnalysis,
                  icon: _isAnalyzing
                      ? const SizedBox.shrink()
                      : const Icon(Icons.health_and_safety_outlined, color: Colors.white),
                  label: _isAnalyzing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text("Analyzing FSSAI Harm Rules...", style: TextStyle(color: Colors.white)),
                          ],
                        )
                      : const Text(
                          "Run Food Safety Analysis",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
