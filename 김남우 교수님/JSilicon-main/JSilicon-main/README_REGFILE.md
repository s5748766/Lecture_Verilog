# REG — 내부 레지스터 파일 (2R 구조 기반)

> Module: `REG`  
> Timescale: `1ns/1ps`  
> Nettype: ``default_nettype none``  
> Design Type: **Dual 8-bit Register File (R0, R1)**

---

## 📘 1. Register File 개요
**Register File**은 CPU의 핵심 구성 요소로, 데이터 임시 저장 및 연산 중간값 유지에 사용됩니다.  
이 모듈은 단순한 **2-Register 구조 (R0, R1)** 로, **Opcode**에 따라 데이터를 저장하거나 이동하는 기능을 수행합니다.

```
[PC] → [ROM] → [Decoder] → [REG] → [ALU] → [FSM + UART]
```

> 즉, 이 모듈은 디코더와 ALU 사이의 **데이터 허브(Data Hub)** 역할을 합니다.

---

## 🧭 2. Register File 이론 및 배경

### 🧩 Register File의 발전
- 초기 CPU(예: Intel 4004)는 단일 누산기(accumulator) 구조만을 사용했습니다.
- RISC 아키텍처(Reduced Instruction Set Computer)의 등장 이후, **범용 레지스터(General Purpose Register)** 구조가 표준이 되었습니다.
- 현대 CPU에서는 16~64개 이상의 레지스터 뱅크를 두며, 동시 접근(2R1W) 구조를 사용합니다.

### ⚙️ 역할 요약
| 구성 요소 | 역할 |
|------------|------|
| **Decoder** | 명령어 해독 후 레지스터 선택 제어 |
| **Register File** | 연산 데이터 임시 저장 |
| **ALU** | 연산 수행 |
| **FSM(Control Unit)** | 명령 실행 순서 제어 |

> 본 설계에서는 단순한 2개 레지스터 구조이지만, FSM 및 ALU와 직접 연결되어 **마이크로 연산 레벨 제어**를 수행합니다.

---

## 🔧 3. 포트 설명

| 이름 | 방향 | 폭 | 설명 |
|------|------|----|------|
| `clock` | 입력 | 1 | 시스템 클럭 |
| `reset` | 입력 | 1 | 비동기 리셋 |
| `ena` | 입력 | 1 | Enable 신호 (1일 때만 동작) |
| `opcode` | 입력 | 3 | 동작 명령 코드 |
| `data_in` | 입력 | 8 | 저장할 데이터 |
| `R0_out` | 출력 | 8 | 레지스터 R0의 현재 값 |
| `R1_out` | 출력 | 8 | 레지스터 R1의 현재 값 |

---

## 🧮 4. Opcode 기반 동작 정의

| Opcode | 명령 | 설명 |
|--------|------|------|
| `000` | LOAD R0 | `R0 <= data_in` |
| `001` | LOAD R1 | `R1 <= data_in` |
| `010` | MOV R1,R0 | `R1 <= R0` |
| `011` | MOV R0,R1 | `R0 <= R1` |
| `100~111` | NOP | 동작 없음 (유지) |

> 본 구조에서는 OUT 명령(`data_out`)은 직접 사용하지 않고, **ALU나 FSM**이 `R0_out`, `R1_out` 신호를 참조합니다.

---

## 🧠 5. 설계 구조 및 동작 원리

### 전체 블록 개요

```
                +-----------------------+
   data_in ---> |                       | ---> R0_out
        +------>|       REG Module      |
        |       |  +-------+   +------+ |
        |       |  |  R0   |   |  R1  | |
        |       |  +---+---+   +---+--+ |
        |       |      ^         ^      |
        |       |      |         |      |
        |       |   Decoder(opcode)     |
        |       +-----------------------+
        |              |
        +--------------+ (ena)
```

- `reset`: 두 레지스터를 초기화 (`0x00`)  
- `ena=1`일 때만 opcode 수행  
- `opcode`에 따라 R0, R1 업데이트  
- 모든 레지스터는 클럭 상승 에지에서 갱신

---

## ⚙️ 6. Verilog 코드 요약

```verilog
// 내부 레지스터 파일
// 구조 :2 PC + ROM > Decoder > REG > ALU > FSM + UART

`define default_netname none

(* keep_hierarchy *)
module REG (
    input wire clock,
    input wire reset,
    input wire ena,

    // 데이터 입출력
    input wire [2:0] opcode,
    // 명령어 저장
    input wire [7:0] data_in, 
    // FSM, ALU 데이터 저장
    // output reg [7:0] data_out,

    // 디버그 포트
    output wire [7:0] R0_out,
    output wire [7:0] R1_out
    );

    reg [7:0] R0, R1;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            // 기본값 초기화
            R0 <= 0; R1 <= 0;
            // data_out <= 8'b0;
        end else if (ena) begin
            case (opcode)
                // opcode 별 분리
                // LOAD R0, R1 (데이터 저장)
                3'b000: R0 <= data_in;
                3'b001: R1 <= data_in;

                // MOV (덮어쓰기)
                3'b010: R1 <= R0;
                3'b011: R0 <= R1;

                // OUT (출력) <- assign으로 직접 가져다 씀
                // 3'b100: data_out <= R0;
                // 3'b101: data_out <= R1;

                // NOP (기본값)
                default: begin
                    // 다른 opcode 에서는 명령 실행 안함
                end
            endcase
        end
    end

    assign R0_out = R0;
    assign R1_out = R1;
    
endmodule
```

---

## ⏱ 7. 동작 타이밍 예시

| Cycle | ena | opcode | data_in | R0 | R1 | 설명 |
|--------|------|--------|---------|----|----|------|
| 1 | 1 | 000 | 0x12 | 0x12 | 0x00 | R0 ← 0x12 |
| 2 | 1 | 001 | 0x34 | 0x12 | 0x34 | R1 ← 0x34 |
| 3 | 1 | 010 | — | 0x12 | 0x12 | R1 ← R0 |
| 4 | 1 | 011 | — | 0x12 | 0x12 | R0 ← R1 |
| 5 | 0 | — | — | 유지 | 유지 | 동작 정지 |

---

## 🧪 8. Testbench 예시

```verilog
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

```

---

## 🧩 9. 설계적 고찰

1. **Reset 안정화**: 모든 레지스터는 초기화되어야 한다.  
2. **Enable 제어**: FSM에서 타이밍을 맞춰 `ena`를 gating하는 것이 중요.  
3. **Opcode 관리**: Decoder에서 전달받는 opcode는 ALU/Control Unit과 일관되어야 한다.  
4. **확장 가능성**: R0~R7 구조(3-bit addressable)로 확장 시 `case` → `regfile[addr]`로 전환.  
5. **Synthesis 최적화**: 두 개 레지스터만 존재하므로 LUT 자원 소모가 매우 작다.

---

## 📂 10. 프로젝트 구조 예시

```
├─ rtl/
│  └─ REG.v
├─ sim/
│  └─ tb_reg.v
└─ docs/
   └─ README_REG_FULL.md
```

---

**작성자:** MultiMix Tech (NAMWOO KIM)  
**버전:** 1.0 (2-Register 구조)  
**업데이트:** 2025-11-12 22:44
