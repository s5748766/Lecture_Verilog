
# Motion Blur Filter Pack (C / Python / Verilog + TB)

- Input: `brainct_001.bmp` (630×630, 24bpp)
- Output:
  - C: `output_grayscale-c.bmp`, `output_motionblur-c.bmp`, `output_motionblur-c.mem`
  - Python: `output_grayscale-py.bmp`, `output_motionblur-py.bmp`, `output_motionblur-py.mem`
  - Verilog: `output_motionblur-vlog.bmp`, `output_motionblur-vlog.mem`

## Operator
**Horizontal Motion Blur (length=9, uniform weights)** with replicate border, integer arithmetic:
\[
K = \frac{1}{9}[1,1,1,1,1,1,1,1,1],\quad
O(x,y) = \left\lfloor \frac{1}{9} \sum_{k=-4}^{4} I(x+k,y) \right\rfloor
\]
- Division is integer truncation (no rounding), matching C/Python/Verilog.
- Outputs are clipped to 0..255 (not strictly needed for averages, but kept for safety/consistency).

All three implementations share the same math and boundary policy.

## C (Visual Studio)
```
cl /O2 /Fe:motionblur.exe motionblur.c
motionblur.exe --in brainct_001.bmp --outdir .
```

## Python
```
pip install pillow numpy
python motionblur.py --in brainct_001.bmp --outdir .
```

## Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/`.
```
cd verilog/motionblur
vlib work
vlog ../common/bmp_write_tasks.vh
vlog motionblur_frame.v
vlog motionblur_tb.v
vsim -c work.motionblur_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
