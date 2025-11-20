# FSM — 연산 제어 상태기계 (ALU + UART_TX 통합)

> Module: `FSM`  
> Timescale: `1ns/1ps`  
> Nettype: ``default_nettype none``  
> Design Type: **Moore-like FSM controlling ALU + UART_TX (TX-only, 8N1)**

---

## 📘 1) 개요 (Overview)

이 모듈은 간단한 **제어 FSM**으로, ALU의 연산 결과(16-bit 중 하위 8-bit)를 **UART_TX**로 송신하는 일련의 절차를 관리합니다.  
`ena`가 1일 때만 동작하며, UART 전송이 끝나면 다시 초기 상태로 복귀하여 다음 연산을 준비합니다.

데이터 경로 요약:

```
a[7:0], b[7:0], opcode[2:0] ──> [ ALU ] ──> alu_result[15:0] ──> [ UART_TX ] ──> uart_tx
                                     ^
                                  alu_ena
```

- **ALU**: `a`, `b`, `opcode` 입력 기반으로 16-bit 결과 생성
- **FSM**: UART에 start pulse를 제공하여 `alu_result[7:0]`를 직렬 송신
- **UART_TX**: 8N1 프레임으로 송신, `busy`로 진행 상태 보고

---

## 🧠 2) FSM 이론 요약 (Mealy vs Moore)

- **Moore FSM**: 출력이 **현재 상태**에만 의존 → 출력 신호의 글리치가 적고 안정적  
- **Mealy FSM**: 출력이 **현재 상태 + 입력**에 의존 → 반응이 한 사이클 빠를 수 있으나 글리치 주의  
- 본 설계는 `start_uart`를 상태에 따라 구동하는 **Moore-like** 형태로 이해할 수 있습니다.

FSM 일반 구조:

```
[State Reg] ──(posedge clk)──> [Next-State Logic] ──→ state_n
    │                                        │
    └─────────────[Output Decode] <──────────┘
```

---

## 🧩 3) 내부 구조 및 인터페이스

### 포트

| 이름 | 방향 | 폭 | 설명 |
|------|------|----|------|
| `clock` | In | 1 | 시스템 클럭 |
| `reset` | In | 1 | **비동기 High** 리셋 |
| `a`, `b` | In | 8 | ALU 피연산자 |
| `opcode` | In | 3 | ALU 연산 선택 |
| `ena` | In | 1 | FSM 동작 Enable (0이면 INIT로 유지) |
| `alu_ena` | In | 1 | ALU 연산 Enable (ALU 내부에서 사용) |
| `alu_result` | Out | 16 | ALU 결과 |
| `uart_tx` | Out | 1 | UART 직렬 송신선 |
| `uart_busy` | Out | 1 | UART 송신 중 표시 |

### 상태 정의

```verilog
localparam INIT = 2'd0;
localparam SEND = 2'd1;
localparam WAIT = 2'd2;
```

- **INIT**: 준비 상태. `start_uart`를 1로 만들어 전송 개시
- **SEND**: UART가 `busy=1`이 될 때까지 대기하면서 `start_uart`를 0으로 내림(펄스 유지 방지)
- **WAIT**: UART가 `busy=0`이 될 때까지 대기 → 완료 시 `INIT`로 복귀

### 제어 시그널

- `start_uart`: UART_TX에 **1사이클 이상의 펄스**를 제공하여 전송 개시  
  - 구현상 INIT에서 1로 세트 → `busy`가 1되면 즉시 0으로 클리어
- `uart_busy`: UART_TX 내부에서 전송 중 High로 유지
- `ena`: 0이면 **언제나 INIT + start_uart=0**으로 되돌림 (안전한 정지)

---

## 🔧 4) 코드 핵심 (요약)

```verilog
// 헤드 연산 할당 장치

`define default_netname none

