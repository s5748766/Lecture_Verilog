# 🔍 현재 설계의 모든 잠재적 문제점 리스트업

* jsilicon.v + fsm.v + alu + pc + decoder + regfile + switch + uart 전체 구조를 분석
* CPU 모드 불능, 결과가 항상 0, UART 타이밍 불량 등의 이유를 전부 포함합니다.

## 🧩 A. CPU 모드에서 값이 0에서 벗어나지 않는 구조적 문제
### A-1. 명령어의 즉시값(immediate)이 ALU에 전달되지 않음
   * DECODER는 operand(4bit)를 뽑아냄
   * 그러나 ALU는 항상 R0, R1만 사용
   * CPU 모드에서 operand가 calculation path에 들어오지 않음
   * ➡ ROM의 ADD 3, SUB 2, MUL 5 등이 실제 ALU에는 적용되지 않음

### A-2. R0/R1 초기값이 0이기 때문에 모든 연산 결과가 영구히 0
   * R0 = 0, R1 = 0으로 시작
   * operand를 쓰지 않으므로 ADD 3 → 0 + 0
   * 연속적으로 모든 명령이 0을 다시 R0에 저장
   * ➡ CPU 모드에서 영원히 0만 돌고 있음

## 🧩 B. Manual 모드와 CPU 모드가 Enable(ena) 한 신호에 묶여 있는 구조적 문제
### B-1. manual 연산과 CPU 파이프라인이 동시에 움직임
   * PC, DECODER, REG, FSM이 전부 같은 ena를 사용
   * mode=0이어도 PC/DECODER/REG가 움직여 버림
   * mode=1이어도 FSM/UART가 manual 입력을 동시에 받아버릴 수 있음
   * ➡ 모드가 분리되지 않아 신호 경로가 서로 간섭함

### B-2. SWITCH 모듈은 선택만 하지만 "enable 분리"가 없이 그냥 모두 active
   * select_a, select_b, select_opcode는 mode로 선택하지만,
   * PC/DECODER/ALU는 여전히 ena에 반응
   * ➡ 모드 전환 시 자동/수동 파이프라인이 완전히 분리되지 않음

## 🧩 C. FSM 및 UART 전송 타이밍 관련 문제
### C-1. FSM이 “ena level=1” 동안 계속 UART 송신을 반복하려는 구조
   * FSM 내부:
```perl
if (ena) state <= INIT → SEND → WAIT → INIT...
```
   * 새 연산인지 과거 연산인지 구분 없음
   * ena가 1이면 계속 반복적으로 전송 state 재진입 가능
   * ➡ 동일한 결과를 연속해서 쏘거나, 타이밍이 꼬여 다른 결과가 전송됨

### C-2. ALU 계산 완료와 UART 시작이 동기화되어 있지 않음
   * ALU는 alu_ena의 rising edge에서 계산됨
   * FSM은 그냥 ena만 보며 UART start를 킴
   * ➡ 아직 계산되지 않은 값(이전 값)을 UART로 보내는 경우 발생

## 🧩 D. ALU enable(alu_ena) 생성 방식의 문제
### D-1. manual 모드일 때 ALU가 계속 계산하고 있음

```verilog
wire alu_ena = mode ? (ena & decoder_alu_enable) : ena;
```
   * manual mode에서 ALU는 ena=1이면 계속 계산
   * FSM도 ena level을 그대로 받아 계속 전송
   * ➡ manual 연속 연산 시 ALU/FSM이 함께 폭주

### D-2. CPU 모드에서도 decode가 연산 명령이 아닐 때 unnecessary alu_ena가 1이 될 수 있음
   * alu_ena는 decoder_alu_enable에 따라 달라지지만
   * ena 자체가 계속 high일 경우 특정 조건에서 ALU가 두 번 계산할 가능성 있음

## 🧩 E. PC / Decoder / REG 라인의 동작 타이밍 문제
### E-1. PC는 ena만 보면 증가 → manual 모드에서도 계속 증가
   * mode=0이어도 ena=1이면 계속 PC가 증가
   * ➡ 수동 모드에서도 CPU 파이프라인이 무의미하게 진행됨

