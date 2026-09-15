/// Data layer — mirrors D1 Ingredients & Aliases, D2 Category Configuration,
/// D3 Generic Risk Profiles, D4 Alternatives Data from the Level 1/2 DFDs.

enum Severity { clean, watch, high }

class SeverityInfo {
  final String label;
  final int weight;
  const SeverityInfo(this.label, this.weight);
}

const Map<Severity, SeverityInfo> severityInfo = {
  Severity.clean: SeverityInfo('Clean', 0),
  Severity.watch: SeverityInfo('Watch', 9),
  Severity.high: SeverityInfo('High risk', 20),
};

class IngredientEntry {
  final String canonical;
  final List<String> aliases;
  final Severity severity;
  final String effect;
  const IngredientEntry(this.canonical, this.aliases, this.severity, this.effect);
}

final List<IngredientEntry> ingredientDb = [
  IngredientEntry('Monosodium Glutamate', ['msg', 'ajinomoto', 'e621', 'monosodium glutamate'], Severity.watch,
      'Flavor enhancer linked to headaches and flushing in sensitive individuals.'),
  IngredientEntry('Partially Hydrogenated Oil',
      ['partially hydrogenated oil', 'vanaspati', 'hydrogenated vegetable oil', 'trans fat'], Severity.high,
      'Industrial trans fat — raises LDL cholesterol and cardiovascular risk.'),
  IngredientEntry('Palm Oil', ['palm oil', 'palmolein'], Severity.watch,
      'High in saturated fat; frequent use is linked to poorer cardiometabolic outcomes.'),
  IngredientEntry('High Fructose Corn Syrup', ['high fructose corn syrup', 'hfcs', 'corn syrup'], Severity.high,
      'Concentrated added sugar linked to weight gain and metabolic strain.'),
  IngredientEntry('Refined Sugar', ['sugar', 'refined sugar', 'sucrose'], Severity.watch,
      'Excess added sugar contributes to weight gain and dental issues.'),
  IngredientEntry('Tartrazine (E102)', ['tartrazine', 'e102', 'yellow 5'], Severity.high,
      'Synthetic dye linked to hyperactivity in children in some studies.'),
  IngredientEntry('Sunset Yellow (E110)', ['sunset yellow', 'e110', 'yellow 6'], Severity.high,
      'Synthetic dye associated with allergic reactions in sensitive people.'),
  IngredientEntry('Allura Red (E129)', ['allura red', 'e129', 'red 40'], Severity.high,
      'Synthetic dye under review for links to hyperactivity in children.'),
  IngredientEntry('Sodium Benzoate (E211)', ['sodium benzoate', 'e211'], Severity.watch,
      'Preservative that can form benzene when combined with vitamin C.'),
  IngredientEntry('Potassium Sorbate (E202)', ['potassium sorbate', 'e202'], Severity.clean,
      'Widely used preservative, generally recognized as low-risk.'),
  IngredientEntry('BHA (E320)', ['bha', 'e320', 'butylated hydroxyanisole'], Severity.high,
      'Synthetic antioxidant classified as a possible carcinogen by some agencies.'),
  IngredientEntry('BHT (E321)', ['bht', 'e321', 'butylated hydroxytoluene'], Severity.watch,
      'Synthetic antioxidant preservative; long-term intake is debated.'),
  IngredientEntry('Aspartame (E951)', ['aspartame', 'e951'], Severity.watch,
      'Artificial sweetener; considered unsafe for those with PKU.'),
  IngredientEntry('Maida (Refined Flour)',
      ['maida', 'refined flour', 'refined wheat flour', 'all purpose flour'], Severity.watch,
      'Stripped of bran and germ — low fiber, spikes blood sugar quickly.'),
  IngredientEntry('Excess Sodium', ['salt', 'excess sodium', 'sodium chloride'], Severity.watch,
      'High sodium intake is linked to elevated blood pressure.'),
  IngredientEntry('Soy Lecithin (E322)', ['soy lecithin', 'e322', 'lecithin'], Severity.clean,
      'Common emulsifier derived from soy; low risk for most people.'),
  IngredientEntry('Citric Acid', ['citric acid', 'e330'], Severity.clean,
      'Natural acidity regulator, low risk.'),
  IngredientEntry('Ghee', ['ghee', 'clarified butter'], Severity.clean,
      'Traditional clarified butter — fine in moderation.'),
  IngredientEntry('Turmeric', ['turmeric', 'haldi'], Severity.clean,
      'Traditional spice with antioxidant properties.'),
  IngredientEntry('Whole Wheat', ['whole wheat', 'atta', 'whole grain'], Severity.clean,
      'Retains bran and germ — a good fiber source.'),
  IngredientEntry('Oats', ['oats', 'rolled oats'], Severity.clean,
      'High-fiber whole grain, generally beneficial.'),
  IngredientEntry('Jaggery', ['jaggery', 'gur'], Severity.clean,
      'Unrefined traditional sweetener; still a sugar, but minimally processed.'),
  IngredientEntry('Artificial Flavoring',
      ['artificial flavor', 'artificial flavour', 'synthetic flavour', 'nature-identical flavour'], Severity.watch,
      'Lab-replicated flavor compounds; not inherently harmful but non-natural.'),
  IngredientEntry('Hydrolyzed Vegetable Protein', ['hydrolyzed vegetable protein', 'hvp'], Severity.watch,
      'Processing can generate small amounts of MSG-like glutamates.'),
  IngredientEntry('Acesulfame K', ['acesulfame k', 'e950', 'acesulfame potassium'], Severity.watch,
      'Artificial sweetener; considered safe in moderation by most regulators.'),
  IngredientEntry('Caramel Color (E150d)', ['caramel color', 'caramel colour', 'e150d', 'e150'], Severity.watch,
      'Some manufacturing processes generate a compound flagged as a possible carcinogen.'),
];

