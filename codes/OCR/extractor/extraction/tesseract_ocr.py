"""
Enhanced Local OCR extractor using Tesseract with pre-processing pipeline.
Applies:
- Auto-rotation from EXIF
- Adaptive contrast stretching and sharpening
- Otsu binarization fallback for shiny or low-contrast wrappers
- Multi-pass extraction to select the best recognized text
"""

from PIL import Image
import pytesseract

from .base import IngredientExtractor, ExtractionResult, ExtractionError
from .preprocessor import enhance_for_ocr, otsu_binarize


class TesseractExtractor(IngredientExtractor):
    def __init__(self, lang: str = "eng"):
        self.lang = lang

    def extract(self, image_path: str) -> ExtractionResult:
        try:
            original_image = Image.open(image_path)
        except Exception as e:
            raise ExtractionError(f"Could not open image at {image_path}: {e}")

        # Multi-pass OCR:
        # Pass 1: Enhanced grayscale & sharpened
        try:
            pass1_img = enhance_for_ocr(original_image)
            pass1_text = pytesseract.image_to_string(pass1_img, lang=self.lang, config="--psm 6")
            pass1_conf = self._estimate_confidence(pass1_img)
        except Exception:
            pass1_text = ""
            pass1_conf = 0.0

        # Pass 2: Otsu binarized (handles glossy metallic reflection on foil snack packets)
        pass2_text = ""
        pass2_conf = 0.0
        if pass1_conf < 0.65 or len(pass1_text.strip()) < 20:
            try:
                pass2_img = otsu_binarize(original_image)
                pass2_text = pytesseract.image_to_string(pass2_img, lang=self.lang, config="--psm 6")
                pass2_conf = self._estimate_confidence(pass2_img)
            except Exception:
                pass2_text = ""
                pass2_conf = 0.0

        # Pass 3: Default layout analysis on original if psm 6 was too rigid
        pass3_text = ""
        pass3_conf = 0.0
        if max(pass1_conf, pass2_conf) < 0.5:
            try:
                pass3_text = pytesseract.image_to_string(original_image, lang=self.lang)
                pass3_conf = self._estimate_confidence(original_image)
            except Exception:
                pass3_text = ""
                pass3_conf = 0.0

        # Pick best outcome based on confidence and content length
        candidates = [
            (pass1_text.strip(), pass1_conf),
            (pass2_text.strip(), pass2_conf),
            (pass3_text.strip(), pass3_conf),
        ]
        # Sort by combination of confidence and text presence
        best_text, best_conf = max(
            candidates,
            key=lambda c: (1 if len(c[0]) > 15 else 0, c[1], len(c[0]))
        )

        return ExtractionResult(
            raw_text=best_text,
            confidence=round(best_conf, 2),
            provider="tesseract-enhanced",
        )

    def _estimate_confidence(self, image: Image.Image) -> float:
        """Tesseract reports per-word confidence (0-100, -1 for non-text).
        Average the valid scores as a rough overall confidence signal."""
        try:
            data = pytesseract.image_to_data(image, output_type=pytesseract.Output.DICT)
            scores = [int(c) for c in data.get("conf", []) if str(c) not in ("-1", "")]
            if not scores:
                return 0.0
            return round(sum(scores) / len(scores) / 100, 2)
        except Exception:
            return 0.0
