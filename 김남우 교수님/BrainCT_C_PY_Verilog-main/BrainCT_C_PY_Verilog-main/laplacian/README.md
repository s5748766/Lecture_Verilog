# Laplacian Filter Pack (C / Python / Verilog + TB)

- Input: `brainct_001.bmp` (630×630, 24bpp)
- Output:
  - C: `output_grayscale-c.bmp`, `output_laplacian-c.bmp`, `output_laplacian-c.mem`
  - Python: `output_grayscale-py.bmp`, `output_laplacian-py.bmp`, `output_laplacian-py.mem`
  - Verilog: `output_laplacian-vlog.bmp`, `output_laplacian-vlog.mem`

## Notes
- Kernel: 3×3 4-neighbor Laplacian  
  \[ K = \begin{bmatrix} 0 & -1 & 0 \\ -1 & 4 & -1 \\ 0 & -1 & 0 \end{bmatrix} \]
- Visualization bias: **+128** (i.e., `dst = clamp(src ⊗ K + 128)`), to map negative responses into [0,255].
- Border handling: **replicate**.

## C (Visual Studio)
```
cl /O2 /Fe:laplacian.exe laplacian.c
laplacian.exe --in brainct_001.bmp --outdir .
```

## Python
```
pip install pillow numpy
python laplacian.py --in brainct_001.bmp --outdir .
```

## Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/`.
```
cd verilog/laplacian
vlib work
vlog ../common/bmp_write_tasks.vh
vlog laplacian_frame.v
vlog laplacian_tb.v
vsim -c work.laplacian_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
