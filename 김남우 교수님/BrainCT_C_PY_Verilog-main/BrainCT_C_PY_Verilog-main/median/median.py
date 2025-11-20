
import os, argparse
from PIL import Image
import numpy as np

W,H=630,630

def clamp8(a): return np.clip(a,0,255).astype(np.uint8)

def load_bmp_to_gray(path):
    im = Image.open(path).convert('L').resize((W,H))
    return np.array(im, dtype=np.uint8)

def save_bmp_gray(path, arr):
    Image.fromarray(arr, mode='L').save(path)

def save_mem(path, arr):
    with open(path, "wb") as f:
        for v in arr.reshape(-1):
            f.write(f"{int(v):02X}\r\n".encode("ascii"))

def median3(a):
    pad = np.pad(a, ((1,1),(1,1)), mode='edge')
    out = np.empty_like(a)
    for y in range(H):
        for x in range(W):
            w = pad[y:y+3, x:x+3].reshape(-1)
            # nth element median (simple sort for 9 elems)
            w_sorted = np.sort(w, kind='quicksort')
            out[y,x] = w_sorted[4]
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="input", default="brainct_001.bmp")  # ← dest 지정
    ap.add_argument("--outdir", default=".")
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    g = load_bmp_to_gray(args.input)  # ← 수정됨
    o = median3(g)

    save_bmp_gray(os.path.join(args.outdir, "output_grayscale-py.bmp"), g)
    save_bmp_gray(os.path.join(args.outdir, "output_median-py.bmp"), o)
    save_mem(os.path.join(args.outdir, "output_median-py.mem"), o)
    print("Done PY: median")

if __name__=="__main__":
    main()
