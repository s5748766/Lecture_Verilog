// REG (Register File) Testbench for Xcelsium (Verilog-1995)
// Tests register read/write operations

`timescale 1ns/1ps

module tb_reg;

    // Inputs
    reg clock;
    reg reset;
    reg ena;
    reg [2:0] opcode;
    reg [7:0] data_in;

    // Outputs
    wire [7:0] R0_out;
    wire [7:0] R1_out;

    // Clock period (12 MHz = 83.33ns)
    parameter CLK_PERIOD = 83.33;

    // Instantiate the REG
    REG uut (
        .clock(clock),
        .reset(reset),
        .ena(ena),
        .opcode(opcode),
        .data_in(data_in),
        .R0_out(R0_out),
        .R1_out(R1_out)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end

    // Test procedure
    initial begin
        // Initialize VCD dump
        $dumpfile("reg_wave.vcd");
        $dumpvars(0, tb_reg);

        // Display header
        $display("========================================");
        $display("REG (Register File) Testbench");
        $display("========================================");
        $display("Time\t Opcode\t Data_in\t R0\t R1\t Operation");
        $display("----------------------------------------------------------------");

        // Initialize inputs
        reset = 1;
        ena = 0;
        opcode = 3'b111;
        data_in = 8'd0;
        #(CLK_PERIOD*5);

        // Release reset
        reset = 0;
        #(CLK_PERIOD*2);
        $display("%0t\t %b\t %d\t %d\t %d\t After Reset", 
                 $time, opcode, data_in, R0_out, R1_out);

        // Enable register file
        ena = 1;
        #(CLK_PERIOD);

        // Test LOAD R0 (opcode = 000)
        $display("\n--- Testing LOAD R0 ---");
        opcode = 3'b000;
        data_in = 8'd25;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t LOAD R0, 25", 
                    $time, opcode, data_in, R0_out, R1_out);

        data_in = 8'd100;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t LOAD R0, 100", 
                    $time, opcode, data_in, R0_out, R1_out);

        // Test LOAD R1 (opcode = 001)
        $display("\n--- Testing LOAD R1 ---");
        opcode = 3'b001;
        data_in = 8'd50;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t LOAD R1, 50", 
                    $time, opcode, data_in, R0_out, R1_out);

        data_in = 8'd200;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t LOAD R1, 200", 
                    $time, opcode, data_in, R0_out, R1_out);

        // Test MOV R1 <- R0 (opcode = 010)
        $display("\n--- Testing MOV R1 <- R0 ---");
        opcode = 3'b000;
        data_in = 8'd77;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t LOAD R0, 77", 
                    $time, opcode, data_in, R0_out, R1_out);

        opcode = 3'b010;
        data_in = 8'd0; // data_in is ignored for MOV
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t MOV R1 <- R0", 
                    $time, opcode, data_in, R0_out, R1_out);

        // Test MOV R0 <- R1 (opcode = 011)
        $display("\n--- Testing MOV R0 <- R1 ---");
        opcode = 3'b001;
        data_in = 8'd88;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t LOAD R1, 88", 
                    $time, opcode, data_in, R0_out, R1_out);

        opcode = 3'b011;
        data_in = 8'd0; // data_in is ignored for MOV
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t MOV R0 <- R1", 
                    $time, opcode, data_in, R0_out, R1_out);

        // Test NOP (opcode = 111)
        $display("\n--- Testing NOP ---");
        opcode = 3'b111;
        data_in = 8'd255;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t NOP (no change)", 
                    $time, opcode, data_in, R0_out, R1_out);

        // Test multiple operations sequence
        $display("\n--- Testing Sequence: LOAD R0, LOAD R1, ADD simulation ---");
        opcode = 3'b000;
        data_in = 8'd15;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t LOAD R0, 15", 
                    $time, opcode, data_in, R0_out, R1_out);

        opcode = 3'b001;
        data_in = 8'd30;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t LOAD R1, 30", 
                    $time, opcode, data_in, R0_out, R1_out);

        // Simulate ALU result write-back to R0
        opcode = 3'b000;
        data_in = 8'd45; // 15 + 30 = 45
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t Write ALU result to R0", 
                    $time, opcode, data_in, R0_out, R1_out);

        // Test enable control
        $display("\n--- Testing Enable Control (ena=0) ---");
        ena = 0;
        opcode = 3'b000;
        data_in = 8'd99;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t ENA=0 (no write)", 
                    $time, opcode, data_in, R0_out, R1_out);

        // Re-enable
        ena = 1;
        #(CLK_PERIOD);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t ENA=1 (write resumed)", 
                    $time, opcode, data_in, R0_out, R1_out);

        // Test reset during operation
        $display("\n--- Testing Reset during operation ---");
        reset = 1;
        #(CLK_PERIOD*2);
        #1 $display("%0t\t %b\t %d\t %d\t %d\t RESET (all cleared)", 
                    $time, opcode, data_in, R0_out, R1_out);
        
        reset = 0;
        #(CLK_PERIOD*2);

        // End simulation
        $display("\n========================================");
        $display("REG Testbench Complete");
        $display("========================================");
        #(CLK_PERIOD*5);
        $finish;
    end

endmodule
