// UART_TX Testbench for Xcelsium (Verilog-1995)
// Tests UART transmission at 9600 bps

`timescale 1ns/1ps

module tb_uart;

    // Inputs
    reg clock;
    reg reset;
    reg start;
    reg [7:0] data_in;

    // Outputs
    wire tx;
    wire busy;

    // Clock period (12 MHz = 83.33ns)
    parameter CLK_PERIOD = 83.33;

    // Instantiate the UART_TX
    UART_TX uut (
        .clock(clock),
        .reset(reset),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end

    // Test procedure
    initial begin
        // Initialize VCD dump
        $dumpfile("uart_wave.vcd");
        $dumpvars(0, tb_uart);

        // Display header
        $display("========================================");
        $display("UART_TX Testbench Start");
        $display("Clock: 12 MHz, Baudrate: 9600 bps");
        $display("========================================");

        // Initialize inputs
        reset = 1;
        start = 0;
        data_in = 8'h00;
        #(CLK_PERIOD*10);

        // Release reset
        reset = 0;
        #(CLK_PERIOD*10);
        $display("Time=%0t: Reset released", $time);

        // Test 1: Send 0x55 (01010101 - alternating pattern)
        $display("\n--- Test 1: Send 0x55 ---");
        data_in = 8'h55;
        start = 1;
        #(CLK_PERIOD*2);
        start = 0;
        $display("Time=%0t: Start transmission of 0x55", $time);
        
        // Wait for busy flag
        wait(busy == 1);
        $display("Time=%0t: UART busy", $time);
        
        // Wait for transmission complete
        wait(busy == 0);
        $display("Time=%0t: Transmission complete", $time);
        #(CLK_PERIOD*100);

        // Test 2: Send 0xAA (10101010 - alternating pattern)
        $display("\n--- Test 2: Send 0xAA ---");
        data_in = 8'hAA;
        start = 1;
        #(CLK_PERIOD*2);
        start = 0;
        $display("Time=%0t: Start transmission of 0xAA", $time);
        
        wait(busy == 1);
        $display("Time=%0t: UART busy", $time);
        
        wait(busy == 0);
        $display("Time=%0t: Transmission complete", $time);
        #(CLK_PERIOD*100);

        // Test 3: Send 0xFF (11111111)
        $display("\n--- Test 3: Send 0xFF ---");
        data_in = 8'hFF;
        start = 1;
        #(CLK_PERIOD*2);
        start = 0;
        $display("Time=%0t: Start transmission of 0xFF", $time);
        
        wait(busy == 1);
        $display("Time=%0t: UART busy", $time);
        
        wait(busy == 0);
        $display("Time=%0t: Transmission complete", $time);
        #(CLK_PERIOD*100);

        // Test 4: Send 0x00 (00000000)
        $display("\n--- Test 4: Send 0x00 ---");
        data_in = 8'h00;
        start = 1;
        #(CLK_PERIOD*2);
        start = 0;
        $display("Time=%0t: Start transmission of 0x00", $time);
        
        wait(busy == 1);
        $display("Time=%0t: UART busy", $time);
        
        wait(busy == 0);
        $display("Time=%0t: Transmission complete", $time);
        #(CLK_PERIOD*100);

        // Test 5: Send ASCII 'A' (0x41)
        $display("\n--- Test 5: Send ASCII 'A' (0x41) ---");
        data_in = 8'h41;
        start = 1;
        #(CLK_PERIOD*2);
        start = 0;
        $display("Time=%0t: Start transmission of 0x41 ('A')", $time);
        
        wait(busy == 1);
        $display("Time=%0t: UART busy", $time);
        
        wait(busy == 0);
        $display("Time=%0t: Transmission complete", $time);
        #(CLK_PERIOD*100);

        // End simulation
        $display("\n========================================");
        $display("UART_TX Testbench Complete");
        $display("========================================");
        #(CLK_PERIOD*10);
        $finish;
    end

    // Monitor TX line changes
    initial begin
        $monitor("Time=%0t: tx=%b, busy=%b, state=%d", 
                 $time, tx, busy, uut.state);
    end

endmodule
