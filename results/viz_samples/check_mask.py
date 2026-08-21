"""
Inspect and visualize a DAAAM masks_only PNG.

The file is 16-bit grayscale; each pixel's value is the semantic_id of the mask
it belongs to (0 = background). Values only span 0-18 on a 0-65535 scale, so the
raw file looks almost solid black in standard viewers -- that's expected, not
a corrupted file.

Usage:
    pip install pillow numpy matplotlib
    python3 check_mask.py <path_to_masks_only.png>
"""

import sys
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt

path = sys.argv[1] if len(sys.argv) > 1 else "grounding_images_masks_only_grounding_1673884386.611053_000000.png"

arr = np.array(Image.open(path))
print(f"dtype={arr.dtype}  shape={arr.shape}  unique semantic_ids={np.unique(arr)}")

plt.imshow(arr, cmap="tab10")
plt.colorbar(label="semantic_id")
plt.title("Mask visualization")
out = "mask_view.png"
plt.savefig(out)
print(f"saved -> {out}")
