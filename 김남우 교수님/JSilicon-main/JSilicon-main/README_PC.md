# PC — Program Counter + ROM (CPU mode)

> Module: `PC`  
> Role: **Instruction fetch** (4‑bit PC indexing an internal 16×8 ROM)  
> Nettype: ``default_nettype none``  
> Style: **TinyTapeout top**와 호환되는 단순 IF(Stage)

---

## 📘 1) 개요 (Overview)
`PC` 모듈은 4‑bit 프로그램 카운터를 사용해 **내장 ROM(16×8)** 에서 8‑bit 명령어를 읽어 `instr_out`으로 내보냅니다.  
`ena=1`인 사이클마다 PC가 1씩 증가하며, 지정된 **끝 주소(예: 3)**에 도달하면 **0으로 랩어라운드**합니다.

데이터 경로:
```
clk, reset, ena ──> [ PC (4b) ] ──> rom[pc] ──> instr_out[7:0]
```

---

## 🧠 2) 명령어 포맷(ISA fragment)
본 프로젝트의 공통 포맷을 따릅니다.
```
[7:5]=opcode, [4]=reg_sel, [3:0]=imm4
```
- 예) `ADD 3` ⇒ `8'b000_0_0011`  
- 현재 ROM 초기값 예시:
  - `rom[0] = 8'b00000011; // ADD 3`
  - `rom[1] = 8'b00100010; // SUB 2`
  - `rom[2] = 8'b01000101; // MUL 5`
  - `rom[3] = 8'b00000000; // NOP`
  - `rom[4..15] = 8'b00000000` (클리어)

---

## 🔌 3) 인터페이스

### 입력
| 이름 | 폭 | 설명 |
|------|---:|------|
| `clock` | 1 | 시스템 클럭 |
| `reset` | 1 | 비동기 High 리셋 |
| `ena` | 1 | Enable (1일 때 PC 진행) |

### 출력
| 이름 | 폭 | 설명 |
|------|---:|------|
| `instr_out` | 8 | ROM에서 페치한 명령 바이트 |

---

## 🔧 4) 코드 핵심

```verilog
// mode=1, program counter + rom
// 프로그램 카운터 + 롬 ( CPU 모드 1 인 경우 )

`define default_netname none

