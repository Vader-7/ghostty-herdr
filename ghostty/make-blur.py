import sys, os
from PIL import Image, ImageFilter, ImageEnhance

# usage: make-blur.py <image> [radius]   ->  writes <image>-blur.<ext> next to it
p = sys.argv[1]
radius = int(sys.argv[2]) if len(sys.argv) > 2 else 26
im = Image.open(p).convert("RGB").filter(ImageFilter.GaussianBlur(radius))
im = ImageEnhance.Brightness(im).enhance(0.82)
base, ext = os.path.splitext(p)
im.save(base + "-blur" + ext, quality=92)
print(f"  blurred version written (radius {radius}): {base}-blur{ext}")
