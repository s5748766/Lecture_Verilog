# compare_results.py
import os
import sys
import re
import hashlib
from typing import Tuple

# ─────────────────────────────────────────────────────────────
# 기본 비교 폴더: 현재 compare_results.py가 있는 경로
# ─────────────────────────────────────────────────────────────
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_BASE_DIR = SCRIPT_DIR  # 예: C:\Users\Administrator\Desktop\sobel\chatgpt\01

FILES = {
    # BMP
    "GRAY_BMP": {
        "C":    "output_grayscale-c.bmp",
        "PY":   "output_grayscale-py.bmp",
        "VLOG": "output_grayscale-vlog.bmp",
    },
    "EDGE_BMP": {
        "C":    "output_edge-c.bmp",
        "PY":   "output_edge-py.bmp",
        "VLOG": "output_edge-vlog.bmp",
    },
    # MEM
    "IMAGE_MEM": {
        "C":    "output_image-c.mem",
        "PY":   "output_image-py.mem",
        "VLOG": "output_image-vlog.mem",
    },
    "EDGE_MEM": {
        "C":    "output_edge-c.mem",
        "PY":   "output_edge-py.mem",
        "VLOG": "output_edge-vlog.mem",
    },
}

# ─────────────────────────────────────────────────────────────
# 공통 유틸
# ─────────────────────────────────────────────────────────────
def sizeof(path: str) -> int:
    return os.path.getsize(path)

def human(n: int) -> str:
    return f"{n:,}B"

def exists_or_msg(path: str) -> Tuple[bool, str]:
    if os.path.exists(path):
        return True, ""
    return False, f"파일 없음: {path}"

def compare_files(path_a: str, path_b: str, chunk: int = 1024 * 1024) -> str:
    """크기와 내용 비교. 같으면 '✅ 동일',
    크기만 같고 내용 다르면 '⚠ 크기만 동일, 내용 다름',
    크기도 다르면 '❌ 크기 다름 (A vs B)' 반환."""
    ok_a, msg_a = exists_or_msg(path_a)
    ok_b, msg_b = exists_or_msg(path_b)
    if not ok_a or not ok_b:
        missing = " / ".join(m for m in [msg_a, msg_b] if m)
        return f"❌ {missing}"

    size_a = sizeof(path_a)
    size_b = sizeof(path_b)
    if size_a != size_b:
        return f"❌ 크기 다름  ({human(size_a)} vs {human(size_b)})"

    # 크기가 같으면 바이트 비교
    with open(path_a, "rb") as fa, open(path_b, "rb") as fb:
        while True:
            ba = fa.read(chunk)
            bb = fb.read(chunk)
            if not ba and not bb:
                break
            if ba != bb:
                return f"⚠ 크기만 동일, 내용 다름  ({human(size_a)} = {human(size_b)})"
    return "✅ 동일"

def print_sizes(title: str, base_dir: str, triplet: dict):
    print(f"\n[{title} 파일 크기]")
    for tag, fname in triplet.items():
        path = os.path.join(base_dir, fname)
        ok, msg = exists_or_msg(path)
        if ok:
            print(f"{fname:28s} : {human(sizeof(path))}")
        else:
            print(f"{fname:28s} : (없음)")

def do_pairwise(title: str, base_dir: str, triplet: dict):
    a = os.path.join(base_dir, triplet["C"])
    b = os.path.join(base_dir, triplet["PY"])
    c = os.path.join(base_dir, triplet["VLOG"])

    def bn(p): return os.path.basename(p)

    print(f"\n[{title} 비교]")
    print(f"{bn(a):28s} ↔ {bn(b):28s} → {compare_files(a, b)}")
    print(f"{bn(a):28s} ↔ {bn(c):28s} → {compare_files(a, c)}")
    print(f"{bn(b):28s} ↔ {bn(c):28s} → {compare_files(b, c)}")

# ─────────────────────────────────────────────────────────────
# MEM 전용: 값 비교 + 정규화(옵션)
# ─────────────────────────────────────────────────────────────
UPPER_HEX   = True        # 정규화 시 대문자 HEX
LINE_ENDING = b"\r\r\n"   # 정규화 시 개행: CR CR LF (C에서 관찰된 패턴)
OUT_SUFFIX  = "-canon.mem"

