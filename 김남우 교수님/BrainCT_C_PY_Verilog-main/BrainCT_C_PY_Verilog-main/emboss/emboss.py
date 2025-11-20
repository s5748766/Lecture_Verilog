
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

def emboss3(a):
    p = np.pad(a, ((1,1),(1,1)), mode='edge').astype(np.int32)
    s = ( -2*p[0:H,0:W] + -1*p[0:H,1:W+1] + 0*p[0:H,2:W+2]
        +  -1*p[1:H+1,0:W] + 1*p[1:H+1,1:W+1] + 1*p[1:H+1,2:W+2]
        +   0*p[2:H+2,0:W] + 1*p[2:H+2,1:W+1] + 2*p[2:H+2,2:W+2] )
    s = s + 128
    s = np.clip(s,0,255).astype(np.uint8)
    return s

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="input", default="brainct_001.bmp")
    ap.add_argument("--outdir", default=".")
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    g = load_bmp_to_gray(args.input)
    o = emboss3(g)

    save_bmp_gray(os.path.join(args.outdir, "output_grayscale-py.bmp"), g)
    save_bmp_gray(os.path.join(args.outdir, "output_emboss-py.bmp"), o)
    save_mem(os.path.join(args.outdir, "output_emboss-py.mem"), o)
    print("Done PY: emboss")

if __name__=="__main__":
    main()
