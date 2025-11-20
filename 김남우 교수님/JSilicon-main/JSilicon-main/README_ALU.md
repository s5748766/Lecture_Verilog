# ALU — 8‑bit 연산기 (조합 논리, 16‑bit 결과)

> Module: `ALU`  
> Timescale: `1ns/1ps`  
> Nettype: ``default_nettype none``  
> Design Type: **Combinational ALU (8‑bit operands → 16‑bit result)**

---

## 📘 1) 개요 (Overview)
이 ALU는 8‑bit 피연산자 `a`, `b`와 3‑bit `opcode`를 입력받아 산술/비교 연산을 수행하고, **16‑bit 결과**를 출력합니다.  
`ena=1`일 때만 동작하며, 그렇지 않으면 결과는 기본값(0)으로 유지됩니다.  
모든 연산은 **조합 논리**로 구현되어 **1‑cycle latency(= 0 cycle, 동기레지스터 없음)**를 갖습니다.

데이터 경로 요약:
```
a[7:0], b[7:0], opcode ──> [ ALU (comb) ] ──> result[15:0]
                         ^
                        ena
```

---

## 🧠 2) 지원 연산 (opcode 매핑)

| opcode | 연산 | 설명 | 결과 폭 |
|-------:|------|------|---------|
| `000` | `a + b` | 8‑bit 덧셈(무부호) | `{8'b0, a+b}` |
| `001` | `a - b` | 8‑bit 뺄셈(무부호) | `{8'b0, a-b}` |
| `010` | `a * b` | 8×8 → 16‑bit 곱셈 | `a*b` |
| `011` | `a / b` | 8‑bit 정수 나눗셈 | `b==0 ? 0 : {8'b0, a/b}` |
| `100` | `a % b` | 8‑bit 정수 나머지 | `b==0 ? 0 : {8'b0, a%b}` |
| `101` | `a == b` | 비교(같음) | `1 → 16'h0001, else 16'h0000` |
| `110` | `a > b` | 비교(초과) | 동일 |
| `111` | `a < b` | 비교(미만) | 동일 |

> 비교 연산의 결과는 **Boolean(1/0)을 16‑bit로 표현**합니다. (LSB=1 → 참)

---

## 🔌 3) 인터페이스

### 입력
| 이름 | 폭 | 설명 |
|------|----|------|
| `a`, `b` | 8 | 피연산자(무부호) |
| `opcode` | 3 | 연산 선택 |
| `ena` | 1 | Enable (1일 때만 연산 유효) |

### 출력
| 이름 | 폭 | 설명 |
|------|----|------|
| `result` | 16 | 연산 결과 |

---

## 🔧 4) 코드 핵심 (요약)

```verilog
(* keep_hierarchy *)
module ALU(
  input  wire [7:0] a, b,
  input  wire [2:0] opcode,
  input  wire       ena,
  output reg  [15:0] result
);
  wire [15:0] multiply_temp = a * b;
  wire        div_by_zero   = (b == 8'h00);

  always @(*) begin
    result = 16'b0;
    if (ena) begin
      case (opcode)
        3'b000: result = {{8{1'b0}}, a + b};
        3'b001: result = {{8{1'b0}}, a - b};
        3'b010: result = multiply_temp;
        3'b011: result = div_by_zero ? 16'b0 : {{8{1'b0}}, a / b};
        3'b100: result = div_by_zero ? 16'b0 : {{8{1'b0}}, a % b};
        3'b101: result = (a == b) ? 16'h0001 : 16'h0000;
        3'b110: result = (a > b)  ? 16'h0001 : 16'h0000;
        3'b111: result = (a < b)  ? 16'h0001 : 16'h0000;
        default: result = 16'h0000;
      endcase
    end
  end
endmodule
```

특징
- **조합 논리**: `always @(*)`로 동작, 내부 레지스터/클럭 미사용  
- **폭 확장**: 덧셈/뺄셈/나눗셈/나머지는 8→16 제로확장 출력  
- **0 나눗셈 보호**: `b==0`이면 결과 0 정책(디폴트)

---

## ⏱ 5) 타이밍/합성 고려사항

1. **조합 경로 지연**: 곱셈(`*`) 연산은 타겟 FPGA/ASIC에 따라 **긴 경로**가 될 수 있습니다.  
   - 고속 동작 필요 시 **파이프라인 레지스터**(예: 결과를 1‑2 stage로 레지스터링) 추가 권장
2. **분기/사용 시점**: 상위 FSM에서 `result`를 사용하는 사이클에 **안정화 시간**을 고려하세요.
3. **연산기 자원**: FPGA에서는 DSP 슬라이스 사용이 유리. 합성 옵션에서 곱셈을 DSP에 매핑하도록 설정.
4. **부호 처리**: 본 ALU는 **무부호 연산** 기준입니다. 부호 연산이 필요하면 `signed` 선언 또는 변환이 필요.

---

## 🧪 6) 제공된 Testbench 요약

- 전 연산(ADD/SUB/MUL/DIV/MOD/EQ/GT/LT)을 개별 케이스로 검증  
- `b==0` 케이스로 나눗셈/나머지 보호 정책 검증  
- `ena`=0에서 결과가 0 유지되는지 확인  
- VCD 파형: `alu_wave.vcd`

