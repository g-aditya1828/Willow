import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ingredient_scanner_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _picker = ImagePicker();
  final _scanner = IngredientScannerService();
  bool _loading = false;
  List<String>? _ingredients;
  String? _error;

  Future<void> _captureAndScan() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    setState(() {
      _loading = true;
      _error = null;
      _ingredients = null;
    });

    final result = await _scanner.extractIngredients(File(picked.path));

    setState(() {
      _loading = false;
      _error = result.error;
      _ingredients = result.ingredients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Ingredients")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _loading ? null : _captureAndScan,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture Product Photo"),
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null) Text("Error: $_error", style: const TextStyle(color: Colors.red)),
            if (_ingredients != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _ingredients!.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: const Icon(Icons.circle, size: 8),
                    title: Text(_ingredients![i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}