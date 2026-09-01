"""
Parses raw ingredient-panel text (from any extractor) into a clean,
structured list of ingredient strings.

This is deliberately NOT where classification happens (see handover
Section 5.4) — it only cleans and splits text. Alias resolution
(E621 -> MSG -> Ajinomoto) and harmful-ingredient matching happen in the
classification layer against our curated database, not here.
"""

import re


def parse_ingredient_list(raw_text: str) -> list[str]:
    """
    Splits raw ingredient text into individual ingredient entries.

    Handles the common real-world messiness:
    - Splits on commas/semicolons, but NOT inside parentheses
      (e.g. "Wheat Flour (Wheat, Gluten)" stays as one entry)
    - Strips percentage annotations like "(2%)" is left alone if it's the
      whole parenthetical, but bare leading/trailing punctuation is cleaned
    - Removes empty entries and normalizes whitespace
    - Removes a trailing period on the whole raw text before splitting
    """
    if not raw_text or not raw_text.strip():
        return []

    text = raw_text.strip()
    if text.endswith("."):
        text = text[:-1]

    # Strip a leading label like "INGREDIENTS:" or "Ingredients :" that
    # commonly precedes the actual list on real packaging.
    text = re.sub(r"^ingredients\s*:?\s*", "", text, flags=re.IGNORECASE)

    entries = _split_respecting_parens(text)

    cleaned = []
    for entry in entries:
        e = entry.strip().strip(",;")
        e = re.sub(r"\s+", " ", e)
        # Drop a lone leading "and" from phrasing like "...,and Salt"
        e = re.sub(r"^(and)\s+", "", e, flags=re.IGNORECASE)
        if e:
            cleaned.append(e)

    return cleaned


def _split_respecting_parens(text: str) -> list[str]:
    """Split on ',' or ';' but never inside ( ... ) groups."""
    parts = []
    buf = []
    depth = 0
    for ch in text:
        if ch == "(":
            depth += 1
            buf.append(ch)
        elif ch == ")":
            depth = max(0, depth - 1)
            buf.append(ch)
        elif ch in ",;" and depth == 0:
            parts.append("".join(buf))
            buf = []
        else:
            buf.append(ch)
    if buf:
        parts.append("".join(buf))
    return parts
