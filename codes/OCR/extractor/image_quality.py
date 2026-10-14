"""
Image quality validation for Willow (FR-3).
Checks blur, brightness, and resolution before sending to OCR pipeline.
Returns a confidence score (0-1) and a list of issues + suggestions.
No heavy dependencies — uses only Pillow if available, otherwise passes through.
"""
import os

try:
    from PIL import Image
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False


def check_image_quality(image_path: str) -> dict:
    """
    Validate image quality for OCR suitability.

    Returns:
        {
            "ok": bool,
            "confidence": float (0.0–1.0),
            "issues": list[str],
            "suggestions": list[str]
        }
    """
    issues: list[str] = []
    suggestions: list[str] = []

    # ── Basic file existence check ─────────────────────────────────────────────
    if not os.path.exists(image_path):
        return {
            "ok": False, "confidence": 0.0,
            "issues": ["File not found"],
            "suggestions": ["Upload a valid image file"],
        }

    file_size = os.path.getsize(image_path)
    if file_size < 5_000:   # < 5 KB — almost certainly too small
        return {
            "ok": False, "confidence": 0.1,
            "issues": ["Image file too small — may be corrupt or empty"],
            "suggestions": ["Take a clearer, closer photo of the ingredient panel"],
        }

    # ── PIL-based checks (optional, gracefully skipped if Pillow not installed) ─
    if not PIL_AVAILABLE:
        return {"ok": True, "confidence": 0.70, "issues": [], "suggestions": []}

    try:
        img = Image.open(image_path)
        w, h = img.size

        # Resolution
        if w < 300 or h < 300:
            issues.append(f"Image resolution too low ({w}×{h} px) — text may be unreadable")
            suggestions.append("Move closer and retake the photo")

        # Convert to grayscale for analysis
        gray = img.convert("L")
        pixels = list(gray.getdata())
        n = len(pixels)
        if n == 0:
            return {"ok": True, "confidence": 0.60, "issues": [], "suggestions": []}

        # Brightness
        mean_brightness = sum(pixels) / n
        if mean_brightness < 50:
            issues.append("Image is too dark — text may not be visible")
            suggestions.append("Move to a brighter area or enable torch/flash")
        elif mean_brightness > 220:
            issues.append("Image is overexposed — glare may obscure text")
            suggestions.append("Avoid direct flash; use ambient or indirect lighting")

        # Blur heuristic: variance of pixel values
        # Blurry images have very uniform pixel values → low variance
        sample = pixels[:min(n, 8_000)]
        variance = sum((p - mean_brightness) ** 2 for p in sample) / len(sample)
        if variance < 150:
            issues.append("Image appears blurry — ingredient text may not be readable")
            suggestions.append("Hold the phone steady and ensure the label is in sharp focus")

        # Aspect ratio — very extreme ratios are unusual for ingredient panels
        aspect = w / h if h > 0 else 1.0
        if aspect > 6.0 or aspect < 0.1:
            issues.append("Unusual image orientation — may not be an ingredient label photo")
            suggestions.append("Photograph the ingredient panel directly, filling the frame")

        ok = len(issues) == 0
        confidence = max(0.15, 1.0 - len(issues) * 0.22)
        return {
            "ok": ok,
            "confidence": round(confidence, 2),
            "issues": issues,
            "suggestions": suggestions,
        }

    except Exception:
        # Never block the pipeline on a validation error
        return {"ok": True, "confidence": 0.65, "issues": [], "suggestions": []}
