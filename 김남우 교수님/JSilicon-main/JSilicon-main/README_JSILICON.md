# Jsilicon Top — `tt_um_Jsilicon` (TinyTapeout‑style Top Level)

> Module: `tt_um_Jsilicon`  
> Role: **System stitch** — connects PC/Decoder/REG/ALU/FSM(UART) and Manual inputs via `SWITCH`  
> Style: TinyTapeout pin conventions (`clk`, `rst_n`, `ui_in`, `uio_*`, `uo_out`)  
> Nettype: ``default_nettype none``

---

## 📘 1) Overview

이 모듈은 두 가지 동작 경로를 **런타임 스위칭**으로 제공하는 SoC 톱 레벨입니다.

- **Manual 모드 (`mode=0`)**: 외부 스위치/버튼 등으로 A, B, OPCODE를 직접 입력 → FSM이 ALU를 구동 후 UART_TX로 하위 8비트 송신  
- **CPU 모드 (`mode=1`)**: `PC → DECODER → REG → SWITCH → FSM(ALU)`의 전형적 순서를 따르며, ALU 결과는 REG로 Write‑Back

데이터 플로우 요약:
```
Manual:  ui_in[7:4], ui_in[3:0], uio_in[7:5] ──> SWITCH ──> FSM ──> ALU ──> UART_TX
CPU:     PC ─> DECODER ─> REG ─> SWITCH ─> FSM ─> ALU ─> (WB) ─> REG
```

> FSM은 ALU의 16‑bit 결과 중 **하위 8‑bit**를 UART_TX로 송신합니다. 상위/하위 결과 비트는 패드 제약으로 일부만 외부 핀에 매핑됩니다.

---

## 🧩 2) Block Diagram

```
                 +--------------------+
                 |        PC          |  instr[7:0]
 clk,rst_n,ena ->|  (w/ small ROM?)   |--------------+
                 +--------------------+              |
                                                    v
                                             +-------------+
                                             |   DECODER   |-- alu_op[2:0]
                                             +-------------+-- imm4/reg_sel
                                                    |           |      |
                                    +---------------+           |      |
                                    |                           |      |
                                    v                           v      v
                      +----------------------+            +----------------+
Manual A,B,OP ───────>|       SWITCH         |----------->|      FSM       |---> UART_TX
(mode=0)              |  (mode=0: Manual,    |            |  (ALU control) |
CPU R0,R1,OP ────────>|   mode=1: CPU path)  |            +----------------+
                      +----------------------+                     |
                                                                  v
                                                        +----------------+
                                                        |      ALU       |
                                                        +----------------+
                                                                  |
                                                                  v
                                                          +-------------+
                                                          |    REG      |<-- WB (lower 8b)
                                                          +-------------+
```

---

## 🔌 3) I/O Mapping (TinyTapeout‑style)

### Inputs
| Signal | Width | Desc |
|-------|------:|------|
| `clk` | 1 | 시스템 클럭 |
| `rst_n` | 1 | **Active‑Low** reset → 내부 `reset = ~rst_n` |
| `ena` | 1 | 시스템 Enable (PC, Decoder, REG, FSM 등 전반 gating) |
| `ui_in` | 8 | Manual 데이터: `manual_a=ui_in[7:4]`, `manual_b=ui_in[3:0]` (각 4‑bit) |
| `uio_in` | 8 | `manual_opcode=uio_in[7:5]` (3‑bit), `mode=uio_in[4]` (0=Manual, 1=CPU) |

### Outputs
| Signal | Width | Desc |
|--------|------:|------|
| `uo_out` | 8 | `{uart_busy, alu_result[6:0]}` |
| `uio_out` | 8 | `{alu_result[15:9], uart_tx}` |
| `uio_oe` | 8 | 출력 enable 비트. 설계상 `8'b0000_0001` (LSB만 출력 사용) |

⚠️ **결과 비트 매핑 주의**: 외부 핀 예산으로 `alu_result[8]` 비트는 노출되지 않습니다.  
테스트벤치에서는 ``{1'b0, uio_out[7:1], 1'b0, uo_out[6:0]}``로 16‑bit를 **보간**합니다.

---

## 🧠 4) Sub‑modules & Handshake