(* keep_hierarchy *)
module FSM (
    input wire clock,
    input wire reset,
    // 입력 wire 분리
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [2:0] opcode,

    input wire ena,
    input wire alu_ena,

    // 출력 wire
    output wire [15:0] alu_result,
    output wire uart_tx,
    output wire uart_busy
    );

    reg [1:0] state;

    // FSM - compress bits
    localparam INIT = 2'd0;
    // remove unused code (EXEC)
    localparam SEND = 2'd1;
    localparam WAIT = 2'd2;
    reg start_uart;

    
    // ALU 연동
    ALU alu_connect (
        .a(a),
        .b(b),
        .opcode(opcode),
        .ena(alu_ena),
        .result(alu_result)
    );

    // UART 연동
    UART_TX uart_connect(
        .clock(clock),
        .reset(reset),
        .start(start_uart),
        .data_in(alu_result[7:0]),
        .tx(uart_tx),
        .busy(uart_busy)
    );



    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= INIT;
            // 하드코딩 값 삭제
            start_uart <= 1'b0;
        end else if (ena) begin
            case (state)
                INIT: begin
                    start_uart <= 1'b1;
                    state <= SEND;
                end

                SEND: begin
                    // 안정성 코드 추가 (state가 INIT이 될 수 있음)
                    if (uart_busy) begin
                        start_uart <= 1'b0;
                        state <= WAIT;
                    end
                end

                WAIT: begin
                    start_uart <= 1'b0; // 재 초기화
                    if (!uart_busy) state <= INIT;
                end

                default: begin
                    state <= INIT;
                    start_uart <= 1'b0;
                end
            endcase 
        end else begin
            state <= INIT;
            start_uart <= 1'b0;
        end
    end

endmodule
```

**핵심 포인트**
- `start_uart`는 **펄스 형태**로 만들어 **중복 트리거 방지**
- `ena=0`일 때 언제든 안전하게 초기화
- UART_TX는 예시로 12MHz/9600bps(`CLOCK_DIV=1250`) 설정을 사용할 수 있음

---

## ⏱ 5) 상태 전이 타이밍

```
INIT ── start_uart=1 ──> SEND ── (uart_busy=1) ──> WAIT ── (uart_busy=0) ──> INIT
             ^ 1비트 이상 유지                                            ^ 루프
```

- ALU 결과는 항상 계산되어 `alu_result`에 반영 (`alu_ena`가 1일 때)
- UART는 `alu_result[7:0]`를 8N1 프레임으로 송신

---

## 🧪 6) 제공된 Testbench 요약

테스트벤치 주요 특징:
- `CLK_PERIOD = 83.33ns` → **12 MHz** 클럭
- VCD 덤프(`fsm_wave.vcd`) 출력
- 덧셈/곱셈/뺄셈/나눗셈/비교 등 다양한 ALU 연산 시나리오
- `ena=0`/`alu_ena=0` 케이스, 동작 중 `reset`도 검증
- 각 테스트 사이클마다 `uart_busy` 상승/하강 대기 (`wait()`)

```verilog
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

```

시뮬레이션 실행 예시 (Icarus Verilog):

```sh
iverilog -g2012 -o fsm_tb.out alu.v uart.v fsm.v
vvp fsm_tb.out
gtkwave fsm_wave.vcd &
```

ModelSim/Questa:

```sh
vlog alu.v uart.v fsm.v tb_fsm.v
vsim -c tb_fsm -do "run -all; quit"
```

> ⚠️ `UART_TX`의 분주기(`CLOCK_DIV=1250`)는 **12 MHz / 9600bps**에 해당합니다.  
> 테스트 클럭과 분주기 설정이 일치해야 정상적인 `uart_busy` 타이밍이 나옵니다.

---

## 🧰 7) 설계적 고찰 & 개선 포인트

1. **start 펄스 보장**: INIT에서 1로 세팅 후 `busy`가 1이 되는 즉시 0으로 내리는 방식 → **중복 트리거 방지**
2. **데이터 유효 기간**: `alu_result`는 전송 동안 안정적이어야 함 → 필요 시 송신 시작 시점에 래치(`data_latched <= alu_result[7:0]`)
3. **상태 복원력**: `ena=0`에서 INIT으로 되돌리는 정책은 안전하지만, **일시 정지/재개** 시 요구 동작을 명확히 정의 필요
4. **상위 바이트 전송**: 현 설계는 `alu_result[7:0]`만 송신. 16-bit 전송이 필요하면 **두 번의 프레임**으로 나눠 송신하거나, FSM 상태를 `SEND_LO → SEND_HI → WAIT`로 확장
5. **에러 처리**: UART 오버런, `busy` stuck 등 예외 처리 로직 추가 고려
6. **검증 Coverage**: 나눗셈 0 처리, 비교 연산의 경계값 등 코너 케이스 테스트 보강

---

## 📂 8) 권장 디렉토리 구조

```
├─ rtl/
│  ├─ alu.v
│  ├─ uart.v         // UART_TX
│  └─ fsm.v
├─ sim/
│  └─ tb_fsm.v
└─ docs/
   └─ README_FSM_FULL.md
```

---

**작성자:** MultiMix Tech (NAMWOO KIM)  
**버전:** 1.0 (ALU + UART_TX Controller)  
**업데이트:** 2025-11-12 22:49
