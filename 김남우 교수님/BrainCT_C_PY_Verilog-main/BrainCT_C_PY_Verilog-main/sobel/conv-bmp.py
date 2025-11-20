# make_c_identical.py
# C 프로그램과 바이트 단위로 동일한 결과를 만드는 Python 스크립트
# - 입력:  brainct_001.bmp (24bit, 630x630)
# - 출력:  output_grayscale-py.bmp, output_edge-py.bmp
#         output_image-py.mem, output_edge-py.mem
# - BMP 저장: C와 동일하게 수동 작성 (팔레트/패딩/헤더)
# - MEM 저장: 한 픽셀당 "XX\r\r\n" (C의 텍스트 변환과 동일한 5바이트/픽셀)

import os
import struct
import math

# ------------ 설정 ------------
INPUT_BMP = "brainct_001.bmp"
OUT_GRAY_BMP = "output_grayscale-py.bmp"
OUT_EDGE_BMP = "output_edge-py.bmp"
OUT_GRAY_MEM = "output_image-py.mem"
OUT_EDGE_MEM = "output_edge-py.mem"

REF_GRAY_BMP = "output_grayscale-c.bmp"
REF_EDGE_BMP = "output_edge-c.bmp"
REF_GRAY_MEM = "output_image-c.mem"
REF_EDGE_MEM = "output_edge-c.mem"

W, H = 630, 630

# ------------ 유틸 ------------
def read_bmp_rgb24_bottom_up(path):
    with open(path, "rb") as f:
        bf = f.read(14)
        if len(bf) != 14:
            raise ValueError("파일헤더 읽기 실패")
        bfType, bfSize, bfReserved1, bfReserved2, bfOffBits = struct.unpack("<HIHHI", bf)
        if bfType != 0x4D42:  # 'BM'
            raise ValueError("BM 아님")

        bi = f.read(40)
        if len(bi) != 40:
            raise ValueError("정보헤더 읽기 실패")
        (biSize, biWidth, biHeight, biPlanes, biBitCount, biCompression,
         biSizeImage, biXPelsPerMeter, biYPelsPerMeter, biClrUsed, biClrImportant) = struct.unpack("<IIIHHIIIIII", bi)

        if biBitCount != 24:
            raise ValueError(f"24bit 아님: {biBitCount}")
        if not (biWidth == W and (biHeight == H or biHeight == -H)):
            raise ValueError(f"크기 불일치: 기대 {W}x{H}, 실제 {biWidth}x{biHeight}")

        top_down = (biHeight < 0)
        row_pad = (4 - ((W * 3) % 4)) % 4

        f.seek(bfOffBits, 0)

        # 메모리에는 top-down으로 보관
        rgb = [[(0,0,0)] * W for _ in range(H)]

        if top_down:
            for y in range(H):
                row = f.read(W*3)
                if len(row) != W*3:
                    raise ValueError("픽셀 읽기 실패")
                for x in range(W):
                    b = row[3*x+0]; g = row[3*x+1]; r = row[3*x+2]
                    rgb[y][x] = (r,g,b)
                if row_pad: f.read(row_pad)
        else:
            for row_idx in range(H):
                row = f.read(W*3)
                if len(row) != W*3:
                    raise ValueError("픽셀 읽기 실패")
                y = H - 1 - row_idx
                for x in range(W):
                    b = row[3*x+0]; g = row[3*x+1]; r = row[3*x+2]
                    rgb[y][x] = (r,g,b)
                if row_pad: f.read(row_pad)

    return rgb

def rgb_to_gray_trunc(r,g,b):
    # C의 (uint8_t)(0.299R + 0.587G + 0.114B)와 동일 - truncation
    y = 0.299*r + 0.587*g + 0.114*b
    yi = int(y)
    if yi < 0: yi = 0
    elif yi > 255: yi = 255
    return yi

def sobel_edge(gray):
    sx = [[-1,0,1],[-2,0,2],[-1,0,1]]
    sy = [[-1,-2,-1],[0,0,0],[1,2,1]]
    def gp(x,y):
        if x < 0: x = 0
        elif x >= W: x = W-1
        if y < 0: y = 0
        elif y >= H: y = H-1
        return gray[y][x]
    edge = [[0]*W for _ in range(H)]
    for y in range(H):
        for x in range(W):
            gx = 0; gy = 0
            for dy in (-1,0,1):
                for dx in (-1,0,1):
                    p = gp(x+dx, y+dy)
                    gx += p * sx[dy+1][dx+1]
                    gy += p * sy[dy+1][dx+1]
            mag = int(math.sqrt(gx*gx + gy*gy))
            if mag > 255: mag = 255
            edge[y][x] = mag
    return edge

