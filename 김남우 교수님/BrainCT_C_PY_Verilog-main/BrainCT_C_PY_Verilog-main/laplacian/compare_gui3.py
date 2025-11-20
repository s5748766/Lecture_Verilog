# compare_gui.py
# - 폴더 내 결과 이미지들(BMP/PNG) 비교 + 원본 brainct_001.bmp와의 비교 프리셋 지원
# - 좌/우 파일 선택, 차영상(diff) 보기, 슬라이더 블렌딩, MSE/PSNR/MAE/MaxDiff/%Diff 표시
# - 하단 로그 패널에 비교 결과 자동 기록 + Save Log 지원
#
# 사용:
#   python compare_gui.py
#   python compare_gui.py "<이미지들이 있는 폴더>"
#
# 필요한 패키지: Pillow, numpy
#   pip install pillow numpy

import os
import sys
import glob
import math
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from PIL import Image, ImageTk
import numpy as np
from datetime import datetime

W, H = 630, 630  # 비교 시 내부 기준 해상도
ORIG_NAME_CANDIDATES = ["brainct_001.bmp", "brainct_001.jpg", "brainct_001.png"]

def find_base_dir():
    # 항상 실행한 폴더 기준
    if len(sys.argv) >= 2 and sys.argv[1].strip():
        return sys.argv[1]
    return os.getcwd()

def find_original_path(base_dir):
    for n in ORIG_NAME_CANDIDATES:
        p = os.path.join(base_dir, n)
        if os.path.exists(p):
            return p
    return None

def list_images(base_dir):
    pats = ["*.bmp", "*.png", "*.jpg", "*.jpeg"]
    files = []
    for p in pats:
        files.extend(glob.glob(os.path.join(base_dir, p)))
    return sorted(set(files), key=lambda x: (0 if os.path.basename(x) in ORIG_NAME_CANDIDATES else 1, x.lower()))

def load_gray_630(path):
    img = Image.open(path).convert("L").resize((W, H))
    return img

def pil_to_np(img):
    return np.array(img, dtype=np.uint8)

def mse(a, b):
    a = a.astype(np.float32); b = b.astype(np.float32)
    d = a - b
    return float(np.mean(d * d))

def mae(a, b):
    a = a.astype(np.float32); b = b.astype(np.float32)
    return float(np.mean(np.abs(a - b)))

def psnr(a, b):
    m = mse(a, b)
    if m <= 1e-12:
        return float("inf")
    return 20.0 * math.log10(255.0) - 10.0 * math.log10(m)

def max_abs_diff(a, b):
    return int(np.max(np.abs(a.astype(np.int16) - b.astype(np.int16))))

def percent_diff_pixels(a, b, thresh=0):
    # thresh=0 이면 한 픽셀이라도 다르면 카운트
    d = np.abs(a.astype(np.int16) - b.astype(np.int16))
    return float(np.count_nonzero(d > thresh)) * 100.0 / d.size

def make_diff_img(a, b):
    d = np.abs(a.astype(np.int16) - b.astype(np.int16)).astype(np.uint8)
    return Image.fromarray(d, mode="L")

def blend_imgs(a_img, b_img, alpha):
    a = np.array(a_img, dtype=np.float32)
    b = np.array(b_img, dtype=np.float32)
    out = (alpha * a + (1.0 - alpha) * b)
    out = np.clip(out, 0, 255).astype(np.uint8)
    return Image.fromarray(out, mode="L")

