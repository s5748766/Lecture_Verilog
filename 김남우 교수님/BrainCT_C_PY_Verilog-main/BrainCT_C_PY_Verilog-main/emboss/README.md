
# Emboss Filter Pack (C / Python / Verilog + TB)

- Input: `brainct_001.bmp` (630×630, 24bpp)
- Output:
  - C: `output_grayscale-c.bmp`, `output_emboss-c.bmp`, `output_emboss-c.mem`
  - Python: `output_grayscale-py.bmp`, `output_emboss-py.bmp`, `output_emboss-py.mem`
  - Verilog: `output_emboss-vlog.bmp`, `output_emboss-vlog.mem`

## Operator
**Emboss 3×3** with replicate border and bias 128:
\[
K = \begin{bmatrix}
-2 & -1 & 0\\
-1 &  1 & 1\\
 0 &  1 & 2
\end{bmatrix},\quad
O = \operatorname{clip}( (I * K) + 128, 0..255 )
\]

All three implementations (C/Python/Verilog) use identical integer math.

## C (Visual Studio)
```
cl /O2 /Fe:emboss.exe emboss.c
emboss.exe --in brainct_001.bmp --outdir .
```

## Python
```
pip install pillow numpy
python emboss.py --in brainct_001.bmp --outdir .
```

## Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/`.
```
cd verilog/emboss
vlib work
vlog ../common/bmp_write_tasks.vh
vlog emboss_frame.v
vlog emboss_tb.v
vsim -c work.emboss_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
