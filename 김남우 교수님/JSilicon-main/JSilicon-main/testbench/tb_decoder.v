// DECODER Testbench for Xcelsium (Verilog-1995)
// Tests instruction decoder

`timescale 1ns/1ps

module tb_decoder;

    // Inputs
    reg clock;
    reg reset;
    reg ena;
    reg [7:0] instr_in;

    // Outputs
    wire [2:0] alu_opcode;
    wire [3:0] operand;
    wire reg_sel;
    wire alu_enable;
    wire write_enable;

    // Clock period (12 MHz = 83.33ns)
    parameter CLK_PERIOD = 83.33;

    // Instantiate the DECODER
    DECODER uut (
        .clock(clock),
        .reset(reset),
        .ena(ena),
        .instr_in(instr_in),
        .alu_opcode(alu_opcode),
        .operand(operand),
        .reg_sel(reg_sel),
        .alu_enable(alu_enable),
        .write_enable(write_enable)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end

    // Test procedure
    initial begin
        // Initialize VCD dump
        $dumpfile("decoder_wave.vcd");
        $dumpvars(0, tb_decoder);

        // Display header
        $display("========================================");
        $display("DECODER Testbench");
        $display("========================================");
        $display("Time\t Instr\t\t Opcode\t Operand\t Reg\t ALU_EN\t WR_EN\t Description");
        $display("------------------------------------------------------------------------------------");

        // Initialize inputs
        reset = 1;
        ena = 0;
        instr_in = 8'b00000000;
        #(CLK_PERIOD*5);

        // Release reset
        reset = 0;
        #(CLK_PERIOD*2);

        // Enable decoder
        ena = 1;
        #(CLK_PERIOD);

        // Test ADD instruction (000 + operand + reg_sel)
        $display("\n--- Testing ADD Instructions ---");
        instr_in = 8'b00000011; // ADD 3 to R0
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t ADD R0, 3", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        instr_in = 8'b00010101; // ADD 5 to R1
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t ADD R1, 5", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        // Test SUB instruction
        $display("\n--- Testing SUB Instructions ---");
        instr_in = 8'b00100010; // SUB 2 from R0
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t SUB R0, 2", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        instr_in = 8'b00110111; // SUB 7 from R1
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t SUB R1, 7", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        // Test MUL instruction
        $display("\n--- Testing MUL Instructions ---");
        instr_in = 8'b01000101; // MUL R0 by 5
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t MUL R0, 5", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        instr_in = 8'b01011010; // MUL R1 by 10
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t MUL R1, 10", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        // Test DIV instruction
        $display("\n--- Testing DIV Instructions ---");
        instr_in = 8'b01100100; // DIV R0 by 4
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t DIV R0, 4", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        // Test MOD instruction
        $display("\n--- Testing MOD Instructions ---");
        instr_in = 8'b10000111; // MOD R0 by 7
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t MOD R0, 7", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        // Test CMP instruction (no write)
        $display("\n--- Testing CMP Instruction (no write_enable) ---");
        instr_in = 8'b10100101; // CMP with 5
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t CMP 5 (no write)", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        // Test NOP instruction
        $display("\n--- Testing NOP Instruction ---");
        instr_in = 8'b11100000; // Undefined opcode (acts as NOP)
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t NOP/Undefined", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        // Test enable control
        $display("\n--- Testing Enable Control (ena=0) ---");
        ena = 0;
        instr_in = 8'b00000111; // ADD 7
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t ENA=0 (no decode)", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        // Re-enable
        ena = 1;
        #(CLK_PERIOD);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t ENA=1 (decode resumed)", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);

        // Test reset
        $display("\n--- Testing Reset ---");
        reset = 1;
        #(CLK_PERIOD*2);
        #1 $display("%0t\t 8'b%b\t %b\t %d\t\t %d\t %b\t %b\t RESET", 
                    $time, instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);
        
        reset = 0;
        #(CLK_PERIOD*2);

        // End simulation
        $display("\n========================================");
        $display("DECODER Testbench Complete");
        $display("========================================");
        #(CLK_PERIOD*5);
        $finish;
    end

endmodule
