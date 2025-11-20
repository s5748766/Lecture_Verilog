
# LoG (Laplacian of Gaussian) Filter Pack — C / Python / Verilog + Testbench

- **Input**: `brainct_001.bmp` (630×630, 24bpp)
- **Kernel**: 5×5 LoG (σ≈1) integer approximation, **zero-sum** with **+128 bias** for visualization  
  \[
  K=\begin{bmatrix}
  0 & 0 & -1 & 0 & 0\\
  0 & -1 & -2 & -1 & 0\\
  -1 & -2 & 16 & -2 & -1\\
  0 & -1 & -2 & -1 & 0\\
  0 & 0 & -1 & 0 & 0
  \end{bmatrix},\quad
  O=\operatorname{clip}(I*K + 128, 0..255)
  \]
- **Border**: replicate (edge padding)
- **Math**: pure integers, identical across C / Python / Verilog

## Outputs
- C: `output_grayscale-c.bmp`, `output_log-c.bmp`, `output_log-c.mem`
- Python: `output_grayscale-py.bmp`, `output_log-py.bmp`, `output_log-py.mem`
- Verilog (ModelSim 10.1): `output_log-vlog.bmp`, `output_log-vlog.mem`

**MEM format**: uppercase hex + CRLF per line (`XX\r\n`), 630×630 lines → 1,984,500B.

## Build / Run

### C (Windows / Visual Studio)
```
cl /O2 /Fe:log.exe log.c
log.exe --in brainct_001.bmp --outdir .
```

### Python
```
pip install pillow numpy
python log.py --in brainct_001.bmp --outdir .
```

### Verilog (ModelSim 10.1)
Place `input_image.mem` (630×630 lines, `XX\r\n`) **two levels up** from `verilog/`.
```
cd verilog/log
vlib work
vlog ../common/bmp_write_tasks.vh
vlog log_frame.v
vlog log_tb.v
vsim -c work.log_tb -do "run -all; quit"
```
Outputs will be written to `../../`.