class CategoryProfile {
  final List<String> keywords;
  final int genericRisk;
  final String note;
  const CategoryProfile(this.keywords, this.genericRisk, this.note);
}

final Map<String, CategoryProfile> categoryProfiles = {
  'Namkeen / Fried Snacks': CategoryProfile(
      ['namkeen', 'bhujia', 'chips', 'mixture', 'sev', 'chivda', 'fryums'], 42,
      'This category is typically fried in reused oil and high in sodium.'),
  'Bakery / Biscuits': CategoryProfile(
      ['biscuit', 'cookie', 'bread', 'bakery', 'rusk', 'cracker'], 50,
      'Usually made with refined flour and added sugar or hydrogenated fat.'),
  'Sweets / Mithai': CategoryProfile(
      ['mithai', 'sweet', 'barfi', 'ladoo', 'halwa', 'peda'], 38,
      'Traditional sweets are often high in sugar, ghee, or khoya.'),
  'Packaged Spices / Masala': CategoryProfile(
      ['masala', 'spice', 'powder', 'seasoning'], 68,
      'Generally lower intrinsic risk, but loose spice mixes carry adulteration risk.'),
  'Beverages': CategoryProfile(
      ['drink', 'beverage', 'juice', 'cola', 'soda', 'squash'], 45,
      'Packaged beverages are frequently high in added sugar.'),
  'Dairy': CategoryProfile(
      ['milk', 'curd', 'paneer', 'cheese', 'dairy', 'yogurt'], 64,
      'Moderate risk category — watch for added sugar in flavored variants.'),
};

class Alternative {
  final String name;
  final int score;
  final String price;
  const Alternative(this.name, this.score, this.price);
}

final Map<String, List<Alternative>> alternativesDb = {
  'Namkeen / Fried Snacks': [
    Alternative('Roasted Makhana', 81, '₹80 / 100g'),
    Alternative('Baked Chana Chaat Mix', 74, '₹90 / 100g'),
  ],
  'Bakery / Biscuits': [
    Alternative('Multigrain Digestive (No Trans Fat)', 70, '₹60 / pack'),
    Alternative('Ragi Cookies', 76, '₹85 / pack'),
  ],
  'Sweets / Mithai': [
    Alternative('Dry Fruit Ladoo (No Added Sugar)', 72, '₹350 / kg'),
    Alternative('Date & Nut Barfi', 69, '₹320 / kg'),
  ],
  'Packaged Spices / Masala': [
    Alternative('FSSAI-Certified Single-Origin Masala', 88, '₹120 / 100g'),
  ],
  'Beverages': [
    Alternative('Fresh Nimbu Paani (unsweetened)', 90, '₹40 / bottle'),
    Alternative('Buttermilk (Chaas)', 85, '₹35 / bottle'),
  ],
  'Dairy': [
    Alternative('Plain Unsweetened Curd', 92, '₹45 / 400g'),
  ],
  'Uncategorized': [
    Alternative('A cleaner product in the same aisle', 75, 'Comparable price band'),
  ],
};

class SampleProduct {
  final String name;
  final String category;
  final bool hasLabel;
  final String ingredientText;
  final String fssai;
  const SampleProduct(this.name, this.category, this.hasLabel, this.ingredientText, this.fssai);
}

