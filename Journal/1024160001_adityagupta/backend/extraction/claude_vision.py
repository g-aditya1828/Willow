"""
Vision-LLM extractor using a multimodal model's vision capability.

This is the PRIMARY production extractor (see handover Section 5.4):
vision-capable models read real-world packaging (glare, curved surfaces,
mixed languages) far better than classic OCR. Its prompt is deliberately
scoped to extraction ONLY — no classification, no judgment, no health
claims. That separation is a deliberate architecture decision, not an
oversight: keeping this layer "dumb" (read-only) is what keeps harmful-
ingredient claims traceable to our own curated database instead of to
model output.

Requires an API key set as an environment variable (see .env.example).
Swap the model/provider here without touching any other layer.
"""

import base64
import os

from .base import IngredientExtractor, ExtractionResult, ExtractionError

EXTRACTION_PROMPT = (
    "You are looking at a photo of a packaged product. Find the ingredient "
    "list printed on the label and transcribe it EXACTLY as written, as a "
    "single comma-separated line of text.\n\n"
    "Rules:\n"
    "- Only transcribe text that is actually printed on the package.\n"
    "- Do not classify, judge, explain, or comment on any ingredient.\n"
    "- Do not add ingredients that are not visible.\n"
    "- If no ingredient list is visible anywhere on the package, respond "
    "with exactly: NO_INGREDIENT_LIST_FOUND\n"
    "- If the text is partially unreadable, transcribe what you can and "
    "mark unreadable portions as [unclear].\n\n"
    "Respond with ONLY the transcribed text or NO_INGREDIENT_LIST_FOUND. "
    "No preamble, no explanation."
)


class ClaudeVisionExtractor(IngredientExtractor):
    def __init__(self, api_key: str | None = None, model: str = "gemini-2.5-flash"):
        self.api_key = api_key or os.environ.get("GEMINI_API_KEY")
        self.model = model
        if not self.api_key:
            raise ExtractionError(
                "No API key found. Set GEMINI_API_KEY in your environment "
                "or .env file (see .env.example)."
            )

    def extract(self, image_path: str) -> ExtractionResult:
        try:
            from google import genai
            from google.genai import types
        except ImportError:
            raise ExtractionError(
                "The 'google-genai' package is not installed. Run: "
                "pip install google-genai"
            )

        media_type = self._guess_media_type(image_path)
        try:
            with open(image_path, "rb") as f:
                image_bytes = f.read()
        except Exception as e:
            raise ExtractionError(f"Could not read image at {image_path}: {e}")

        client = genai.Client(api_key=self.api_key)
        try:
            response = client.models.generate_content(
                model=self.model,
                max_tokens=1000,
                contents=[
                    types.Part.from_bytes(
                        data=image_bytes,
                        mime_type=media_type,
                    ),
                    EXTRACTION_PROMPT,
                ],
            )
        except Exception as e:
            raise ExtractionError(f"Vision API call failed: {e}")

        raw_text = "".join(
            block.text for block in response.content if block.type == "text"
        ).strip()

        if raw_text == "NO_INGREDIENT_LIST_FOUND":
            return ExtractionResult(raw_text="", confidence=0.0, provider=f"vision:{self.model}")

        # Heuristic confidence: no [unclear] markers and reasonable length -> higher confidence
        confidence = 0.9 if "[unclear]" not in raw_text and len(raw_text) > 10 else 0.5

        return ExtractionResult(raw_text=raw_text, confidence=confidence, provider=f"vision:{self.model}")

    @staticmethod
    def _guess_media_type(image_path: str) -> str:
        ext = image_path.lower().rsplit(".", 1)[-1]
        return {
            "jpg": "image/jpeg",
            "jpeg": "image/jpeg",
            "png": "image/png",
            "webp": "image/webp",
        }.get(ext, "image/jpeg")