### E-2. Decoder가 명령을 매 사이클마다 실행하려 함
   * ena만 보고 decode → reg write → alu_enable
   * ➡ operand 기반 계산이 무효라 CPU 전체가 의미 없이 0만 반복

### E-3. Regfile write가 immediate 명령에서도 발생하고 목적지가 구분되지 않음
   * decoder_write_enable만 보고 writeback
   * regfile_opcode도 reg_sel 기반인데 operand 사용 구조에 맞지 않음
   * ➡ 의도된 R0/R1 제어 구조가 실제로는 구현되지 않음

## 🧩 F. Switch 모듈 + Top 연결 관련 문제
### F-1. manual_a/manual_b가 4비트인데 select 경로는 8비트
   * top에서는 manual_a/b는 4bit
   * SWITCH에서는 8bit expected → zero-padding이 중첩되거나 잘못됨
   * ➡ manual 모드 ALU 입력 자체도 항상 상위 4비트=0

### F-2. opcode도 CPU/manual 간의 enable 타이밍이 맞지 않음
   * decoder는 계속 opcode를 내고 있고
   * switch는 mode 따라 값을 바꾸는데
   * ➡ mode 변화 순간에 ALU/REG/UART 타이밍 mismatch 가능

## 🧩 G. UART 출력 포맷 문제
### G-1. uart_busy, result 등이 uo_out에 직접 연결

```verilog
assign uo_out = { uart_busy, alu_result[6:0] };
```
   * UART busy는 비트 단위로 변하는 시그널
   * ALU result는 UART와 무관한 타이밍에 업데이트
   * ➡ 사용자가 LED로 보면 “버벅임 + 불완전한 표시”

### G-2. uio_out에 높은 비트가 나가는데 register 타이밍 없음

```verilog
assign uio_out = { alu_result[15:9], uart_tx };
```
   * mid/upper ALU result는 동기화 없이 바로 나감
   * ➡ mode 변환, ena pulse 등에 따라 출력 glitch 발생

## 🧩 H. Reset 처리 / 초기화 관련 문제
### H-1. 수동 모드와 CPU 모드가 reset 타이밍에서 서로 다른 초기 상태 요구
   * FSM은 reset 시 INIT로
   * PC도 reset 시 0으로
   * 하지만:
   * manual 모드는 reset 구조가 필요 없음
   * CPU 모드는 reset 이후부터 instruction pipeline이 시작되어야 함
   * ➡ 둘 사이의 reset 요구가 충돌

## 🧩 I. 구조적/관점적 문제 — 전체 아키텍처 레벨에서
### I-1. Manual/CPU 모드를 하나의 FSM/ALU/UART 구조에 억지로 공존시킴

   * manual은 즉시 연산
   * CPU는 명령어 기반 파이프라인
   * ➡ 동일 FSM/ALU/UART에 두 모드 신호를 억지로 섞어 문제가 반복 발생

### I-2. pipeline 단계 구분이 없음
   * PC 증가
   * 명령 fetch
   * decode
   * operand load
   * ALU execute
   * write-back
   * UART send
   * ➡ 이 모든 게 한 클럭에서 혼합됨

### I-3. FSM이 사실상 UART controller일 뿐인데 ALU timing controller 역할까지 하려함

   * UART start가 ALU 완료 타이밍과 전혀 관리되지 않음

# 📌 총정리 – 현재 구조의 핵심 문제 맵

| 분류	| 문제 | 
|:---:|:---:|
| CPU 연산 경로	| operand 미사용, R0/R1 구조 불일치, 계산값 0 고정| 
| enable 구조	| manual/CPU 간 enable 분리 없음, pipeline 동시 활성화| 
| FSM	| ena level-based, rising-edge detection 없음, 반복 전송| 
| UART	| ALU 완료와 동기화 없음, glitchy 출력| 
| Switch	| bit width 혼재, mode 전환 순간 glitch| 
| PC/Decoder	| ena 의존, manual 모드에서도 의미 없이 진행| 
| REG	| 목적지 위치/형태 불명확, immediate 구조와 불일치| 
| Reset	| dual-mode 초기화 요구 충돌| 
| 아키텍처	| pipeline 불분리, manual/CPU 억지 통합| 

