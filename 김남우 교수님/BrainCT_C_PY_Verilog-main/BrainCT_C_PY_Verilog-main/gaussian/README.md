# Gaussian Filter Pack (C / Python / Verilog + TB)

- Input: `brainct_001.bmp` (630×630, 24bpp)
- Output:
  - C: `output_gaussian-c.bmp`, `output_gaussian-c.mem`
  - Python: `output_gaussian-py.bmp`, `output_gaussian-py.mem`
  - Verilog: `output_gaussian-vlog.bmp`, `output_gaussian-vlog.mem`

## C (Visual Studio)
```
cl /O2 /Fe:gaussian.exe gaussian.c
gaussian.exe --in brainct_001.bmp --outdir .
```

## Python
```
pip install pillow numpy
python gaussian.py --in brainct_001.bmp --outdir .
```

## Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/` (i.e., alongside outputs).
```
cd verilog/gaussian
vlib work
vlog ../common/bmp_write_tasks.vh
vlog gaussian_frame.v
vlog gaussian_tb.v
vsim -c work.gaussian_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
