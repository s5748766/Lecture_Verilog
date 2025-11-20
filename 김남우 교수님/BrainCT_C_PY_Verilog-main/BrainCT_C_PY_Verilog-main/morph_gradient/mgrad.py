
import os, argparse
from PIL import Image
import numpy as np

W,H=630,630

def save_bmp_gray(path, arr):
    Image.fromarray(arr.astype(np.uint8), mode='L').save(path)

def save_mem(path, arr):
    with open(path, "wb") as f:
        for v in arr.reshape(-1):
            f.write(f"{int(v):02X}\r\n".encode("ascii"))

def load_bmp_to_gray(path):
    im = Image.open(path).convert('L').resize((W,H))
    return np.array(im, dtype=np.uint8)

def dilate3x3(a):
    p = np.pad(a, ((1,1),(1,1)), mode='edge').astype(np.uint8)
    out = np.zeros_like(a, dtype=np.uint8)
    for dy in range(3):
        for dx in range(3):
            out = np.maximum(out, p[dy:dy+H, dx:dx+W])
    return out

def erode3x3(a):
    p = np.pad(a, ((1,1),(1,1)), mode='edge').astype(np.uint8)
    out = np.full_like(a, 255, dtype=np.uint8)
    for dy in range(3):
        for dx in range(3):
            out = np.minimum(out, p[dy:dy+H, dx:dx+W])
    return out

def morph_gradient(a):
    d = dilate3x3(a)
    e = erode3x3(a)
    return np.clip(d.astype(np.int16)-e.astype(np.int16), 0, 255).astype(np.uint8)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="input", default="brainct_001.bmp")  # ← dest 지정
    ap.add_argument("--outdir", default=".")
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    g = load_bmp_to_gray(args.input)  # ← 수정됨
    o = morph_gradient(g)

    save_bmp_gray(os.path.join(args.outdir, "output_grayscale-py.bmp"), g)
    save_bmp_gray(os.path.join(args.outdir, "output_mgrad-py.bmp"), o)
    save_mem(os.path.join(args.outdir, "output_mgrad-py.mem"), o)
    print("Done PY: Morphological Gradient")

if __name__=="__main__":
    main()
