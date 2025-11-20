
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

def log5(a):
    K = np.array([[ 0,  0, -1,  0,  0],
                  [ 0, -1, -2, -1,  0],
                  [-1, -2, 16, -2, -1],
                  [ 0, -1, -2, -1,  0],
                  [ 0,  0, -1,  0,  0]], dtype=np.int32)
    p = np.pad(a, ((2,2),(2,2)), mode='edge').astype(np.int32)
    s = np.zeros_like(a, dtype=np.int32)
    for dy in range(5):
        for dx in range(5):
            s += K[dy,dx] * p[dy:dy+H, dx:dx+W]
    s += 128  # bias for visualization
    return np.clip(s,0,255).astype(np.uint8)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="input", default="brainct_001.bmp")  # ← dest 지정
    ap.add_argument("--outdir", default=".")
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    g = load_bmp_to_gray(args.input)  # ← 수정됨
    o = log5(g)

    save_bmp_gray(os.path.join(args.outdir, "output_grayscale-py.bmp"), g)
    save_bmp_gray(os.path.join(args.outdir, "output_log-py.bmp"), o)
    save_mem(os.path.join(args.outdir, "output_log-py.mem"), o)
    print("Done PY: LoG")

if __name__=="__main__":
    main()
