
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

def blur3_gauss(a):
    p = np.pad(a, ((1,1),(1,1)), mode='edge').astype(np.int32)
    s = ( 1*p[0:H,0:W] + 2*p[0:H,1:W+1] + 1*p[0:H,2:W+2]
        + 2*p[1:H+1,0:W] + 4*p[1:H+1,1:W+1] + 2*p[1:H+1,2:W+2]
        + 1*p[2:H+2,0:W] + 2*p[2:H+2,1:W+1] + 1*p[2:H+2,2:W+2] )
    blr = ((s + 8) >> 4).astype(np.uint8)
    return blr

def unsharp(a):
    blr = blur3_gauss(a)
    mask = (a.astype(np.int16) - blr.astype(np.int16))
    out  = a.astype(np.int16) + mask  # alpha=1.0
    out  = np.clip(out, 0, 255).astype(np.uint8)
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="input", default="brainct_001.bmp")  # ← dest 지정
    ap.add_argument("--outdir", default=".")
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    g = load_bmp_to_gray(args.input)  # ← 수정됨
    o = unsharp(g)

    save_bmp_gray(os.path.join(args.outdir, "output_grayscale-py.bmp"), g)
    save_bmp_gray(os.path.join(args.outdir, "output_unsharp-py.bmp"), o)
    save_mem(os.path.join(args.outdir, "output_unsharp-py.mem"), o)
    print("Done PY: unsharp")

if __name__=="__main__":
    main()
