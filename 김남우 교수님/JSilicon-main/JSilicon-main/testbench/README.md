# Jsilicon 테스트벤치 사용 가이드

## 개요
이 디렉토리에는 Jsilicon 디자인의 모든 모듈에 대한 테스트벤치가 포함되어 있습니다.
모든 테스트벤치는 Xcelsium (Cadence) 시뮬레이터용으로 작성되었습니다.

## 파일 구조

```
.
├── design_summary.md          # 디자인 하이어러키 및 기능 정리
├── Makefile                   # 시뮬레이션 실행 스크립트
├── tb_alu.v                   # ALU 테스트벤치
├── tb_uart.v                  # UART 테스트벤치
├── tb_pc.v                    # PC 테스트벤치
├── tb_decoder.v               # DECODER 테스트벤치
├── tb_reg.v                   # REG 테스트벤치
├── tb_switch.v                # SWITCH 테스트벤치
├── tb_fsm.v                   # FSM 테스트벤치
└── tb_jsilicon_top.v          # TOP 모듈 테스트벤치
```

## Xcelsium에서 시뮬레이션 실행 방법

### 방법 1: Makefile 사용 (권장)

```bash
# 개별 모듈 테스트
make alu       # ALU 테스트
make uart      # UART 테스트
make pc        # PC 테스트
make decoder   # DECODER 테스트
make reg       # REG 테스트
make switch    # SWITCH 테스트
make fsm       # FSM 테스트
make top       # TOP 모듈 (전체 시스템) 테스트

# 모든 테스트 실행
make all_tests

# 시뮬레이션 파일 정리
make clean
```

### 방법 2: 직접 xrun 명령 실행

```bash
# ALU 테스트
xrun +v2k -access +rwc ../alu.v ../tb_alu.v

# UART 테스트
xrun +v2k -access +rwc ../uart.v ../tb_uart.v

# PC 테스트
xrun +v2k -access +rwc ../pc.v ../tb_pc.v

# DECODER 테스트
xrun +v2k -access +rwc ../inst.v ../tb_decoder.v

# REG 테스트
xrun +v2k -access +rwc ../regfile.v ../tb_reg.v

# SWITCH 테스트
xrun +v2k -access +rwc ../switch.v ../tb_switch.v

# FSM 테스트 (여러 소스 파일 필요)
xrun +v2k -access +rwc ../alu.v \
     ../uart.v ../fsm.v ../tb_fsm.v

# TOP 모듈 테스트 (전체 시스템)
xrun +v2k -access +rwc ../alu.v \
     ../uart.v ../pc.v \
     ../inst.v ../regfile.v \
     ../switch.v ../fsm.v \
     ../jsilicon.v ../tb_jsilicon_top.v
```

### 방법 3: GUI 모드로 실행

```bash
# GUI 모드로 파형 확인
xrun +v2k -access +rwc -gui ../alu.v ../tb_alu.v
xrun -gui -access +rwc ../alu.v  -log alu_sim_gui.log
xrun -gui -access +rwc ../alu.v ../tb_alu.v -top tb_alu -log alu_sim.log

# 또는 VCD 파일 생성 후 파형 뷰어로 확인
# 시뮬레이션 실행 후 생성되는 *.vcd 파일을 SimVision으로 열기
simvision alu_wave.vcd
```

## 각 테스트벤치 설명

### 1. tb_alu.v - ALU 테스트벤치
**테스트 내용:**
- 8가지 ALU 연산 (ADD, SUB, MUL, DIV, MOD, EQ, GT, LT)
- 0으로 나누기 보호 기능 검증
- Enable 신호 제어 검증

**예상 결과:**
- 15 + 10 = 25
- 12 * 5 = 60
- 100 / 7 = 14
- 100 % 7 = 2
- 25 == 25 = 1 (true)

### 2. tb_uart.v - UART 테스트벤치
**테스트 내용:**
- 9600bps UART 송신 테스트
- 다양한 데이터 패턴 전송 (0x55, 0xAA, 0xFF, 0x00, 0x41)
- busy 플래그 동작 검증
- START-DATA-STOP 비트 시퀀스 확인

**예상 결과:**
- 각 바이트 전송에 약 1.04ms 소요 (9600bps 기준)
- TX 라인에서 올바른 비트 시퀀스 관찰 가능

### 3. tb_pc.v - PC (Program Counter) 테스트벤치
**테스트 내용:**
- 프로그램 카운터 증가 동작 (0→1→2→3→0)
- ROM 명령어 페치 검증
- Enable 제어 검증
- Reset 동작 검증

