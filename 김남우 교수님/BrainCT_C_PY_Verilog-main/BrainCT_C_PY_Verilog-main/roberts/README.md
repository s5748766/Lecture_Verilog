# Roberts Filter Pack (C / Python / Verilog + TB)

- Input: `brainct_001.bmp` (630×630, 24bpp)
- Output:
  - C: `output_grayscale-c.bmp`, `output_roberts-c.bmp`, `output_roberts-c.mem`
  - Python: `output_grayscale-py.bmp`, `output_roberts-py.bmp`, `output_roberts-py.mem`
  - Verilog: `output_roberts-vlog.bmp`, `output_roberts-vlog.mem`

## Operator
**Roberts Cross (2×2)** with replicate border and **L1 magnitude**:
- gx = I(x,y) − I(x+1,y+1)
- gy = I(x+1,y) − I(x,y+1)
- mag = clamp(|gx| + |gy|, 0..255)

> L1 magnitude (|gx|+|gy|) is used across C/Python/Verilog for deterministic matching (no sqrt).

## C (Visual Studio)
```
cl /O2 /Fe:roberts.exe roberts.c
roberts.exe --in brainct_001.bmp --outdir .
```

## Python
```
pip install pillow numpy
python roberts.py --in brainct_001.bmp --outdir .
```

## Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/`.
```
cd verilog/roberts
vlib work
vlog ../common/bmp_write_tasks.vh
vlog roberts_frame.v
vlog roberts_tb.v
vsim -c work.roberts_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
