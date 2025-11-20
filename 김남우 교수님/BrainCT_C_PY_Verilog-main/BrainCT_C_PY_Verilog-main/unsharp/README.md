# Unsharp Mask Filter Pack (C / Python / Verilog + TB)

- Input: `brainct_001.bmp` (630×630, 24bpp)
- Output:
  - C: `output_grayscale-c.bmp`, `output_unsharp-c.bmp`, `output_unsharp-c.mem`
  - Python: `output_grayscale-py.bmp`, `output_unsharp-py.bmp`, `output_unsharp-py.mem`
  - Verilog: `output_unsharp-vlog.bmp`, `output_unsharp-vlog.mem`

## Operator
**Unsharp Mask** with replicate border:
- Blur: 3×3 Gaussian-like kernel \(K = \frac{1}{16}\begin{bmatrix}1&2&1\\2&4&2\\1&2&1\end{bmatrix}\)
- Mask: \(M = I - (I * K)\)
- Sharpen: \(O = \operatorname{clip}( I + \alpha M, 0..255 )\), here **\(\alpha = 1.0\)**

All three implementations (C/Python/Verilog) use identical integer math:
- Blur = `(sum + 8) >> 4` (round-to-nearest)
- `alpha = 1.0` (can be generalized if needed)

## C (Visual Studio)
```
cl /O2 /Fe:unsharp.exe unsharp.c
unsharp.exe --in brainct_001.bmp --outdir .
```

## Python
```
pip install pillow numpy
python unsharp.py --in brainct_001.bmp --outdir .
```

## Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/`.
```
cd verilog/unsharp
vlib work
vlog ../common/bmp_write_tasks.vh
vlog unsharp_frame.v
vlog unsharp_tb.v
vsim -c work.unsharp_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
