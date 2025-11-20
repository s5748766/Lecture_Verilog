# pip install pillow numpy

import os
import sys
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from PIL import Image, ImageTk
import numpy as np

# ------------------------------------------------------------
# 유틸: PSNR / MSE / MAE 등
# ------------------------------------------------------------
def mse(a, b):
    a = a.astype(np.float32)
    b = b.astype(np.float32)
    return float(np.mean((a - b) ** 2))

def mae(a, b):
    a = a.astype(np.float32)
    b = b.astype(np.float32)
    return float(np.mean(np.abs(a - b)))

def psnr(a, b, max_val=255.0):
    m = mse(a, b)
    if m == 0:
        return float('inf')
    return 10.0 * np.log10((max_val ** 2) / m)

def diff_metrics(a, b):
    # a,b: uint8 2D ndarray, same HxW
    diff = np.abs(a.astype(np.int16) - b.astype(np.int16))
    m = mse(a, b)
    a_mae = mae(a, b)
    p = psnr(a, b)
    maxd = int(diff.max()) if diff.size else 0
    diff_count = int(np.count_nonzero(diff))
    total = diff.size if diff.size else 1
    diff_ratio = diff_count / total
    identical = (diff_count == 0)
    return {
        "MSE": m,
        "MAE": a_mae,
        "PSNR": p,
        "MaxDiff": maxd,
        "DiffCount": diff_count,
        "Total": total,
        "DiffRatio": diff_ratio,
        "Identical": identical,
        "DiffArray": diff
    }

def load_gray_8bit_bmp(path):
    # BMP 8bpp 또는 팔레트/24bpp 등도 일단 L로 변환
    im = Image.open(path).convert('L')
    return im

def image_to_array(im):
    return np.array(im, dtype=np.uint8)

def array_to_image(arr):
    arr = np.clip(arr, 0, 255).astype(np.uint8)
    return Image.fromarray(arr, mode='L')

def colorize_diff_gray_to_red(diff_arr):
    # diff 0=검정, 클수록 밝은 빨강
    h, w = diff_arr.shape
    out = np.zeros((h, w, 3), dtype=np.uint8)
    out[..., 0] = diff_arr  # R채널
    # G/B는 0
    return Image.fromarray(out, mode='RGB')

# ------------------------------------------------------------
# GUI
# ------------------------------------------------------------
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_BASE_DIR = SCRIPT_DIR  # 예: C:\Users\Administrator\Desktop\sobel\chatgpt\01

PAIRS = [
    # (표시이름, 좌파일, 우파일)
    ("[GRAY]  C ↔ PY",   "output_grayscale-c.bmp", "output_grayscale-py.bmp"),
    ("[GRAY]  C ↔ VLOG", "output_grayscale-c.bmp", "output_grayscale-vlog.bmp"),
    ("[GRAY]  PY ↔ VLOG","output_grayscale-py.bmp","output_grayscale-vlog.bmp"),
    ("[EDGE]  C ↔ PY",   "output_edge-c.bmp",      "output_edge-py.bmp"),
    ("[EDGE]  C ↔ VLOG", "output_edge-c.bmp",      "output_edge-vlog.bmp"),
    ("[EDGE]  PY ↔ VLOG","output_edge-py.bmp",     "output_edge-vlog.bmp"),
]

