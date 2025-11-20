# Makefile for Xcelsium (Verilog-1995) Simulation
# Jsilicon Design Testbenches

# Compiler settings
XRUN = xrun
XRUNFLAGS = +v2k -access +rwc -clean -timescale 1ns/1ps

# Source files directory
SRC_DIR = ..
TB_DIR = .

# Design source files
ALU_SRC = $(SRC_DIR)/alu.v
UART_SRC = $(SRC_DIR)/uart.v
PC_SRC = $(SRC_DIR)/pc.v
INST_SRC = $(SRC_DIR)/inst.v
REG_SRC = $(SRC_DIR)/regfile.v
SWITCH_SRC = $(SRC_DIR)/switch.v
FSM_SRC = $(SRC_DIR)/fsm.v
TOP_SRC = $(SRC_DIR)/jsilicon.v

# Testbench files
TB_ALU = ../tb_alu.v
TB_UART = ../tb_uart.v
TB_PC = ../tb_pc.v
TB_DECODER = ../tb_decoder.v
TB_REG = ../tb_reg.v
TB_SWITCH = ../tb_switch.v
TB_FSM = ../tb_fsm.v
TB_TOP = ../tb_jsilicon_top.v

# Default target
all: help

help:
	@echo "=========================================="
	@echo "Jsilicon Testbench Simulation Makefile"
	@echo "=========================================="
	@echo "Available targets:"
	@echo "  make alu       - Simulate ALU module"
	@echo "  make uart      - Simulate UART module"
	@echo "  make pc        - Simulate PC module"
	@echo "  make decoder   - Simulate DECODER module"
	@echo "  make reg       - Simulate REG module"
	@echo "  make switch    - Simulate SWITCH module"
	@echo "  make fsm       - Simulate FSM module"
	@echo "  make top       - Simulate TOP module (full system)"
	@echo "  make all_tests - Run all testbenches"
	@echo "  make clean     - Clean simulation files"
	@echo "=========================================="

# Individual module simulations
alu:
	@echo "Running ALU testbench..."
	$(XRUN) $(XRUNFLAGS) $(ALU_SRC) $(TB_ALU)

uart:
	@echo "Running UART testbench..."
	$(XRUN) $(XRUNFLAGS) $(UART_SRC) $(TB_UART)

pc:
	@echo "Running PC testbench..."
	$(XRUN) $(XRUNFLAGS) $(PC_SRC) $(TB_PC)

decoder:
	@echo "Running DECODER testbench..."
	$(XRUN) $(XRUNFLAGS) $(INST_SRC) $(TB_DECODER)

reg:
	@echo "Running REG testbench..."
	$(XRUN) $(XRUNFLAGS) $(REG_SRC) $(TB_REG)

switch:
	@echo "Running SWITCH testbench..."
	$(XRUN) $(XRUNFLAGS) $(SWITCH_SRC) $(TB_SWITCH)

fsm:
	@echo "Running FSM testbench..."
	$(XRUN) $(XRUNFLAGS) $(ALU_SRC) $(UART_SRC) $(FSM_SRC) $(TB_FSM)

top:
	@echo "Running TOP module testbench..."
	$(XRUN) $(XRUNFLAGS) $(ALU_SRC) $(UART_SRC) $(PC_SRC) $(INST_SRC) \
	       $(REG_SRC) $(SWITCH_SRC) $(FSM_SRC) $(TOP_SRC) $(TB_TOP)

# Run all tests
all_tests: alu uart pc decoder reg switch fsm top
	@echo "=========================================="
	@echo "All testbenches completed!"
	@echo "=========================================="

# Clean targets
clean:
	@echo "Cleaning simulation files..."
	rm -rf *.log *.vcd *.key *.history
	rm -rf xcelium.d INCA_libs waves.shm
	@echo "Clean complete!"

.PHONY: all help alu uart pc decoder reg switch fsm top all_tests clean
