# UART_TX — UART 송신기 (8N1 고정형)

> Module: `UART_TX`  
> Timescale: `1ns/1ps`  
> Nettype: ``default_nettype none``  
> Design Type: **TX-only, 8N1 fixed**

---

## 📘 1. UART 개요
UART(Universal Asynchronous Receiver/Transmitter)는 CPU와 외부 장치 간의 **비동기 직렬 통신**을 수행하는 핵심 회로입니다.  
송신기(TX)는 병렬 데이터를 직렬 신호로 변환하고, 수신기(RX)는 이를 다시 병렬 데이터로 복원합니다.

- 초기 RS-232 표준(1960년대)에서 발전
- Intel 8250 → 16450 → 16550 (FIFO 내장형) 칩으로 진화
- 현재는 **FPGA/SoC 내부 IP 코어** 형태로 내장

---

## ⚙️ 2. UART 전체 구성

```
           +--------------------------+
           |        CPU / BUS         |
           +-----------+--------------+
                       |
                       v
              +--------+--------+
              |   UART REGISTER |
              +--------+--------+
                       |
                       v
           +-----------+------------+
           | Baud Generator / Clock |
           +-----------+------------+
                       |
        +--------------+-------------+
        | TX Logic     | RX Logic    |
        | (Shift Out)  | (Shift In)  |
        +--------------+-------------+
                       |
                    Serial Line
```

이 설계에서는 TX 경로만 포함되어 있습니다.  
Start → Data bits(LSB first) → Stop 순서로 직렬화됩니다.


```verilog
// UART 외부 송신 모듈

//`define default_netname none
`timescale 1ns / 1ps
`default_nettype none

