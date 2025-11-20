# Median Filter Pack (C / Python / Verilog + TB)

- Input: `brainct_001.bmp` (630×630, 24bpp)
- Output:
  - C: `output_grayscale-c.bmp`, `output_median-c.bmp`, `output_median-c.mem`
  - Python: `output_grayscale-py.bmp`, `output_median-py.bmp`, `output_median-py.mem`
  - Verilog: `output_median-vlog.bmp`, `output_median-vlog.mem`

## C (Visual Studio)
```
cl /O2 /Fe:median.exe median.c
median.exe --in brainct_001.bmp --outdir .
```

## Python
```
pip install pillow numpy
python median.py --in brainct_001.bmp --outdir .
```

## Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/`.
```
cd verilog/median
vlib work
vlog ../common/bmp_write_tasks.vh
vlog median_frame.v
vlog median_tb.v
vsim -c work.median_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
