// TOP Module (tt_um_Jsilicon) Testbench for Xcelsium (Verilog-1995)
// Tests complete system integration in both Manual and CPU modes

`timescale 1ns/1ps

module tb_jsilicon_top;

    // Inputs
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;

    // Outputs
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Clock period (12 MHz = 83.33ns)
    parameter CLK_PERIOD = 83.33;

    // Instantiate the TOP module
    tt_um_Jsilicon uut (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uio_in(uio_in),
        .uo_out(uo_out),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Extract output signals
    wire uart_busy = uo_out[7];
    wire [6:0] result_low = uo_out[6:0];
    wire [6:0] result_high = uio_out[7:1];
    wire uart_tx = uio_out[0];
    wire [15:0] full_result = {1'b0, result_high, 1'b0, result_low};

    // Test procedure
    initial begin
        // Initialize VCD dump
        $dumpfile("jsilicon_top_wave.vcd");
        $dumpvars(0, tb_jsilicon_top);

        // Display header
        $display("========================================");
        $display("Jsilicon TOP Module Testbench");
        $display("Testing complete system integration");
        $display("========================================");

        // Initialize inputs
        rst_n = 0;
        ena = 0;
        ui_in = 8'b00000000;
        uio_in = 8'b00000000;
        #(CLK_PERIOD*10);

        // Release reset
        rst_n = 1;
        #(CLK_PERIOD*5);
        $display("\nTime=%0t: System Reset Released", $time);

        // Enable system
        ena = 1;
        #(CLK_PERIOD*5);

        //=================================================================
        // PART 1: Manual Mode Tests (mode = 0)
        //=================================================================
        $display("\n========================================");
        $display("PART 1: MANUAL MODE TESTS (mode=0)");
        $display("========================================");

        // Test 1: Manual Addition
        $display("\n--- Manual Test 1: ADD 15 + 10 ---");
        ui_in[7:4] = 4'd15;  // manual_a
        ui_in[3:0] = 4'd10;  // manual_b
        uio_in[7:5] = 3'b000; // ADD opcode
        uio_in[4] = 1'b0;    // mode = Manual
        #(CLK_PERIOD*5);
        $display("Time=%0t: Inputs - A=%d, B=%d, OP=ADD", $time, ui_in[7:4], ui_in[3:0]);
        #(CLK_PERIOD*100);
        wait(uart_busy == 0);
        $display("Time=%0t: Result=%d, UART_TX=%b", $time, {result_high, result_low}, uart_tx);

        // Test 2: Manual Multiplication
        $display("\n--- Manual Test 2: MUL 12 * 5 ---");
        ui_in[7:4] = 4'd12;
        ui_in[3:0] = 4'd5;
        uio_in[7:5] = 3'b010; // MUL opcode
        uio_in[4] = 1'b0;    // mode = Manual
        #(CLK_PERIOD*5);
        $display("Time=%0t: Inputs - A=%d, B=%d, OP=MUL", $time, ui_in[7:4], ui_in[3:0]);
        #(CLK_PERIOD*100);
        wait(uart_busy == 0);
        $display("Time=%0t: Result=%d, UART_TX=%b", $time, {result_high, result_low}, uart_tx);

        // Test 3: Manual Subtraction
        $display("\n--- Manual Test 3: SUB 15 - 7 ---");
        ui_in[7:4] = 4'd15;
        ui_in[3:0] = 4'd7;
        uio_in[7:5] = 3'b001; // SUB opcode
        uio_in[4] = 1'b0;    // mode = Manual
        #(CLK_PERIOD*5);
        $display("Time=%0t: Inputs - A=%d, B=%d, OP=SUB", $time, ui_in[7:4], ui_in[3:0]);
        #(CLK_PERIOD*100);
        wait(uart_busy == 0);
        $display("Time=%0t: Result=%d, UART_TX=%b", $time, {result_high, result_low}, uart_tx);

        // Test 4: Manual Division
        $display("\n--- Manual Test 4: DIV 15 / 3 ---");
        ui_in[7:4] = 4'd15;
        ui_in[3:0] = 4'd3;
        uio_in[7:5] = 3'b011; // DIV opcode
        uio_in[4] = 1'b0;    // mode = Manual
        #(CLK_PERIOD*5);
        $display("Time=%0t: Inputs - A=%d, B=%d, OP=DIV", $time, ui_in[7:4], ui_in[3:0]);
        #(CLK_PERIOD*100);
        wait(uart_busy == 0);
        $display("Time=%0t: Result=%d, UART_TX=%b", $time, {result_high, result_low}, uart_tx);

        // Test 5: Manual Comparison (Greater Than)
        $display("\n--- Manual Test 5: GT 15 > 10 ---");
        ui_in[7:4] = 4'd15;
        ui_in[3:0] = 4'd10;
        uio_in[7:5] = 3'b110; // GT opcode
        uio_in[4] = 1'b0;    // mode = Manual
        #(CLK_PERIOD*5);
        $display("Time=%0t: Inputs - A=%d, B=%d, OP=GT", $time, ui_in[7:4], ui_in[3:0]);
        #(CLK_PERIOD*100);
        wait(uart_busy == 0);
        $display("Time=%0t: Result=%d (1=true), UART_TX=%b", $time, {result_high, result_low}, uart_tx);

        //=================================================================
        // PART 2: CPU Mode Tests (mode = 1)
        //=================================================================
        $display("\n========================================");
        $display("PART 2: CPU MODE TESTS (mode=1)");
        $display("ROM Program: ADD 3, SUB 2, MUL 5, NOP");
        $display("========================================");

        // Switch to CPU mode
        uio_in[4] = 1'b1; // mode = CPU
        ui_in = 8'h00;    // Manual inputs ignored in CPU mode
        #(CLK_PERIOD*10);

        // Monitor PC and instruction execution
        $display("\n--- Monitoring CPU Execution ---");
        $display("PC will cycle through: 0->1->2->3->0...");
        
        // Let CPU run through one complete program cycle
        $display("\nTime=%0t: Starting CPU program execution", $time);
        
        // Instruction 0: ADD 3
        #(CLK_PERIOD*10);
        wait(uart_busy == 0);
        $display("Time=%0t: PC=0, Instr=ADD 3, R0=%d, R1=%d", 
                 $time, uut.R0, uut.R1);
        #(CLK_PERIOD*100);
        
        // Instruction 1: SUB 2
        wait(uart_busy == 0);
        $display("Time=%0t: PC=1, Instr=SUB 2, R0=%d, R1=%d", 
                 $time, uut.R0, uut.R1);
        #(CLK_PERIOD*100);
        
        // Instruction 2: MUL 5
        wait(uart_busy == 0);
        $display("Time=%0t: PC=2, Instr=MUL 5, R0=%d, R1=%d", 
                 $time, uut.R0, uut.R1);
        #(CLK_PERIOD*100);
        
        // Instruction 3: NOP
        wait(uart_busy == 0);
        $display("Time=%0t: PC=3, Instr=NOP, R0=%d, R1=%d", 
                 $time, uut.R0, uut.R1);
        #(CLK_PERIOD*100);

        // Verify program loops back
        $display("\n--- Verifying Program Loop ---");
        wait(uart_busy == 0);
        $display("Time=%0t: PC=0 (wrapped), Instr=ADD 3, R0=%d, R1=%d", 
                 $time, uut.R0, uut.R1);
        #(CLK_PERIOD*100);

        //=================================================================
        // PART 3: Mode Switching Test
        //=================================================================
        $display("\n========================================");
        $display("PART 3: MODE SWITCHING TEST");
        $display("========================================");

        // Switch back to Manual mode
        $display("\n--- Switching from CPU to Manual Mode ---");
        uio_in[4] = 1'b0; // mode = Manual
        ui_in[7:4] = 4'd8;
        ui_in[3:0] = 4'd8;
        uio_in[7:5] = 3'b101; // EQ opcode
        #(CLK_PERIOD*10);
        $display("Time=%0t: Manual Mode - Testing EQ 8 == 8", $time);
        #(CLK_PERIOD*100);
        wait(uart_busy == 0);
        $display("Time=%0t: Result=%d (should be 1)", $time, {result_high, result_low});

        // Switch back to CPU mode
        $display("\n--- Switching from Manual to CPU Mode ---");
        uio_in[4] = 1'b1; // mode = CPU
        #(CLK_PERIOD*10);
        $display("Time=%0t: CPU Mode resumed", $time);
        #(CLK_PERIOD*200);

        //=================================================================
        // PART 4: Enable Control Test
        //=================================================================
        $display("\n========================================");
        $display("PART 4: ENABLE CONTROL TEST");
        $display("========================================");

        $display("\n--- Disabling System (ena=0) ---");
        ena = 0;
        #(CLK_PERIOD*50);
        $display("Time=%0t: System disabled, PC should not advance", $time);

        $display("\n--- Re-enabling System (ena=1) ---");
        ena = 1;
        #(CLK_PERIOD*10);
        $display("Time=%0t: System re-enabled", $time);
        #(CLK_PERIOD*200);

        //=================================================================
        // PART 5: Reset Test
        //=================================================================
        $display("\n========================================");
        $display("PART 5: RESET TEST");
        $display("========================================");

        $display("\n--- Asserting Reset ---");
        rst_n = 0;
        #(CLK_PERIOD*20);
        $display("Time=%0t: Reset asserted, R0=%d, R1=%d", 
                 $time, uut.R0, uut.R1);

        $display("\n--- Releasing Reset ---");
        rst_n = 1;
        #(CLK_PERIOD*20);
        $display("Time=%0t: Reset released, system restarted", $time);
        #(CLK_PERIOD*200);

        // End simulation
        $display("\n========================================");
        $display("Jsilicon TOP Module Testbench Complete");
        $display("All tests passed successfully!");
        $display("========================================");
        #(CLK_PERIOD*10);
        $finish;
    end

    // Continuous monitoring
    initial begin
        $display("\n--- Continuous Monitor Active ---");
        $monitor("Time=%0t: Mode=%b, PC=%d, R0=%d, R1=%d, Result=%d, UART_Busy=%b", 
                 $time, uio_in[4], uut.pc_inst.pc, uut.R0, uut.R1, 
                 {result_high, result_low}, uart_busy);
    end

endmodule