(* keep_hierarchy *)
module PC (
    input wire clock,
    input wire reset,
    input wire ena,

    // 디버그 포트 - JSilicon.v (TOP)에서 사용하지 않도록 설정하여 제거
    // output wire [3:0] pc_out,
    output wire [7:0] instr_out

    );

    reg [3:0] pc;
    // 하드코딩 롬 지정
    // wire 선언시 오류 발생 > reg로 수정
    reg [7:0] rom [0:15];

    // 내장 롬 명령어 지시 (프로그램)
    // 명령구조 : [7:5] = opcode, [4:0]=operand 
    // ex, ADD 3  = [000](opcode) + [00011](operand)
    // todo - FSM 명령어 추가하기 (25.10.06)  

    // 루프 변수 추가
    integer i; 
    initial begin
        // ADD 3
        rom[0] = 8'b00000011;
        // SUB 2
        rom[1] = 8'b00100010;
        // MUL 5
        rom[2] = 8'b01000101;
        // NOP
        rom[3] = 8'b00000000;

        //  Sky130 합성에 맞춰서 조정
        for (i = 4; i < 16; i = i + 1)
            // 데이터를 쓰기 전에는 0으로 채워두기
            rom[i] = 8'b00000000;
    end

    always @(posedge clock or posedge reset) begin
        // 명시적 비트폭(합성 경고 해결)로 지정
        if (reset) pc <= 4'd0;
        else if (ena) begin
            // 롬 명령어 끝까지 도달하면 0으로 로드
            if (pc == 4'd3)
                pc <= 4'd0;
            else
                pc <= pc + 1;
        end
    end

    // 포트명 오류 수정
    assign instr_out = rom[pc];

    // 디버그 포트 - 합성 과정에서 pc_out 포트 제거로 인한 제거
    // assign pc_out = pc;

endmodule
```

특징
- **간결한 IF 스테이지**: 분기/점프 없이 선형 실행 패턴
- **명시적 폭 지정**: `pc`는 4‑bit로 제한, 합성 경고 방지
- **내장 ROM**: 초기블록(`initial`)로 기본 프로그램 탑재

---

## ⏱ 5) 타이밍/합성 메모
- ROM은 합성 시 **LUT ROM/분산 RAM** 또는 **register init**로 매핑됩니다. (FPGA/PDK에 따라 다름)
- `instr_out`은 **동기 1‑cycle 지연**처럼 사용하세요: `pc`가 증가한 **다음 클럭**에 해당 인스트럭션을 상위(DECODER)가 샘플링하도록 설계하면 안전합니다.
- 프로그램 길이를 바꿀 경우 `pc == 4'd3` 비교 상수를 **끝 주소로 수정**하세요.

---

## 🧪 6) 제공된 테스트벤치(`tb_pc`)

### 테스트 항목
- **리셋/랩어라운드**: `pc`가 0→1→2→3→0 순환하는지
- **ENA 제어**: `ena=0`일 때 `pc`가 정지하는지
- **동작 중 리셋**: 동작 중 `reset=1` 시 `pc=0`으로 복귀

```verilog
// PC (Program Counter + ROM) Testbench for Xcelsium (Verilog-1995)
// Tests program counter and ROM instruction fetch

`timescale 1ns/1ps

module tb_pc;

    // Inputs
    reg clock;
    reg reset;
    reg ena;

    // Outputs
    wire [7:0] instr_out;

    // Clock period (12 MHz = 83.33ns)
    parameter CLK_PERIOD = 83.33;

    // Instantiate the PC
    PC uut (
        .clock(clock),
        .reset(reset),
        .ena(ena),
        .instr_out(instr_out)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end

    // Test procedure
    initial begin
        // Initialize VCD dump
        $dumpfile("pc_wave.vcd");
        $dumpvars(0, tb_pc);

        // Display header
        $display("========================================");
        $display("PC (Program Counter + ROM) Testbench");
        $display("========================================");
        $display("Time\t PC\t Instruction\t Opcode\t Operand\t Description");
        $display("------------------------------------------------------------------------");

        // Initialize inputs
        reset = 1;
        ena = 0;
        #(CLK_PERIOD*5);

        // Release reset
        reset = 0;
        #(CLK_PERIOD*5);

        // Enable PC
        ena = 1;
        #(CLK_PERIOD*2);

        // Run through one complete cycle (4 instructions)
        repeat(4) begin
            #(CLK_PERIOD);
            $display("%0t\t %d\t 8'b%b\t %b\t %b\t\t %s", 
                     $time, 
                     uut.pc, 
                     instr_out, 
                     instr_out[7:5],
                     instr_out[3:0],
                     decode_instruction(instr_out));
        end

        // Run one more cycle to verify wrap-around
        $display("\n--- Testing PC wrap-around ---");
        repeat(4) begin
            #(CLK_PERIOD);
            $display("%0t\t %d\t 8'b%b\t %b\t %b\t\t %s", 
                     $time, 
                     uut.pc, 
                     instr_out, 
                     instr_out[7:5],
                     instr_out[3:0],
                     decode_instruction(instr_out));
        end

        // Test enable control
        $display("\n--- Testing Enable Control (ena=0) ---");
        ena = 0;
        #(CLK_PERIOD*5);
        $display("%0t\t %d\t 8'b%b\t %b\t %b\t\t ENA=0 (PC should not change)", 
                 $time, uut.pc, instr_out, instr_out[7:5], instr_out[3:0]);

        // Re-enable
        ena = 1;
        #(CLK_PERIOD);
        $display("%0t\t %d\t 8'b%b\t %b\t %b\t\t ENA=1 (PC resumed)", 
                 $time, uut.pc, instr_out, instr_out[7:5], instr_out[3:0]);

        // Test reset during operation
        $display("\n--- Testing Reset during operation ---");
        #(CLK_PERIOD*2);
        reset = 1;
        #(CLK_PERIOD*2);
        $display("%0t\t %d\t 8'b%b\t %b\t %b\t\t RESET (PC should go to 0)", 
                 $time, uut.pc, instr_out, instr_out[7:5], instr_out[3:0]);
        
        reset = 0;
        #(CLK_PERIOD*2);

        // End simulation
        $display("\n========================================");
        $display("PC Testbench Complete");
        $display("========================================");
        #(CLK_PERIOD*5);
        $finish;
    end

    // Function to decode instruction
    function [255:0] decode_instruction;
        input [7:0] instr;
        reg [2:0] opcode;
        reg [3:0] operand;
        begin
            opcode = instr[7:5];
            operand = instr[3:0];
            
            case(opcode)
                3'b000: decode_instruction = "ADD";
                3'b001: decode_instruction = "SUB";
                3'b010: decode_instruction = "MUL";
                3'b011: decode_instruction = "DIV";
                3'b100: decode_instruction = "MOD";
                3'b101: decode_instruction = "CMP";
                3'b110: decode_instruction = "GT";
                3'b111: decode_instruction = "LT";
                default: decode_instruction = "UNKNOWN";
            endcase
        end
    endfunction

endmodule

```

### 실행 예시
Icarus Verilog
```sh
iverilog -g2012 -o pc_tb.out pc.v tb_pc.v
vvp pc_tb.out
gtkwave pc_wave.vcd &
```

ModelSim/Questa
```sh
vlog pc.v tb_pc.v
vsim -c tb_pc -do "run -all; quit"
```

> TB는 내부 `uut.pc` 접근을 통해 현재 PC 값을 인쇄합니다. 합성 대상에서는 이 포트를 노출하지 않는 게 일반적입니다.

---

## 🛠 7) 커스터마이즈 포인트
1. **프로그램 길이 변경**: `pc` 비교 상수(여기서는 `4'd3`)를 원하는 끝 주소로 변경
2. **분기/점프**: 분기 명령을 도입한다면, DECODER/CTRL에서 `pc_next`를 산출하여 `pc <= pc_next` 형태로 확장
3. **외부 ROM로 분리**: 대규모 프로그램은 별도 `IMEM` 모듈(초기화 파일 `.hex/.mem`)을 사용
4. **리셋 정책**: 동기 리셋으로 바꾸고 싶다면 `if (reset)` 분기를 동기식으로 이동
5. **TinyTapeout 제약**: 게이트/플롭 수를 줄이려면 프로그램을 더 짧게 하고 ROM 초기값을 최소화

---

## 📂 8) 디렉토리 구조(권장)
```
├─ rtl/
│  └─ pc.v
├─ sim/
│  └─ tb_pc.v
└─ docs/
   └─ README_PC_FULL.md
```

---

**작성자:** MultiMix Tech (NAMWOO KIM)  
**버전:** 1.0 (PC + Internal ROM)  
**업데이트:** 2025-11-12 23:09
