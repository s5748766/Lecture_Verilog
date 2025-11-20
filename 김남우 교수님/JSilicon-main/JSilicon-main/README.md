# JSilicon

# Jsilicon 디자인 하이어러키 및 기능 정리

## 1. 전체 디자인 하이어러키

```
tt_um_Jsilicon (TOP)
├── PC (Program Counter + ROM)
│   └── ROM[0:15] - 내장 명령어 저장
│
├── DECODER (명령어 디코더)
│   └── 명령어 파싱 및 제어신호 생성
│
├── REG (Register File)
│   └── R0, R1 레지스터
│
├── SWITCH (모드 선택기)
│   └── Manual/CPU 모드 전환
│
└── FSM (연산 실행 제어)
    ├── ALU (산술논리연산장치)
    │   └── 8가지 연산 수행
    └── UART_TX (직렬 통신)
        └── 9600bps 송신
```

## 2. 주요 모듈별 기능 설명

### 2.1 tt_um_Jsilicon (TOP 모듈)
**기능**: 전체 시스템 통합 및 모드 제어
- **동작 모드**:
  - Manual Mode (mode=0): 외부 입력으로 직접 ALU 제어
  - CPU Mode (mode=1): 내장 ROM 프로그램 자동 실행
- **신호 흐름**:
  - Manual: ui_in → SWITCH → FSM → ALU/UART
  - CPU: PC → DECODER → REG → SWITCH → FSM → ALU/UART
- **입출력**:
  - ui_in[7:4]: manual_a, ui_in[3:0]: manual_b
  - uio_in[7:5]: manual_opcode, uio_in[4]: mode
  - uo_out[7]: uart_busy, uo_out[6:0]: result[6:0]
  - uio_out[7:1]: result[15:9], uio_out[0]: uart_tx

### 2.2 PC (Program Counter + ROM)
**기능**: 명령어 메모리 및 순차 실행 제어
- 4비트 PC (0~15 주소)
- 내장 ROM 프로그램:
  - rom[0]: ADD 3 (8'b00000011)
  - rom[1]: SUB 2 (8'b00100010)
  - rom[2]: MUL 5 (8'b01000101)
  - rom[3]: NOP   (8'b00000000)
- PC는 0→1→2→3→0으로 순환

### 2.3 DECODER (명령어 디코더)
**기능**: 8비트 명령어를 제어신호로 변환
- **명령어 포맷**: [7:5]=opcode, [4]=reg_sel, [3:0]=operand
- **생성 제어신호**:
  - alu_opcode[2:0]: ALU 연산 종류
  - operand[3:0]: 즉시값
  - reg_sel: 레지스터 선택 (0=R0, 1=R1)
  - alu_enable: ALU 실행 허가
  - write_enable: 레지스터 쓰기 허가

### 2.4 REG (Register File)
**기능**: 2개의 8비트 레지스터 관리
- **레지스터**: R0, R1 (각 8비트)
- **opcode 동작**:
  - 000: R0 ← data_in
  - 001: R1 ← data_in
  - 010: R1 ← R0 (MOV)
  - 011: R0 ← R1 (MOV)
  - 111: NOP (기본값)

### 2.5 SWITCH (모드 선택기)
**기능**: Manual/CPU 모드에 따라 ALU 입력 선택
- mode=0: manual_a, manual_b, manual_opcode 선택
- mode=1: cpu_a(R0), cpu_b(R1), cpu_opcode 선택

### 2.6 FSM (실행 제어 상태머신)
**기능**: ALU 실행 및 UART 송신 제어
- **상태**: INIT → SEND → WAIT → INIT (순환)
- **동작**:
  - INIT: UART 송신 시작 신호 생성
  - SEND: UART가 busy 될 때까지 대기
  - WAIT: UART 송신 완료 대기
- ALU와 UART를 하위 모듈로 관리

### 2.7 ALU (산술논리연산장치)
**기능**: 8비트 연산 수행 (결과는 16비트)
- **연산 종류** (opcode):
  - 000: a + b (덧셈)
  - 001: a - b (뺄셈)
  - 010: a * b (곱셈)
  - 011: a / b (나눗셈, 0나눔 방지)
  - 100: a % b (나머지)
  - 101: a == b (같음 비교)
  - 110: a > b (크기 비교)
  - 111: a < b (크기 비교)

### 2.8 UART_TX (직렬 통신 송신)
**기능**: 8비트 데이터를 직렬로 송신
- **통신 규격**: 9600bps, 8N1 (8bit, No parity, 1 stop bit)
- **상태**: IDLE → START → DATA → STOP → IDLE
- **동작**:
  - START bit: tx=0
  - 8 DATA bits: LSB first
  - STOP bit: tx=1
- CLOCK_DIV = 1250 (12MHz / 9600bps)

## 3. 전체 데이터 흐름

### Manual Mode (mode=0)
```
사용자 입력 (ui_in, uio_in)
  ↓
SWITCH (수동 데이터 선택)
  ↓
FSM (실행 제어)
  ↓
ALU (연산 수행) + UART (결과 송신)
  ↓
출력 (uo_out, uio_out)
```

### CPU Mode (mode=1)
```
PC (명령어 페치)
  ↓
DECODER (명령어 디코드)
  ↓
REG (레지스터 읽기/쓰기)
  ↓
SWITCH (CPU 데이터 선택)
  ↓
FSM (실행 제어)
  ↓
ALU (연산 수행) + UART (결과 송신)
  ↓
REG (결과 저장 - Write Back)
  ↓
출력 (uo_out, uio_out)
```

## 4. 주요 특징

1. **듀얼 모드 동작**: 수동 제어와 자동 프로그램 실행 모드 지원
2. **간단한 CPU 구조**: PC → Decoder → Register → Execute → WriteBack
3. **비동기 리셋**: 모든 모듈은 active-high reset 사용
4. **Enable 제어**: ena 신호로 전체 동작 제어 가능
5. **UART 통신**: 연산 결과를 외부로 직렬 전송
6. **Zero Division 보호**: 0으로 나누기 시 0 반환
7. **16비트 결과**: 곱셈 결과를 위한 확장 출력

## 5. 클럭 및 타이밍

- **시스템 클럭**: 12 MHz (TinyTapeout 기본 클럭)
- **UART 보레이트**: 9600 bps
- **PC 주기**: 4 사이클 (0→3)
- **FSM 주기**: INIT→SEND→WAIT (약 1ms per cycle @ 9600bps)
