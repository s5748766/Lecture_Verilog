# EXAM

---

## CLOCK 설정
   * Fclk = 12 MHz (83nsec)
   * Baud = 9600 bps
---

## 버튼정의

| 역할                     | 입력 방법         |
| ---------------------- | ------------- |
| Reset                  | BTNC (Center) |
| Mode 전환 (Manual / CPU) | SW4 슬라이드 스위치  |
| Enable                 | SW3 슬라이드 스위치  |
| Operand A / B          | SW15~SW8      |
| Opcode                 | SW7~SW5       |

| 구분       | 보드 핀명     | Verilog 신호명        | Active 상태    | 기능 설명                                       |
| -------- | --------- | ------------------ | ------------ | ------------------------------------------- |
| **BTNC** | Center 버튼 | `rst_n`            | Low (눌림 시 0) | 시스템 리셋 (Active-Low). 눌렀다 떼면 리셋 해제 후 프로그램 시작 |
| **BTNU** | Up 버튼     | (옵션) `step_up`     | High         | CPU 수동 Step 실행 (옵션: ena=1일 때 1클럭 명령 수행)     |
| **BTND** | Down 버튼   | (옵션) `mode_toggle` | High         | Manual ↔ CPU 모드 전환 토글 (SW4 대신 사용 가능)        |
| **BTNL** | Left 버튼   | (옵션) `manual_prev` | High         | Manual 모드에서 이전 연산 결과 불러오기 (확장용)             |
| **BTNR** | Right 버튼  | (옵션) `manual_next` | High         | Manual 모드에서 다음 연산 수행 (확장용)                  |

* Basys3 버튼은 Active-High 입력이지만, 리셋만 Active-Low(rst_n = ~BTNC)로 처리.
* 버튼은 메커니컬 바운스가 있으므로 실제 하드웨어에서는 2-FF 동기화 + 디바운서 회로를 추가하면 안정적.
* Up/Down/Left/Right 버튼은 확장 제어용으로 자유롭게 할당 가능(예: Step 실행, Mode 전환 등).

---

## A. Manual 모드 (SW4=0)
1. SW3(ena)=1, BTNC 눌렀다 떼서 리셋 해제
2. 연산 선택:
  * SW[15:12] = A (0~15)
  * SW[11:8] = B (0~15)
  * SW[7:5] opcode:
     * 000=ADD, 001=SUB, 010=MUL, 011=DIV, 100=MOD, 101=EQ, 110=GT, 111=LT
3. 결과 확인:
   * LED 하위 영역: {busy, result[6:0]}
   * LED 상위 영역: result[15:9]
   * UART 터미널: 하위 8비트가 1바이트로 주기적 전송( FSM이 busy→idle 사이클)
예) A=15, B=10, opcode=000(ADD):
   * 예상 결과 = 25(0x19) → 터미널에 0x19 바이트 관측
   * LED 하위 7비트에 0x19의 LSBs가 보이고, busy LED(최상위 비트)가 TX 동안 켜졌다 꺼짐


---

## B. CPU 모드 (SW4=1)
1. SW3(ena)=1, BTNC 리셋
2. 내장 ROM 시퀀스가 자동 실행(ADD 3 → SUB 2 → MUL 5 → NOP → 루프)
3. 각 명령의 결과 하위 8비트가 UART로 전송, LED에 결과 비트 표시
4. SW4를 0/1 토글하며 Manual↔CPU 전환 시 UART busy가 0일 때 전환 추천(글리치 회피)


---


## C. Disable/Reset 동작 확인
   * SW3를 0으로 내리면 PC/FSM 정지(상태 유지) → 1로 올리면 재개
   * BTNC를 눌러 리셋: 내부 상태 초기화, PC=0부터 재시작

4) 검증 체크리스트

   * Manual 모드에서 각 opcode별 결과가 기대와 일치
   * DIV/MOD에서 B=0이면 결과 0 방어 로직 동작
   * CPU 모드에서 ROM 프로그램이 순환 실행
   * ena=0일 때 PC advance 정지, 재개 시 정상 진행
   * UART 터미널에서 1바이트 전송이 주기적으로 관측(115200bps)
   * busy LED가 전송 타이밍 동안만 켜짐
  

# 🎯 QUIZ

---

## 🧩 Part 1. Basys3 실험 퀴즈 (이론 + 실습 혼합)

