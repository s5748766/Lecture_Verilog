
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

def motionblur9(a):
    # pad 4 columns on both sides
    p = np.pad(a, ((0,0),(4,4)), mode='edge').astype(np.int32)
    s = ( p[:,0:W] + p[:,1:W+1] + p[:,2:W+2] + p[:,3:W+3] + p[:,4:W+4]
        +  p[:,5:W+5] + p[:,6:W+6] + p[:,7:W+7] + p[:,8:W+8] )
    s = (s // 9).clip(0,255).astype(np.uint8)  # integer truncation
    return s

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="input", default="brainct_001.bmp")  # ← dest 지정
    ap.add_argument("--outdir", default=".")
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    g = load_bmp_to_gray(args.input)  # ← 수정됨
    o = motionblur9(g)

    save_bmp_gray(os.path.join(args.outdir, "output_grayscale-py.bmp"), g)
    save_bmp_gray(os.path.join(args.outdir, "output_motionblur-py.bmp"), o)
    save_mem(os.path.join(args.outdir, "output_motionblur-py.mem"), o)
    print("Done PY: motion-blur")

if __name__=="__main__":
    main()