class CompareApp(tk.Tk):
    def __init__(self, base_dir=None):
        super().__init__()
        self.title("BMP 비교 뷰어 (C / PY / VLOG)")
        self.geometry("1280x800")
        self.minsize(1000, 700)

        self.base_dir = base_dir or DEFAULT_BASE_DIR
        self.pairs = PAIRS
        self.current_pair_idx = 0
        self.scale_factor = tk.DoubleVar(value=4.0)  # diff 증강 배율
        self.color_mode = tk.StringVar(value="Gray") # Gray or Red

        # 상단 컨트롤
        top = ttk.Frame(self)
        top.pack(side=tk.TOP, fill=tk.X, padx=8, pady=6)

        ttk.Label(top, text="기준 폴더:").pack(side=tk.LEFT)
        self.base_dir_var = tk.StringVar(value=self.base_dir)
        self.base_entry = ttk.Entry(top, textvariable=self.base_dir_var, width=70)
        self.base_entry.pack(side=tk.LEFT, padx=4)
        ttk.Button(top, text="폴더 선택...", command=self.choose_folder).pack(side=tk.LEFT, padx=4)

        ttk.Label(top, text="비교쌍:").pack(side=tk.LEFT, padx=(12, 2))
        self.combo = ttk.Combobox(top, state="readonly", values=[p[0] for p in self.pairs], width=28)
        self.combo.current(0)
        self.combo.pack(side=tk.LEFT, padx=4)
        self.combo.bind("<<ComboboxSelected>>", lambda e: self.update_view())

        ttk.Label(top, text="Diff 배율:").pack(side=tk.LEFT, padx=(12, 2))
        self.scale = ttk.Scale(top, from_=1.0, to=16.0, variable=self.scale_factor, command=lambda e: self.update_view())
        self.scale.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=4)

        ttk.Label(top, text="표시:").pack(side=tk.LEFT, padx=(12, 2))
        self.color_combo = ttk.Combobox(top, state="readonly", values=["Gray", "Red"], width=8, textvariable=self.color_mode)
        self.color_combo.pack(side=tk.LEFT, padx=4)
        self.color_combo.bind("<<ComboboxSelected>>", lambda e: self.update_view())

        ttk.Button(top, text="차이 이미지 저장", command=self.save_diff_image).pack(side=tk.LEFT, padx=(12,4))

        # 중앙 3분할
        center = ttk.Frame(self)
        center.pack(side=tk.TOP, fill=tk.BOTH, expand=True, padx=8, pady=6)
        self.left_panel = ImagePanel(center, title="좌측 이미지")
        self.mid_panel  = ImagePanel(center, title="절대차(Abs Diff)")
        self.right_panel= ImagePanel(center, title="우측 이미지")
        self.left_panel.frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=4)
        self.mid_panel.frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=4)
        self.right_panel.frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=4)

        # 하단: 메트릭
        bottom = ttk.Frame(self)
        bottom.pack(side=tk.BOTTOM, fill=tk.X, padx=8, pady=6)
        self.metrics_text = tk.Text(bottom, height=6)
        self.metrics_text.pack(side=tk.LEFT, fill=tk.X, expand=True)
        self.metrics_text.configure(state=tk.DISABLED)

        # 키바인딩
        self.bind("<Left>", lambda e: self.prev_pair())
        self.bind("<Right>", lambda e: self.next_pair())

        # 초기 로드
        self.update_view()

    def choose_folder(self):
        d = filedialog.askdirectory(initialdir=self.base_dir_var.get() or DEFAULT_BASE_DIR)
        if d:
            self.base_dir_var.set(d)
            self.update_view()

    def get_current_paths(self):
        base = self.base_dir_var.get().strip()
        _, left_name, right_name = self.pairs[self.combo.current()]
        left = os.path.join(base, left_name)
        right = os.path.join(base, right_name)
        return left, right

    def update_view(self):
        left_path, right_path = self.get_current_paths()
        if not os.path.exists(left_path) or not os.path.exists(right_path):
            messagebox.showerror("파일 없음", f"다음 파일을 찾을 수 없습니다:\n{left_path}\n{right_path}")
            return

        # 로드
        left_img = load_gray_8bit_bmp(left_path)
        right_img= load_gray_8bit_bmp(right_path)

        # 크기 체크
        if left_img.size != right_img.size:
            messagebox.showerror("크기 불일치", f"이미지 크기가 다릅니다:\n{left_img.size} vs {right_img.size}")
            return

        a = image_to_array(left_img)   # uint8 HxW
        b = image_to_array(right_img)  # uint8 HxW

        # 메트릭
        dm = diff_metrics(a, b)

        # diff 이미지 생성 (abs diff 증강)
        scale = max(1.0, float(self.scale_factor.get()))
        diff = (dm["DiffArray"].astype(np.float32) * scale).clip(0, 255).astype(np.uint8)
        if self.color_mode.get() == "Red":
            diff_img = colorize_diff_gray_to_red(diff)
        else:
            diff_img = array_to_image(diff)

        # 표시용 리사이즈 (패널폭에 맞춰 자동 리사이즈)
        self.left_panel.set_image(left_img)
        self.right_panel.set_image(right_img)
        self.mid_panel.set_image(diff_img)

        # 메트릭 갱신
        identical = "✅ 동일" if dm["Identical"] else "⚠ 차이 있음"
        text = []
        text.append(f"비교쌍: {self.pairs[self.combo.current()][0]}")
        text.append(f"파일 A: {left_path}")
        text.append(f"파일 B: {right_path}")
        text.append("")
        text.append(f"결론: {identical}")
        text.append(f"MSE  : {dm['MSE']:.6f}")
        text.append(f"MAE  : {dm['MAE']:.6f}")
        text.append(f"PSNR : {'∞' if np.isinf(dm['PSNR']) else f'{dm['PSNR']:.4f} dB'}")
        text.append(f"MaxDiff : {dm['MaxDiff']}")
        text.append(f"Diff 수 : {dm['DiffCount']} / {dm['Total']}  ({dm['DiffRatio']*100:.6f} %)")
        text.append("")
        text.append(f"Diff 배율 : x{scale:.2f}   표시모드: {self.color_mode.get()}")

        self.metrics_text.configure(state=tk.NORMAL)
        self.metrics_text.delete("1.0", tk.END)
        self.metrics_text.insert(tk.END, "\n".join(text))
        self.metrics_text.configure(state=tk.DISABLED)

    def prev_pair(self):
        idx = self.combo.current()
        idx = (idx - 1) % len(self.pairs)
        self.combo.current(idx)
        self.update_view()

    def next_pair(self):
        idx = self.combo.current()
        idx = (idx + 1) % len(self.pairs)
        self.combo.current(idx)
        self.update_view()

    def save_diff_image(self):
        # 현재 diff 이미지를 다시 생성하여 저장
        left_path, right_path = self.get_current_paths()
        if not (os.path.exists(left_path) and os.path.exists(right_path)):
            return
        left_img = load_gray_8bit_bmp(left_path)
        right_img= load_gray_8bit_bmp(right_path)
        a = image_to_array(left_img)
        b = image_to_array(right_img)
        dm = diff_metrics(a, b)
        scale = max(1.0, float(self.scale_factor.get()))
        diff = (dm["DiffArray"].astype(np.float32) * scale).clip(0, 255).astype(np.uint8)
        if self.color_mode.get() == "Red":
            out_img = colorize_diff_gray_to_red(diff)
            default_ext = ".png"
        else:
            out_img = array_to_image(diff)
            default_ext = ".bmp"

        base = os.path.dirname(left_path)
        name = self.pairs[self.combo.current()][0].replace(" ", "_").replace("[", "").replace("]", "")
        default_name = f"diff_{name}{default_ext}"

        fpath = filedialog.asksaveasfilename(initialdir=base, initialfile=default_name,
                                             defaultextension=default_ext,
                                             filetypes=[("PNG", "*.png"), ("BMP", "*.bmp"), ("All Files", "*.*")])
        if fpath:
            try:
                out_img.save(fpath)
                messagebox.showinfo("저장 완료", f"저장됨:\n{fpath}")
            except Exception as e:
                messagebox.showerror("저장 실패", str(e))


