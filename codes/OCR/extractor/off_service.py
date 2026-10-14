"""
Open Food Facts (OFF) integration service for Willow.
Provides product lookup, NutriScore/NOVA group enrichment, and nutriments.
Always fails gracefully — OFF is optional enrichment, never a hard dependency.
"""
import requests

OFF_SEARCH_URL = "https://world.openfoodfacts.org/cgi/search.pl"
OFF_PRODUCT_URL = "https://world.openfoodfacts.org/api/v3/product/{barcode}.json"
OFF_HEADERS = {"User-Agent": "WillowFoodScanner/1.0 (open-source-student-project)"}
TIMEOUT = 6
SEARCH_FIELDS = (
    "product_name,nutriscore_grade,nova_group,additives_tags,"
    "nutriments,ingredients_text,brands,categories,image_url"
)


def lookup_by_barcode(barcode: str) -> dict | None:
    """Fetch OFF product by barcode. Returns product dict or None."""
    try:
        url = OFF_PRODUCT_URL.format(barcode=barcode.strip())
        resp = requests.get(url, headers=OFF_HEADERS, timeout=TIMEOUT)
        if resp.status_code == 200:
            data = resp.json()
            status = data.get("status")
            if status == 1 or status == "success":
                return data.get("product") or {}
    except Exception:
        pass
    return None


def search_by_name(name: str) -> dict | None:
    """Search OFF by product name. Returns first result or None."""
    if not name or len(name.strip()) < 2:
        return None
    try:
        params = {
            "search_terms": name.strip(),
            "search_simple": 1,
            "action": "process",
            "json": 1,
            "page_size": 3,
            "fields": SEARCH_FIELDS,
        }
        resp = requests.get(OFF_SEARCH_URL, params=params, headers=OFF_HEADERS, timeout=TIMEOUT)
        if resp.status_code == 200:
            data = resp.json()
            products = data.get("products") or []
            if products:
                return products[0]
    except Exception:
        pass
    return None


def _safe_float(val) -> float | None:
    try:
        v = float(val)
        return round(v, 1)
    except (TypeError, ValueError):
        return None


def extract_off_data(off_product: dict) -> dict:
    """
    Extract the key health fields from an OFF product dict.
    Returns a clean dict ready to merge into the Willow API response.
    """
    if not off_product:
        return {}

    nutriments = off_product.get("nutriments") or {}

    # NutriScore: a (best) → e (worst). Map to numeric for blending.
    ns_grade = (off_product.get("nutriscore_grade") or "").lower().strip()
    ns_score_map = {"a": 90, "b": 72, "c": 50, "d": 28, "e": 10}
    ns_score = ns_score_map.get(ns_grade)  # None if not found

    # NOVA group: 1 (whole foods) → 4 (ultra-processed)
    nova_group = off_product.get("nova_group")
    try:
        nova_group = int(nova_group)
    except (TypeError, ValueError):
        nova_group = None

    # Additives — strip "en:" prefix, uppercase
    additives_raw = off_product.get("additives_tags") or []
    additives_clean = [a.replace("en:", "").upper() for a in additives_raw if a][:12]

    # AI insight sentence based on NutriScore + NOVA
    ai_insight = _build_ai_insight(ns_grade, nova_group, additives_clean)

    # Health benefit tag & best time to eat
    health_tags = _build_health_tags(ns_grade, nova_group)

    return {
        "off_product_name": (off_product.get("product_name") or "").strip(),
        "off_brands": (off_product.get("brands") or "").strip(),
        "off_image_url": (off_product.get("image_url") or "").strip() or None,
        "nutriscore_grade": ns_grade or None,
        "nutriscore_score": ns_score,
        "nova_group": nova_group,
        "additives": additives_clean,
        "ai_insight": ai_insight,
        "health_tags": health_tags,
        "nutrients": {
            "energy_kcal": _safe_float(
                nutriments.get("energy-kcal_100g") or nutriments.get("energy_100g")
            ),
            "fat_g": _safe_float(nutriments.get("fat_100g")),
            "saturated_fat_g": _safe_float(nutriments.get("saturated-fat_100g")),
            "carbohydrates_g": _safe_float(nutriments.get("carbohydrates_100g")),
            "sugars_g": _safe_float(nutriments.get("sugars_100g")),
            "fiber_g": _safe_float(nutriments.get("fiber_100g")),
            "proteins_g": _safe_float(nutriments.get("proteins_100g")),
            "salt_g": _safe_float(nutriments.get("salt_100g")),
        },
        "ingredients_text": (off_product.get("ingredients_text") or "")[:600].strip(),
    }


def _build_ai_insight(ns_grade: str, nova_group: int | None, additives: list[str]) -> str:
    """Generate a short AI insight sentence from OFF data."""
    parts = []
    if ns_grade in ("a", "b"):
        parts.append("Great nutritional profile — well-balanced macros.")
    elif ns_grade in ("d", "e"):
        parts.append("Poor nutritional profile — high in sugar, fat, or salt.")
    elif ns_grade == "c":
        parts.append("Moderate nutritional profile — consume in moderation.")

    if nova_group == 1:
        parts.append("Minimally processed whole food.")
    elif nova_group == 2:
        parts.append("Lightly processed — largely safe.")
    elif nova_group == 3:
        parts.append("Processed food — check additives carefully.")
    elif nova_group == 4:
        parts.append("Ultra-processed — linked to long-term health risks.")

    if len(additives) > 4:
        parts.append(f"Contains {len(additives)} additives including {', '.join(additives[:2])}.")

    return " ".join(parts) if parts else "Cross-referenced with Open Food Facts global database."


def _build_health_tags(ns_grade: str, nova_group: int | None) -> dict:
    """Return health benefit and best-time-to-eat tags."""
    benefit = "Check Labels"
    time = "Any Time"

    if ns_grade in ("a", "b"):
        benefit = "Boosts Immunity"
        time = "Morning"
    elif ns_grade == "c":
        benefit = "Moderate Choice"
        time = "Afternoon"
    elif ns_grade in ("d", "e"):
        benefit = "Limit Intake"
        time = "Rarely"

    if nova_group == 1:
        benefit = "Natural & Healthy"
        time = "Any Time"
    elif nova_group == 4 and ns_grade not in ("d", "e"):
        benefit = "Ultra-Processed"
        time = "Limit"

    return {"health_benefit": benefit, "best_time_to_eat": time}


def compute_blended_score(willow_score: int, off_data: dict) -> int:
    """
    Blend Willow FSSAI score (0-100) with OFF NutriScore + NOVA penalty.
    Higher = healthier/safer. Returns integer 5-100.
    """
    if not off_data:
        return willow_score

    ns_score = off_data.get("nutriscore_score")     # 10-90 or None
    nova_group = off_data.get("nova_group")          # 1-4 or None

    # Willow gets 60% weight; NS gets 30%; NOVA gets 10%
    total_weight = 0.6
    weighted_sum = willow_score * 0.6

    if ns_score is not None:
        weighted_sum += ns_score * 0.3
        total_weight += 0.3

    if nova_group is not None:
        nova_pts = {1: 90, 2: 65, 3: 40, 4: 15}.get(int(nova_group), 50)
        weighted_sum += nova_pts * 0.1
        total_weight += 0.1

    blended = weighted_sum / total_weight if total_weight > 0 else willow_score
    return max(5, min(100, round(blended)))