const List<SampleProduct> sampleProducts = [
  SampleProduct('Masala Oats', 'Beverages', true,
      'Oats, Mixed Vegetables, Salt, Turmeric, Spices, Citric Acid, Artificial Flavoring', '10012345006789'),
  SampleProduct('Classic Salted Chips', 'Namkeen / Fried Snacks', true,
      'Potatoes, Palm Oil, Salt, MSG, Acesulfame K, Sodium Benzoate (E211)', '10098765004321'),
  SampleProduct('Cream Biscuits', 'Bakery / Biscuits', true,
      'Refined Flour (Maida), Sugar, Partially Hydrogenated Oil, Tartrazine (E102), BHA (E320)', ''),
  SampleProduct('Loose Namkeen (no printed label)', 'Namkeen / Fried Snacks', false, '', ''),
];

/// ---- Pipeline logic (mirrors Level 2 processes 2.4–2.9) ----

class MatchedIngredient {
  final String raw;
  final IngredientEntry entry;
  MatchedIngredient(this.raw, this.entry);
}

class AnalysisResult {
  final bool isFallback;
  final String category;
  final int riskScore;
  final int confidence;
  final List<MatchedIngredient> flagged;
  final List<MatchedIngredient> clean;
  final List<String> unknown;
  final String? fssai;
  final String? fallbackNote;

  AnalysisResult({
    required this.isFallback,
    required this.category,
    required this.riskScore,
    required this.confidence,
    required this.flagged,
    required this.clean,
    required this.unknown,
    this.fssai,
    this.fallbackNote,
  });
}

List<String> parseIngredientText(String text) {
  return text
      .split(RegExp(r'[,•\n]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

String? detectFssai(String text) {
  final match = RegExp(r'\b\d{14}\b').firstMatch(text);
  return match?.group(0);
}

String classifyCategory(String productName, String text, {String? manualCategory}) {
  if (manualCategory != null && manualCategory.isNotEmpty) return manualCategory;
  final haystack = '$productName $text'.toLowerCase();
  for (final entry in categoryProfiles.entries) {
    if (entry.value.keywords.any((k) => haystack.contains(k))) return entry.key;
  }
  return 'Uncategorized';
}

AnalysisResult runAnalysis({
  required String productName,
  required String ingredientText,
  required String fssaiInput,
  String? manualCategory,
}) {
  final tokens = parseIngredientText(ingredientText);
  final fssai = detectFssai(ingredientText) ?? (fssaiInput.isNotEmpty ? fssaiInput : null);
  final category = classifyCategory(productName, ingredientText, manualCategory: manualCategory);

  if (tokens.isEmpty) {
    final profile = categoryProfiles[category];
    return AnalysisResult(
      isFallback: true,
      category: category,
      riskScore: profile?.genericRisk ?? 50,
      confidence: 30,
      flagged: [],
      clean: [],
      unknown: [],
      fssai: fssai,
      fallbackNote: profile?.note ?? 'No specific data available for this category yet.',
    );
  }

  final matched = <MatchedIngredient>[];
  final unknown = <String>[];
  for (final token in tokens) {
    final lower = token.toLowerCase();
    IngredientEntry? hit;
    for (final entry in ingredientDb) {
      if (entry.aliases.any((a) => lower.contains(a))) {
        hit = entry;
        break;
      }
    }
    if (hit != null) {
      matched.add(MatchedIngredient(token, hit));
    } else {
      unknown.add(token);
    }
  }

  final flagged = matched.where((m) => m.entry.severity != Severity.clean).toList();
  final clean = matched.where((m) => m.entry.severity == Severity.clean).toList();
  final weight = flagged.fold<int>(0, (sum, f) => sum + severityInfo[f.entry.severity]!.weight);
  final cleanBonus = (clean.length * 2).clamp(0, 10);
  final riskScore = (82 - weight + cleanBonus).clamp(0, 100);

  final totalTokens = matched.length + unknown.length;
  final recognizedRatio = totalTokens > 0 ? matched.length / totalTokens : 0.0;
  int confidence = totalTokens == 0 ? 30 : (40 + recognizedRatio * 55).round();
  confidence = confidence.clamp(0, 97);

  return AnalysisResult(
    isFallback: false,
    category: category,
    riskScore: riskScore,
    confidence: confidence,
    flagged: flagged,
    clean: clean,
    unknown: unknown,
    fssai: fssai,
  );
}

class ScoreLabel {
  final String label;
  final Severity? tone; // reused just for color mapping convenience
  const ScoreLabel(this.label, this.tone);
}

String scoreLabelFor(int score) {
  if (score >= 75) return 'Excellent';
  if (score >= 50) return 'Good';
  if (score >= 25) return 'Mediocre';
  return 'High risk';
}
