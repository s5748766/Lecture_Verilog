# DECODER — 명령어 디코더 (8-bit ISA, ALU 제어 신호 생성)

> Module: `DECODER`  
> Timescale: `1ns/1ps`  
> Nettype: ``default_nettype none``  
> Design Type: **Synchronous Instruction Decoder (1-cycle decode)**

---

## 📘 1) 개요 (Overview)
`DECODER`는 8비트 명령어를 해독해 **ALU 제어 신호**와 **레지스터 선택/쓰기 제어**를 생성합니다.  
명령어는 다음과 같은 **고정 포맷**을 가집니다:

```
 [7:5]   [4]      [3:0]
 opcode  reg_sel  operand(imm4)
```

- `opcode` : ALU 연산 종류 선택 (ADD/SUB/MUL/DIV/MOD/CMP 등)  
- `reg_sel`: 대상/소스 레지스터 선택 비트 (예: 0=R0, 1=R1)  
- `operand`: 즉시값(imm4) — 상위 로직에서 확장/사용

디코더는 `ena=1`일 때만 유효한 출력을 발생합니다.

---

## 🧠 2) 디코더 이론 및 설계 원칙

- **Decode Stage(해독 단계)**: Fetch된 명령어를 해독하여 **제어 신호(Control Signals)** 생성  
- **Single-cycle Decode**: 본 모듈은 `posedge clock`에서 **1사이클 내**에 해독 결과를 출력 레지스터에 반영  
- **Hazard-Free 기본형**: 파이프라인 구조가 아니므로 데이터/컨트롤 해저드 처리 로직은 상위에서 담당

제어 신호 요약:
- `alu_opcode`  : ALU에 전달할 연산 코드 (3비트)  
- `operand`     : 즉시값 (4비트)  
- `reg_sel`     : 레지스터 선택 (0=R0, 1=R1)  
- `alu_enable`  : ALU 실행 트리거 (1=실행)  
- `write_enable`: 연산 결과를 레지스터에 기록할지 여부

---

## 🔌 3) 인터페이스

### 입력
| 이름 | 방향 | 폭 | 설명 |
|------|------|----|------|
| `clock` | In | 1 | 시스템 클럭 |
| `reset` | In | 1 | 비동기 High 리셋 |
| `ena` | In | 1 | Decode Enable |
| `instr_in` | In | 8 | Fetch된 명령어 |

### 출력
| 이름 | 방향 | 폭 | 설명 |
|------|------|----|------|
| `alu_opcode` | Out | 3 | ALU 오퍼레이션 코드 |
| `operand` | Out | 4 | 즉시값(imm4) |
| `reg_sel` | Out | 1 | 대상 레지스터 선택 |
| `alu_enable` | Out | 1 | ALU 실행 허용 |
| `write_enable` | Out | 1 | 레지스터 쓰기 허용 |

---

## 🗂 4) ISA 매핑 (현재 정의)

| opcode `[7:5]` | 연산 | 설명 | `alu_enable` | `write_enable` |
|----------------|------|------|--------------|----------------|
| `000` | ADD | 덧셈 | 1 | 1 |
| `001` | SUB | 뺄셈 | 1 | 1 |
| `010` | MUL | 곱셈 | 1 | 1 |
| `011` | DIV | 나눗셈 | 1 | 1 |
| `100` | MOD | 나머지 | 1 | 1 |
| `101` | CMP | 비교(== 등) | 1 | 0 |
| `110` | — | 미정/예약 | 0 | 0 |
| `111` | — | 미정/예약 | 0 | 0 |

> 필요 시 `101`(CMP)에 대해 결과 플래그를 별도 플래그 레지스터로 보관하는 구조를 상위에서 설계할 수 있습니다.

---

## 🔧 5) 코드 요약 및 동작

```verilog
// 명령어 디코더 (Instruction Decoder)

`define default_netname none