**예상 결과:**
- PC=0: ADD 3 (8'b00000011)
- PC=1: SUB 2 (8'b00100010)
- PC=2: MUL 5 (8'b01000101)
- PC=3: NOP   (8'b00000000)

### 4. tb_decoder.v - DECODER 테스트벤치
**테스트 내용:**
- 명령어 디코딩 기능 검증
- alu_enable, write_enable 신호 생성 확인
- 레지스터 선택 신호 (reg_sel) 검증
- NOP 명령어 처리 확인

**예상 결과:**
- ADD/SUB/MUL: alu_enable=1, write_enable=1
- CMP: alu_enable=1, write_enable=0
- NOP: alu_enable=0, write_enable=0

### 5. tb_reg.v - REG (Register File) 테스트벤치
**테스트 내용:**
- R0, R1 레지스터 읽기/쓰기
- LOAD 명령어 검증
- MOV 명령어 검증 (R0↔R1 데이터 이동)
- Write-back 시뮬레이션

**예상 결과:**
- LOAD R0, 25: R0=25
- LOAD R1, 50: R1=50
- MOV R1←R0: R1=R0의 값

### 6. tb_switch.v - SWITCH 테스트벤치
**테스트 내용:**
- Manual 모드 (mode=0) 입력 선택 검증
- CPU 모드 (mode=1) 입력 선택 검증
- 모드 전환 동작 확인
- Edge case 테스트 (0, 최대값)

**예상 결과:**
- mode=0: manual 입력이 출력으로 전달
- mode=1: cpu 입력이 출력으로 전달

### 7. tb_fsm.v - FSM 테스트벤치
**테스트 내용:**
- FSM 상태 천이 검증 (INIT→SEND→WAIT)
- ALU와 UART 통합 동작 확인
- 여러 연산 순차 실행
- Enable 제어 검증

**예상 결과:**
- 각 연산 후 UART로 결과 전송
- UART busy 신호 올바른 타이밍
- 연속 연산 처리 가능

### 8. tb_jsilicon_top.v - TOP 모듈 테스트벤치
**테스트 내용:**
- **Manual 모드**: 외부 입력으로 직접 제어
- **CPU 모드**: ROM 프로그램 자동 실행
- 모드 전환 테스트
- Enable/Reset 제어
- 전체 시스템 통합 검증

**예상 결과:**
- Manual 모드에서 즉각적인 연산 실행
- CPU 모드에서 ROM 프로그램 순차 실행
- R0, R1 레지스터 값 변화 관찰
- UART로 연산 결과 전송

## 시뮬레이션 파라미터

### 클럭 설정
- **시스템 클럭**: 12 MHz (CLK_PERIOD = 83.33ns)
- **UART 보레이트**: 9600 bps
- **UART CLOCK_DIV**: 1250

### 타이밍
- 1 UART 바이트 전송: 약 1.04ms
- PC 주기: 4 클럭 사이클
- FSM 한 사이클: UART 전송 시간 포함하여 약 1ms

## VCD 파일 생성

모든 테스트벤치는 자동으로 VCD 파일을 생성합니다:
- `alu_wave.vcd`
- `uart_wave.vcd`
- `pc_wave.vcd`
- `decoder_wave.vcd`
- `reg_wave.vcd`
- `switch_wave.vcd`
- `fsm_wave.vcd`
- `jsilicon_top_wave.vcd`

파형 뷰어로 확인:
```bash
simvision *.vcd
```

## 디버깅 팁

### 1. 모니터 출력 활용
각 테스트벤치는 `$display`와 `$monitor`를 사용하여 상세한 로그를 출력합니다.

### 2. 파형 분석
VCD 파일을 열어서 신호 파형을 직접 확인하세요.

### 3. 상태 추적
FSM과 UART 모듈의 내부 상태(state)를 모니터링하여 상태 천이를 확인하세요.

### 4. 타이밍 확인
UART 전송의 경우 CLOCK_DIV 설정에 따른 정확한 타이밍을 확인하세요.

## 문제 해결

### 시뮬레이션이 시작되지 않을 때
1. 소스 파일 경로 확인 (`/mnt/user-data/uploads/`)
2. xrun 라이센스 확인
3. Verilog-1995 문법 호환성 확인

### 파형이 표시되지 않을 때
1. VCD 파일 생성 확인
2. `$dumpfile`과 `$dumpvars` 명령 확인
3. 시뮬레이션 시간이 충분한지 확인

### UART 타이밍 이슈
1. CLOCK_DIV 값 확인 (1250 for 9600bps @ 12MHz)
2. 시뮬레이션 시간 증가 (`#(CLK_PERIOD*...)`)

## 추가 정보

더 자세한 디자인 정보는 `design_summary.md` 파일을 참고하세요.

## 연락처

질문이나 문제가 있으면 디자인 문서를 참고하거나 시뮬레이션 로그를 확인하세요.
