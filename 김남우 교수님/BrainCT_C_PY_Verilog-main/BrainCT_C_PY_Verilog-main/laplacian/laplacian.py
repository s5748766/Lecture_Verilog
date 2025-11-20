
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

def laplacian4(a):
    pad = np.pad(a, ((1,1),(1,1)), mode='edge').astype(np.int32)
    out = (4*pad[1:H+1,1:W+1]
           - pad[1:H+1,0:W] - pad[1:H+1,2:W+2]
           - pad[0:H,1:W+1] - pad[2:H+2,1:W+1])
    out = out + 128
    return clamp8(out)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="input", default="brainct_001.bmp")  # ← dest 지정
    ap.add_argument("--outdir", default=".")
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    g = load_bmp_to_gray(args.input)  # ← 수정됨
    o = laplacian4(g)

    save_bmp_gray(os.path.join(args.outdir, "output_grayscale-py.bmp"), g)
    save_bmp_gray(os.path.join(args.outdir, "output_laplacian-py.bmp"), o)
    save_mem(os.path.join(args.outdir, "output_laplacian-py.mem"), o)
    print("Done PY: laplacian")

if __name__=="__main__":
    main()
