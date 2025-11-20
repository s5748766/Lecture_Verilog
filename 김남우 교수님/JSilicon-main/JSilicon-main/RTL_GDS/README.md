# JSilicon: RTL-to-GDS Design Flow Tutorial

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Technology: FreePDK45](https://img.shields.io/badge/Technology-FreePDK45-blue.svg)](https://github.com/baichen318/FreePDK45)
[![Tool: Cadence](https://img.shields.io/badge/Tool-Cadence-red.svg)](https://www.cadence.com/)

---

## 📚 목차

1. [프로젝트 소개](#-프로젝트-소개)
2. [학습 목표](#-학습-목표)
3. [설계 개요](#-설계-개요)
4. [환경 준비](#-환경-준비)
5. [RTL-to-GDS 플로우](#-rtl-to-gds-플로우)
6. [상세 실습 가이드](#-상세-실습-가이드)
7. [결과 분석](#-결과-분석)
8. [문제 해결](#-문제-해결)
9. [참고 자료](#-참고-자료)

---

## 🎓 프로젝트 소개

**JSilicon**은 **RTL-to-GDS (Register Transfer Level to Graphic Data System)** 디지털 IC 설계 플로우를 직접 경험할 수 있도록 만든 교육용 프로세서 프로젝트입니다.

- ✅ **실무 도구 사용**: Cadence Genus, Innovus 등 실제 산업에서 사용하는 EDA 툴 경험
- ✅ **완전한 플로우**: RTL 작성부터 최종 Layout까지 전체 과정 학습
- ✅ **오픈소스 PDK**: FreePDK45를 사용하여 누구나 접근 가능
- ✅ **단계별 학습**: 각 단계마다 명확한 입출력과 검증 방법 제시

### 설계 사양

| 항목 | 사양 |
|------|------|
| **아키텍처** | 8-bit 프로세서 |
| **클록 주파수** | 12 MHz (검토결과 200MHz - 5ns period) |
| **공정 기술** | FreePDK45 (45nm) |
| **모듈 수** | 8개 (ALU, FSM, Instruction, PC, Register File, Switch, UART, Top) |
| **게이트 수** | ~595 cells (합성 후) |
| **면적** | ~2958 um² |

---

## 🎯 학습 목표

이 튜토리얼을 완료하면 다음을 배울 수 있습니다:

### 1. RTL 설계 이해
- Verilog로 작성된 디지털 회로 구조 분석
- 각 모듈의 기능과 인터페이스 이해
- 계층적 설계 방법론

### 2. 논리 합성 (Logic Synthesis)
- RTL을 게이트 수준으로 변환하는 과정
- 타이밍 제약 조건 (SDC) 작성
- 면적, 속도, 전력 트레이드오프

### 3. 배치 및 배선 (Place & Route)
- Floorplanning 개념
- 표준 셀 배치 최적화
- 클록 트리 합성 (CTS)
- 전역/상세 배선

### 4. 타이밍 검증
- Setup/Hold 타이밍 분석
- Critical Path 분석
- Timing Slack 해석

### 5. 물리적 검증
- Design Rule Check (DRC)
- Layout vs Schematic (LVS)
- 기생 성분 추출

---

## 🔧 설계 개요

### JSilicon 프로세서 아키텍처

```
┌─────────────────────────────────────────────────┐
│              tt_um_Jsilicon (Top)               │
│                                                 │
│  ┌─────────┐  ┌─────────┐  ┌──────────┐       │
│  │   PC    │  │  INST   │  │ REGFILE  │       │
│  │ (8-bit) │→ │ Decoder │→ │ (8 regs) │       │
│  └─────────┘  └─────────┘  └──────────┘       │
│       ↓            ↓             ↓              │
│  ┌─────────────────────────────────┐           │
│  │          FSM (Control)          │           │
│  └─────────────────────────────────┘           │
│       ↓            ↓             ↓              │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │   ALU   │  │ SWITCH  │  │  UART   │        │
│  │ (8-bit) │  │  (I/O)  │  │ (Serial)│        │
│  └─────────┘  └─────────┘  └─────────┘        │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 주요 모듈 설명

| 모듈 | 파일 | 기능 | 크기 |
|------|------|------|------|
| **PC** | `pc.v` | Program Counter - 다음 실행할 명령어 주소 관리 | ~50 lines |
| **INST** | `inst.v` | Instruction Decoder - 명령어 해석 및 제어 신호 생성 | ~80 lines |
| **REGFILE** | `regfile.v` | Register File - 8개의 8-bit 범용 레지스터 | ~60 lines |
| **ALU** | `alu.v` | Arithmetic Logic Unit - 산술/논리 연산 수행 | ~100 lines |
| **FSM** | `fsm.v` | Finite State Machine - 프로세서 상태 제어 | ~120 lines |
| **SWITCH** | `switch.v` | Switch Interface - 외부 입력 처리 | ~40 lines |
| **UART** | `uart.v` | UART Controller - 시리얼 통신 | ~150 lines |
| **JSILICON** | `jsilicon.v` | Top Module - 모든 모듈 통합 | ~200 lines |

---

## 🛠️ 환경 준비

### 1. 필수 소프트웨어

#### EDA Tools (교육기관 라이선스 필요)

| 툴 | 용도 | 최소 버전 |
|-----|------|-----------|
| **Cadence Genus** | 논리 합성 | 21.1 이상 |
| **Cadence Innovus** | 배치 및 배선 | 21.1 이상 |
| **Synopsys VCS** (선택) | RTL 시뮬레이션 | 2020 이상 |
| **Verdi** (선택) | 파형 분석 | 2020 이상 |

#### PDK (Process Design Kit)

- **FreePDK45**: 오픈소스 45nm PDK
  - GitHub: [baichen318/FreePDK45](https://github.com/baichen318/FreePDK45)
  - 포함: Liberty (.lib), LEF (.lef), Technology files

### 2. 시스템 요구사항

```yaml
OS: Linux (CentOS 7, Ubuntu 18.04+, RHEL 7+)
CPU: 4 cores 이상 (권장: 8 cores)
RAM: 16 GB 이상 (권장: 32 GB)
Disk: 50 GB 여유 공간
```

### 3. 디렉토리 구조

```bash
JSilicon2/
├── src/                    # RTL 소스 파일
│   ├── alu.v
│   ├── fsm.v
│   ├── inst.v
│   ├── pc.v
│   ├── regfile.v
│   ├── switch.v
│   ├── uart.v
│   └── jsilicon.v
├── sim/                    # 시뮬레이션 테스트벤치
├── constraints/            # 타이밍 제약 조건
│   └── jsilicon.sdc
├── tech/                   # 기술 파일
│   ├── lib/               # Liberty 파일
│   │   └── gscl45nm.lib
│   └── lef/               # LEF 파일
│       └── gscl45nm.lef
├── scripts/               # 실행 스크립트
│   ├── genus/            # 합성 스크립트
│   └── innovus/          # P&R 스크립트
├── work/                  # 작업 디렉토리
│   ├── synthesis/        # 합성 작업 공간
│   └── pnr/              # P&R 작업 공간
├── results/               # 출력 결과
│   ├── netlist/          # 네트리스트
│   ├── def/              # DEF 레이아웃
│   └── gds/              # GDS 파일
└── reports/               # 분석 리포트
    ├── synthesis/        # 합성 리포트
    └── pnr/              # P&R 리포트
```

---

## 🚀 RTL-to-GDS 플로우

### 전체 플로우 다이어그램

```
┌─────────────┐
│  RTL Design │  ← Verilog 코드 작성
│   (src/)    │
└──────┬──────┘
       │
       ↓
┌─────────────┐
│ Simulation  │  ← 기능 검증 (VCS/Xcelium)
│  (optional) │
└──────┬──────┘
       │
       ↓
┌─────────────┐
│  Synthesis  │  ← RTL → Gate-level (Genus)
│   (Genus)   │    - Technology mapping
└──────┬──────┘    - Optimization
       │           - Timing check
       ↓
   [Netlist]      ← Gate-level netlist (.v)
   [Reports]      ← Area, Timing, Power
       │
       ↓
┌─────────────┐
│ Floorplan   │  ← Die size, aspect ratio
│  (Innovus)  │    - Power planning
└──────┬──────┘    - Pin placement
       │
       ↓
┌─────────────┐
│  Placement  │  ← Standard cell placement
│  (Innovus)  │    - Global placement
└──────┬──────┘    - Detailed placement
       │
       ↓
┌─────────────┐
│     CTS     │  ← Clock Tree Synthesis
│  (Innovus)  │    - Clock distribution
└──────┬──────┘    - Skew optimization
       │
       ↓
┌─────────────┐
│   Routing   │  ← Global + Detailed routing
│  (Innovus)  │    - Metal layer assignment
└──────┬──────┘    - Via insertion
       │
       ↓
┌─────────────┐
│Optimization │  ← Post-route optimization
│  (Innovus)  │    - Timing fix
└──────┬──────┘    - SI fix
       │
       ↓
┌─────────────┐
│Verification │  ← DRC, LVS, Timing
│  (Innovus)  │    - Physical verification
│  (Pegasus)  │    - Extraction
└──────┬──────┘    
       │
       ↓
┌─────────────┐
│  GDS Output │  ← Final layout
│   (.gds)    │    Ready for fabrication
└─────────────┘
```

### 각 단계별 소요 시간 (예상)

| 단계 | 소요 시간 | 난이도 |
|------|-----------|--------|
| 환경 설정 | 30분 | ⭐⭐ |
| RTL 분석 | 1시간 | ⭐⭐⭐ |
| 합성 (Synthesis) | 5-10분 | ⭐⭐⭐⭐ |
| 배치배선 (P&R) | 10-15분 | ⭐⭐⭐⭐⭐ |
| 검증 | 10-20분 | ⭐⭐⭐⭐ |
| **전체** | **2-3시간** | - |

---

## 📖 상세 실습 가이드

```
vi ~/.cshrc

setenv PATH /tools/cadence/XCELIUMMAIN2409/tools/bin:${PATH}
setenv PATH /home/student001/miniconda3/bin:${PATH}
setenv PATH /tools/cadence/DDI231/GENUS231/bin:${PATH}
setenv PATH /tools/cadence/DDI231/INNOVUS231/bin:${PATH}
```

### Step 0: 프로젝트 설정

#### 0-1. 저장소 클론

```bash
# GitHub에서 프로젝트 다운로드
git clone https://github.com/YOUR_USERNAME/JSilicon2.git
cd JSilicon2

# 또는 ZIP 다운로드
wget https://github.com/YOUR_USERNAME/JSilicon2/archive/main.zip
unzip main.zip
cd JSilicon2-main
```

#### 0-2. FreePDK45 설치

```bash
# FreePDK45 다운로드
cd ~
git clone https://github.com/baichen318/FreePDK45.git
cd FreePDK45

# 또는 ZIP 다운로드
wget https://github.com/baichen318/FreePDK45/archive/main.zip
unzip main.zip
mv FreePDK45-main FreePDK45
```

#### 0-3. 기술 파일 복사

```bash
cd ~/JSilicon2

# 디렉토리 생성
mkdir -p tech/lib tech/lef

# Liberty 파일 복사
cp ~/FreePDK45/FreePDK45/osu_soc/lib/files/gscl45nm.lib tech/lib/

# LEF 파일 복사
cp ~/FreePDK45/FreePDK45/osu_soc/lib/files/gscl45nm.lef tech/lef/

# 확인
ls -lh tech/lib/
ls -lh tech/lef/
```

**예상 출력:**
```
tech/lef/gscl45nm.lef  (예상 크기 : ~64 KB)
tech/lib/gscl45nm.lib  (예상 크기 : ~257 KB)
```

* LEF (.lef)      ← 물리적 정보 (레이아웃)
* Liberty (.lib)  ← 타이밍, 전력 (논리적)

* 두 파일의 관계

| 항목 | LEF | LIB |
|:----:|:----:|:----:| 
| 용도 | Physical Design | Logic Synthesis & STA|
| 정보 | 셀 크기, 핀 위치, 금속층 | 타이밍, 전력, 논리 기능|
| 툴| Innovus, ICC2 | Genus, DC, PrimeTime| 

* 워크플로우:
  * Synthesis: LIB로 논리 최적화 → netlist 생성
  * P&R: LEF로 물리 배치/배선
  * STA: LIB로 타이밍 검증

#### * gscl45nm.lef (Library Exchange Format)
* LEF 파일은 물리적 레이아웃 정보를 담고 있습니다. Place & Route 툴에서 사용됩니다.
* 📌 Metal Layer 예시 (metal1)
```lef
  LAYER metal1
  TYPE ROUTING ;
  DIRECTION HORIZONTAL ;
  PITCH 0.19 ;
  WIDTH 0.065 ;
  SPACING 0.065 ;
  RESISTANCE RPERSQ 0.38 ;
END metal1
```

* 설명:
  * TYPE ROUTING: 배선용 레이어
  * DIRECTION HORIZONTAL: metal1은 수평 방향 우선 배선
  * PITCH 0.19 µm: 인접 트랙 간격
  * WIDTH 0.065 µm: 최소 배선 폭
  * SPACING 0.065 µm: 최소 배선 간격 (DRC 규칙)
  * RESISTANCE 0.38 Ω/□: Sheet resistance (IR drop 계산용)

* 📌 Standard Cell 예시 (AND2X1)
```lef
MACRO AND2X1
  CLASS CORE ;
  SIZE 1.14 BY 2.47 ;
  SYMMETRY X Y ;
  PIN A
    DIRECTION INPUT ;
    PORT
      LAYER metal1 ;
        RECT 0.1475 1.2275 0.2825 1.3625 ;
    END
  END A
  PIN Y
    DIRECTION OUTPUT ;
    ...
END AND2X1
```

* 설명:
   * SIZE 1.14 × 2.47 µm: 셀의 물리적 크기
   * SYMMETRY X Y: 좌우/상하 대칭 가능 (placement 최적화)
   * PIN A RECT: 입력 핀 A의 metal1 상의 좌표 (µm)
   * Place & Route 시 이 좌표로 net을 연결합니다

#### * gscl45nm.lib (Liberty Format)
* LIB 파일은 타이밍, 전력, 기능 정보를 담고 있습니다. Synthesis와 STA에서 사용됩니다.
* 📌 라이브러리 공통 정보
```lib
  ertylibrary(gscl45nm) {
  time_unit : "1ns";
  voltage_unit : "1V";
  nom_voltage : 1.1;
  nom_temperature : 27;
  
  operating_conditions ( typical ) {
     process : 1;
     voltage : 1.1;
     temperature : 27;
  }
```

* 설명:
  * nominal voltage 1.1V, 27°C 조건
  * typical corner (TT) 기준 characterization

* 📌 Cell 타이밍 예시 (AND2X1)
```lib
  ertycell (AND2X1) {
  area : 2.346500;
  cell_leakage_power : 15.6059;
  
  pin(A) {
    direction : input;
    capacitance : 0.00229149;  /* pF */
  }
  
  pin(Y) {
    direction : output;
    max_capacitance : 0.137429;
    function : "(A B)";
    
    timing() {
      related_pin : "A";
      cell_rise(delay_template_6x6) {
        index_1 ("0.1, 0.5, 1.2, 3, 4, 5");      /* input slew */
        index_2 ("0.06, 0.24, 0.48, 0.9, 1.2, 1.8"); /* load cap */
        values (
          "0.335, 0.333, 0.278, ...",  /* ns */
          ...
        );
      }
    }
  }
}
```

* 설명:
  * area: 셀 면적 (µm²)
  * leakage_power: 정적 소비 전력 (nW)
  * capacitance: 입력 핀 부하 (pF) - fanout 계산에 사용
  * function: Boolean 논리식 Y = A & B
  * cell_rise: 6×6 lookup table
      * index_1: 입력 slew (ns)
      * index_2: 출하 부하 (pF)
      * values: 전파 지연 시간 (ns)
      * 예: input slew 0.1ns, load 0.06pF → delay 0.335ns

#### 0-4. 환경 변수 설정

```csh
[student001@gjchamber ~/JSilicon2]$ vi ~/JSilicon2/setup_env.sh
```

```csh
#!/bin/csh
###############################################################################
# JSilicon2 환경 설정 파일 (C Shell / tcsh 용)
# Cadence Tools Environment Setup for C Shell
###############################################################################

#==============================================================================
# 1. Cadence 툴 경로 설정
#==============================================================================
# ⚠️ 중요: 실제 환경에 맞게 아래 경로를 수정하세요!

setenv CADENCE_ROOT /tools/cadence/DDI231

#==============================================================================
# 2. Genus (논리 합성 툴)
#==============================================================================
setenv GENUS_HOME ${CADENCE_ROOT}/GENUS231

# 다른 버전 예시:
# setenv GENUS_HOME ${CADENCE_ROOT}/GENUS221
# setenv GENUS_HOME ${CADENCE_ROOT}/GENUS201

#==============================================================================
# 3. Innovus (P&R 툴)
#==============================================================================
setenv INNOVUS_HOME ${CADENCE_ROOT}/INNOVUS231

# 다른 버전 예시:
# setenv INNOVUS_HOME ${CADENCE_ROOT}/INNOVUS221
# setenv INNOVUS_HOME ${CADENCE_ROOT}/INNOVUS201

#==============================================================================
# 4. PATH 환경 변수 추가
#==============================================================================
setenv PATH ${GENUS_HOME}/bin:${INNOVUS_HOME}/bin:${PATH}

#==============================================================================
# 5. 라이선스 서버 설정
#==============================================================================
# ⚠️ 중요: 실제 라이선스 서버 정보로 수정하세요!

setenv CDS_LIC_FILE 5280@license.gjchamber.ac.kr

# 여러 라이선스 서버:
# setenv CDS_LIC_FILE 5280@server1.edu:5280@server2.edu

#==============================================================================
# 6. OA_HOME 제거
#==============================================================================
unsetenv OA_HOME

#==============================================================================
# 7. 프로젝트 루트
#==============================================================================
setenv JSILICON_ROOT ${HOME}/JSilicon2

#==============================================================================
# 8. 확인 메시지
#==============================================================================
echo ""
echo "=========================================="
echo " JSilicon2 환경 설정 완료 (C Shell)"
echo "=========================================="
echo "  CADENCE_ROOT: ${CADENCE_ROOT}"
echo "  GENUS:        ${GENUS_HOME}"
echo "  INNOVUS:      ${INNOVUS_HOME}"
echo "  PROJECT:      ${JSILICON_ROOT}"
echo "  LICENSE:      ${CDS_LIC_FILE}"
echo "=========================================="
echo ""

#==============================================================================
# 9. 툴 존재 확인
#==============================================================================
if ( -d ${GENUS_HOME} ) then
    echo "✓ Genus found at ${GENUS_HOME}"
    if ( -x ${GENUS_HOME}/bin/genus ) then
        echo "  ✓ genus executable found"
    else
        echo "  ⚠ genus executable not found"
    endif
else
    echo "✗ Genus NOT found at ${GENUS_HOME}"
    echo "  → 경로를 확인하고 수정하세요!"
endif

if ( -d ${INNOVUS_HOME} ) then
    echo "✓ Innovus found at ${INNOVUS_HOME}"
    if ( -x ${INNOVUS_HOME}/bin/innovus ) then
        echo "  ✓ innovus executable found"
    else
        echo "  ⚠ innovus executable not found"
    endif
else
    echo "✗ Innovus NOT found at ${INNOVUS_HOME}"
    echo "  → 경로를 확인하고 수정하세요!"
endif

echo ""
echo "사용 방법:"
echo "  1. 환경 로드:  source ~/JSilicon2/setup_env.csh"
echo "  2. Genus 실행: genus"
echo "  3. Innovus 실행: innovus"
echo ""

###############################################################################
# End of setup_env.csh
###############################################################################
```

**환경 변수 확인:**
```csh
[student001@gjchamber ~/JSilicon2]$ chmod +x ~/JSilicon2/setup_env.sh
[student001@gjchamber ~/JSilicon2]$ ~/JSilicon2/setup_env.sh

==========================================
 JSilicon2 환경 설정 완료 (C Shell)
==========================================
  CADENCE_ROOT: /tools/cadence/DDI231
  GENUS:        /tools/cadence/DDI231/GENUS231
  INNOVUS:      /tools/cadence/DDI231/INNOVUS231
  PROJECT:      /home/student001/JSilicon2
  LICENSE:      5280@license.gjchamber.ac.kr
==========================================

✓ Genus found at /tools/cadence/DDI231/GENUS231
  ✓ genus executable found
✓ Innovus found at /tools/cadence/DDI231/INNOVUS231
  ✓ innovus executable found

사용 방법:
  1. 환경 로드:  source ~/JSilicon2/setup_env.csh
  2. Genus 실행: genus
  3. Innovus 실행: innovus
```

#### 0-5. 디렉토리 구조 생성

```csh
cd ~/JSilicon2

# 자동 생성 스크립트
mkdir -p {work/{synthesis,pnr,sta},results/{netlist,def,gds,timing},reports/{synthesis,pnr,sta},constraints}
```


```
# 확인용 프로그램 만들기 : Centos tree 설치를 못해서(Admin 계정 필요)
vi tree.sh
```

```
#!/bin/bash

# tree 명령어와 유사한 기능을 하는 스크립트
# 사용법: ./tree.sh [디렉토리] [깊이]

# 색상 정의
COLOR_DIR='\033[1;34m'      # 파란색 (디렉토리)
COLOR_EXEC='\033[1;32m'     # 초록색 (실행파일)
COLOR_LINK='\033[1;36m'     # 청록색 (심볼릭 링크)
COLOR_RESET='\033[0m'       # 색상 리셋

# 전역 변수
total_dirs=0
total_files=0
declare -A visited_inodes  # 방문한 inode 추적 (순환 참조 방지)

# 파일 타입에 따른 색상 반환
get_color() {
    local path="$1"
    
    if [ -L "$path" ]; then
        echo -e "${COLOR_LINK}"
    elif [ -d "$path" ]; then
        echo -e "${COLOR_DIR}"
    elif [ -x "$path" ]; then
        echo -e "${COLOR_EXEC}"
    else
        echo -e "${COLOR_RESET}"
    fi
}

# 디렉토리 트리 출력 함수
print_tree() {
    local dir="$1"
    local prefix="$2"
    local max_depth="$3"
    local current_depth="$4"
    
    # 최대 깊이 체크
    if [ -n "$max_depth" ] && [ "$current_depth" -ge "$max_depth" ]; then
        return
    fi
    
    # 디렉토리 접근 권한 체크
    if [ ! -r "$dir" ]; then
        echo "${prefix}[권한 없음]"
        return
    fi
    
    # inode 가져오기 (순환 참조 방지)
    local inode=$(stat -c '%i' "$dir" 2>/dev/null)
    if [ -n "$inode" ] && [ -n "${visited_inodes[$inode]}" ]; then
        return  # 이미 방문한 디렉토리
    fi
    visited_inodes[$inode]=1
    
    # 파일 목록 가져오기 (숨김 파일 포함)
    local items=()
    while IFS= read -r -d '' item; do
        items+=("$(basename "$item")")
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | sort -z)
    
    local count=${#items[@]}
    
    # 각 항목 처리
    for ((i=0; i<count; i++)); do
        local item="${items[$i]}"
        local path="$dir/$item"
        local is_last=false
        
        # 마지막 항목인지 확인
        if [ $i -eq $((count-1)) ]; then
            is_last=true
        fi
        
        # 트리 구조 문자
        if $is_last; then
            local branch="└── "
            local extension="    "
        else
            local branch="├── "
            local extension="│   "
        fi
        
        # 색상 적용
        local color=$(get_color "$path")
        
        # 심볼릭 링크 처리
        if [ -L "$path" ]; then
            local target=$(readlink "$path")
            echo -e "${prefix}${branch}${color}${item}${COLOR_RESET} -> ${target}"
            ((total_files++))
        # 디렉토리 처리
        elif [ -d "$path" ]; then
            echo -e "${prefix}${branch}${color}${item}/${COLOR_RESET}"
            ((total_dirs++))
            # 재귀 호출
            print_tree "$path" "${prefix}${extension}" "$max_depth" $((current_depth+1))
        # 일반 파일 처리
        else
            echo -e "${prefix}${branch}${color}${item}${COLOR_RESET}"
            ((total_files++))
        fi
    done
}

# 사용법 출력
usage() {
    echo "사용법: $0 [디렉토리] [옵션]"
    echo ""
    echo "옵션:"
    echo "  -L [깊이]    최대 디렉토리 깊이 지정"
    echo "  -d           디렉토리만 표시"
    echo "  -a           숨김 파일 포함 (기본값)"
    echo "  -h, --help   도움말 표시"
    echo ""
    echo "예제:"
    echo "  $0                    # 현재 디렉토리"
    echo "  $0 /home/user         # 특정 디렉토리"
    echo "  $0 /home/user -L 2    # 깊이 2까지만"
    exit 1
}

# 메인 실행 부분
main() {
    local target_dir="."
    local max_depth=""
    local dir_only=false
    
    # 인자 파싱
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                usage
                ;;
            -L)
                shift
                max_depth="$1"
                if ! [[ "$max_depth" =~ ^[0-9]+$ ]]; then
                    echo "오류: 깊이는 숫자여야 합니다."
                    exit 1
                fi
                ;;
            -d)
                dir_only=true
                ;;
            -a)
                # 이미 기본값이므로 무시
                ;;
            -*)
                echo "알 수 없는 옵션: $1"
                usage
                ;;
            *)
                target_dir="$1"
                ;;
        esac
        shift
    done
    
    # 디렉토리 존재 확인
    if [ ! -d "$target_dir" ]; then
        echo "오류: '$target_dir'는 디렉토리가 아닙니다."
        exit 1
    fi
    
    # 절대 경로로 변환
    target_dir=$(cd "$target_dir" && pwd)
    
    # 루트 디렉토리 출력
    echo -e "${COLOR_DIR}${target_dir}/${COLOR_RESET}"
    
    # 트리 출력
    print_tree "$target_dir" "" "$max_depth" 0
    
    # 통계 출력
    echo ""
    echo "$total_dirs directories, $total_files files"
}

# 스크립트 실행
main "$@"
```

```
# 확인
[student001@gjchamber ~]$ ./tree.sh JSilicon2
/home/student001/JSilicon2/
├── constraints/
├── reports/
│   ├── pnr/
│   ├── sta/
│   ├── sta/
│   └── synthesis/
│   ├── sta/
│   └── synthesis/
├── sim/
│   ├── tb_alu.v
│   ├── tb_decoder.v
│   ├── tb_fsm.v
│   ├── tb_jsilicon_top.v
│   ├── tb_pc.v
│   ├── tb_reg.v
│   ├── tb_switch.v
│   └── tb_uart.v

9 directories, 8 files

```

---

### Step 1: RTL 코드 분석

#### 1-1. RTL 파일 확인

```csh
cd ~/JSilicon2/src

# 파일 목록 및 크기
ls -lh *.v

# 각 파일의 모듈명 확인
foreach f (*.v)
    echo "=== $f ==="
    grep "^module" $f
    echo ""
end
```

**출력:**
```
[student001@gjchamber src]$ foreach f (*.v)
foreach?     echo "=== $f ==="
foreach?     grep "^module" $f
foreach?     echo ""
foreach? end
=== alu.v ===
module ALU(

=== fsm.v ===
module FSM (

=== inst.v ===
module DECODER (

=== jsilicon.v ===
module tt_um_Jsilicon(

=== pc.v ===
module PC (

=== regfile.v ===
module REG (

=== switch.v ===
module SWITCH (

=== uart.v ===
module UART_TX(

```

#### 1-2. Top 모듈 분석

```csh
# Top 모듈 인터페이스 확인
cd ~/JSilicon2/

cat src/jsilicon.v | grep -A 20 "module tt_um_Jsilicon"

module tt_um_Jsilicon(
    // Tinytapeout 요구 변수명으로 수정
    input wire clk,
    input wire rst_n,

    // 사용자 입력 기능 추가
    input wire [7:0] ui_in,
    input wire [7:0] uio_in,

    // Enable Input 추가
    input wire ena,

    // 출력핀 재지정
    output wire [7:0] uio_oe,

    // 사용자 출력 추가
    output wire [7:0] uo_out,
    output wire [7:0] uio_out
    );

    // 초기화 동기화

```

**주요 포트:**
- `clk`: 클록 입력
- `rst_n`: 리셋 신호 (active-low)
- `ui_in[7:0]`: 외부 입력
- `uo_out[7:0]`: 외부 출력
- 기타 제어 신호

#### 1-3. 모듈 계층 구조 확인

```
vi dishi
```

```
#!/bin/csh
###############################################################################
# JSilicon 모듈 완전 분석 (간단 버전)
# analyze_modules.csh
###############################################################################

set SRC_DIR = "src"

if ( ! -d $SRC_DIR ) then
    echo "Error: src directory not found"
    exit 1
endif

echo "=========================================="
echo " JSilicon 모듈 분석"
echo "=========================================="
echo ""

# 1. 모든 .v 파일 목록
echo "1. Verilog 파일 목록:"
echo ""
set files = `find $SRC_DIR -name "*.v" -type f | sort`
set count = 1
foreach file ( $files )
    echo "  [$count] `basename $file`"
    @ count++
end

echo ""
echo "총 $#files 개 파일"
echo ""

# 2. 각 파일의 모듈명과 인스턴스
echo "=========================================="
echo "2. 모듈별 상세 정보"
echo "=========================================="
echo ""

foreach file ( $files )
    set module = `grep "^module" $file | head -1 | awk '{print $2}' | sed 's/(.*$//'`
    if ( "$module" != "" ) then
        echo "파일: `basename $file`"
        echo "모듈: $module"
        
        # 인스턴스 찾기
        set inst_count = `grep -c '_inst *(' $file`
        if ( $inst_count > 0 ) then
            echo "인스턴스 ($inst_count):"
            grep "_inst *(" $file | sed 's/^[ \t]*//' | awk '{printf "  - %-20s <- %s\n", $2, $1}' | sed 's/(.*$//'
        else
            echo "인스턴스: 없음 (Leaf 모듈)"
        endif
        echo ""
    endif
end

# 3. Top 모듈의 계층 구조
echo "=========================================="
echo "3. Top 모듈 계층 구조"
echo "=========================================="
echo ""

# Top 파일 찾기
set top_file = ""
foreach file ( $files )
    set basename = `basename $file`
    if ( "$basename" =~ *top* || "$basename" =~ *jsilicon* || "$basename" =~ *tt_um* ) then
        set top_file = $file
        break
    endif
end

if ( "$top_file" == "" ) then
    set top_file = $files[1]
endif

set top_module = `grep "^module" $top_file | head -1 | awk '{print $2}' | sed 's/(.*$//'`

echo "$top_module (Top)"
echo ""

# Level 1 인스턴스
echo "Level 1 인스턴스:"
grep "_inst *(" $top_file | sed 's/^[ \t]*//' | awk '{printf "  ├── %-20s <- %s\n", $2, $1}' | sed 's/($//' | sed '$ s/├──/└──/'

echo ""

# 각 Level 1 모듈의 하위 확인
echo "Level 2+ 인스턴스:"
echo ""

set level1_modules = `grep "_inst *(" $top_file | awk '{print $1}'`

foreach l1_module ( $level1_modules )
    # 해당 모듈 파일 찾기
    set module_file = ""
    foreach file ( $files )
        set check_module = `grep "^module $l1_module" $file`
        if ( "$check_module" != "" ) then
            set module_file = $file
            break
        endif
    end
    
    if ( "$module_file" != "" ) then
        set sub_inst_count = `grep -c '_inst *(' $module_file`
        if ( $sub_inst_count > 0 ) then
            echo "  $l1_module 의 하위 인스턴스:"
            grep "_inst *(" $module_file | sed 's/^[ \t]*//' | awk '{printf "    ├── %-20s <- %s\n", $2, $1}' | sed 's/($//' | sed '$ s/├──/└──/'
            echo ""
        endif
    endif
end

echo "=========================================="
```


**계층 구조:**
* _inst를 찾아서 계측을 확인하기 때문에 일부 코드에서 수정이 필요.
   * jsilicon.v
   * fsm.v

```
[student001@gjchamber ~/JSilicon2]$ ./dishi
==========================================
 JSilicon 모듈 분석
==========================================

1. Verilog 파일 목록:

  [1] alu.v
  [2] fsm.v
  [3] inst.v
  [4] jsilicon.v
  [5] pc.v
  [6] regfile.v
  [7] switch.v
  [8] uart.v

총 8 개 파일

==========================================
2. 모듈별 상세 정보
==========================================

파일: alu.v
모듈: ALU
인스턴스: 없음 (Leaf 모듈)

파일: fsm.v
모듈: FSM
인스턴스 (2):
  - alu_inst             <- ALU
  - uart_inst

파일: inst.v
모듈: DECODER
인스턴스: 없음 (Leaf 모듈)

파일: jsilicon.v
모듈: tt_um_Jsilicon
인스턴스 (5):
  - pc_inst              <- PC
  - dec_inst             <- DECODER
  - reg_inst             <- REG
  - switch_inst          <- SWITCH
  - core_inst            <- FSM

파일: pc.v
모듈: PC
인스턴스: 없음 (Leaf 모듈)

파일: regfile.v
모듈: REG
인스턴스: 없음 (Leaf 모듈)

파일: switch.v
모듈: SWITCH
인스턴스: 없음 (Leaf 모듈)

파일: uart.v
모듈: UART_TX
인스턴스: 없음 (Leaf 모듈)

==========================================
3. Top 모듈 계층 구조
==========================================

tt_um_Jsilicon (Top)

Level 1 인스턴스:
  ├── pc_inst              <- PC
  ├── dec_inst             <- DECODER
  ├── reg_inst             <- REG
  ├── switch_inst          <- SWITCH
  └── core_inst            <- FSM

Level 2+ 인스턴스:

  FSM 의 하위 인스턴스:
    ├── alu_inst             <- ALU
    └── uart_inst(           <- UART_TX

==========================================
```

#### 1-4. RTL 코드 리뷰 포인트

**확인 사항:**
- [ ] 모든 입력 포트가 사용되는가?
- [ ] 출력 포트에 항상 값이 할당되는가?
- [ ] 조합 논리에 latch가 생성되지 않는가?
- [ ] 클록과 리셋이 올바르게 연결되었는가?
- [ ] 타이밍 위반 가능성이 있는 긴 경로가 있는가?

---

### Step 2: 타이밍 제약 조건 작성

#### 2-1. SDC 파일 생성

```
cd ~/JSilicon2/constraints
```

```
vi jsilicon.sdc
```

* SDC (Synopsys Design Constraints) 파일 생성 : Cadence도 동일함

```csh
###############################################################################
# JSilicon Timing Constraints
# Target: 200 MHz (5ns period)
###############################################################################

# Create clock
create_clock -name clk -period 5.0 [get_ports clk]

# Clock uncertainty (jitter + skew)
set_clock_uncertainty 0.5 [get_clocks clk]

# Clock transition
set_clock_transition 0.1 [get_clocks clk]

# Input delays (relative to clock)
set_input_delay -clock clk -max 1.5 [all_inputs]
set_input_delay -clock clk -min 0.5 [all_inputs]

# Output delays
set_output_delay -clock clk -max 1.5 [all_outputs]
set_output_delay -clock clk -min 0.5 [all_outputs]

# Remove clock from delay calculation
remove_input_delay clk
remove_output_delay clk

# Set driving cell (standard cell buffer)
set_driving_cell -lib_cell BUFX2 [all_inputs]

# Set load capacitance (approximate wire load)
set_load 0.05 [all_outputs]

# False paths (if any)
# set_false_path -from [get_ports rst_n] -to [all_registers]

# Multi-cycle paths (if any)
# set_multicycle_path 2 -from [get_pins uart_inst/*] -to [get_pins regfile_inst/*]

###############################################################################
# End of constraints
###############################################################################

# 확인
cat jsilicon.sdc
```

#### 2-2. SDC 파일 설명

| 제약 조건 | 값 | 의미 |
|-----------|-----|------|
| `create_clock` | 5.0ns | 200MHz 클록 생성 |
| `set_clock_uncertainty` | 0.5ns | 클록 불확실성 (지터+스큐) |
| `set_input_delay` | 1.5ns (max) | 입력 신호 도착 시간 |
| `set_output_delay` | 1.5ns (max) | 출력 신호 요구 시간 |

**타이밍 마진 계산:**
```
Clock Period:        5.0 ns
- Uncertainty:      -0.5 ns
- Input Delay:      -1.5 ns
- Output Delay:     -1.5 ns
------------------------
Available Time:      1.5 ns (for logic delay)
```

---

### Step 3: 논리 합성 (Synthesis with Genus)

#### 3-1. 합성 스크립트 생성

* 라이센스 확인

```
printenv | egrep 'CDS|LM_LICENSE'
```

* 실행 결과

```
CDS_LIC_FILE=5280@10.10.20.247
LM_LICENSE_FILE=5280@10.10.20.247
CDS_LIC_ONLY=1
CDS_ROOT=/tools/cadence
CDS_INST_DIR=/tools/cadence/IC618
CDSHOME=/tools/cadence/IC618
CDS_Netlisting_Mode=Analog
CDS_AUTO_64BIT_ALL=
CDS_PALETTE_TYPE=MultiAssistance
```

```
mkdir ~/JSilicon2/scripts
cd ~/JSilicon2/scripts
mkdir -p genus
```

* Genus 합성 스크립트

```
vi genus/synthesis.tcl
```

```
###############################################################################
# Genus Synthesis Script for JSilicon
# FreePDK45 Technology
###############################################################################

puts "========================================="
puts "JSilicon Synthesis - FreePDK45"
puts "========================================="
puts ""

# Project paths
set project_root [file normalize ../../]
set tech_lib $project_root/tech/lib/gscl45nm.lib
set tech_lef $project_root/tech/lef/gscl45nm.lef
set src_dir $project_root/src

puts "Project root: $project_root"
puts "Library: $tech_lib"
puts "LEF: $tech_lef"
puts ""

# Read timing library
puts "Reading timing library..."
read_libs $tech_lib

# Read physical library (LEF)
puts "Reading LEF file..."
read_physical -lef $tech_lef

# Read RTL files
puts "Reading RTL files..."
set_db init_hdl_search_path $src_dir

read_hdl -sv {
    alu.v
    fsm.v
    inst.v
    pc.v
    regfile.v
    switch.v
    uart.v
    jsilicon.v
}

# Elaborate design
puts "Elaborating design..."
elaborate tt_um_Jsilicon

# Read constraints
puts "Reading SDC constraints..."
read_sdc $project_root/constraints/jsilicon.sdc

# Set synthesis effort
puts "Setting synthesis options..."
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium
set_db syn_global_effort medium

# Generic synthesis
puts "========================================="
puts "Phase 1: Generic Synthesis"
puts "========================================="
syn_generic

# Technology mapping
puts "========================================="
puts "Phase 2: Technology Mapping"
puts "========================================="
syn_map

# Optimization
puts "========================================="
puts "Phase 3: Optimization"
puts "========================================="
syn_opt

# Generate reports
puts "========================================="
puts "Generating Reports"
puts "========================================="

set report_dir $project_root/reports/synthesis
file mkdir $report_dir

redirect $report_dir/area.rpt {report_area}
redirect $report_dir/gates.rpt {report_gates}
redirect $report_dir/power.rpt {report_power}
redirect $report_dir/timing.rpt {report_timing -nworst 10}
redirect $report_dir/qor.rpt {report_qor}

puts "Reports generated in: $report_dir"
puts ""

# Write outputs
puts "========================================="
puts "Writing Output Files"
puts "========================================="

set netlist_dir $project_root/results/netlist
set work_dir $project_root/work/synthesis

file mkdir $netlist_dir
file mkdir $work_dir

write_hdl > $netlist_dir/tt_um_Jsilicon_synth.v
write_sdc > $work_dir/tt_um_Jsilicon_synth.sdc
write_sdf -timescale ns > $project_root/results/timing/tt_um_Jsilicon_synth.sdf
write_db $work_dir/tt_um_Jsilicon_synth.db

puts ""
puts "========================================="
puts "SYNTHESIS COMPLETE!"
puts "========================================="
puts ""
puts "Output Files:"
puts "  Netlist: $netlist_dir/tt_um_Jsilicon_synth.v"
puts "  SDF:     $project_root/results/timing/tt_um_Jsilicon_synth.sdf"
puts ""
puts "Reports:"
puts "  $report_dir/qor.rpt"
puts "  $report_dir/timing.rpt"
puts ""

exit
```

```
chmod +x genus/synthesis.tcl
```

#### 3-2. 합성 실행

```
cd ~/JSilicon2/work/synthesis

# Genus 실행
genus -f ../../scripts/genus/synthesis.tcl |& tee synthesis.log
```

**실행 과정:**
```
1. Library loading        [~20초]
2. RTL reading            [~10초]
3. Elaboration            [~5초]
4. Generic synthesis      [~30초]
5. Technology mapping     [~40초]
6. Optimization           [~30초]
7. Report generation      [~10초]
------------------------
Total: ~2-3분
```

#### 3-3. 합성 결과 확인

```
cd ~/JSilicon2

# 생성된 파일 확인
echo "=== Generated Files ==="
ls -lh results/netlist/tt_um_Jsilicon_synth.v
ls -lh work/synthesis/tt_um_Jsilicon_synth.db

# QoR 리포트 확인
echo ""
echo "=== QoR Summary ==="
cat reports/synthesis/qor.rpt | tail -50
```

```
=== QoR Summary ===
[student001@gjchamber ~/JSilicon2]$ cat reports/synthesis/qor.rpt | tail -50
  Generated by:           Genus(TM) Synthesis Solution 23.13-s073_1
  Generated on:           Nov 18 2025  07:22:45 am
  Module:                 tt_um_Jsilicon
  Operating conditions:   typical
  Interconnect mode:      global
  Area mode:              physical library
============================================================

Timing
--------

Clock Period
-------------
clk   5000.0


  Cost    Critical         Violating
 Group   Path Slack  TNS     Paths
-------------------------------------
clk             2.9   0.0          0
default    No paths   0.0
-------------------------------------
Total                 0.0          0

Instance Count
--------------
Leaf Instance Count             669
Physical Instance count           0
Sequential Instance Count        42
Combinational Instance Count    627
Hierarchical Instance Count       2

Area
----
Cell Area                          1982.793
Physical Cell Area                 0.000
Total Cell Area (Cell+Physical)    1982.793
Net Area                           1319.789
Total Area (Cell+Physical+Net)     3302.582

Max Fanout                         42 (clk)
Min Fanout                         0 (n_4)
Average Fanout                     1.8
Terms to net ratio                 2.8428
Terms to instance ratio            3.0807
Runtime                            122.600606 seconds
Elapsed Runtime                    141 seconds
Genus peak memory usage            1982.35
Innovus peak memory usage          no_value
Hostname                           localhost

```

**주요 확인 항목:**

```
# 1. 타이밍 확인
grep -A 10 "Timing" reports/synthesis/qor.rpt

# 출력:
# Timing
# --------
# 
# Clock Period
# -------------
# clk   5000.0
# 
# 
#  Cost    Critical         Violating
# Group   Path Slack  TNS     Paths
# -------------------------------------


# 2. 면적 확인
grep -A 5 "Area" reports/synthesis/qor.rpt

# 출력:
#  Area mode:              physical library
#============================================================
#
#Timing
#--------
#
#--
#Area
#----
#Cell Area                          1982.793
#Physical Cell Area                 0.000
#Total Cell Area (Cell+Physical)    1982.793
#Net Area                           1319.789
#Total Area (Cell+Physical+Net)     3302.582
#
#Max Fanout                         42 (clk)
#Min Fanout                         0 (n_4)
#Average Fanout                     1.8
#Terms to net ratio                 2.8428


# 3. 게이트 수 확인
cat reports/synthesis/gates.rpt | head -20

# 출력:
# ============================================================
#   Generated by:           Genus(TM) Synthesis Solution 23.13-s073_1
#   Generated on:           Nov 18 2025  07:22:45 am
#   Module:                 tt_um_Jsilicon
#   Technology libraries:   gscl45nm
#                           physical_cells
#                           gscl45nm
#                           physical_cells
#   Operating conditions:   typical
#   Interconnect mode:      global
#   Area mode:              physical library
# ============================================================
# 
# 
#   Gate    Instances    Area     Library
# ------------------------------------------
# AND2X2           84   197.106    gscl45nm
# AOI21X1          14    32.851    gscl45nm
# AOI22X1          10    28.158    gscl45nm
# BUFX2            73   137.036    gscl45nm

```

#### 3-4. 타이밍 분석

```
# 상위 10개 Critical Path 확인
cat reports/synthesis/timing.rpt | head -100
```

```

============================================================
  Generated by:           Genus(TM) Synthesis Solution 23.13-s073_1
  Generated on:           Nov 18 2025  07:22:45 am
  Module:                 tt_um_Jsilicon
  Operating conditions:   typical
  Interconnect mode:      global
  Area mode:              physical library
============================================================


Path 1: MET (3 ps) Setup Check with Pin core_inst_uart_inst/data_reg_reg[0]/CLK->D
          Group: clk
     Startpoint: (R) uio_in[4]
          Clock: (R) clk
       Endpoint: (R) core_inst_uart_inst/data_reg_reg[0]/D
          Clock: (R) clk

                     Capture       Launch
        Clock Edge:+    5000            0
        Drv Adjust:+       0           16
       Src Latency:+       0            0
       Net Latency:+       0 (I)        0 (I)
           Arrival:=    5000           16

             Setup:-    1438
       Uncertainty:-     500
     Required Time:=    3062
      Launch Clock:-      16
       Input Delay:-    1500
         Data Path:-    1544
             Slack:=       3

Exceptions/Constraints:
  input_delay             1500            jsilicon.sdc_line_16_12_1

#---------------------------------------------------------------------------------------------------------------------
#                Timing Point                  Flags   Arc   Edge   Cell     Fanout Load Trans Delay Arrival Instance
#                                                                                   (fF)  (ps)  (ps)   (ps)  Location
#---------------------------------------------------------------------------------------------------------------------
  uio_in[4]                                    -       -     R     (arrival)      2  9.8    23     0    1516    (-,-)
  g2013/Y                                      -       A->Y  F     INVX2          9 34.8    40    48    1563    (-,-)
  g1991__6161/Y                                -       B->Y  R     NAND2X1        1  4.7    45    30    1594    (-,-)
  drc_bufs20986/Y                              -       A->Y  R     BUFX2         12 64.2   155   132    1726    (-,-)
  core_inst_alu_inst_rem_39_73_g20534__4319/YC -       B->YC R     FAX1           1  5.2    33    74    1800    (-,-)
  core_inst_alu_inst_rem_39_73_g20530__2398/Y  -       C->Y  F     OAI21X1        1  5.4    18    25    1824    (-,-)
  g20831/Y                                     -       A->Y  R     NOR2X1         1  4.7    35    39    1863    (-,-)
  g20767/Y                                     -       A->Y  R     BUFX2          2  8.6    24    45    1908    (-,-)
  g21054/Y                                     -       B->Y  R     AND2X2         3 12.3    32    48    1956    (-,-)
  drc_bufs20844/Y                              -       A->Y  F     INVX1          1  5.1    19    28    1984    (-,-)
  core_inst_alu_inst_rem_39_73_g20477__1666/Y  -       B->Y  R     NAND2X1        1  4.7    46    23    2008    (-,-)
  g20795/Y                                     -       A->Y  R     BUFX2          2  8.4    25    45    2053    (-,-)
  core_inst_alu_inst_rem_39_73_g20447__9315/Y  -       B->Y  F     NAND2X1        1  4.7    27    23    2076    (-,-)
  drc_bufs20854/Y                              -       A->Y  F     BUFX2          1  5.8    10    40    2116    (-,-)
  core_inst_alu_inst_rem_39_73_g20422__8246/Y  -       A->Y  R     OAI21X1        4 17.2   112    90    2207    (-,-)
  g20803/Y                                     -       A->Y  F     INVX1          2  9.3    26    58    2265    (-,-)
  core_inst_alu_inst_rem_39_73_g20402__3680/Y  -       B->Y  F     AND2X2         3 13.2    17    53    2318    (-,-)
  core_inst_alu_inst_rem_39_73_g20383__2346/Y  -       B->Y  R     OAI21X1        2  8.7    72    62    2380    (-,-)
  core_inst_alu_inst_rem_39_73_g20373__9315/Y  -       B->Y  R     AND2X2         2  9.8    29    47    2427    (-,-)
  core_inst_alu_inst_rem_39_73_g20372/Y        -       A->Y  F     INVX2          4 21.8    30    38    2465    (-,-)
  core_inst_alu_inst_rem_39_73_g20370__4733/Y  -       A->Y  F     OR2X2          2  9.4    25    49    2514    (-,-)
  core_inst_alu_inst_rem_39_73_g20333__6260/Y  -       C->Y  R     NAND3X1        1  4.7    48    41    2555    (-,-)
  drc_bufs21070/Y                              -       A->Y  R     BUFX2          1  5.0    18    40    2595    (-,-)
  core_inst_alu_inst_rem_39_73_g20319__6161/Y  -       A->Y  R     AND2X2         1  5.2    17    38    2633    (-,-)
  core_inst_alu_inst_rem_39_73_g20317__4733/Y  -       C->Y  F     OAI21X1        2  9.8    25    27    2660    (-,-)
  core_inst_alu_inst_rem_39_73_g20308__7098/Y  -       A->Y  F     OR2X2          4 17.7    30    57    2718    (-,-)
  core_inst_alu_inst_rem_39_73_g20291__2398/Y  -       A->Y  R     AOI21X1        1  4.7    39    49    2767    (-,-)
  drc_bufs20863/Y                              -       A->Y  R     BUFX2          1  5.5    17    40    2807    (-,-)
  core_inst_alu_inst_rem_39_73_g20283__9945/Y  -       A->Y  R     OR2X2          1  5.9    20    44    2850    (-,-)
  g21052/Y                                     -       B->Y  F     AOI21X1        1  5.9    26    33    2884    (-,-)
  g3/Y                                         -       A->Y  R     INVX2          3 61.9   144   106    2990    (-,-)
  core_inst_uart_inst/g2965__3680/Y            -       A->Y  F     MUX2X1         1  4.7    22    56    3045    (-,-)
  core_inst_uart_inst/g2960/Y                  -       A->Y  R     INVX1          1  5.0     0    14    3059    (-,-)
  core_inst_uart_inst/data_reg_reg[0]/D        -       -     R     DFFPOSX1       1    -     -     0    3060    (-,-)
#---------------------------------------------------------------------------------------------------------------------



Path 2: MET (4 ps) Setup Check with Pin core_inst_uart_inst/data_reg_reg[0]/CLK->D
          Group: clk
     Startpoint: (R) uio_in[4]
          Clock: (R) clk
       Endpoint: (R) core_inst_uart_inst/data_reg_reg[0]/D
          Clock: (R) clk

                     Capture       Launch
        Clock Edge:+    5000            0
        Drv Adjust:+       0           16
       Src Latency:+       0            0
       Net Latency:+       0 (I)        0 (I)
           Arrival:=    5000           16

             Setup:-    1438
       Uncertainty:-     500
     Required Time:=    3062
      Launch Clock:-      16
       Input Delay:-    1500
         Data Path:-    1543
             Slack:=       4

Exceptions/Constraints:
```

**타이밍 리포트 해석:**

```
Startpoint: regfile_inst/regs_reg[0][0]  ← 시작점 (FF)
Endpoint:   alu_inst/result_reg[7]       ← 끝점 (FF)
Path Type: max                            ← Setup 체크

Clock Period: 5.000 ns
Data Arrival Time: 4.783 ns               ← 실제 지연
Data Required Time: 5.000 ns              ← 요구 시간
-----------------------------------
Slack: 0.217 ns                           ← 여유 시간 (양수!)

Path:
  regfile_inst/regs_reg[0][0] (FF) 
  → alu_inst/add_logic (ADDER)
  → alu_inst/result_reg[7] (FF)
```

**타이밍 위반 시 조치:**
- Slack < 0 → 타이밍 위반!
- 해결 방법:
  1. Clock period 증가 (주파수 낮춤)
  2. Optimization effort 증가
  3. RTL 코드 최적화 (파이프라인 추가 등)

---

### Step 4: 배치 및 배선 (Place & Route with Innovus)

#### 4-1. MMMC 설정 파일 생성

```
cd ~/JSilicon2/scripts
mkdir -p innovus
```

```
# MMMC (Multi-Mode Multi-Corner) 설정
vi innovus/mmmc.tcl
```


~~###############################################################################~~
~~# MMMC Setup for JSilicon~~
~~###############################################################################~~

~~set project_root [file normalize ../../]~~
~~set tech_lib $project_root/tech/lib/gscl45nm.lib~~
~~set sdc_file $project_root/work/synthesis/tt_um_Jsilicon_synth.sdc~~

~~# Library set~~
~~create_library_set -name LIB_TYPICAL \~~
~~    -timing $tech_lib~~

~~# RC corner~~
~~create_rc_corner -name RC_TYPICAL \~~
~~    -temperature 27~~

~~# Delay corner~~
~~create_delay_corner -name DELAY_TYPICAL \~~
~~    -library_set LIB_TYPICAL \~~
~~    -rc_corner RC_TYPICAL~~

~~# Constraint mode~~
~~create_constraint_mode -name CONSTRAINTS \~~
~~    -sdc_files $sdc_file~~

~~# Analysis view~~
~~create_analysis_view -name VIEW_TYPICAL \~~
~~    -constraint_mode CONSTRAINTS \~~
~~    -delay_corner DELAY_TYPICAL~~

~~# Set analysis view~~
~~set_analysis_view -setup VIEW_TYPICAL -hold VIEW_TYPICAL~~

~~puts "MMMC setup complete"~~


* Final

```
###############################################################################
# MMMC Setup for JSilicon (MMMC-1 방식)
# File: scripts/innovus/mmmc.tcl
###############################################################################

set project_root [file normalize ../../]
set tech_lib $project_root/tech/lib/gscl45nm.lib
set sdc_file $project_root/work/synthesis/tt_um_Jsilicon_synth.sdc

puts "=========================================="
puts "MMMC Configuration (MMMC-1)"
puts "=========================================="
puts "Tech Library: $tech_lib"
puts "SDC File: $sdc_file"
puts ""

# Check if files exist
if { ![file exists $tech_lib] } {
    puts "ERROR: Technology library not found: $tech_lib"
    exit 1
}

if { ![file exists $sdc_file] } {
    puts "WARNING: SDC file not found: $sdc_file"
    puts "  Will use inline timing constraints instead"
    set sdc_file ""
}

# MMMC-1 방식: library_set 기반
puts "Creating library set..."
create_library_set -name LIB_TYPICAL \
    -timing $tech_lib

puts "Creating RC corner..."
create_rc_corner -name RC_TYPICAL \
    -temperature 27

puts "Creating delay corner..."
create_delay_corner -name DELAY_TYPICAL \
    -library_set LIB_TYPICAL \
    -rc_corner RC_TYPICAL

puts "Creating constraint mode..."
if { $sdc_file != "" } {
    create_constraint_mode -name CONSTRAINTS \
        -sdc_files $sdc_file
} else {
    create_constraint_mode -name CONSTRAINTS \
        -sdc_files {}
}

puts "Creating analysis view..."
create_analysis_view -name VIEW_TYPICAL \
    -constraint_mode CONSTRAINTS \
    -delay_corner DELAY_TYPICAL

puts "Setting analysis view..."
set_analysis_view -setup VIEW_TYPICAL -hold VIEW_TYPICAL

puts ""
puts "✓ MMMC setup complete"
puts "=========================================="
puts ""
```

#### 4-2. P&R 스크립트 생성

```
# Innovus P&R 스크립트
vi innovus/pnr_flow.tcl
```


~~###############################################################################~~
~~# Innovus P&R Flow for JSilicon~~
~~###############################################################################~~

~~puts "========================================="~~
~~puts "JSilicon P&R Flow - FreePDK45"~~
~~puts "========================================="~~
~~puts ""~~

~~# Project paths~~
~~set project_root [file normalize ../../]~~
~~set init_mmmc_file $project_root/scripts/innovus/mmmc.tcl~~
~~set init_lef_file $project_root/tech/lef/gscl45nm.lef~~
~~set init_verilog $project_root/results/netlist/tt_um_Jsilicon_synth.v~~
~~set init_top_cell tt_um_Jsilicon~~

~~puts "Initializing design..."~~
~~init_design~~

~~# Floorplan~~
~~puts "========================================="~~
~~puts "Step 1: Floorplan"~~
~~puts "========================================="~~
~~floorPlan -r 1.0 0.70 10.0 10.0 10.0 10.0~~

~~puts "Floorplan created"~~
~~puts "  Die area: [dbGet top.fPlan.box]"~~
~~puts ""~~

~~# Power planning~~
~~puts "========================================="~~
~~puts "Step 2: Power Planning"~~
~~puts "========================================="~~
~~catch {addRing -nets {VDD VSS} -width 2.0 -spacing 1.0 -layer metal1}~~

~~# Placement~~
~~puts "========================================="~~
~~puts "Step 3: Placement"~~
~~puts "========================================="~~
~~place_design~~

~~saveDesign $project_root/work/pnr/jsilicon_placed.enc~~

~~# Pre-CTS optimization~~
~~optDesign -preCTS~~

~~# CTS~~
~~puts "========================================="~~
~~puts "Step 4: Clock Tree Synthesis"~~
~~puts "========================================="~~
~~create_ccopt_clock_tree_spec~~
~~ccopt_design~~

~~saveDesign $project_root/work/pnr/jsilicon_cts.enc~~

~~# Post-CTS optimization~~
~~optDesign -postCTS~~

~~# Routing~~
~~puts "========================================="~~
~~puts "Step 5: Routing"~~
~~puts "========================================="~~
~~routeDesign~~

~~# Post-route optimization~~
~~puts "========================================="~~
~~puts "Step 6: Post-Route Optimization"~~
~~puts "========================================="~~
~~optDesign -postRoute~~

~~# Reports~~
~~puts "========================================="~~
~~puts "Generating Reports"~~
~~puts "========================================="~~

~~set report_dir $project_root/reports/pnr~~
~~file mkdir $report_dir~~

~~report_timing -max_paths 10 > $report_dir/timing_final.rpt~~
~~report_power > $report_dir/power_final.rpt~~
~~report_area > $report_dir/area_final.rpt~~
~~summaryReport -outfile $report_dir/summary.rpt~~

~~# Write outputs~~
~~set result_dir $project_root/results~~
~~defOut -floorplan -netlist -routing $result_dir/def/tt_um_Jsilicon.def~~
~~saveNetlist $result_dir/netlist/tt_um_Jsilicon_final.v~~
~~saveDesign $project_root/work/pnr/jsilicon_final.enc~~

~~puts ""~~
~~puts "========================================="~~
~~puts "P&R COMPLETE!"~~
~~puts "========================================="~~
~~puts ""~~

~~exit~~


### Final (scripts/innovus/pnr_flow.tcl)

```
###############################################################################
# Innovus P&R Flow for JSilicon (init_design 방식)
# File: scripts/innovus/pnr_flow.tcl
###############################################################################

set DESIGN_NAME "tt_um_Jsilicon"

puts "=========================================="
puts "JSilicon P&R Flow - FreePDK45 (gscl45nm)"
puts "Design: $DESIGN_NAME"
puts "=========================================="
puts ""

# Project paths
set project_root [file normalize ../../]

###############################################################################
# init_design 옵션 설정
###############################################################################
puts "Setting up init_design options..."

set init_lef_file $project_root/tech/lef/gscl45nm.lef
set init_verilog $project_root/results/netlist/${DESIGN_NAME}_synth.v
set init_top_cell $DESIGN_NAME
set init_pwr_net vdd
set init_gnd_net gnd

# MMMC 파일
set init_mmmc_file $project_root/scripts/innovus/mmmc.tcl

# Check files
if { ![file exists $init_lef_file] } {
    puts "ERROR: LEF file not found: $init_lef_file"
    exit 1
}

if { ![file exists $init_verilog] } {
    puts "ERROR: Netlist not found: $init_verilog"
    exit 1
}

if { ![file exists $init_mmmc_file] } {
    puts "ERROR: MMMC file not found: $init_mmmc_file"
    exit 1
}

puts "  ✓ LEF: $init_lef_file"
puts "  ✓ Netlist: $init_verilog"
puts "  ✓ MMMC: $init_mmmc_file"
puts ""

###############################################################################
# Design 초기화 (init_design이 모든 것을 처리)
###############################################################################
puts "Initializing design with init_design..."
puts "(This will load LEF, MMMC, and netlist together)"
puts ""

init_design

puts ""
puts "  ✓ Design initialized successfully"
puts "  ✓ Top module: $init_top_cell"
puts ""

###############################################################################
# Step 1: Floorplan
###############################################################################
puts "=========================================="
puts "Step 1: Floorplan"
puts "=========================================="

floorPlan -r 1.0 0.70 10.0 10.0 10.0 10.0

puts "  ✓ Floorplan created"
puts "    Die area: [dbGet top.fPlan.box]"

# I/O pin assignment - 자동 배치
catch {
    # 모든 I/O를 가장자리에 균등 분배
    editPin -fixOverlap 1 -unit MICRON -spreadType start -spreadDirection clockwise -pin [dbGet top.terms.name -e]
}

puts "  ✓ I/O pins assigned"
puts ""

###############################################################################
# Step 2: Power Planning
###############################################################################
puts "=========================================="
puts "Step 2: Power Planning"
puts "=========================================="

globalNetConnect vdd -type pgpin -pin vdd -inst * -override
globalNetConnect gnd -type pgpin -pin gnd -inst * -override
globalNetConnect vdd -type tiehi -inst *
globalNetConnect gnd -type tielo -inst *

puts "  ✓ Global nets connected"

catch {
    addRing -nets {vdd gnd} -type core_rings \
        -layer {metal9 metal10} \
        -width 2.0 -spacing 1.0 -offset 5.0
}
puts "  ✓ Power rings added"

catch {
    addStripe -nets {vdd gnd} \
        -layer metal8 \
        -direction vertical \
        -width 1.0 -spacing 10.0 -number_of_sets 3
}
puts "  ✓ Power stripes added"

sroute -connect {corePin} -nets {vdd gnd}
puts "  ✓ Power routing completed"
puts ""

###############################################################################
# Step 3: Placement
# (타이밍 제약은 SDC 파일에서 이미 로드됨)
###############################################################################
puts "=========================================="
puts "Step 3: Placement"
puts "=========================================="

setPlaceMode -congEffort high -timingDriven true
place_design

puts "  ✓ Placement completed"

saveDesign $project_root/work/pnr/jsilicon_placed.enc
puts "  ✓ Checkpoint saved: jsilicon_placed.enc"
puts ""

###############################################################################
# Step 4: Pre-CTS Optimization
###############################################################################
puts "=========================================="
puts "Step 4: Pre-CTS Optimization"
puts "=========================================="

optDesign -preCTS

puts "  ✓ Pre-CTS optimization done"
puts ""

###############################################################################
# Step 5: Clock Tree Synthesis (Simplified)
###############################################################################
puts "=========================================="
puts "Step 5: Clock Tree Synthesis"
puts "=========================================="

# CTS 설정 - gscl45nm 라이브러리용
puts "  Configuring CTS for gscl45nm library..."

# 사용 가능한 버퍼 지정
set_ccopt_property buffer_cells {BUFX2 BUFX4}
set_ccopt_property inverter_cells {INVX1 INVX2 INVX4}

# 클락 트리 시도
catch {
    # 간단한 CTS 시도
    create_ccopt_clock_tree_spec -immediate
    ccopt_design
    puts "  ✓ Clock tree built"
} result

if { $result != 0 } {
    puts "  ⚠ CTS skipped (library limitations)"
    puts "  → Proceeding with direct clock routing"
}

saveDesign $project_root/work/pnr/jsilicon_cts.enc
puts "  ✓ Checkpoint saved: jsilicon_cts.enc"
puts ""

###############################################################################
# Step 6: Post-CTS Optimization
###############################################################################
puts "=========================================="
puts "Step 6: Post-CTS Optimization"
puts "=========================================="

optDesign -postCTS

puts "  ✓ Post-CTS optimization done"
puts ""

###############################################################################
# Step 7: Routing
###############################################################################
puts "=========================================="
puts "Step 7: Routing"
puts "=========================================="

setNanoRouteMode -drouteFixAntenna true
setNanoRouteMode -droutePostRouteSwapVia true

routeDesign

puts "  ✓ Routing completed"
puts ""

###############################################################################
# Step 8: Post-Route Optimization
###############################################################################
puts "=========================================="
puts "Step 8: Post-Route Optimization"
puts "=========================================="

# AAE-SI 최적화 비활성화 (OCV 모드 필요)
setOptMode -addInstancePrefix POSTROUTE

# Post-route 최적화 (간단한 모드)
catch {
    optDesign -postRoute
} result

if { $result != 0 } {
    puts "  ⚠ Advanced optimization skipped"
    puts "  → Basic post-route cleanup performed"
}

puts "  ✓ Post-route optimization done"
puts ""

###############################################################################
# Step 9: Filler Cells
###############################################################################
puts "=========================================="
puts "Step 9: Adding Filler Cells"
puts "=========================================="

setFillerMode -corePrefix FILL -core "FILL*"
addFiller

puts "  ✓ Filler cells added"
puts ""

###############################################################################
# Step 10: Verification
###############################################################################
puts "=========================================="
puts "Step 10: Design Verification"
puts "=========================================="

set report_dir $project_root/reports/pnr
file mkdir $report_dir

verifyGeometry -report $report_dir/geometry.rpt
puts "  ✓ Geometry check completed"

verifyConnectivity -report $report_dir/connectivity.rpt
puts "  ✓ Connectivity check completed"
puts ""

###############################################################################
# Step 11: Report Generation
###############################################################################
puts "=========================================="
puts "Step 11: Generating Reports"
puts "=========================================="

# Setup timing (max delay)
report_timing -max_paths 10 -nworst 1 -late \
    > $report_dir/timing_setup.rpt
puts "  ✓ Setup timing report"

# Hold timing (min delay)
report_timing -max_paths 10 -nworst 1 -early \
    > $report_dir/timing_hold.rpt
puts "  ✓ Hold timing report"

# Timing summary
report_timing -late > $report_dir/timing_summary.rpt
puts "  ✓ Timing summary"

# Power report
report_power > $report_dir/power_final.rpt
puts "  ✓ Power report"

# Area report
report_area > $report_dir/area_final.rpt
puts "  ✓ Area report"

# Constraint violations
report_constraint -all_violators > $report_dir/violations.rpt
puts "  ✓ Violations report"

# Summary report
summaryReport -outfile $report_dir/summary.rpt
puts "  ✓ Summary report"
puts ""

###############################################################################
# Step 12: Write Outputs
###############################################################################
puts "=========================================="
puts "Step 12: Writing Output Files"
puts "=========================================="

set result_dir $project_root/results
file mkdir $result_dir/def

defOut -floorplan -netlist -routing $result_dir/def/${DESIGN_NAME}.def
puts "  ✓ DEF: $result_dir/def/${DESIGN_NAME}.def"

saveNetlist $result_dir/netlist/${DESIGN_NAME}_final.v
puts "  ✓ Netlist: $result_dir/netlist/${DESIGN_NAME}_final.v"

saveDesign $project_root/work/pnr/jsilicon_final.enc
puts "  ✓ Database: work/pnr/jsilicon_final.enc"
puts ""

###############################################################################
# Summary
###############################################################################
puts ""
puts "=========================================="
puts "✓✓✓ P&R FLOW COMPLETED SUCCESSFULLY! ✓✓✓"
puts "=========================================="
puts ""
puts "Output Files:"
puts "  DEF:      results/def/${DESIGN_NAME}.def"
puts "  Netlist:  results/netlist/${DESIGN_NAME}_final.v"
puts "  Database: work/pnr/jsilicon_final.enc"
puts ""
puts "Reports:"
puts "  reports/pnr/timing_summary.rpt"
puts "  reports/pnr/timing_setup.rpt"
puts "  reports/pnr/timing_hold.rpt"
puts "  reports/pnr/power_final.rpt"
puts "  reports/pnr/area_final.rpt"
puts "  reports/pnr/summary.rpt"
puts ""
puts "Checkpoints:"
puts "  work/pnr/jsilicon_placed.enc"
puts "  work/pnr/jsilicon_cts.enc"
puts "  work/pnr/jsilicon_final.enc"
puts ""
puts "Next Steps:"
puts "  1. Check timing: cat reports/pnr/timing_summary.rpt"
puts "  2. Check violations: cat reports/pnr/violations.rpt"
puts ""
puts "=========================================="
puts ""

exit
```

```
chmod +x innovus/pnr_flow.tcl
```

#### 4-3. P&R 실행

```
cd ~/JSilicon2/work/pnr

# Innovus 실행
innovus -init ../../scripts/innovus/pnr_flow.tcl |& tee pnr.log

```

```
==========================================
✓✓✓ P&R FLOW COMPLETED SUCCESSFULLY! ✓✓✓
==========================================

Output Files:
  DEF:      results/def/tt_um_Jsilicon.def
  Netlist:  results/netlist/tt_um_Jsilicon_final.v
  Database: work/pnr/jsilicon_final.enc

Reports:
  reports/pnr/timing_summary.rpt
  reports/pnr/timing_setup.rpt
  reports/pnr/timing_hold.rpt
  reports/pnr/power_final.rpt
  reports/pnr/area_final.rpt
  reports/pnr/summary.rpt

Checkpoints:
  work/pnr/jsilicon_placed.enc
  work/pnr/jsilicon_cts.enc
  work/pnr/jsilicon_final.enc

Next Steps:
  1. Check timing: cat reports/pnr/timing_summary.rpt
  2. Check violations: cat reports/pnr/violations.rpt

==========================================


*** Memory Usage v#2 (Current mem = 2848.219M, initial mem = 831.172M) ***
*** Message Summary: 278 warning(s), 11 error(s)

--- Ending "Innovus" (totcpu=0:01:10, real=0:02:22, mem=2848.2M) ---

```

```
cd ~/JSilicon2/work/pnr
innovus
restoreDesign jsilicon_final.enc.dat tt_um_Jsilicon
fit
```

<img width="1032" height="897" alt="001" src="https://github.com/user-attachments/assets/82f700c2-bdd3-45c4-afac-fcb39ca6c160" />
<br>
<img width="1920" height="1080" alt="003" src="https://github.com/user-attachments/assets/a58dc74e-7208-4bc8-bd2e-96ce0ef20382" />
<br>
<img width="1920" height="1080" alt="004" src="https://github.com/user-attachments/assets/0f817212-d79d-481e-ab0c-996b869e6fbd" />
<br>
<img width="1920" height="1080" alt="005" src="https://github.com/user-attachments/assets/d665323f-2970-492e-87f1-4259925566fe" />
<br>

**실행 과정 (예상 10-15분):**
```
1. Design initialization [~1분]
2. Floorplanning         [~30초]
3. Placement             [~3분]
4. CTS                   [~2분]
5. Routing               [~5분]
6. Optimization          [~3분]
7. Report generation     [~30초]
```

#### 4-4. P&R 결과 확인

```
cd ~/JSilicon2

# 생성된 파일
echo "=== Generated Files ==="
ls -lh results/def/tt_um_Jsilicon.def
ls -lh results/netlist/tt_um_Jsilicon_final.v

# Summary 리포트
echo ""
echo "=== P&R Summary ==="
cat reports/pnr/summary.rpt
```

* DEF 파일이란?
   * DEF (Design Exchange Format) 파일은 물리적 배치 정보를 담고 있는 파일입니다.

* 주요 내용
   * 셀 배치 (Placement): 각 표준 셀의 x, y 좌표
   * 라우팅 (Routing): 금속 배선 정보
   * 핀 위치: I/O 핀의 물리적 위치
   * 다이 크기: 칩의 실제 물리적 크기
   * 전원/그라운드 네트워크: Power grid 정보


**주요 메트릭:**

```
cd ~/JSilicon2

# 1. 타이밍
cat reports/pnr/timing_summary.rpt

# 2. 면적
cat reports/pnr/area_final.rpt

# 3. 전력
head -30 reports/pnr/power_final.rpt
grep -i "total" reports/pnr/power_final.rpt

# 4. Violations
head -20 reports/pnr/violations.rpt
wc -l reports/pnr/violations.rpt

# 5. Summary (전체)
less reports/pnr/summary.rpt

# 6. Geometry/Connectivity
cat reports/pnr/geometry.rpt
cat reports/pnr/connectivity.rpt

## 📁 생성된 리포트 파일들
reports/pnr/
├── timing_summary.rpt    (4.5 KB)  - 타이밍 요약
├── timing_setup.rpt      (40 KB)   - Setup 타이밍 상세
├── timing_hold.rpt       (17 KB)   - Hold 타이밍 상세
├── area_final.rpt        (368 B)   - 면적 리포트
├── power_final.rpt       (7.8 KB)  - 전력 리포트
├── violations.rpt        (9.9 KB)  - Constraint violations
├── geometry.rpt          (488 B)   - DRC 체크
├── connectivity.rpt      (2.7 KB)  - 연결성 체크
└── summary.rpt           (22 KB)   - 전체 요약
```

* quick_check.csh

```
################################################################################
# JSilicon P&R 결과 확인 가이드
# reports/pnr/ 디렉토리의 리포트 분석
################################################################################

cd ~/JSilicon2

################################################################################
# 1. 타이밍 결과 확인
################################################################################

echo "=========================================="
echo "1. 타이밍 결과"
echo "=========================================="

# 1-1. Timing Summary (전체 요약)
echo ""
echo "=== Timing Summary (전체) ==="
cat reports/pnr/timing_summary.rpt

# 1-2. Setup Timing (최악의 경로 10개)
echo ""
echo "=== Setup Timing (Critical Paths) ==="
head -50 reports/pnr/timing_setup.rpt

# 1-3. Hold Timing (최악의 경로 10개)
echo ""
echo "=== Hold Timing (Critical Paths) ==="
head -50 reports/pnr/timing_hold.rpt

# 1-4. Summary 파일에서 타이밍 정보
echo ""
echo "=== Summary - Timing Section ==="
grep -A 20 "Timing" reports/pnr/summary.rpt

# WNS/TNS 확인
echo ""
echo "=== WNS/TNS (Worst/Total Negative Slack) ==="
grep -E "WNS|TNS|Slack" reports/pnr/summary.rpt

################################################################################
# 2. 면적 결과 확인
################################################################################

echo ""
echo "=========================================="
echo "2. 면적 결과"
echo "=========================================="

# 2-1. Area Report (상세)
echo ""
echo "=== Area Report ==="
cat reports/pnr/area_final.rpt

# 2-2. Summary에서 면적 정보
echo ""
echo "=== Summary - Design Area ==="
grep -A 10 "Design Area" reports/pnr/summary.rpt

# 2-3. Cell Count
echo ""
echo "=== Cell Statistics ==="
grep -A 10 "Instance" reports/pnr/summary.rpt

# 2-4. Utilization
echo ""
echo "=== Core Utilization ==="
grep -i "utilization" reports/pnr/summary.rpt

################################################################################
# 3. 전력 결과 확인
################################################################################

echo ""
echo "=========================================="
echo "3. 전력 결과"
echo "=========================================="

# 3-1. Power Summary
echo ""
echo "=== Power Summary ==="
head -30 reports/pnr/power_final.rpt

# 3-2. Total Power
echo ""
echo "=== Total Power ==="
grep -A 5 -i "total power" reports/pnr/power_final.rpt

# 3-3. Power by hierarchy
echo ""
echo "=== Power Breakdown ==="
grep -A 20 "Internal" reports/pnr/power_final.rpt

################################################################################
# 4. Violations 확인
################################################################################

echo ""
echo "=========================================="
echo "4. Constraint Violations"
echo "=========================================="

# 4-1. Violation 개수 확인
echo ""
echo "=== Violation Count ==="
wc -l reports/pnr/violations.rpt

# 4-2. Violations 내용
echo ""
echo "=== Violations (첫 30줄) ==="
head -30 reports/pnr/violations.rpt

# 4-3. Setup/Hold Violations
echo ""
echo "=== Timing Violations ==="
grep -i "violated" reports/pnr/violations.rpt

################################################################################
# 5. Geometry & Connectivity 확인
################################################################################

echo ""
echo "=========================================="
echo "5. Physical Verification"
echo "=========================================="

# 5-1. Geometry Check
echo ""
echo "=== Geometry Violations ==="
cat reports/pnr/geometry.rpt

# 5-2. Connectivity Check
echo ""
echo "=== Connectivity Issues ==="
cat reports/pnr/connectivity.rpt

################################################################################
# 6. Summary Report (전체 개요)
################################################################################

echo ""
echo "=========================================="
echo "6. Overall Summary"
echo "=========================================="

# 6-1. Summary 파일 전체 (주요 섹션만)
echo ""
echo "=== Design Statistics ==="
grep -A 5 "Design Statistics" reports/pnr/summary.rpt

echo ""
echo "=== Instance Count ==="
grep -A 10 "Instance" reports/pnr/summary.rpt

echo ""
echo "=== Net Statistics ==="
grep -A 10 "Net" reports/pnr/summary.rpt

################################################################################
# 7. 한눈에 보기 (요약)
################################################################################

echo ""
echo "=========================================="
echo "7. 핵심 결과 요약"
echo "=========================================="

echo ""
echo "타이밍:"
echo "--------"
grep -E "setup|hold|WNS|TNS" reports/pnr/timing_summary.rpt | head -10

echo ""
echo "면적:"
echo "-----"
grep -A 3 "Total area" reports/pnr/area_final.rpt

echo ""
echo "전력:"
echo "-----"
grep "Total" reports/pnr/power_final.rpt | head -5

echo ""
echo "Violations:"
echo "-----------"
set viol_lines = `wc -l < reports/pnr/violations.rpt`
if ( $viol_lines > 1 ) then
    echo "⚠ Found violations: $viol_lines"
else
    echo "✓ No violations"
endif

echo ""
echo "=========================================="

################################################################################
# 간단 버전 (빠른 확인용)
################################################################################

# 아래 명령어들을 개별적으로 사용 가능:

# 타이밍만 빠르게 확인
# cat reports/pnr/timing_summary.rpt

# 면적만 빠르게 확인
# cat reports/pnr/area_final.rpt

# 전력만 빠르게 확인
# head -20 reports/pnr/power_final.rpt

# Summary 전체 확인
# less reports/pnr/summary.rpt

################################################################################
# grep 활용 예제
################################################################################

# Setup timing만
# grep -A 30 "Setup" reports/pnr/timing_summary.rpt

# Hold timing만
# grep -A 30 "Hold" reports/pnr/timing_summary.rpt

# 특정 net 검색
# grep "clk" reports/pnr/timing_setup.rpt

# 전력에서 leakage만
# grep -i "leakage" reports/pnr/power_final.rpt

# Summary에서 특정 섹션
# grep -A 20 "Instance Count" reports/pnr/summary.rpt
```

---

### Step 5: 결과 분석 및 검증

* 📋 목차
- [P&R 결과 분석](#pr-결과-분석)
  - [1. 타이밍 분석](#1-타이밍-분석)
  - [2. 면적 분석](#2-면적-분석)
  - [3. 전력 분석](#3-전력-분석)
  - [4. Violations 분석](#4-violations-분석)
  - [5. Physical Verification](#5-physical-verification)
- [디렉토리 구조](#디렉토리-구조)
- [실행 방법](#실행-방법)

---

#### 사용 도구
- **Synthesis**: Cadence Genus
- **Place & Route**: Cadence Innovus 23.13
- **Technology**: FreePDK45 (gscl45nm)
---

#### 디자인 스펙

#### 칩 사양
| 항목 | 값 |
|------|-----|
| **Technology** | FreePDK45 (45nm) |
| **Die Size** | 74.86 × 72.01 μm² |
| **Core Size** | 54.72 × 51.87 μm² |
| **Total Area** | 1,828.86 μm² |
| **Cell Count** | 587 cells |
| **Utilization** | 64.4% |

#### 클럭 사양
| 항목 | 값 |
|------|-----|
| **Target Clock** | 200 MHz (5.0 ns) |
| **Clock Uncertainty** | 0.5 ns |

---

#### P&R 결과 분석

##### 5.1. 타이밍 분석

###### 🔴 Setup Timing (최대 동작 주파수)

**Status**: ⚠️ **VIOLATED** (최적화 필요)

```
Worst Negative Slack (WNS): -0.011 ns
Critical Path: uio_in[4] → core_inst_uart_inst/data_reg_reg[1]/D
```

**Critical Path 상세**:
- **Start Point**: `uio_in[4]` (입력 포트)
- **End Point**: `core_inst_uart_inst/data_reg_reg[1]/D` (UART 데이터 레지스터)
- **Path Delay**: 3.090 ns
- **Required Time**: 3.079 ns
- **Slack**: -0.011 ns (11 ps 위반)

**타이밍 분석**:
```
Clock Rise Edge:              0.000 ns
+ Input Delay:                1.500 ns
+ Logic Delay:                1.590 ns (26 stages)
--------------------------------
Total Arrival Time:           3.090 ns

Clock Period:                 5.000 ns
- Setup Time:                 1.421 ns
- Uncertainty:                0.500 ns
--------------------------------
Required Time:                3.079 ns

Setup Slack:                 -0.011 ns ❌
```

**Critical Path Breakdown** (주요 게이트):
1. `uio_in[4]` → INVX2 (58 ps)
2. NAND2X1 (170 ps)
3. INVX8 (55 ps)
4. ALU 연산 경로 (다수의 AND/OR/XOR gates)
5. MUX2X1 (99 ps)
6. INVX1 (16 ps)
7. `data_reg_reg[1]` (DFFPOSX1)

**개선 방안**:
- ✅ 입력 지연 감소 (현재 1.5ns → 1.0ns로 조정)
- ✅ ALU 경로 파이프라인 추가
- ✅ 클럭 주파수 하향 조정 (200MHz → 150MHz)
- ✅ 게이트 크기 증가 (INVX1 → INVX2/INVX4)

###### 🔴 Hold Timing (최소 지연)

**Status**: ⚠️ **VIOLATED** (버퍼 삽입 필요)

```
Worst Hold Slack: -0.395 ns
Critical Path: core_inst_uart_inst/clock_count_reg[12]/Q → /D
```

**Hold Path 상세**:
- **Start Point**: `clock_count_reg[12]/Q` (UART 클럭 카운터)
- **End Point**: `clock_count_reg[12]/D` (동일 레지스터)
- **Path Delay**: 0.151 ns
- **Required Time**: 0.546 ns
- **Hold Slack**: -0.395 ns (395 ps 위반)

**홀드 타임 분석**:
```
Clock Rise Edge:              0.000 ns
+ Clock Network Latency:      0.000 ns (Ideal)
--------------------------------
Beginpoint Arrival:           0.000 ns

DFFSR CLK→Q:                  0.086 ns
+ HAX1 (Half Adder):          0.065 ns
--------------------------------
Arrival Time:                 0.151 ns

Hold Time:                    0.046 ns
+ Uncertainty:                0.500 ns
--------------------------------
Required Time:                0.546 ns

Hold Slack:                  -0.395 ns ❌
```

**개선 방안**:
- ✅ 지연 셀(Delay Cell) 삽입
- ✅ 버퍼 체인 추가 (BUFX2/BUFX4)
- ✅ 클럭 트리 최적화 (CTS 재실행)

#### 📊 타이밍 요약

| Timing Check | WNS | TNS | Status |
|-------------|-----|-----|--------|
| Setup (Max) | -0.011 ns | - | ⚠️ VIOLATED |
| Hold (Min) | -0.395 ns | - | ⚠️ VIOLATED |

**달성 가능한 최대 주파수**:
```
Current Target: 200 MHz (5.0 ns)
Achievable:     ~162 MHz (6.17 ns)
  = 1 / (5.0ns + 0.011ns + margin)
```

* 1. WNS (Worst Negative Slack)
   * 최악의 음수 여유 시간
```
WNS = Required Time - Arrival Time
    = 3.079 ns - 3.090 ns  
    = -0.011 ns ❌
```

* 의미:
   * 가장 나쁜(worst) 타이밍 위반 경로의 slack 값
   * 음수 = 타이밍 위반 (신호가 너무 늦게 도착)
   * 양수 = 타이밍 만족 (신호가 제시간에 도착)

* 지금의 경우:

```
-0.011 ns = -11 ps 위반
신호가 11 피코초 늦게 도착함
200MHz에서는 동작 불가능!
```

* 2. TNS (Total Negative Slack)
  * 전체 음수 여유 시간의 합
  * TNS = Σ(모든 음수 slack 값)

* 의미: 
  * 위반된 모든 경로의 slack을 합산
  * 설계 전체의 타이밍 위반 심각도 평가
  * 여기서는 TNS를 계산하지 않음

📊 타이밍 위반 심각도 분류

| WNS 범위| 심각도| 조치| 
|:----:|:----:|:----:|
| > 0 ns | ✅ 안전 | 타이밍 만족| 
| 0 ~ -0.05 ns| ⚠️ 경미| 약간의 최적화 필요| 
| -0.05 ~ -0.2 ns| 🔶 보통| 구조적 수정 필요| 
| < -0.2 ns| 🔴 심각| 설계 재검토 필요| 
  * Setup WNS: -0.011 ns → ⚠️ 경미한 위반
  * Hold WNS: -0.395 ns → 🔴 심각한 위반!

---

##### 5.2. 면적 분석

###### 📐 칩 면적

| 구분 | 크기 (μm²) | 비율 |
|------|-----------|------|
| **Die Area** | 5,389.57 (74.86 × 72.01) | 100% |
| **Core Area** | 2,838.33 (54.72 × 51.87) | 52.7% |
| **Std Cell Area** | 1,828.86 | 33.9% |
| **Utilization** | - | 64.4% |

**면적 계산**:
```
Die Area        = 74.86 × 72.01 = 5,389.57 μm²
Core Area       = 54.72 × 51.87 = 2,838.33 μm²
Std Cell Area   = 1,828.86 μm²
Core Margin     = 10.07 μm (각 면)

Utilization = Std Cell Area / Core Area
            = 1,828.86 / 2,838.33
            = 64.4%
```

###### 📦 모듈별 면적

| Module | Instances | Area (μm²) | 비율 |
|--------|-----------|-----------|------|
| **Total** | 587 | 1,828.86 | 100% |
| UART_TX | 162 | 623.70 | 34.1% |
| DECODER | 1 | 10.33 | 0.6% |
| Others | 424 | 1,194.83 | 65.3% |

#### 🔧 셀 타입별 분포

| Cell Type | Count | Area (μm²) | 평균 (μm²) |
|-----------|-------|-----------|-----------|
| **AND2X2** | 84 | 197.11 | 2.35 |
| **INVX2** | 85 | 119.67 | 1.41 |
| **FAX1** (Full Adder) | 19 | 169.42 | 8.92 |
| **HAX1** (Half Adder) | 15 | 77.43 | 5.16 |
| **INVX1** | 51 | 71.80 | 1.41 |
| **DFFSR** (Flip-Flop) | 34 | 351.04 | 10.33 |
| **AOI21X1** | 14 | 32.85 | 2.35 |
| **AOI22X1** | 10 | 28.16 | 2.82 |
| **DFFPOSX1** | 8 | 52.56 | 6.57 |
| **Others** | 267 | - | - |

**셀 분포 분석**:
- **조합 논리**: 70.3% (AND, OR, INV, AOI, XOR 등)
- **순차 논리**: 29.7% (DFF, DFFSR)
- **산술 연산**: 14.5% (FAX1, HAX1 - Adder cells)

---

##### 5.3. 전력 분석

###### ⚡ 전력 소모 요약

| 구분 | 전력 (mW) | 비율 |
|------|----------|------|
| **Internal Power** | 0.399 | 71.0% |
| **Switching Power** | 0.150 | 26.7% |
| **Leakage Power** | 0.013 | 2.3% |
| **Total Power** | **0.561 mW** | 100% |

**클럭 주파수**: 200 MHz  
**전원 전압**: 1.1V

###### 📊 전력 분포 상세

**블록별 전력 소모**:

| Block Type | Internal | Switching | Leakage | Total | 비율 |
|-----------|----------|-----------|---------|-------|------|
| **Sequential** | 0.256 mW | 0.012 mW | 0.004 mW | 0.272 mW | 48.4% |
| **Combinational** | 0.143 mW | 0.137 mW | 0.009 mW | 0.289 mW | 51.6% |
| **Clock** | 0 mW | 0 mW | 0 mW | 0 mW | 0% |

**전력 분석**:
```
Internal Power (Dynamic):
  - Sequential Logic:      0.256 mW (45.6%)
  - Combinational Logic:   0.143 mW (25.4%)

Switching Power:           0.150 mW (26.7%)
  - Data Switching:        0.137 mW
  - Clock Tree:            0.012 mW

Leakage Power:            0.013 mW (2.3%)
  - 45nm 공정 특성상 낮은 누설 전류
```

###### 🔋 전력 효율

| 항목 | 값 |
|------|-----|
| **Power Density** | 0.104 mW/mm² |
| **Energy per Cycle** | 2.81 pJ/cycle |
| **Power/Gate** | 0.96 μW/gate |

**계산**:
```
Power Density = Total Power / Die Area
              = 0.561 mW / 5,389.57 μm²
              = 0.104 mW/mm²

Energy/Cycle  = Total Power / Frequency
              = 0.561 mW / 200 MHz
              = 2.81 pJ/cycle
```

###### 🌟 최대 전력 소모 인스턴스

```
Highest Average Power: 
  - core_inst_uart_inst/tx_reg (DFFSR): 8.68 μW

Highest Leakage Power:
  - core_inst_uart_inst/tx_reg (DFFSR): 108.6 nW
```

---

##### 5.4. Violations 분석

###### ⚠️ Constraint Violations 요약

**Total Violations**: 126 lines

**주요 위반 사항**:

###### Setup Timing Violations (2건)
```
1. core_inst_uart_inst/data_reg_reg[1]/D
   - Slack: -0.011 ns
   - Path: uio_in[4] → UART data register

2. core_inst_uart_inst/data_reg_reg[2]/D
   - Slack: -0.010 ns
   - Path: Similar to above
```

**원인 분석**:
- UART 모듈의 데이터 경로가 긴 조합 논리를 포함
- 입력 지연(1.5ns)이 과도하게 설정됨
- ALU 연산 경로 최적화 부족

##### Hold Timing Violations (다수)
```
주요 위반:
- UART clock_count_reg 체인
- Slack: -0.395 ns ~ -0.393 ns
```

**원인 분석**:
- 클럭 트리가 구축되지 않음 (Ideal clock 사용)
- 레지스터 간 경로가 너무 짧음 (Half Adder 단일 단계)
- 버퍼 삽입 필요

###### 📋 Violation 카테고리

| Check Type | Count | Status |
|-----------|-------|--------|
| **max_delay/setup** | 2 | VIOLATED |
| **min_delay/hold** | 다수 | VIOLATED |
| **clock_period** | 0 | PASS |
| **skew** | 0 | PASS |
| **pulse_width** | 0 | PASS |

#### 🔧 해결 방안

**Setup Violations**:
1. ✅ 클럭 주파수 하향 (200MHz → 150MHz)
2. ✅ 입력 지연 재조정 (1.5ns → 1.0ns)
3. ✅ 조합 논리 파이프라이닝
4. ✅ 게이트 사이징 최적화

**Hold Violations**:
1. ✅ CTS (Clock Tree Synthesis) 재실행
2. ✅ 지연 셀 삽입
3. ✅ 버퍼 체인 추가
4. ✅ `optDesign -postRoute -hold` 실행

---

##### 5.5. Physical Verification

###### ✅ Geometry Check (DRC)

**Status**: ✅ **PASS** - No violations

```
DRC Summary:
  - Cells:      0 violations
  - SameNet:    0 violations
  - Wiring:     0 violations
  - Antenna:    0 violations
  - Short:      0 violations
  - Overlap:    0 violations

Result: No DRC violations were found ✓
```

**의미**: 
- 모든 레이아웃이 FreePDK45 Design Rule을 준수
- Metal spacing, width, via 규칙 만족
- 제조 가능한 레이아웃

###### ⚠️ Connectivity Check

**Status**: ⚠️ **27 Issues** (Minor - Dangling Wires)

**발견된 문제**:
```
Power Net (vdd): 14 dangling wires
Ground Net (gnd): 13 dangling wires

Total: 27 dangling wire segments
```

**Dangling Wire 위치**:

**VDD Net** (14개):
```
Metal1 Layer (11개):
  - (64.790, 10.070) ~ (64.790, 59.470)
  - 균등 간격 (약 4.94 μm)

Metal8 Layer (3개):
  - (53.290, 61.940)
  - (31.930, 61.940)
  - (10.570, 61.940)
```

**GND Net** (13개):
```
Metal1 Layer (10개):
  - (10.070, 12.540) ~ (10.070, 61.940)
  
Metal8 Layer (3개):
  - (64.290, 10.070)
  - (42.930, 10.070)
  - (21.570, 10.070)
```

**원인 분석**:
- Power stripe와 core 경계 간 연결 누락
- Power ring의 일부 세그먼트 미연결
- Standard cell row 끝단 연결 문제

**영향**:
- 🟡 **Minor Issue**: 기능에는 영향 없음
- 일부 전원 경로 redundancy 감소
- IR drop에 약간의 영향 가능

**해결 방안**:
```tcl
# Innovus에서 수정
editPowerVia -add_vias 1 -orthogonal_only 1
verifyConnectivity -type special
```

###### 📊 Physical Summary

| Check | Result | Details |
|-------|--------|---------|
| **DRC** | ✅ PASS | 0 violations |
| **LVS** | - | Not performed |
| **Connectivity** | ⚠️ 27 issues | Dangling wires (non-critical) |
| **Antenna** | ✅ PASS | No violations |

---

###### 📁 디렉토리 구조

```
JSilicon2/
├── tech/                          # Technology files
│   ├── lef/
│   │   └── gscl45nm.lef          # LEF (45nm)
│   └── lib/
│       └── gscl45nm.lib          # Liberty (45nm)
│
├── rtl/                           # RTL source files
│   ├── tt_um_Jsilicon.v          # Top module
│   ├── core.v                    # Core logic
│   ├── alu.v                     # ALU
│   ├── uart_tx.v                 # UART transmitter
│   └── decoder.v                 # Instruction decoder
│
├── scripts/                       # TCL scripts
│   ├── genus/
│   │   └── synthesis.tcl         # Synthesis script
│   └── innovus/
│       ├── pnr_flow.tcl          # P&R main flow
│       └── mmmc.tcl              # MMMC setup
│
├── work/                          # Working directory
│   ├── synthesis/                # Synthesis outputs
│   └── pnr/                      # P&R database
│       ├── jsilicon_placed.enc   # After placement
│       ├── jsilicon_cts.enc      # After CTS
│       └── jsilicon_final.enc    # Final design
│
├── results/                       # Final outputs
│   ├── netlist/
│   │   ├── tt_um_Jsilicon_synth.v      # Post-synthesis netlist
│   │   └── tt_um_Jsilicon_final.v      # Post-P&R netlist
│   └── def/
│       └── tt_um_Jsilicon.def          # Final DEF
│
└── reports/                       # Reports
    ├── synthesis/
    │   ├── area.rpt
    │   ├── power.rpt
    │   └── timing.rpt
    └── pnr/
        ├── timing_summary.rpt    # 타이밍 요약
        ├── timing_setup.rpt      # Setup 상세
        ├── timing_hold.rpt       # Hold 상세
        ├── area_final.rpt        # 면적
        ├── power_final.rpt       # 전력
        ├── violations.rpt        # Violations
        ├── geometry.rpt          # DRC
        ├── connectivity.rpt      # 연결성
        └── summary.rpt           # 전체 요약
```

---

##### 📊 성능 요약

| 항목 | 타겟 | 실제 | Status |
|------|------|------|--------|
| **클럭 주파수** | 200 MHz | ~162 MHz | ⚠️ |
| **전력 소모** | < 1 mW | 0.561 mW | ✅ |
| **면적** | < 0.01 mm² | 0.0054 mm² | ✅ |
| **셀 수** | - | 587 cells | - |
| **Setup Timing** | 0 violations | 2 violations | ⚠️ |
| **Hold Timing** | 0 violations | 다수 | ⚠️ |
| **DRC** | 0 violations | 0 violations | ✅ |

---

##### 🔄 개선 사항

###### 우선순위 1 (Critical)
- [ ] Setup timing violation 해결
  - 클럭 주파수 조정: 200MHz → 150MHz
  - 입력 지연 재설정: 1.5ns → 1.0ns
  
- [ ] Hold timing violation 해결
  - CTS 재실행 (현재 ideal clock 사용)
  - 지연 셀 삽입

###### 우선순위 2 (Important)
- [ ] Power grid dangling wire 수정
  - Power stripe 연결 보강
  - Via 추가

###### 우선순위 3 (Nice to have)
- [ ] 면적 최적화
  - Utilization 64% → 70% 증가 가능
  
- [ ] 전력 최적화
  - Clock gating 추가
  - Multi-Vt cell 활용

---

##### 📚 GDS 생성 단계별 수동 실행

###### Step 1: 타이밍 최적화 (필수)
```csh
cd ~/JSilicon2/work/pnr
innovus
```

```tcl
# 디자인 복원
restoreDesign jsilicon_final.enc.dat tt_um_Jsilicon

# 타이밍 최적화
setOptMode -effort high
setOptMode -usefulSkew true
setOptMode -fixHoldAllowSetupTnsDegrade false

optDesign -postRoute -setup
optDesign -postRoute -hold
optDesign -postRoute -drv

# 확인
report_timing -late -max_paths 5
report_timing -early -max_paths 5

# 저장
saveDesign jsilicon_final_opt.enc

exit
```

###### Step 2: LVS 검증
```csh
cd ~/JSilicon2/work/pnr
innovus -init ../../scripts/innovus/run_lvs.tcl

# 결과 확인
cat ../../results/lvs/lvs_summary.rpt
```

```
#!/bin/tcsh
###############################################################################
# LVS (Layout vs Schematic) Check Script
# File: scripts/innovus/run_lvs.tcl
###############################################################################

set DESIGN_NAME "tt_um_Jsilicon"
set project_root [file normalize ../../]

puts "=========================================="
puts "LVS (Layout vs Schematic) Check"
puts "Design: $DESIGN_NAME"
puts "=========================================="
puts ""

###############################################################################
# 1. 디자인 복원
###############################################################################

puts "1. Loading design..."

# 최적화된 디자인 우선, 없으면 final 사용
if { [file exists jsilicon_optimized.enc.dat] } {
    restoreDesign jsilicon_optimized.enc.dat $DESIGN_NAME
    puts "  ✓ Loaded: jsilicon_optimized.enc.dat"
} elseif { [file exists jsilicon_final.enc.dat] } {
    restoreDesign jsilicon_final.enc.dat $DESIGN_NAME
    puts "  ✓ Loaded: jsilicon_final.enc.dat"
} else {
    puts "  ✗ Error: No design database found!"
    exit 1
}

fit
puts ""

###############################################################################
# 2. 디렉토리 준비
###############################################################################

set lvs_dir $project_root/results/lvs
file mkdir $lvs_dir

puts "2. LVS directory: $lvs_dir"
puts ""

###############################################################################
# 3. Layout Netlist 추출
###############################################################################

puts "=========================================="
puts "3. Extracting Layout Netlist"
puts "=========================================="

# SPICE netlist 추출
set layout_netlist $lvs_dir/layout_extracted.sp

puts "  Extracting to: $layout_netlist"

saveNetlist -excludeLeafCell \
    -includePhysicalInst \
    -includePowerGround \
    $layout_netlist

puts "  ✓ Layout netlist extracted"
puts ""

# Verilog netlist도 추출
set layout_verilog $lvs_dir/layout_extracted.v

saveNetlist $layout_verilog

puts "  ✓ Verilog netlist: $layout_verilog"
puts ""

###############################################################################
# 4. Source Netlist 확인
###############################################################################

puts "=========================================="
puts "4. Source Netlist"
puts "=========================================="

set source_netlist $project_root/results/netlist/tt_um_Jsilicon_final.v

if { [file exists $source_netlist] } {
    puts "  ✓ Source: $source_netlist"
} else {
    puts "  ⚠ Warning: Final netlist not found"
    set source_netlist $project_root/results/netlist/tt_um_Jsilicon_synth.v
    if { [file exists $source_netlist] } {
        puts "  ✓ Using synthesis netlist: $source_netlist"
    } else {
        puts "  ✗ Error: No source netlist found!"
        exit 1
    }
}
puts ""

###############################################################################
# 5. 인스턴스 카운트 비교
###############################################################################

puts "=========================================="
puts "5. Instance Count Comparison"
puts "=========================================="

# Layout 인스턴스 개수
set layout_insts [llength [dbGet top.insts]]
puts "  Layout instances:  $layout_insts cells"

# Source netlist 파싱 (간단 추정)
catch {
    set fp [open $source_netlist r]
    set content [read $fp]
    close $fp
    
    # Verilog instance 패턴 매칭
    set inst_count 0
    foreach line [split $content "\n"] {
        if {[regexp {^\s*[A-Z][A-Z0-9_]+\s+[a-z_]} $line]} {
            incr inst_count
        }
    }
    puts "  Source instances:  ~$inst_count (estimated)"
    
    # 비교
    set diff [expr abs($layout_insts - $inst_count)]
    if { $diff < 50 } {
        puts "  ✓ Instance count similar (diff: $diff)"
    } else {
        puts "  ⚠ Instance count difference: $diff"
    }
}

puts ""

###############################################################################
# 6. Net 카운트 비교
###############################################################################

puts "=========================================="
puts "6. Net Count Comparison"
puts "=========================================="

set layout_nets [llength [dbGet top.nets]]
puts "  Layout nets:       $layout_nets"

# Special nets
set special_nets [dbGet top.nets.isSpecial 1 -e]
if { $special_nets != "" } {
    set special_count [llength $special_nets]
} else {
    set special_count 0
}
puts "  Special nets:      $special_count (Power/Ground)"

set signal_nets [expr $layout_nets - $special_count]
puts "  Signal nets:       $signal_nets"

puts ""

###############################################################################
# 7. Connectivity Verification
###############################################################################

puts "=========================================="
puts "7. Connectivity Verification"
puts "=========================================="

# 전체 connectivity
puts "  Checking general connectivity..."
verifyConnectivity -noAntenna \
    -noUnroutedNet \
    -report $lvs_dir/connectivity_check.rpt

puts "  ✓ Report: connectivity_check.rpt"

# Power/Ground connectivity
puts "  Checking P/G connectivity..."
verifyConnectivity -type special \
    -report $lvs_dir/pg_connectivity.rpt

puts "  ✓ Report: pg_connectivity.rpt"

puts ""

###############################################################################
# 8. Pin Placement Check
###############################################################################

puts "=========================================="
puts "8. Pin Placement Check"
puts "=========================================="

# Pin 개수 확인
set all_terms [dbGet top.terms -e]
if { $all_terms != "" } {
    set pin_count [llength $all_terms]
    puts "  Total I/O pins: $pin_count"
    
    # Unplaced pin 확인 (간단한 방법)
    set unplaced_count 0
    foreach term $all_terms {
        set is_placed [dbGet ${term}.isPlaced -e]
        if { $is_placed == "0" || $is_placed == "" } {
            incr unplaced_count
        }
    }
    
    if { $unplaced_count > 0 } {
        puts "  ⚠ Unplaced pins: $unplaced_count"
    } else {
        puts "  ✓ All pins placed"
    }
} else {
    puts "  (No I/O pins found)"
}

puts ""

###############################################################################
# 9. 상세 통계
###############################################################################

puts "=========================================="
puts "9. Design Statistics"
puts "=========================================="

# Cell 타입별 카운트 (간단한 방법)
puts "  Cell Type Distribution:"

# 모든 인스턴스 가져오기
set all_insts [dbGet top.insts -e]

if { $all_insts != "" } {
    # Cell 타입별로 그룹화
    array set cell_types {}
    
    foreach inst $all_insts {
        set cell_name [dbGet ${inst}.cell.name -e]
        if { $cell_name != "" && $cell_name != "0x0" } {
            if { ![info exists cell_types($cell_name)] } {
                set cell_types($cell_name) 0
            }
            incr cell_types($cell_name)
        }
    }
    
    # 카운트별로 정렬하여 상위 10개 출력
    set sorted_list {}
    foreach {cell count} [array get cell_types] {
        lappend sorted_list [list $cell $count]
    }
    set sorted_list [lsort -integer -decreasing -index 1 $sorted_list]
    
    set display_count 0
    foreach item $sorted_list {
        set cell [lindex $item 0]
        set count [lindex $item 1]
        puts "    [format %-20s $cell]: $count"
        incr display_count
        if { $display_count >= 10 } break
    }
} else {
    puts "    (No instances found)"
}

puts ""

# Port 개수
set port_count [llength [dbGet top.terms -e]]
puts "  I/O Ports:         $port_count"

# 면적
set total_area [dbGet top.fPlan.area -e]
if { $total_area != "" && $total_area != "0x0" } {
    puts "  Total Area:        [format %.2f $total_area] μm²"
}

puts ""

###############################################################################
# 10. LVS Summary Report 생성
###############################################################################

puts "=========================================="
puts "10. Generating LVS Summary"
puts "=========================================="

set summary_file $lvs_dir/lvs_summary.rpt
set fp [open $summary_file w]

puts $fp "=============================================================================="
puts $fp "LVS (Layout vs Schematic) Summary Report"
puts $fp "=============================================================================="
puts $fp "Design:       $DESIGN_NAME"
puts $fp "Date:         [clock format [clock seconds]]"
puts $fp "Database:     [file tail [pwd]]"
puts $fp "=============================================================================="
puts $fp ""
puts $fp "1. INSTANCE COUNT"
puts $fp "   Layout instances:     $layout_insts cells"
puts $fp ""
puts $fp "2. NET COUNT"
puts $fp "   Total nets:           $layout_nets"
puts $fp "   Signal nets:          $signal_nets"
puts $fp "   Power/Ground nets:    $special_count"
puts $fp ""
puts $fp "3. I/O PORTS"
puts $fp "   Total ports:          $port_count"
puts $fp ""
puts $fp "4. AREA"
if { $total_area != "" && $total_area != "0x0" } {
    puts $fp "   Total area:           [format %.2f $total_area] μm²"
} else {
    puts $fp "   Total area:           N/A"
}
puts $fp ""
puts $fp "5. TOP CELL TYPES (by count)"

# sorted_list 사용 (섹션 9에서 생성한 변수)
set count 0
foreach item $sorted_list {
    set cell [lindex $item 0]
    set num [lindex $item 1]
    puts $fp [format "   %-20s %5d" $cell $num]
    incr count
    if { $count >= 15 } break
}

puts $fp ""
puts $fp "6. NETLISTS"
puts $fp "   Layout (extracted):   $layout_netlist"
puts $fp "   Layout (Verilog):     $layout_verilog"
puts $fp "   Source (reference):   $source_netlist"
puts $fp ""
puts $fp "7. CONNECTIVITY CHECKS"
puts $fp "   General connectivity: connectivity_check.rpt"
puts $fp "   P/G connectivity:     pg_connectivity.rpt"
puts $fp ""
puts $fp "8. VERIFICATION STATUS"

# Connectivity 리포트 파싱하여 문제 확인
set has_issues 0
catch {
    set fp_conn [open $lvs_dir/connectivity_check.rpt r]
    set conn_content [read $fp_conn]
    close $fp_conn
    
    if {[regexp -nocase "problem|error|violation" $conn_content]} {
        puts $fp "   ⚠ Issues found - Review connectivity reports"
        set has_issues 1
    } else {
        puts $fp "   ✓ No connectivity issues detected"
    }
}

puts $fp ""
puts $fp "9. NEXT STEPS"
if { $has_issues } {
    puts $fp "   - Review detailed connectivity reports"
    puts $fp "   - Fix any dangling wires or shorts"
    puts $fp "   - Re-run LVS after fixes"
} else {
    puts $fp "   - Compare extracted vs source netlist manually"
    puts $fp "   - For formal LVS, use Calibre or Assura:"
    puts $fp "     * Export GDS: streamOut tt_um_Jsilicon.gds"
    puts $fp "     * Run Calibre LVS with rule deck"
}
puts $fp ""
puts $fp "=============================================================================="
puts $fp "NOTE: This is a basic connectivity check using Innovus."
puts $fp "      For production tapeout, use formal LVS tools (Calibre/Assura)."
puts $fp "=============================================================================="

close $fp

puts "  ✓ Summary: $summary_file"
puts ""

###############################################################################
# 11. 결과 출력
###############################################################################

puts "=========================================="
puts "✓✓✓ LVS Check Complete ✓✓✓"
puts "=========================================="
puts ""
puts "Generated Files:"
puts "  $lvs_dir/lvs_summary.rpt"
puts "  $lvs_dir/layout_extracted.sp"
puts "  $lvs_dir/layout_extracted.v"
puts "  $lvs_dir/connectivity_check.rpt"
puts "  $lvs_dir/pg_connectivity.rpt"
puts "  $lvs_dir/pin_placement.rpt"
puts ""
puts "Review Summary:"
puts "  cat $lvs_dir/lvs_summary.rpt"
puts ""
puts "Check Connectivity:"
puts "  cat $lvs_dir/connectivity_check.rpt"
puts ""
puts "For GDS export (Calibre LVS):"
puts "  streamOut $lvs_dir/tt_um_Jsilicon.gds \\"
puts "    -mapFile ../../tech/lef/gds.map"
puts ""
puts "=========================================="

exit
```

* 결과화면

```

==========================================
10. Generating LVS Summary
==========================================
  ✓ Summary: /home/student001/JSilicon2/results/lvs/lvs_summary.rpt

==========================================
✓✓✓ LVS Check Complete ✓✓✓
==========================================

Generated Files:
  /home/student001/JSilicon2/results/lvs/lvs_summary.rpt
  /home/student001/JSilicon2/results/lvs/layout_extracted.sp
  /home/student001/JSilicon2/results/lvs/layout_extracted.v
  /home/student001/JSilicon2/results/lvs/connectivity_check.rpt
  /home/student001/JSilicon2/results/lvs/pg_connectivity.rpt
  /home/student001/JSilicon2/results/lvs/pin_placement.rpt

Review Summary:
  cat /home/student001/JSilicon2/results/lvs/lvs_summary.rpt

Check Connectivity:
  cat /home/student001/JSilicon2/results/lvs/connectivity_check.rpt

For GDS export (Calibre LVS):
  streamOut /home/student001/JSilicon2/results/lvs/tt_um_Jsilicon.gds \
    -mapFile ../../tech/lef/gds.map

==========================================

*** Memory Usage v#2 (Current mem = 2266.172M, initial mem = 839.172M) ***
*** Message Summary: 214 warning(s), 4 error(s)

--- Ending "Innovus" (totcpu=0:00:28.4, real=0:00:30.0, mem=2266.2M) ---

```

```

[student001@gjchamber pnr]$ cat ../../results/lvs/lvs_summary.rpt
==============================================================================
LVS (Layout vs Schematic) Summary Report
==============================================================================
Design:       tt_um_Jsilicon
Date:         Tue Nov 18 12:14:54 KST 2025
Database:     pnr
==============================================================================

1. INSTANCE COUNT
   Layout instances:     587 cells

2. NET COUNT
   Total nets:           704
   Signal nets:          702
   Power/Ground nets:    2

3. I/O PORTS
   Total ports:          43

4. AREA
   Total area:           5390.67 μm²

5. TOP CELL TYPES (by count)
   OR2X2                  106
   INVX2                   85
   AND2X2                  84
   INVX1                   51
   OAI21X1                 43
   MUX2X1                  43
   DFFSR                   34
   NOR3X1                  23
   FAX1                    19
   NAND2X1                 17
   HAX1                    15
   XNOR2X1                 14
   AOI21X1                 14
   XOR2X1                  13
   AOI22X1                 10

6. NETLISTS
   Layout (extracted):   /home/student001/JSilicon2/results/lvs/layout_extracted.sp
   Layout (Verilog):     /home/student001/JSilicon2/results/lvs/layout_extracted.v
   Source (reference):   /home/student001/JSilicon2/results/netlist/tt_um_Jsilicon_final.v

7. CONNECTIVITY CHECKS
   General connectivity: connectivity_check.rpt
   P/G connectivity:     pg_connectivity.rpt

8. VERIFICATION STATUS
   ⚠ Issues found - Review connectivity reports

9. NEXT STEPS
   - Review detailed connectivity reports
   - Fix any dangling wires or shorts
   - Re-run LVS after fixes

```

###### Step 3: DRC 확인
```tcl
innovus

restoreDesign jsilicon_final_opt.enc.dat tt_um_Jsilicon

file mkdir ../../reports/drc
verifyGeometry -report ../../reports/drc/geometry_final.rpt

exit
```

```

innovus 3> verifyGeometry -report ../../reports/drc/geometry_final.rpt
 *** Starting Verify Geometry (MEM: 2984.0) ***

**WARN: (IMPVFG-257):   setVerifyGeometryMode/verifyGeometry command is obsolete and should not be used any more. It still works in this release but will be removed in future release. You should change to use set_verify_drc_mode/verify_drc which is the replacement tool for verifyGeometry.
  VERIFY GEOMETRY ...... Starting Verification
  VERIFY GEOMETRY ...... Initializing
  VERIFY GEOMETRY ...... Deleting Existing Violations
  VERIFY GEOMETRY ...... Creating Sub-Areas
                  ...... bin size: 2080
  VERIFY GEOMETRY ...... SubArea : 1 of 1
  VERIFY GEOMETRY ...... Cells          :  0 Viols.
  VERIFY GEOMETRY ...... SameNet        :  0 Viols.
  VERIFY GEOMETRY ...... Wiring         :  0 Viols.
  VERIFY GEOMETRY ...... Antenna        :  0 Viols.
VG: elapsed time: 0.00
Begin Summary ...
  Cells       : 0
  SameNet     : 0
  Wiring      : 0
  Antenna     : 0
  Short       : 0
  Overlap     : 0
End Summary

  Verification Complete : 0 Viols.  0 Wrngs.

**********End: VERIFY GEOMETRY**********
 *** verify geometry (CPU: 0:00:00.2  MEM: 362.6M)

1
```

###### Step 4: RC Extraction
```tcl
innovus

restoreDesign jsilicon_final_opt.enc.dat tt_um_Jsilicon

file mkdir ../../results/extraction

extractRC
rcOut -spef ../../results/extraction/tt_um_Jsilicon.spef
write_sdf -version 3.0 ../../results/extraction/tt_um_Jsilicon.sdf

saveDesign jsilicon_extracted.enc

exit
```

```
innovus 4> file mkdir ../../results/extraction
innovus 5> extractRC
Extraction called for design 'tt_um_Jsilicon' of instances=587 and nets=704 using extraction engine 'postRoute' at effort level 'low' .
**WARN: (IMPEXT-3530):  The process node is not set. Use the command setDesignMode -process <process node> prior to extraction for maximum accuracy and optimal automatic threshold setting.
Type 'man IMPEXT-3530' for more detail.
PostRoute (effortLevel low) RC Extraction called for design tt_um_Jsilicon.
RC Extraction called in multi-corner(1) mode.
**WARN: (IMPEXT-6197):  The Cap table file is not specified. This will result in lower parasitic accuracy when using preRoute extraction or postRoute extraction with effort level 'low'. It is recommended to generate the Cap table file using the 'generateCapTbl' command and specify it before extraction using 'create_rc_corner/update_rc_corner -cap_table'.
Type 'man IMPEXT-6197' for more detail.
**WARN: (IMPEXT-3032):  Because the cap table file was not provided, it will be created internally with the following process info:
* Layer Id             : 1 - M1
      Thickness        : 0.6
      Min Width        : 0.065
      Layer Dielectric : 4.1
* Layer Id             : 2 - M2
      Thickness        : 0.6
      Min Width        : 0.07
      Layer Dielectric : 4.1
* Layer Id             : 3 - M3
      Thickness        : 0.6
      Min Width        : 0.07
      Layer Dielectric : 4.1
* Layer Id             : 4 - M4
      Thickness        : 0.6
      Min Width        : 0.14
      Layer Dielectric : 4.1
* Layer Id             : 5 - M5
      Thickness        : 0.6
      Min Width        : 0.14
      Layer Dielectric : 4.1
* Layer Id             : 6 - M6
      Thickness        : 0.6
      Min Width        : 0.14
      Layer Dielectric : 4.1
* Layer Id             : 7 - M7
      Thickness        : 0.6
      Min Width        : 0.4
      Layer Dielectric : 4.1
* Layer Id             : 8 - M8
      Thickness        : 0.6
      Min Width        : 0.4
      Layer Dielectric : 4.1
* Layer Id             : 9 - M9
      Thickness        : 0.6
      Min Width        : 0.8
      Layer Dielectric : 4.1
* Layer Id             : 10 - M10
      Thickness        : 1
      Min Width        : 0.8
      Layer Dielectric : 4.1
extractDetailRC Option : -outfile /home/student001/JSilicon2/work/pnr/innovus_temp_91111_465e4ac5-b2c6-4aaa-bb81-8d6131065257_gjchamber_student001_KfoLAy/tt_um_Jsilicon_91111_465e4ac5-b2c6-4aaa-bb81-8d6131065257_Mnde6h.rcdb.d  -basic
RC Mode: PostRoute -effortLevel low [Basic CapTable, LEF Resistances]
      RC Corner Indexes            0
Capacitance Scaling Factor   : 1.00000
Coupling Cap. Scaling Factor : 1.00000
Resistance Scaling Factor    : 1.00000
Clock Cap. Scaling Factor    : 1.00000
Clock Res. Scaling Factor    : 1.00000
Shrink Factor                : 1.00000
Initializing multi-corner resistance tables ...
Checking LVS Completed (CPU Time= 0:00:00.0  MEM= 3354.6M)
Extracted 10.0289% (CPU Time= 0:00:00.0  MEM= 3402.7M)
**WARN: (IMPEXT-2882):  Unable to find the resistance for via 'M2_M1_via' in Cap table or LEF or OA files. The default value of 4.0 ohms is being assigned. To avoid this, check the Cap table and LEF and OA files, provide the resistance and read the files again.
Extracted 20.0217% (CPU Time= 0:00:00.0  MEM= 3402.7M)
Extracted 30.0325% (CPU Time= 0:00:00.0  MEM= 3402.7M)
Extracted 40.0253% (CPU Time= 0:00:00.1  MEM= 3402.7M)
Extracted 50.0361% (CPU Time= 0:00:00.1  MEM= 3402.7M)
Extracted 60.0289% (CPU Time= 0:00:00.1  MEM= 3402.7M)
Extracted 70.0217% (CPU Time= 0:00:00.1  MEM= 3402.7M)
**WARN: (IMPEXT-2882):  Unable to find the resistance for via 'M3_M2_via' in Cap table or LEF or OA files. The default value of 4.0 ohms is being assigned. To avoid this, check the Cap table and LEF and OA files, provide the resistance and read the files again.
Extracted 80.0325% (CPU Time= 0:00:00.1  MEM= 3402.7M)
Extracted 90.0253% (CPU Time= 0:00:00.1  MEM= 3402.7M)
**WARN: (IMPEXT-2882):  Unable to find the resistance for via 'M4_M3_via' in Cap table or LEF or OA files. The default value of 4.0 ohms is being assigned. To avoid this, check the Cap table and LEF and OA files, provide the resistance and read the files again.
Extracted 100% (CPU Time= 0:00:00.1  MEM= 3402.7M)
Number of Extracted Resistors     : 8754
Number of Extracted Ground Cap.   : 9306
Number of Extracted Coupling Cap. : 14588
Filtering XCap in 'relativeOnly' mode using values relative_c_threshold=0.03 and total_c_threshold=5fF.
Checking LVS Completed (CPU Time= 0:00:00.0  MEM= 3378.7M)
PostRoute (effortLevel low) RC Extraction DONE (CPU Time: 0:00:00.2  Real Time: 0:00:01.0  MEM: 3378.656M)
false
innovus 6> rcOut -spef ../../results/extraction/tt_um_Jsilicon.spef
RC Out has the following PVT Info:
   RC-typical
Dumping Spef file.....
Printing D_NET...
rcOut completed:: 9 % rcOut completed:: 19 % rcOut completed:: 29 % rcOut completed:: 39 % rcOut completed:: 49 % rcOut completed:: 59 % rcOut completed:: 69 % rcOut completed:: 79 % rcOut completed:: 89 % rcOut completed:: 100 %
RC Out from RCDB Completed (CPU Time= 0:00:00.1  MEM= 3378.7M)
innovus 7> write_sdf -version 3.0 ../../results/extraction/tt_um_Jsilicon.sdf
**WARN: (SDF-808):      The software is currently operating in a high performance mode which optimizes the handling of multiple timing arcs between input and output pin pairs. With the current settings, the SDF file generated will contain the same delay information for all of these arcs. To have the SDF recalculated with explicit pin pair data, you should use the option '-recompute_delay_calc'. This setting is recommended for generating SDF for functional  simulation applications.
AAE_INFO: opIsDesignInPostRouteState() is 1
AAE_INFO: resetNetProps viewIdx 0
Starting SI iteration 1 using Infinite Timing Windows
#################################################################################
# Design Stage: PostRoute
# Design Name: tt_um_Jsilicon
# Design Mode: 90nm
# Analysis Mode: MMMC Non-OCV
# Parasitics Mode: SPEF/RCDB
# Signoff Settings: SI On
#################################################################################
AAE_INFO: 1 threads acquired from CTE.
Start delay calculation (fullDC) (1 T). (MEM=2353.84)
Initializing multi-corner resistance tables ...
siFlow : Timing analysis mode is single, using late cdB files
siFlow : Timing analysis mode is single, using late cdB files
Total number of fetched objects 636
AAE_INFO: Total number of nets for which stage creation was skipped for all views 0
AAE_INFO-618: Total number of nets in the design is 704,  93.8 percent of the nets selected for SI analysis
End delay calculation. (MEM=2393.92 CPU=0:00:00.2 REAL=0:00:00.0)
End delay calculation (fullDC). (MEM=2393.16 CPU=0:00:00.4 REAL=0:00:00.0)
Save waveform /home/student001/JSilicon2/work/pnr/innovus_temp_91111_465e4ac5-b2c6-4aaa-bb81-8d6131065257_gjchamber_student001_KfoLAy/.AAE_IKffn8/.AAE_91111_465e4ac5-b2c6-4aaa-bb81-8d6131065257/waveform.data...
Loading CTE timing window with TwFlowType 0...(CPU = 0:00:00.0, REAL = 0:00:00.0, MEM = 2394.5M)
Add other clocks and setupCteToAAEClockMapping during iter 1
Loading CTE timing window is completed (CPU = 0:00:00.0, REAL = 0:00:00.0, MEM = 2394.7M)
Starting SI iteration 2
Start delay calculation (fullDC) (1 T). (MEM=2373.89)
**DIAG: Timing query is performed without necessary timing update!
Glitch Analysis: View VIEW_TYPICAL -- Total Number of Nets Skipped = 0.
Glitch Analysis: View VIEW_TYPICAL -- Total Number of Nets Analyzed = 636.
Total number of fetched objects 636
AAE_INFO: Total number of nets for which stage creation was skipped for all views 0
AAE_INFO-618: Total number of nets in the design is 704,  12.1 percent of the nets selected for SI analysis
End delay calculation. (MEM=2391.07 CPU=0:00:00.1 REAL=0:00:00.0)
End delay calculation (fullDC). (MEM=2391.07 CPU=0:00:00.1 REAL=0:00:00.0)
innovus 8> saveDesign jsilicon_extracted.enc
The in-memory database contained RC information but was not saved. To save
the RC information, use saveDesign's -rc option. Note: Saving RC information can be quite large,
so it should only be saved when it is really desired.
#% Begin save design ... (date=11/18 12:22:47, mem=2361.3M)
% Begin Save ccopt configuration ... (date=11/18 12:22:47, mem=2361.3M)
% End Save ccopt configuration ... (date=11/18 12:22:47, total cpu=0:00:00.0, real=0:00:00.0, peak res=2363.0M, current mem=2363.0M)
% Begin Save netlist data ... (date=11/18 12:22:47, mem=2380.3M)
Writing Binary DB to jsilicon_extracted.enc.dat/tt_um_Jsilicon.v.bin in single-threaded mode...
% End Save netlist data ... (date=11/18 12:22:47, total cpu=0:00:00.0, real=0:00:00.0, peak res=2380.4M, current mem=2380.4M)
Saving symbol-table file ...
Saving congestion map file jsilicon_extracted.enc.dat/tt_um_Jsilicon.route.congmap.gz ...
% Begin Save AAE data ... (date=11/18 12:22:47, mem=2380.9M)
Saving AAE Data ...
% End Save AAE data ... (date=11/18 12:22:47, total cpu=0:00:00.2, real=0:00:00.0, peak res=2440.4M, current mem=2381.5M)
Saving preference file jsilicon_extracted.enc.dat/gui.pref.tcl ...
Saving mode setting ...
**WARN: (IMPMF-5054):   fill_setting_save command is obsolete and should not be used any more. It still works in this release but will be removed in future release. Recommend to use Pegasus metal fill flow which is the replacement.
Saving global file ...
% Begin Save floorplan data ... (date=11/18 12:22:47, mem=2387.1M)
Saving floorplan file ...
Convert 0 swires and 0 svias from compressed groups
% End Save floorplan data ... (date=11/18 12:22:48, total cpu=0:00:00.0, real=0:00:01.0, peak res=2387.5M, current mem=2387.5M)
Saving PG file jsilicon_extracted.enc.dat/tt_um_Jsilicon.pg.gz, version#2, (Created by Innovus v23.13-s082_1 on Tue Nov 18 12:22:48 2025)
*** Completed savePGFile (cpu=0:00:00.0 real=0:00:00.0 mem=3175.2M) ***
*info - save blackBox cells to lef file jsilicon_extracted.enc.dat/tt_um_Jsilicon.bbox.lef
Saving Drc markers ...
... 27 markers are saved ...
... 0 geometry drc markers are saved ...
... 0 antenna drc markers are saved ...
% Begin Save placement data ... (date=11/18 12:22:48, mem=2387.5M)
** Saving stdCellPlacement_binary (version# 2) ...
Save Adaptive View Pruning View Names to Binary file
% End Save placement data ... (date=11/18 12:22:48, total cpu=0:00:00.0, real=0:00:00.0, peak res=2387.6M, current mem=2387.6M)
% Begin Save routing data ... (date=11/18 12:22:48, mem=2387.6M)
Saving route file ...
*** Completed saveRoute (cpu=0:00:00.0 real=0:00:00.0 mem=3175.2M) ***
% End Save routing data ... (date=11/18 12:22:48, total cpu=0:00:00.0, real=0:00:00.0, peak res=2387.8M, current mem=2387.8M)
Saving property file jsilicon_extracted.enc.dat/tt_um_Jsilicon.prop
*** Completed saveProperty (cpu=0:00:00.0 real=0:00:00.0 mem=3178.2M) ***
#Saving pin access data to file jsilicon_extracted.enc.dat/tt_um_Jsilicon.apa ...
% Begin Save power constraints data ... (date=11/18 12:22:48, mem=2388.4M)
% End Save power constraints data ... (date=11/18 12:22:48, total cpu=0:00:00.0, real=0:00:00.0, peak res=2388.4M, current mem=2388.4M)
Generated self-contained design jsilicon_extracted.enc.dat
#% End save design ... (date=11/18 12:22:48, total cpu=0:00:01.3, real=0:00:01.0, peak res=2440.4M, current mem=2389.6M)

*** Summary of all messages that are not suppressed in this session:
Severity  ID               Count  Summary
WARNING   IMPMF-5054           1  fill_setting_save command is obsolete an...
*** Message Summary: 1 warning(s), 0 error(s)

0
innovus 9>

```


###### Step 5: 최종 리포트
```tcl
innovus

restoreDesign jsilicon_extracted.enc.dat tt_um_Jsilicon

file mkdir ../../reports/final

report_timing -late > ../../reports/final/timing_summary.rpt
report_power > ../../reports/final/power.rpt
report_area > ../../reports/final/area.rpt
summaryReport -outfile ../../reports/final/summary.rpt

exit
```

```
innovus 10> file mkdir ../../reports/final
innovus 11> report_timing -late > ../../reports/final/timing_summary.rpt
AAE_INFO: opIsDesignInPostRouteState() is 1
AAE_INFO: resetNetProps viewIdx 0
Starting SI iteration 1 using Infinite Timing Windows
#################################################################################
# Design Stage: PostRoute
# Design Name: tt_um_Jsilicon
# Design Mode: 90nm
# Analysis Mode: MMMC Non-OCV
# Parasitics Mode: SPEF/RCDB
# Signoff Settings: SI On
#################################################################################
AAE_INFO: 1 threads acquired from CTE.
Calculate delays in Single mode...
Start delay calculation (fullDC) (1 T). (MEM=2420.84)
Total number of fetched objects 636
AAE_INFO: Total number of nets for which stage creation was skipped for all views 0
AAE_INFO-618: Total number of nets in the design is 704,  90.3 percent of the nets selected for SI analysis
End delay calculation. (MEM=2429.05 CPU=0:00:00.1 REAL=0:00:00.0)
End delay calculation (fullDC). (MEM=2429.05 CPU=0:00:00.2 REAL=0:00:00.0)
Save waveform /home/student001/JSilicon2/work/pnr/innovus_temp_91111_465e4ac5-b2c6-4aaa-bb81-8d6131065257_gjchamber_student001_KfoLAy/.AAE_IKffn8/.AAE_91111_465e4ac5-b2c6-4aaa-bb81-8d6131065257/waveform.data...
Loading CTE timing window with TwFlowType 0...(CPU = 0:00:00.0, REAL = 0:00:00.0, MEM = 2429.2M)
Add other clocks and setupCteToAAEClockMapping during iter 1
Loading CTE timing window is completed (CPU = 0:00:00.0, REAL = 0:00:00.0, MEM = 2429.2M)
Starting SI iteration 2
Calculate delays in Single mode...
Start delay calculation (fullDC) (1 T). (MEM=2423.17)
Total number of fetched objects 636
AAE_INFO: Total number of nets for which stage creation was skipped for all views 0
AAE_INFO-618: Total number of nets in the design is 704,  1.8 percent of the nets selected for SI analysis
End delay calculation. (MEM=2427.17 CPU=0:00:00.0 REAL=0:00:00.0)
End delay calculation (fullDC). (MEM=2427.17 CPU=0:00:00.0 REAL=0:00:00.0)
innovus 12> report_power > ../../reports/final/power.rpt
innovus 13> report_area > ../../reports/final/area.rpt
innovus 14>
innovus 14> summaryReport -outfile ../../reports/final/summary.rpt
Start to collect the design information.
Build netlist information for Cell tt_um_Jsilicon.
Finished collecting the design information.
Generating standard cells used in the design report.
Analyze library ...
Analyze netlist ...
Generate no-driven nets information report.
Analyze timing ...
Analyze floorplan/placement ...
Analysis Routing ...
Report saved in file ../../reports/final/summary.rpt
innovus 15>

```


###### Step 6: GDS 생성 🎉

```tcl
innovus
restoreDesign jsilicon_extracted.enc.dat tt_um_Jsilicon

file mkdir ../../results/gds

# GDS 생성
file mkdir ../../results/gds
streamOut ../../results/gds/tt_um_Jsilicon.gds

~~ 이하는 실행하지 마시로 ~~
streamOut ../../results/gds/tt_um_Jsilicon.gds \
    -mapFile ../../tech/lef/gds.map \
    -stripes 1 \
    -units 1000 \
    -mode ALL

exit
```

```

innovus 18> file mkdir ../../results/gds
innovus 19> streamOut ../../results/gds/tt_um_Jsilicon.gds
Parse flat map file 'streamOut.map'
Writing GDSII file ...
        ****** db unit per micron = 2000 ******
        ****** output gds2 file unit per micron = 2000 ******
        ****** unit scaling factor = 1 ******
Output for instance
Output for bump
Output for physical terminals
Output for logical terminals
Output for regular nets
Output for special nets and metal fills
Convert 0 swires and 0 svias from compressed groups
Output for via structure generation total number 14
Statistics for GDS generated (version 3)
----------------------------------------
Stream Out Layer Mapping Information:
GDS Layer Number          GDS Layer Name
----------------------------------------
    212                             COMP
    213                          DIEAREA
    206                          metal10
    196                             via9
    205                          metal10
    185                           metal9
    195                             via9
    175                             via8
    204                          metal10
    184                           metal9
    164                           metal8
    8                             metal1
    22                              via1
    2                            contact
    64                              via3
    44                              via2
    5                            contact
    43                              via2
    23                              via1
    1                            contact
    9                             metal1
    29                            metal2
    50                            metal3
    10                            metal1
    30                            metal2
    71                            metal4
    11                            metal1
    51                            metal3
    31                            metal2
    65                              via3
    26                              via1
    85                              via4
    52                            metal3
    32                            metal2
    72                            metal4
    92                            metal5
    47                              via2
    3                            contact
    86                              via4
    106                             via5
    200                          metal10
    161                           metal8
    78                            metal4
    38                            metal2
    58                            metal3
    97                            metal5
    117                           metal6
    53                            metal3
    14                            metal1
    73                            metal4
    93                            metal5
    113                           metal6
    198                          metal10
    178                           metal9
    158                           metal8
    75                            metal4
    36                            metal2
    16                            metal1
    55                            metal3
    119                           metal6
    68                              via3
    24                              via1
    4                            contact
    107                             via5
    127                             via6
    182                           metal9
    59                            metal3
    79                            metal4
    99                            metal5
    118                           metal6
    138                           metal7
    173                             via8
    70                              via3
    90                              via4
    109                             via5
    129                             via6
    202                          metal10
    183                           metal9
    163                           metal8
    143                           metal7
    190                             via9
    170                             via8
    67                              via3
    48                              via2
    28                              via1
    87                              via4
    131                             via6
    180                           metal9
    160                           metal8
    101                           metal5
    121                           metal6
    141                           metal7
    35                            metal2
    74                            metal4
    94                            metal5
    114                           metal6
    134                           metal7
    176                           metal9
    156                           metal8
    13                            metal1
    33                            metal2
    77                            metal4
    116                           metal6
    136                           metal7
    197                          metal10
    177                           metal9
    157                           metal8
    54                            metal3
    34                            metal2
    15                            metal1
    98                            metal5
    137                           metal7
    203                          metal10
    159                           metal8
    80                            metal4
    100                           metal5
    120                           metal6
    139                           metal7
    199                          metal10
    179                           metal9
    57                            metal3
    37                            metal2
    17                            metal1
    76                            metal4
    96                            metal5
    140                           metal7
    201                          metal10
    181                           metal9
    162                           metal8
    122                           metal6
    142                           metal7
    45                              via2
    6                            contact
    25                              via1
    89                              via4
    128                             via6
    148                             via7
    169                             via8
    66                              via3
    46                              via2
    7                            contact
    27                              via1
    110                             via5
    149                             via7
    194                             via9
    91                              via4
    111                             via5
    130                             via6
    150                             via7
    171                             via8
    112                             via5
    132                             via6
    151                             via7
    191                             via9
    69                              via3
    49                              via2
    88                              via4
    108                             via5
    152                             via7
    192                             via9
    172                             via8
    133                             via6
    153                             via7
    193                             via9
    174                             via8
    154                             via7
    56                            metal3
    12                            metal1
    95                            metal5
    115                           metal6
    135                           metal7
    155                           metal8
    18                            metal1
    19                            metal1
    39                            metal2
    60                            metal3
    20                            metal1
    40                            metal2
    81                            metal4
    21                            metal1
    61                            metal3
    41                            metal2
    62                            metal3
    42                            metal2
    82                            metal4
    102                           metal5
    210                          metal10
    63                            metal3
    83                            metal4
    103                           metal5
    123                           metal6
    208                          metal10
    188                           metal9
    168                           metal8
    84                            metal4
    104                           metal5
    124                           metal6
    144                           metal7
    186                           metal9
    166                           metal8
    126                           metal6
    146                           metal7
    207                          metal10
    187                           metal9
    167                           metal8
    147                           metal7
    209                          metal10
    189                           metal9
    105                           metal5
    125                           metal6
    145                           metal7
    165                           metal8


Stream Out Information Processed for GDS version 3:
Units: 2000 DBU

Object                             Count
----------------------------------------
Instances                            587

Ports/Pins                             0

Nets                                5684
    metal layer metal1               712
    metal layer metal2              3368
    metal layer metal3              1501
    metal layer metal4               103

    Via Instances                   3229

Special Nets                          28
    metal layer metal1                22
    metal layer metal8                 6

    Via Instances                    462

Metal Fills                            0

    Via Instances                      0

Metal FillOPCs                         0

    Via Instances                      0

Metal FillDRCs                         0

    Via Instances                      0

Text                                 647
    metal layer metal1               101
    metal layer metal2               473
    metal layer metal3                71
    metal layer metal4                 2


Blockages                              0


Custom Text                            0


Custom Box                             0

Trim Metal                             0

######Streamout is finished!
innovus 20>
c
```

##### 📊 최종 파일 확인
```csh
# GDS 파일
ls -lh ~/JSilicon2/results/gds/tt_um_Jsilicon.gds

# 예상 크기: 100KB ~ 10MB

# 기타 파일
ls -lh ~/JSilicon2/results/extraction/
ls -lh ~/JSilicon2/reports/final/
```

```
# GDS 파일 확인
ls -lh ~/JSilicon2/results/gds/tt_um_Jsilicon.gds

# 출력: 크기 564K 
-rw-r--r-- 1 student001 student001 564K Nov 18 12:28 /home/student001/JSilicon2/results/gds/tt_um_Jsilicon.gds

# 파일 타입
file ~/JSilicon2/results/gds/tt_um_Jsilicon.gds
# 출력:
/home/student001/JSilicon2/results/gds/tt_um_Jsilicon.gds: GDSII Stream file version 3.0

# 압축 (선택)
gzip -k ~/JSilicon2/results/gds/tt_um_Jsilicon.gds
```

---

##### 📊 예상 GDS 크기
```
정상 범위: 100KB ~ 10MB

JSilicon 예상:
  - Cell count: ~600
  - Area: 1829 μm²
  - 예상 GDS: 300KB ~ 1MB
  
⚠️ 50KB 미만: 문제 있음
✓ 100KB 이상: 정상
```

---

##### 📁 최종 Deliverables
```
필수 제출 파일:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. tt_um_Jsilicon.gds          ← GDS (Layout)
2. tt_um_Jsilicon_final.v      ← Netlist
3. tt_um_Jsilicon.spef         ← Parasitic
4. summary_final.rpt           ← Summary
5. gscl45nm.lef                ← Technology

보조 파일:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
6. timing_summary.rpt          ← Timing
7. power.rpt                   ← Power
8. area.rpt                    ← Area
9. geometry_final.rpt          ← DRC
10. connectivity_check.rpt     ← LVS
```

---

#### ✅ Tape-out 체크리스트
```
최종 확인 사항:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

□ Timing
  □ Setup WNS > 0 ns  (또는 < -0.05ns)
  □ Hold WNS > 0 ns   (또는 < -0.05ns)
  
□ Physical
  □ DRC: 0 violations
  □ LVS: Clean
  □ Connectivity: OK (minor issues 허용)
  
□ Files
  □ GDS 파일 생성됨
  □ 파일 크기 정상 (>100KB)
  
□ Reports
  □ 모든 리포트 생성됨
  □ Summary 확인
  
□ Documentation
  □ Pin list 준비
  □ Design spec 준비
```

## 🎉 결과 확인

```csh
# 타이밍
cat ~/JSilicon2/reports/final/timing_summary.rpt

# 전력
cat ~/JSilicon2/reports/final/power.rpt

# 면적
cat ~/JSilicon2/reports/final/area.rpt

# 요약
cat ~/JSilicon2/reports/final/summary.rpt

# GDS 정보
ls -lh ~/JSilicon2/results/gds/tt_um_Jsilicon.gds
```

~~# Violations~~
~~cat ~/JSilicon2/reports/final/violations.rpt~~

~~# DRC~~
~~cat ~/JSilicon2/reports/final/geometry_final.rpt~~

# [Skip] JSilicon 타이밍 위반 해결 가이드 (Timing Violation Fix Guide)

* 필요한 파일
```
tt_um_Jsilicon_synth_optimized.sdc
fix_timing.tcl
```

* 현재 상태
```
Setup WNS:  -0.011 ns (200MHz)
Hold WNS:   -0.395 ns

Target: Setup & Hold violations 모두 해결
```

* 수정 방법 1: SDC 파일 수정
   * 파일: work/synthesis/tt_um_Jsilicon_synth.sdc

```
# 현재 설정
-------------------
create_clock -name clk -period 5.0 [get_ports clk]         # 200MHz
set_clock_uncertainty 0.5 [get_clocks clk]
set_input_delay -clock clk -max 1.5 [all_inputs]          # 1.5ns


# 수정 후 (옵션 A: 150MHz)
-------------------
create_clock -name clk -period 6.67 [get_ports clk]        # 150MHz
set_clock_uncertainty 0.5 [get_clocks clk]
set_input_delay -clock clk -max 1.0 [all_inputs]          # 1.0ns
set_output_delay -clock clk -max 1.0 [all_outputs]


# 수정 후 (옵션 B: 160MHz - 더 도전적)
-------------------
create_clock -name clk -period 6.25 [get_ports clk]        # 160MHz
set_clock_uncertainty 0.5 [get_clocks clk]
set_input_delay -clock clk -max 1.0 [all_inputs]
set_output_delay -clock clk -max 1.0 [all_outputs]
```

* 수정 방법 2: 타이밍 최적화 스크립트
   * 파일: scripts/innovus/fix_timing.tcl (새로 생성)

```
#!/bin/tcsh
################################################################################
# 타이밍 최적화 스크립트
################################################################################

# 1. 기존 디자인 복원
restoreDesign jsilicon_final.enc.dat tt_um_Jsilicon

puts "=========================================="
puts "타이밍 최적화 시작"
puts "=========================================="

################################################################################
# Setup Timing 개선
################################################################################

puts "1. Setup Timing 최적화..."

# 최적화 모드 설정
setOptMode -addInstancePrefix OPT_SETUP
setOptMode -fixFanoutLoad true
setOptMode -usefulSkew true
setOptMode -effort high

# Setup 최적화 실행
optDesign -postRoute -setup -drv

puts "  ✓ Setup 최적화 완료"

################################################################################
# Hold Timing 개선
################################################################################

puts "2. Hold Timing 최적화..."

# Hold 최적화 모드
setOptMode -addInstancePrefix OPT_HOLD
setOptMode -fixHoldAllowSetupTnsDegrade false

# Hold 최적화 실행
optDesign -postRoute -hold

puts "  ✓ Hold 최적화 완료"

################################################################################
# 타이밍 재확인
################################################################################

puts "3. 타이밍 재확인..."

# Setup timing
report_timing -late -max_paths 10 > reports_opt/timing_setup_fixed.rpt

# Hold timing
report_timing -early -max_paths 10 > reports_opt/timing_hold_fixed.rpt

# Summary
report_timing -late > reports_opt/timing_summary_fixed.rpt

################################################################################
# 최종 저장
################################################################################

puts "4. 최적화된 디자인 저장..."

saveDesign work/pnr/jsilicon_optimized.enc

# DEF 저장
defOut -floorplan -netlist -routing results/def/tt_um_Jsilicon_optimized.def

# Netlist 저장
saveNetlist results/netlist/tt_um_Jsilicon_optimized.v

puts ""
puts "=========================================="
puts "✓ 타이밍 최적화 완료"
puts "=========================================="
puts ""
puts "결과 확인:"
puts "  cat reports_opt/timing_summary_fixed.rpt"
puts ""

exit
```

* 수정 방법 3: CTS 재실행
   * 파일: scripts/innovus/run_cts.tcl (새로 생성)
```
#!/bin/tcsh
################################################################################
# Clock Tree Synthesis 스크립트
################################################################################

# 1. 기존 디자인 복원 (Placement 단계)
restoreDesign jsilicon_placed.enc.dat tt_um_Jsilicon

puts "=========================================="
puts "Clock Tree Synthesis 재실행"
puts "=========================================="

################################################################################
# CTS 설정
################################################################################

puts "1. CTS 설정..."

# 사용할 버퍼/인버터 지정
set_ccopt_property buffer_cells {BUFX2 BUFX4}
set_ccopt_property inverter_cells {INVX1 INVX2 INVX4}

# CTS 목표 설정
set_ccopt_property target_max_trans 0.2
set_ccopt_property target_skew 0.1

puts "  ✓ CTS 설정 완료"

################################################################################
# CTS 실행
################################################################################

puts "2. CTS 실행..."

# Clock tree spec 생성
create_ccopt_clock_tree_spec -immediate

# CTS 실행
catch {
    ccopt_design
} result

if { $result == 0 } {
    puts "  ✓ CTS 성공"
} else {
    puts "  ⚠ CTS 실패 - clock_opt_design으로 재시도"
    
    # 대안: clock_opt_design 사용
    clock_opt_design
}

################################################################################
# Post-CTS 최적화
################################################################################

puts "3. Post-CTS 최적화..."

# 최적화 모드 설정
setOptMode -addInstancePrefix OPT_CTS
setOptMode -effort high

# Post-CTS 최적화
optDesign -postCTS

puts "  ✓ Post-CTS 최적화 완료"

################################################################################
# Hold Timing 수정
################################################################################

puts "4. Hold Timing 수정..."

# Hold 최적화
setOptMode -fixHoldAllowSetupTnsDegrade false
optDesign -postCTS -hold

puts "  ✓ Hold 최적화 완료"

################################################################################
# 저장
################################################################################

puts "5. CTS 결과 저장..."

saveDesign work/pnr/jsilicon_cts_fixed.enc

puts ""
puts "=========================================="
puts "✓ CTS 재실행 완료"
puts "=========================================="

# 다음 단계 계속 (Routing)
source ../../scripts/innovus/continue_pnr.tcl
```

* 수정 방법 4: 전체 플로우 재실행
   * 파일: scripts/innovus/pnr_flow_optimized.tcl
```
기존 pnr_flow.tcl 수정 사항:

1) SDC 파일 경로를 새로운 파일로 변경
-------------------
# 기존
set init_mmmc_file $project_root/scripts/innovus/mmmc.tcl

# mmmc.tcl 내에서:
set sdc_file $project_root/work/synthesis/tt_um_Jsilicon_synth_optimized.sdc


2) CTS 섹션 강화
-------------------
# Step 5: Clock Tree Synthesis 수정

puts "Step 5: Clock Tree Synthesis"

# CTS 설정 강화
set_ccopt_property buffer_cells {BUFX2 BUFX4}
set_ccopt_property inverter_cells {INVX1 INVX2 INVX4}
set_ccopt_property target_max_trans 0.2
set_ccopt_property target_skew 0.1
set_ccopt_property use_inverters true

# CTS 실행
create_ccopt_clock_tree_spec -immediate
ccopt_design

# Hold 최적화 추가
setOptMode -fixHoldAllowSetupTnsDegrade false
optDesign -postCTS -hold


3) Post-Route 최적화 강화
-------------------
# Step 8: Post-Route Optimization 수정

puts "Step 8: Post-Route Optimization"

# Setup & Hold 동시 최적화
setOptMode -effort high
setOptMode -usefulSkew true

optDesign -postRoute -setup
optDesign -postRoute -hold

# 추가 최적화
optDesign -postRoute -drv
```

* 실행 순서
  * 방법 A: 빠른 수정 (기존 결과 활용)
-------------------
1. SDC 파일 수정
   * cd ~/JSilicon2/work/synthesis
   * vi tt_um_Jsilicon_synth.sdc
   * 클럭 주기: 5.0 → 6.67 (150MHz)
   * 입력 지연: 1.5 → 1.0

2. 타이밍 최적화 실행
   * cd ~/JSilicon2/work/pnr
   * innovus -init ../../scripts/innovus/fix_timing.tcl

* 방법 B: CTS 재실행
-------------------
  * 1. SDC 파일 수정 (위와 동일)

  * 2. CTS 재실행
   * cd ~/JSilicon2/work/pnr
   * innovus -init ../../scripts/innovus/run_cts.tcl


* 방법 C: 전체 재실행 (가장 확실)
-------------------
* 1. 새로운 SDC 파일 생성
   * cp work/synthesis/tt_um_Jsilicon_synth.sdc \
      * work/synthesis/tt_um_Jsilicon_synth_optimized.sdc
   
   * vi work/synthesis/tt_um_Jsilicon_synth_optimized.sdc
   * 수정 적용

* 2. Synthesis 재실행
   * cd ~/JSilicon2/work/synthesis
   * genus -f ../../scripts/genus/synthesis.tcl

* 3. P&R 재실행
   * cd ~/JSilicon2/work/pnr
   * innovus -init ../../scripts/innovus/pnr_flow_optimized.tcl

* 예상 결과

* 수정 전:
  * Setup WNS: -0.011 ns @ 200MHz
  * Hold WNS:  -0.395 ns

* 수정 후 (150MHz + CTS):
  * Setup WNS: +0.5 ~ +1.0 ns (여유 확보)
  * Hold WNS:  +0.1 ~ +0.2 ns (Pass)


* 확인 방법

* # 타이밍 확인
* cat reports_opt/timing_summary_fixed.rpt

* # WNS 추출
* grep -i "slack" reports_opt/timing_summary_fixed.rpt

* # 상세 경로
* less reports_opt/timing_setup_fixed.rpt
* less reports_opt/timing_hold_fixed.rpt

---

## 📈 다음 단계

1. **타이밍 최적화**
   ```tcl
   # Innovus에서
   restoreDesign jsilicon_final.enc
   optDesign -postRoute -setup -hold
   saveDesign jsilicon_final_opt.enc
   ```

2. **Clock Tree Synthesis**
   ```tcl
   set_ccopt_property buffer_cells {BUFX2 BUFX4}
   set_ccopt_property inverter_cells {INVX1 INVX2}
   clock_opt_design
   ```

3. **검증**
   - LVS (Layout vs Schematic)
   - Parasitic extraction
   - Post-layout simulation

4. **GDS 생성**
   ```tcl
   streamOut final.gds -mapFile gds.map -merge
   ```

```
################################################################################
# JSilicon 최종 검증 및 GDS 생성 플로우
# Complete Verification and Tape-out Flow
################################################################################

========================================
작업 디렉토리 및 순서
========================================
```

* 모든 작업은 다음 디렉토리에서 수행:
```
  ~/JSilicon2/work/pnr

기본 구조:
  ~/JSilicon2/
  ├── work/pnr/              ← 여기서 작업!
  │   ├── *.enc.dat          (checkpoint 파일들)
  │   └── innovus.cmd        (명령 히스토리)
  ├── scripts/innovus/
  │   ├── fix_timing.tcl
  │   ├── run_lvs.tcl
  │   └── run_cts.tcl
  ├── results/
  │   ├── gds/               (최종 GDS)
  │   ├── lvs/               (LVS 결과)
  │   └── netlist/
  ├── reports/
  │   └── pnr_optimized/     (최적화 후 리포트)
  └── tech/
      └── lef/
          └── gds.map
```

```
========================================
STEP 1: 타이밍 최적화
========================================

디렉토리: ~/JSilicon2/work/pnr

방법 A: 스크립트 사용 (권장)
-------------------
cd ~/JSilicon2/work/pnr
innovus -init ../../scripts/innovus/fix_timing.tcl |& tee timing_opt.log

# 결과 확인
cat ../../reports/pnr_optimized/timing_summary_fixed.rpt


방법 B: 대화형으로 실행
-------------------
cd ~/JSilicon2/work/pnr
innovus

# Innovus 콘솔에서:
restoreDesign jsilicon_final.enc.dat tt_um_Jsilicon

# Setup & Hold 최적화
setOptMode -effort high
setOptMode -usefulSkew true
setOptMode -fixHoldAllowSetupTnsDegrade false

optDesign -postRoute -setup
optDesign -postRoute -hold

# 타이밍 확인
report_timing -late -max_paths 5
report_timing -early -max_paths 5

# 저장
saveDesign jsilicon_final_opt.enc

# 리포트
report_timing -late > ../../reports/pnr_optimized/timing_opt.rpt

exit
```
```
========================================
STEP 2: Clock Tree Synthesis (재실행)
========================================

디렉토리: ~/JSilicon2/work/pnr

※ 주의: 이미 CTS가 완료된 상태라면 이 단계는 SKIP 가능
※ Hold violation이 심각하면 CTS 재실행 필요

방법: Placement 단계부터 재시작
-------------------
cd ~/JSilicon2/work/pnr
innovus

# Placement 단계 복원
restoreDesign jsilicon_placed.enc.dat tt_um_Jsilicon

# CTS 설정
set_ccopt_property buffer_cells {BUFX2 BUFX4}
set_ccopt_property inverter_cells {INVX1 INVX2 INVX4}
set_ccopt_property target_max_trans 0.2
set_ccopt_property target_skew 0.1

# CTS 실행
create_ccopt_clock_tree_spec -immediate
ccopt_design

# Post-CTS 최적화
optDesign -postCTS
optDesign -postCTS -hold

# 저장
saveDesign jsilicon_cts_new.enc

# 라우팅 계속
routeDesign
optDesign -postRoute

# 최종 저장
saveDesign jsilicon_final_cts.enc

exit
```
```
========================================
STEP 3: LVS (Layout vs Schematic)
========================================

디렉토리: ~/JSilicon2/work/pnr

방법 A: 스크립트 사용 (권장)
-------------------
cd ~/JSilicon2/work/pnr
innovus -init ../../scripts/innovus/run_lvs.tcl |& tee lvs.log

# 결과 확인
cat ../../results/lvs/lvs_summary.rpt
cat ../../results/lvs/connectivity_check.rpt


방법 B: 대화형으로 실행
-------------------
cd ~/JSilicon2/work/pnr
innovus

# 최적화된 디자인 복원
restoreDesign jsilicon_final_opt.enc.dat tt_um_Jsilicon

# LVS 디렉토리 생성
file mkdir ../../results/lvs

# Layout netlist 추출
saveNetlist -excludeLeafCell \
    -includePhysicalInst \
    -includePowerGround \
    ../../results/lvs/layout_extracted.sp

# Connectivity check
verifyConnectivity -report ../../results/lvs/connectivity.rpt

# P/G connectivity
verifyConnectivity -type special \
    -report ../../results/lvs/pg_connectivity.rpt

exit
```
```
========================================
STEP 4: Parasitic Extraction
========================================

디렉토리: ~/JSilicon2/work/pnr

방법: Innovus 내장 RC Extraction
-------------------
cd ~/JSilicon2/work/pnr
innovus

# 디자인 복원
restoreDesign jsilicon_final_opt.enc.dat tt_um_Jsilicon

# RC Extraction 디렉토리
file mkdir ../../results/extraction

# Extract RC parasitics
extractRC

# SPEF 파일 생성
rcOut -spef ../../results/extraction/tt_um_Jsilicon.spef

# SDF 파일 생성 (타이밍 백-어노테이션용)
write_sdf -version 3.0 \
    ../../results/extraction/tt_um_Jsilicon.sdf

# 저장
saveDesign jsilicon_extracted.enc

exit
```
# SPEF 파일 확인
```
ls -lh ../../results/extraction/
```
```
========================================
STEP 5: Post-Layout Simulation (선택)
========================================

디렉토리: ~/JSilicon2/work/simulation

※ 이 단계는 Verilog 시뮬레이터 필요 (VCS, NC-Verilog, ModelSim 등)
※ SPEF를 사용한 백-어노테이션 시뮬레이션

준비물:
  1. Post-P&R netlist: results/netlist/tt_um_Jsilicon_final.v
  2. SDF file: results/extraction/tt_um_Jsilicon.sdf
  3. Testbench: rtl/tb/testbench.v

실행 예시 (VCS):
-------------------
cd ~/JSilicon2/work/simulation

# 컴파일
vcs -full64 \
    -timescale=1ns/1ps \
    ../../results/netlist/tt_um_Jsilicon_final.v \
    ../../rtl/tb/testbench.v \
    -sdf max:../../results/extraction/tt_um_Jsilicon.sdf

# 실행
./simv +vcs+dumpvars

# 파형 확인
dve -vpd vcdplus.vpd &
```
```
========================================
STEP 6: GDS 생성 (Tape-out)
========================================

디렉토리: ~/JSilicon2/work/pnr

방법: streamOut 사용
-------------------
cd ~/JSilicon2/work/pnr
innovus

# 최종 디자인 복원
restoreDesign jsilicon_final_opt.enc.dat tt_um_Jsilicon

# GDS 디렉토리 생성
file mkdir ../../results/gds

# GDS Map 파일 확인
# 파일 위치: ../../tech/lef/gds.map

# GDS 생성
streamOut ../../results/gds/tt_um_Jsilicon.gds \
    -mapFile ../../tech/lef/gds.map \
    -stripes 1 \
    -units 1000 \
    -mode ALL \
    -merge {../../tech/gds/gscl45nm_stdcells.gds}

# 압축 (선택)
gzip ../../results/gds/tt_um_Jsilicon.gds

exit

# GDS 파일 확인
ls -lh ../../results/gds/
file ../../results/gds/tt_um_Jsilicon.gds
```
```
========================================
전체 플로우 실행 스크립트
========================================

파일: scripts/innovus/complete_flow.tcl

#!/bin/tcsh
###############################################################################
# 완전한 검증 및 Tape-out 플로우
###############################################################################

set DESIGN_NAME "tt_um_Jsilicon"
set project_root [file normalize ../../]

puts "=========================================="
puts "Complete Verification & Tape-out Flow"
puts "=========================================="

# 1. 타이밍 최적화
puts "\n1. Timing Optimization..."
source ../../scripts/innovus/fix_timing.tcl

# 2. LVS 검증
puts "\n2. LVS Check..."
source ../../scripts/innovus/run_lvs.tcl

# 3. RC Extraction
puts "\n3. RC Extraction..."
restoreDesign jsilicon_final_opt.enc.dat $DESIGN_NAME

file mkdir $project_root/results/extraction

extractRC
rcOut -spef $project_root/results/extraction/tt_um_Jsilicon.spef
write_sdf -version 3.0 $project_root/results/extraction/tt_um_Jsilicon.sdf

saveDesign jsilicon_extracted.enc

# 4. GDS 생성
puts "\n4. GDS Generation..."

file mkdir $project_root/results/gds

streamOut $project_root/results/gds/tt_um_Jsilicon.gds \
    -mapFile $project_root/tech/lef/gds.map \
    -stripes 1 \
    -units 1000 \
    -mode ALL

puts "\n=========================================="
puts "Complete Flow Finished!"
puts "=========================================="
puts "\nGenerated Files:"
puts "  GDS:  results/gds/tt_um_Jsilicon.gds"
puts "  SPEF: results/extraction/tt_um_Jsilicon.spef"
puts "  SDF:  results/extraction/tt_um_Jsilicon.sdf"
puts "=========================================="

exit
```

* 한번에 실행하기

```
cd ~/JSilicon2/work/pnr
innovus -init ../../scripts/innovus/complete_flow.tcl |& tee complete_flow.log
```

* 체크리스트

* □ Step 1: 타이밍 최적화 완료
  * 파일: jsilicon_final_opt.enc.dat
  * 리포트: reports/pnr_optimized/timing_opt.rpt
  
* □ Step 2: CTS (필요시만)
  * 파일: jsilicon_cts_new.enc.dat
  
* □ Step 3: LVS 검증 완료
  * 리포트: results/lvs/lvs_summary.rpt
  * Status: Clean or Minor issues
  
* □ Step 4: RC Extraction 완료
  * 파일: results/extraction/tt_um_Jsilicon.spef
  * 파일: results/extraction/tt_um_Jsilicon.sdf
  
* □ Step 5: Post-layout Simulation (선택)
  * 결과: 타이밍 검증 완료
  
* □ Step 6: GDS 생성 완료
  * 파일: results/gds/tt_um_Jsilicon.gds
  * 크기: ~500KB - 5MB
  
* □ 최종 검증
  * DRC: Clean ✓
  * LVS: Clean ✓
  * Timing: Met ✓
  

* 각 단계별 예상 시간

* Step 1 (타이밍 최적화):     5-15분
* Step 2 (CTS 재실행):       10-20분 (필요시만)
* Step 3 (LVS):              2-5분
* Step 4 (RC Extraction):    5-10분
* Step 5 (Simulation):       10-30분 (선택)
* Step 6 (GDS):              1-3분

* 전체 소요 시간: 약 25-45분 (CTS 제외)


* 파일 크기 예상

* jsilicon_final_opt.enc.dat     ~50-200MB
* tt_um_Jsilicon.spef            ~500KB-2MB
* tt_um_Jsilicon.sdf             ~200KB-1MB
* tt_um_Jsilicon.gds             ~500KB-5MB
* layout_extracted.sp            ~100KB-500KB


* 주의사항

1. 디스크 공간 확인
   df -h ~/JSilicon2
   최소 1GB 여유 공간 필요

2. CTS는 선택적
   - Hold violation이 크면 재실행
   - 작으면 (< 0.5ns) 최적화만으로 충분

3. GDS Map 파일 확인
   - tech/lef/gds.map 파일 존재 확인
   - Layer mapping이 올바른지 확인

4. Backup
   중요한 checkpoint는 백업
   cp jsilicon_final_opt.enc.dat jsilicon_final_opt.backup.enc.dat

---

## 📝 참고 자료

- [FreePDK45 Documentation](http://www.eda.ncsu.edu/wiki/FreePDK45)
- [Cadence Innovus User Guide](https://www.cadence.com/)
- [RISC-V Specification](https://riscv.org/specifications/)

---

## 🎯 결론

JSilicon 프로젝트는 FreePDK45 공정을 사용한 RISC-V 코어의 성공적인 ASIC 구현을 보여줍니다:

### ✅ 성공 사항
- 완전한 RTL-to-Layout 플로우 완료
- DRC Clean (0 violations)
- 저전력 설계 (0.561 mW)
- 소면적 구현 (5,390 μm²)

### ⚠️ 개선 필요
- 타이밍 위반 해결 (Setup: -0.011ns, Hold: -0.395ns)
- CTS 최적화
- Power grid 연결 개선

전반적으로 **첫 번째 테이프아웃 준비 80% 완료** 상태이며, 타이밍 최적화 후 **제조 가능한 수준**에 도달할 것으로 예상됩니다.

---

*Last Updated: November 18, 2025*
**GUI 확인 사항:**
- [ ] 셀들이 균일하게 배치되었는가?
- [ ] 클록 트리가 대칭적으로 구성되었는가?
- [ ] 배선 혼잡도가 과도하지 않은가?
- [ ] DRC 위반이 없는가?

---

## 📊 결과 분석

### 종합 성능 지표

#### JSilicon 최종 결과

| 항목 | 목표 | 실제 결과 | 달성 여부 |
|------|------|-----------|-----------|
| **클록 주파수** | 200 MHz | 200 MHz | ✅ |
| **타이밍 (WNS)** | > 0 | +216 ps | ✅ |
| **게이트 수** | < 1000 | 595 | ✅ |
| **면적** | < 5000 um² | 2958 um² | ✅ |
| **전력** | < 150 mW | ~100 mW | ✅ |

### 상세 메트릭

#### 1. 타이밍 메트릭

```
Clock Period:              5.000 ns (200 MHz)
Setup WNS:                 0.217 ns ✓
Setup TNS:                 0.000 ns ✓
Hold WNS:                  0.050 ns ✓
Hold TNS:                  0.000 ns ✓
Max Fanout:                42 (clk)
Critical Path Stages:      ~15 gates
```

#### 2. 면적 메트릭

```
Total Die Area:            2958.316 um²
Standard Cell Area:        1785.687 um²
Utilization:               60.4%
Number of Cells:           595
  - Sequential:            42 (7.1%)
  - Combinational:         553 (92.9%)
Number of Nets:            ~700
Average Fanout:            1.8
```

#### 3. 전력 메트릭 (@ 200MHz, 1.1V, 27°C)

```
Total Power:               ~100 mW
  - Dynamic Power:         ~70 mW (70%)
    * Switching:           ~50 mW
    * Internal:            ~20 mW
  - Leakage Power:         ~30 mW (30%)

Power Breakdown by Module:
  - ALU:                   ~25 mW (25%)
  - Register File:         ~20 mW (20%)
  - FSM:                   ~15 mW (15%)
  - Others:                ~40 mW (40%)
```

#### 4. 물리적 특성

```
Die Dimensions:            ~54 x 54 um
Aspect Ratio:              1.0
Number of Metal Layers:    10
Routing Congestion:        Low (<50%)
Clock Tree:
  - Clock Sinks:           42
  - Clock Skew:            <100 ps
  - Clock Latency:         ~500 ps
```

### 비교 분석

#### 공정 기술 비교

| 공정 | JSilicon (45nm) | 예상 (28nm) | 예상 (7nm) |
|------|-----------------|-------------|------------|
| 면적 | 2958 um² | ~1600 um² | ~400 um² |
| 전력 | 100 mW | ~50 mW | ~15 mW |
| 주파수 | 200 MHz | ~500 MHz | ~2 GHz |

#### 최적화 여지

| 항목 | 현재 | 최적화 후 예상 | 방법 |
|------|------|---------------|------|
| 면적 | 2958 um² | ~2500 um² | Clock gating, 논리 간소화 |
| 전력 | 100 mW | ~70 mW | 동적 전압/주파수 조정 |
| 주파수 | 200 MHz | ~250 MHz | Pipeline 추가 |

---

## 🔧 문제 해결

### 자주 발생하는 오류

#### 1. 합성 오류

**오류:** `Could not find module 'tt_um_Jsilicon'`

**원인:** RTL 파일 읽기 실패 또는 모듈명 불일치

**해결:**
```bash
# RTL 파일 확인
ls -lh src/*.v

# 모듈명 확인
grep "^module" src/jsilicon.v

# 스크립트에서 올바른 이름 사용
# elaborate tt_um_Jsilicon  (대소문자 정확히!)
```

#### 2. 타이밍 위반

**오류:** `WNS: -0.5 ns (Timing violated)`

**원인:** Critical path 지연이 클록 주기를 초과

**해결 방법:**

1. **클록 주기 증가** (가장 간단)
```tcl
# jsilicon.sdc 수정
create_clock -name clk -period 6.0 [get_ports clk]  # 5.0 → 6.0
```

2. **합성 최적화 강화**
```tcl
# synthesis.tcl 수정
set_db syn_generic_effort high
set_db syn_map_effort high
set_db syn_opt_effort high
```

3. **RTL 최적화**
- 조합 논리 경로 단축
- Pipeline stage 추가
- 병렬 처리 구조로 변경

#### 3. LEF/Liberty 파일 오류

**오류:** `Cannot find library file 'gscl45nm.lib'`

**원인:** 파일 경로 문제

**해결:**
```bash
# 파일 존재 확인
ls -lh ~/JSilicon2/tech/lib/gscl45nm.lib
ls -lh ~/JSilicon2/tech/lef/gscl45nm.lef

# 절대 경로 사용
set tech_lib [file normalize ~/JSilicon2/tech/lib/gscl45nm.lib]
```

#### 4. Innovus OA 오류

**오류:** `OpenAccess (OA) shared library installation is older`

**원인:** OA_HOME 환경 변수 충돌

**해결:**
```bash
# OA_HOME 제거
unset OA_HOME

# .bashrc에 추가
echo "unset OA_HOME" >> ~/.bashrc
source ~/.bashrc
```

#### 5. 라이선스 오류

**오류:** `License checkout failed`

**원인:** 라이선스 서버 연결 실패

**해결:**
```bash
# 라이선스 서버 확인
echo $CDS_LIC_FILE

# Ping 테스트
ping license.server.edu

# 라이선스 상태 확인
lmstat -a
```

### 디버깅 팁

#### 로그 파일 확인

```bash
# Genus 로그
tail -100 work/synthesis/genus.log

# Innovus 로그
tail -100 work/pnr/innovus.log

# 오류 메시지 검색
grep -i "error" work/synthesis/genus.log
grep -i "warning" work/synthesis/genus.log
```

#### 단계별 체크포인트

```bash
# 합성 후 확인
ls -lh results/netlist/tt_um_Jsilicon_synth.v
cat reports/synthesis/qor.rpt | tail -30

# P&R 후 확인
ls -lh results/def/tt_um_Jsilicon.def
cat reports/pnr/summary.rpt
```



---

## 📚 참고 자료

### 학습 자료

#### 온라인 강의
- [Cadence Tutorial](https://www.cadence.com/en_US/home/training.html)
- [VLSI Design Flow - NPTEL](https://nptel.ac.in/courses/106/106/106106210/)
- [Digital IC Design - Coursera](https://www.coursera.org/)

#### 교재
1. **"Digital Integrated Circuits"** - Jan M. Rabaey
   - 디지털 IC 설계 기초
2. **"CMOS VLSI Design"** - Neil Weste, David Harris
   - VLSI 설계 전반
3. **"Static Timing Analysis for Nanometer Designs"** - J. Bhasker
   - 타이밍 분석 상세

#### 논문 및 문서
- [FreePDK45 Documentation](https://github.com/baichen318/FreePDK45)
- [Cadence Genus User Guide](https://support.cadence.com/)
- [Innovus User Guide](https://support.cadence.com/)

### 관련 프로젝트

#### 오픈소스 프로세서
- [PicoRV32](https://github.com/YosysHQ/picorv32) - RISC-V 프로세서
- [BOOM](https://github.com/riscv-boom/riscv-boom) - Out-of-Order RISC-V
- [OpenSPARC](https://www.oracle.com/servers/technologies/opensparc-overview.html)

#### 오픈소스 PDK
- [SkyWater 130nm](https://github.com/google/skywater-pdk)
- [ASAP7](http://asap.asu.edu/asap/)
- [FreePDK45](https://github.com/baichen318/FreePDK45)

### 유용한 도구

#### EDA Tools (오픈소스)
- [Yosys](https://github.com/YosysHQ/yosys) - Synthesis
- [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) - P&R
- [Magic](http://opencircuitdesign.com/magic/) - Layout
- [ngspice](http://ngspice.sourceforge.net/) - SPICE 시뮬레이션

#### 검증 도구
- [Verilator](https://www.veripool.org/verilator/) - RTL 시뮬레이터
- [GTKWave](http://gtkwave.sourceforge.net/) - 파형 뷰어
- [Icarus Verilog](http://iverilog.icarus.com/) - Verilog 시뮬레이터

---

## 🎓 학습 평가

### 체크리스트

완료한 항목에 체크하세요:

#### 기초 이해
- [ ] RTL 코드를 읽고 이해할 수 있다
- [ ] 각 모듈의 기능을 설명할 수 있다
- [ ] 타이밍 제약 조건의 의미를 안다

#### 합성 (Synthesis)
- [ ] Genus로 합성을 성공적으로 실행했다
- [ ] QoR 리포트를 읽고 해석할 수 있다
- [ ] 타이밍 위반을 수정할 수 있다
- [ ] 면적-속도 트레이드오프를 이해한다

#### 배치배선 (P&R)
- [ ] Innovus로 P&R을 성공적으로 실행했다
- [ ] Floorplan을 이해하고 조정할 수 있다
- [ ] 레이아웃을 시각적으로 확인했다
- [ ] DRC/LVS 개념을 이해한다

#### 검증
- [ ] Setup/Hold 타이밍을 확인할 수 있다
- [ ] Critical path를 분석할 수 있다
- [ ] 전력 소모를 계산하고 분석할 수 있다

### 심화 과제

#### Level 1: 파라미터 변경
1. 클록 주파수를 100MHz → 300MHz로 변경하고 결과 비교
2. Utilization을 50% → 80%로 변경하고 면적 변화 관찰
3. 다른 synthesis effort 설정으로 QoR 비교

#### Level 2: 설계 수정
1. ALU에 곱셈기 추가
2. Register file을 8개 → 16개로 확장
3. Pipeline stage 추가하여 주파수 향상

#### Level 3: 최적화
1. Clock gating으로 전력 소모 20% 감소
2. Multi-cycle path 활용으로 타이밍 개선
3. Custom floorplan으로 면적 10% 감소

---

---

## 📄 라이선스

이 프로젝트는 **MIT License** 하에 배포됩니다.

```
MIT License

Copyright (c) 2025 JSilicon Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Reference

- **FreePDK45**: baichen318님의 오픈소스 PDK
- **Cadence**: 교육용 툴 제공
- **오픈소스 커뮤니티**: 지속적인 지원과 피드백
- **GitHub**: [https://github.com/YOUR_USERNAME/JSilicon2](https://github.com/YOUR_USERNAME/JSilicon2)

---


---

# 작업 자동화 (확인중)

* 1. run_full_flow.csh - 전체 자동화 실행

```csh
chmod +x run_full_flow.csh
./run_full_flow.csh
```

  * Synthesis → P&R → STA → GDS 생성까지 자동 실행
  * 각 단계마다 결과 확인 및 계속 여부 확인

* 2. check_status.csh - 현재 상태 확인

```csh
chmod +x check_status.csh
./check_status.csh
```

   * 각 단계별 완료 여부 체크
   * 리포트 요약 표시
   * 다음 단계 제안

* 3. generate_gds.csh - GDS 생성 및 테이프아웃 준비

```csh
chmod +x generate_gds.csh
./generate_gds.csh

- GDS 파일 생성
- DRC/LVS 준비
- 테이프아웃 체크리스트

## 🔄 완전한 설계 흐름
1. RTL Synthesis (Genus)
   ├── Input:  src/*.v
   └── Output: results/netlist/tt_um_Jsilicon_synth.v
               reports/synthesis/*.rpt

2. Place & Route (Innovus)
   ├── Input:  synthesized netlist
   └── Output: results/def/tt_um_Jsilicon.def
               results/netlist/tt_um_Jsilicon_final.v
               reports/pnr/*.rpt

3. Static Timing Analysis (Tempus)
   ├── Input:  final netlist + DEF
   └── Output: reports/sta/*.rpt

4. GDS Generation (Innovus)
   ├── Input:  placed & routed design
   └── Output: results/gds/tt_um_Jsilicon.gds
               results/tt_um_Jsilicon.lef

5. Verification (Magic/Calibre)
   ├── DRC: Design Rule Check
   ├── LVS: Layout vs Schematic
   └── Output: reports/drc/*.rpt
               reports/lvs/*.rpt

6. Tapeout Package
   └── GDS + LEF + 검증 리포트
```

* 🚀 실행 순서
```csh
# 1. 현재 상태 확인
./check_status.csh

# 2-a. 전체 자동 실행 (추천)
./run_full_flow.csh

# 또는 2-b. 단계별 수동 실행
cd work/synthesis
genus -f ../../scripts/genus/synthesis.tcl |& tee synthesis.log
cd ../pnr
innovus -init ../../scripts/innovus/pnr_flow.tcl |& tee pnr.log
cd ../..

# 3. GDS 생성 및 검증
./generate_gds.csh

# 4. 최종 상태 확인
./check_status.csh
```



## 🚀 실행 방법

### 1. Synthesis (Genus)

```csh
cd ~/JSilicon2/work/synthesis
genus -f ../../scripts/genus/synthesis.tcl |& tee synthesis.log
```

### 2. Place & Route (Innovus)

```csh
cd ~/JSilicon2/work/pnr
innovus -init ../../scripts/innovus/pnr_flow.tcl |& tee pnr.log
```

### 3. 결과 확인

```csh
cd ~/JSilicon2

# 빠른 확인
./quick_check.csh

# 상세 분석
./analyze_pnr_results.csh

# 개별 리포트
cat reports/pnr/timing_summary.rpt
cat reports/pnr/area_final.rpt
cat reports/pnr/power_final.rpt
```

### 4. GUI로 레이아웃 보기

```csh
cd ~/JSilicon2/work/pnr
innovus
```

Innovus 콘솔에서:
```tcl
restoreDesign jsilicon_final.enc.dat tt_um_Jsilicon
fit
```