(* keep_hierarchy *)
module DECODER (
    input wire clock,
    input wire reset,
    input wire ena,

    // PC 명령어 입력
    input wire [7:0] instr_in,

    output reg [2:0] alu_opcode,
    output reg [3:0] operand,
    // ALU 
    // 레지스터 선택기
    output reg reg_sel,
    // ALU 실행 명령
    output reg alu_enable,
    // 레지스터 쓰기 허용
    output reg write_enable
    );

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            alu_opcode <= 3'b000;
            operand <= 4'b0000;
            reg_sel <= 1'b0;
            alu_enable <= 1'b0;
            write_enable <= 1'b0;
        end else if (ena) begin
            // 명령구조 : [7:5] = opcode, [4:0]=operand 
            // ex, ADD 3  = [000](opcode) + [00011](operand)
            // 명령어 종류 (opcode)

            alu_opcode <= instr_in[7:5];
            // 목적지 레지스터 선택
            reg_sel <= instr_in[4];
            // 즉시 명령 입력 (즉시값)
            operand <= instr_in[3:0];

            // 파서 구조화
            case (instr_in[7:5])
                // AND, SUB, MUL (ALU 필요)
                3'b000, 3'b001, 3'b010: begin
                    alu_enable <= 1'b1;
                    write_enable <= 1'b1;
                end
                // DIV, MOD (ALU 필요)
                3'b011, 3'b100: begin
                    alu_enable <= 1'b1;
                    write_enable <= 1'b1;
                end
                // CMP (==)
                3'b101: begin
                    // 레지스터 불필요
                    alu_enable <= 1'b1;
                    write_enable <= 1'b0;
                end

                // NOP or Undefined
                default: begin
                    alu_enable <= 1'b0;
                    write_enable <= 1'b0;
                end
            endcase
        end else begin
            //ena Off 인 경우
            // latch 생성 방지
            alu_opcode <= 3'b000;
            operand <= 4'b0000;
            reg_sel <= 1'b0;
            alu_enable <= 1'b0;
            write_enable <= 1'b0;
        end
    end


endmodule

```

특징
- **동기식 Decode**: 모든 출력은 클럭 에지에서만 갱신 → 글리치 최소화  
- **ena gating**: `ena=0`이면 모든 출력 0으로 유지해 **래치 생성 방지**  
- **비동기 리셋**: 리셋 시 모든 출력이 0으로 초기화

---

## ⏱ 6) 타이밍 및 사용 예

- PC가 Instr Memory에서 읽어 온 바이트를 `instr_in`으로 입력  
- 다음 클럭에서 디코딩 결과가 유효
- `ena=1` 유지 동안 연속 명령 디코딩 가능 (본 TB는 1사이클 펄스 방식 사용)

예시 (ADD R1, 5):
```
instr_in = 8'b000_1_0101
           └─┬─┘ └─┬─┘
           opcode  imm4
               reg_sel=1
```

---

## 🧪 7) 제공된 Testbench 개요

- **VCD**: `decoder_tb.vcd` 덤프
- **리셋, ENA=0, 각 연산별 정상 동작, 정의되지 않은 opcode, 경계값, 연속 명령, 중간 리셋**까지 망라
- `check_output` 태스크로 기대값/실제값 비교, PASS/FAIL 카운트

```verilog
`timescale 1ns / 1ps
`default_nettype none

