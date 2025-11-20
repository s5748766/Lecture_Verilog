// SWITCH Testbench for Xcelsium (Verilog-1995)
// Tests mode switching between Manual and CPU modes

`timescale 1ns/1ps

module tb_switch;

    // Inputs
    reg mode;
    reg [7:0] manual_a, manual_b;
    reg [2:0] manual_opcode;
    reg [7:0] cpu_a, cpu_b;
    reg [2:0] cpu_opcode;

    // Outputs
    wire [7:0] select_a, select_b;
    wire [2:0] select_opcode;

    // Instantiate the SWITCH
    SWITCH uut (
        .mode(mode),
        .manual_a(manual_a),
        .manual_b(manual_b),
        .manual_opcode(manual_opcode),
        .cpu_a(cpu_a),
        .cpu_b(cpu_b),
        .cpu_opcode(cpu_opcode),
        .select_a(select_a),
        .select_b(select_b),
        .select_opcode(select_opcode)
    );

    // Test procedure
    initial begin
        // Initialize VCD dump
        $dumpfile("switch_wave.vcd");
        $dumpvars(0, tb_switch);

        // Display header
        $display("========================================");
        $display("SWITCH Testbench");
        $display("Mode 0 = Manual, Mode 1 = CPU");
        $display("========================================");
        $display("Time\t Mode\t Manual_A Manual_B M_Op\t CPU_A\t CPU_B\t C_Op\t Sel_A\t Sel_B\t S_Op");
        $display("--------------------------------------------------------------------------------------------");

        // Initialize inputs
        mode = 0;
        manual_a = 8'd0;
        manual_b = 8'd0;
        manual_opcode = 3'b000;
        cpu_a = 8'd0;
        cpu_b = 8'd0;
        cpu_opcode = 3'b000;
        #10;

        // Test Manual Mode (mode = 0)
        $display("\n--- Testing Manual Mode (mode=0) ---");
        
        mode = 0;
        manual_a = 8'd10;
        manual_b = 8'd5;
        manual_opcode = 3'b000; // ADD
        cpu_a = 8'd100;
        cpu_b = 8'd50;
        cpu_opcode = 3'b001; // SUB
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t Manual ADD", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        manual_a = 8'd20;
        manual_b = 8'd3;
        manual_opcode = 3'b010; // MUL
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t Manual MUL", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        manual_a = 8'd15;
        manual_b = 8'd7;
        manual_opcode = 3'b001; // SUB
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t Manual SUB", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        // Test CPU Mode (mode = 1)
        $display("\n--- Testing CPU Mode (mode=1) ---");
        
        mode = 1;
        manual_a = 8'd99;
        manual_b = 8'd88;
        manual_opcode = 3'b111; // Should be ignored
        cpu_a = 8'd40;
        cpu_b = 8'd8;
        cpu_opcode = 3'b011; // DIV
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t CPU DIV", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        cpu_a = 8'd25;
        cpu_b = 8'd25;
        cpu_opcode = 3'b101; // EQ
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t CPU EQ", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        cpu_a = 8'd60;
        cpu_b = 8'd30;
        cpu_opcode = 3'b110; // GT
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t CPU GT", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        // Test Mode Switching
        $display("\n--- Testing Mode Switching ---");
        
        mode = 0;
        manual_a = 8'd50;
        manual_b = 8'd25;
        manual_opcode = 3'b000; // ADD
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t Switch to Manual", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        mode = 1;
        cpu_a = 8'd80;
        cpu_b = 8'd20;
        cpu_opcode = 3'b010; // MUL
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t Switch to CPU", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        mode = 0;
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t Switch to Manual", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        // Test with all zeros
        $display("\n--- Testing Edge Cases ---");
        
        mode = 0;
        manual_a = 8'd0;
        manual_b = 8'd0;
        manual_opcode = 3'b000;
        cpu_a = 8'd0;
        cpu_b = 8'd0;
        cpu_opcode = 3'b000;
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t All zeros Manual", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        mode = 1;
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t All zeros CPU", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        // Test with maximum values
        mode = 0;
        manual_a = 8'd255;
        manual_b = 8'd255;
        manual_opcode = 3'b111;
        cpu_a = 8'd255;
        cpu_b = 8'd255;
        cpu_opcode = 3'b111;
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t Max values Manual", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        mode = 1;
        #10;
        $display("%0t\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t %d\t %d\t %b\t Max values CPU", 
                 $time, mode, manual_a, manual_b, manual_opcode, cpu_a, cpu_b, cpu_opcode, 
                 select_a, select_b, select_opcode);

        // End simulation
        $display("\n========================================");
        $display("SWITCH Testbench Complete");
        $display("========================================");
        #10;
        $finish;
    end

endmodule
