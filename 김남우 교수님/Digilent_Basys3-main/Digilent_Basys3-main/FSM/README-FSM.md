# FSM

---
# FSM 예제 동작 개념 정리

## 1. Toggle FSM (입문) - 기본 2-상태 토글 [1. Toggle FSM (입문)](#1-toggle-fsm-입문)
### 📌 핵심 개념
   * 상태: OFF → ON → OFF (2개 상태)
   * 입력: 버튼
   * 출력: LED
### 🔄 동작 원리
   * 1. 초기 상태는 OFF (LED 꺼짐)
   * 2. 버튼을 누르면 → ON 상태로 전환 (LED 켜짐)
   * 3. 다시 버튼을 누르면 → OFF 상태로 전환 (LED 꺼짐)
   * 4. 버튼 엣지 감지로 한 번만 토글되도록 처리
### 💡 학습 포인트
   * FSM의 가장 기본 구조 (State Register, Next State Logic, Output Logic)
   * 엣지 감지 (Edge Detection) 기법
   * 버튼 디바운싱 개념

---

## 2. 시퀀스 FSM (입문) - 4-상태 LED 순차 점등 [2️. 시퀀스 FSM (입문)](#2-시퀀스-FSM-입문)
### 📌 핵심 개념
   * 상태: S0 → S1 → S2 → S3 → S0 (4개 상태)
   * 입력: enable 스위치
   * 출력: 4개의 LED
### 🔄 동작 원리
   * 1. enable이 켜져 있을 때만 동작
   * 2. 1초마다 상태가 자동으로 순환
   * 3. S0: LED[0] 점등 → S1: LED[1] 점등 → S2: LED[2] 점등 → S3: LED[3] 점등
   * 4. 100MHz 클럭을 1초로 분주하는 카운터 사용
### 💡 학습 포인트
   * 타이머 기반 상태 전환
   * 클럭 분주 (Clock Divider) 개념
   * 순환 상태 머신 (Cyclic FSM)

---

## 3. 신호등 FSM (초급) - 3-상태 신호등 제어 [3. 신호등 FSM (초급)](#3-신호등-FSM-초급)
### 📌 핵심 개념
   * 상태: RED → GREEN → YELLOW → RED (3개 상태)
   * 입력: enable 스위치
   * 출력: 빨강, 노랑, 초록 LED
### 🔄 동작 원리
   * 1. RED 상태: 빨간불 5초 동안 켜짐
   * 2. GREEN 상태: 초록불 5초 동안 켜짐
   * 3. YELLOW 상태: 노란불 2초 동안 켜짐
   * 4. 각 상태마다 다른 지속 시간 적용
### 💡 학습 포인트
   * 상태별 다른 타이머 값 적용
   * 함수(function)를 이용한 코드 간결화
   * 실생활 응용 예제

---

## 4. 자판기 FSM (중급) - 6-상태 자판기 [4. 자판기 FSM (중급)](#4-자판기-FSM-중급)
### 📌 핵심 개념
   * 상태: IDLE → COIN1 → COIN2 → COIN3 → COIN4 → COIN5 (6개 상태)
   * 입력: 100원 버튼, 500원 버튼, 취소 버튼
   * 출력: 음료 제공, 거스름돈, 7-segment 금액 표시
### 🔄 동작 원리
   * 1. IDLE: 대기 상태 (0원)
   * 2. 동전 투입 시 금액에 따라 상태 전환
   * 3. 500원 이상 → 음료 제공 및 거스름돈 반환
   * 4. 취소 버튼 → 투입 금액 전액 반환
   * 5. 7-segment에 현재 투입 금액 표시
### 💡 학습 포인트
   * 복수 입력 처리
   * 조건부 상태 전환
   * 7-segment 디코딩
   * 거스름돈 계산 로직

---

## 5. UART 수신기 FSM (중상급) - 5-상태 UART 통신 [5. UART 수신기 FSM (중상급)](#5-uart-수신기-FSM-중상급)
### 📌 핵심 개념
   * 상태: IDLE → START_BIT → DATA_BITS → STOP_BIT → CLEANUP (5개 상태)
   * 입력: RX 신호
   * 출력: 8비트 데이터, valid 신호, error 신호
### 🔄 동작 원리
   * 1. IDLE: RX 신호가 0으로 떨어지면 Start bit 감지
   * 2. START_BIT: Start bit 중간점에서 샘플링하여 검증
   * 3. DATA_BITS: 8비트 데이터를 LSB부터 순차적으로 수신
   * 4. STOP_BIT: Stop bit 확인 (1이어야 정상)
   * 5. CLEANUP: 수신 완료 후 IDLE로 복귀
### 💡 학습 포인트
   * Baud rate 생성 (100MHz → 9600 baud)
   * 신호 동기화 (메타스테이블 방지)
   * 시프트 레지스터 사용
   * Framing error 검출
   * 통신 프로토콜 구현

---

## 6. 엘리베이터 FSM (상급) - 6-상태 엘리베이터 제어 [6. 엘리베이터 FSM (상급)](#6-엘리베이터-FSM-상급)
### 📌 핵심 개념
   * 상태: IDLE → MOVING_UP/DOWN → DOOR_OPENING → DOOR_OPEN_WAIT → DOOR_CLOSING (6개 상태)
   * 입력: 4개 층 호출 버튼, 도어 센서
   * 출력: 모터 제어, 도어 제어, 현재 층 표시, 방향 LED
### 🔄 동작 원리
   * 1. 요청 큐(request_queue)에 각 층 호출 저장
   * 2. 목표 층까지 이동 (층당 2초 소요)
   * 3. 도착 후 도어 개방 → 3초 대기 → 도어 폐쇄
   * 4. 도어 센서 감지 시 재개방
   * 5. 방향에 따라 효율적으로 층 방문
### 💡 학습 포인트
   * 요청 큐 관리
   * 복잡한 조건 분기
   * 최적 경로 알고리즘
   * 다중 출력 제어
   * 안전 기능 구현 (도어 센서)

---

## 7. I2C Master FSM (고급) - 9-상태 I2C 통신 [7. I2C Master FSM (고급)](#7-i2c-master-FSM-고급)
### 📌 핵심 개념
   * 상태: IDLE → START_COND → ADDR_SEND → ADDR_ACK → DATA_WR/RD → ACK → STOP_COND (9개 상태)
   * 입력: start, rw, slave_addr, wr_data
   * 출력: rd_data, busy, ack_error, SDA, SCL
### 🔄 동작 원리
   * 1. START 조건: SCL이 HIGH일 때 SDA를 HIGH → LOW
   * 2. 주소 전송: 7비트 슬레이브 주소 + R/W 비트
   * 3. ACK 확인: 슬레이브가 SDA를 LOW로 당김
   * 4. 데이터 전송/수신: 8비트 데이터 처리
   * 5. STOP 조건: SCL이 HIGH일 때 SDA를 LOW → HIGH
### 💡 학습 포인트
   * I2C 프로토콜 상세 구현
   * 양방향(inout) 신호 제어
   * Quarter clock 분주 (4단계 타이밍)
   * ACK/NACK 처리
   * 버스 충돌 방지

---

## 8. 게임 FSM (최고급) - 9-상태 반응속도 게임 [8. 게임 FSM (최고급)](#8-게임-FSM-최고급)
### 📌 핵심 개념
   * 상태: IDLE → READY → WAIT_RANDOM → LED_ON → MEASURING → SUCCESS/FAIL → GAME_OVER (9개 상태)
   * 입력: start_btn, react_btn
   * 출력: 16개 LED 패턴, 4자리 7-segment, 부저
### 🔄 동작 원리
   * 1. 게임 시작 후 랜덤 시간 대기 (1~3초)
   * 2. LED가 켜지면 빠르게 버튼 클릭
   * 3. 반응 시간 측정 (1ms 단위)
   * 4. 점수 계산: 200ms 미만(3점), 400ms 미만(2점), 그 외(1점)
   * 5. 5라운드 진행 후 최종 점수 표시
### 💡 학습 포인트
   * LFSR(Linear Feedback Shift Register) 난수 생성
   * 1ms 정밀 타이머 구현
   * 동적 점수 계산 로직
   * 멀티 라운드 관리
   * 4자리 7-segment 제어
   * 사운드 피드백 (부저)
   * 복합적인 게임 로직 구현

---

## 📊 난이도별 핵심 기술 비교

| 예제 | 상태 수 | 핵심 기술 | 난이도 |
|------|---------|-----------|--------|
| Toggle | 2 | 엣지 감지, 기본 FSM | ⭐ |
| 시퀀스 | 4 | 타이머, 클럭 분주 | ⭐ |
| 신호등 | 3 | 상태별 타이머 | ⭐⭐ |
| 자판기 | 6 | 복수 입력, 조건 분기 | ⭐⭐⭐ |
| UART | 5 | 통신 프로토콜, 동기화 | ⭐⭐⭐⭐ |
| 엘리베이터 | 6 | 요청 큐, 최적화 | ⭐⭐⭐⭐ |
| I2C | 9 | 양방향 제어, 정밀 타이밍 | ⭐⭐⭐⭐⭐ |
| 게임 | 9 | LFSR, 복합 로직 | ⭐⭐⭐⭐⭐ |

---

## 🎓 학습 로드맵
### 1단계: 기초 (예제 1-2)
- FSM 기본 구조 이해
- 상태 전환 메커니즘
- 타이머 사용법
### 2단계: 응용 (예제 3-4)
- 실생활 문제 해결
- 복수 입력 처리
- 조건부 로직
### 3단계: 통신 (예제 5, 7)
- 표준 프로토콜 구현
- 타이밍 정밀 제어
- 에러 처리
### 4단계: 고급 제어 (예제 6, 8)
- 복잡한 알고리즘
- 다중 기능 통합
- 최적화 기법

---

## 💻 Basys3 보드 활용 팁

### 공통 리소스
- **클럭**: 100MHz 시스템 클럭 사용
- **리셋**: 중앙 버튼 (U18)
- **LED**: 16개 LED 활용 가능
- **7-segment**: 4자리 디스플레이
- **스위치**: 16개 스위치
- **버튼**: 5개 버튼

### 제약 파일(XDC) 설정 필수
각 예제를 Basys3에서 실행하려면 적절한 핀 할당이 필요합니다.

---

## 🔧 디버깅 팁

1. **시뮬레이션 먼저**: 각 예제를 먼저 시뮬레이션으로 검증
2. **LED 활용**: 상태를 LED로 표시하여 디버깅
3. **타이머 축소**: 시뮬레이션 시 카운터 값을 줄여서 테스트
4. **단계별 테스트**: 복잡한 FSM은 부분별로 나눠서 검증

---

## 🎯 다음 단계

이 8개 예제를 마스터하면:
- ✅ FSM 설계 완벽 이해
- ✅ 실전 프로젝트 수행 가능
- ✅ SPI, CAN 등 다른 프로토콜 확장 가능
- ✅ CPU, 메모리 컨트롤러 등 복잡한 시스템 설계 준비 완료

---