class ImagePanel:
    def __init__(self, parent, title=""):
        self.frame = ttk.Frame(parent)
        self.title = ttk.Label(self.frame, text=title, font=("Segoe UI", 10, "bold"))
        self.title.pack(side=tk.TOP, anchor="w", padx=4, pady=2)
        self.canvas = tk.Canvas(self.frame, bg="#222222")
        self.canvas.pack(side=tk.TOP, fill=tk.BOTH, expand=True)

        self.img_obj = None
        self.tkimg = None
        self.src_img = None

        self.canvas.bind("<Configure>", self._on_resize)

    def set_image(self, pil_img):
        self.src_img = pil_img.copy()
        self._draw()

    def _on_resize(self, event):
        self._draw()

    def _draw(self):
        if self.src_img is None:
            return
        cw = self.canvas.winfo_width()
        ch = self.canvas.winfo_height()
        if cw < 10 or ch < 10:
            return
        # 원본 비율 유지 리사이즈
        w, h = self.src_img.size
        scale = min(cw / w, ch / h)
        rw = max(1, int(w * scale))
        rh = max(1, int(h * scale))
        img = self.src_img.resize((rw, rh), Image.NEAREST)
        self.tkimg = ImageTk.PhotoImage(img)
        self.canvas.delete("all")
        self.canvas.create_image(cw//2, ch//2, image=self.tkimg, anchor="center")


if __name__ == "__main__":
    base = sys.argv[1] if len(sys.argv) > 1 else None
    app = CompareApp(base)
    app.mainloop()
