"""
Vision-LLM extractor using Google's Gemini API (free tier).
Same IngredientExtractor interface as claude_vision.py — swappable,
extraction-only, no judgment (see handover Section 5.4).
"""

import os
from pathlib import Path
from dotenv import load_dotenv

from .base import IngredientExtractor, ExtractionResult, ExtractionError

# Load .env from the extraction folder
# ENV_FILE = Path("D:\\Aditya\\5th semester\\SE\\willlow\\Journal\\1024160001_adityagupta\\backend\\extraction\\.env").resolve().parent / ".env"
# load_dotenv(ENV_FILE)

ENV_FILE = Path(__file__).resolve().parent / ".env"
load_dotenv(ENV_FILE)

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

DEFAULT_MODEL = "gemini-3.6-flash"  # if this errors as "model not found", check
                                     # https://ai.google.dev/gemini-api/docs/pricing
                                     # for the current free-tier name


class GeminiVisionExtractor(IngredientExtractor):
    def __init__(self, api_key: str | None = None, model: str | None = None):
        self.api_key = api_key or os.environ.get("GEMINI_API_KEY")
        self.model = model or os.environ.get("GEMINI_MODEL", DEFAULT_MODEL)
        if not self.api_key:
            raise ExtractionError(
                "No API key found. Set GEMINI_API_KEY in your environment "
                "or .env file. Get a free key at https://aistudio.google.com/apikey"
            )

    def extract(self, image_path: str) -> ExtractionResult:
        try:
            from google import genai
        except ImportError:
            raise ExtractionError("Run: pip install google-genai")

        if not os.path.exists(image_path):
            raise ExtractionError(f"Image not found at {image_path}")

        client = genai.Client(api_key=self.api_key)

        try:
            uploaded_file = client.files.upload(file=image_path)
        except Exception as e:
            raise ExtractionError(f"Image upload to Gemini failed: {e}")

        try:
            interaction = client.interactions.create(
                model=self.model,
                input=[
                    {"type": "text", "text": EXTRACTION_PROMPT},
                    {"type": "image", "uri": uploaded_file.uri, "mime_type": uploaded_file.mime_type},
                ],
            )
        except Exception as e:
            raise ExtractionError(
                f"Gemini API call failed (model='{self.model}'): {e}. "
                f"Check current free-tier model name at "
                f"https://ai.google.dev/gemini-api/docs/pricing"
            )

        raw_text = (interaction.output_text or "").strip()
        if raw_text == "NO_INGREDIENT_LIST_FOUND":
            return ExtractionResult(raw_text="", confidence=0.0, provider=f"gemini:{self.model}")

        confidence = 0.9 if "[unclear]" not in raw_text and len(raw_text) > 10 else 0.5
        return ExtractionResult(raw_text=raw_text, confidence=confidence, provider=f"gemini:{self.model}")