| 번호  | 퀴즈 내용                                                            | 
| --- | ---------------------------------------------------------------- |
| Q1  | ALU의 `opcode`가 3'b011일 때 수행되는 연산은 무엇인가요?                         |
| Q2  | FSM 모듈은 어떤 역할을 하나요?                                              |
| Q3  | CPU 모드에서 ROM에 저장된 첫 번째 명령어(`rom[0]`)는 무엇인가요?                     |
| Q4  | UART 통신의 `CLOCK_DIV`가 868이면, 시스템 클럭은 약 몇 Hz일까요? (BAUD=115200 기준) |
| Q5  | Manual 모드에서 A=8, B=4, opcode=010을 입력했을 때 결과와 LED 표시값은?           |
| Q6  | `ena=0` 상태에서는 프로그램 카운터(PC)가 어떻게 되나요?                             |
| Q7  | UART 송신 중 Busy 신호(`uart_busy`)는 어떤 역할을 하나요?                      |
| Q8  | Basys3 버튼 중 BTNC의 역할은 무엇인가요?                                     |
| Q9  | ROM이 `initial begin` 블록으로 초기화되어 있음에도 합성 가능한 이유는?                 |
| Q10 | TinyTapeout 버전과 Basys3 버전의 차이는 무엇인가요?                            |

<details>
  <summary>확인</summary>
    
| 번호  | 퀴즈 내용                                                            | 정답 포인트                                                      |
| --- | ---------------------------------------------------------------- | ----------------------------------------------------------- |
| Q1  | ALU의 `opcode`가 3'b011일 때 수행되는 연산은 무엇인가요?                         | 나눗셈(DIV), 단 b=0이면 0으로 출력                                    |
| Q2  | FSM 모듈은 어떤 역할을 하나요?                                              | ALU 제어 및 UART 송신 제어를 통합 관리                                  |
| Q3  | CPU 모드에서 ROM에 저장된 첫 번째 명령어(`rom[0]`)는 무엇인가요?                     | `ADD 3` (`8'b00000011`)                                     |
| Q4  | UART 통신의 `CLOCK_DIV`가 868이면, 시스템 클럭은 약 몇 Hz일까요? (BAUD=115200 기준) | 약 100 MHz                                                   |
| Q5  | Manual 모드에서 A=8, B=4, opcode=010을 입력했을 때 결과와 LED 표시값은?           | 8×4=32(0x20), LED 하위에 0x20 표시                               |
| Q6  | `ena=0` 상태에서는 프로그램 카운터(PC)가 어떻게 되나요?                             | 정지(현재 값 유지)                                                 |
| Q7  | UART 송신 중 Busy 신호(`uart_busy`)는 어떤 역할을 하나요?                      | 송신 중 LED가 켜지며, 전송 완료 후 꺼짐                                   |
| Q8  | Basys3 버튼 중 BTNC의 역할은 무엇인가요?                                     | 리셋(Active-Low), 시스템 초기화                                     |
| Q9  | ROM이 `initial begin` 블록으로 초기화되어 있음에도 합성 가능한 이유는?                 | Vivado가 초기화 내용을 Bitstream에 포함 (BRAM/LUTROM으로 매핑)            |
| Q10 | TinyTapeout 버전과 Basys3 버전의 차이는 무엇인가요?                            | TinyTapeout은 mask-level RTL용 최소형, Basys3는 교육 및 실시간 입출력용 확장형 |
</details>

---

## 🚀 Part 2. 업그레이드 요청 아이디어

| 카테고리                         | 제안 내용                                | 설명                                          |
| ---------------------------- | ------------------------------------ | ------------------------------------------- |
| **1. UART RX 추가**            | UART 수신기(UART_RX) 모듈 추가              | 외부 PC에서 연산 명령을 실시간 전송 (예: "A=5,B=7,OP=ADD") |
| **2. 7-Segment 표시기 연결**      | ALU 결과 하위 8비트를 7세그먼트 4자리로 출력         | UART 없이도 결과를 눈으로 확인                         |
| **3. Debounce 회로 추가**        | BTNC, SW 입력에 debounce 적용             | 노이즈에 의한 잘못된 리셋/모드전환 방지                      |
| **4. ROM 초기화 파일 분리**         | `program.mem` 로드 방식                  | 명령어 변경 시 코드 재합성 없이 수정 가능                    |
| **5. Step-by-Step 실행**       | BTNU(Up 버튼)로 한 명령씩 실행                | 교육용 디버깅 모드                                  |
| **6. LCD 연결 (Pmod CLS)**     | UART 대신 문자로 결과 표시                    | Basys3의 Pmod CLS 사용 시 간단한 printf 구현 가능      |
| **7. ALU 파이프라인화**            | 곱셈/나눗셈 등 지연 연산을 pipeline stage로 분리   | 고클럭 환경에서도 안정적                               |
| **8. EEPROM 프로그램 저장**        | ROM 대신 외부 EEPROM 연결                  | 프로그램 변경 가능 SoC (TinyCPU 완성형)                |
| **9. FSM + Interrupt 구조 추가** | FSM 내에서 UART TX 완료 시 Interrupt 발생    | CPU 모드와 연계한 고급 실습 가능                        |
| **10. HLS 기반 ALU 자동 생성**     | Vivado HLS로 C 기반 ALU 설계 후 Verilog 변환 | 하이레벨 합성 교육용 실습 확장                           |





