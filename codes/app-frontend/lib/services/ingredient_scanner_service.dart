import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class IngredientScanResult {
  final List<String> ingredients;
  final double confidence;
  final String? error;

  IngredientScanResult({required this.ingredients, required this.confidence, this.error});
}

class IngredientScannerService {
  // Change this per the table above depending on where you're running.
  static const String baseUrl = "http://127.0.0.1:5000";

  Future<IngredientScanResult> extractIngredients(File imageFile) async {
    final uri = Uri.parse("$baseUrl/extract");
    final request = http.MultipartRequest("POST", uri)
      ..fields["provider"] = "gemini"
      ..files.add(await http.MultipartFile.fromPath("image", imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return IngredientScanResult(ingredients: [], confidence: 0, error: body["error"]);
    }

    return IngredientScanResult(
      ingredients: List<String>.from(body["ingredients"]),
      confidence: (body["confidence"] as num).toDouble(),
    );
  }
}