# pipeline 단계 구분

1. 왜 “단계 구분”이 방향을 확 열어줄 수 있냐면
* 단계를 나누는 순간, 각 타이밍에 대해 다음 질문을 할 수 있게 됩니다:
* 이 사이클에서 PC는 무엇을 해야 하나?
* 이 사이클에서 ALU는 누구의 값을 가지고 있나?
* 이 사이클에서 REG는 write를 해야 하나, 말아야 하나?
* 이 사이클에서 UART는 “이제 보내도 되는 값”을 봐도 되나?
* 즉, “각 사이클에 하나의 역할만 시킨다”는 규칙을 만들 수 있고,
* 그 규칙이 생기면:
* Manual 모드에서는 어떤 단계만 사용하고,
* CPU 모드에서는 Fetch → Decode → Execute → WB → UART로 선형 흐름을 만들 수 있음
* 그러면 지금처럼:
* ena, mode, alu_ena, decoder_write_enable, uart_busy…가 한 사이클에 서로 끼어들면서,
* “어느 타이밍에 무엇이 진짜인가?”가 꼬이는 상황을 많이 줄일 수 있어요.

2. “가능한” 파이프라인 이미지(생각 실험용)
* 예를 들어, **“멀티사이클 CPU”**처럼만 생각해봐도:
* Cycle 0 – FETCH
  * PC 값으로 ROM에서 instr 읽어서 instr_reg에 저장
* Cycle 1 – DECODE
  * instr_reg에서 opcode, operand 뽑아서 opcode_reg, operand_reg에 저장
* Cycle 2 – EXECUTE
  * R0_reg, R1_reg, operand_reg 가지고 ALU 실행
  * 결과를 alu_result_reg에 저장
* Cycle 3 – WRITE-BACK
  * alu_result_reg를 R0에 쓰기
* Cycle 4 – UART SEND
  * alu_result_reg를 UART에 한 번 보내기 시작
  * 이렇게 “개념적인” 5단계만 잡아도:
  * 어느 단계에서 값이 ‘확정’되는지
  * UART는 어디 단계의 값을 써야 하는지
  * Manual 모드는 이 중 어느 subset만 쓰면 되는지
  * 이 전체 지도가 생기죠.
  * 지금 설계의 많은 문제(A, B, C, D, E, G…)가 사실 전부
  * “이 다섯 줄을 한 줄에 우겨 넣어버린 결과”
  * 라고 봐도 될 정도예요.
* 3. 이 관점에서 보면 “어디가 특히 명확해질까?”
  * 3-1. CPU 모드 값 생성 문제
    * 지금은 operand가 ALU에 어떻게 들어가야 하는지 애매함
    * 파이프라인을 생각하면 자연스럽게:
    * DECODE 단계: operand_reg에 저장
    * EXECUTE 단계: ALU(a=R0, b=operand_reg)
    * 이렇게 “경로 정의”가 쉬워짐 →
    * “R0+imm인지, R1+imm인지” 같은 설계 결정이 명확해짐
  * 3-2. UART와의 동기화 문제
    * 지금은 ALU와 UART가 같은 사이클 공간에서 뒤엉켜 있어서,
    * ALU 결과가 바뀌는 순간과
    * UART start가 올라가는 순간이 분리 안 됨
    * 파이프라인 관점에서는:
    * EXECUTE 단계에서 alu_result_reg 확정
    * WRITE-BACK에서 레지스터에 저장
    * UART SEND 단계에서 alu_result_reg를 TX에 싣기 시작
    * 이렇게 하면 자연스럽게:
    * **“반드시 계산 끝난 값만 UART로 나간다”**가 보장됨
  * 3-3. Manual / CPU 모드 공존 문제
    * 파이프라인이 없으니까 manual 모드는:
    * “그냥 ALU에 a,b,opcode 꽂고 ena 누르면 바로 결과”
    * CPU 모드는:
      * “ROM→DECODER→ALU→REG→UART를 한 번에 돌리려는 중”
      * 이게 섞여 있으니 mode 전환이 항상 위험해요.
      * 반대로 파이프라인이 있으면:
    * Manual 모드는:
      * EXECUTE 단계 + UART SEND 단계만 따로 “직접 트리거”
    * CPU 모드는:
      * FETCH → … → UART SEND 까지 자동
      * 처럼 모드마다 사용하는 단계 subset을 정리할 수 있음
    *  두 모드의 경계도 훨씬 명확해짐.