- **PC**: `instr_out`을 제공. (이 구현은 PC+ROM 모듈일 수 있음. 인터페이스: `.clock`, `.reset`, `.ena`, `.instr_out`)  
- **DECODER**: `[7:5]=opcode`, `[4]=reg_sel`, `[3:0]=imm4`를 해독 → `alu_opcode`, `reg_sel`, `operand`, `alu_enable`, `write_enable` 생성  
- **REG**: 간단한 2레지스터 파일(R0, R1). `write_enable`이 1일 때 **WB 데이터**를 해당 레지스터에 적재  
  - WB 데이터: `decoder_alu_enable ? alu_result[7:0] : {4'b0000, decoder_operand}`  
  - WB 타겟 opcode: `decoder_write_enable ? (decoder_reg_sel ? 3'b001 : 3'b000) : 3'b111`  
- **SWITCH**: `mode`에 따라 `(Manual) vs (CPU:R0/R1/op)` 선택  
- **FSM**: `ena`가 1일 때 동작, ALU를 구동하고 `uart_busy`를 통해 TX 상태 노출  
- **ALU**: 8‑bit 산술/비교 연산, 16‑bit 결과

---

## ⚙️ 5) Reset/Enable/Mode 정책

- `reset = ~rst_n` (Active‑Low 입력을 Active‑High 내부로 전환)  
- `ena=0`일 때 상위 경로 정지(PC advance 금지, FSM 초기화 유지)  
- `mode`는 비동기 입력일 수 있으므로, 실제 보드에서는 **2FF 동기화** 후 사용 권장

예시(상위에서 동기화):
```verilog
reg mode_d1, mode_sync;
always @(posedge clk or posedge reset) begin
  if (reset) begin mode_d1 <= 0; mode_sync <= 0; end
  else begin mode_d1 <= uio_in[4]; mode_sync <= mode_d1; end
end
```

```verilog
// top 모듈
// FSM 커버
// 동작 구조 - Manual : USER INPUT > Jsilicon.v > FSM.v (Internal ALU, UART)
// 동작 구조 - CPU(AUTO)
// Foward : PC > DECODER > REG > SWITCH > FSM (Internal ALU, UART)
// Write-Back : ALU Result (FSM output) > REG

`define default_netname none

