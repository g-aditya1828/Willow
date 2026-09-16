"""
Compare extractors against a folder of real product photos.

Usage:
    python3 scripts/compare_extractors.py
    python3 scripts/compare_extractors.py --photos tests/real_photos --ground-truth tests/real_photos/ground_truth.json

What it does:
    1. Finds every image in --photos.
    2. Instantiates whichever extractors have an API key available
       (Tesseract always runs -- it's local and free; Gemini/Claude run
       only if GEMINI_API_KEY / ANTHROPIC_API_KEY are set).
    3. Runs each available extractor on each image, through the SAME
       parser everyone downstream uses (parse_ingredient_list).
    4. If a ground_truth.json is provided, computes precision/recall of
       the parsed ingredient list against your manually-transcribed
       "true" list for that photo.
    5. Prints a per-provider summary table and writes full results to
       results.json for closer inspection.
"""

import argparse
import json
import os
import sys
import time

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from extraction import parse_ingredient_list, ExtractionError
from extraction.tesseract_ocr import TesseractExtractor

IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp"}


def build_available_extractors():
    """Only instantiate extractors that can actually run right now.
    Missing an API key is not a crash -- it just skips that provider
    and tells you why.
    """
    extractors = {}
    extractors["tesseract"] = TesseractExtractor()

    try:
        from extraction.gemini_vision import GeminiVisionExtractor
        extractors["gemini"] = GeminiVisionExtractor()
    except ExtractionError as e:
        print(f"[skip] Gemini extractor not available: {e}")
    except ImportError:
        print("[skip] Gemini extractor not available: google-genai not installed")


    return extractors


def score_against_ground_truth(predicted, truth):
    """Case-insensitive set comparison -- simple and transparent on purpose."""
    pred_set = {p.strip().lower() for p in predicted if p.strip()}
    truth_set = {t.strip().lower() for t in truth if t.strip()}

    if not truth_set:
        return {"precision": None, "recall": None, "matched": 0, "truth_count": 0}

    matched = pred_set & truth_set
    precision = len(matched) / len(pred_set) if pred_set else 0.0
    recall = len(matched) / len(truth_set)
    return {
        "precision": round(precision, 2),
        "recall": round(recall, 2),
        "matched": len(matched),
        "truth_count": len(truth_set),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--photos", default=os.path.join(os.path.dirname(__file__), "..", "tests", "real_photos"))
    parser.add_argument("--ground-truth", default=None)
    parser.add_argument("--out", default=os.path.join(os.path.dirname(__file__), "..", "tests", "results.json"))
    args = parser.parse_args()

    photos_dir = os.path.abspath(args.photos)
    if not os.path.isdir(photos_dir):
        print(f"No photos directory at {photos_dir}. Create it and drop your test images in.")
        return

    images = sorted(f for f in os.listdir(photos_dir) if os.path.splitext(f)[1].lower() in IMAGE_EXTS)
    if not images:
        print(f"No images found in {photos_dir}. Supported: {sorted(IMAGE_EXTS)}")
        return

    ground_truth = {}
    if args.ground_truth and os.path.exists(args.ground_truth):
        with open(args.ground_truth) as f:
            ground_truth = json.load(f)
    elif args.ground_truth:
        print(f"Ground truth file not found at {args.ground_truth}, continuing without accuracy scoring.")

    extractors = build_available_extractors()
    print(f"\nRunning {len(extractors)} extractor(s) on {len(images)} image(s): {list(extractors.keys())}\n")

    results = {}
    tallies = {name: {"count": 0, "no_list_found": 0, "errors": 0, "precisions": [], "recalls": [], "latencies": []}
               for name in extractors}

    for image_name in images:
        image_path = os.path.join(photos_dir, image_name)
        results[image_name] = {}
        print(f"--- {image_name} ---")

        for name, extractor in extractors.items():
            tallies[name]["count"] += 1
            t0 = time.time()
            try:
                extraction = extractor.extract(image_path)
                elapsed = time.time() - t0
                tallies[name]["latencies"].append(elapsed)

                parsed = parse_ingredient_list(extraction.raw_text)
                if not parsed:
                    tallies[name]["no_list_found"] += 1

                entry = {
                    "raw_text": extraction.raw_text,
                    "parsed": parsed,
                    "confidence": extraction.confidence,
                    "latency_sec": round(elapsed, 2),
                }

                if image_name in ground_truth:
                    score = score_against_ground_truth(parsed, ground_truth[image_name])
                    entry["score"] = score
                    if score["precision"] is not None:
                        tallies[name]["precisions"].append(score["precision"])
                        tallies[name]["recalls"].append(score["recall"])

                results[image_name][name] = entry
                print(f"  [{name}] {len(parsed)} ingredients, confidence={extraction.confidence}, "
                      f"{elapsed:.1f}s" + (f", precision={entry.get('score', {}).get('precision')}"
                                           if "score" in entry else ""))

            except ExtractionError as e:
                tallies[name]["errors"] += 1
                results[image_name][name] = {"error": str(e)}
                print(f"  [{name}] ERROR: {e}")

        print()

    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    for name, t in tallies.items():
        avg_precision = round(sum(t["precisions"]) / len(t["precisions"]), 2) if t["precisions"] else "n/a"
        avg_recall = round(sum(t["recalls"]) / len(t["recalls"]), 2) if t["recalls"] else "n/a"
        avg_latency = round(sum(t["latencies"]) / len(t["latencies"]), 2) if t["latencies"] else "n/a"
        print(f"{name:12s}  images={t['count']:3d}  errors={t['errors']:2d}  "
              f"no_list_found={t['no_list_found']:2d}  avg_precision={avg_precision}  "
              f"avg_recall={avg_recall}  avg_latency={avg_latency}s")

    if not ground_truth:
        print("\n(No ground_truth.json provided -- precision/recall not computed.)")

    with open(args.out, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\nFull results written to {args.out}")


if __name__ == "__main__":
    main()