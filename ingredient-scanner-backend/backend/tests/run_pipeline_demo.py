"""
End-to-end sanity check: runs a real image through the Tesseract extractor,
then through the parser, and prints the result. This is the fastest way to
confirm the extraction module actually works before wiring it into an app.

Run: python3 tests/run_pipeline_demo.py
"""

import sys
import os
import pytesseract

pytesseract.pytesseract.tesseract_cmd = r"D:/tesseract-ocr/tesseract.exe"
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from extraction import TesseractExtractor, parse_ingredient_list
from generate_test_image import generate, OUTPUT_PATH


def main():
    image_path = generate() if not os.path.exists(OUTPUT_PATH) else OUTPUT_PATH

    extractor = TesseractExtractor()
    result = extractor.extract(image_path)

    print("=" * 60)
    print(f"Provider:   {result.provider}")
    print(f"Confidence: {result.confidence}")
    print("-" * 60)
    print("Raw extracted text:")
    print(result.raw_text)
    print("-" * 60)

    ingredients = parse_ingredient_list(result.raw_text)
    print(f"Parsed into {len(ingredients)} ingredient entries:")
    for i, ing in enumerate(ingredients, 1):
        print(f"  {i}. {ing}")
    print("=" * 60)


if __name__ == "__main__":
    main()
