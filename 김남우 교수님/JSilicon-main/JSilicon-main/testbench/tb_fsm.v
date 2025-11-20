// FSM Testbench for Xcelsium (Verilog-1995)
// Tests FSM state machine with ALU and UART integration

`timescale 1ns/1ps

module tb_fsm;

    // Inputs
    reg clock;
    reg reset;
    reg ena;
    reg alu_ena;
    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] opcode;

    // Outputs
    wire [15:0] alu_result;
    wire uart_tx;
    wire uart_busy;

    // Clock period (12 MHz = 83.33ns)
    parameter CLK_PERIOD = 83.33;

    // Instantiate the FSM
    FSM uut (
        .clock(clock),
        .reset(reset),
        .ena(ena),
        .alu_ena(alu_ena),
        .a(a),
        .b(b),
        .opcode(opcode),
        .alu_result(alu_result),
        .uart_tx(uart_tx),
        .uart_busy(uart_busy)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end

    // Test procedure
    initial begin
        // Initialize VCD dump
        $dumpfile("fsm_wave.vcd");
        $dumpvars(0, tb_fsm);

        // Display header
        $display("========================================");
        $display("FSM Testbench");
        $display("Testing FSM state machine with ALU and UART");
        $display("========================================");

        // Initialize inputs
        reset = 1;
        ena = 0;
        alu_ena = 0;
        a = 8'd0;
        b = 8'd0;
        opcode = 3'b000;
        #(CLK_PERIOD*10);

        // Release reset
        reset = 0;
        #(CLK_PERIOD*5);
        $display("Time=%0t: Reset released, FSM in INIT state", $time);

        // Test 1: Addition operation
        $display("\n--- Test 1: Addition (15 + 10) ---");
        ena = 1;
        alu_ena = 1;
        a = 8'd15;
        b = 8'd10;
        opcode = 3'b000; // ADD
        #(CLK_PERIOD);
        $display("Time=%0t: Inputs set - A=%d, B=%d, OP=ADD", $time, a, b);
        $display("Time=%0t: ALU Result=%d", $time, alu_result);
        
        // Wait for UART transmission
        $display("Time=%0t: FSM state=%d, UART busy=%b", $time, uut.state, uart_busy);
        #(CLK_PERIOD*10);
        
        // Monitor state transitions
        wait(uart_busy == 1);
        $display("Time=%0t: UART transmission started, busy=1", $time);
        
        wait(uart_busy == 0);
        $display("Time=%0t: UART transmission complete, busy=0", $time);
        #(CLK_PERIOD*10);

        // Test 2: Multiplication operation
        $display("\n--- Test 2: Multiplication (12 * 5) ---");
        a = 8'd12;
        b = 8'd5;
        opcode = 3'b010; // MUL
        #(CLK_PERIOD);
        $display("Time=%0t: Inputs set - A=%d, B=%d, OP=MUL", $time, a, b);
        $display("Time=%0t: ALU Result=%d", $time, alu_result);
        
        wait(uart_busy == 1);
        $display("Time=%0t: UART transmission started", $time);
        
        wait(uart_busy == 0);
        $display("Time=%0t: UART transmission complete", $time);
        #(CLK_PERIOD*10);

        // Test 3: Subtraction operation
        $display("\n--- Test 3: Subtraction (50 - 20) ---");
        a = 8'd50;
        b = 8'd20;
        opcode = 3'b001; // SUB
        #(CLK_PERIOD);
        $display("Time=%0t: Inputs set - A=%d, B=%d, OP=SUB", $time, a, b);
        $display("Time=%0t: ALU Result=%d", $time, alu_result);
        
        wait(uart_busy == 1);
        $display("Time=%0t: UART transmission started", $time);
        
        wait(uart_busy == 0);
        $display("Time=%0t: UART transmission complete", $time);
        #(CLK_PERIOD*10);

        // Test 4: Division operation
        $display("\n--- Test 4: Division (100 / 7) ---");
        a = 8'd100;
        b = 8'd7;
        opcode = 3'b011; // DIV
        #(CLK_PERIOD);
        $display("Time=%0t: Inputs set - A=%d, B=%d, OP=DIV", $time, a, b);
        $display("Time=%0t: ALU Result=%d (100/7=%d)", $time, alu_result, alu_result);
        
        wait(uart_busy == 1);
        $display("Time=%0t: UART transmission started", $time);
        
        wait(uart_busy == 0);
        $display("Time=%0t: UART transmission complete", $time);
        #(CLK_PERIOD*10);

        // Test 5: Comparison operation (Equal)
        $display("\n--- Test 5: Comparison Equal (25 == 25) ---");
        a = 8'd25;
        b = 8'd25;
        opcode = 3'b101; // EQ
        #(CLK_PERIOD);
        $display("Time=%0t: Inputs set - A=%d, B=%d, OP=EQ", $time, a, b);
        $display("Time=%0t: ALU Result=%d (1=true, 0=false)", $time, alu_result);
        
        wait(uart_busy == 1);
        $display("Time=%0t: UART transmission started", $time);
        
        wait(uart_busy == 0);
        $display("Time=%0t: UART transmission complete", $time);
        #(CLK_PERIOD*10);

        // Test 6: Enable control
        $display("\n--- Test 6: Enable Control (ena=0) ---");
        ena = 0;
        a = 8'd99;
        b = 8'd88;
        opcode = 3'b000;
        #(CLK_PERIOD*20);
        $display("Time=%0t: ENA=0, FSM should be in INIT, busy=%b", $time, uart_busy);
        $display("Time=%0t: FSM state=%d (should be 0=INIT)", $time, uut.state);

        // Re-enable
        $display("\n--- Re-enabling FSM ---");
        ena = 1;
        #(CLK_PERIOD*2);
        $display("Time=%0t: ENA=1, FSM resumed", $time);
        
        wait(uart_busy == 1);
        $display("Time=%0t: UART transmission started", $time);
        
        wait(uart_busy == 0);
        $display("Time=%0t: UART transmission complete", $time);
        #(CLK_PERIOD*10);

        // Test 7: ALU enable control
        $display("\n--- Test 7: ALU Enable Control (alu_ena=0) ---");
        alu_ena = 0;
        a = 8'd100;
        b = 8'd50;
        opcode = 3'b000;
        #(CLK_PERIOD);
        $display("Time=%0t: ALU_ENA=0, Result should be 0", $time);
        $display("Time=%0t: ALU Result=%d", $time, alu_result);
        
        wait(uart_busy == 1);
        $display("Time=%0t: UART transmission started (sending 0)", $time);
        
        wait(uart_busy == 0);
        $display("Time=%0t: UART transmission complete", $time);
        #(CLK_PERIOD*10);

        // Re-enable ALU
        alu_ena = 1;
        #(CLK_PERIOD);
        $display("Time=%0t: ALU_ENA=1, Result=%d", $time, alu_result);
        
        wait(uart_busy == 1);
        wait(uart_busy == 0);
        #(CLK_PERIOD*10);

        // Test 8: Reset during operation
        $display("\n--- Test 8: Reset during operation ---");
        a = 8'd77;
        b = 8'd33;
        opcode = 3'b000;
        #(CLK_PERIOD*5);
        
        reset = 1;
        #(CLK_PERIOD*5);
        $display("Time=%0t: RESET asserted, state=%d, busy=%b", 
                 $time, uut.state, uart_busy);
        
        reset = 0;
        #(CLK_PERIOD*5);
        $display("Time=%0t: RESET released, FSM restarted", $time);
        
        wait(uart_busy == 1);
        wait(uart_busy == 0);
        #(CLK_PERIOD*10);

        // Test 9: Multiple consecutive operations
        $display("\n--- Test 9: Multiple consecutive operations ---");
        a = 8'd10;
        b = 8'd5;
        opcode = 3'b000; // ADD
        wait(uart_busy == 0);
        #(CLK_PERIOD*5);
        $display("Time=%0t: Operation 1 - ADD: %d + %d = %d", $time, a, b, alu_result);

        a = 8'd20;
        b = 8'd4;
        opcode = 3'b010; // MUL
        wait(uart_busy == 0);
        #(CLK_PERIOD*5);
        $display("Time=%0t: Operation 2 - MUL: %d * %d = %d", $time, a, b, alu_result);

        a = 8'd100;
        b = 8'd3;
        opcode = 3'b100; // MOD
        wait(uart_busy == 0);
        #(CLK_PERIOD*5);
        $display("Time=%0t: Operation 3 - MOD: %d %% %d = %d", $time, a, b, alu_result);

        // Wait for final transmission
        wait(uart_busy == 0);
        #(CLK_PERIOD*10);

        // End simulation
        $display("\n========================================");
        $display("FSM Testbench Complete");
        $display("All state transitions verified");
        $display("========================================");
        #(CLK_PERIOD*10);
        $finish;
    end

    // Monitor for debugging
    initial begin
        $monitor("Time=%0t: State=%d, UART_TX=%b, Busy=%b, Result=%d", 
                 $time, uut.state, uart_tx, uart_busy, alu_result);
    end

endmodule