def write_bmp_8bpp_like_c(path, img2d):
    # C와 동일: 8bpp 팔레트, bottom-up, 행 패딩
    row_pad = (4 - (W % 4)) % 4
    palette_size = 256*4
    bfOffBits = 14 + 40 + palette_size
    biSizeImage = (W + row_pad) * H
    bfSize = bfOffBits + biSizeImage
    with open(path, "wb") as f:
        # BITMAPFILEHEADER
        f.write(struct.pack("<HIHHI", 0x4D42, bfSize, 0, 0, bfOffBits))
        # BITMAPINFOHEADER
        f.write(struct.pack("<IIIHHIIIIII",
            40, W, H, 1, 8, 0, biSizeImage,
            2835, 2835, 256, 256  # 72 DPI, 팔레트 사용
        ))
        # 팔레트 (B,G,R,0)
        for i in range(256):
            f.write(bytes([i,i,i,0]))
        # 픽셀 bottom-up
        pad = b"\x00"*row_pad
        for y in range(H-1, -1, -1):
            f.write(bytes(img2d[y]))
            if row_pad:
                f.write(pad)

def write_mem_c_textmode_equivalent(path, flat_bytes):
    # C 텍스트 모드에서 "%02X\r\n" → 실제 파일에는 "XX\r\r\n" (5 bytes)
    with open(path, "wb") as f:
        for v in flat_bytes:
            hex2 = f"{v:02X}".encode("ascii")
            f.write(hex2 + b"\r\r\n")

def compare(f1, f2):
    if not os.path.exists(f1) or not os.path.exists(f2):
        missing = f1 if not os.path.exists(f1) else f2
        return f"⚠ 파일 없음: {missing}"
    s1, s2 = os.path.getsize(f1), os.path.getsize(f2)
    if s1 != s2:
        return f"❌ 크기 다름 (C:{s1:,}B  PY:{s2:,}B)"
    with open(f1, "rb") as a, open(f2, "rb") as b:
        same = (a.read() == b.read())
    return "✅ 동일" if same else "⚠ 크기만 동일, 내용 다름"

def main():
    # 0) 기존 py 결과 삭제
    for f in [OUT_GRAY_BMP, OUT_EDGE_BMP, OUT_GRAY_MEM, OUT_EDGE_MEM]:
        try: os.remove(f)
        except FileNotFoundError: pass

    print("0.기존 py 결과 삭제")
    
    # 1) 입력 읽기 (RGB24)
    rgb = read_bmp_rgb24_bottom_up(INPUT_BMP)

    print("1.입력 읽기 (RGB24)")

    # 2) 그레이스케일 (C와 동일 truncation)
    gray2d = [[0]*W for _ in range(H)]
    for y in range(H):
        for x in range(W):
            r,g,b = rgb[y][x]
            gray2d[y][x] = rgb_to_gray_trunc(r,g,b)
    
    print("2.그레이스케일 (C와 동일 truncation)")

    # 3) 소벨 엣지 (C와 동일 sqrt 방식)
    edge2d = sobel_edge(gray2d)

    print("3.소벨 엣지 (C와 동일 sqrt 방식)")

    # 4) BMP 저장 (C와 동일한 방식)
    write_bmp_8bpp_like_c(OUT_GRAY_BMP, gray2d)
    write_bmp_8bpp_like_c(OUT_EDGE_BMP, edge2d)

    print("4.BMP 저장 (C와 동일한 방식)")
    
    # 5) MEM 저장 (C 텍스트 모드 결과와 동일한 라인 엔딩: "XX\r\r\n")
    gray_flat = [gray2d[y][x] for y in range(H) for x in range(W)]
    edge_flat = [edge2d[y][x] for y in range(H) for x in range(W)]
    write_mem_c_textmode_equivalent(OUT_GRAY_MEM, gray_flat)
    write_mem_c_textmode_equivalent(OUT_EDGE_MEM, edge_flat)

    print("5.BMP 저장 (C와 동일한 방식)")

    # 6) 요약 및 비교
    print()
    print("6.요약 및 비교")
    print(f"그레이스케일 BMP 파일: {OUT_GRAY_BMP}")
    print(f"엣지 검출 BMP 파일: {OUT_EDGE_BMP}")
    print(f"그레이스케일 MEM 파일: {OUT_GRAY_MEM}")
    print(f"엣지 검출 MEM 파일: {OUT_EDGE_MEM}")
    print("모든 파일이 성공적으로 생성되었습니다.\n")

    print("[결과 파일 비교 (C ↔ PY)]")
    print(f"{os.path.basename(REF_GRAY_BMP):25s} ↔ {os.path.basename(OUT_GRAY_BMP):25s} → {compare(REF_GRAY_BMP, OUT_GRAY_BMP)}")
    print(f"{os.path.basename(REF_EDGE_BMP):25s} ↔ {os.path.basename(OUT_EDGE_BMP):25s} → {compare(REF_EDGE_BMP, OUT_EDGE_BMP)}")
    print(f"{os.path.basename(REF_GRAY_MEM):25s} ↔ {os.path.basename(OUT_GRAY_MEM):25s} → {compare(REF_GRAY_MEM, OUT_GRAY_MEM)}")
    print(f"{os.path.basename(REF_EDGE_MEM):25s} ↔ {os.path.basename(OUT_EDGE_MEM):25s} → {compare(REF_EDGE_MEM, OUT_EDGE_MEM)}")

if __name__ == "__main__":
    main()
