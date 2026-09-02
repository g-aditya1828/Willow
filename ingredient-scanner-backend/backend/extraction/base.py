"""
Abstract interface for ingredient-panel text extraction.

Design principle (from project handover, Section 5.4):
The extraction layer's ONLY job is to read text off a product photo.
It must NOT judge, classify, or explain anything about the ingredients —
that happens later, against our own curated database.

Any concrete extractor (a vision LLM, a local OCR engine, or something
else entirely) must implement this interface, so the provider can be
swapped without touching the classification or alternatives layers.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass


@dataclass
class ExtractionResult:
    raw_text: str        # unprocessed text as read from the image
    confidence: float     # 0.0-1.0, provider-reported or heuristic
    provider: str          # which extractor produced this, for logging/debugging


class IngredientExtractor(ABC):
    """Reads the ingredient-panel text off a product photo. Nothing more."""

    @abstractmethod
    def extract(self, image_path: str) -> ExtractionResult:
        """
        Args:
            image_path: path to a product photo on disk.
        Returns:
            ExtractionResult with the raw extracted text and a confidence score.
        Raises:
            ExtractionError: if the image can't be read or processed at all.
        """
        raise NotImplementedError


class ExtractionError(Exception):
    """Raised when extraction fails outright (bad file, provider error, etc.)."""
    pass
