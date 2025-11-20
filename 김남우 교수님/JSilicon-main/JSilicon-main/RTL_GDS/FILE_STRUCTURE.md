# JSilicon RTL-to-GDS 튜토리얼 파일 구성

## 📦 GitHub 저장소 구조

```
JSilicon2/
│
├── README.md                    # 메인 튜토리얼 가이드 (38KB)
├── QUICKSTART.md                # 빠른 시작 가이드 (5KB)
├── install.sh                   # 자동 설치 스크립트 (13KB)
├── LICENSE                      # MIT 라이선스
│
├── src/                         # RTL 소스 파일
│   ├── alu.v                   # ALU 모듈
│   ├── fsm.v                   # FSM 제어 모듈
│   ├── inst.v                  # 명령어 디코더
│   ├── pc.v                    # Program Counter
│   ├── regfile.v               # Register File
│   ├── switch.v                # Switch 인터페이스
│   ├── uart.v                  # UART 컨트롤러
│   └── jsilicon.v              # Top 모듈
│
├── sim/                         # 시뮬레이션 테스트벤치
│   ├── tb_alu.v
│   ├── tb_fsm.v
│   ├── tb_inst.v
│   ├── tb_pc.v
│   ├── tb_regfile.v
│   ├── tb_switch.v
│   ├── tb_uart.v
│   └── tb_jsilicon.v
│
├── constraints/                 # 타이밍 제약 조건
│   └── jsilicon.sdc
│
├── scripts/                     # 실행 스크립트
│   ├── genus/
│   │   └── synthesis.tcl       # Genus 합성 스크립트
│   └── innovus/
│       ├── mmmc.tcl            # MMMC 설정
│       └── pnr_flow.tcl        # Innovus P&R 스크립트
│
├── setup_env.sh                # 환경 설정 스크립트
└── docs/                       # 추가 문서
    ├── ARCHITECTURE.md         # 아키텍처 상세 설명
    ├── TUTORIAL_STEP1.md       # 단계별 튜토리얼 1
    ├── TUTORIAL_STEP2.md       # 단계별 튜토리얼 2
    └── FAQ.md                  # 자주 묻는 질문
```

---

## 📋 주요 파일 설명

### 1. 문서 파일

#### README.md (38KB)
- **내용**: 전체 RTL-to-GDS 플로우 튜토리얼
- **대상**: 디지털 IC 설계를 처음 배우는 대학생
- **포함 내용**:
  - 프로젝트 소개 및 학습 목표
  - 설계 개요 및 아키텍처
  - 환경 준비 (EDA 툴, PDK)
  - 상세 실습 가이드 (합성, P&R)
  - 결과 분석 방법
  - 문제 해결 가이드
  - 참고 자료

#### QUICKSTART.md (5KB)
- **내용**: 30분 빠른 시작 가이드
- **대상**: 빠르게 실행해보고 싶은 사용자
- **포함 내용**:
  - 5분 설치 가이드
  - 자동 실행 스크립트
  - 단계별 수동 실행
  - 결과 확인 방법
  - 빠른 트러블슈팅

### 2. 스크립트 파일

#### install.sh (13KB)
- **기능**: 전체 환경 자동 설정
- **실행**: `bash install.sh`
- **수행 작업**:
  1. 환경 확인 (Cadence 툴)
  2. FreePDK45 다운로드
  3. 디렉토리 구조 생성
  4. 기술 파일 복사
  5. 환경 설정 파일 생성
  6. RTL 파일 확인

#### setup_env.sh
- **기능**: 환경 변수 설정
- **실행**: `source setup_env.sh`
- **설정 항목**:
  - Cadence 툴 경로
  - 프로젝트 루트
  - OA_HOME 제거

### 3. 합성 스크립트

#### scripts/genus/synthesis.tcl
- **기능**: Genus 논리 합성 실행
- **입력**: RTL 파일 (src/*.v)
- **출력**:
  - Gate-level netlist
  - 타이밍/면적/전력 리포트
- **소요 시간**: 2-3분

### 4. P&R 스크립트

#### scripts/innovus/pnr_flow.tcl
- **기능**: Innovus 배치 및 배선
- **입력**: 합성된 netlist
- **출력**:
  - DEF 레이아웃
  - 최종 netlist
  - 타이밍/면적 리포트
- **소요 시간**: 10-15분

#### scripts/innovus/mmmc.tcl
- **기능**: Multi-Mode Multi-Corner 설정
- **설정**:
  - Library sets
  - RC corners
  - Analysis views

---

## 🎓 사용 방법

### 방법 1: 자동 설치 (추천)

```bash
# 1. 저장소 클론
git clone https://github.com/YOUR_USERNAME/JSilicon2.git
cd JSilicon2

# 2. 자동 설치 실행
bash install.sh

# 3. RTL 파일이 있는지 확인하고 없으면 복사

# 4. 합성 실행
cd work/synthesis
genus -f ../../scripts/genus/synthesis.tcl

# 5. P&R 실행
cd ../pnr
innovus -init ../../scripts/innovus/pnr_flow.tcl
```

### 방법 2: 수동 설치

```bash
# QUICKSTART.md 참조
```

---

## 📊 예상 결과

### 합성 결과
```
┌─────────────────────────────────┐
│ JSilicon 합성 결과              │
├─────────────────────────────────┤
│ Cells:     595                  │
│ Clock:     5.0 ns (200 MHz)     │
│ WNS:       +0.217 ns ✓          │
│ TNS:       0.0 ns ✓             │
│ Area:      2958 um²             │
│ Power:     ~100 mW              │
└─────────────────────────────────┘
```

### P&R 결과
```
┌─────────────────────────────────┐
│ JSilicon P&R 결과               │
├─────────────────────────────────┤
│ Layout:    tt_um_Jsilicon.def   │
│ Size:      54 x 54 um           │
│ Util:      60%                  │
│ Routing:   Complete ✓           │
│ Timing:    Met ✓                │
└─────────────────────────────────┘
```

---

## 🔧 필수 요구사항

### 소프트웨어
- **OS**: Linux (CentOS 7+, Ubuntu 18.04+)
- **EDA Tools**:
  - Cadence Genus 21.1+ (합성)
  - Cadence Innovus 21.1+ (P&R)
- **PDK**: FreePDK45 (자동 다운로드)

### 하드웨어
- **CPU**: 4 cores 이상
- **RAM**: 16 GB 이상
- **Disk**: 50 GB 여유 공간

---

## 📚 학습 경로

### 초급 (1주차)
1. README.md 읽기
2. RTL 코드 분석
3. 합성 실행 및 결과 확인

### 중급 (2주차)
4. P&R 실행 및 레이아웃 확인
5. 타이밍 분석 및 최적화
6. 파라미터 변경 실험

### 고급 (3주차)
7. 설계 수정 (ALU 확장 등)
8. 전력 최적화
9. 자신만의 프로세서 설계

---

## 🤝 기여 방법

### 버그 리포트
GitHub Issues에 다음 정보 포함:
- 오류 메시지
- 실행 환경 (OS, 툴 버전)
- 재현 방법

### 개선 제안
Pull Request로 다음 제출:
- 코드 개선
- 문서 수정
- 새로운 튜토리얼

---

## 📞 지원

- **GitHub Issues**: 기술적 질문
- **GitHub Discussions**: 일반 토론
- **Email**: your.email@university.edu

---

## 📄 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능

---

## 🙏 감사

- FreePDK45: baichen318
- Cadence: 교육용 툴 지원
- 오픈소스 커뮤니티

---

**Last Updated**: 2025-11-17
**Version**: 1.0
**Maintainer**: JSilicon Team
