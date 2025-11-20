
# High-pass Filter Pack (C / Python / Verilog + TB)

- Input: `brainct_001.bmp` (630×630, 24bpp)
- Output:
  - C: `output_grayscale-c.bmp`, `output_highpass-c.bmp`, `output_highpass-c.mem`
  - Python: `output_grayscale-py.bmp`, `output_highpass-py.bmp`, `output_highpass-py.mem`
  - Verilog: `output_highpass-vlog.bmp`, `output_highpass-vlog.mem`

## Operator
**3×3 High-pass** with replicate border, no bias:
\[
K = \begin{bmatrix}
-1 & -1 & -1\\
-1 &  8 & -1\\
-1 & -1 & -1
\end{bmatrix},\quad
O = \operatorname{clip}( I * K, 0..255 )
\]

All three implementations (C/Python/Verilog) use identical integer math and boundary policy.

## C (Visual Studio)
```
cl /O2 /Fe:highpass.exe highpass.c
highpass.exe --in brainct_001.bmp --outdir .
```

## Python
```
pip install pillow numpy
python highpass.py --in brainct_001.bmp --outdir .
```

## Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/`.
```
cd verilog/highpass
vlib work
vlog ../common/bmp_write_tasks.vh
vlog highpass_frame.v
vlog highpass_tb.v
vsim -c work.highpass_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
