// ALU Testbench for Xcelsium (Verilog-1995)
// Tests all 8 ALU operations

`timescale 1ns/1ps

module tb_alu;

    // Inputs
    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] opcode;
    reg ena;

    // Outputs
    wire [15:0] result;

    // Instantiate the ALU
    ALU uut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .ena(ena),
        .result(result)
    );

    // Test procedure
    initial begin
        // Initialize VCD dump
        $dumpfile("alu_wave.vcd");
        $dumpvars(0, tb_alu);

        // Display header
        $display("========================================");
        $display("ALU Testbench Start");
        $display("========================================");
        $display("Time\t Opcode\t A\t B\t Result\t Operation");
        $display("----------------------------------------");

        // Initialize inputs
        a = 8'd0;
        b = 8'd0;
        opcode = 3'b000;
        ena = 1'b0;
        #10;

        // Enable ALU
        ena = 1'b1;
        #10;

        // Test 000: Addition
        a = 8'd15;
        b = 8'd10;
        opcode = 3'b000;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t ADD", $time, opcode, a, b, result);

        // Test 001: Subtraction
        a = 8'd20;
        b = 8'd7;
        opcode = 3'b001;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t SUB", $time, opcode, a, b, result);

        // Test 010: Multiplication
        a = 8'd12;
        b = 8'd5;
        opcode = 3'b010;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t MUL", $time, opcode, a, b, result);

        // Test 011: Division
        a = 8'd100;
        b = 8'd7;
        opcode = 3'b011;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t DIV", $time, opcode, a, b, result);

        // Test 100: Modulo
        a = 8'd100;
        b = 8'd7;
        opcode = 3'b100;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t MOD", $time, opcode, a, b, result);

        // Test 101: Equal comparison (true)
        a = 8'd50;
        b = 8'd50;
        opcode = 3'b101;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t EQ (==)", $time, opcode, a, b, result);

        // Test 101: Equal comparison (false)
        a = 8'd50;
        b = 8'd30;
        opcode = 3'b101;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t EQ (==)", $time, opcode, a, b, result);

        // Test 110: Greater than (true)
        a = 8'd60;
        b = 8'd30;
        opcode = 3'b110;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t GT (>)", $time, opcode, a, b, result);

        // Test 110: Greater than (false)
        a = 8'd20;
        b = 8'd40;
        opcode = 3'b110;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t GT (>)", $time, opcode, a, b, result);

        // Test 111: Less than (true)
        a = 8'd25;
        b = 8'd50;
        opcode = 3'b111;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t LT (<)", $time, opcode, a, b, result);

        // Test 111: Less than (false)
        a = 8'd75;
        b = 8'd50;
        opcode = 3'b111;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t LT (<)", $time, opcode, a, b, result);

        // Test division by zero protection
        a = 8'd100;
        b = 8'd0;
        opcode = 3'b011;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t DIV by 0", $time, opcode, a, b, result);

        // Test modulo by zero protection
        a = 8'd100;
        b = 8'd0;
        opcode = 3'b100;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t MOD by 0", $time, opcode, a, b, result);

        // Test with enable disabled
        ena = 1'b0;
        a = 8'd50;
        b = 8'd30;
        opcode = 3'b000;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t ENA=0", $time, opcode, a, b, result);

        // End simulation
        #10;
        $display("========================================");
        $display("ALU Testbench Complete");
        $display("========================================");
        $finish;
    end

endmodule
