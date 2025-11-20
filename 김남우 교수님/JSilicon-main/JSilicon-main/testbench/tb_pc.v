// PC (Program Counter + ROM) Testbench for Xcelsium (Verilog-1995)
// Tests program counter and ROM instruction fetch

`timescale 1ns/1ps

module tb_pc;

    // Inputs
    reg clock;
    reg reset;
    reg ena;

    // Outputs
    wire [7:0] instr_out;

    // Clock period (12 MHz = 83.33ns)
    parameter CLK_PERIOD = 83.33;

    // Instantiate the PC
    PC uut (
        .clock(clock),
        .reset(reset),
        .ena(ena),
        .instr_out(instr_out)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end

    // Test procedure
    initial begin
        // Initialize VCD dump
        $dumpfile("pc_wave.vcd");
        $dumpvars(0, tb_pc);

        // Display header
        $display("========================================");
        $display("PC (Program Counter + ROM) Testbench");
        $display("========================================");
        $display("Time\t PC\t Instruction\t Opcode\t Operand\t Description");
        $display("------------------------------------------------------------------------");

        // Initialize inputs
        reset = 1;
        ena = 0;
        #(CLK_PERIOD*5);

        // Release reset
        reset = 0;
        #(CLK_PERIOD*5);

        // Enable PC
        ena = 1;
        #(CLK_PERIOD*2);

        // Run through one complete cycle (4 instructions)
        repeat(4) begin
            #(CLK_PERIOD);
            $display("%0t\t %d\t 8'b%b\t %b\t %b\t\t %s", 
                     $time, 
                     uut.pc, 
                     instr_out, 
                     instr_out[7:5],
                     instr_out[3:0],
                     decode_instruction(instr_out));
        end

        // Run one more cycle to verify wrap-around
        $display("\n--- Testing PC wrap-around ---");
        repeat(4) begin
            #(CLK_PERIOD);
            $display("%0t\t %d\t 8'b%b\t %b\t %b\t\t %s", 
                     $time, 
                     uut.pc, 
                     instr_out, 
                     instr_out[7:5],
                     instr_out[3:0],
                     decode_instruction(instr_out));
        end

        // Test enable control
        $display("\n--- Testing Enable Control (ena=0) ---");
        ena = 0;
        #(CLK_PERIOD*5);
        $display("%0t\t %d\t 8'b%b\t %b\t %b\t\t ENA=0 (PC should not change)", 
                 $time, uut.pc, instr_out, instr_out[7:5], instr_out[3:0]);

        // Re-enable
        ena = 1;
        #(CLK_PERIOD);
        $display("%0t\t %d\t 8'b%b\t %b\t %b\t\t ENA=1 (PC resumed)", 
                 $time, uut.pc, instr_out, instr_out[7:5], instr_out[3:0]);

        // Test reset during operation
        $display("\n--- Testing Reset during operation ---");
        #(CLK_PERIOD*2);
        reset = 1;
        #(CLK_PERIOD*2);
        $display("%0t\t %d\t 8'b%b\t %b\t %b\t\t RESET (PC should go to 0)", 
                 $time, uut.pc, instr_out, instr_out[7:5], instr_out[3:0]);
        
        reset = 0;
        #(CLK_PERIOD*2);

        // End simulation
        $display("\n========================================");
        $display("PC Testbench Complete");
        $display("========================================");
        #(CLK_PERIOD*5);
        $finish;
    end

    // Function to decode instruction
    function [255:0] decode_instruction;
        input [7:0] instr;
        reg [2:0] opcode;
        reg [3:0] operand;
        begin
            opcode = instr[7:5];
            operand = instr[3:0];
            
            case(opcode)
                3'b000: decode_instruction = "ADD";
                3'b001: decode_instruction = "SUB";
                3'b010: decode_instruction = "MUL";
                3'b011: decode_instruction = "DIV";
                3'b100: decode_instruction = "MOD";
                3'b101: decode_instruction = "CMP";
                3'b110: decode_instruction = "GT";
                3'b111: decode_instruction = "LT";
                default: decode_instruction = "UNKNOWN";
            endcase
        end
    endfunction

endmodule
