
# Morphological Gradient Filter Pack — C / Python / Verilog + Testbench

- **Definition**: Morphological Gradient = Dilation - Erosion (on grayscale image)
- **SE (structuring element)**: 3×3 square
- **Border**: replicate (edge padding)
- **Math**: uint8 grayscale, dilation=max(3×3), erosion=min(3×3), gradient = max - min (0..255)

- **Input**: `brainct_001.bmp` (630×630, 24bpp)
- **Outputs**
  - C: `output_grayscale-c.bmp`, `output_mgrad-c.bmp`, `output_mgrad-c.mem`
  - Python: `output_grayscale-py.bmp`, `output_mgrad-py.bmp`, `output_mgrad-py.mem`
  - Verilog: `output_mgrad-vlog.bmp`, `output_mgrad-vlog.mem`

**MEM format**: uppercase hex + CRLF (`XX\r\n`), 630×630 lines → 1,984,500B.

## Build / Run

### C (Windows / Visual Studio)
```
cl /O2 /Fe:mgrad.exe mgrad.c
mgrad.exe --in brainct_001.bmp --outdir .
```

### Python
```
pip install pillow numpy
python mgrad.py --in brainct_001.bmp --outdir .
```

### Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/`.
```
cd verilog/mgrad
vlib work
vlog ../common/bmp_write_tasks.vh
vlog mgrad_frame.v
vlog mgrad_tb.v
vsim -c work.mgrad_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