* 4. 결론적으로 “파이프라인 단계 구분”이 해줄 수 있는 것
  * 정리하면, I-2를 먼저 설계 차원에서 정리하면:
  * 타이밍 기준점이 생김
  * “이 값은 사이클 N에서 확정된다”를 말할 수 있음
  * 각 모듈의 책임 범위가 분리됨
  * PC는 FETCH, DECODER는 DECODE, ALU는 EXECUTE, REG는 WB, UART는 SEND
  * 문제를 디버깅할 좌표계가 생김
  * “지금 3단계까지는 정상인데 4단계에서 꼬였다” 같이 말할 수 있음
  * Manual / CPU, UART, ALU, REG의 엮임을 차례대로 풀 수 있음
  * 지금은 다 동시에 얽혀 있어서, 무엇부터 고쳐야 할지 감이 안 옴
  * 그래서 “가능성만” 이야기하자면:
  * 👉 네, I-2(파이프라인 단계 구분)를 먼저 개념적으로라도 정리하면,
  * 체 방향이 훨씬 명확해질 가능성이 크다
  * “지금 있는 코드 손보는 느낌”에서
  * “작은 멀티사이클 CPU를 하나 설계한다” 쪽으로 관점이 바뀌기 때문이에요.


## 🧠 1. 파이프라인이 없는 CPU(Non-Pipelined / Single-Cycle / Multi-Cycle)의 특징
### 🟦 1-1. Single-Cycle CPU
* 한 명령어를 1 클럭 안에서 Fetch → Decode → Execute → Write-Back까지 모두 처리함
* ALU, 메모리, 레지스터 파일 등 모든 하드웨어를 1 싸이클 안에 다 통과해야 함
### ✔ 장점
* 구조가 단순함
* 구현 난이도 낮음
* 디버깅 쉬움
## ✘ 단점
* 클럭 속도를 매우 낮게 잡아야 함
* 어떤 명령어든 가장 느린 명령어의 시간을 기준으로 클럭을 맞춰야 함
* UART 같은 주변장치와 동기화가 매우 어려움 (너무 짧은 시간에 모든 게 이루어져서)

### 🟦 1-2. Non-Pipelined Multi-Cycle CPU
* 명령어 하나를 여러 클럭에 나눠 처리하지만, 한번에 하나의 명령어만 처리
* 일반적인 단계:
  * FETCH
  * DECODE
  * EXECUTE
  * MEMORY (optional)
  * WRITE-BACK
* ✔ 장점
  * 회로가 single-cycle보다 훨씬 작음
  * 클럭 주기를 더 짧게 잡을 수 있음 (각 단계는 가벼움)
  * 제어 논리 설계가 간단
* ✘ 단점
  * 성능은 파이프라인 CPU보다 낮음 (명령어 1개 = 여러 클럭)
  * 외부 장치와 타이밍을 맞추려면 FSM 제어가 필요함 → UART 트리거, ALU 결과 sync 등

## 🚀 2. 파이프라인이 있는 CPU(Pipelined CPU)의 특징
* 가장 널리 알려진 구조가 5-stage pipeline:

| 단계	| 설명|
|:--:|:--:| 
| IF	| instruction fetch| 
| ID	| instruction decode| 
| EX	| execute (ALU)| 
| MEM	| memory access| 
| WB	| write-back| 

* 각 명령어는 각 단계에서 “흐름처럼” 진행됨.
마치 공장에서 물건을 찍어내듯이,
여러 명령어가 동시에 서로 다른 단계에서 실행됨.

예:
1번째 명령: EX 단계
2번째 명령: ID 단계
3번째 명령: IF 단계