```verilog
// ALU Testbench for Xcelsium (Verilog-1995)
// Tests all 8 ALU operations

`timescale 1ns/1ps

module tb_alu;

    // Inputs
    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] opcode;
    reg ena;

    // Outputs
    wire [15:0] result;

    // Instantiate the ALU
    ALU uut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .ena(ena),
        .result(result)
    );

    // Test procedure
    initial begin
        // Initialize VCD dump
        $dumpfile("alu_wave.vcd");
        $dumpvars(0, tb_alu);

        // Display header
        $display("========================================");
        $display("ALU Testbench Start");
        $display("========================================");
        $display("Time\t Opcode\t A\t B\t Result\t Operation");
        $display("----------------------------------------");

        // Initialize inputs
        a = 8'd0;
        b = 8'd0;
        opcode = 3'b000;
        ena = 1'b0;
        #10;

        // Enable ALU
        ena = 1'b1;
        #10;

        // Test 000: Addition
        a = 8'd15;
        b = 8'd10;
        opcode = 3'b000;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t ADD", $time, opcode, a, b, result);

        // Test 001: Subtraction
        a = 8'd20;
        b = 8'd7;
        opcode = 3'b001;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t SUB", $time, opcode, a, b, result);

        // Test 010: Multiplication
        a = 8'd12;
        b = 8'd5;
        opcode = 3'b010;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t MUL", $time, opcode, a, b, result);

        // Test 011: Division
        a = 8'd100;
        b = 8'd7;
        opcode = 3'b011;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t DIV", $time, opcode, a, b, result);

        // Test 100: Modulo
        a = 8'd100;
        b = 8'd7;
        opcode = 3'b100;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t MOD", $time, opcode, a, b, result);

        // Test 101: Equal comparison (true)
        a = 8'd50;
        b = 8'd50;
        opcode = 3'b101;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t EQ (==)", $time, opcode, a, b, result);

        // Test 101: Equal comparison (false)
        a = 8'd50;
        b = 8'd30;
        opcode = 3'b101;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t EQ (==)", $time, opcode, a, b, result);

        // Test 110: Greater than (true)
        a = 8'd60;
        b = 8'd30;
        opcode = 3'b110;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t GT (>)", $time, opcode, a, b, result);

        // Test 110: Greater than (false)
        a = 8'd20;
        b = 8'd40;
        opcode = 3'b110;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t GT (>)", $time, opcode, a, b, result);

        // Test 111: Less than (true)
        a = 8'd25;
        b = 8'd50;
        opcode = 3'b111;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t LT (<)", $time, opcode, a, b, result);

        // Test 111: Less than (false)
        a = 8'd75;
        b = 8'd50;
        opcode = 3'b111;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t LT (<)", $time, opcode, a, b, result);

        // Test division by zero protection
        a = 8'd100;
        b = 8'd0;
        opcode = 3'b011;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t DIV by 0", $time, opcode, a, b, result);

        // Test modulo by zero protection
        a = 8'd100;
        b = 8'd0;
        opcode = 3'b100;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t MOD by 0", $time, opcode, a, b, result);

        // Test with enable disabled
        ena = 1'b0;
        a = 8'd50;
        b = 8'd30;
        opcode = 3'b000;
        #10;
        $display("%0t\t %b\t %d\t %d\t %d\t ENA=0", $time, opcode, a, b, result);

        // End simulation
        #10;
        $display("========================================");
        $display("ALU Testbench Complete");
        $display("========================================");
        $finish;
    end

endmodule

```


### 실행 예시

Icarus Verilog
```sh
iverilog -g2012 -o alu_tb.out alu.v tb_alu.v
vvp alu_tb.out
gtkwave alu_wave.vcd &
```

ModelSim/Questa
```sh
vlog alu.v tb_alu.v
vsim -c tb_alu -do "run -all; quit"
```

---

## 🛠 7) 확장 포인트 (실무형 옵션)

1. **상태 플래그 출력**: `Z`(Zero), `C`(Carry), `N`(Negative), `V`(Overflow) 등 상태 레지스터 제공  
2. **부호 연산 모드**: `signed` 기반의 `add/sub/compare` (2’s complement) 지원  
3. **포화 산술(Saturating)**: 오버/언더플로 시 상한/하한으로 클램프  
4. **시프트/논리 연산**: AND/OR/XOR/NOT/SHL/SHR/ROL/ROR opcode 확장  
5. **파이프라인화**: `MUL/DIV` 경로에 레지스터 삽입, 주파수↑  
6. **예외 코드/트랩**: `b==0`시 특정 예외 코드를 출력하거나 인터럽트 유발  
7. **파라미터화**: `parameter W=8, OW=16`으로 폭 일반화 (N‑bit ALU)

---

## 📂 8) 권장 디렉토리 구조

```
├─ rtl/
│  └─ alu.v
├─ sim/
│  └─ tb_alu.v
└─ docs/
   └─ README_ALU_FULL.md
```

---

**작성자:** MultiMix Tech (NAMWOO KIM)  
**버전:** 1.0 (Comb ALU, Unsigned)  
**업데이트:** 2025-11-12 23:00
