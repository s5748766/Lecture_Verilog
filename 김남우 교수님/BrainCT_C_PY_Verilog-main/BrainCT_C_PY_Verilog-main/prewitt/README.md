# Prewitt Filter Pack (C / Python / Verilog + TB)

- Input: `brainct_001.bmp` (630×630, 24bpp)
- Output:
  - C: `output_grayscale-c.bmp`, `output_prewitt-c.bmp`, `output_prewitt-c.mem`
  - Python: `output_grayscale-py.bmp`, `output_prewitt-py.bmp`, `output_prewitt-py.mem`
  - Verilog: `output_prewitt-vlog.bmp`, `output_prewitt-vlog.mem`

## Operator
3×3 Prewitt kernels (replicate border) with **L1 magnitude**:
- Gx = \[[-1,0,1],[-1,0,1],[-1,0,1]\]
- Gy = \[[ 1,1,1],[ 0,0,0],[-1,-1,-1]\]
- mag = clamp( |Gx| + |Gy|, 0..255 )

> Note: L1 magnitude (|Gx|+|Gy|) is used across C/Python/Verilog for deterministic matching (no sqrt).

## C (Visual Studio)
```
cl /O2 /Fe:prewitt.exe prewitt.c
prewitt.exe --in brainct_001.bmp --outdir .
```

## Python
```
pip install pillow numpy
python prewitt.py --in brainct_001.bmp --outdir .
```

## Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/`.
```
cd verilog/prewitt
vlib work
vlog ../common/bmp_write_tasks.vh
vlog prewitt_frame.v
vlog prewitt_tb.v
vsim -c work.prewitt_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