class App(tk.Tk):
    def __init__(self, base_dir):
        super().__init__()
        self.title("Image Compare (with Log)")
        self.geometry("1280x880")

        self.base_dir = base_dir
        self.img_paths = list_images(self.base_dir)
        if not self.img_paths:
            messagebox.showerror("Error", f"이미지 파일이 없습니다: {self.base_dir}")
            self.destroy()
            return

        self.orig_path = find_original_path(self.base_dir)

        # 상단: 폴더/프리셋/파일 선택
        top = ttk.Frame(self)
        top.pack(side=tk.TOP, fill=tk.X, padx=8, pady=6)

        ttk.Label(top, text="폴더:").pack(side=tk.LEFT)
        self.dir_var = tk.StringVar(value=self.base_dir)
        ttk.Entry(top, textvariable=self.dir_var, width=60).pack(side=tk.LEFT, padx=4)
        ttk.Button(top, text="열기...", command=self.choose_dir).pack(side=tk.LEFT, padx=4)
        ttk.Button(top, text="새로고침", command=self.reload_dir).pack(side=tk.LEFT, padx=4)

        ttk.Separator(self, orient="horizontal").pack(fill=tk.X, pady=4)

        preset = ttk.Frame(self)
        preset.pack(side=tk.TOP, fill=tk.X, padx=8, pady=4)

        self.preset_box = ttk.Combobox(preset, state="readonly", width=60, values=self.build_presets())
        self.preset_box.set("(프리셋 선택)")
        self.preset_box.pack(side=tk.LEFT, padx=4)
        ttk.Button(preset, text="프리셋 적용", command=self.apply_preset).pack(side=tk.LEFT, padx=4)

        ttk.Separator(self, orient="horizontal").pack(fill=tk.X, pady=4)

        # 선택 영역
        sel = ttk.Frame(self)
        sel.pack(side=tk.TOP, fill=tk.X, padx=8, pady=4)

        ttk.Label(sel, text="Left:").pack(side=tk.LEFT)
        self.left_box = ttk.Combobox(sel, state="readonly", width=45, values=[os.path.basename(p) for p in self.img_paths])
        self.left_box.pack(side=tk.LEFT, padx=4)

        ttk.Label(sel, text="Right:").pack(side=tk.LEFT)
        self.right_box = ttk.Combobox(sel, state="readonly", width=45, values=[os.path.basename(p) for p in self.img_paths])
        self.right_box.pack(side=tk.LEFT, padx=4)

        ttk.Button(sel, text="비교", command=self.update_view).pack(side=tk.LEFT, padx=8)

        # 중앙: 이미지 영역
        mid = ttk.Frame(self)
        mid.pack(side=tk.TOP, fill=tk.BOTH, expand=True, padx=8, pady=4)

        self.left_canvas  = tk.Canvas(mid, bg="#222", width=400, height=400)
        self.center_canvas= tk.Canvas(mid, bg="#222", width=400, height=400)
        self.right_canvas = tk.Canvas(mid, bg="#222", width=400, height=400)

        self.left_canvas.grid(row=0, column=0, sticky="nsew", padx=4, pady=4)
        self.center_canvas.grid(row=0, column=1, sticky="nsew", padx=4, pady=4)
        self.right_canvas.grid(row=0, column=2, sticky="nsew", padx=4, pady=4)

        mid.grid_columnconfigure(0, weight=1)
        mid.grid_columnconfigure(1, weight=1)
        mid.grid_columnconfigure(2, weight=1)
        mid.grid_rowconfigure(0, weight=1)

        # 하단: 블렌드/메트릭스 + 로그 패널
        bot = ttk.Frame(self)
        bot.pack(side=tk.TOP, fill=tk.X, padx=8, pady=6)

        ttk.Label(bot, text="블렌드(Left↔Right):").pack(side=tk.LEFT)
        self.blend_var = tk.DoubleVar(value=0.5)
        self.blend_scale = ttk.Scale(bot, from_=0.0, to=1.0, orient=tk.HORIZONTAL, variable=self.blend_var, command=self.on_blend)
        self.blend_scale.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=8)

        self.metrics_var = tk.StringVar(value="MSE: -, PSNR: - dB, MAE: -, Max: -, %Diff: -%")
        ttk.Label(bot, textvariable=self.metrics_var).pack(side=tk.RIGHT)

        # 로그 컨테이너
        logf = ttk.Frame(self)
        logf.pack(side=tk.BOTTOM, fill=tk.BOTH, expand=True, padx=8, pady=6)
        ttk.Label(logf, text="비교 로그").pack(anchor="w")

        self.log_text = tk.Text(logf, height=10, wrap="none")
        self.log_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        sy = ttk.Scrollbar(logf, orient="vertical", command=self.log_text.yview)
        sx = ttk.Scrollbar(logf, orient="horizontal", command=self.log_text.xview)
        self.log_text.configure(yscrollcommand=sy.set, xscrollcommand=sx.set)
        sy.pack(side=tk.RIGHT, fill=tk.Y)
        sx.pack(side=tk.BOTTOM, fill=tk.X)

        # 로그 버튼들
        logbtns = ttk.Frame(self)
        logbtns.pack(side=tk.BOTTOM, fill=tk.X, padx=8, pady=4)
        ttk.Button(logbtns, text="Save Log...", command=self.save_log).pack(side=tk.RIGHT, padx=4)
        self.autolog = tk.BooleanVar(value=True)
        ttk.Checkbutton(logbtns, text="Auto Log on Compare", variable=self.autolog).pack(side=tk.RIGHT)

        # 기본 선택
        if self.orig_path:
            self.left_box.set(os.path.basename(self.orig_path))
            if len(self.img_paths) >= 2:
                self.right_box.set(os.path.basename(self.img_paths[1]))
        else:
            self.left_box.set(os.path.basename(self.img_paths[0]))
            if len(self.img_paths) >= 2:
                self.right_box.set(os.path.basename(self.img_paths[1]))

        self._tk_left = None
        self._tk_center = None
        self._tk_right = None

        self.update_view()

    def build_presets(self):
        presets = ["(프리셋 선택)"]
        if self.orig_path:
            orig = os.path.basename(self.orig_path)
            names = [os.path.basename(p) for p in self.img_paths if os.path.basename(p) != orig]
            def group(prefix):
                return [n for n in names if prefix in n]
            groups = {
                "Original vs Grayscale (C/PY/VLOG)": group("output_grayscale-"),
                "Original vs Edge (C/PY/VLOG)":      group("output_edge-"),
                "Original vs Bilateral":             group("output_bilateral-"),
                "Original vs LoG":                   group("output_log-"),
                "Original vs MGrad":                 group("output_mgrad-"),
                "Original vs Emboss":                group("output_emboss-"),
                "Original vs Highpass":              group("output_highpass-"),
                "Original vs MotionBlur":            group("output_motion-"),
                "Original vs Prewitt":               group("output_prewitt-"),
                "Original vs Roberts":               group("output_roberts-"),
                "Original vs Laplacian":             group("output_laplacian-"),
                "Original vs Gaussian":              group("output_gaussian-"),
                "Original vs Median":                group("output_median-"),
            }
            for title, lst in groups.items():
                for n in sorted(lst):
                    presets.append(f"{title} :: {n}")
        return presets

    def apply_preset(self):
        s = self.preset_box.get()
        if s.strip() == "(프리셋 선택)":
            return
        if self.orig_path is None:
            messagebox.showinfo("Info", "원본 파일(brainct_001.bmp 등)을 찾지 못했습니다.")
            return
        orig = os.path.basename(self.orig_path)
        if "::" in s:
            _, fname = s.split("::", 1)
            fname = fname.strip()
            if fname in [os.path.basename(p) for p in self.img_paths]:
                self.left_box.set(orig)
                self.right_box.set(fname)
                self.update_view()

    def choose_dir(self):
        d = filedialog.askdirectory(initialdir=self.base_dir)
        if d:
            self.dir_var.set(d)
            self.reload_dir()

    def reload_dir(self):
        d = self.dir_var.get().strip()
        if not d or not os.path.isdir(d):
            messagebox.showerror("Error", f"폴더가 올바르지 않습니다: {d}")
            return
        self.base_dir = d
        self.img_paths = list_images(self.base_dir)
        self.orig_path = find_original_path(self.base_dir)

        values = [os.path.basename(p) for p in self.img_paths]
        self.left_box["values"]  = values
        self.right_box["values"] = values
        self.preset_box["values"]= self.build_presets()
        self.preset_box.set("(프리셋 선택)")

        if not self.img_paths:
            messagebox.showerror("Error", f"이미지 파일이 없습니다: {self.base_dir}")
            return

        if self.orig_path:
            self.left_box.set(os.path.basename(self.orig_path))
            if len(self.img_paths) >= 2:
                self.right_box.set(os.path.basename(self.img_paths[1]))
        else:
            self.left_box.set(os.path.basename(self.img_paths[0]))
            if len(self.img_paths) >= 2:
                self.right_box.set(os.path.basename(self.img_paths[1]))

        self.update_view()

    def update_view(self):
        left_name = self.left_box.get()
        right_name = self.right_box.get()
        if not left_name or not right_name:
            return
        left_path = os.path.join(self.base_dir, left_name)
        right_path = os.path.join(self.base_dir, right_name)
        if not (os.path.exists(left_path) and os.path.exists(right_path)):
            return

        L_img = load_gray_630(left_path)
        R_img = load_gray_630(right_path)
        L_np = pil_to_np(L_img)
        R_np = pil_to_np(R_img)

        # diff & blend
        D_img = make_diff_img(L_np, R_np)
        alpha = float(self.blend_var.get())
        B_img = blend_imgs(L_img, R_img, alpha)

        # metrics
        m  = mse(L_np, R_np)
        p  = psnr(L_np, R_np)
        a  = mae(L_np, R_np)
        mx = max_abs_diff(L_np, R_np)
        pd = percent_diff_pixels(L_np, R_np, thresh=0)
        p_str = "∞" if math.isinf(p) else f"{p:.2f}"
        self.metrics_var.set(f"MSE: {m:.2f}, PSNR: {p_str} dB, MAE: {a:.2f}, Max: {mx}, %Diff: {pd:.2f}%")

        # draw
        self._tk_left   = ImageTk.PhotoImage(L_img.resize((400, 400), Image.NEAREST))
        self._tk_center = ImageTk.PhotoImage(B_img.resize((400, 400), Image.NEAREST))
        self._tk_right  = ImageTk.PhotoImage(D_img.resize((400, 400), Image.NEAREST))

        self.left_canvas.delete("all");   self.left_canvas.create_image(200, 200, image=self._tk_left)
        self.center_canvas.delete("all"); self.center_canvas.create_image(200, 200, image=self._tk_center)
        self.right_canvas.delete("all");  self.right_canvas.create_image(200, 200, image=self._tk_right)

        self.left_canvas.create_text(10, 10, text=f"LEFT:  {left_name}",  anchor="nw", fill="white")
        self.center_canvas.create_text(10, 10, text=f"BLEND α={alpha:.2f}", anchor="nw", fill="white")
        self.right_canvas.create_text(10, 10, text="DIFF |L-R|",          anchor="nw", fill="white")

        if self.autolog.get():
            self.log_line(left_name, right_name, m, p_str, a, mx, pd)

    def on_blend(self, _evt=None):
        left_name = self.left_box.get()
        right_name = self.right_box.get()
        if not left_name or not right_name:
            return
        left_path = os.path.join(self.base_dir, left_name)
        right_path = os.path.join(self.base_dir, right_name)
        if not (os.path.exists(left_path) and os.path.exists(right_path)):
            return
        L_img = load_gray_630(left_path)
        R_img = load_gray_630(right_path)
        alpha = float(self.blend_var.get())
        B_img = blend_imgs(L_img, R_img, alpha)
        self._tk_center = ImageTk.PhotoImage(B_img.resize((400, 400), Image.NEAREST))
        self.center_canvas.delete("all")
        self.center_canvas.create_image(200, 200, image=self._tk_center)
        self.center_canvas.create_text(10, 10, text=f"BLEND α={alpha:.2f}", anchor="nw", fill="white")

    def log_line(self, left_name, right_name, mse_v, psnr_str, mae_v, maxdiff, pdiff):
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        line = (f"[{now}] {left_name}  vs  {right_name}  |  "
                f"MSE={mse_v:.2f}, PSNR={psnr_str} dB, MAE={mae_v:.2f}, "
                f"MaxDiff={maxdiff}, %Diff={pdiff:.2f}%\n")
        self.log_text.insert(tk.END, line)
        self.log_text.see(tk.END)

    def save_log(self):
        dflt = os.path.join(self.base_dir, "compare_log.txt")
        path = filedialog.asksaveasfilename(initialdir=self.base_dir, initialfile="compare_log.txt",
                                            defaultextension=".txt",
                                            filetypes=[("Text Files","*.txt"), ("All Files","*.*")])
        if not path:
            return
        try:
            with open(path, "w", encoding="utf-8") as f:
                f.write(self.log_text.get("1.0", tk.END))
            messagebox.showinfo("Saved", f"로그 저장 완료: {path}")
        except Exception as e:
            messagebox.showerror("Error", f"로그 저장 실패: {e}")

if __name__ == "__main__":
    base = find_base_dir()
    app = App(base)
    app.mainloop()
