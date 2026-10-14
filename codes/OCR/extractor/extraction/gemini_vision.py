"""
Vision-LLM extractor using Google's Gemini API with automatic local OCR fallback.
Implements the abstracted IngredientExtractor interface.
Extracts verbatim text only (no hallucinated health claims).
"""

import os
from pathlib import Path
from dotenv import load_dotenv

from .base import IngredientExtractor, ExtractionResult, ExtractionError
from .tesseract_ocr import TesseractExtractor

# Look for .env in current directory or extraction parent
for p in [Path(__file__).resolve().parent / ".env", Path(__file__).resolve().parent.parent / ".env"]:
    if p.exists():
        load_dotenv(p)
        break

EXTRACTION_PROMPT = (
    "You are an expert food packaging vision scanner for Indian packaged food products.\n"
    "Look at the package image and perform verbatim extraction:\n"
    "1. Find the INGREDIENT LIST and transcribe it EXACTLY as written on the packaging as a single comma-separated line.\n"
    "2. If an FSSAI 14-digit license number is visible (e.g. Lic. No. 10012345678901), note it as FSSAI: <number>.\n"
    "3. If a product title is clearly visible on the pack, note it as PRODUCT: <title>.\n\n"
    "Rules:\n"
    "- Only transcribe text that is actually visible on the package.\n"
    "- Do not classify, judge, explain, or alter any ingredient name.\n"
    "- If no ingredient list is visible anywhere, respond with exactly: NO_INGREDIENT_LIST_FOUND\n"
    "- Output format:\n"
    "PRODUCT: <product name or UNKNOWN>\n"
    "FSSAI: <14-digit number if visible or NONE>\n"
    "INGREDIENTS: <comma-separated ingredients>\n"
)

DEFAULT_MODEL = os.environ.get("GEMINI_MODEL", "gemini-2.5-flash")


class GeminiVisionExtractor(IngredientExtractor):
    def __init__(self, api_key: str | None = None, model: str | None = None):
        self.api_key = api_key or os.environ.get("GEMINI_API_KEY")
        self.model = model or DEFAULT_MODEL
        self._fallback = TesseractExtractor()

    def extract(self, image_path: str) -> ExtractionResult:
        if not os.path.exists(image_path):
            raise ExtractionError(f"Image not found at {image_path}")

        # If no Gemini API key configured, gracefully use the enhanced local Tesseract extractor
        if not self.api_key:
            return self._fallback.extract(image_path)

        try:
            from google import genai
            client = genai.Client(api_key=self.api_key)
            uploaded_file = client.files.upload(file=image_path)

            interaction = client.interactions.create(
                model=self.model,
                input=[
                    {"type": "text", "text": EXTRACTION_PROMPT},
                    {"type": "image", "uri": uploaded_file.uri, "mime_type": uploaded_file.mime_type},
                ],
            )
            raw_text = (interaction.output_text or "").strip()

            if "NO_INGREDIENT_LIST_FOUND" in raw_text:
                return ExtractionResult(raw_text="", confidence=0.0, provider=f"gemini:{self.model}")

            confidence = 0.95 if "[unclear]" not in raw_text and len(raw_text) > 10 else 0.65
            return ExtractionResult(raw_text=raw_text, confidence=confidence, provider=f"gemini:{self.model}")

        except Exception as e:
            # Fall back to enhanced local Tesseract on any Gemini API failure
            try:
                res = self._fallback.extract(image_path)
                return ExtractionResult(
                    raw_text=res.raw_text,
                    confidence=res.confidence,
                    provider=f"tesseract-fallback (gemini failed: {str(e)[:50]})"
                )
            except Exception:
                raise ExtractionError(f"Extraction failed via Gemini and local fallback: {e}")