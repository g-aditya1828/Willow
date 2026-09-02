"""
Local OCR extractor using Tesseract.

Use case: development/testing without needing a vision-API key, and as a
free fallback path. NOT the primary extractor for production — real-world
product packaging (glare, curved surfaces, small print) is exactly where
classic OCR struggles most and vision LLMs do noticeably better. This is
here so the pipeline is testable end-to-end from day one.
"""

from PIL import Image
import pytesseract

from .base import IngredientExtractor, ExtractionResult, ExtractionError
# from extraction import ClaudeVisionExtractor, parse_ingredient_list

# extractor = ClaudeVisionExtractor()
# result = extractor.extract("D:/Aditya/5th semester/SE/not-so-real-ingredients-1.jpg")
# ingredients = parse_ingredient_list(result.raw_text)
# print(ingredients)

class TesseractExtractor(IngredientExtractor):
    def __init__(self, lang: str = "eng"):
        self.lang = lang

    def extract(self, image_path: str) -> ExtractionResult:
        try:
            image = Image.open(image_path)
        except Exception as e:
            raise ExtractionError(f"Could not open image at {image_path}: {e}")

        try:
            raw_text = pytesseract.image_to_string(image, lang=self.lang)
        except Exception as e:
            raise ExtractionError(f"Tesseract OCR failed: {e}")

        confidence = self._estimate_confidence(image)

        return ExtractionResult(
            raw_text=raw_text.strip(),
            confidence=confidence,
            provider="tesseract-local",
        )

    def _estimate_confidence(self, image: Image.Image) -> float:
        """Tesseract reports per-word confidence (0-100, -1 for non-text).
        Average the valid scores as a rough overall confidence signal."""
        try:
            data = pytesseract.image_to_data(image, output_type=pytesseract.Output.DICT)
            scores = [int(c) for c in data.get("conf", []) if c not in ("-1", -1)]
            if not scores:
                return 0.0
            return round(sum(scores) / len(scores) / 100, 2)
        except Exception:
            return 0.0
