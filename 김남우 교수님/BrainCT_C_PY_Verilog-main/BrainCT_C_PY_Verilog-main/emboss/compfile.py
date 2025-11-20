# compare_results.py
import os
import sys
import re
import hashlib
from typing import Tuple

# BMP 픽셀 비교용
try:
    from PIL import Image
    PIL_OK = True
except Exception:
    PIL_OK = False

import numpy as np

# ─────────────────────────────────────────────────────────────
# 기본 비교 폴더: 현재 compare_results.py가 있는 경로
# ─────────────────────────────────────────────────────────────
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_BASE_DIR = SCRIPT_DIR

FILES = {
    # BMP (C vs PY)
    "GRAY_BMP": {
        "C":  "brainct_001_gray-c.bmp",
        "PY": "brainct_001_gray-py.bmp",
    },
    "EMBOSS_BMP": {
        "C":  "brainct_001_emboss-c.bmp",
        "PY": "brainct_001_emboss-py.bmp",
        "V":  "brainct_001_emboss-verilog.bmp",  # 추가
    },
    # MEM (그레이 원본 값)
    "GRAY_MEM": {
        "C":  "brainct_001_gray-c.mem",
        "PY": "brainct_001_gray-py.mem",
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

    with open(path_a, "rb") as fa, open(path_b, "rb") as fb:
        while True:
            ba = fa.read(chunk)
            bb = fb.read(chunk)
            if not ba and not bb:
                break
            if ba != bb:
                return f"⚠ 크기만 동일, 내용 다름  ({human(size_a)} = {human(size_b)})"
    return "✅ 동일"

def print_sizes(title: str, base_dir: str, pair: dict):
    print(f"\n[{title} 파일 크기]")
    for tag, fname in pair.items():
        path = os.path.join(base_dir, fname)
        ok, _ = exists_or_msg(path)
        if ok:
            print(f"{fname:28s} : {human(sizeof(path))}")
        else:
            print(f"{fname:28s} : (없음)")

def sha16(path: str) -> str:
    if not os.path.exists(path):
        return "MISSING"
    return hashlib.sha256(open(path, "rb").read()).hexdigest()[:16]

# ─────────────────────────────────────────────────────────────
# BMP 픽셀 비교 (Pillow + NumPy)
# ─────────────────────────────────────────────────────────────
def bmp_pixel_compare_gray(path_a: str, path_b: str) -> str:
    """BMP를 열어 그레이(L)로 변환 후 픽셀 비교.
    결과: ✅ 동일, 또는 차이 통계(다른 픽셀 수, 최대/평균 절대차)."""
    if not PIL_OK:
        return "ℹ Pillow 미설치 → 픽셀 비교 생략"

    ok_a, msg_a = exists_or_msg(path_a)
    ok_b, msg_b = exists_or_msg(path_b)
    if not ok_a or not ok_b:
        missing = " / ".join(m for m in [msg_a, msg_b] if m)
        return f"❌ {missing}"

    try:
        a = Image.open(path_a).convert("L")
        b = Image.open(path_b).convert("L")
    except Exception as e:
        return f"❌ 이미지 열기 실패: {e}"

    if a.size != b.size:
        return f"❌ 해상도 다름 ({a.size} vs {b.size})"

    na = np.array(a, dtype=np.int16)
    nb = np.array(b, dtype=np.int16)
    diff = np.abs(na - nb)
    diffs = int((diff != 0).sum())

    if diffs == 0:
        return "✅ 픽셀 동일"

    maxd = int(diff.max())
    meand = float(diff.mean())
    return f"⚠ 픽셀 다름: count={diffs:,}, max={maxd}, mean={meand:.3f}"

def do_bmp_section(title: str, base_dir: str, pair: dict):
    # sizes
    print_sizes(title, base_dir, pair)

    # C vs PY
    a = os.path.join(base_dir, pair["C"])
    b = os.path.join(base_dir, pair["PY"])
    print(f"\n[{title} 바이트 비교]")
    print(f"{os.path.basename(a):28s} ↔ {os.path.basename(b):28s} → {compare_files(a, b)}")
    print(f"[{title} 픽셀 비교(L 변환)]")
    print(bmp_pixel_compare_gray(a, b))
    print(f"[{title} 해시(앞 16자)]")
    print(f"  {os.path.basename(a):28s}: {sha16(a)}")
    print(f"  {os.path.basename(b):28s}: {sha16(b)}")

def do_bmp_verilog_section(base_dir: str, pair: dict):
    """EMBOSS_BMP 전용: VERILOG 결과를 C, PY와 각각 비교"""
    if "V" not in pair:
        return
    v = os.path.join(base_dir, pair["V"])
    c = os.path.join(base_dir, pair["C"])
    p = os.path.join(base_dir, pair["PY"])

    print("\n[Emboss BMP (VERILOG) 파일 크기]")
    for fname in [pair["V"], pair["C"], pair["PY"]]:
        path = os.path.join(base_dir, fname)
        ok, _ = exists_or_msg(path)
        if ok:
            print(f"{fname:28s} : {human(sizeof(path))}")
        else:
            print(f"{fname:28s} : (없음)")

    print("\n[Emboss BMP (VERILOG vs C) 바이트 비교]")
    print(f"{os.path.basename(v):28s} ↔ {os.path.basename(c):28s} → {compare_files(v, c)}")
    print("[Emboss BMP (VERILOG vs C) 픽셀 비교(L 변환)]")
    print(bmp_pixel_compare_gray(v, c))
    print("[해시(앞 16자)]")
    print(f"  {os.path.basename(v):28s}: {sha16(v)}")
    print(f"  {os.path.basename(c):28s}: {sha16(c)}")

    print("\n[Emboss BMP (VERILOG vs PY) 바이트 비교]")
    print(f"{os.path.basename(v):28s} ↔ {os.path.basename(p):28s} → {compare_files(v, p)}")
    print("[Emboss BMP (VERILOG vs PY) 픽셀 비교(L 변환)]")
    print(bmp_pixel_compare_gray(v, p))
    print("[해시(앞 16자)]")
    print(f"  {os.path.basename(v):28s}: {sha16(v)}")
    print(f"  {os.path.basename(p):28s}: {sha16(p)}")

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

def mem_value_compare_two(path_a: str, path_b: str) -> str:
    va = load_mem_values(path_a)
    vb = load_mem_values(path_b)
    if va is None or vb is None:
        missing = []
        if va is None: missing.append(f"파일 없음: {path_a}")
        if vb is None: missing.append(f"파일 없음: {path_b}")
        return " / ".join(missing) if missing else "❌ 파일 없음"
    if len(va) != len(vb):
        return f"❌ 길이 상이 ({len(va)} vs {len(vb)})"
    equal = (va == vb)
    if equal:
        return "✅ 값 동일"
    # 간단한 차이 통계
    diff_cnt = sum(1 for i in range(len(va)) if va[i] != vb[i])
    return f"⚠ 값 다름 (서로 다른 항목 {diff_cnt:,}개)"

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

def mem_section_two(title: str, base_dir: str, pair: dict, normalize: bool):
    print_sizes(title, base_dir, pair)

    a = os.path.join(base_dir, pair["C"])
    b = os.path.join(base_dir, pair["PY"])

    print(f"\n[{title} 바이트 비교]")
    print(f"{os.path.basename(a):28s} ↔ {os.path.basename(b):28s} → {compare_files(a, b)}")

    print(f"[{title} 값 비교]")
    print(mem_value_compare_two(a, b))

    if normalize:
        print(f"\n[{title} 정규화(canonical) 생성 및 해시 비교]")
        a_out = os.path.join(base_dir, pair["C"].replace(".mem", OUT_SUFFIX))
        b_out = os.path.join(base_dir, pair["PY"].replace(".mem", OUT_SUFFIX))

        ok1 = write_canonical(a, a_out)
        ok2 = write_canonical(b, b_out)

        if ok1 and ok2:
            da, db = sha16(a_out), sha16(b_out)
            print(f"  SHA-256(16) {os.path.basename(a_out):25s}: {da}")
            print(f"  SHA-256(16) {os.path.basename(b_out):25s}: {db}")
            print("  정규화 바이트 비교:", "✅ 동일" if (da == db) else "⚠ 다름")

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

    # BMP 비교 (바이트 + 픽셀)
    do_bmp_section("Grayscale BMP", base_dir, FILES["GRAY_BMP"])
    do_bmp_section("Emboss BMP (C vs PY)", base_dir, FILES["EMBOSS_BMP"])

    # VERILOG 결과 비교 추가
    do_bmp_verilog_section(base_dir, FILES["EMBOSS_BMP"])

    # MEM 비교 (값 + 정규화 옵션)
    mem_section_two("Grayscale MEM", base_dir, FILES["GRAY_MEM"], normalize)

    print("\n완료.")

if __name__ == "__main__":
    main()
