"""
Deterministic Classification & Risk Analysis Engine for Willow.
Per handover doc Section 5.4:
- Deterministic lookup against curated database (not hallucinated LLM claims)
- "Category is data, not code" (driven by database tables)
- Smart local-food fallback for unbranded Indian foods with no ingredient list
- Price-comparable healthier alternatives matching
"""

import json
from database import get_db_connection


def classify_product(
    product_name: str,
    raw_ingredients: list[str],
    fssai_number: str | None = None,
    user_id: int | None = None,
    image_path: str | None = None,
    manual_category: str | None = None,
) -> dict:
    conn = get_db_connection()
    cursor = conn.cursor()

    # 1. Load categories and keywords from database
    cursor.execute("SELECT id, name, generic_risk, note, keywords FROM categories")
    categories_rows = cursor.fetchall()

    # 2. Determine product category
    category_name = manual_category or _detect_category(product_name, raw_ingredients, categories_rows)

    # 3. Handle unbranded food fallback if ingredient list is empty
    if not raw_ingredients:
        category_info = next((c for c in categories_rows if c["name"] == category_name), None)
        generic_risk = category_info["generic_risk"] if category_info else 45
        fallback_note = (
            category_info["note"]
            if category_info
            else "Estimated category-level risk profile. No exact ingredient list detected on packaging."
        )

        # Retrieve alternatives for this category
        alternatives = _get_alternatives(cursor, category_name, generic_risk)

        scan_result = {
            "product_name": product_name or "Unlabeled Regional Food",
            "category": category_name,
            "risk_score": generic_risk,
            "score_label": _score_label(generic_risk),
            "confidence": 30,
            "is_fallback": True,
            "fallback_note": fallback_note,
            "fssai_number": fssai_number,
            "flagged": [],
            "clean": [],
            "unknown": [],
            "alternatives": alternatives,
        }

        # Persist scan if user is authenticated
        if user_id:
            scan_id = _save_scan_record(cursor, user_id, scan_result, image_path)
            conn.commit()
            scan_result["scan_id"] = scan_id

        conn.close()
        return scan_result

    # 4. Fetch all ingredients and aliases from database
    cursor.execute("""
        SELECT i.id, i.canonical_name, i.risk_level, i.health_effects, i.fssai_ref, a.alias
        FROM ingredients i
        JOIN aliases a ON i.id = a.ingredient_id
    """)
    alias_rows = cursor.fetchall()

    # Build alias lookup map: lowercase_alias -> ingredient info
    alias_map = {}
    for r in alias_rows:
        alias_map[r["alias"].lower().strip()] = {
            "id": r["id"],
            "canonical": r["canonical_name"],
            "risk_level": r["risk_level"],
            "health_effects": r["health_effects"],
            "fssai_ref": r["fssai_ref"],
        }

    # Also map exact canonical names
    cursor.execute("SELECT id, canonical_name, risk_level, health_effects, fssai_ref FROM ingredients")
    for r in cursor.fetchall():
        canonical_lower = r["canonical_name"].lower().strip()
        if canonical_lower not in alias_map:
            alias_map[canonical_lower] = {
                "id": r["id"],
                "canonical": r["canonical_name"],
                "risk_level": r["risk_level"],
                "health_effects": r["health_effects"],
                "fssai_ref": r["fssai_ref"],
            }

    # 5. Match tokens against alias map
    flagged = []
    clean = []
    unknown = []
    seen_canonicals = set()

    for token in raw_ingredients:
        t_lower = token.lower().strip()
        matched = None

        # Exact alias match first
        if t_lower in alias_map:
            matched = alias_map[t_lower]
        else:
            # Substring match (e.g. "contains palm oil" or "ins 621")
            for alias, info in alias_map.items():
                if alias in t_lower or t_lower in alias:
                    matched = info
                    break

        if matched:
            canonical = matched["canonical"]
            if canonical in seen_canonicals:
                continue
            seen_canonicals.add(canonical)

            entry = {
                "raw_token": token,
                "canonical": canonical,
                "risk_level": matched["risk_level"],
                "health_effects": matched["health_effects"],
                "fssai_ref": matched["fssai_ref"],
            }
            if matched["risk_level"] in ("high", "watch"):
                flagged.append(entry)
            else:
                clean.append(entry)
        else:
            unknown.append(token)

    # 6. Calculate risk score (0-100)
    # High risk flags penalize 20 pts, Watch risk penalize 9 pts, Clean bonus +2 up to 10 pts
    high_penalty = sum(20 for f in flagged if f["risk_level"] == "high")
    watch_penalty = sum(9 for f in flagged if f["risk_level"] == "watch")
    clean_bonus = min(len(clean) * 2, 10)

    raw_score = 85 - (high_penalty + watch_penalty) + clean_bonus
    risk_score = max(5, min(100, raw_score))

    # Calculate confidence based on proportion of recognized ingredients
    total_tokens = len(flagged) + len(clean) + len(unknown)
    recognized = len(flagged) + len(clean)
    if total_tokens > 0:
        ratio = recognized / total_tokens
        confidence = min(98, round(45 + ratio * 50))
    else:
        confidence = 30

    # 7. Get healthier alternatives for this category
    alternatives = _get_alternatives(cursor, category_name, risk_score)

    scan_result = {
        "product_name": product_name or "Packaged Food Product",
        "category": category_name,
        "risk_score": risk_score,
        "score_label": _score_label(risk_score),
        "confidence": confidence,
        "is_fallback": False,
        "fallback_note": None,
        "fssai_number": fssai_number,
        "flagged": flagged,
        "clean": clean,
        "unknown": unknown,
        "alternatives": alternatives,
    }

    # Save to history if user is logged in
    if user_id:
        scan_id = _save_scan_record(cursor, user_id, scan_result, image_path)
        conn.commit()
        scan_result["scan_id"] = scan_id

    conn.close()
    return scan_result


