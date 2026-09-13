import sys, os
from PIL import Image, ImageFilter, ImageEnhance

# uso: make-blur.py <imagen> [radio]   ->  guarda <imagen>-blur.<ext>
p = sys.argv[1]
radio = int(sys.argv[2]) if len(sys.argv) > 2 else 26
im = Image.open(p).convert("RGB").filter(ImageFilter.GaussianBlur(radio))
im = ImageEnhance.Brightness(im).enhance(0.82)
base, ext = os.path.splitext(p)
im.save(base + "-blur" + ext, quality=92)
print(f"  version difuminada regenerada (radio {radio})")