def load_mem_values(path: str):
    """임의의 공백/개행/대소문자 허용, 2-hex 토큰을 모두 파싱해 값 리스트 반환."""
    if not os.path.exists(path):
        return None
    data = open(path, "rb").read()
    tokens = re.findall(rb"([0-9A-Fa-f]{2})", data)
    vals = [int(t, 16) for t in tokens]
    return vals

def mem_value_compare(paths) -> str:
    vals = [load_mem_values(p) for p in paths]
    if any(v is None for v in vals):
        return "❌ 파일 없음"
    if len(set(len(v) for v in vals)) != 1:
        return f"❌ 길이 상이 ({len(vals[0])}, {len(vals[1])}, {len(vals[2])})"
    equal = (vals[0] == vals[1] == vals[2])
    return "✅ 값 동일" if equal else "⚠ 값 다름"

def write_canonical(in_path: str, out_path: str) -> bool:
    vals = load_mem_values(in_path)
    if vals is None:
        print(f"  ❌ 파일 없음: {in_path}")
        return False
    with open(out_path, "wb") as f:
        for v in vals:
            hex2 = f"{v:02X}" if UPPER_HEX else f"{v:02x}"
            f.write(hex2.encode("ascii") + LINE_ENDING)
    return True

def sha16(path: str) -> str:
    if not os.path.exists(path):
        return "MISSING"
    return hashlib.sha256(open(path, "rb").read()).hexdigest()[:16]

def mem_section(title: str, base_dir: str, triplet: dict, normalize: bool):
    print_sizes(title, base_dir, triplet)

    a = os.path.join(base_dir, triplet["C"])
    b = os.path.join(base_dir, triplet["PY"])
    c = os.path.join(base_dir, triplet["VLOG"])

    def bn(p): return os.path.basename(p)
    print(f"\n[{title} 바이트 비교]")
    print(f"{bn(a):28s} ↔ {bn(b):28s} → {compare_files(a, b)}")
    print(f"{bn(a):28s} ↔ {bn(c):28s} → {compare_files(a, c)}")
    print(f"{bn(b):28s} ↔ {bn(c):28s} → {compare_files(b, c)}")

    print(f"\n[{title} 값 비교]")
    print("값 동등성(C, PY, VLOG):", mem_value_compare([a, b, c]))

    if normalize:
        print(f"\n[{title} 정규화(canonical) 생성 및 해시 비교]")
        a_out = os.path.join(base_dir, triplet["C"].replace(".mem", OUT_SUFFIX))
        b_out = os.path.join(base_dir, triplet["PY"].replace(".mem", OUT_SUFFIX))
        c_out = os.path.join(base_dir, triplet["VLOG"].replace(".mem", OUT_SUFFIX))

        ok1 = write_canonical(a, a_out)
        ok2 = write_canonical(b, b_out)
        ok3 = write_canonical(c, c_out)

        if ok1 and ok2 and ok3:
            da, db, dc = sha16(a_out), sha16(b_out), sha16(c_out)
            print(f"  SHA-256(16) {os.path.basename(a_out):25s}: {da}")
            print(f"  SHA-256(16) {os.path.basename(b_out):25s}: {db}")
            print(f"  SHA-256(16) {os.path.basename(c_out):25s}: {dc}")
            print("  정규화 바이트 비교:", "✅ 동일" if (da == db == dc) else "⚠ 다름")

# ─────────────────────────────────────────────────────────────
# main
# ─────────────────────────────────────────────────────────────
def main():
    args = [a for a in sys.argv[1:] if a.strip()]
    base_dir = DEFAULT_BASE_DIR
    normalize = False
    for a in args:
        if a.startswith("--"):
            if a == "--normalize":
                normalize = True
        else:
            base_dir = a

    print(f"비교 대상 폴더: {base_dir}\n")

    print_sizes("Grayscale BMP", base_dir, FILES["GRAY_BMP"])
    print_sizes("Edge BMP",      base_dir, FILES["EDGE_BMP"])
    do_pairwise("Grayscale BMP", base_dir, FILES["GRAY_BMP"])
    do_pairwise("Edge BMP",      base_dir, FILES["EDGE_BMP"])

    mem_section("Image MEM", base_dir, FILES["IMAGE_MEM"], normalize)
    mem_section("Edge MEM",  base_dir, FILES["EDGE_MEM"],  normalize)

    print("\n완료.")

if __name__ == "__main__":
    main()