(* keep_hierarchy *)
module UART_TX(
    input wire clock,
    input wire reset,
    input wire start,
    input wire [7:0] data_in, 

    output reg tx,
    output reg busy
    );

    // CLOCK_DIV = Fclk / Baurate
    // 12,000,000 / 9600
    parameter CLOCK_DIV = 1250; // 시스템 클럭 9600bps 지정

    reg [7:0] data_reg;
    reg [2:0] bit_idx;
    reg [15:0] clock_count;
    reg [2:0] state;
    
    localparam IDLE = 3'd0;
    localparam START = 3'd1;
    localparam DATA = 3'd2;
    localparam STOP = 3'd3;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            tx <= 1'b1;
            busy <= 1'b0;
            state <= IDLE;
            clock_count <= 16'd0;
            bit_idx <= 3'd0;
        end else begin
            case (state)
            // 상태코드 분리
                // IDLE 상태 시
                IDLE: begin
                    tx <= 1'b1;
                    busy <= 1'b0;
                    if (start) begin
                        data_reg <= data_in;
                        state <= START;
                        busy <= 1'b1;
                    end
                end
                // START 
                START: begin
                    tx <= 1'b0; 
                    // 주기 비교용 클럭 읽기 수정
                    if (clock_count == CLOCK_DIV - 1) begin
                        clock_count <= 16'd0;
                        state <= DATA;
                        bit_idx <= 3'd0;
                    end else clock_count <= clock_count + 1'b1;
                end

                // DATA
                DATA: begin
                    tx <= data_reg[bit_idx];
                    if (clock_count == CLOCK_DIV - 1) begin
                        clock_count <= 16'd0;
                        if (bit_idx == 3'd7) begin
                            bit_idx <= 3'd0;
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1'b1;
                        end
                    end else clock_count <= clock_count + 1'b1;
                end

                // STOP
                STOP: begin
                    tx <= 1'b1;
                    if (clock_count == CLOCK_DIV - 1) begin
                        state <= IDLE;
                        busy <= 1'b0;
                        clock_count <= 16'd0;
                    end else clock_count <= clock_count + 1'b1;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
```

---

## 🔢 3. Baud Rate 계산

UART는 내부 클럭을 Baud rate로 분주합니다.

\$\$ Divider = \frac{F_{CLK}}{BAUD} \$\$

예시:  
`Fclk = 12 MHz`, `Baud = 9600 bps`  
→ Divider = 12,000,000 / 9600 = **1250**  
→ 코드의 `parameter CLOCK_DIV = 1250`이 이에 해당합니다.

Baud 오차율은 다음으로 계산합니다:

\$\$ Error(%) = \frac{|F_{CLK}/Divider - BAUD|}{BAUD} \times 100 \$\$

<img width="331" height="65" alt="001" src="https://github.com/user-attachments/assets/ae38af6b-8567-4823-be1a-c9f164d8ca76" />


> ⚠️ 2% 이하 오차율이면 대부분의 UART 간 통신에서 안정적입니다.

---

## ⏱ 4. UART 프레임 구조 (8N1)

| 항목 | 비트수 | 설명 |
|------|--------|------|
| Start | 1 | 항상 0 |
| Data  | 8 | LSB → MSB 순 |
| Parity | 0 | 없음 (N) |
| Stop | 1 | 항상 1 |

총 10비트로 구성되어 있으며, 9600bps 기준 약 **1.04ms/byte** 소요됩니다.

---

## 🧩 5. Verilog 코드 설명

```verilog
(* keep_hierarchy *)
module UART_TX(
    input wire clock,      // 시스템 클럭
    input wire reset,      // 비동기 리셋
    input wire start,      // 송신 시작 트리거
    input wire [7:0] data_in, // 송신할 8비트 데이터

    output reg tx,         // 직렬 출력 (Idle 시 High)
    output reg busy        // 송신 중이면 High
);
```

### 파라미터
| 이름 | 기본값 | 설명 |
|------|--------|------|
| `CLOCK_DIV` | 1250 | 12MHz → 9600bps Baud 분주기 |

### 내부 레지스터
| 이름 | 폭 | 설명 |
|------|----|------|
| `data_reg` | 8 | 송신 데이터 버퍼 |
| `bit_idx` | 3 | 현재 전송 중 비트 인덱스 |
| `clock_count` | 16 | Baud 카운터 |
| `state` | 3 | FSM 상태 |

### 상태 정의
```verilog
localparam IDLE  = 3'd0;
localparam START = 3'd1;
localparam DATA  = 3'd2;
localparam STOP  = 3'd3;
```

### FSM 동작 요약

| 상태 | TX 출력 | 동작 설명 |
|------|----------|------------|
| **IDLE** | 1 | 대기 상태. `start`=1이면 `data_in`을 latch하고 START로 전환 |
| **START** | 0 | Start bit 송신 (1비트 기간 유지) |
| **DATA** | data_reg[bit_idx] | LSB부터 순차 송신 (8비트) |
| **STOP** | 1 | Stop bit 송신 (1비트 기간 유지 후 IDLE 복귀) |

---

## ⚙️ 6. 실제 동작 타이밍

```
    Bit:    S 0 1 2 3 4 5 6 7 P
    TX : ___     _ _ _ _ _ _ _ ___
           |Start|<-- Data 8bit -->|Stop|
```

각 비트는 `CLOCK_DIV` 주기 동안 유지됩니다.  
즉, 12MHz/9600bps일 경우 한 비트당 약 104µs 유지됩니다.

---

## 🧠 7. 설계적 고려사항

1. **비동기 구조** — 송신측/수신측 클럭이 다르므로 Start Bit으로 동기화 필요.  
2. **Reset 안정화** — 초기 `tx=1`, `busy=0`으로 유지.  
3. **오차 누적 방지** — 분수분주기(Fractional Divider) 또는 Oversampling(×8, ×16) 구조 권장.  
4. **테스트 편의성** — 파형 확인 시 Start(0) → Data(LSB=bit0) → Stop(1) 순서 확인.  

---

## 🧪 8. Testbench 예시

```verilog
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

```

---

## 🧰 9. 확장형 UART 구조 이론

| 기능 | 설명 |
|------|------|
| **Parity 지원** | Even/Odd 선택 후 FSM에 Parity 상태 추가 |
| **Stop Bit 가변** | FSM에 STOP2 상태 추가 (2bit Stop) |
| **데이터 비트 가변** | `parameter DATA_BITS`로 7~9bit 설정 |
| **Fractional Baud Generator** | 정확도 향상 위해 분수 분주기 사용 |
| **Oversampling RX** | RX FSM은 16× Oversampling으로 Sampling 정확도 향상 |
| **FIFO 버퍼링** | TX/RX 버퍼링으로 CPU 부하 감소 |

---

## ⚙️ 10. 하드웨어 구현 시 고려사항

- **FPGA**: LUT 기반 FSM 및 Counter로 충분히 구현 가능  
- **ASIC**: Power/Timing trade-off를 고려하여 Clock Gating 추가 가능  
- **CDC**: RX 신호는 반드시 2FF 동기화 필요  
- **Baud Drift 허용 오차**: ±3% 이내 유지 권장  
- **검증**: Start/Stop 비트 타이밍, TX High Idle 유지 여부 확인

---

## 📂 11. 프로젝트 구조 예시

```
├─ rtl/
│  └─ UART_TX.v
├─ sim/
│  └─ tb_uart_tx.v
└─ docs/
   └─ README_UART.md
```

---

**작성자:** MultiMix Tech (NAMWOO KIM)  
**버전:** 1.0 (TX Only)  
**업데이트:** 2025-11-12 22:35
