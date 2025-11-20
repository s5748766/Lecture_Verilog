`timescale 1ns / 1ps
`default_nettype none

module ALU_tb;
    // 테스트벤치 신호 선언
    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] opcode;
    reg ena;
    wire [15:0] result;
   
    // ALU 모듈 인스턴스화
    ALU uut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .ena(ena),
        .result(result)
    );
   
    // 테스트 시퀀스
    initial begin
        // 파형 덤프
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, ALU_tb);
       
        $display("========================================");
        $display("ALU Testbench 시작");
        $display("========================================");
       
        // 초기화
        a = 8'h00;
        b = 8'h00;
        opcode = 3'b000;
        ena = 1'b0;
       
        // 초기 대기
        #10;
       
        // Test 1: ena=0
        $display("\n[Test 1] ena=0 테스트");
        b = 8'h00;
        a = 8'h00;
        ena = 1'b0;
        opcode = 3'b000;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h05;
        a = 8'h0F;
        ena = 1'b0;
        opcode = 3'b000;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        // Test 2: ena=1 
        $display("\n[Test 2] ena=1 테스트");
        b = 8'h00;
        a = 8'h00;
        ena = 1'b1;
        opcode = 3'b000;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        // Test 3: 덧셈
        $display("\n[Test 3] 덧셈 테스트");
        b = 8'h05;
        a = 8'h0F;
        ena = 1'b1;
        opcode = 3'b000;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h01;
        a = 8'hFF;
        ena = 1'b1;
        opcode = 3'b000;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h7F;
        a = 8'h7F;
        ena = 1'b1;
        opcode = 3'b000;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        // Test 4: 뺄셈
        $display("\n[Test 4] 뺄셈 테스트");
        b = 8'h05;
        a = 8'h0A;
        ena = 1'b1;
        opcode = 3'b001;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h0A;
        a = 8'h05;
        ena = 1'b1;
        opcode = 3'b001;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'hFF;
        a = 8'hFF;
        ena = 1'b1;
        opcode = 3'b001;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        // Test 5: 곱셈
        $display("\n[Test 5] 곱셈 테스트");
        b = 8'h05;
        a = 8'h00;
        ena = 1'b1;
        opcode = 3'b010;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h06;
        a = 8'h05;
        ena = 1'b1;
        opcode = 3'b010;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h10;
        a = 8'h0F;
        ena = 1'b1;
        opcode = 3'b010;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'hFF;
        a = 8'hFF;
        ena = 1'b1;
        opcode = 3'b010;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        // Test 6: 나눗셈
        $display("\n[Test 6] 나눗셈 테스트");
        b = 8'h02;
        a = 8'h0A;
        ena = 1'b1;
        opcode = 3'b011;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h04;
        a = 8'h0F;
        ena = 1'b1;
        opcode = 3'b011;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h00;
        a = 8'h64;
        ena = 1'b1;
        opcode = 3'b011;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h01;
        a = 8'hFF;
        ena = 1'b1;
        opcode = 3'b011;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        // Test 7: %
        $display("\n[Test 7] 나머지 테스트");
        b = 8'h03;
        a = 8'h0A;
        ena = 1'b1;
        opcode = 3'b100;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h04;
        a = 8'h0F;
        ena = 1'b1;
        opcode = 3'b100;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h00;
        a = 8'h64;
        ena = 1'b1;
        opcode = 3'b100;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h04;
        a = 8'h08;
        ena = 1'b1;
        opcode = 3'b100;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        // Test 8: 같음
        $display("\n[Test 8] 데이터 비교 테스트");
        $display("\nopcode = 101 > 같다");
        $display("\nopcode = 110 > a가 더 크다");
        $display("\nopcode = 111 > b가 더 크다");
        b = 8'h0A;
        a = 8'h0A;
        ena = 1'b1;
        opcode = 3'b101;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h0B;
        a = 8'hFA;
        ena = 1'b1;
        opcode = 3'b101;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'hFF;
        a = 8'hFF;
        ena = 1'b1;
        opcode = 3'b101;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h0A;
        a = 8'h0B;
        ena = 1'b1;
        opcode = 3'b110;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h0B;
        a = 8'h0A;
        ena = 1'b1;
        opcode = 3'b110;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h0A;
        a = 8'h0A;
        ena = 1'b1;
        opcode = 3'b110;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h0B;
        a = 8'h0A;
        ena = 1'b1;
        opcode = 3'b111;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h0A;
        a = 8'h0B;
        ena = 1'b1;
        opcode = 3'b111;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);

        b = 8'h0A;
        a = 8'h0A;
        ena = 1'b1;
        opcode = 3'b111;
        #10
        $display("  ena=%b, a=%h, b=%h, opcode=%b => result=%h", ena, a, b, opcode, result);
       
        // 테스트 완료
        #10;
        $display("\n========================================");
        $display("테스트 완료!");
        $display("========================================");
       
        $finish;
    end
   
endmodule