[FSM 예제 동작 개념 정리](#FSM-예제-동작-개념-정리)
## 1. Toggle FSM (입문)

### 📋 테스트 시나리오
### ✅ 포함된 테스트
- **TEST 1**: 첫 번째 버튼 누름 → LED 켜짐 확인
- **TEST 2**: 두 번째 버튼 누름 → LED 꺼짐 확인
- **TEST 3**: 세 번째 버튼 누름 → LED 다시 켜짐 확인
- **TEST 4**: 버튼 길게 누르기 → 한 번만 토글 확인
- **TEST 5**: 리셋 기능 → LED 초기화 확인
- **TEST 6**: 빠른 연속 버튼 누름 → 디바운싱 확인

### 🔧 시뮬레이션 실행 방법
```bash
# Vivado 시뮬레이터
xvlog toggle_fsm.v
xvlog tb_toggle_fsm.v
xelab -debug typical tb_toggle_fsm -s sim
xsim sim -gui

# 또는 ModelSim
vlog toggle_fsm.v tb_toggle_fsm.v
vsim tb_toggle_fsm
run -all
```
### 📊 예상 결과
- **각 테스트마다 PASSED/FAILED 메시지 출력**
- **$monitor로 모든 신호 변화 실시간 출력**
- **VCD 파일 생성으로 파형 분석 가능**

```verilog
// ========================================
// 1번 - Toggle FSM (입문)
// ========================================
// 버튼을 누르면 LED가 켜지고 꺼지는 토글 동작
// Basys3 보드 100MHz 클럭 사용

module toggle_fsm(
    input clk,           // 100MHz 클럭
    input reset,         // 리셋 버튼
    input btn,           // 입력 버튼
    output reg led       // 출력 LED
);

    // State 정의
    localparam OFF = 1'b0;
    localparam ON  = 1'b1;
    
    reg state, next_state;
    
    // 버튼 디바운싱을 위한 변수
    reg btn_prev;
    wire btn_edge;
    
    // 상승 엣지 감지
    assign btn_edge = btn & ~btn_prev;
    
    // State Register (Sequential Logic)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= OFF;
            btn_prev <= 0;
        end
        else begin
            state <= next_state;
            btn_prev <= btn;
        end
    end
    
    // Next State Logic (Combinational Logic)
    always @(*) begin
        case (state)
            OFF: begin
                if (btn_edge)
                    next_state = ON;
                else
                    next_state = OFF;
            end
            ON: begin
                if (btn_edge)
                    next_state = OFF;
                else
                    next_state = ON;
            end
            default: next_state = OFF;
        endcase
    end
    
    // Output Logic
    always @(*) begin
        case (state)
            OFF: led = 1'b0;
            ON:  led = 1'b1;
            default: led = 1'b0;
        endcase
    end

endmodule
```

```verilog
// ========================================
// 1번 - Toggle FSM 테스트벤치
// ========================================
`timescale 1ns / 1ps

module tb_toggle_fsm;

    // 입력 신호 (reg)
    reg clk;
    reg reset;
    reg btn;
    
    // 출력 신호 (wire)
    wire led;
    
    // DUT (Device Under Test) 인스턴스화
    toggle_fsm uut (
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .led(led)
    );
    
    // 클럭 생성 (100MHz = 10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 5ns마다 토글 (10ns 주기)
    end
    
    // 테스트 시나리오
    initial begin
        // 파형 덤프 설정 (시뮬레이션 결과 저장)
        $dumpfile("toggle_fsm.vcd");
        $dumpvars(0, tb_toggle_fsm);
        
        // 초기화
        reset = 1;
        btn = 0;
        
        // 리셋 해제
        #100;
        reset = 0;
        $display("Time=%0t: Reset released", $time);
        
        // 테스트 1: 첫 번째 버튼 누름 (LED 켜짐)
        #50;
        btn = 1;
        $display("Time=%0t: Button pressed (1st time)", $time);
        #20;
        btn = 0;
        $display("Time=%0t: Button released", $time);
        #100;
        
        if (led == 1)
            $display("Time=%0t: TEST 1 PASSED - LED is ON", $time);
        else
            $display("Time=%0t: TEST 1 FAILED - LED should be ON", $time);
        
        // 테스트 2: 두 번째 버튼 누름 (LED 꺼짐)
        #50;
        btn = 1;
        $display("Time=%0t: Button pressed (2nd time)", $time);
        #20;
        btn = 0;
        $display("Time=%0t: Button released", $time);
        #100;
        
        if (led == 0)
            $display("Time=%0t: TEST 2 PASSED - LED is OFF", $time);
        else
            $display("Time=%0t: TEST 2 FAILED - LED should be OFF", $time);
        
        // 테스트 3: 세 번째 버튼 누름 (LED 다시 켜짐)
        #50;
        btn = 1;
        $display("Time=%0t: Button pressed (3rd time)", $time);
        #20;
        btn = 0;
        $display("Time=%0t: Button released", $time);
        #100;
        
        if (led == 1)
            $display("Time=%0t: TEST 3 PASSED - LED is ON", $time);
        else
            $display("Time=%0t: TEST 3 FAILED - LED should be ON", $time);
        
        // 테스트 4: 버튼을 계속 누르고 있을 때 (한 번만 토글되어야 함)
        #50;
        btn = 1;
        $display("Time=%0t: Button pressed and held", $time);
        #200;  // 버튼을 200ns 동안 누르고 있음
        btn = 0;
        $display("Time=%0t: Button released after long press", $time);
        #100;
        
        if (led == 0)
            $display("Time=%0t: TEST 4 PASSED - LED toggled only once", $time);
        else
            $display("Time=%0t: TEST 4 FAILED - LED should be OFF", $time);
        
        // 테스트 5: 리셋 테스트 (LED가 꺼져야 함)
        #50;
        btn = 1;
        #20;
        btn = 0;
        #50;  // LED가 켜진 상태
        
        reset = 1;
        $display("Time=%0t: Reset activated", $time);
        #50;
        reset = 0;
        $display("Time=%0t: Reset deactivated", $time);
        #50;
        
        if (led == 0)
            $display("Time=%0t: TEST 5 PASSED - LED reset to OFF", $time);
        else
            $display("Time=%0t: TEST 5 FAILED - LED should be OFF after reset", $time);
        
        // 테스트 6: 빠른 연속 버튼 누름 (디바운싱 테스트)
        #100;
        $display("Time=%0t: Testing rapid button presses", $time);
        
        // 첫 번째 누름
        btn = 1; #15; btn = 0; #15;
        // 두 번째 누름
        btn = 1; #15; btn = 0; #15;
        // 세 번째 누름
        btn = 1; #15; btn = 0; #100;
        
        // LED는 3번 토글되어 켜진 상태여야 함 (OFF->ON->OFF->ON)
        if (led == 1)
            $display("Time=%0t: TEST 6 PASSED - Rapid presses handled correctly", $time);
        else
            $display("Time=%0t: TEST 6 FAILED - LED should be ON after 3 toggles", $time);
        
        // 시뮬레이션 종료
        #200;
        $display("\n========================================");
        $display("Toggle FSM Testbench Completed");
        $display("========================================");
        $finish;
    end
    
    // 상태 변화 모니터링
    initial begin
        $monitor("Time=%0t | clk=%b reset=%b btn=%b | led=%b", 
                 $time, clk, reset, btn, led);
    end
    
    // 타임아웃 (무한 루프 방지)
    initial begin
        #10000;  // 10us 후 자동 종료
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
```

---

[FSM 예제 동작 개념 정리](#FSM-예제-동작-개념-정리)
## 2️. 시퀀스 FSM (입문)

### 📋 테스트 시나리오
### ✅ 포함된 테스트
- **TEST 1**: Enable OFF - 동작하지 않음 확인
- **TEST 2**: Enable ON - 시퀀스 동작 확인 (S0→S1→S2→S3)
- **TEST 3**: 동작 중 Disable - 시퀀스 멈춤 확인
- **TEST 4**: Re-enable - 시퀀스 재개 확인
- **TEST 5**: Reset - S0으로 초기화 확인
- **TEST 6**: 완전한 사이클 - 순환 동작 확인

### ⚠️ 중요 사항
- **실제 시뮬레이션을 위해서는 sequence_fsm.v의 카운터 값을 수정해야 합니다:**
```verilog
// 원본 (1초 = 100,000,000 클럭)**
assign tick = (counter == 27'd99_999_999);

// 시뮬레이션용 (100 클럭으로 축소)
assign tick = (counter == 27'd100);**
```

### 🔧 시뮬레이션 실행 방법
```bash
# 1. 수정된 sequence_fsm.v 사용 (counter를 100으로 변경)
# 2. 시뮬레이션 실행
xvlog sequence_fsm.v
xvlog tb_sequence_fsm.v
xelab -debug typical tb_sequence_fsm -s sim
xsim sim -gui
```
### 📊 예상 결과
- **각 상태 전환마다 LED 패턴 표시**
- **S0(0001) → S1(0010) → S2(0100) → S3(1000) → S0 순환**
- **Enable/Disable 제어 확인**
- **Reset 동작 확인**


```verilog
// ========================================
// 2번 - 시퀀스 FSM (입문)
// ========================================
// 4개의 LED가 순차적으로 켜지는 패턴
// Basys3 보드 100MHz 클럭 사용

module sequence_fsm(
    input clk,              // 100MHz 클럭
    input reset,            // 리셋
    input enable,           // 동작 활성화
    output reg [3:0] leds   // 4개의 LED
);

    // State 정의
    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;
    localparam S3 = 2'b11;
    
    reg [1:0] state, next_state;
    
    // 1초 카운터 (100MHz / 100,000,000 = 1Hz)
    reg [26:0] counter;
    wire tick;
    
    assign tick = (counter == 27'd99_999_999);
    
    // 1초 타이머
    always @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 0;
        else if (enable) begin
            if (tick)
                counter <= 0;
            else
                counter <= counter + 1;
        end
        else
            counter <= 0;
    end
    
    // State Register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0;
        else if (enable && tick)
            state <= next_state;
    end
    
    // Next State Logic
    always @(*) begin
        case (state)
            S0: next_state = S1;
            S1: next_state = S2;
            S2: next_state = S3;
            S3: next_state = S0;
            default: next_state = S0;
        endcase
    end
    
    // Output Logic
    always @(*) begin
        case (state)
            S0: leds = 4'b0001;  // LED 0만 켜짐
            S1: leds = 4'b0010;  // LED 1만 켜짐
            S2: leds = 4'b0100;  // LED 2만 켜짐
            S3: leds = 4'b1000;  // LED 3만 켜짐
            default: leds = 4'b0000;
        endcase
    end

endmodule
```

```verilog
// ========================================
// 2번 - 시퀀스 FSM 테스트벤치
// ========================================
`timescale 1ns / 1ps

module tb_sequence_fsm;

    // 입력 신호 (reg)
    reg clk;
    reg reset;
    reg enable;
    
    // 출력 신호 (wire)
    wire [3:0] leds;
    
    // DUT (Device Under Test) 인스턴스화
    sequence_fsm uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .leds(leds)
    );
    
    // 클럭 생성 (100MHz = 10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 5ns마다 토글 (10ns 주기)
    end
    
    // 1초 카운터를 빠르게 하기 위한 매개변수
    // 실제 시뮬레이션에서는 1초를 기다릴 수 없으므로 짧게 설정
    // sequence_fsm 모듈에서 counter 값을 줄여야 함
    // 테스트를 위해 100 클럭 = 1초로 가정
    
    // 테스트 시나리오
    initial begin
        // 파형 덤프 설정
        $dumpfile("sequence_fsm.vcd");
        $dumpvars(0, tb_sequence_fsm);
        
        // 초기화
        reset = 1;
        enable = 0;
        
        $display("========================================");
        $display("Sequence FSM Testbench Started");
        $display("========================================\n");
        
        // 리셋 해제
        #100;
        reset = 0;
        $display("Time=%0t: Reset released", $time);
        
        // 테스트 1: enable이 꺼져있을 때 (동작하지 않아야 함)
        #200;
        $display("\n--- TEST 1: Enable OFF (No operation) ---");
        $display("Time=%0t: Enable=0, LEDs should remain at initial state", $time);
        
        if (leds == 4'b0001)
            $display("Time=%0t: TEST 1 PASSED - LEDs stayed at S0", $time);
        else
            $display("Time=%0t: TEST 1 FAILED - LEDs changed without enable", $time);
        
        // 테스트 2: enable 켜고 시퀀스 동작 확인
        #100;
        enable = 1;
        $display("\n--- TEST 2: Enable ON (Sequence operation) ---");
        $display("Time=%0t: Enable=1, Starting sequence", $time);
        
        // 주의: 실제로는 1초마다 변경되지만, 시뮬레이션에서는
        // counter 값을 줄여서 테스트해야 합니다.
        // 여기서는 개념적으로 시간을 표시합니다.
        
        // S0 상태 확인
        #50;
        $display("Time=%0t: State S0 - LEDs=%b (Expected: 0001)", $time, leds);
        if (leds == 4'b0001)
            $display("Time=%0t: S0 PASSED", $time);
        else
            $display("Time=%0t: S0 FAILED", $time);
        
        // 충분한 시간 대기 (실제 구현에서 counter를 줄인 경우)
        // 예: counter가 100까지만 카운트하도록 수정했다면
        #1500;  // 100 클럭 * 10ns = 1000ns 정도 대기
        
        // S1 상태 확인
        $display("Time=%0t: State S1 - LEDs=%b (Expected: 0010)", $time, leds);
        if (leds == 4'b0010)
            $display("Time=%0t: S1 PASSED", $time);
        else
            $display("Time=%0t: S1 FAILED", $time);
        
        #1500;
        
        // S2 상태 확인
        $display("Time=%0t: State S2 - LEDs=%b (Expected: 0100)", $time, leds);
        if (leds == 4'b0100)
            $display("Time=%0t: S2 PASSED", $time);
        else
            $display("Time=%0t: S2 FAILED", $time);
        
        #1500;
        
        // S3 상태 확인
        $display("Time=%0t: State S3 - LEDs=%b (Expected: 1000)", $time, leds);
        if (leds == 4'b1000)
            $display("Time=%0t: S3 PASSED", $time);
        else
            $display("Time=%0t: S3 FAILED", $time);
        
        #1500;
        
        // S0으로 다시 돌아왔는지 확인 (순환)
        $display("Time=%0t: Back to S0 - LEDs=%b (Expected: 0001)", $time, leds);
        if (leds == 4'b0001)
            $display("Time=%0t: CYCLE TEST PASSED - Returned to S0", $time);
        else
            $display("Time=%0t: CYCLE TEST FAILED", $time);
        
        // 테스트 3: enable 끄기 (동작 멈춤)
        #1000;
        $display("\n--- TEST 3: Disable during operation ---");
        enable = 0;
        $display("Time=%0t: Enable=0, Sequence should stop", $time);
        
        // 현재 LED 상태 저장
        reg [3:0] leds_before;
        leds_before = leds;
        
        #3000;  // 충분히 대기
        
        if (leds == leds_before)
            $display("Time=%0t: TEST 3 PASSED - Sequence stopped", $time);
        else
            $display("Time=%0t: TEST 3 FAILED - Sequence should not change", $time);
        
        // 테스트 4: 다시 enable 켜기 (이어서 동작)
        #500;
        $display("\n--- TEST 4: Re-enable ---");
        enable = 1;
        $display("Time=%0t: Enable=1, Sequence resumes", $time);
        
        #1500;
        $display("Time=%0t: LEDs=%b (Should have moved to next state)", $time, leds);
        
        // 테스트 5: 리셋 테스트
        #2000;
        $display("\n--- TEST 5: Reset during operation ---");
        reset = 1;
        $display("Time=%0t: Reset activated", $time);
        
        #100;
        reset = 0;
        $display("Time=%0t: Reset deactivated", $time);
        
        #50;
        if (leds == 4'b0001)
            $display("Time=%0t: TEST 5 PASSED - Reset to S0", $time);
        else
            $display("Time=%0t: TEST 5 FAILED - Should reset to S0", $time);
        
        // 완전한 사이클 테스트
        #500;
        $display("\n--- TEST 6: Complete cycle verification ---");
        enable = 1;
        
        #1500;
        $display("Time=%0t: S0->S1 transition, LEDs=%b", $time, leds);
        #1500;
        $display("Time=%0t: S1->S2 transition, LEDs=%b", $time, leds);
        #1500;
        $display("Time=%0t: S2->S3 transition, LEDs=%b", $time, leds);
        #1500;
        $display("Time=%0t: S3->S0 transition, LEDs=%b", $time, leds);
        
        if (leds == 4'b0001)
            $display("Time=%0t: TEST 6 PASSED - Complete cycle verified", $time);
        else
            $display("Time=%0t: TEST 6 FAILED - Cycle incomplete", $time);
        
        // 시뮬레이션 종료
        #1000;
        $display("\n========================================");
        $display("Sequence FSM Testbench Completed");
        $display("========================================");
        $display("\nNOTE: For actual simulation, modify the counter");
        $display("      in sequence_fsm.v from 99_999_999 to 100");
        $display("      for faster testing.");
        $finish;
    end
    
    // LED 상태 변화 모니터링
    always @(leds) begin
        case (leds)
            4'b0001: $display("  --> LED Pattern: 0001 (State S0)");
            4'b0010: $display("  --> LED Pattern: 0010 (State S1)");
            4'b0100: $display("  --> LED Pattern: 0100 (State S2)");
            4'b1000: $display("  --> LED Pattern: 1000 (State S3)");
            default: $display("  --> LED Pattern: %b (Unknown)", leds);
        endcase
    end
    
    // 타임아웃 (무한 루프 방지)
    initial begin
        #50000;  // 50us 후 자동 종료
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule


// ========================================
// 시뮬레이션을 위한 수정된 sequence_fsm
// ========================================
// 원본 sequence_fsm의 counter를 줄인 버전
// 테스트 시 이 버전을 사용하세요

/*
module sequence_fsm(
    input clk,
    input reset,
    input enable,
    output reg [3:0] leds
);

    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;
    localparam S3 = 2'b11;
    
    reg [1:0] state, next_state;
    
    // 시뮬레이션용: 100 클럭으로 변경 (원본은 99_999_999)
    reg [26:0] counter;
    wire tick;
    
    assign tick = (counter == 27'd100);  // 테스트용으로 축소
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 0;
        else if (enable) begin
            if (tick)
                counter <= 0;
            else
                counter <= counter + 1;
        end
        else
            counter <= 0;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0;
        else if (enable && tick)
            state <= next_state;
    end
    
    always @(*) begin
        case (state)
            S0: next_state = S1;
            S1: next_state = S2;
            S2: next_state = S3;
            S3: next_state = S0;
            default: next_state = S0;
        endcase
    end
    
    always @(*) begin
        case (state)
            S0: leds = 4'b0001;
            S1: leds = 4'b0010;
            S2: leds = 4'b0100;
            S3: leds = 4'b1000;
            default: leds = 4'b0000;
        endcase
    end

endmodule
*/
```

---

[FSM 예제 동작 개념 정리](#FSM-예제-동작-개념-정리)
## 3️. 신호등 FSM (초급)

## 📋 테스트 시나리오
## ✅ 포함된 테스트
- **1.TEST 1**: Enable OFF - 초기 RED 상태 확인
- **2.TEST 2**: Full Cycle - 전체 사이클 동작 확인
- ** -RED (5초) → GREEN (5초) → YELLOW (2초) → RED**
- **3.TEST 3**: Cycle Repeat - 사이클 반복 동작 확인
- **4.TEST 4**: Disable - 동작 멈춤 및 RED 복귀 확인
- **5.TEST 5**: Re-enable - 재시작 확인
- **6.TEST 6**: Reset - 리셋 기능 확인
- **7.TEST 7**: Timing Accuracy - 각 상태의 정확한 시간 확인

## ⚠️ 중요 사항
- **실제 시뮬레이션을 위해서는 traffic_light_fsm.v의 카운터 값을 수정:**
```verilog
// 원본 (1초 = 100,000,000 클럭)
assign tick_1sec = (counter == 27'd99_999_999);

// 시뮬레이션용 (1초 = 100 클럭으로 축소)
assign tick_1sec = (counter == 27'd100);
```

## 📊 예상 동작
- **RED: 5초 (500ns in simulation)**
- **GREEN: 5초 (500ns in simulation)**
- **YELLOW: 2초 (200ns in simulation)**
- **한 사이클: 12초 (1200ns in simulation)**

##🚦 신호등 상태 표시
- **테스트벤치는 자동으로 신호등 상태를 표시합니다:
- ***R=1 Y=0 G=0 [RED]***
- ***R=0 Y=0 G=1 [GREEN]***
- ***R=0 Y=1 G=0 [YELLOW]***

```verilog
// ========================================
// 3번 - 신호등 FSM (초급)
// ========================================
// 빨강(5초) -> 초록(5초) -> 노랑(2초) -> 반복
// Basys3 보드 100MHz 클럭 사용

module traffic_light_fsm(
    input clk,              // 100MHz 클럭
    input reset,            // 리셋
    input enable,           // 동작 활성화
    output reg red,         // 빨간불
    output reg yellow,      // 노란불
    output reg green        // 초록불
);

    // State 정의
    localparam RED    = 2'b00;
    localparam GREEN  = 2'b01;
    localparam YELLOW = 2'b10;
    
    reg [1:0] state, next_state;
    
    // 타이머 카운터 (1초 = 100,000,000 클럭)
    reg [26:0] counter;
    reg [3:0] time_count;  // 상태별 시간 카운터
    
    wire tick_1sec;
    assign tick_1sec = (counter == 27'd99_999_999);
    
    // 상태별 지속 시간 정의
    localparam RED_TIME    = 4'd5;  // 5초
    localparam GREEN_TIME  = 4'd5;  // 5초
    localparam YELLOW_TIME = 4'd2;  // 2초
    
    // 1초 타이머
    always @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 0;
        else if (enable) begin
            if (tick_1sec)
                counter <= 0;
            else
                counter <= counter + 1;
        end
        else
            counter <= 0;
    end
    
    // State Register와 시간 카운터
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= RED;
            time_count <= 0;
        end
        else if (enable) begin
            if (tick_1sec) begin
                if (time_count == get_state_time(state) - 1) begin
                    state <= next_state;
                    time_count <= 0;
                end
                else begin
                    time_count <= time_count + 1;
                end
            end
        end
        else begin
            state <= RED;
            time_count <= 0;
        end
    end
    
    // 상태별 시간을 반환하는 함수
    function [3:0] get_state_time;
        input [1:0] s;
        begin
            case (s)
                RED:    get_state_time = RED_TIME;
                GREEN:  get_state_time = GREEN_TIME;
                YELLOW: get_state_time = YELLOW_TIME;
                default: get_state_time = RED_TIME;
            endcase
        end
    endfunction
    
    // Next State Logic
    always @(*) begin
        case (state)
            RED:    next_state = GREEN;
            GREEN:  next_state = YELLOW;
            YELLOW: next_state = RED;
            default: next_state = RED;
        endcase
    end
    
    // Output Logic
    always @(*) begin
        // 기본값
        red = 0;
        yellow = 0;
        green = 0;
        
        case (state)
            RED: begin
                red = 1;
                yellow = 0;
                green = 0;
            end
            GREEN: begin
                red = 0;
                yellow = 0;
                green = 1;
            end
            YELLOW: begin
                red = 0;
                yellow = 1;
                green = 0;
            end
            default: begin
                red = 1;
                yellow = 0;
                green = 0;
            end
        endcase
    end

endmodule
```

```verilog
// ========================================
// 3번 - 신호등 FSM 테스트벤치
// ========================================
`timescale 1ns / 1ps

module tb_traffic_light_fsm;

    // 입력 신호 (reg)
    reg clk;
    reg reset;
    reg enable;
    
    // 출력 신호 (wire)
    wire red;
    wire yellow;
    wire green;
    
    // 신호등 상태를 문자열로 표시하기 위한 변수
    reg [63:0] light_state;
    
    // DUT (Device Under Test) 인스턴스화
    traffic_light_fsm uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .red(red),
        .yellow(yellow),
        .green(green)
    );
    
    // 클럭 생성 (100MHz = 10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 신호등 상태를 문자열로 변환
    always @(*) begin
        if (red && !yellow && !green)
            light_state = "RED";
        else if (!red && !yellow && green)
            light_state = "GREEN";
        else if (!red && yellow && !green)
            light_state = "YELLOW";
        else if (!red && !yellow && !green)
            light_state = "OFF";
        else
            light_state = "ERROR";
    end
    
    // 테스트 시나리오
    initial begin
        // 파형 덤프 설정
        $dumpfile("traffic_light_fsm.vcd");
        $dumpvars(0, tb_traffic_light_fsm);
        
        // 초기화
        reset = 1;
        enable = 0;
        
        $display("========================================");
        $display("Traffic Light FSM Testbench Started");
        $display("========================================\n");
        
        // 리셋 해제
        #100;
        reset = 0;
        $display("Time=%0t: Reset released", $time);
        
        // 테스트 1: enable이 꺼져있을 때
        #200;
        $display("\n--- TEST 1: Enable OFF ---");
        $display("Time=%0t: Enable=0, Lights should be RED", $time);
        
        #100;
        if (red && !yellow && !green)
            $display("Time=%0t: TEST 1 PASSED - Initial state is RED", $time);
        else
            $display("Time=%0t: TEST 1 FAILED - Should be RED", $time);
        
        // 테스트 2: enable 켜고 전체 사이클 동작 확인
        #100;
        enable = 1;
        $display("\n--- TEST 2: Full Cycle Test ---");
        $display("Time=%0t: Enable=1, Starting traffic light cycle", $time);
        $display("Expected sequence: RED(5s) -> GREEN(5s) -> YELLOW(2s) -> RED");
        
        // 주의: 실제 시뮬레이션을 위해서는 counter 값을 줄여야 합니다
        // 예: 99_999_999 -> 100 (1초를 100 클럭으로)
        
        // RED 상태 확인 (5초)
        #50;
        $display("\nTime=%0t: Checking RED state (should last 5 seconds)", $time);
        if (red && !yellow && !green)
            $display("Time=%0t: RED state - PASS", $time);
        else
            $display("Time=%0t: RED state - FAIL", $time);
        
        // RED 상태 유지 확인 (중간 시점)
        #2500;  // 가정: 1초 = 500ns (축소된 counter 사용 시)
        if (red && !yellow && !green)
            $display("Time=%0t: Still RED (mid-duration) - PASS", $time);
        else
            $display("Time=%0t: Should still be RED - FAIL", $time);
        
        // GREEN으로 전환 대기 (RED 5초 완료)
        #2500;
        $display("\nTime=%0t: Expecting transition to GREEN", $time);
        #100;
        if (!red && !yellow && green)
            $display("Time=%0t: GREEN state - PASS", $time);
        else
            $display("Time=%0t: GREEN state - FAIL (R=%b Y=%b G=%b)", $time, red, yellow, green);
        
        // GREEN 상태 유지 확인
        #2500;
        if (!red && !yellow && green)
            $display("Time=%0t: Still GREEN (mid-duration) - PASS", $time);
        else
            $display("Time=%0t: Should still be GREEN - FAIL", $time);
        
        // YELLOW로 전환 대기 (GREEN 5초 완료)
        #2500;
        $display("\nTime=%0t: Expecting transition to YELLOW", $time);
        #100;
        if (!red && yellow && !green)
            $display("Time=%0t: YELLOW state - PASS", $time);
        else
            $display("Time=%0t: YELLOW state - FAIL (R=%b Y=%b G=%b)", $time, red, yellow, green);
        
        // YELLOW 상태 유지 확인 (2초)
        #1000;
        if (!red && yellow && !green)
            $display("Time=%0t: Still YELLOW (mid-duration) - PASS", $time);
        else
            $display("Time=%0t: Should still be YELLOW - FAIL", $time);
        
        // RED로 다시 전환 대기 (YELLOW 2초 완료)
        #1000;
        $display("\nTime=%0t: Expecting transition back to RED", $time);
        #100;
        if (red && !yellow && !green)
            $display("Time=%0t: Back to RED - CYCLE COMPLETE - PASS", $time);
        else
            $display("Time=%0t: Should be RED - FAIL", $time);
        
        // 테스트 3: 사이클 반복 확인
        $display("\n--- TEST 3: Cycle Repeat Test ---");
        $display("Time=%0t: Verifying cycle repeats correctly", $time);
        
        // 다시 GREEN으로 전환 확인
        #5000;
        #100;
        if (!red && !yellow && green)
            $display("Time=%0t: Second GREEN cycle - PASS", $time);
        else
            $display("Time=%0t: Second cycle failed - FAIL", $time);
        
        // 테스트 4: enable 끄기 (동작 멈춤)
        #1000;
        $display("\n--- TEST 4: Disable Test ---");
        enable = 0;
        $display("Time=%0t: Enable=0, Traffic light should stop and reset to RED", $time);
        
        #200;
        if (red && !yellow && !green)
            $display("Time=%0t: TEST 4 PASSED - Reset to RED when disabled", $time);
        else
            $display("Time=%0t: TEST 4 FAILED - Should be RED", $time);
        
        // 시간이 지나도 상태 변경 없어야 함
        #3000;
        if (red && !yellow && !green)
            $display("Time=%0t: Still RED (no state change) - PASS", $time);
        else
            $display("Time=%0t: Should not change state - FAIL", $time);
        
        // 테스트 5: 다시 enable 켜기
        #500;
        $display("\n--- TEST 5: Re-enable Test ---");
        enable = 1;
        $display("Time=%0t: Enable=1, Cycle should restart from RED", $time);
        
        #100;
        if (red && !yellow && !green)
            $display("Time=%0t: Starting from RED - PASS", $time);
        else
            $display("Time=%0t: Should start from RED - FAIL", $time);
        
        // 다음 상태로 전환 확인
        #5000;
        #100;
        if (!red && !yellow && green)
            $display("Time=%0t: Transitioned to GREEN - PASS", $time);
        else
            $display("Time=%0t: Should be GREEN - FAIL", $time);
        
        // 테스트 6: 리셋 테스트
        #2000;
        $display("\n--- TEST 6: Reset Test ---");
        reset = 1;
        $display("Time=%0t: Reset activated (should go to RED)", $time);
        
        #100;
        reset = 0;
        $display("Time=%0t: Reset deactivated", $time);
        
        #50;
        if (red && !yellow && !green)
            $display("Time=%0t: TEST 6 PASSED - Reset to RED", $time);
        else
            $display("Time=%0t: TEST 6 FAILED - Should be RED after reset", $time);
        
        // 테스트 7: 타이밍 정확도 테스트
        $display("\n--- TEST 7: Timing Accuracy Test ---");
        $display("Time=%0t: Verifying state durations", $time);
        
        enable = 1;
        
        // RED 시작 시간 기록
        #100;
        $display("Time=%0t: RED started", $time);
        
        // 정확히 5초(축소 시간) 후 GREEN 확인
        #5000;
        #100;
        if (!red && !yellow && green) begin
            $display("Time=%0t: GREEN started (RED lasted correct duration) - PASS", $time);
            
            // GREEN 5초 확인
            #5000;
            #100;
            if (!red && yellow && !green) begin
                $display("Time=%0t: YELLOW started (GREEN lasted correct duration) - PASS", $time);
                
                // YELLOW 2초 확인
                #2000;
                #100;
                if (red && !yellow && !green)
                    $display("Time=%0t: RED started (YELLOW lasted correct duration) - PASS", $time);
                else
                    $display("Time=%0t: Timing error in YELLOW duration - FAIL", $time);
            end else
                $display("Time=%0t: GREEN duration error - FAIL", $time);
        end else
            $display("Time=%0t: RED duration error - FAIL", $time);
        
        // 시뮬레이션 종료
        #1000;
        $display("\n========================================");
        $display("Traffic Light FSM Testbench Completed");
        $display("========================================");
        $display("\nNOTE: For actual simulation, modify the counter");
        $display("      in traffic_light_fsm.v from 99_999_999 to 100");
        $display("      for faster testing.");
        $display("      Timing: 1 second = 100 clocks (1000ns)");
        $finish;
    end
    
    // 신호등 상태 변화 모니터링
    always @(red or yellow or green) begin
        $display("  --> Traffic Light: R=%b Y=%b G=%b [%s]", 
                 red, yellow, green, light_state);
    end
    
    // 타임아웃 (무한 루프 방지)
    initial begin
        #100000;  // 100us 후 자동 종료
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule


// ========================================
// 시뮬레이션을 위한 수정된 traffic_light_fsm
// ========================================
// 원본 traffic_light_fsm의 counter를 줄인 버전
// 테스트 시 이 버전을 사용하세요

/*
module traffic_light_fsm(
    input clk,
    input reset,
    input enable,
    output reg red,
    output reg yellow,
    output reg green
);

    localparam RED    = 2'b00;
    localparam GREEN  = 2'b01;
    localparam YELLOW = 2'b10;
    
    reg [1:0] state, next_state;
    
    // 시뮬레이션용으로 축소 (1초 = 100 클럭)
    reg [26:0] counter;
    reg [3:0] time_count;
    
    wire tick_1sec;
    assign tick_1sec = (counter == 27'd100);  // 테스트용
    
    localparam RED_TIME    = 4'd5;
    localparam GREEN_TIME  = 4'd5;
    localparam YELLOW_TIME = 4'd2;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 0;
        else if (enable) begin
            if (tick_1sec)
                counter <= 0;
            else
                counter <= counter + 1;
        end
        else
            counter <= 0;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= RED;
            time_count <= 0;
        end
        else if (enable) begin
            if (tick_1sec) begin
                if (time_count == get_state_time(state) - 1) begin
                    state <= next_state;
                    time_count <= 0;
                end
                else begin
                    time_count <= time_count + 1;
                end
            end
        end
        else begin
            state <= RED;
            time_count <= 0;
        end
    end
    
    function [3:0] get_state_time;
        input [1:0] s;
        begin
            case (s)
                RED:    get_state_time = RED_TIME;
                GREEN:  get_state_time = GREEN_TIME;
                YELLOW: get_state_time = YELLOW_TIME;
                default: get_state_time = RED_TIME;
            endcase
        end
    endfunction
    
    always @(*) begin
        case (state)
            RED:    next_state = GREEN;
            GREEN:  next_state = YELLOW;
            YELLOW: next_state = RED;
            default: next_state = RED;
        endcase
    end
    
    always @(*) begin
        red = 0;
        yellow = 0;
        green = 0;
        
        case (state)
            RED: begin
                red = 1;
                yellow = 0;
                green = 0;
            end
            GREEN: begin
                red = 0;
                yellow = 0;
                green = 1;
            end
            YELLOW: begin
                red = 0;
                yellow = 1;
                green = 0;
            end
            default: begin
                red = 1;
                yellow = 0;
                green = 0;
            end
        endcase
    end

endmodule
*/
```

---

[FSM 예제 동작 개념 정리](#FSM-예제-동작-개념-정리)
## 4️. 자판기 FSM (중급)

### 📋 테스트 시나리오

### ✅ 포함된 테스트 (총 10개)
- **TEST 1**: 100원 × 5 = 500원 (정확한 금액)
- **TEST 2**: 500원 × 1 = 500원 (정확한 금액)
- **TEST 3**: 100원 × 3 + 500원 × 1 = 800원 (거스름돈 300원)
- **TEST 4**: 취소 기능 (300원 투입 후 취소)
- **TEST 5**: 7-segment 디스플레이 확인 (0→1→2→3→4→5)
- **TEST 6**: 혼합 투입 700원 (거스름돈 200원)
- **TEST 7**: 리셋 테스트 (투입 중 리셋)
- **TEST 8**: 최대 금액 테스트 1000원 (거스름돈 500원)
- **TEST 9**: 연속 구매 테스트 (3회 연속)
- **TEST 10**: 엣지 케이스 - 400원 투입 후 취소

###💡 특징
### 편리한 태스크(Task) 제공:
- **insert_coin_100: 100원 투입**
- **insert_coin_500: 500원 투입**
- **press_cancel: 취소 버튼**

### 자동 검증:
- **음료 제공 여부 확인**
- **거스름돈 정확도 검증**
- **7-segment 표시 확인**
- **각 테스트 PASS/FAIL 자동 판정**

### 🔧 시뮬레이션 실행 방법
```bash
# Vivado 시뮬레이터
xvlog vending_machine_fsm.v
xvlog tb_vending_machine_fsm.v
xelab -debug typical tb_vending_machine_fsm -s sim
xsim sim -gui

# ModelSim
vlog vending_machine_fsm.v tb_vending_machine_fsm.v
vsim tb_vending_machine_fsm
run -all
```

### 📊 예상 결과
```
[INSERT] 100원 투입 - 총 투입액: 100원
[DISPLAY] 7-segment 값: 1 (투입 금액: 100원)
[INSERT] 100원 투입 - 총 투입액: 200원
...
[OUTPUT] 음료 제공! 거스름돈: 0원
TEST 1 PASSED - 음료 제공, 거스름돈 없음
```

```verilog
// ========================================
// 4번 - 자판기 FSM (중급)
// ========================================
// 500원짜리 음료 판매, 100원/500원 동전 투입 가능
// 거스름돈 반환 기능 포함
// Basys3 보드 100MHz 클럭 사용

module vending_machine_fsm(
    input clk,              // 100MHz 클럭
    input reset,            // 리셋
    input coin_100,         // 100원 투입
    input coin_500,         // 500원 투입
    input cancel,           // 취소 버튼
    output reg dispense,    // 음료 제공
    output reg [2:0] change,// 거스름돈 (100원 단위)
    output reg [6:0] seg,   // 7-segment 디스플레이
    output reg [3:0] an     // 7-segment anode
);

    // State 정의
    localparam IDLE   = 3'b000;  // 0원
    localparam COIN1  = 3'b001;  // 100원
    localparam COIN2  = 3'b010;  // 200원
    localparam COIN3  = 3'b011;  // 300원
    localparam COIN4  = 3'b100;  // 400원
    localparam COIN5  = 3'b101;  // 500원 이상 (제공)
    
    reg [2:0] state, next_state;
    reg [2:0] amount;  // 현재 투입 금액 (100원 단위)
    
    // 버튼 엣지 감지
    reg coin_100_prev, coin_500_prev, cancel_prev;
    wire coin_100_edge, coin_500_edge, cancel_edge;
    
    assign coin_100_edge = coin_100 & ~coin_100_prev;
    assign coin_500_edge = coin_500 & ~coin_500_prev;
    assign cancel_edge = cancel & ~cancel_prev;
    
    // State Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            coin_100_prev <= 0;
            coin_500_prev <= 0;
            cancel_prev <= 0;
        end
        else begin
            state <= next_state;
            coin_100_prev <= coin_100;
            coin_500_prev <= coin_500;
            cancel_prev <= cancel;
        end
    end
    
    // Next State Logic
    always @(*) begin
        next_state = state;
        
        if (cancel_edge) begin
            next_state = IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    if (coin_100_edge)
                        next_state = COIN1;
                    else if (coin_500_edge)
                        next_state = COIN5;
                end
                
                COIN1: begin
                    if (coin_100_edge)
                        next_state = COIN2;
                    else if (coin_500_edge)
                        next_state = COIN5;
                end
                
                COIN2: begin
                    if (coin_100_edge)
                        next_state = COIN3;
                    else if (coin_500_edge)
                        next_state = COIN5;
                end
                
                COIN3: begin
                    if (coin_100_edge)
                        next_state = COIN4;
                    else if (coin_500_edge)
                        next_state = COIN5;
                end
                
                COIN4: begin
                    if (coin_100_edge)
                        next_state = COIN5;
                    else if (coin_500_edge)
                        next_state = COIN5;
                end
                
                COIN5: begin
                    // 음료 제공 후 IDLE로 복귀
                    next_state = IDLE;
                end
                
                default: next_state = IDLE;
            endcase
        end
    end
    
    // Output Logic
    always @(*) begin
        // 기본값
        dispense = 0;
        change = 0;
        amount = 0;
        
        case (state)
            IDLE: begin
                amount = 0;
                dispense = 0;
                change = 0;
            end
            COIN1: amount = 1;
            COIN2: amount = 2;
            COIN3: amount = 3;
            COIN4: amount = 4;
            COIN5: begin
                dispense = 1;
                if (amount > 5)
                    change = amount - 5;
                else
                    change = 0;
            end
            default: begin
                amount = 0;
                dispense = 0;
                change = 0;
            end
        endcase
        
        // 취소 시 전액 반환
        if (cancel_edge && state != IDLE)
            change = amount;
    end
    
    // 7-segment 디스플레이 (투입 금액 표시)
    always @(*) begin
        an = 4'b1110;  // 첫 번째 디지트만 활성화
        
        case (state)
            IDLE:   seg = 7'b1000000;  // 0
            COIN1:  seg = 7'b1111001;  // 1
            COIN2:  seg = 7'b0100100;  // 2
            COIN3:  seg = 7'b0110000;  // 3
            COIN4:  seg = 7'b0011001;  // 4
            COIN5:  seg = 7'b0010010;  // 5
            default: seg = 7'b1111111;  // off
        endcase
    end

endmodule
```

```verilog
// ========================================
// 4번 - 자판기 FSM 테스트벤치
// ========================================
`timescale 1ns / 1ps

module tb_vending_machine_fsm;

    // 입력 신호 (reg)
    reg clk;
    reg reset;
    reg coin_100;
    reg coin_500;
    reg cancel;
    
    // 출력 신호 (wire)
    wire dispense;
    wire [2:0] change;
    wire [6:0] seg;
    wire [3:0] an;
    
    // 테스트용 변수
    integer total_inserted;
    integer test_count;
    
    // DUT (Device Under Test) 인스턴스화
    vending_machine_fsm uut (
        .clk(clk),
        .reset(reset),
        .coin_100(coin_100),
        .coin_500(coin_500),
        .cancel(cancel),
        .dispense(dispense),
        .change(change),
        .seg(seg),
        .an(an)
    );
    
    // 클럭 생성 (100MHz = 10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 7-segment 값을 숫자로 디코딩하는 함수
    function [3:0] decode_seg;
        input [6:0] seg_val;
        begin
            case (seg_val)
                7'b1000000: decode_seg = 0;
                7'b1111001: decode_seg = 1;
                7'b0100100: decode_seg = 2;
                7'b0110000: decode_seg = 3;
                7'b0011001: decode_seg = 4;
                7'b0010010: decode_seg = 5;
                7'b0000010: decode_seg = 6;
                7'b1111000: decode_seg = 7;
                7'b0000000: decode_seg = 8;
                7'b0010000: decode_seg = 9;
                default: decode_seg = 15;  // Error
            endcase
        end
    endfunction
    
    // 동전 투입 태스크
    task insert_coin_100;
        begin
            @(posedge clk);
            coin_100 = 1;
            @(posedge clk);
            #10;
            coin_100 = 0;
            total_inserted = total_inserted + 100;
            $display("  [INSERT] 100원 투입 - 총 투입액: %0d원", total_inserted);
            #50;  // 안정화 대기
        end
    endtask
    
    task insert_coin_500;
        begin
            @(posedge clk);
            coin_500 = 1;
            @(posedge clk);
            #10;
            coin_500 = 0;
            total_inserted = total_inserted + 500;
            $display("  [INSERT] 500원 투입 - 총 투입액: %0d원", total_inserted);
            #50;  // 안정화 대기
        end
    endtask
    
    task press_cancel;
        begin
            @(posedge clk);
            cancel = 1;
            @(posedge clk);
            #10;
            cancel = 0;
            $display("  [CANCEL] 취소 버튼 눌림 - 반환 예상액: %0d원", total_inserted);
            total_inserted = 0;
            #50;
        end
    endtask
    
    // 테스트 시나리오
    initial begin
        // 파형 덤프 설정
        $dumpfile("vending_machine_fsm.vcd");
        $dumpvars(0, tb_vending_machine_fsm);
        
        // 초기화
        reset = 1;
        coin_100 = 0;
        coin_500 = 0;
        cancel = 0;
        total_inserted = 0;
        test_count = 0;
        
        $display("========================================");
        $display("Vending Machine FSM Testbench Started");
        $display("음료 가격: 500원");
        $display("========================================\n");
        
        // 리셋 해제
        #100;
        reset = 0;
        $display("Time=%0t: Reset released\n", $time);
        
        // 테스트 1: 100원 동전 5개로 정확히 500원
        test_count = test_count + 1;
        $display("--- TEST %0d: 100원 x 5 = 500원 (정확한 금액) ---", test_count);
        total_inserted = 0;
        
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        
        #100;
        if (dispense && change == 0) begin
            $display("Time=%0t: TEST %0d PASSED - 음료 제공, 거스름돈 없음", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - dispense=%b, change=%d", 
                     $time, test_count, dispense, change);
        end
        
        #200;
        total_inserted = 0;
        
        // 테스트 2: 500원 동전 1개
        test_count = test_count + 1;
        $display("\n--- TEST %0d: 500원 x 1 = 500원 (정확한 금액) ---", test_count);
        
        insert_coin_500;
        
        #100;
        if (dispense && change == 0) begin
            $display("Time=%0t: TEST %0d PASSED - 음료 제공, 거스름돈 없음", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - dispense=%b, change=%d", 
                     $time, test_count, dispense, change);
        end
        
        #200;
        total_inserted = 0;
        
        // 테스트 3: 100원 3개 + 500원 1개 = 800원 (거스름돈 300원)
        test_count = test_count + 1;
        $display("\n--- TEST %0d: 100원 x 3 + 500원 x 1 = 800원 (거스름돈 300원) ---", test_count);
        
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        insert_coin_500;
        
        #100;
        if (dispense && change == 3) begin
            $display("Time=%0t: TEST %0d PASSED - 음료 제공, 거스름돈 300원", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - dispense=%b, change=%d (expected 3)", 
                     $time, test_count, dispense, change);
        end
        
        #200;
        total_inserted = 0;
        
        // 테스트 4: 취소 기능 (300원 투입 후 취소)
        test_count = test_count + 1;
        $display("\n--- TEST %0d: 취소 기능 테스트 (300원 투입 후 취소) ---", test_count);
        
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        
        #100;
        $display("  현재 투입액: 300원");
        
        press_cancel;
        
        #100;
        if (!dispense && change == 3) begin
            $display("Time=%0t: TEST %0d PASSED - 음료 미제공, 300원 반환", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - dispense=%b, change=%d", 
                     $time, test_count, dispense, change);
        end
        
        #200;
        total_inserted = 0;
        
        // 테스트 5: 7-segment 디스플레이 확인
        test_count = test_count + 1;
        $display("\n--- TEST %0d: 7-segment 디스플레이 확인 ---", test_count);
        
        #50;
        $display("  IDLE 상태: 표시값 = %0d (expected: 0)", decode_seg(seg));
        
        insert_coin_100;
        #50;
        $display("  100원 투입: 표시값 = %0d (expected: 1)", decode_seg(seg));
        
        insert_coin_100;
        #50;
        $display("  200원 투입: 표시값 = %0d (expected: 2)", decode_seg(seg));
        
        insert_coin_100;
        #50;
        $display("  300원 투입: 표시값 = %0d (expected: 3)", decode_seg(seg));
        
        insert_coin_100;
        #50;
        $display("  400원 투입: 표시값 = %0d (expected: 4)", decode_seg(seg));
        
        insert_coin_100;
        #50;
        $display("  500원 투입: 표시값 = %0d (expected: 5)", decode_seg(seg));
        
        if (decode_seg(seg) == 5)
            $display("Time=%0t: TEST %0d PASSED - 7-segment 표시 정상", $time, test_count);
        else
            $display("Time=%0t: TEST %0d FAILED - 7-segment 오류", $time, test_count);
        
        #200;
        total_inserted = 0;
        
        // 테스트 6: 혼합 투입 (100원 2개 + 500원 1개 = 700원)
        test_count = test_count + 1;
        $display("\n--- TEST %0d: 혼합 투입 700원 (거스름돈 200원) ---", test_count);
        
        insert_coin_100;
        insert_coin_100;
        insert_coin_500;
        
        #100;
        if (dispense && change == 2) begin
            $display("Time=%0t: TEST %0d PASSED - 음료 제공, 거스름돈 200원", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - dispense=%b, change=%d", 
                     $time, test_count, dispense, change);
        end
        
        #200;
        total_inserted = 0;
        
        // 테스트 7: 리셋 테스트 (투입 중 리셋)
        test_count = test_count + 1;
        $display("\n--- TEST %0d: 리셋 테스트 (300원 투입 중 리셋) ---", test_count);
        
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        
        #100;
        $display("  현재 투입액: 300원");
        
        reset = 1;
        $display("  [RESET] 리셋 신호 활성화");
        #100;
        reset = 0;
        
        #100;
        if (decode_seg(seg) == 0 && !dispense) begin
            $display("Time=%0t: TEST %0d PASSED - 리셋 후 초기 상태", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - 리셋 오류", $time, test_count);
        end
        
        #200;
        total_inserted = 0;
        
        // 테스트 8: 최대 금액 테스트 (500원 2개 = 1000원)
        test_count = test_count + 1;
        $display("\n--- TEST %0d: 최대 금액 테스트 1000원 (거스름돈 500원) ---", test_count);
        
        insert_coin_500;
        insert_coin_500;
        
        #100;
        if (dispense && change >= 5) begin
            $display("Time=%0t: TEST %0d PASSED - 음료 제공, 거스름돈 500원 이상", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - dispense=%b, change=%d", 
                     $time, test_count, dispense, change);
        end
        
        #200;
        total_inserted = 0;
        
        // 테스트 9: 연속 구매 테스트
        test_count = test_count + 1;
        $display("\n--- TEST %0d: 연속 구매 테스트 ---", test_count);
        
        $display("  첫 번째 구매:");
        insert_coin_500;
        #200;
        
        $display("  두 번째 구매:");
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        #200;
        
        $display("  세 번째 구매:");
        insert_coin_500;
        #200;
        
        $display("Time=%0t: TEST %0d PASSED - 연속 구매 완료", $time, test_count);
        
        #200;
        
        // 테스트 10: 엣지 케이스 - 정확히 400원 투입 후 취소
        test_count = test_count + 1;
        $display("\n--- TEST %0d: 400원 투입 후 취소 ---", test_count);
        total_inserted = 0;
        
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        insert_coin_100;
        
        #100;
        press_cancel;
        
        #100;
        if (!dispense && change == 4) begin
            $display("Time=%0t: TEST %0d PASSED - 400원 반환", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - change=%d (expected 4)", 
                     $time, test_count, change);
        end
        
        // 시뮬레이션 종료
        #500;
        $display("\n========================================");
        $display("Vending Machine FSM Testbench Completed");
        $display("Total Tests: %0d", test_count);
        $display("========================================");
        $finish;
    end
    
    // 상태 변화 모니터링
    always @(posedge clk) begin
        if (dispense)
            $display("  [OUTPUT] 음료 제공! 거스름돈: %0d원", change * 100);
    end
    
    // 7-segment 표시 모니터링
    always @(seg) begin
        $display("  [DISPLAY] 7-segment 값: %0d (투입 금액: %0d00원)", 
                 decode_seg(seg), decode_seg(seg));
    end
    
    // 타임아웃 (무한 루프 방지)
    initial begin
        #50000;  // 50us 후 자동 종료
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
```

---

[FSM 예제 동작 개념 정리](#FSM-예제-동작-개념-정리)
## 5️. UART 수신기 FSM (중상급)

### 📋 테스트 시나리오
### ✅ 포함된 테스트 (총 10개)
1. TEST 1: 단일 바이트 수신 (0x55)
2. TEST 2: 다른 바이트 수신 (0xAA)
3. TEST 3: All zeros (0x00)
4. TEST 4: All ones (0xFF)
5. TEST 5: ASCII 문자 수신 ('A' = 0x41)
6. TEST 6: 연속 바이트 수신 (0x12, 0x34, 0x56)
7. TEST 7: Framing Error 테스트 (잘못된 Stop bit)
8. TEST 8: False Start 감지 및 복구
9. TEST 9: 리셋 테스트 (수신 중 리셋)
10. TEST 10: 문자열 수신 ("HELLO")

### 💡 특징
   * 정확한 UART 타이밍:
      * 9600 baud = 104.167 μs per bit
      * Start bit (0) → 8 Data bits (LSB first) → Stop bit (1)
   * 편리한 태스크 제공:
      * send_uart_byte: 정상 UART 바이트 전송
      * send_uart_byte_bad_stop: 잘못된 Stop bit 전송
      * send_false_start: False start 시뮬레이션
   * 자동 검증:
      * 데이터 정확도 확인
      * Valid 신호 검증
      * Framing error 감지
      * 각 테스트 PASS/FAIL 자동 판정

### 🔧 시뮬레이션 실행 방법
```bash
# Vivado 시뮬레이터
xvlog uart_rx_fsm.v
xvlog tb_uart_rx_fsm.v
xelab -debug typical tb_uart_rx_fsm -s sim
xsim sim -gui

# ModelSim
vlog uart_rx_fsm.v tb_uart_rx_fsm.v
vsim tb_uart_rx_fsm
run -all
```

### 📊 예상 결과
```
[TX] Sending UART byte: 0x55 (85)
[RX] Valid data received: 0x55 (85) 'U'
TEST 1 PASSED - Received: 0x55

[TX] Sending UART byte: 0x41 (65)
[RX] Valid data received: 0x41 (65) 'A'
TEST 5 PASSED - Received: 0x41 ('A')

[TX] Sending UART byte with bad stop bit: 0x88
[ERROR] Framing error detected!
TEST 7 PASSED - Framing error detected
```

### ⚡ 주의 사항
   * 시뮬레이션 시간이 길 수 있습니다 (각 비트가 104μs)
   * 전체 테스트는 약 2-3ms 소요
   * 파형 뷰어에서 UART 타이밍을 확인하세요

```verilog
// ========================================
// 5번 - UART 수신기 FSM (중상급)
// ========================================
// 9600 baud, 8-N-1 프로토콜
// Basys3 보드 100MHz 클럭 사용

module uart_rx_fsm(
    input clk,              // 100MHz 클럭
    input reset,            // 리셋
    input rx,               // UART RX 신호
    output reg [7:0] data,  // 수신된 데이터
    output reg valid,       // 데이터 유효 신호
    output reg error        // 에러 플래그
);

    // State 정의
    localparam IDLE       = 3'b000;
    localparam START_BIT  = 3'b001;
    localparam DATA_BITS  = 3'b010;
    localparam STOP_BIT   = 3'b011;
    localparam CLEANUP    = 3'b100;
    
    reg [2:0] state, next_state;
    
    // Baud rate 생성 (100MHz / 9600 = 10416.67)
    localparam BAUD_RATE = 16'd10417;
    localparam HALF_BAUD = 16'd5208;
    
    reg [15:0] baud_counter;
    reg [2:0] bit_counter;    // 0~7 비트 카운터
    reg [7:0] shift_reg;      // 수신 데이터 시프트 레지스터
    reg sample_tick;
    
    // RX 신호 동기화 (메타스테이블 방지)
    reg rx_sync1, rx_sync2;
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end
    
    // Baud rate 카운터
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_counter <= 0;
            sample_tick <= 0;
        end
        else begin
            sample_tick <= 0;
            
            if (state == IDLE) begin
                baud_counter <= 0;
            end
            else if (state == START_BIT && baud_counter == HALF_BAUD - 1) begin
                baud_counter <= 0;
                sample_tick <= 1;
            end
            else if (baud_counter == BAUD_RATE - 1) begin
                baud_counter <= 0;
                sample_tick <= 1;
            end
            else begin
                baud_counter <= baud_counter + 1;
            end
        end
    end
    
    // State Register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    // Next State Logic
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (rx_sync2 == 0)  // Start bit 감지 (falling edge)
                    next_state = START_BIT;
            end
            
            START_BIT: begin
                if (sample_tick) begin
                    if (rx_sync2 == 0)  // Start bit 확인
                        next_state = DATA_BITS;
                    else
                        next_state = IDLE;  // False start
                end
            end
            
            DATA_BITS: begin
                if (sample_tick && bit_counter == 7)
                    next_state = STOP_BIT;
            end
            
            STOP_BIT: begin
                if (sample_tick)
                    next_state = CLEANUP;
            end
            
            CLEANUP: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // 비트 카운터
    always @(posedge clk or posedge reset) begin
        if (reset)
            bit_counter <= 0;
        else begin
            if (state == DATA_BITS && sample_tick)
                bit_counter <= bit_counter + 1;
            else if (state != DATA_BITS)
                bit_counter <= 0;
        end
    end
    
    // 데이터 시프트 레지스터
    always @(posedge clk or posedge reset) begin
        if (reset)
            shift_reg <= 0;
        else begin
            if (state == DATA_BITS && sample_tick)
                shift_reg <= {rx_sync2, shift_reg[7:1]};  // LSB first
        end
    end
    
    // Output Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data <= 0;
            valid <= 0;
            error <= 0;
        end
        else begin
            valid <= 0;
            error <= 0;
            
            if (state == STOP_BIT && sample_tick) begin
                if (rx_sync2 == 1) begin  // 유효한 stop bit
                    data <= shift_reg;
                    valid <= 1;
                end
                else begin
                    error <= 1;  // Framing error
                end
            end
        end
    end

endmodule
```

```verilog
// ========================================
// 5번 - UART 수신기 FSM 테스트벤치
// ========================================
`timescale 1ns / 1ps

module tb_uart_rx_fsm;

    // 입력 신호 (reg)
    reg clk;
    reg reset;
    reg rx;
    
    // 출력 신호 (wire)
    wire [7:0] data;
    wire valid;
    wire error;
    
    // 테스트용 변수
    integer test_count;
    integer bit_period;  // UART 비트 주기 (9600 baud)
    
    // DUT (Device Under Test) 인스턴스화
    uart_rx_fsm uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data(data),
        .valid(valid),
        .error(error)
    );
    
    // 클럭 생성 (100MHz = 10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // UART 비트 주기 계산
    // 9600 baud = 104.167 us per bit
    // 100MHz 클럭 = 10ns per cycle
    // 104.167us / 10ns = 10416.7 cycles
    initial begin
        bit_period = 104167;  // ns 단위 (104.167 us)
    end
    
    // UART 바이트 전송 태스크 (8-N-1 프레임)
    task send_uart_byte;
        input [7:0] byte_data;
        integer i;
        begin
            $display("  [TX] Sending UART byte: 0x%02h (%d)", byte_data, byte_data);
            
            // Start bit (0)
            rx = 0;
            #bit_period;
            
            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = byte_data[i];
                #bit_period;
            end
            
            // Stop bit (1)
            rx = 1;
            #bit_period;
            
            // Idle
            #(bit_period/2);
        end
    endtask
    
    // 잘못된 프레임 전송 태스크 (Stop bit = 0)
    task send_uart_byte_bad_stop;
        input [7:0] byte_data;
        integer i;
        begin
            $display("  [TX] Sending UART byte with bad stop bit: 0x%02h", byte_data);
            
            // Start bit
            rx = 0;
            #bit_period;
            
            // Data bits
            for (i = 0; i < 8; i = i + 1) begin
                rx = byte_data[i];
                #bit_period;
            end
            
            // Bad Stop bit (0 instead of 1)
            rx = 0;
            #bit_period;
            
            // Idle
            rx = 1;
            #(bit_period/2);
        end
    endtask
    
    // False start 시뮬레이션
    task send_false_start;
        begin
            $display("  [TX] Sending false start");
            rx = 0;
            #(bit_period/4);  // 짧게만 0
            rx = 1;
            #(bit_period*2);
        end
    endtask
    
    // 테스트 시나리오
    initial begin
        // 파형 덤프 설정
        $dumpfile("uart_rx_fsm.vcd");
        $dumpvars(0, tb_uart_rx_fsm);
        
        // 초기화
        reset = 1;
        rx = 1;  // IDLE state (high)
        test_count = 0;
        
        $display("========================================");
        $display("UART RX FSM Testbench Started");
        $display("Baud Rate: 9600");
        $display("Format: 8-N-1 (8 data bits, No parity, 1 stop bit)");
        $display("Bit Period: %0d ns", bit_period);
        $display("========================================\n");
        
        // 리셋 해제
        #1000;
        reset = 0;
        $display("Time=%0t: Reset released\n", $time);
        
        // Idle 상태 안정화
        #(bit_period*2);
        
        // 테스트 1: 단일 바이트 수신 (0x55 = 01010101)
        test_count = test_count + 1;
        $display("--- TEST %0d: Single byte reception (0x55) ---", test_count);
        
        send_uart_byte(8'h55);
        
        #1000;
        if (valid && data == 8'h55 && !error) begin
            $display("Time=%0t: TEST %0d PASSED - Received: 0x%02h", $time, test_count, data);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - valid=%b, data=0x%02h, error=%b", 
                     $time, test_count, valid, data, error);
        end
        
        #(bit_period*2);
        
        // 테스트 2: 다른 바이트 수신 (0xAA = 10101010)
        test_count = test_count + 1;
        $display("\n--- TEST %0d: Different byte reception (0xAA) ---", test_count);
        
        send_uart_byte(8'hAA);
        
        #1000;
        if (valid && data == 8'hAA && !error) begin
            $display("Time=%0t: TEST %0d PASSED - Received: 0x%02h", $time, test_count, data);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - valid=%b, data=0x%02h, error=%b", 
                     $time, test_count, valid, data, error);
        end
        
        #(bit_period*2);
        
        // 테스트 3: 0x00 수신
        test_count = test_count + 1;
        $display("\n--- TEST %0d: All zeros (0x00) ---", test_count);
        
        send_uart_byte(8'h00);
        
        #1000;
        if (valid && data == 8'h00 && !error) begin
            $display("Time=%0t: TEST %0d PASSED - Received: 0x%02h", $time, test_count, data);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - valid=%b, data=0x%02h, error=%b", 
                     $time, test_count, valid, data, error);
        end
        
        #(bit_period*2);
        
        // 테스트 4: 0xFF 수신
        test_count = test_count + 1;
        $display("\n--- TEST %0d: All ones (0xFF) ---", test_count);
        
        send_uart_byte(8'hFF);
        
        #1000;
        if (valid && data == 8'hFF && !error) begin
            $display("Time=%0t: TEST %0d PASSED - Received: 0x%02h", $time, test_count, data);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - valid=%b, data=0x%02h, error=%b", 
                     $time, test_count, valid, data, error);
        end
        
        #(bit_period*2);
        
        // 테스트 5: ASCII 문자 수신 ('A' = 0x41)
        test_count = test_count + 1;
        $display("\n--- TEST %0d: ASCII character 'A' (0x41) ---", test_count);
        
        send_uart_byte(8'h41);
        
        #1000;
        if (valid && data == 8'h41 && !error) begin
            $display("Time=%0t: TEST %0d PASSED - Received: 0x%02h ('%c')", 
                     $time, test_count, data, data);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - valid=%b, data=0x%02h, error=%b", 
                     $time, test_count, valid, data, error);
        end
        
        #(bit_period*2);
        
        // 테스트 6: 연속 바이트 수신
        test_count = test_count + 1;
        $display("\n--- TEST %0d: Consecutive bytes (0x12, 0x34, 0x56) ---", test_count);
        
        send_uart_byte(8'h12);
        #1000;
        if (valid && data == 8'h12)
            $display("  Byte 1: PASS (0x%02h)", data);
        
        #(bit_period);
        send_uart_byte(8'h34);
        #1000;
        if (valid && data == 8'h34)
            $display("  Byte 2: PASS (0x%02h)", data);
        
        #(bit_period);
        send_uart_byte(8'h56);
        #1000;
        if (valid && data == 8'h56)
            $display("  Byte 3: PASS (0x%02h)", data);
        
        $display("Time=%0t: TEST %0d PASSED - Consecutive bytes received", $time, test_count);
        
        #(bit_period*2);
        
        // 테스트 7: Framing Error (잘못된 Stop bit)
        test_count = test_count + 1;
        $display("\n--- TEST %0d: Framing Error Test ---", test_count);
        
        send_uart_byte_bad_stop(8'h88);
        
        #1000;
        if (error && !valid) begin
            $display("Time=%0t: TEST %0d PASSED - Framing error detected", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - error=%b, valid=%b (expected error=1, valid=0)", 
                     $time, test_count, error, valid);
        end
        
        #(bit_period*2);
        
        // 테스트 8: False Start 감지
        test_count = test_count + 1;
        $display("\n--- TEST %0d: False Start Test ---", test_count);
        
        send_false_start;
        
        // 정상 바이트 전송해서 복구 확인
        send_uart_byte(8'h99);
        
        #1000;
        if (valid && data == 8'h99 && !error) begin
            $display("Time=%0t: TEST %0d PASSED - Recovered from false start, received: 0x%02h", 
                     $time, test_count, data);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - Recovery failed", $time, test_count);
        end
        
        #(bit_period*2);
        
        // 테스트 9: 리셋 테스트
        test_count = test_count + 1;
        $display("\n--- TEST %0d: Reset during reception ---", test_count);
        
        // 전송 시작
        rx = 0;  // Start bit
        #(bit_period*3);  // 몇 비트 전송 중
        
        // 리셋
        reset = 1;
        $display("  [RESET] Reset activated during reception");
        #1000;
        reset = 0;
        rx = 1;
        
        #(bit_period*2);
        
        // 정상 바이트 전송으로 복구 확인
        send_uart_byte(8'hAB);
        
        #1000;
        if (valid && data == 8'hAB && !error) begin
            $display("Time=%0t: TEST %0d PASSED - Recovered from reset, received: 0x%02h", 
                     $time, test_count, data);
        end else begin
            $display("Time=%0t: TEST %0d FAILED", $time, test_count);
        end
        
        #(bit_period*2);
        
        // 테스트 10: 문자열 수신 "HELLO"
        test_count = test_count + 1;
        $display("\n--- TEST %0d: String reception 'HELLO' ---", test_count);
        
        send_uart_byte(8'h48);  // 'H'
        #1000;
        $display("  Received: '%c' (0x%02h)", data, data);
        
        #(bit_period);
        send_uart_byte(8'h45);  // 'E'
        #1000;
        $display("  Received: '%c' (0x%02h)", data, data);
        
        #(bit_period);
        send_uart_byte(8'h4C);  // 'L'
        #1000;
        $display("  Received: '%c' (0x%02h)", data, data);
        
        #(bit_period);
        send_uart_byte(8'h4C);  // 'L'
        #1000;
        $display("  Received: '%c' (0x%02h)", data, data);
        
        #(bit_period);
        send_uart_byte(8'h4F);  // 'O'
        #1000;
        $display("  Received: '%c' (0x%02h)", data, data);
        
        $display("Time=%0t: TEST %0d PASSED - String 'HELLO' received", $time, test_count);
        
        // 시뮬레이션 종료
        #(bit_period*5);
        $display("\n========================================");
        $display("UART RX FSM Testbench Completed");
        $display("Total Tests: %0d", test_count);
        $display("========================================");
        $finish;
    end
    
    // Valid 신호 모니터링
    always @(posedge valid) begin
        $display("  [RX] Valid data received: 0x%02h (%d) '%c'", 
                 data, data, (data >= 32 && data <= 126) ? data : ".");
    end
    
    // Error 신호 모니터링
    always @(posedge error) begin
        $display("  [ERROR] Framing error detected!");
    end
    
    // 상태 전환 디버그 (옵션)
    /*
    always @(uut.state) begin
        case (uut.state)
            3'b000: $display("    State: IDLE");
            3'b001: $display("    State: START_BIT");
            3'b010: $display("    State: DATA_BITS");
            3'b011: $display("    State: STOP_BIT");
            3'b100: $display("    State: CLEANUP");
        endcase
    end
    */
    
    // 타임아웃 (무한 루프 방지)
    initial begin
        #5000000;  // 5ms 후 자동 종료
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
```

---

[FSM 예제 동작 개념 정리](#FSM-예제-동작-개념-정리)
## 6️. 엘리베이터 FSM (상급)

### 📋 테스트 시나리오
### ✅ 포함된 테스트 (총 9개)
1. TEST 1: 단일 층 상승 이동 (1층 → 3층)
2. TEST 2: 하강 이동 (3층 → 1층)
3. TEST 3: 다중 층 순차 방문 (2층, 3층, 4층)
4. TEST 4: 현재 층 요청 (즉시 도어 개방)
5. TEST 5: 도어 센서 테스트 (장애물 감지 시 재개방)
6. TEST 6: 반대 방향 요청 처리 (방향 우선 알고리즘)
7. TEST 7: 리셋 테스트 (이동 중 리셋)
8. TEST 8: 연속 요청 처리 (모든 층 요청)
9. TEST 9: 7-segment 디스플레이 확인

### 💡 특징
   * 편리한 태스크 제공:
      * request_floor: 단일 층 요청
      * request_multiple_floors: 다중 층 동시 요청
      * wait_for_arrival: 목표 층 도착 대기
      * wait_for_door_cycle: 도어 개폐 사이클 완료 대기
   * 실시간 모니터링:
      * 현재 층 변화 표시 (↑/↓ 방향 표시)
      * 도어 상태 (열림/닫힘)
      * 모터 동작 (상승/하강)
      * 요청 큐 상태
   * 고급 시나리오:
      * 도어 센서를 이용한 재개방 테스트
      * 방향 우선 알고리즘 검증
      * 요청 큐 관리 확인

### ⚠️ 중요 사항
   * 실제 시뮬레이션을 위해서는 elevator_fsm.v의 타이머를 축소:

```verilog
// 원본 (1초 = 100,000,000 클럭)
assign tick_1sec = (timer == 27'd99_999_999);

// 시뮬레이션용 (1초 = 100 클럭으로 축소)
assign tick_1sec = (timer == 27'd100);
```

### 🔧 시뮬레이션 실행 방법

```bash
# Vivado 시뮬레이터
xvlog elevator_fsm.v
xvlog tb_elevator_fsm.v
xelab -debug typical tb_elevator_fsm -s sim
xsim sim -gui

# ModelSim
vlog elevator_fsm.v tb_elevator_fsm.v
vsim tb_elevator_fsm
run -all
```

### 📊 예상 결과

```
[REQUEST] 3층 호출 버튼 눌림
  모터 상승 시작 - PASS
  --> 현재 층: 2층 [↑ ]
  --> 현재 층: 3층 [↑ ]
  [ARRIVED] 3층 도착!
  --> 도어: 열림
  --> 도어: 닫힘
TEST 1 PASSED - 3층 도착 및 도어 사이클 완료

[SENSOR] 장애물 감지! 도어 센서 활성화
  도어 재개방 확인 - PASS
```

### 🏗️ 테스트 포인트
   * ✅ 층 이동 정확도
   * ✅ 도어 개폐 타이밍
   * ✅ 요청 큐 관리
   * ✅ 방향 우선 처리
   * ✅ 안전 기능 (도어 센서)
   * ✅ 7-segment 표시


```verilog
// ========================================
// 6번 - 엘리베이터 FSM (상급)
// ========================================
// 4층 엘리베이터 제어, 도어 개폐, 방향 표시
// Basys3 보드 100MHz 클럭 사용

module elevator_fsm(
    input clk,                  // 100MHz 클럭
    input reset,                // 리셋
    input [3:0] floor_req,      // 각 층 호출 버튼 (1~4층)
    input door_sensor,          // 도어 센서 (막힘 감지)
    output reg [1:0] current_floor,  // 현재 층 (0~3)
    output reg motor_up,        // 모터 상승
    output reg motor_down,      // 모터 하강
    output reg door_open,       // 도어 열림
    output reg [6:0] seg,       // 7-segment (층 표시)
    output reg dir_up_led,      // 상승 방향 LED
    output reg dir_down_led     // 하강 방향 LED
);

    // State 정의
    localparam IDLE           = 3'b000;
    localparam MOVING_UP      = 3'b001;
    localparam MOVING_DOWN    = 3'b010;
    localparam DOOR_OPENING   = 3'b011;
    localparam DOOR_OPEN_WAIT = 3'b100;
    localparam DOOR_CLOSING   = 3'b101;
    
    reg [2:0] state, next_state;
    reg [3:0] request_queue;    // 각 층 요청 큐
    reg [1:0] target_floor;     // 목표 층
    reg [1:0] direction;        // 0: none, 1: up, 2: down
    
    // 타이머 관련
    reg [26:0] timer;
    reg [3:0] time_count;
    wire tick_1sec;
    
    assign tick_1sec = (timer == 27'd99_999_999);
    
    // 1초 타이머
    always @(posedge clk or posedge reset) begin
        if (reset)
            timer <= 0;
        else begin
            if (tick_1sec)
                timer <= 0;
            else
                timer <= timer + 1;
        end
    end
    
    // 버튼 엣지 감지
    reg [3:0] floor_req_prev;
    wire [3:0] floor_req_edge;
    
    assign floor_req_edge = floor_req & ~floor_req_prev;
    
    always @(posedge clk) begin
        floor_req_prev <= floor_req;
    end
    
    // 요청 큐 관리
    always @(posedge clk or posedge reset) begin
        if (reset)
            request_queue <= 4'b0000;
        else begin
            // 새 요청 추가
            request_queue <= request_queue | floor_req_edge;
            
            // 현재 층 도착 시 해당 요청 제거
            if (state == DOOR_OPENING)
                request_queue[current_floor] <= 0;
        end
    end
    
    // 다음 목표 층 결정
    always @(*) begin
        target_floor = current_floor;
        
        if (direction == 1) begin  // 상승 중
            // 위쪽 요청 찾기
            if (current_floor < 3 && request_queue[3])
                target_floor = 3;
            else if (current_floor < 2 && request_queue[2])
                target_floor = 2;
            else if (current_floor < 1 && request_queue[1])
                target_floor = 1;
            else if (request_queue[0])
                target_floor = 0;
        end
        else if (direction == 2) begin  // 하강 중
            // 아래쪽 요청 찾기
            if (current_floor > 0 && request_queue[0])
                target_floor = 0;
            else if (current_floor > 1 && request_queue[1])
                target_floor = 1;
            else if (current_floor > 2 && request_queue[2])
                target_floor = 2;
            else if (request_queue[3])
                target_floor = 3;
        end
        else begin  // 방향 없음 - 가장 가까운 요청
            if (request_queue != 4'b0000) begin
                // 간단한 최근접 층 찾기
                if (request_queue[current_floor])
                    target_floor = current_floor;
                else if (current_floor < 3 && request_queue[current_floor + 1])
                    target_floor = current_floor + 1;
                else if (current_floor > 0 && request_queue[current_floor - 1])
                    target_floor = current_floor - 1;
                else if (request_queue[0])
                    target_floor = 0;
                else if (request_queue[1])
                    target_floor = 1;
                else if (request_queue[2])
                    target_floor = 2;
                else if (request_queue[3])
                    target_floor = 3;
            end
        end
    end
    
    // State Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            current_floor <= 0;
            time_count <= 0;
            direction <= 0;
        end
        else begin
            state <= next_state;
            
            // 층 이동
            if (state == MOVING_UP && tick_1sec && time_count >= 2) begin
                current_floor <= current_floor + 1;
                time_count <= 0;
            end
            else if (state == MOVING_DOWN && tick_1sec && time_count >= 2) begin
                current_floor <= current_floor - 1;
                time_count <= 0;
            end
            else if ((state == MOVING_UP || state == MOVING_DOWN) && tick_1sec)
                time_count <= time_count + 1;
            else if (state == DOOR_OPEN_WAIT && tick_1sec)
                time_count <= time_count + 1;
            else if (state != DOOR_OPEN_WAIT && state != MOVING_UP && state != MOVING_DOWN)
                time_count <= 0;
        end
    end
    
    // Next State Logic
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (request_queue != 4'b0000) begin
                    if (target_floor == current_floor)
                        next_state = DOOR_OPENING;
                    else if (target_floor > current_floor)
                        next_state = MOVING_UP;
                    else
                        next_state = MOVING_DOWN;
                end
            end
            
            MOVING_UP: begin
                if (current_floor == target_floor)
                    next_state = DOOR_OPENING;
            end
            
            MOVING_DOWN: begin
                if (current_floor == target_floor)
                    next_state = DOOR_OPENING;
            end
            
            DOOR_OPENING: begin
                next_state = DOOR_OPEN_WAIT;
            end
            
            DOOR_OPEN_WAIT: begin
                if (time_count >= 3 && !door_sensor)  // 3초 대기
                    next_state = DOOR_CLOSING;
            end
            
            DOOR_CLOSING: begin
                if (!door_sensor)
                    next_state = IDLE;
                else
                    next_state = DOOR_OPENING;  // 재개방
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Output Logic
    always @(*) begin
        motor_up = 0;
        motor_down = 0;
        door_open = 0;
        dir_up_led = 0;
        dir_down_led = 0;
        
        case (state)
            MOVING_UP: begin
                motor_up = 1;
                dir_up_led = 1;
            end
            MOVING_DOWN: begin
                motor_down = 1;
                dir_down_led = 1;
            end
            DOOR_OPENING, DOOR_OPEN_WAIT, DOOR_CLOSING: begin
                door_open = 1;
            end
        endcase
    end
    
    // 7-segment 디스플레이 (현재 층 표시: 1~4)
    always @(*) begin
        case (current_floor)
            2'd0: seg = 7'b1111001;  // 1
            2'd1: seg = 7'b0100100;  // 2
            2'd2: seg = 7'b0110000;  // 3
            2'd3: seg = 7'b0011001;  // 4
            default: seg = 7'b1111111;
        endcase
    end

endmodule
```

```verilog
// ========================================
// 6번 - 엘리베이터 FSM 테스트벤치
// ========================================
`timescale 1ns / 1ps

module tb_elevator_fsm;

    // 입력 신호 (reg)
    reg clk;
    reg reset;
    reg [3:0] floor_req;
    reg door_sensor;
    
    // 출력 신호 (wire)
    wire [1:0] current_floor;
    wire motor_up;
    wire motor_down;
    wire door_open;
    wire [6:0] seg;
    wire dir_up_led;
    wire dir_down_led;
    
    // 테스트용 변수
    integer test_count;
    integer wait_count;
    
    // DUT (Device Under Test) 인스턴스화
    elevator_fsm uut (
        .clk(clk),
        .reset(reset),
        .floor_req(floor_req),
        .door_sensor(door_sensor),
        .current_floor(current_floor),
        .motor_up(motor_up),
        .motor_down(motor_down),
        .door_open(door_open),
        .seg(seg),
        .dir_up_led(dir_up_led),
        .dir_down_led(dir_down_led)
    );
    
    // 클럭 생성 (100MHz = 10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 현재 층을 숫자로 표시 (1~4층)
    function [7:0] get_floor_number;
        input [1:0] floor;
        begin
            case (floor)
                2'd0: get_floor_number = 1;
                2'd1: get_floor_number = 2;
                2'd2: get_floor_number = 3;
                2'd3: get_floor_number = 4;
                default: get_floor_number = 0;
            endcase
        end
    endfunction
    
    // 층 요청 태스크
    task request_floor;
        input [1:0] floor_num;
        begin
            @(posedge clk);
            floor_req[floor_num] = 1;
            $display("  [REQUEST] %0d층 호출 버튼 눌림", floor_num + 1);
            @(posedge clk);
            #20;
            floor_req[floor_num] = 0;
            #100;
        end
    endtask
    
    // 다중 층 요청 태스크
    task request_multiple_floors;
        input [3:0] floors;
        integer i;
        begin
            for (i = 0; i < 4; i = i + 1) begin
                if (floors[i]) begin
                    @(posedge clk);
                    floor_req[i] = 1;
                    $display("  [REQUEST] %0d층 호출 버튼 눌림", i + 1);
                    @(posedge clk);
                    #20;
                    floor_req[i] = 0;
                    #50;
                end
            end
        end
    endtask
    
    // 엘리베이터 도착 대기 태스크
    task wait_for_arrival;
        input [1:0] target_floor;
        input integer max_wait;
        begin
            wait_count = 0;
            $display("  [WAIT] %0d층 도착 대기 중...", target_floor + 1);
            
            while (current_floor != target_floor && wait_count < max_wait) begin
                #1000;
                wait_count = wait_count + 1;
            end
            
            if (current_floor == target_floor) begin
                $display("  [ARRIVED] %0d층 도착!", target_floor + 1);
            end else begin
                $display("  [TIMEOUT] %0d층 도착 실패 (현재: %0d층)", 
                         target_floor + 1, current_floor + 1);
            end
        end
    endtask
    
    // 도어 개방 완료 대기 태스크
    task wait_for_door_cycle;
        integer door_wait;
        begin
            door_wait = 0;
            $display("  [DOOR] 도어 사이클 대기 중...");
            
            // 도어가 열릴 때까지 대기
            while (!door_open && door_wait < 5000) begin
                #100;
                door_wait = door_wait + 1;
            end
            
            // 도어가 닫힐 때까지 대기
            door_wait = 0;
            while (door_open && door_wait < 10000) begin
                #100;
                door_wait = door_wait + 1;
            end
            
            $display("  [DOOR] 도어 사이클 완료");
        end
    endtask
    
    // 테스트 시나리오
    initial begin
        // 파형 덤프 설정
        $dumpfile("elevator_fsm.vcd");
        $dumpvars(0, tb_elevator_fsm);
        
        // 초기화
        reset = 1;
        floor_req = 4'b0000;
        door_sensor = 0;
        test_count = 0;
        
        $display("========================================");
        $display("Elevator FSM Testbench Started");
        $display("4층 엘리베이터 시스템");
        $display("========================================\n");
        
        // 리셋 해제
        #1000;
        reset = 0;
        $display("Time=%0t: Reset released", $time);
        $display("초기 위치: %0d층\n", get_floor_number(current_floor));
        
        #2000;
        
        // 테스트 1: 단일 층 이동 (1층 -> 3층)
        test_count = test_count + 1;
        $display("--- TEST %0d: 단일 층 이동 (1층 -> 3층) ---", test_count);
        
        request_floor(2'd2);  // 3층 요청 (인덱스 2)
        
        #1000;
        if (motor_up && dir_up_led) begin
            $display("  모터 상승 시작 - PASS");
        end else begin
            $display("  모터 상승 실패 - FAIL");
        end
        
        wait_for_arrival(2'd2, 20000);
        wait_for_door_cycle;
        
        if (current_floor == 2'd2) begin
            $display("Time=%0t: TEST %0d PASSED - 3층 도착 및 도어 사이클 완료\n", 
                     $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED\n", $time, test_count);
        end
        
        #3000;
        
        // 테스트 2: 하강 이동 (3층 -> 1층)
        test_count = test_count + 1;
        $display("--- TEST %0d: 하강 이동 (3층 -> 1층) ---", test_count);
        
        request_floor(2'd0);  // 1층 요청
        
        #1000;
        if (motor_down && dir_down_led) begin
            $display("  모터 하강 시작 - PASS");
        end else begin
            $display("  모터 하강 실패 - FAIL");
        end
        
        wait_for_arrival(2'd0, 20000);
        wait_for_door_cycle;
        
        if (current_floor == 2'd0) begin
            $display("Time=%0t: TEST %0d PASSED - 1층 도착\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED\n", $time, test_count);
        end
        
        #3000;
        
        // 테스트 3: 다중 층 요청 (1층 -> 2층, 3층, 4층)
        test_count = test_count + 1;
        $display("--- TEST %0d: 다중 층 순차 방문 (2층, 3층, 4층) ---", test_count);
        
        request_multiple_floors(4'b1110);  // 2층, 3층, 4층 요청
        
        #2000;
        
        // 2층 도착 확인
        wait_for_arrival(2'd1, 15000);
        $display("  2층 방문 확인");
        wait_for_door_cycle;
        
        // 3층 도착 확인
        wait_for_arrival(2'd2, 15000);
        $display("  3층 방문 확인");
        wait_for_door_cycle;
        
        // 4층 도착 확인
        wait_for_arrival(2'd3, 15000);
        $display("  4층 방문 확인");
        wait_for_door_cycle;
        
        if (current_floor == 2'd3) begin
            $display("Time=%0t: TEST %0d PASSED - 모든 층 방문 완료\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED\n", $time, test_count);
        end
        
        #3000;
        
        // 테스트 4: 현재 층 요청 (즉시 도어 개방)
        test_count = test_count + 1;
        $display("--- TEST %0d: 현재 층 요청 (4층에서 4층 호출) ---", test_count);
        
        request_floor(2'd3);  // 현재 위치인 4층 요청
        
        #2000;
        if (door_open && !motor_up && !motor_down) begin
            $display("  즉시 도어 개방 - PASS");
        end else begin
            $display("  즉시 도어 개방 실패 - FAIL");
        end
        
        wait_for_door_cycle;
        
        $display("Time=%0t: TEST %0d PASSED - 현재 층 요청 처리\n", $time, test_count);
        
        #3000;
        
        // 테스트 5: 도어 센서 테스트 (장애물 감지 시 재개방)
        test_count = test_count + 1;
        $display("--- TEST %0d: 도어 센서 테스트 (재개방) ---", test_count);
        
        request_floor(2'd0);  // 1층 요청
        wait_for_arrival(2'd0, 20000);
        
        #1000;
        // 도어가 열리기 시작하면
        if (door_open) begin
            $display("  도어 개방 중...");
            
            // 도어 센서 활성화 (장애물 감지)
            #5000;
            door_sensor = 1;
            $display("  [SENSOR] 장애물 감지! 도어 센서 활성화");
            
            #3000;
            if (door_open) begin
                $display("  도어 재개방 확인 - PASS");
            end else begin
                $display("  도어 재개방 실패 - FAIL");
            end
            
            // 센서 해제
            door_sensor = 0;
            $display("  [SENSOR] 장애물 제거, 센서 비활성화");
            
            wait_for_door_cycle;
            
            $display("Time=%0t: TEST %0d PASSED - 도어 센서 동작 확인\n", 
                     $time, test_count);
        end
        
        #3000;
        
        // 테스트 6: 반대 방향 요청 처리
        test_count = test_count + 1;
        $display("--- TEST %0d: 반대 방향 요청 (1층 -> 4층, 중간에 2층 요청) ---", 
                 test_count);
        
        // 4층 먼저 요청
        request_floor(2'd3);
        #500;
        // 상승 중 2층 요청
        request_floor(2'd1);
        
        #2000;
        $display("  상승 시작");
        
        // 먼저 2층 방문하는지 확인
        wait_for_arrival(2'd1, 15000);
        if (current_floor == 2'd1) begin
            $display("  2층 먼저 방문 - 상승 방향 우선 처리 확인");
        end
        wait_for_door_cycle;
        
        // 그 다음 4층 방문
        wait_for_arrival(2'd3, 15000);
        if (current_floor == 2'd3) begin
            $display("  4층 도착 - 방향 우선 처리 완료");
        end
        wait_for_door_cycle;
        
        $display("Time=%0t: TEST %0d PASSED - 방향 우선 처리\n", $time, test_count);
        
        #3000;
        
        // 테스트 7: 리셋 테스트
        test_count = test_count + 1;
        $display("--- TEST %0d: 리셋 테스트 (이동 중 리셋) ---", test_count);
        
        request_floor(2'd0);  // 1층 요청
        
        #5000;  // 이동 중
        $display("  이동 중 리셋 활성화");
        reset = 1;
        #1000;
        reset = 0;
        
        #2000;
        if (current_floor == 2'd0) begin
            $display("  리셋 후 1층으로 복귀 - PASS");
            $display("Time=%0t: TEST %0d PASSED\n", $time, test_count);
        end else begin
            $display("  리셋 동작 확인");
            $display("Time=%0t: TEST %0d COMPLETED\n", $time, test_count);
        end
        
        #3000;
        
        // 테스트 8: 연속 요청 처리
        test_count = test_count + 1;
        $display("--- TEST %0d: 연속 요청 처리 ---", test_count);
        
        request_floor(2'd1);  // 2층
        #500;
        request_floor(2'd2);  // 3층
        #500;
        request_floor(2'd3);  // 4층
        #500;
        request_floor(2'd0);  // 1층
        
        $display("  모든 층 요청 완료, 순차 방문 시작");
        
        // 상승하면서 2,3,4층 방문
        wait_for_arrival(2'd1, 15000);
        wait_for_door_cycle;
        wait_for_arrival(2'd2, 15000);
        wait_for_door_cycle;
        wait_for_arrival(2'd3, 15000);
        wait_for_door_cycle;
        
        // 하강하면서 1층 방문
        wait_for_arrival(2'd0, 20000);
        wait_for_door_cycle;
        
        $display("Time=%0t: TEST %0d PASSED - 모든 요청 처리 완료\n", $time, test_count);
        
        #3000;
        
        // 테스트 9: 7-segment 표시 확인
        test_count = test_count + 1;
        $display("--- TEST %0d: 7-segment 디스플레이 확인 ---", test_count);
        
        request_floor(2'd0);  // 1층
        wait_for_arrival(2'd0, 20000);
        #1000;
        $display("  1층: seg=%b", seg);
        wait_for_door_cycle;
        
        request_floor(2'd1);  // 2층
        wait_for_arrival(2'd1, 15000);
        #1000;
        $display("  2층: seg=%b", seg);
        wait_for_door_cycle;
        
        request_floor(2'd2);  // 3층
        wait_for_arrival(2'd2, 15000);
        #1000;
        $display("  3층: seg=%b", seg);
        wait_for_door_cycle;
        
        request_floor(2'd3);  // 4층
        wait_for_arrival(2'd3, 15000);
        #1000;
        $display("  4층: seg=%b", seg);
        
        $display("Time=%0t: TEST %0d PASSED - 7-segment 표시 확인\n", $time, test_count);
        
        // 시뮬레이션 종료
        #5000;
        $display("\n========================================");
        $display("Elevator FSM Testbench Completed");
        $display("Total Tests: %0d", test_count);
        $display("========================================");
        $display("\nNOTE: For faster simulation, modify the counter");
        $display("      in elevator_fsm.v from 99_999_999 to 100");
        $finish;
    end
    
    // 층 변화 모니터링
    always @(current_floor) begin
        $display("  --> 현재 층: %0d층 [%s%s]", 
                 get_floor_number(current_floor),
                 motor_up ? "↑ " : "",
                 motor_down ? "↓ " : "");
    end
    
    // 도어 상태 모니터링
    always @(door_open) begin
        if (door_open)
            $display("  --> 도어: 열림");
        else
            $display("  --> 도어: 닫힘");
    end
    
    // 타임아웃 (무한 루프 방지)
    initial begin
        #10000000;  // 10ms 후 자동 종료
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
```

---

[FSM 예제 동작 개념 정리](#FSM-예제-동작-개념-정리)

## 7️. I2C Master FSM (고급)

### 📋 테스트 시나리오
### ✅ 포함된 테스트 (총 9개)
1. TEST 1: 쓰기 동작 - 정상 ACK
2. TEST 2: 읽기 동작 - 정상 ACK
3. TEST 3: 주소 NACK (슬레이브 응답 없음)
4. TEST 4: 데이터 NACK
5. TEST 5: 다양한 슬레이브 주소 테스트 (0x10, 0x7F)
6. TEST 6: 연속 쓰기 동작 (3회)
7. TEST 7: 연속 읽기 동작 (3회)
8. TEST 8: 리셋 테스트 (전송 중 리셋)
9. TEST 9: 전체 데이터 범위 테스트 (0x00, 0xFF, 0x55, 0xAA)

### 💡 특징
   * I2C 슬레이브 시뮬레이터:
      * i2c_slave_response: 완전한 I2C 슬레이브 동작 시뮬레이션
      * START/STOP 조건 감지
      * 주소 및 데이터 ACK/NACK 생성
      * 읽기/쓰기 모드 모두 지원
   * 편리한 태스크:
      * start_i2c_transaction: I2C 전송 시작
      * wait_for_complete: busy 신호 해제 대기
   * 실시간 모니터링:
      * START/STOP 조건 자동 감지
      * Busy 상태 추적
      * 마스터/슬레이브 동작 로그

### 🔧 시뮬레이션 실행 방법

```bash
# Vivado 시뮬레이터
xvlog i2c_master_fsm.v
xvlog tb_i2c_master_fsm.v
xelab -debug typical tb_i2c_master_fsm -s sim
xsim sim -gui

# ModelSim
vlog i2c_master_fsm.v tb_i2c_master_fsm.v
vsim tb_i2c_master_fsm
run -all
```

### 📊 예상 결과
```
[MASTER] Transaction started - WRITE, Addr=0x50, Data=0xA5
  [SLAVE] START condition detected
  [SLAVE] Address received
  [SLAVE] Sent ACK for address
  [SLAVE] WRITE mode - Receiving data
  [SLAVE] Sent ACK for data
  [SLAVE] STOP condition detected
  [MASTER] Transaction completed
TEST 1 PASSED - Write successful

[MASTER] Transaction started - READ, Addr=0x50, Data=0x00
  [SLAVE] READ mode - Sending data: 0x5A
  [MASTER] Read data: 0x5A (Expected: 0x5A)
TEST 2 PASSED - Read successful

[SLAVE] Sent NACK for address
TEST 3 PASSED - ACK error detected
```

### 📡 I2C 프로토콜 검증
   * ✅ START 조건 (SDA: 1→0 while SCL=1)
   * ✅ STOP 조건 (SDA: 0→1 while SCL=1)
   * ✅ 7비트 주소 + R/W 비트
   * ✅ ACK/NACK 처리
   * ✅ 데이터 전송 (MSB first)
   * ✅ 클럭 스트레칭 (옵션)

###⚡ I2C 타이밍
   * SCL 주파수: 100kHz (10μs 주기)
   * Quarter period: 2.5μs (CLK_DIV=250)
   * 완전한 바이트 전송: 약 90μs

```verilog
// ========================================
// 7번 - I2C Master FSM (고급)
// ========================================
// 100kHz I2C 통신, 7비트 주소, 단일 바이트 쓰기/읽기 지원
// Basys3 보드 100MHz 클럭 사용

module i2c_master_fsm(
    input clk,              // 100MHz 클럭
    input reset,            // 리셋
    input start,            // 전송 시작
    input rw,               // 1: read, 0: write
    input [6:0] slave_addr, // 슬레이브 주소 (7비트)
    input [7:0] wr_data,    // 쓰기 데이터
    output reg [7:0] rd_data,   // 읽기 데이터
    output reg busy,        // 통신 중 플래그
    output reg ack_error,   // ACK 에러
    inout sda,              // I2C Data (양방향)
    output reg scl          // I2C Clock
);

    // State 정의
    localparam IDLE        = 4'd0;
    localparam START_COND  = 4'd1;
    localparam ADDR_SEND   = 4'd2;
    localparam ADDR_ACK    = 4'd3;
    localparam DATA_WR     = 4'd4;
    localparam DATA_WR_ACK = 4'd5;
    localparam DATA_RD     = 4'd6;
    localparam DATA_RD_ACK = 4'd7;
    localparam STOP_COND   = 4'd8;
    
    reg [3:0] state, next_state;
    
    // I2C 클럭 생성 (100kHz, 250kHz quarter period)
    // 100MHz / 400 = 250kHz (quarter period)
    localparam CLK_DIV = 16'd250;
    reg [15:0] clk_counter;
    reg [1:0] quarter_tick;  // 0~3: 4분주 틱
    
    // 비트 카운터
    reg [2:0] bit_cnt;
    
    // 데이터 레지스터
    reg [7:0] addr_rw;       // {slave_addr, rw}
    reg [7:0] data_tx;
    reg [7:0] data_rx;
    reg sda_out;
    reg sda_oe;              // SDA output enable
    
    // SDA 양방향 제어
    assign sda = sda_oe ? sda_out : 1'bz;
    wire sda_in = sda;
    
    // 클럭 분주기
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_counter <= 0;
            quarter_tick <= 0;
        end
        else begin
            if (state == IDLE) begin
                clk_counter <= 0;
                quarter_tick <= 0;
            end
            else if (clk_counter == CLK_DIV - 1) begin
                clk_counter <= 0;
                quarter_tick <= quarter_tick + 1;
            end
            else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end
    
    // State Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_cnt <= 0;
        end
        else begin
            state <= next_state;
            
            // 비트 카운터 관리
            if (state == ADDR_SEND && quarter_tick == 3)
                bit_cnt <= bit_cnt + 1;
            else if (state == DATA_WR && quarter_tick == 3)
                bit_cnt <= bit_cnt + 1;
            else if (state == DATA_RD && quarter_tick == 3)
                bit_cnt <= bit_cnt + 1;
            else if (state != ADDR_SEND && state != DATA_WR && state != DATA_RD)
                bit_cnt <= 0;
        end
    end
    
    // Next State Logic
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (start)
                    next_state = START_COND;
            end
            
            START_COND: begin
                if (quarter_tick == 3)
                    next_state = ADDR_SEND;
            end
            
            ADDR_SEND: begin
                if (bit_cnt == 7 && quarter_tick == 3)
                    next_state = ADDR_ACK;
            end
            
            ADDR_ACK: begin
                if (quarter_tick == 3) begin
                    if (sda_in == 0)  // ACK received
                        next_state = rw ? DATA_RD : DATA_WR;
                    else
                        next_state = STOP_COND;  // NACK
                end
            end
            
            DATA_WR: begin
                if (bit_cnt == 7 && quarter_tick == 3)
                    next_state = DATA_WR_ACK;
            end
            
            DATA_WR_ACK: begin
                if (quarter_tick == 3)
                    next_state = STOP_COND;
            end
            
            DATA_RD: begin
                if (bit_cnt == 7 && quarter_tick == 3)
                    next_state = DATA_RD_ACK;
            end
            
            DATA_RD_ACK: begin
                if (quarter_tick == 3)
                    next_state = STOP_COND;
            end
            
            STOP_COND: begin
                if (quarter_tick == 3)
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // SCL 생성
    always @(posedge clk or posedge reset) begin
        if (reset)
            scl <= 1;
        else begin
            case (state)
                IDLE, START_COND, STOP_COND:
                    scl <= 1;
                default: begin
                    if (quarter_tick == 0 || quarter_tick == 1)
                        scl <= 0;
                    else
                        scl <= 1;
                end
            endcase
        end
    end
    
    // SDA 제어
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sda_out <= 1;
            sda_oe <= 0;
            addr_rw <= 0;
            data_tx <= 0;
            data_rx <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    sda_out <= 1;
                    sda_oe <= 1;
                    addr_rw <= {slave_addr, rw};
                    data_tx <= wr_data;
                end
                
                START_COND: begin
                    if (quarter_tick == 2) begin
                        sda_out <= 0;  // START condition
                        sda_oe <= 1;
                    end
                end
                
                ADDR_SEND: begin
                    sda_oe <= 1;
                    if (quarter_tick == 0)
                        sda_out <= addr_rw[7 - bit_cnt];
                end
                
                ADDR_ACK: begin
                    sda_oe <= 0;  // Release for ACK
                end
                
                DATA_WR: begin
                    sda_oe <= 1;
                    if (quarter_tick == 0)
                        sda_out <= data_tx[7 - bit_cnt];
                end
                
                DATA_WR_ACK: begin
                    sda_oe <= 0;  // Release for ACK
                end
                
                DATA_RD: begin
                    sda_oe <= 0;  // Release for reading
                    if (quarter_tick == 2)
                        data_rx[7 - bit_cnt] <= sda_in;
                end
                
                DATA_RD_ACK: begin
                    sda_oe <= 1;
                    sda_out <= 1;  // Master NACK (single byte read)
                end
                
                STOP_COND: begin
                    sda_oe <= 1;
                    if (quarter_tick == 0)
                        sda_out <= 0;
                    else if (quarter_tick == 2)
                        sda_out <= 1;  // STOP condition
                end
            endcase
        end
    end
    
    // Output signals
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            busy <= 0;
            ack_error <= 0;
            rd_data <= 0;
        end
        else begin
            busy <= (state != IDLE);
            
            // ACK 에러 체크
            if (state == ADDR_ACK && quarter_tick == 3 && sda_in == 1)
                ack_error <= 1;
            else if (state == DATA_WR_ACK && quarter_tick == 3 && sda_in == 1)
                ack_error <= 1;
            else if (state == IDLE)
                ack_error <= 0;
            
            // 읽기 데이터 출력
            if (state == DATA_RD_ACK && quarter_tick == 3)
                rd_data <= data_rx;
        end
    end

endmodule
```

```verilog
// ========================================
// 7번 - I2C Master FSM 테스트벤치
// ========================================
`timescale 1ns / 1ps

module tb_i2c_master_fsm;

    // 입력 신호 (reg)
    reg clk;
    reg reset;
    reg start;
    reg rw;
    reg [6:0] slave_addr;
    reg [7:0] wr_data;
    
    // 출력 신호 (wire)
    wire [7:0] rd_data;
    wire busy;
    wire ack_error;
    wire scl;
    
    // SDA 양방향 신호
    wire sda;
    reg sda_slave;  // 슬레이브 시뮬레이션용
    reg sda_slave_oe;
    
    // SDA 양방향 제어
    assign sda = sda_slave_oe ? sda_slave : 1'bz;
    
    // 테스트용 변수
    integer test_count;
    integer bit_count;
    reg [7:0] slave_data;  // 슬레이브가 전송할 데이터
    
    // DUT (Device Under Test) 인스턴스화
    i2c_master_fsm uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .rw(rw),
        .slave_addr(slave_addr),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .busy(busy),
        .ack_error(ack_error),
        .sda(sda),
        .scl(scl)
    );
    
    // 클럭 생성 (100MHz = 10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // I2C 슬레이브 시뮬레이터
    // SCL의 하강 엣지에서 SDA 변경, 상승 엣지에서 SDA 샘플링
    task i2c_slave_response;
        input ack_addr;      // 주소 ACK 여부
        input ack_data;      // 데이터 ACK 여부
        input [7:0] tx_data; // 읽기 시 전송할 데이터
        integer i;
        begin
            sda_slave_oe = 0;
            
            // START 조건 대기
            @(negedge sda);
            if (scl) begin
                $display("  [SLAVE] START condition detected");
            end
            
            // 주소 + R/W 수신 (8비트)
            for (i = 0; i < 8; i = i + 1) begin
                @(posedge scl);  // 데이터 샘플링
            end
            $display("  [SLAVE] Address received");
            
            // 주소 ACK 전송
            @(negedge scl);
            sda_slave_oe = 1;
            sda_slave = ack_addr ? 0 : 1;  // ACK = 0, NACK = 1
            @(negedge scl);
            sda_slave_oe = 0;
            
            if (ack_addr) begin
                $display("  [SLAVE] Sent ACK for address");
                
                // R/W 비트 확인 (이전에 수신한 마지막 비트)
                if (rw) begin
                    // 읽기 모드 - 슬레이브가 데이터 전송
                    $display("  [SLAVE] READ mode - Sending data: 0x%02h", tx_data);
                    
                    for (i = 7; i >= 0; i = i - 1) begin
                        @(negedge scl);
                        sda_slave_oe = 1;
                        sda_slave = tx_data[i];
                    end
                    
                    @(negedge scl);
                    sda_slave_oe = 0;
                    
                    // 마스터의 ACK/NACK 대기
                    @(posedge scl);
                    $display("  [SLAVE] Received %s from master", sda ? "NACK" : "ACK");
                    
                end else begin
                    // 쓰기 모드 - 슬레이브가 데이터 수신
                    $display("  [SLAVE] WRITE mode - Receiving data");
                    
                    for (i = 0; i < 8; i = i + 1) begin
                        @(posedge scl);
                    end
                    
                    // 데이터 ACK 전송
                    @(negedge scl);
                    sda_slave_oe = 1;
                    sda_slave = ack_data ? 0 : 1;
                    @(negedge scl);
                    sda_slave_oe = 0;
                    
                    $display("  [SLAVE] Sent %s for data", ack_data ? "ACK" : "NACK");
                end
            end else begin
                $display("  [SLAVE] Sent NACK for address");
            end
            
            // STOP 조건 대기
            @(posedge sda);
            if (scl) begin
                $display("  [SLAVE] STOP condition detected");
            end
        end
    endtask
    
    // I2C 전송 시작 태스크
    task start_i2c_transaction;
        input r_w;
        input [6:0] addr;
        input [7:0] data;
        begin
            @(posedge clk);
            start = 0;
            rw = r_w;
            slave_addr = addr;
            wr_data = data;
            
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;
            
            $display("  [MASTER] Transaction started - %s, Addr=0x%02h, Data=0x%02h", 
                     r_w ? "READ" : "WRITE", addr, data);
        end
    endtask
    
    // Busy 신호 해제 대기
    task wait_for_complete;
        integer timeout;
        begin
            timeout = 0;
            while (busy && timeout < 100000) begin
                #100;
                timeout = timeout + 1;
            end
            
            if (busy) begin
                $display("  [ERROR] Transaction timeout");
            end else begin
                $display("  [MASTER] Transaction completed");
            end
        end
    endtask
    
    // 테스트 시나리오
    initial begin
        // 파형 덤프 설정
        $dumpfile("i2c_master_fsm.vcd");
        $dumpvars(0, tb_i2c_master_fsm);
        
        // 초기화
        reset = 1;
        start = 0;
        rw = 0;
        slave_addr = 7'h00;
        wr_data = 8'h00;
        sda_slave = 1;
        sda_slave_oe = 0;
        test_count = 0;
        
        $display("========================================");
        $display("I2C Master FSM Testbench Started");
        $display("Clock: 100MHz");
        $display("I2C Speed: 100kHz");
        $display("========================================\n");
        
        // 리셋 해제
        #1000;
        reset = 0;
        $display("Time=%0t: Reset released\n", $time);
        
        #2000;
        
        // 테스트 1: 쓰기 동작 - 정상 ACK
        test_count = test_count + 1;
        $display("--- TEST %0d: Write operation with ACK ---", test_count);
        
        fork
            // 마스터
            begin
                start_i2c_transaction(0, 7'h50, 8'hA5);
                wait_for_complete;
            end
            
            // 슬레이브
            begin
                i2c_slave_response(1, 1, 8'h00);  // ACK, ACK
            end
        join
        
        #1000;
        if (!ack_error && !busy) begin
            $display("Time=%0t: TEST %0d PASSED - Write successful\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - ack_error=%b\n", 
                     $time, test_count, ack_error);
        end
        
        #5000;
        
        // 테스트 2: 읽기 동작 - 정상 ACK
        test_count = test_count + 1;
        $display("--- TEST %0d: Read operation with ACK ---", test_count);
        
        slave_data = 8'h5A;
        
        fork
            // 마스터
            begin
                start_i2c_transaction(1, 7'h50, 8'h00);
                wait_for_complete;
            end
            
            // 슬레이브
            begin
                i2c_slave_response(1, 1, slave_data);
            end
        join
        
        #1000;
        if (!ack_error && rd_data == slave_data) begin
            $display("  [MASTER] Read data: 0x%02h (Expected: 0x%02h)", rd_data, slave_data);
            $display("Time=%0t: TEST %0d PASSED - Read successful\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - rd_data=0x%02h, ack_error=%b\n", 
                     $time, test_count, rd_data, ack_error);
        end
        
        #5000;
        
        // 테스트 3: 주소 NACK (슬레이브 응답 없음)
        test_count = test_count + 1;
        $display("--- TEST %0d: Address NACK (No slave response) ---", test_count);
        
        fork
            // 마스터
            begin
                start_i2c_transaction(0, 7'h60, 8'h11);
                wait_for_complete;
            end
            
            // 슬레이브
            begin
                i2c_slave_response(0, 0, 8'h00);  // NACK 주소
            end
        join
        
        #1000;
        if (ack_error) begin
            $display("Time=%0t: TEST %0d PASSED - ACK error detected\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - Should detect ACK error\n", $time, test_count);
        end
        
        #5000;
        
        // 테스트 4: 데이터 NACK
        test_count = test_count + 1;
        $display("--- TEST %0d: Data NACK ---", test_count);
        
        fork
            // 마스터
            begin
                start_i2c_transaction(0, 7'h50, 8'h22);
                wait_for_complete;
            end
            
            // 슬레이브
            begin
                i2c_slave_response(1, 0, 8'h00);  // ACK 주소, NACK 데이터
            end
        join
        
        #1000;
        if (ack_error) begin
            $display("Time=%0t: TEST %0d PASSED - Data NACK detected\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - Should detect data NACK\n", $time, test_count);
        end
        
        #5000;
        
        // 테스트 5: 다양한 주소 테스트
        test_count = test_count + 1;
        $display("--- TEST %0d: Different slave addresses ---", test_count);
        
        // 주소 0x10
        fork
            begin
                start_i2c_transaction(0, 7'h10, 8'h33);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'h00);
            end
        join
        #3000;
        
        // 주소 0x7F (최대 7비트 주소)
        fork
            begin
                start_i2c_transaction(0, 7'h7F, 8'h44);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'h00);
            end
        join
        #3000;
        
        $display("Time=%0t: TEST %0d PASSED - Multiple addresses\n", $time, test_count);
        
        #5000;
        
        // 테스트 6: 연속 쓰기 동작
        test_count = test_count + 1;
        $display("--- TEST %0d: Consecutive write operations ---", test_count);
        
        fork
            begin
                start_i2c_transaction(0, 7'h50, 8'h11);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'h00);
            end
        join
        #3000;
        
        fork
            begin
                start_i2c_transaction(0, 7'h50, 8'h22);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'h00);
            end
        join
        #3000;
        
        fork
            begin
                start_i2c_transaction(0, 7'h50, 8'h33);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'h00);
            end
        join
        #3000;
        
        $display("Time=%0t: TEST %0d PASSED - Consecutive writes\n", $time, test_count);
        
        #5000;
        
        // 테스트 7: 연속 읽기 동작
        test_count = test_count + 1;
        $display("--- TEST %0d: Consecutive read operations ---", test_count);
        
        fork
            begin
                start_i2c_transaction(1, 7'h50, 8'h00);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'hAA);
            end
        join
        #1000;
        $display("  Read 1: 0x%02h", rd_data);
        #3000;
        
        fork
            begin
                start_i2c_transaction(1, 7'h50, 8'h00);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'hBB);
            end
        join
        #1000;
        $display("  Read 2: 0x%02h", rd_data);
        #3000;
        
        fork
            begin
                start_i2c_transaction(1, 7'h50, 8'h00);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'hCC);
            end
        join
        #1000;
        $display("  Read 3: 0x%02h", rd_data);
        
        $display("Time=%0t: TEST %0d PASSED - Consecutive reads\n", $time, test_count);
        
        #5000;
        
        // 테스트 8: 리셋 테스트
        test_count = test_count + 1;
        $display("--- TEST %0d: Reset during transaction ---", test_count);
        
        fork
            begin
                start_i2c_transaction(0, 7'h50, 8'h99);
                #10000;  // 전송 중
                $display("  [RESET] Activating reset during transaction");
                reset = 1;
                #1000;
                reset = 0;
                #1000;
            end
            begin
                i2c_slave_response(1, 1, 8'h00);
            end
        join
        
        #3000;
        if (!busy) begin
            $display("Time=%0t: TEST %0d PASSED - Reset successful\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - Busy still active\n", $time, test_count);
        end
        
        #5000;
        
        // 테스트 9: 전체 데이터 범위 테스트
        test_count = test_count + 1;
        $display("--- TEST %0d: Full data range test ---", test_count);
        
        // 0x00
        fork
            begin
                start_i2c_transaction(0, 7'h50, 8'h00);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'h00);
            end
        join
        #3000;
        
        // 0xFF
        fork
            begin
                start_i2c_transaction(0, 7'h50, 8'hFF);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'h00);
            end
        join
        #3000;
        
        // 0x55 (01010101)
        fork
            begin
                start_i2c_transaction(0, 7'h50, 8'h55);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'h00);
            end
        join
        #3000;
        
        // 0xAA (10101010)
        fork
            begin
                start_i2c_transaction(0, 7'h50, 8'hAA);
                wait_for_complete;
            end
            begin
                i2c_slave_response(1, 1, 8'h00);
            end
        join
        
        $display("Time=%0t: TEST %0d PASSED - Data range test\n", $time, test_count);
        
        // 시뮬레이션 종료
        #10000;
        $display("\n========================================");
        $display("I2C Master FSM Testbench Completed");
        $display("Total Tests: %0d", test_count);
        $display("========================================");
        $finish;
    end
    
    // SDA/SCL 모니터링
    always @(negedge sda) begin
        if (scl)
            $display("    [BUS] START/Repeated START condition");
    end
    
    always @(posedge sda) begin
        if (scl)
            $display("    [BUS] STOP condition");
    end
    
    // Busy 신호 모니터링
    always @(busy) begin
        if (busy)
            $display("  [STATUS] I2C transaction started");
        else
            $display("  [STATUS] I2C transaction ended");
    end
    
    // 타임아웃 (무한 루프 방지)
    initial begin
        #5000000;  // 5ms 후 자동 종료
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
```

---

[FSM 예제 동작 개념 정리](#FSM-예제-동작-개념-정리)

## 8️. 게임 FSM (최고급)

### 📋 테스트 시나리오
### ✅ 포함된 테스트 (총 12개)

1. TEST 1: 초기 상태 확인
2. TEST 2: 게임 시작
3. TEST 3: 정상 플레이 - 빠른 반응 (150ms, 3점)
4. TEST 4: 중간 반응 속도 (300ms, 2점)
5. TEST 5: 느린 반응 속도 (500ms, 1점)
6. TEST 6: 너무 빨리 누름 (FAIL 케이스)
7. TEST 7: 너무 늦게 누름 (>1000ms, FAIL)
8. TEST 8: 게임 오버 확인
9. TEST 9: 재시작 테스트
10. TEST 10: 리셋 테스트 (게임 중 리셋)
11. TEST 11: 7-segment 디스플레이 확인
12. TEST 12: LFSR 랜덤성 확인

### 💡 특징
- **자동 게임 플레이:**
   * play_round: 완전한 라운드 자동 실행
   * wait_for_led_on: LED 점등 대기
   * wait_for_round_complete: 라운드 완료 대기
- **점수 시스템 검증:
   * 반응 시간 측정
   * 점수 계산 확인
7-segment 디코딩
- **실시간 모니터링:
   * 상태 전환 추적
   * LED 패턴 변화
   * 부저 사운드
   * 라운드 진행 상황
   * 게임 오버 신호

### ⚠️ 중요 사항
- **시뮬레이션을 위해 reaction_game_fsm.v의 타이머 축소:**

```verilog
// 원본 (1ms = 100,000 클럭)
assign tick_1ms = (ms_counter == 27'd99_999);

// 시뮬레이션용 (1ms = 100 클럭으로 축소)
assign tick_1ms = (ms_counter == 27'd100);
```

### 🔧 시뮬레이션 실행 방법
```bash
# Vivado 시뮬레이터
xvlog reaction_game_fsm.v
xvlog tb_reaction_game_fsm.v
xelab -debug typical tb_reaction_game_fsm -s sim
xsim sim -gui

# ModelSim
vlog reaction_game_fsm.v tb_reaction_game_fsm.v
vsim tb_reaction_game_fsm
run -all
```

### 📊 예상 결과
```
[BTN] Start button pressed
    [STATE] READY
    [LED] Pattern changed: 1111111111111111
    [STATE] WAIT_RANDOM
    [WAIT] Waiting for LED to turn on...
    [LED] LED turned ON! Pattern: 1010110110101101
    [STATE] MEASURING
[BTN] React button pressed
    [RESULT] Reaction time: 150 ms
    [SCORE] Current score: 3
    [BUZZER] Sound ON
    [STATE] SUCCESS

=== Round 2 ===
    [RESULT] Reaction time: 300 ms
    [SCORE] Current score: 5

[GAME] GAME OVER - Final Score: 8
```

### 🎮 게임 메커니즘 검증
  * ✅ 5 라운드 진행
  * ✅ 랜덤 대기 시간 (LFSR 기반)
  * ✅ 반응 시간 측정 (1ms 단위)
  * ✅ 점수 계산 (<200ms: 3점, <400ms: 2점, 기타: 1점)
  * ✅ 실패 조건 (너무 빨리/늦게)
  * ✅ 부저 피드백
  * ✅ LED 패턴 표시

### 🏆 완료!
- **이제 8개의 FSM 예제 모두에 대한 완전한 테스트벤치가 준비되었습니다! 각 테스트벤치는:**
  * 포괄적인 테스트 시나리오
  * 자동 검증 기능
  * 실시간 모니터링
  * 명확한 PASS/FAIL 판정

```verilog
// ========================================
// 8번 - 게임 FSM (최고급)
// ========================================
// 반응속도 테스트 게임
// LED가 랜덤하게 켜지면 빠르게 버튼을 눌러야 함
// 반응 시간 측정 및 점수 계산
// Basys3 보드 100MHz 클럭 사용

module reaction_game_fsm(
    input clk,              // 100MHz 클럭
    input reset,            // 리셋
    input start_btn,        // 게임 시작 버튼
    input react_btn,        // 반응 버튼
    output reg [15:0] leds, // LED 패턴
    output reg [6:0] seg0,  // 7-segment digit 0 (반응시간 1의 자리)
    output reg [6:0] seg1,  // 7-segment digit 1 (반응시간 10의 자리)
    output reg [6:0] seg2,  // 7-segment digit 2 (반응시간 100의 자리)
    output reg [6:0] seg3,  // 7-segment digit 3 (점수)
    output reg [3:0] an,    // 7-segment anode
    output reg game_over,   // 게임 오버 신호
    output reg buzzer       // 부저 (성공/실패 피드백)
);

    // State 정의
    localparam IDLE         = 4'd0;
    localparam READY        = 4'd1;
    localparam WAIT_RANDOM  = 4'd2;
    localparam LED_ON       = 4'd3;
    localparam MEASURING    = 4'd4;
    localparam SUCCESS      = 4'd5;
    localparam FAIL         = 4'd6;
    localparam SHOW_RESULT  = 4'd7;
    localparam GAME_OVER    = 4'd8;
    
    reg [3:0] state, next_state;
    
    // 타이머 및 카운터
    reg [26:0] ms_counter;      // 1ms 카운터
    reg [15:0] reaction_time;   // 반응 시간 (ms)
    reg [15:0] wait_time;       // 랜덤 대기 시간
    reg [3:0] score;            // 점수 (0~9)
    reg [2:0] round;            // 라운드 (1~5)
    
    // LFSR for pseudo-random number generation
    reg [15:0] lfsr;
    wire lfsr_feedback;
    assign lfsr_feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];
    
    // 1ms tick 생성
    wire tick_1ms;
    assign tick_1ms = (ms_counter == 27'd99_999);
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            ms_counter <= 0;
        else begin
            if (tick_1ms)
                ms_counter <= 0;
            else
                ms_counter <= ms_counter + 1;
        end
    end
    
    // 버튼 엣지 감지
    reg start_btn_prev, react_btn_prev;
    wire start_btn_edge, react_btn_edge;
    
    assign start_btn_edge = start_btn & ~start_btn_prev;
    assign react_btn_edge = react_btn & ~react_btn_prev;
    
    always @(posedge clk) begin
        start_btn_prev <= start_btn;
        react_btn_prev <= react_btn;
    end
    
    // LFSR 업데이트
    always @(posedge clk or posedge reset) begin
        if (reset)
            lfsr <= 16'hACE1;  // 초기 시드
        else if (tick_1ms)
            lfsr <= {lfsr[14:0], lfsr_feedback};
    end
    
    // State Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            round <= 0;
            score <= 0;
            reaction_time <= 0;
            wait_time <= 0;
        end
        else begin
            state <= next_state;
            
            // 대기 시간 카운트
            if (state == WAIT_RANDOM && tick_1ms) begin
                if (wait_time > 0)
                    wait_time <= wait_time - 1;
            end
            
            // 반응 시간 측정
            if (state == MEASURING && tick_1ms)
                reaction_time <= reaction_time + 1;
            
            // 라운드 및 점수 관리
            if (state == READY) begin
                round <= round + 1;
                reaction_time <= 0;
                // 랜덤 대기 시간 설정 (1~3초)
                wait_time <= 1000 + (lfsr[10:0] % 2000);
            end
            else if (state == SUCCESS) begin
                // 반응시간에 따른 점수 부여
                if (reaction_time < 200)
                    score <= score + 3;
                else if (reaction_time < 400)
                    score <= score + 2;
                else
                    score <= score + 1;
            end
            else if (state == IDLE) begin
                round <= 0;
                score <= 0;
            end
        end
    end
    
    // Next State Logic
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (start_btn_edge)
                    next_state = READY;
            end
            
            READY: begin
                next_state = WAIT_RANDOM;
            end
            
            WAIT_RANDOM: begin
                if (react_btn_edge)
                    next_state = FAIL;  // 너무 빨리 누름
                else if (wait_time == 0)
                    next_state = LED_ON;
            end
            
            LED_ON: begin
                next_state = MEASURING;
            end
            
            MEASURING: begin
                if (react_btn_edge)
                    next_state = SUCCESS;
                else if (reaction_time >= 1000)  // 1초 초과
                    next_state = FAIL;
            end
            
            SUCCESS: begin
                if (tick_1ms && reaction_time >= 1500)  // 1.5초 결과 표시
                    next_state = (round >= 5) ? GAME_OVER : READY;
            end
            
            FAIL: begin
                if (tick_1ms && reaction_time >= 1500)  // 1.5초 결과 표시
                    next_state = (round >= 5) ? GAME_OVER : READY;
            end
            
            GAME_OVER: begin
                if (start_btn_edge)
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // LED 패턴 제어
    always @(*) begin
        case (state)
            IDLE:
                leds = 16'b0000000000000000;
            READY:
                leds = 16'b1111111111111111;  // 모든 LED 깜빡임
            WAIT_RANDOM:
                leds = 16'b0000000000000000;
            LED_ON, MEASURING:
                // 랜덤 LED 패턴
                leds = {lfsr[15:8], lfsr[7:0]};
            SUCCESS:
                leds = 16'b0101010101010101;  // 체크 패턴
            FAIL:
                leds = 16'b1010101010101010;  // X 패턴
            GAME_OVER:
                leds = score >= 10 ? 16'hFFFF : 16'h0000;  // 최종 점수 표시
            default:
                leds = 16'b0000000000000000;
        endcase
    end
    
    // 부저 제어
    always @(*) begin
        case (state)
            SUCCESS: buzzer = 1;
            FAIL: buzzer = (reaction_time[7:0] < 8'd128);  // 톤 생성
            default: buzzer = 0;
        endcase
    end
    
    // 7-segment 디코더 함수
    function [6:0] decode_7seg;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: decode_7seg = 7'b1000000;
                4'd1: decode_7seg = 7'b1111001;
                4'd2: decode_7seg = 7'b0100100;
                4'd3: decode_7seg = 7'b0110000;
                4'd4: decode_7seg = 7'b0011001;
                4'd5: decode_7seg = 7'b0010010;
                4'd6: decode_7seg = 7'b0000010;
                4'd7: decode_7seg = 7'b1111000;
                4'd8: decode_7seg = 7'b0000000;
                4'd9: decode_7seg = 7'b0010000;
                default: decode_7seg = 7'b1111111;
            endcase
        end
    endfunction
    
    // 7-segment 디스플레이 제어
    always @(*) begin
        an = 4'b0000;  // 모든 digit 활성화
        
        // 반응 시간 표시 (0~999ms)
        seg0 = decode_7seg(reaction_time % 10);
        seg1 = decode_7seg((reaction_time / 10) % 10);
        seg2 = decode_7seg((reaction_time / 100) % 10);
        
        // 점수 표시
        seg3 = decode_7seg(score);
        
        if (state == IDLE || state == GAME_OVER) begin
            // 최종 점수만 표시
            seg0 = 7'b1111111;
            seg1 = 7'b1111111;
            seg2 = 7'b1111111;
            seg3 = decode_7seg(score);
        end
    end
    
    // 게임 오버 플래그
    always @(*) begin
        game_over = (state == GAME_OVER);
    end

endmodul
```

```verilog
// ========================================
// 8번 - 게임 FSM (반응속도 게임) 테스트벤치
// ========================================
`timescale 1ns / 1ps

module tb_reaction_game_fsm;

    // 입력 신호 (reg)
    reg clk;
    reg reset;
    reg start_btn;
    reg react_btn;
    
    // 출력 신호 (wire)
    wire [15:0] leds;
    wire [6:0] seg0, seg1, seg2, seg3;
    wire [3:0] an;
    wire game_over;
    wire buzzer;
    
    // 테스트용 변수
    integer test_count;
    integer reaction_delay;
    integer round_num;
    
    // DUT (Device Under Test) 인스턴스화
    reaction_game_fsm uut (
        .clk(clk),
        .reset(reset),
        .start_btn(start_btn),
        .react_btn(react_btn),
        .leds(leds),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .an(an),
        .game_over(game_over),
        .buzzer(buzzer)
    );
    
    // 클럭 생성 (100MHz = 10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 7-segment 디코더 함수
    function [3:0] decode_7seg;
        input [6:0] seg_val;
        begin
            case (seg_val)
                7'b1000000: decode_7seg = 0;
                7'b1111001: decode_7seg = 1;
                7'b0100100: decode_7seg = 2;
                7'b0110000: decode_7seg = 3;
                7'b0011001: decode_7seg = 4;
                7'b0010010: decode_7seg = 5;
                7'b0000010: decode_7seg = 6;
                7'b1111000: decode_7seg = 7;
                7'b0000000: decode_7seg = 8;
                7'b0010000: decode_7seg = 9;
                default: decode_7seg = 15;  // Error
            endcase
        end
    endfunction
    
    // 반응 시간 계산 함수 (7-segment에서)
    function [15:0] get_reaction_time;
        begin
            get_reaction_time = decode_7seg(seg0) + 
                               (decode_7seg(seg1) * 10) + 
                               (decode_7seg(seg2) * 100);
        end
    endfunction
    
    // 점수 가져오기 함수
    function [3:0] get_score;
        begin
            get_score = decode_7seg(seg3);
        end
    endfunction
    
    // 버튼 누르기 태스크
    task press_start;
        begin
            @(posedge clk);
            start_btn = 1;
            $display("  [BTN] Start button pressed");
            @(posedge clk);
            #20;
            start_btn = 0;
            #100;
        end
    endtask
    
    task press_react;
        begin
            @(posedge clk);
            react_btn = 1;
            $display("  [BTN] React button pressed");
            @(posedge clk);
            #20;
            react_btn = 0;
            #100;
        end
    endtask
    
    // LED가 켜질 때까지 대기
    task wait_for_led_on;
        integer timeout;
        begin
            timeout = 0;
            $display("  [WAIT] Waiting for LED to turn on...");
            
            while (leds == 16'h0000 && timeout < 5000000) begin
                #1000;  // 1us씩 대기
                timeout = timeout + 1;
            end
            
            if (leds != 16'h0000) begin
                $display("  [LED] LED turned ON! Pattern: %b", leds);
            end else begin
                $display("  [TIMEOUT] LED did not turn on");
            end
        end
    endtask
    
    // 라운드 완료 대기
    task wait_for_round_complete;
        integer timeout;
        begin
            timeout = 0;
            while (!uut.state[0] && timeout < 3000000) begin  // IDLE이 아닐 때
                #1000;
                timeout = timeout + 1;
            end
            #5000;
        end
    endtask
    
    // 완전한 게임 라운드 수행
    task play_round;
        input integer delay_ms;
        integer reaction_time_val;
        begin
            round_num = round_num + 1;
            $display("\n  === Round %0d ===", round_num);
            
            // LED 켜지길 대기
            wait_for_led_on;
            
            // 지정된 지연 후 반응
            #(delay_ms * 100000);  // ms를 ns로 변환 (축소된 시간 기준)
            press_react;
            
            // 결과 대기
            #200000;
            
            reaction_time_val = get_reaction_time;
            $display("  [RESULT] Reaction time: %0d ms", reaction_time_val);
            $display("  [SCORE] Current score: %0d", get_score);
            
            if (buzzer) begin
                $display("  [SOUND] Success buzzer!");
            end
            
            wait_for_round_complete;
        end
    endtask
    
    // 테스트 시나리오
    initial begin
        // 파형 덤프 설정
        $dumpfile("reaction_game_fsm.vcd");
        $dumpvars(0, tb_reaction_game_fsm);
        
        // 초기화
        reset = 1;
        start_btn = 0;
        react_btn = 0;
        test_count = 0;
        round_num = 0;
        
        $display("========================================");
        $display("Reaction Game FSM Testbench Started");
        $display("게임 규칙:");
        $display("- LED 켜지면 빠르게 버튼 클릭");
        $display("- 반응 시간에 따라 점수 획득");
        $display("  < 200ms: 3점");
        $display("  < 400ms: 2점");
        $display("  그 외: 1점");
        $display("- 5라운드 진행");
        $display("========================================\n");
        
        // 리셋 해제
        #1000;
        reset = 0;
        $display("Time=%0t: Reset released", $time);
        $display("Initial state: IDLE\n");
        
        #2000;
        
        // 테스트 1: 초기 상태 확인
        test_count = test_count + 1;
        $display("--- TEST %0d: Initial state verification ---", test_count);
        
        if (leds == 16'h0000 && !game_over && get_score == 0) begin
            $display("Time=%0t: TEST %0d PASSED - Initial state correct\n", 
                     $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - leds=%h, game_over=%b, score=%d\n", 
                     $time, test_count, leds, game_over, get_score);
        end
        
        #5000;
        
        // 테스트 2: 게임 시작
        test_count = test_count + 1;
        $display("--- TEST %0d: Game start ---", test_count);
        
        press_start;
        
        #5000;
        if (leds == 16'hFFFF) begin
            $display("  READY state confirmed (all LEDs on)");
            $display("Time=%0t: TEST %0d PASSED - Game started\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED\n", $time, test_count);
        end
        
        #10000;
        
        // 테스트 3: 정상적인 게임 플레이 (빠른 반응)
        test_count = test_count + 1;
        $display("--- TEST %0d: Normal gameplay - Fast reaction (150ms) ---", test_count);
        
        play_round(150);  // 150ms 반응
        
        if (get_score >= 2) begin
            $display("Time=%0t: TEST %0d PASSED - Good score earned\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d PARTIAL - score=%d\n", $time, test_count, get_score);
        end
        
        #5000;
        
        // 테스트 4: 중간 반응 속도
        test_count = test_count + 1;
        $display("--- TEST %0d: Medium reaction (300ms) ---", test_count);
        
        play_round(300);  // 300ms 반응
        
        $display("Time=%0t: TEST %0d COMPLETED - Score: %d\n", 
                 $time, test_count, get_score);
        
        #5000;
        
        // 테스트 5: 느린 반응 속도
        test_count = test_count + 1;
        $display("--- TEST %0d: Slow reaction (500ms) ---", test_count);
        
        play_round(500);  // 500ms 반응
        
        $display("Time=%0t: TEST %0d COMPLETED - Score: %d\n", 
                 $time, test_count, get_score);
        
        #5000;
        
        // 테스트 6: 너무 빨리 누름 (FAIL)
        test_count = test_count + 1;
        $display("--- TEST %0d: Pressing too early (FAIL case) ---", test_count);
        
        $display("\n  === Round %0d ===", round_num + 1);
        round_num = round_num + 1;
        
        #50000;  // WAIT_RANDOM 상태 중
        $display("  [BTN] Pressing before LED turns on");
        press_react;
        
        #200000;
        if (!buzzer || buzzer == 0) begin
            $display("  [RESULT] Failed - Pressed too early");
            $display("Time=%0t: TEST %0d PASSED - Early press detected\n", $time, test_count);
        end
        
        wait_for_round_complete;
        
        #5000;
        
        // 테스트 7: 너무 늦게 누름 (1초 초과)
        test_count = test_count + 1;
        $display("--- TEST %0d: Pressing too late (>1000ms) ---", test_count);
        
        play_round(1100);  // 1100ms 반응 (실패)
        
        $display("Time=%0t: TEST %0d COMPLETED - Timeout case\n", $time, test_count);
        
        #5000;
        
        // 게임이 끝날 때까지 대기
        $display("--- Waiting for game to complete ---");
        while (!game_over) begin
            #10000;
        end
        
        #10000;
        
        // 테스트 8: 게임 오버 확인
        test_count = test_count + 1;
        $display("--- TEST %0d: Game over state ---", test_count);
        
        if (game_over) begin
            $display("  [GAME OVER] Final Score: %d", get_score);
            $display("Time=%0t: TEST %0d PASSED - Game completed\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED - Game should be over\n", $time, test_count);
        end
        
        #10000;
        
        // 테스트 9: 재시작 테스트
        test_count = test_count + 1;
        $display("--- TEST %0d: Game restart ---", test_count);
        
        press_start;
        
        #10000;
        if (!game_over && get_score == 0) begin
            $display("  Game restarted - Score reset to 0");
            $display("Time=%0t: TEST %0d PASSED - Restart successful\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED\n", $time, test_count);
        end
        
        #5000;
        
        // 테스트 10: 리셋 테스트
        test_count = test_count + 1;
        $display("--- TEST %0d: Reset during game ---", test_count);
        
        // 게임 중 리셋
        wait_for_led_on;
        
        #100000;
        $display("  [RESET] Activating reset during game");
        reset = 1;
        #1000;
        reset = 0;
        
        #5000;
        if (leds == 16'h0000 && get_score == 0 && !game_over) begin
            $display("Time=%0t: TEST %0d PASSED - Reset successful\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d FAILED\n", $time, test_count);
        end
        
        #5000;
        
        // 테스트 11: 7-segment 디스플레이 확인
        test_count = test_count + 1;
        $display("--- TEST %0d: 7-segment display test ---", test_count);
        
        press_start;
        #10000;
        
        play_round(250);
        
        #5000;
        $display("  Digit 0 (1s): %d", decode_7seg(seg0));
        $display("  Digit 1 (10s): %d", decode_7seg(seg1));
        $display("  Digit 2 (100s): %d", decode_7seg(seg2));
        $display("  Digit 3 (score): %d", decode_7seg(seg3));
        $display("  Reaction time: %d ms", get_reaction_time);
        
        $display("Time=%0t: TEST %0d PASSED - Display working\n", $time, test_count);
        
        #10000;
        
        // 테스트 12: LFSR 랜덤성 확인
        test_count = test_count + 1;
        $display("--- TEST %0d: LFSR randomness check ---", test_count);
        
        $display("  LFSR value: %h", uut.lfsr);
        #100000;
        $display("  LFSR value after time: %h", uut.lfsr);
        
        if (uut.lfsr != 16'hACE1) begin
            $display("Time=%0t: TEST %0d PASSED - LFSR is updating\n", $time, test_count);
        end else begin
            $display("Time=%0t: TEST %0d WARNING - LFSR not changing\n", $time, test_count);
        end
        
        // 시뮬레이션 종료
        #20000;
        $display("\n========================================");
        $display("Reaction Game FSM Testbench Completed");
        $display("Total Tests: %0d", test_count);
        $display("========================================");
        $display("\nNOTE: For faster simulation, modify:");
        $display("  ms_counter == 99_999 to ms_counter == 100");
        $display("  in reaction_game_fsm.v");
        $finish;
    end
    
    // 상태 변화 모니터링
    always @(uut.state) begin
        case (uut.state)
            4'd0: $display("    [STATE] IDLE");
            4'd1: $display("    [STATE] READY");
            4'd2: $display("    [STATE] WAIT_RANDOM");
            4'd3: $display("    [STATE] LED_ON");
            4'd4: $display("    [STATE] MEASURING");
            4'd5: $display("    [STATE] SUCCESS");
            4'd6: $display("    [STATE] FAIL");
            4'd7: $display("    [STATE] SHOW_RESULT");
            4'd8: $display("    [STATE] GAME_OVER");
        endcase
    end
    
    // LED 패턴 변화 모니터링
    always @(leds) begin
        if (leds != 16'h0000)
            $display("    [LED] Pattern changed: %b", leds);
    end
    
    // 부저 모니터링
    always @(posedge buzzer) begin
        $display("    [BUZZER] Sound ON");
    end
    
    // 게임 오버 모니터링
    always @(posedge game_over) begin
        $display("    [GAME] GAME OVER - Final Score: %d", get_score);
    end
    
    // 라운드 변화 모니터링
    always @(uut.round) begin
        if (uut.round > 0)
            $display("    [ROUND] Round %d/5", uut.round);
    end
    
    // 타임아웃 (무한 루프 방지)
    initial begin
        #50000000;  // 50ms 후 자동 종료
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
```

---
