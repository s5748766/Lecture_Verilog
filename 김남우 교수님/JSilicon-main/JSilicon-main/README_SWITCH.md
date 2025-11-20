# SWITCH — CPU/Manual 모드 선택 멀티플렉서

> Module: `SWITCH`  
> Timescale: `1ns/1ps` (testbench 기준)  
> Nettype: ``default_nettype none``  
> Design Type: **1-bit 모드 신호 기반 3채널 MUX (A, B, OPCODE)**

---

## 📘 1) 개요 (Overview)
`SWITCH` 모듈은 **CPU 자동 모드**와 **수동(Manual) 모드** 사이에서 연산 입력을 선택하는 **조합 논리 멀티플렉서(MUX)** 입니다.  
`mode=0`이면 Manual 입력을, `mode=1`이면 CPU(내장 ROM/제어 로직) 입력을 선택해 ALU 쪽으로 전달합니다.

데이터 경로 요약:
```
Manual_a,b,opcode ─┐
                   ├─[ SWITCH (mode) ]─> select_a, select_b, select_opcode ──> ALU/FSM
CPU_a,b,opcode    ─┘
```

---

## 🧠 2) 이론 배경 — 멀티플렉서(MUX)
멀티플렉서는 여러 입력 중 **하나**를 선택해 출력으로 전달하는 조합 회로입니다.  
본 모듈은 **3개의 독립 채널(A, B, OPCODE)** 를 **동일한 1-bit select(mode)** 로 제어합니다.

일반식(2:1 MUX):  
\[ y = \bar{s} \cdot d_0 + s \cdot d_1 \]  
Verilog `assign`으로는 `y = s ? d1 : d0;` 와 동일합니다.

---

## 🔌 3) 인터페이스

### 입력
| 이름 | 방향 | 폭 | 설명 |
|------|------|----|------|
| `mode` | In | 1 | 0=Manual, 1=CPU |
| `manual_a` | In | 8 | 수동 모드 A |
| `manual_b` | In | 8 | 수동 모드 B |
| `manual_opcode` | In | 3 | 수동 모드 Opcode |
| `cpu_a` | In | 8 | CPU 모드 A |
| `cpu_b` | In | 8 | CPU 모드 B |
| `cpu_opcode` | In | 3 | CPU 모드 Opcode |

### 출력
| 이름 | 방향 | 폭 | 설명 |
|------|------|----|------|
| `select_a` | Out | 8 | 선택된 A |
| `select_b` | Out | 8 | 선택된 B |
| `select_opcode` | Out | 3 | 선택된 Opcode |

---

## 🧩 4) 코드 요약
```verilog
module SWITCH (
    input  wire        mode,
    input  wire [7:0]  manual_a, manual_b,
    input  wire [2:0]  manual_opcode,
    input  wire [7:0]  cpu_a, cpu_b,
    input  wire [2:0]  cpu_opcode,
    output wire [7:0]  select_a, select_b,
    output wire [2:0]  select_opcode
);
    assign select_a      = mode ? cpu_a      : manual_a;
    assign select_b      = mode ? cpu_b      : manual_b;
    assign select_opcode = mode ? cpu_opcode : manual_opcode;
endmodule
```

특징
- **완전 조합 회로**: 래치/플립플롭 없음 → 지연은 조합 경로 지연에 한정
- **동일 Select**: 입력 채널 간 불일치 방지를 위해 단일 `mode`로 동기 제어

---

## ⏱ 5) 타이밍 및 동기화
- `mode`가 **비동기**로 변화할 경우 **출력 글리치**가 발생할 수 있습니다.  
  - 해결: `mode`를 시스템 `clock` 도메인으로 **2FF 동기화** 후 사용
- `manual_*`/`cpu_*` 역시 비동기라면, 상위 모듈에서 래치/레지스터 단계로 **1-cycle 안정화**를 권장

권장 패턴(상위 모듈 예시):
```verilog
reg mode_d1, mode_sync;
always @(posedge clk) begin
  mode_d1   <= mode;
  mode_sync <= mode_d1; // 2FF sync
end
```

---

## 🧪 6) 제공된 Testbench 개요

- 시나리오
  1) **Manual 모드**에서 다양한 연산 인자/Opcode 선택 검증  
  2) **CPU 모드**에서 선택 검증  
  3) 모드 전환(Manual↔CPU) 시 출력이 즉시 기대값으로 바뀌는지 확인  
  4) 엣지 케이스(모든 0, 최대값 255) 확인  
- VCD 출력: `switch_wave.vcd`

```verilog
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

```

### 실행 예시

Icarus Verilog
```sh
iverilog -g2012 -o switch_tb.out switch.v tb_switch.v
vvp switch_tb.out
gtkwave switch_wave.vcd &
```

ModelSim/Questa
```sh
vlog switch.v tb_switch.v
vsim -c tb_switch -do "run -all; quit"
```

---

## 🛠 7) 설계적 고찰 & 확장 포인트
1. **안전한 모드 전환**: 연산 도중 모드 전환 시 시스템 일관성을 위해 **FSM에서 busy=0 구간에만 모드 변경 허용**하는 정책 권장  
2. **글리치 방지**: 상위에서 `mode`를 레지스터링하거나, `select_*`를 한 사이클 레지스터링해 다운스트림에 안정적 신호 제공  
3. **가드 로직**: 잘못된 Opcode(예약값) 필터링을 원하면, `mode`별 별도 Validation 가능  
4. **버스 확장**: 필요 시 데이터 폭/Opcode 폭을 파라미터화 (`parameter W=8, OW=3`)  
5. **테스트 더블링크**: SWITCH→ALU 경로까지 포함한 통합 TB로 함수적 등가 확인 추천

---

## 📂 8) 권장 디렉토리 구조
```
├─ rtl/
│  └─ switch.v     // SWITCH 모듈
├─ sim/
│  └─ tb_switch.v  // 제공된 테스트벤치
└─ docs/
   └─ README_SWITCH_FULL.md
```

---

**작성자:** MultiMix Tech (NAMWOO KIM)  
**버전:** 1.0 (Manual/CPU Mode Selector)  
**업데이트:** 2025-11-12 22:50
