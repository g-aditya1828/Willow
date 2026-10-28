/// Models for Willow Food Safety Scanner — includes Open Food Facts enrichment fields.
library scan_model;

class FlaggedIngredient {
  final String canonical;
  final String riskLevel; // 'high' or 'watch'
  final String healthEffects;
  final String? fssaiRef;
  final String rawToken;

  FlaggedIngredient({
    required this.canonical,
    required this.riskLevel,
    required this.healthEffects,
    this.fssaiRef,
    required this.rawToken,
  });

  factory FlaggedIngredient.fromJson(Map<String, dynamic> json) {
    return FlaggedIngredient(
      canonical: json['canonical'] ?? '',
      riskLevel: json['risk_level'] ?? 'watch',
      healthEffects: json['health_effects'] ?? '',
      fssaiRef: json['fssai_ref'],
      rawToken: json['raw_token'] ?? json['canonical'] ?? '',
    );
  }
}

class CleanIngredient {
  final String canonical;
  final String healthEffects;
  final String rawToken;

  CleanIngredient({
    required this.canonical,
    required this.healthEffects,
    required this.rawToken,
  });

  factory CleanIngredient.fromJson(Map<String, dynamic> json) {
    return CleanIngredient(
      canonical: json['canonical'] ?? '',
      healthEffects: json['health_effects'] ?? '',
      rawToken: json['raw_token'] ?? json['canonical'] ?? '',
    );
  }
}

class AlternativeSwap {
  final String name;
  final int score;
  final String price;
  final String? note;

  AlternativeSwap({
    required this.name,
    required this.score,
    required this.price,
    this.note,
  });

  factory AlternativeSwap.fromJson(Map<String, dynamic> json) {
    return AlternativeSwap(
      name: json['name'] ?? '',
      score: json['score'] is int ? json['score'] : int.tryParse(json['score'].toString()) ?? 75,
      price: json['price'] ?? '',
      note: json['note'],
    );
  }
}

/// Nutriment data from Open Food Facts (per 100g)
class OffNutrients {
  final double? energyKcal;
  final double? fatG;
  final double? saturatedFatG;
  final double? carbohydratesG;
  final double? sugarsG;
  final double? fiberG;
  final double? proteinsG;
  final double? saltG;

  OffNutrients({
    this.energyKcal,
    this.fatG,
    this.saturatedFatG,
    this.carbohydratesG,
    this.sugarsG,
    this.fiberG,
    this.proteinsG,
    this.saltG,
  });

  factory OffNutrients.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      return double.tryParse(v.toString());
    }

    return OffNutrients(
      energyKcal: parseDouble(json['energy_kcal']),
      fatG: parseDouble(json['fat_g']),
      saturatedFatG: parseDouble(json['saturated_fat_g']),
      carbohydratesG: parseDouble(json['carbohydrates_g']),
      sugarsG: parseDouble(json['sugars_g']),
      fiberG: parseDouble(json['fiber_g']),
      proteinsG: parseDouble(json['proteins_g']),
      saltG: parseDouble(json['salt_g']),
    );
  }
}

/// Open Food Facts enrichment data attached to a ProductAnalysis
class OffData {
  final String? offProductName;
  final String? offBrands;
  final String? offImageUrl;
  final String? nutriscoreGrade; // 'a' to 'e'
  final int? nutriscoreScore;    // 10-90
  final int? novaGroup;          // 1-4
  final List<String> additives;
  final String? aiInsight;
  final String? healthBenefit;
  final String? bestTimeToEat;
  final OffNutrients? nutrients;
  final String? ingredientsText;

  OffData({
    this.offProductName,
    this.offBrands,
    this.offImageUrl,
    this.nutriscoreGrade,
    this.nutriscoreScore,
    this.novaGroup,
    required this.additives,
    this.aiInsight,
    this.healthBenefit,
    this.bestTimeToEat,
    this.nutrients,
    this.ingredientsText,
  });

  factory OffData.fromJson(Map<String, dynamic> json) {
    final tags = json['health_tags'] as Map<String, dynamic>? ?? {};
    final nutrJson = json['nutrients'] as Map<String, dynamic>?;

    return OffData(
      offProductName: json['off_product_name'],
      offBrands: json['off_brands'],
      offImageUrl: json['off_image_url'],
      nutriscoreGrade: json['nutriscore_grade'],
      nutriscoreScore: json['nutriscore_score'] is int ? json['nutriscore_score'] : null,
      novaGroup: json['nova_group'] is int ? json['nova_group'] : null,
      additives: List<String>.from(json['additives'] ?? []),
      aiInsight: json['ai_insight'],
      healthBenefit: tags['health_benefit'],
      bestTimeToEat: tags['best_time_to_eat'],
      nutrients: nutrJson != null ? OffNutrients.fromJson(nutrJson) : null,
      ingredientsText: json['ingredients_text'],
    );
  }
}

class ProductAnalysis {
  final String productName;
  final String category;
  final int riskScore;
  final String scoreLabel;
  final int confidence;
  final bool isFallback;
  final String? fallbackNote;
  final String? fssaiNumber;
  final List<FlaggedIngredient> flagged;
  final List<CleanIngredient> clean;
  final List<String> unknown;
  final List<AlternativeSwap> alternatives;
  final int? scanId;
  final bool isFavorite;