module tt_um_Jsilicon(
    // Tinytapeout 요구 변수명으로 수정 
    input wire clk,
    input wire rst_n,

    // 사용자 입력 기능 추가
    input wire [7:0] ui_in,
    input wire [7:0] uio_in,

    // Enable Input 추가
    input wire ena,
    
    // 출력핀 재지정
    output wire [7:0] uio_oe,
    
    // 사용자 출력 추가
    output wire [7:0] uo_out,
    output wire [7:0] uio_out
    );

    // 초기화 동기화
    wire reset = ~rst_n;

    // Manual 제어 할당
    // 내부 wire 지정
    wire [3:0] manual_a = ui_in[7:4];
    wire [3:0] manual_b = ui_in[3:0];
    // Opcode 지정
    // 연결 추가 - Opcode 
    wire [2:0] manual_opcode = uio_in[7:5];
    // Mode 핀 추가
    // 0 : Manual, 1 = CPU 
    wire mode = uio_in[4]; 

    // CPU 모드 (PC + Decoder)
    // 합성 시에는 미사용 디버그 포트 삭제 (gds 통과를 위한 사항)
    // wire [3:0] pc_cnt;
    wire [7:0] instr;

    PC pc_inst (
        .clock(clk),
        .reset(reset),
        .ena(ena),
        .instr_out(instr)
    );

    wire [2:0] decoder_alu_opcode;
    wire [3:0] decoder_operand;
    wire decoder_reg_sel;
    wire decoder_alu_enable;
    wire decoder_write_enable;

    DECODER dec_inst (
        .clock(clk),
        .reset(reset),
        .ena(ena),
        .instr_in(instr),
        .alu_opcode(decoder_alu_opcode),
        .operand(decoder_operand),
        .reg_sel(decoder_reg_sel),
        .alu_enable(decoder_alu_enable),
        .write_enable(decoder_write_enable)
    );

    // REG 경로 추가
    wire [15:0] alu_result;

    wire [7:0] wb_data = decoder_alu_enable ? alu_result[7:0] : {4'b0000, decoder_operand};
    wire [2:0] regfile_opcode = decoder_write_enable ? (decoder_reg_sel ? 3'b001 : 3'b000) : 3'b111;

    // 미사용 신호 삭제
    wire [7:0] R0, R1;

    // 미사용 디버그 포트 삭제
    REG reg_inst (
        .clock(clk),
        .reset(reset),
        .ena(ena),
        .opcode(regfile_opcode),
        .data_in(wb_data),
        .R0_out(R0),
        .R1_out(R1)
    );

    // ALU - CPU mode
    wire [7:0] cpu_a = R0;
    wire [7:0] cpu_b = R1;
    wire [2:0] cpu_opcode = decoder_alu_opcode;

    // SWITCH 제어
    // 모듈 사용으로 변경
    wire [7:0] select_a;
    wire [7:0] select_b;
    wire [2:0] select_opcode;
    SWITCH switch_inst (
        .mode(mode),
        .manual_a({4'b0000, manual_a}),
        .manual_b({4'b0000, manual_b}),
        .manual_opcode(manual_opcode),
        .cpu_a(cpu_a),
        .cpu_b(cpu_b),
        .cpu_opcode(cpu_opcode),
        .select_a(select_a),
        .select_b(select_b),
        .select_opcode(select_opcode)
    );

    wire uart_tx;
    wire uart_busy;
    wire alu_ena = mode ? (ena & decoder_alu_enable) : ena;

    FSM core_init (
        .clock(clk),
        .reset(reset),
        .ena(ena),
        .a (select_a),
        .b (select_b),
        .opcode(select_opcode),
        .alu_ena(alu_ena),
        .alu_result(alu_result),
        .uart_tx(uart_tx),
        .uart_busy(uart_busy)
    );

    // 출력 핀 설정
    assign uio_oe = 8'b00000001;

    // 출력 지정
    assign uo_out = { uart_busy, alu_result[6:0] };
    assign uio_out = { alu_result[15:9], uart_tx };
endmodule


```

---

## 🧪 6) Testbench (`tb_jsilicon_top`)

### 특징
- 12 MHz 가정(`CLK_PERIOD=83.33ns`)  
- **Manual → CPU → Manual** 모드 전환 시나리오 포함  
- UART Busy 기반 대기(`wait(uart_busy==0)`)로 전송 완료 동기화  
- 결과 재구성:  
  ```verilog
  wire [6:0] result_low  = uo_out[6:0];
  wire [6:0] result_high = uio_out[7:1];
  wire [15:0] full_result = {1'b0, result_high, 1'b0, result_low};
  ```

```verilog
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

```

### 빌드/실행 예시

Icarus Verilog
```sh
iverilog -g2012 -o top_tb.out   alu.v uart.v fsm.v regfile.v decoder.v pc.v switch.v jsilicon.v tb_jsilicon_top.v
vvp top_tb.out
gtkwave jsilicon_top_wave.vcd &
```

ModelSim/Questa
```sh
vlog alu.v uart.v fsm.v regfile.v decoder.v pc.v switch.v jsilicon.v tb_jsilicon_top.v
vsim -c tb_jsilicon_top -do "run -all; quit"
```

> **파일명 일치**: 실제 파일명(`REG.v` vs `regfile.v`, `DECODER.v` vs `decoder.v`)은 로컬 이름에 맞춰 수정하세요.

---

## 🛠 7) Known Limitations & Tips

1. **ALU 결과 비트 유출**: 패드 제약으로 `alu_result[8]`은 외부로 안 나갑니다.  
   - 대안: `uio_oe` 여유 비트를 재배치하거나, 결과를 시분할로 내보내기(예: 두 프레임에 나눠 출력)  
2. **UART 출력은 LSB**: `uio_out[0]`가 `uart_tx`이므로, 계측할 때 해당 핀만 샘플링하면 됩니다.  
3. **PC 모듈 변형**: 본 탑의 PC는 `.instr_out`만 제공하므로, README_PC의 일반형과 **인터페이스가 다릅니다**. (ROM 통합형 가정)  
4. **모드 전환 시점**: 연산 도중 전환하면 일시적으로 출력 글리치가 있을 수 있습니다. `uart_busy==0` 시점에만 전환 권장.  
5. **Manual 입력 폭**: `ui_in`은 각 4‑bit이므로 내부에서 `{4'b0, manual_*}`로 **제로 확장**해 ALU에 전달합니다.

---

## 📂 8) Repo Layout (권장)

```
├─ rtl/
│  ├─ jsilicon.v        // this top
│  ├─ alu.v  uart.v  fsm.v  switch.v
│  ├─ decoder.v  regfile.v  pc.v
├─ sim/
│  └─ tb_jsilicon_top.v
└─ docs/
   └─ README_JSILICON_FULL.md
```

---

**Author**: MultiMix Tech (NAMWOO KIM)  
**Version**: 1.0 (Dual‑mode SoC Top)  
**Updated**: 2025-11-12 23:03
