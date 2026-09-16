Ingredient Scanner — Extraction Module

This is the first piece of the pipeline described in the project handover:
**Photo Upload → Extraction Service → Classification Engine → Alternatives Engine → Results**

This module handles ONLY the first step: turning a product photo into a
clean list of ingredient strings. It deliberately does **not** judge or
classify anything — that's the next module to build, against the curated
harmful-ingredients database (see handover Section 10).

## What's here

```
backend/
  extraction/
    base.py            Abstract interface (IngredientExtractor) — any provider plugs in here
    tesseract_ocr.py    Local OCR extractor (no API key needed) — for dev/testing
    claude_vision.py    Vision-LLM extractor (Claude vision) — the primary production path
    parser.py           Turns raw extracted text into a structured ingredient list
  tests/
    test_parser.py             Unit tests for the parser (pure logic, no image needed)
    test_parser_label_fix.py   Regression test for the "INGREDIENTS:" label-stripping fix
    generate_test_image.py     Creates a synthetic label image for pipeline testing
    run_pipeline_demo.py       Runs a real image through extraction + parsing end-to-end
```

## Setup

```bash
cd backend
pip install -r requirements.txt

# Tesseract binary (if not already installed):
sudo apt-get install tesseract-ocr

# For the vision-LLM path:
cp .env.example .env
# then fill in ANTHROPIC_API_KEY in .env
```

## Try it

Run the local (no API key) pipeline demo — generates a synthetic label
image, extracts it with Tesseract, and parses the result:

```bash
python3 tests/run_pipeline_demo.py
```

Run the unit tests:

```bash
python3 tests/test_parser.py
python3 tests/test_parser_label_fix.py
```

Use the vision extractor on a real photo once your API key is set:

```python
from extraction import ClaudeVisionExtractor, parse_ingredient_list

extractor = ClaudeVisionExtractor()
result = extractor.extract("path/to/product_photo.jpg")
ingredients = parse_ingredient_list(result.raw_text)
print(ingredients)
```

## Status

- [X] Abstract extractor interface (swappable providers — FR-7)
- [X] Local Tesseract extractor — tested end-to-end on a synthetic label, works correctly
- [X] Vision-LLM extractor (Claude vision) — written, not yet tested against a real API key
- [X] Parser: comma/semicolon splitting that respects nested parentheses, label-prefix
  stripping, whitespace normalization — 10/10 unit tests passing
- [ ] Not yet built: alias resolution (E621 → MSG → Ajinomoto), which belongs in the
  classification layer, not here (see handover Section 5.4 and 10)
- [ ] Not yet built: classification engine, harmful-ingredients database, category
  fallback for unbranded products
- [ ] ..

## Next steps (per the project timeline, Phase 1-2)

1. Test `ClaudeVisionExtractor` against real product photos (10-20 image test set,
   mix of clear/blurry/curved packaging) and compare accuracy against Tesseract.
2. Start building the curated ingredient database in parallel (handover Section 10) —
   it doesn't depend on this module being finished.
3. Once both exist, build the matching/classification layer that connects them.
