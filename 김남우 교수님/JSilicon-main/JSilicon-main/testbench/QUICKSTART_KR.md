# Jsilicon 테스트벤치 빠른 시작 가이드

## 📋 요약

Jsilicon은 간단한 8비트 CPU 디자인으로, Manual 모드와 CPU 모드를 지원합니다.
이 패키지에는 모든 모듈에 대한 검증된 Verilog-1995 테스트벤치가 포함되어 있습니다.

## 🚀 빠른 시작

### 1단계: 파일 확인
```bash
ls -la
# 다음 파일들이 있어야 합니다:
# - tb_alu.v, tb_uart.v, tb_pc.v, tb_decoder.v
# - tb_reg.v, tb_switch.v, tb_fsm.v, tb_jsilicon_top.v
# - Makefile
```

### 2단계: 간단한 테스트 실행
```bash
# ALU 테스트 (가장 기본적인 테스트)
xrun +v2k -access +rwc ../alu.v ../tb_alu.v

# 또는 Makefile 사용
make alu
```

### 3단계: 전체 시스템 테스트
```bash
# TOP 모듈 테스트 (모든 기능 통합)
make top
```

## 📊 테스트벤치 우선순위

처음 시뮬레이션을 시작한다면 다음 순서로 진행하세요:

### ⭐ 초급 (개별 모듈)
1. **tb_alu.v** - 가장 기본적인 ALU 연산 테스트
2. **tb_switch.v** - 모드 전환 로직 테스트
3. **tb_reg.v** - 레지스터 읽기/쓰기 테스트

### ⭐⭐ 중급 (통합 모듈)
4. **tb_pc.v** - 프로그램 카운터와 ROM 테스트
5. **tb_decoder.v** - 명령어 디코더 테스트
6. **tb_uart.v** - UART 송신 테스트 (시간이 오래 걸림)

### ⭐⭐⭐ 고급 (전체 시스템)
7. **tb_fsm.v** - FSM 상태머신 통합 테스트
8. **tb_jsilicon_top.v** - 전체 시스템 통합 테스트 (가장 복잡)

## 💡 Xcelsium 명령어 예제

### 기본 시뮬레이션
```bash
xrun +v2k -access +rwc [소스파일.v] [테스트벤치.v]
```

### GUI 모드로 실행
```bash
xrun +v2k -access +rwc -gui [소스파일.v] [테스트벤치.v]
```

### 파형 생성 후 확인
```bash
# 1. 시뮬레이션 실행 (VCD 파일 생성됨)
xrun +v2k -access +rwc ../alu.v ../tb_alu.v

# 2. 파형 뷰어로 열기
simvision alu_wave.vcd
```

## 📖 주요 모듈 설명

### ALU (산술논리연산장치)
- **기능**: 8가지 연산 (ADD, SUB, MUL, DIV, MOD, EQ, GT, LT)
- **입력**: 8비트 a, b
- **출력**: 16비트 result
- **특징**: 0으로 나누기 보호

### UART (직렬통신)
- **기능**: 9600bps 직렬 데이터 송신
- **규격**: 8N1 (8bit, No parity, 1 stop bit)
- **타이밍**: 1바이트당 약 1.04ms

### PC (프로그램 카운터)
- **기능**: 명령어 페치 및 순차 실행
- **ROM**: 4개 명령어 (ADD 3, SUB 2, MUL 5, NOP)
- **순환**: 0→1→2→3→0

### FSM (실행 제어)
- **상태**: INIT → SEND → WAIT → INIT
- **기능**: ALU 실행 후 UART로 결과 전송

## 🔍 예상 시뮬레이션 결과

### ALU 테스트
```
15 + 10 = 25
12 * 5 = 60
100 / 7 = 14
50 - 20 = 30
25 == 25 = 1 (true)
```

### CPU 모드 실행 (ROM 프로그램)
```
PC=0: ADD 3  -> R0 = 0 + 3 = 3
PC=1: SUB 2  -> R0 = 3 - 2 = 1  
PC=2: MUL 5  -> R0 = 1 * 5 = 5
PC=3: NOP    -> (no operation)
PC=0: ADD 3  -> R0 = 5 + 3 = 8 (순환)
```

## 🛠️ 문제 해결

### "파일을 찾을 수 없습니다" 오류
```bash
# 소스 파일 경로 확인
ls /mnt/user-data/uploads/

# 경로를 정확히 지정
xrun +v2k ../alu.v ../tb_alu.v
```

### 시뮬레이션 시간이 너무 길 때
```bash
# UART 테스트는 시간이 오래 걸립니다 (9600bps)
# 대신 ALU나 SWITCH 테스트부터 시작하세요
make alu      # 빠름
make switch   # 빠름
make uart     # 느림 (약 1분)
```

### VCD 파일이 생성되지 않을 때
```bash
# 테스트벤치 코드에 이미 포함되어 있습니다:
# $dumpfile("xxx_wave.vcd");
# $dumpvars(0, tb_xxx);

# 시뮬레이션 후 확인
ls *.vcd
```

## 📚 추가 문서

- **design_summary.md**: 전체 디자인 구조 및 모듈별 상세 설명
- **README.md**: 상세한 사용 가이드 및 문제 해결

## ✅ 체크리스트

시뮬레이션 전 확인사항:
- [ ] Xcelsium (xrun) 설치 및 라이센스 확인
- [ ] 소스 파일 경로 확인 (/mnt/user-data/uploads/)
- [ ] 테스트벤치 파일 존재 확인
- [ ] 충분한 디스크 공간 (VCD 파일용)

## 🎯 권장 학습 순서

1. **design_summary.md** 읽기 (5분)
2. **tb_alu.v** 시뮬레이션 (1분)
3. **tb_switch.v** 시뮬레이션 (1분)
4. **tb_reg.v** 시뮬레이션 (1분)
5. **tb_pc.v** 시뮬레이션 (2분)
6. **tb_decoder.v** 시뮬레이션 (2분)
7. **tb_fsm.v** 시뮬레이션 (5분)
8. **tb_jsilicon_top.v** 시뮬레이션 (10분)

총 소요 시간: 약 30분

## 🚀 고급 사용법

### 모든 테스트 한번에 실행
```bash
make all_tests
```

### 특정 모듈만 반복 테스트
```bash
# ALU 테스트를 여러 번 실행
for i in {1..5}; do
    echo "Run $i"
    make alu
done
```

### 커스텀 시뮬레이션 옵션
```bash
# 더 많은 디버그 정보 출력
xrun +v2k -access +rwc -linedebug -messages \
     ../alu.v ../tb_alu.v
```

---