* ✔ 장점
  * 성능이 비약적으로 상승 (거의 1클럭에 1명령 처리)
  * 클럭 주기를 매우 짧게 잡을 수 있음
  * ALU, 메모리, 레지스터 파일 등이 매 사이클 효율적으로 사용됨

* ✘ 단점
  * 데이터 해저드, 제어 해저드 등 문제가 생김
  * forwarding, stall, flush 같은 복잡한 제어가 필요
  * 설계/디버깅 난이도가 매우 높음
  * UART 같은 외부 slow 장치와 동기화가 난해해짐

## 🏛 3. 구조적으로 어떤 차이가 발생하는가?
  * 🔸 Non-Pipelined CPU
```sql
cycle 1: fetch
cycle 2: decode
cycle 3: execute
cycle 4: write-back
cycle 5: uart-send
```

* 모든 단계는 서로 시간적으로 분리되어 있어서:
* 언제 값이 확정되는지 명확
* UART는 “execute 다음 cycle에 wb 값이 확정됨”처럼 타이밍 설계가 쉬움
* ALU와 UART가 싸우지도 않음

## 👉 TinyTapeout / Micro FPGA 프로젝트엔 이 구조가 적합

*🔸 Pipelined CPU
```sql
cycle 1:   IF1 - - - -
cycle 2:   IF2 ID1 - - -
cycle 3:   IF3 ID2 EX1 - -
cycle 4:   IF4 ID3 EX2 MEM1 -
cycle 5:   IF5 ID4 EX3 MEM2 WB1
```

* fetch/decode/execute/write-back이 겹쳐서 실행됨
* 각 단계는 거의 매 cycle 가동됨
* 갑자기 “operand가 아직 준비 안 됨” 같은 상황이 생김
* 👉 UART처럼 느린 장치 연결 시 매우 비효율적이고 복잡해짐

## 🔎 4. 왜 지금 설계는 비정상적이었나?
* 현재 상황은 파이프라인이 없는 CPU처럼 보이지만, 실제 동작은 아래처럼 “뒤섞인 파이프라인” 형태:
  * PC는 계속 증가 (fetch)
  * DECODER는 매 cycle decode
  * REG는 조건에 따라 매 cycle write
  * 오퍼랜드는 레지스터에 저장되지 않음
  * ALU는 ena=1일 때 아무 때나 계산
  * FSM은 ena level=1이면 반복적으로 UART 전송
  → 각 단계가 독립되어 있지 않고, 경계도 없음
* 즉,
  * 내부적으로 혼합형 파이프라인의 “부작용”은 다 가지고 있는데,
  * 정작 파이프라인이 가진 “장점”은 하나도 없는 상황.

* 파이프라인의 좋은 점(높은 성능)은 활용하지 못하고,
* 파이프라인의 나쁜 점(타이밍 꼬임)만 전부 나타난 것.

* 그래서 operand가 ALU에 안 들어가는 문제,
* UART가 연산 타이밍을 따라가지 못하는 문제,
* manual과 cpu 모드가 충돌하는 문제가 모두 발생한 것.

# ⭐ 5. 일반적인 구조는 이렇게 생각하면 가장 이해가 쉽다

* 같은 디자인을 clean하게 만들려면:

* ✔ Non-Pipelined Multi-Cycle 구조(권장)
```sql
cycle 1: PC -> instr_reg
cycle 2: instr_reg -> opcode/operand_reg
cycle 3: R0, operand_reg -> ALU -> alu_result_reg
cycle 4: R0 <- alu_result_reg
cycle 5: UART <- alu_result_reg
```

* 각 레지스터가 pipeline stage 역할
* 데이터 경로 깨끗
* UART 타이밍 명확
* manual과 cpu 모드 분리가 쉬움 (모드를 바꾸면 사용되는 단계만 달라짐)

# 👑 결론
* 지금 설계 문제는 대부분 “파이프라인이 없는데 파이프라인처럼 뒤섞인 구조” 때문에 발생하는 것.
* 👉 그래서 *“파이프라이닝 유무의 차이를 이해하고, 한 단계씩 동작시키는 Multi-Cycle 구조를 만드는 것”*이 전체 문제를 해결하는 핵심 방향이 됨.


