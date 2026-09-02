"""
Generates a synthetic ingredient-panel image to validate the extraction
pipeline actually works end-to-end (Tesseract extractor -> parser),
without needing a real product photo or an API key.
"""

from PIL import Image, ImageDraw, ImageFont
import os

OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "sample_images", "test_label.png")

LABEL_TEXT = (
    "INGREDIENTS: Refined Wheat Flour (Maida), Sugar, Palm Oil,\n"
    "Milk Solids (Milk, Milk Fat), Salt, Raising Agents (INS 500(ii)),\n"
    "Emulsifier (INS 322), Artificial Flavour."
)


def generate(path: str = OUTPUT_PATH) -> str:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img = Image.new("RGB", (700, 220), color="white")
    draw = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18)
    except Exception:
        font = ImageFont.load_default()
    draw.multiline_text((20, 20), LABEL_TEXT, fill="black", font=font, spacing=10)
    img.save(path)
    return path


if __name__ == "__main__":
    out = generate()
    print(f"Generated test label image at: {out}")
