import 'dart:io';
import 'package:flutter/material.dart';
import 'data/ingredient_data.dart';
import 'widgets/common.dart';
import 'screens/home_screen.dart';
import 'screens/review_screen.dart';
import 'screens/analyzing_screen.dart';
import 'screens/results_screen.dart';

void main() {
  runApp(const WillowMaterialApp());
}

class WillowMaterialApp extends StatelessWidget {
  const WillowMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Willow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: WillowColors.cream,
        colorScheme: ColorScheme.fromSeed(seedColor: WillowColors.green),
        useMaterial3: true,
      ),
      home: const WillowHome(),
    );
  }
}

enum _Step { capture, review, analyzing, results }

class WillowHome extends StatefulWidget {
  const WillowHome({super.key});

  @override
  State<WillowHome> createState() => _WillowHomeState();
}

class _WillowHomeState extends State<WillowHome> {
  _Step _step = _Step.capture;

  File? _image;
  String _productName = '';
  String _ingredientText = '';
  String _fssaiInput = '';
  AnalysisResult? _result;

  void _reset() {
    setState(() {
      _step = _Step.capture;
      _image = null;
      _productName = '';
      _ingredientText = '';
      _fssaiInput = '';
      _result = null;
    });
  }

  void _goToReviewFromPhoto({File? image, required String productName}) {
    setState(() {
      _image = image;
      _productName = productName;
      _ingredientText = '';
      _step = _Step.review;
    });
  }

  void _goToReviewManual() {
    setState(() {
      _image = null;
      _productName = '';
      _ingredientText = '';
      _step = _Step.review;
    });
  }

  void _goToReviewFromSample(SampleProduct sample) {
    setState(() {
      _image = null;
      _productName = sample.name;
      _ingredientText = sample.ingredientText;
      _fssaiInput = sample.fssai;
      _step = _Step.review;
    });
  }

  Future<void> _analyze({
    required String productName,
    required String ingredientText,
    required String fssai,
    String? manualCategory,
  }) async {
    setState(() {
      _productName = productName;
      _ingredientText = ingredientText;
      _fssaiInput = fssai;
      _step = _Step.analyzing;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    final result = runAnalysis(
      productName: productName,
      ingredientText: ingredientText,
      fssaiInput: fssai,
      manualCategory: manualCategory,
    );

    if (!mounted) return;
    setState(() {
      _result = result;
      _step = _Step.results;
    });
  }

  int get _stepIndex => switch (_step) {
        _Step.capture => 0,
        _Step.review => 1,
        _Step.analyzing => 2,
        _Step.results => 3,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WillowColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: WillowColors.ink, width: 2),
              ),
              alignment: Alignment.center,
              child: Text('W', style: willowDisplay(size: 15, weight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            Text('willow', style: willowDisplay(size: 18)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 14, color: WillowColors.green),
                  const SizedBox(width: 4),
                  Text('No ads', style: willowBody(size: 10.5, color: WillowColors.muted)),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: WillowColors.line, height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_step != _Step.capture)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: ProgressRail(
                  stepIndex: _stepIndex,
                  onStepTap: (i) {
                    // Only completed steps are tappable (enforced in the
                    // widget itself); jump back without losing entered data.
                    setState(() {
                      _step = switch (i) {
                        0 => _Step.capture,
                        1 => _Step.review,
                        _ => _step,
                      };
                    });
                  },
                ),
              ),
            Expanded(child: _buildStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.capture:
        return HomeScreen(
          onPhotoChosen: _goToReviewFromPhoto,
          onManualEntry: _goToReviewManual,
          onSampleChosen: _goToReviewFromSample,
        );
      case _Step.review:
        return ReviewScreen(
          image: _image,
          initialProductName: _productName,
          initialIngredientText: _ingredientText,
          initialFssai: _fssaiInput,
          onBack: () => setState(() => _step = _Step.capture),
          onAnalyze: (
              {required productName,
              required ingredientText,
              required fssai,
              manualCategory}) =>
              _analyze(
            productName: productName,
            ingredientText: ingredientText,
            fssai: fssai,
            manualCategory: manualCategory,
          ),
        );
      case _Step.analyzing:
        return const AnalyzingScreen();
      case _Step.results:
        return ResultsScreen(
          result: _result!,
          productName: _productName.isEmpty ? 'Your product' : _productName,
          onReset: _reset,
        );
    }
  }
}