def _detect_category(product_name: str, ingredients: list[str], categories_rows) -> str:
    combined = (f"{product_name} " + " ".join(ingredients)).lower()
    best_category = "Namkeen / Fried Snacks"
    max_matches = 0

    for cat in categories_rows:
        keywords = [k.strip() for k in cat["keywords"].split(",") if k.strip()]
        matches = sum(1 for kw in keywords if kw in combined)
        if matches > max_matches:
            max_matches = matches
            best_category = cat["name"]

    return best_category


def _get_alternatives(cursor, category_name: str, current_score: int) -> list[dict]:
    cursor.execute("""
        SELECT name, score, price, note
        FROM alternatives
        WHERE category_name = ?
        ORDER BY score DESC
        LIMIT 3
    """, (category_name,))
    rows = cursor.fetchall()
    return [
        {
            "name": r["name"],
            "score": r["score"],
            "price": r["price"],
            "note": r["note"],
        }
        for r in rows
    ]


def _score_label(score: int) -> str:
    if score >= 75:
        return "Clean / Safe"
    if score >= 50:
        return "Moderate"
    if score >= 30:
        return "Caution"
    return "High Risk"


def _save_scan_record(cursor, user_id: int, result: dict, image_path: str | None) -> int:
    cursor.execute("""
        INSERT INTO scans (
            user_id, product_name, category, risk_score, confidence,
            flagged_json, clean_json, unknown_json, fssai_number,
            is_fallback, fallback_note, image_path
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        user_id,
        result["product_name"],
        result["category"],
        result["risk_score"],
        result["confidence"],
        json.dumps(result["flagged"]),
        json.dumps(result["clean"]),
        json.dumps(result["unknown"]),
        result.get("fssai_number"),
        1 if result.get("is_fallback") else 0,
        result.get("fallback_note"),
        image_path,
    ))
    return cursor.lastrowid