module DECODER_tb;
    // 테스트벤치 신호 선언
    reg clock;
    reg reset;
    reg ena;
    reg [7:0] instr_in;
    wire [2:0] alu_opcode;
    wire [3:0] operand;
    wire reg_sel;
    wire alu_enable;
    wire write_enable;
    
    // 테스트 카운터
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // DECODER 모듈 인스턴스화
    DECODER uut (
        .clock(clock),
        .reset(reset),
        .ena(ena),
        .instr_in(instr_in),
        .alu_opcode(alu_opcode),
        .operand(operand),
        .reg_sel(reg_sel),
        .alu_enable(alu_enable),
        .write_enable(write_enable)
    );
    
    // 클럭 생성 (10ns 주기 = 100MHz)
    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end
    
    // 결과 검증 태스크
    task check_output;
        input [2:0] exp_opcode;
        input [3:0] exp_operand;
        input exp_reg_sel;
        input exp_alu_en;
        input exp_write_en;
        input [200*8:1] test_name;
        begin
            test_count = test_count + 1;
            @(posedge clock);
            #1;
            
            if (alu_opcode === exp_opcode && 
                operand === exp_operand &&
                reg_sel === exp_reg_sel &&
                alu_enable === exp_alu_en &&
                write_enable === exp_write_en) begin
                $display("[PASS] Test %0d: %0s", test_count, test_name);
                $display("       instr=0x%h, opcode=%b, operand=%h, reg_sel=%b, alu_en=%b, wr_en=%b",
                         instr_in, alu_opcode, operand, reg_sel, alu_enable, write_enable);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %0d: %0s", test_count, test_name);
                $display("       instr=0x%h", instr_in);
                $display("       Expected: opcode=%b, operand=%h, reg_sel=%b, alu_en=%b, wr_en=%b",
                         exp_opcode, exp_operand, exp_reg_sel, exp_alu_en, exp_write_en);
                $display("       Got:      opcode=%b, operand=%h, reg_sel=%b, alu_en=%b, wr_en=%b",
                         alu_opcode, operand, reg_sel, alu_enable, write_enable);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    // 리셋 태스크
    task reset_dut;
        begin
            reset = 1'b1;
            ena = 1'b0;
            instr_in = 8'h00;
            repeat(2) @(posedge clock);
            reset = 1'b0;
            @(posedge clock);
        end
    endtask
    
    // 명령어 전송 태스크
    task send_instruction;
        input [7:0] instruction;
        begin
            @(posedge clock);
            instr_in = instruction;
            ena = 1'b1;
        end
    endtask
    
    // 메인 테스트 시퀀스
    initial begin
        // 초기화
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        clock = 1'b0;
        reset = 1'b0;
        ena = 1'b0;
        instr_in = 8'h00;
        
        $display("========================================");
        $display("DECODER Testbench 시작");
        $display("========================================");
        
        // 리셋 테스트
        $display("\n----- 리셋 테스트 -----");
        reset_dut;
        #1;
        check_output(3'b000, 4'b0000, 1'b0, 1'b0, 1'b0, "리셋 후 모든 출력 0");
        
        // ENA 비활성화 테스트
        $display("\n----- ENA=0 테스트 -----");
        ena = 1'b0;
        instr_in = 8'b000_0_1111; // ADD 명령어지만 ena=0
        @(posedge clock);
        #1;
        check_output(3'b000, 4'b0000, 1'b0, 1'b0, 1'b0, "ENA=0: 모든 출력 0");
        
        // ADD 명령어 테스트 (opcode=000)
        $display("\n----- ADD 명령어 테스트 (opcode=000) -----");
        
        send_instruction(8'b000_0_0011); // ADD R0, 3
        check_output(3'b000, 4'b0011, 1'b0, 1'b1, 1'b1, "ADD R0, 3");
        
        send_instruction(8'b000_1_0101); // ADD R1, 5
        check_output(3'b000, 4'b0101, 1'b1, 1'b1, 1'b1, "ADD R1, 5");
        
        send_instruction(8'b000_0_1111); // ADD R0, 15
        check_output(3'b000, 4'b1111, 1'b0, 1'b1, 1'b1, "ADD R0, 15");
        
        // SUB 명령어 테스트 (opcode=001)
        $display("\n----- SUB 명령어 테스트 (opcode=001) -----");
        
        send_instruction(8'b001_0_0010); // SUB R0, 2
        check_output(3'b001, 4'b0010, 1'b0, 1'b1, 1'b1, "SUB R0, 2");
        
        send_instruction(8'b001_1_0111); // SUB R1, 7
        check_output(3'b001, 4'b0111, 1'b1, 1'b1, 1'b1, "SUB R1, 7");
        
        // MUL 명령어 테스트 (opcode=010)
        $display("\n----- MUL 명령어 테스트 (opcode=010) -----");
        
        send_instruction(8'b010_0_0100); // MUL R0, 4
        check_output(3'b010, 4'b0100, 1'b0, 1'b1, 1'b1, "MUL R0, 4");
        
        send_instruction(8'b010_1_0110); // MUL R1, 6
        check_output(3'b010, 4'b0110, 1'b1, 1'b1, 1'b1, "MUL R1, 6");
        
        // DIV 명령어 테스트 (opcode=011)
        $display("\n----- DIV 명령어 테스트 (opcode=011) -----");
        
        send_instruction(8'b011_0_0010); // DIV R0, 2
        check_output(3'b011, 4'b0010, 1'b0, 1'b1, 1'b1, "DIV R0, 2");
        
        send_instruction(8'b011_1_0011); // DIV R1, 3
        check_output(3'b011, 4'b0011, 1'b1, 1'b1, 1'b1, "DIV R1, 3");
        
        // MOD 명령어 테스트 (opcode=100)
        $display("\n----- MOD 명령어 테스트 (opcode=100) -----");
        
        send_instruction(8'b100_0_0101); // MOD R0, 5
        check_output(3'b100, 4'b0101, 1'b0, 1'b1, 1'b1, "MOD R0, 5");
        
        send_instruction(8'b100_1_1000); // MOD R1, 8
        check_output(3'b100, 4'b1000, 1'b1, 1'b1, 1'b1, "MOD R1, 8");
        
        // CMP 명령어 테스트 (opcode=101)
        $display("\n----- CMP 명령어 테스트 (opcode=101) -----");
        
        send_instruction(8'b101_0_0000); // CMP R0, 0
        check_output(3'b101, 4'b0000, 1'b0, 1'b1, 1'b0, "CMP R0, 0 (write_enable=0)");
        
        send_instruction(8'b101_1_1111); // CMP R1, 15
        check_output(3'b101, 4'b1111, 1'b1, 1'b1, 1'b0, "CMP R1, 15 (write_enable=0)");
        
        // 정의되지 않은 명령어 테스트 (opcode=110, 111)
        $display("\n----- 정의되지 않은 명령어 테스트 -----");
        
        send_instruction(8'b110_0_0001); // Undefined opcode
        check_output(3'b110, 4'b0001, 1'b0, 1'b0, 1'b0, "Undefined opcode=110");
        
        send_instruction(8'b111_1_1010); // Undefined opcode
        check_output(3'b111, 4'b1010, 1'b1, 1'b0, 1'b0, "Undefined opcode=111");
        
        // 경계값 테스트
        $display("\n----- 경계값 테스트 -----");
        
        send_instruction(8'b000_0_0000); // ADD R0, 0 (최소값)
        check_output(3'b000, 4'b0000, 1'b0, 1'b1, 1'b1, "ADD R0, 0 (최소 operand)");
        
        send_instruction(8'b000_1_1111); // ADD R1, 15 (최대값)
        check_output(3'b000, 4'b1111, 1'b1, 1'b1, 1'b1, "ADD R1, 15 (최대 operand)");
        
        // 연속 명령어 테스트
        $display("\n----- 연속 명령어 테스트 -----");
        
        send_instruction(8'b000_0_0001); // ADD R0, 1
        check_output(3'b000, 4'b0001, 1'b0, 1'b1, 1'b1, "연속 1: ADD R0, 1");
        
        send_instruction(8'b001_0_0001); // SUB R0, 1
        check_output(3'b001, 4'b0001, 1'b0, 1'b1, 1'b1, "연속 2: SUB R0, 1");
        
        send_instruction(8'b010_0_0010); // MUL R0, 2
        check_output(3'b010, 4'b0010, 1'b0, 1'b1, 1'b1, "연속 3: MUL R0, 2");
        
        // ENA 토글 테스트
        $display("\n----- ENA 토글 테스트 -----");
        
        send_instruction(8'b000_0_0101); // ADD R0, 5
        check_output(3'b000, 4'b0101, 1'b0, 1'b1, 1'b1, "ENA=1: ADD R0, 5");
        
        @(posedge clock);
        ena = 1'b0;
        instr_in = 8'b001_0_0011; // 명령어 변경
        @(posedge clock);
        #1;
        check_output(3'b000, 4'b0000, 1'b0, 1'b0, 1'b0, "ENA=0: 모든 출력 0");
        
        // 리셋 중간 테스트
        $display("\n----- 중간 리셋 테스트 -----");
        
        send_instruction(8'b010_1_1010); // MUL R1, 10
        @(posedge clock);
        
        reset = 1'b1;
        @(posedge clock);
        #1;
        check_output(3'b000, 4'b0000, 1'b0, 1'b0, 1'b0, "리셋 중: 모든 출력 0");
        
        reset = 1'b0;
        @(posedge clock);
        
        // 모든 opcode 순차 테스트
        $display("\n----- 모든 opcode 순차 테스트 -----");
        begin : opcode_loop
            integer i;
            for (i = 0; i < 8; i = i + 1) begin
                send_instruction({i[2:0], 1'b0, 4'b0001});
                @(posedge clock);
                #1;
                $display("  opcode=%b: alu_en=%b, wr_en=%b", 
                         i[2:0], alu_enable, write_enable);
            end
        end
        
        // 테스트 결과 요약
        #20;
        $display("\n========================================");
        $display("테스트 완료");
        $display("========================================");
        $display("총 테스트: %0d", test_count);
        $display("성공:      %0d", pass_count);
        $display("실패:      %0d", fail_count);
        if (test_count > 0) begin
            $display("성공률:    %0d%%", (pass_count * 100) / test_count);
        end
        $display("========================================");
        
        if (fail_count == 0) begin
            $display("모든 테스트 통과!");
        end else begin
            $display("일부 테스트 실패");
        end
        
        #10;
        $finish;
    end
    
    // 타임아웃 감시
    initial begin
        #10000;
        $display("\n[ERROR] 타임아웃! 테스트가 너무 오래 실행되었습니다.");
        $finish;
    end
    
    // 파형 덤프
    initial begin
        $dumpfile("decoder_tb.vcd");
        $dumpvars(0, DECODER_tb);
    end
    
endmodule
```



### 실행 예시

Icarus Verilog
```sh
iverilog -g2012 -o decoder_tb.out decoder.v DECODER_tb.v
vvp decoder_tb.out
gtkwave decoder_tb.vcd &
```

ModelSim/Questa
```sh
vlog decoder.v DECODER_tb.v
vsim -c DECODER_tb -do "run -all; quit"
```

> 파일명은 로컬 경로 기준으로 조정하세요. 모듈 파일명은 `decoder.v` 또는 `inst.v` 같은 관례를 따르길 권장합니다.

---

## 🛠 8) 설계적 고찰 & 확장 포인트

1. **ISA 확장**: `110/111`에 대한 신규 명령 추가(Shift/Logic/Load/Store/Branch 등).  
2. **즉시값 확장**: `imm4`를 상위 단계에서 **부호 확장(sign-extend)** 또는 **제로 확장(zero-extend)**.  
3. **레지스터 주소화**: 2레지스터(R0/R1)에서 다중 레지스터 파일로 확장 시, `reg_sel` 대신 `rd/rs` 주소 필드 도입.  
4. **마이크로코드**: 복잡한 명령(멀티클럭)을 위해 **Control ROM** 기반의 마이크로시퀀서로 확장 가능.  
5. **예외 처리**: 미정 opcode 사용 시 트랩/예외 인터럽트로 분기하는 상위 제어 로직.  
6. **파이프라인화**: IF/ID/EX 분리 시, ID 단계에서 디코딩 결과를 레지스터로 넘기며 **Hazard Unit** 설계 필요.

---

## 📂 9) 권장 디렉토리 구조

```
├─ rtl/
│  └─ decoder.v       // DECODER 모듈
├─ sim/
│  └─ DECODER_tb.v    // 제공된 테스트벤치
└─ docs/
   └─ README_DECODER_FULL.md
```

---

**작성자:** MultiMix Tech (NAMWOO KIM)  
**버전:** 1.0 (8-bit ISA Decoder)  
**업데이트:** 2025-11-12 22:56
