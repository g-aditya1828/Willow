"""
Image Preprocessing pipeline for food packaging OCR.
Solves common real-world Indian food packaging hurdles:
- Crinkled wrappers & glare from metallic foils (Haldiram's, chips, biscuits)
- EXIF camera rotation from mobile photo uploads
- Low-contrast printed typography
- Uneven shadows
"""

import numpy as np
from PIL import Image, ImageOps, ImageEnhance, ImageFilter


def fix_exif_orientation(image: Image.Image) -> Image.Image:
    """Correct camera rotation stored in mobile EXIF metadata."""
    try:
        return ImageOps.exif_transpose(image)
    except Exception:
        return image


def enhance_for_ocr(image: Image.Image) -> Image.Image:
    """
    Applies multi-step enhancement:
    1. EXIF orientation fix
    2. Convert to grayscale
    3. Auto-contrast stretching
    4. Sharpness boost for small packaging font
    5. Slight noise median filter
    """
    img = fix_exif_orientation(image)
    gray = img.convert("L")

    # Auto-contrast to maximize dynamic range
    contrasted = ImageOps.autocontrast(gray, cutoff=2)

    # Enhance sharpness for tiny printed ingredients
    sharpener = ImageEnhance.Sharpness(contrasted)
    sharpened = sharpener.enhance(2.0)

    # Contrast boost
    enhancer = ImageEnhance.Contrast(sharpened)
    boosted = enhancer.enhance(1.6)

    return boosted


def otsu_binarize(image: Image.Image) -> Image.Image:
    """
    Computes Otsu's threshold on grayscale image using NumPy to separate
    high-contrast text from shiny foil / textured background.
    """
    gray = enhance_for_ocr(image)
    arr = np.array(gray)

    # Histogram of pixel intensities
    hist, bin_edges = np.histogram(arr, bins=256, range=(0, 256))
    total_pixels = arr.size
    current_max, optimal_thresh = 0.0, 128

    sum_total = np.dot(np.arange(256), hist)
    weight_bg, sum_bg = 0, 0

    for t in range(256):
        weight_bg += hist[t]
        if weight_bg == 0:
            continue
        weight_fg = total_pixels - weight_bg
        if weight_fg == 0:
            break

        sum_bg += t * hist[t]
        mean_bg = sum_bg / weight_bg
        mean_fg = (sum_total - sum_bg) / weight_fg

        # Between-class variance
        between_var = weight_bg * weight_fg * ((mean_bg - mean_fg) ** 2)

        if between_var > current_max:
            current_max = between_var
            optimal_thresh = t

    # Binarize with optimal threshold
    binary_arr = np.where(arr > optimal_thresh, 255, 0).astype(np.uint8)
    return Image.fromarray(binary_arr)
