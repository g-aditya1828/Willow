"""
Minimal HTTP API around the existing extraction module, for the Flutter
frontend to call. Scope is deliberately narrow for the midterm: photo in,
ingredient list out. No classification/harmful-flagging yet.

Run:
    pip install flask flask-cors
    python3 api_server.py
"""

import os
import tempfile

from flask import Flask, request, jsonify
from flask_cors import CORS

from extraction import parse_ingredient_list, ExtractionError
from extraction.tesseract_ocr import TesseractExtractor

app = Flask(__name__)
CORS(app)

ALLOWED_EXTS = {".jpg", ".jpeg", ".png", ".webp"}


def get_extractor(provider: str):
    if provider == "tesseract":
        return TesseractExtractor()
    from extraction.gemini_vision import GeminiVisionExtractor
    return GeminiVisionExtractor()


@app.route("/extract", methods=["POST"])
def extract():
    if "image" not in request.files:
        return jsonify({"error": "No 'image' file in request"}), 400

    file = request.files["image"]
    ext = os.path.splitext(file.filename or "")[1].lower()
    if ext not in ALLOWED_EXTS:
        return jsonify({"error": f"Unsupported file type '{ext}'. Use jpg/jpeg/png/webp."}), 400

    provider = request.form.get("provider", "gemini")

    with tempfile.NamedTemporaryFile(suffix=ext, delete=False) as tmp:
        file.save(tmp.name)
        tmp_path = tmp.name

    try:
        extractor = get_extractor(provider)
        result = extractor.extract(tmp_path)
        ingredients = parse_ingredient_list(result.raw_text)
        return jsonify({
            "ingredients": ingredients,
            "raw_text": result.raw_text,
            "confidence": result.confidence,
            "provider": provider,
        })
    except ExtractionError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        os.remove(tmp_path)


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)