  // Open Food Facts enrichment
  final OffData? offData;
  final int? blendedScore;

  ProductAnalysis({
    required this.productName,
    required this.category,
    required this.riskScore,
    required this.scoreLabel,
    required this.confidence,
    required this.isFallback,
    this.fallbackNote,
    this.fssaiNumber,
    required this.flagged,
    required this.clean,
    required this.unknown,
    required this.alternatives,
    this.scanId,
    this.isFavorite = false,
    this.offData,
    this.blendedScore,
  });

  /// The best available health score (blended if OFF data present, else local)
  int get displayScore => blendedScore ?? riskScore;

  factory ProductAnalysis.fromJson(Map<String, dynamic> json) {
    final flaggedList = (json['flagged'] as List? ?? [])
        .map((f) => FlaggedIngredient.fromJson(f as Map<String, dynamic>))
        .toList();

    final cleanList = (json['clean'] as List? ?? [])
        .map((c) => CleanIngredient.fromJson(c as Map<String, dynamic>))
        .toList();

    final altList = (json['alternatives'] as List? ?? [])
        .map((a) => AlternativeSwap.fromJson(a as Map<String, dynamic>))
        .toList();

    final unknownList = (json['unknown'] as List? ?? [])
        .map((u) => u.toString())
        .toList();

    final offJson = json['off_data'] as Map<String, dynamic>?;

    return ProductAnalysis(
      productName: json['product_name'] ?? 'Packaged Food',
      category: json['category'] ?? 'Namkeen / Fried Snacks',
      riskScore: json['risk_score'] is int ? json['risk_score'] : int.tryParse(json['risk_score'].toString()) ?? 50,
      scoreLabel: json['score_label'] ?? 'Moderate',
      confidence: json['confidence'] is int ? json['confidence'] : int.tryParse(json['confidence'].toString()) ?? 50,
      isFallback: json['is_fallback'] == true || json['is_fallback'] == 1,
      fallbackNote: json['fallback_note'],
      fssaiNumber: json['fssai_number'],
      flagged: flaggedList,
      clean: cleanList,
      unknown: unknownList,
      alternatives: altList,
      scanId: json['scan_id'] is int ? json['scan_id'] : int.tryParse(json['scan_id']?.toString() ?? ''),
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      offData: offJson != null ? OffData.fromJson(offJson) : null,
      blendedScore: json['blended_score'] is int ? json['blended_score'] : null,
    );
  }
}

class ScanHistoryItem {
  final int id;
  final String productName;
  final String category;
  final int riskScore;
  final int confidence;
  final int flaggedCount;
  final String? fssaiNumber;
  final bool isFavorite;
  final String createdAt;
  final bool isFallback;
  final String? fallbackNote;
  final List<FlaggedIngredient> flagged;
  final List<CleanIngredient> clean;
  final List<String> unknown;

  ScanHistoryItem({
    required this.id,
    required this.productName,
    required this.category,
    required this.riskScore,
    required this.confidence,
    required this.flaggedCount,
    this.fssaiNumber,
    required this.isFavorite,
    required this.createdAt,
    this.isFallback = false,
    this.fallbackNote,
    this.flagged = const [],
    this.clean = const [],
    this.unknown = const [],
  });

  String get timeAgo {
    if (createdAt.isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes <= 0 ? 1 : diff.inMinutes}m ago';
      }
      if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      }
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawFlagged = json['flagged'] as List? ?? [];
    final flaggedList = rawFlagged
        .map((f) => f is Map<String, dynamic>
            ? FlaggedIngredient.fromJson(f)
            : FlaggedIngredient(
                canonical: f.toString(),
                riskLevel: 'watch',
                healthEffects: '',
                rawToken: f.toString(),
              ))
        .toList();

    final rawClean = json['clean'] as List? ?? [];
    final cleanList = rawClean
        .map((c) => c is Map<String, dynamic>
            ? CleanIngredient.fromJson(c)
            : CleanIngredient(
                canonical: c.toString(),
                healthEffects: '',
                rawToken: c.toString(),
              ))
        .toList();

    final rawUnknown = json['unknown'] as List? ?? [];
    final unknownList = rawUnknown.map((u) => u.toString()).toList();

    return ScanHistoryItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      productName: json['product_name'] ?? 'Product',
      category: json['category'] ?? 'General Food',
      riskScore: json['risk_score'] is int ? json['risk_score'] : 50,
      confidence: json['confidence'] is int ? json['confidence'] : 50,
      flaggedCount: json['flagged_count'] is int ? json['flagged_count'] : flaggedList.length,
      fssaiNumber: json['fssai_number'],
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      createdAt: json['created_at'] ?? '',
      isFallback: json['is_fallback'] == true || json['is_fallback'] == 1,
      fallbackNote: json['fallback_note'],
      flagged: flaggedList,
      clean: cleanList,
      unknown: unknownList,
    );
  }
}
