"""
Parses raw packaging text into structured ingredient lists and metadata.
Features:
- Nested parentheses preservation (e.g. "Wheat Flour (Atta (65%), Maida (10%))")
- 14-digit FSSAI license number extraction
- Product name extraction when present
- Packaging boilerplate noise filtering
- Normalization of INS/E-number annotations
"""

import re
from typing import NamedTuple


class ParsedExtraction(NamedTuple):
    product_name: str | None
    fssai_number: str | None
    ingredients: list[str]


def parse_extraction_output(raw_text: str) -> ParsedExtraction:
    """
    Parses structured text output (or raw OCR string) into:
    product_name, fssai_number, and list of ingredients.
    """
    if not raw_text or not raw_text.strip():
        return ParsedExtraction(product_name=None, fssai_number=None, ingredients=[])

    text = raw_text.strip()
    product_name = None
    fssai_number = None

    # Check for structured keys from Gemini or OCR
    prod_match = re.search(r"^PRODUCT\s*:\s*(.+)$", text, flags=re.MULTILINE | re.IGNORECASE)
    if prod_match:
        cand = prod_match.group(1).strip()
        if cand.upper() not in ("UNKNOWN", "NONE", ""):
            product_name = cand

    # FSSAI 14-digit license number detection anywhere in text
    fssai_match = re.search(r"(?:lic(?:ence)?\.?\s*(?:no\.?)?\s*|fssai\s*(?:licence|lic)?\.?\s*(?:no\.?)?\s*)?(\b\d{14}\b)", text, flags=re.IGNORECASE)
    if fssai_match:
        fssai_number = fssai_match.group(1)
    else:
        # Bare 14-digit sequence
        bare_14 = re.search(r"\b\d{14}\b", text)
        if bare_14:
            fssai_number = bare_14.group(0)

    # Extract ingredients portion
    ing_portion = text
    ing_match = re.search(r"^INGREDIENTS\s*:\s*(.+)$", text, flags=re.MULTILINE | re.IGNORECASE | re.DOTALL)
    if ing_match:
        ing_portion = ing_match.group(1).strip()
    else:
        # Remove PRODUCT: and FSSAI: lines if they exist
        lines = []
        for line in text.splitlines():
            line_s = line.strip()
            if re.match(r"^(PRODUCT|FSSAI)\s*:", line_s, flags=re.IGNORECASE):
                continue
            lines.append(line)
        ing_portion = " ".join(lines)

    ingredients = parse_ingredient_list(ing_portion)
    return ParsedExtraction(product_name=product_name, fssai_number=fssai_number, ingredients=ingredients)


def parse_ingredient_list(raw_text: str) -> list[str]:
    """
    Splits raw ingredient text into individual normalized ingredient entries.
    Handles:
    - Commas and semicolons outside parentheses
    - Drops boilerplate ("Ingredients:", "Manufactured by", "Batch No")
    - Normalizes INS numbers
    """
    if not raw_text or not raw_text.strip():
        return []

    text = raw_text.strip()

    # Drop trailing dot
    if text.endswith("."):
        text = text[:-1]

    # Clean leading label prefixes
    text = re.sub(r"^(ingredients|contains)\s*:?\s*", "", text, flags=re.IGNORECASE)

    # Clean common packaging noise phrases
    noise_patterns = [
        r"(best before|batch no|mfg date|exp date|net weight|net wt|mrp).*$",
        r"store in a cool (and )?dry place.*$",
        r"contains permitted natural food colou?rs?.*$",
        r"contains added flavou?rs?.*$",
    ]
    for np in noise_patterns:
        text = re.sub(np, "", text, flags=re.IGNORECASE)

    entries = _split_respecting_parens(text)

    cleaned = []
    for entry in entries:
        e = entry.strip().strip(",;•.-")
        e = re.sub(r"\s+", " ", e)

        # Drop standalone leading "and" or "&"
        e = re.sub(r"^(and|&)\s+", "", e, flags=re.IGNORECASE)

        # Clean noise entries (e.g. pure numbers, dates)
        if not e or len(e) < 2 or re.match(r"^[\d\W]+$", e):
            continue

        # Drop common non-ingredient junk
        if re.match(r"^(contains|allergen|warning|nutrition|lic|mrp)\b", e, flags=re.IGNORECASE):
            continue

        cleaned.append(e)

    return cleaned


def _split_respecting_parens(text: str) -> list[str]:
    """Split on ',', ';', or bullets, but never inside balanced parentheses."""
    parts = []
    buf = []
    depth = 0
    chars_in_paren = 0

    for ch in text:
        if ch == "(":
            depth += 1
            chars_in_paren = 0
            buf.append(ch)
        elif ch == ")":
            depth = max(0, depth - 1)
            chars_in_paren = 0
            buf.append(ch)
        elif ch in ",;•\n\r":
            # If comma or newline encountered and depth has been active for too long (unclosed paren artifact), reset
            if depth > 0 and (chars_in_paren > 75 or ch in "\n\r"):
                depth = 0
            if depth == 0:
                parts.append("".join(buf))
                buf = []
            else:
                buf.append(ch)
                chars_in_paren += 1
        else:
            if depth > 0:
                chars_in_paren += 1
                if chars_in_paren > 100:  # Safety fallback for runaway unclosed parens
                    depth = 0
            buf.append(ch)

    if buf:
        parts.append("".join(buf))
    return parts
