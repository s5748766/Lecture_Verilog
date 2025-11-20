# 🏗️ ASIC 레이어 설정 및 Foundry PDK 가이드

## 📋 목차
1. 레이어 설정은 어디서?
2. LEF/DEF 파일 구조
3. Foundry PDK 구성
4. 실제 삼성/TSMC PDK 예시
5. 레이어 할당 전략

---

## 1️⃣ 레이어 설정은 어디서?

### SDC는 타이밍만 담당
```tcl
# SDC (Synopsys Design Constraints)
# - 타이밍 제약만 정의
# - 레이어 정보 없음
create_clock -period 10.0 [get_ports clk]
set_input_delay -max 2.0 [all_inputs]
```

### ✅ 레이어는 LEF + Technology File에서 정의

---

## 2️⃣ LEF (Library Exchange Format) 파일 구조

### A. **Technology LEF** - 레이어 정의

```lef
# tech/lef/technology.lef

VERSION 5.8 ;
BUSBITCHARS "[]" ;
DIVIDERCHAR "/" ;

UNITS
  DATABASE MICRONS 2000 ;    # 1 micron = 2000 DBU
END UNITS

#===============================================================================
# LAYER 정의 - 여기서 레이어 속성 결정!
#===============================================================================

# -------------------------
# Metal 1 (가장 얇은 레이어)
# -------------------------
LAYER metal1
  TYPE ROUTING ;              # 용도: ROUTING (신호선)
  DIRECTION HORIZONTAL ;      # 방향: 수평
  PITCH 0.19 ;               # 트랙 간격 (um)
  WIDTH 0.065 ;              # 최소 선폭 (um)
  SPACING 0.065 ;            # 최소 간격 (um)
  RESISTANCE RPERSQ 0.38 ;   # Sheet resistance (ohm/sq)
  CAPACITANCE CPERSQDIST 0.000250 ; # Capacitance (pF/um²)
  EDGECAPACITANCE 0.0001 ;   # Edge capacitance
  THICKNESS 0.13 ;           # 레이어 두께 (um)
  HEIGHT 0.37 ;              # 레이어 높이 (um)
  
  # 선폭별 저항값 (폭이 넓을수록 저항 낮음)
  RESISTANCETABLE
    ( WIDTH 0.065 RESISTANCE 5.846154 ; )  # 좁은 선: 높은 저항
    ( WIDTH 0.100 RESISTANCE 3.800000 ; )
    ( WIDTH 0.200 RESISTANCE 1.900000 ; )
    ( WIDTH 0.500 RESISTANCE 0.760000 ; )  # 넓은 선: 낮은 저항
  END
END metal1

# -------------------------
# Metal 2 (수직)
# -------------------------
LAYER metal2
  TYPE ROUTING ;
  DIRECTION VERTICAL ;        # 방향: 수직 (Metal1과 직교)
  PITCH 0.19 ;
  WIDTH 0.070 ;
  SPACING 0.070 ;
  RESISTANCE RPERSQ 0.25 ;
  CAPACITANCE CPERSQDIST 0.000200 ;
  THICKNESS 0.14 ;
  HEIGHT 0.77 ;
END metal2

# -------------------------
# Metal 9/10 (전원 레이어)
# -------------------------
LAYER metal9
  TYPE ROUTING ;              # 또는 TYPE POWER ; (일부 PDK)
  DIRECTION HORIZONTAL ;
  PITCH 1.60 ;               # 넓은 간격!
  WIDTH 0.80 ;               # 두꺼운 선!
  SPACING 0.80 ;
  RESISTANCE RPERSQ 0.021 ;  # 낮은 저항 (전원용)
  THICKNESS 0.90 ;           # 두꺼운 레이어
  HEIGHT 5.50 ;
  
  # 전원용 - 넓은 선폭 지원
  RESISTANCETABLE
    ( WIDTH 0.80 RESISTANCE 0.262500 ; )
    ( WIDTH 2.00 RESISTANCE 0.105000 ; )
    ( WIDTH 5.00 RESISTANCE 0.042000 ; )
    ( WIDTH 10.0 RESISTANCE 0.021000 ; )
  END
END metal9

#===============================================================================
# VIA 정의 - 레이어 간 연결
#===============================================================================

VIA M1_M2_via DEFAULT
  LAYER metal1 ;
    RECT -0.065 -0.065 0.065 0.065 ;
  LAYER metal2 ;
    RECT -0.065 -0.065 0.065 0.065 ;
  LAYER via1 ;
    RECT -0.035 -0.035 0.035 0.035 ;
  RESISTANCE 4.0 ;             # Via 저항
END M1_M2_via

#===============================================================================
# SITE 정의 - Standard Cell 배치 그리드
#===============================================================================

SITE CoreSite
  CLASS CORE ;
  SIZE 0.19 BY 1.40 ;          # Site 크기
END CoreSite

END LIBRARY
```

---

### B. **Cell LEF** - 셀 물리 정보

```lef
# libs/lef/standard_cells.lef

MACRO INVX1                    # Inverter cell
  CLASS CORE ;
  ORIGIN 0.0 0.0 ;
  SIZE 0.38 BY 1.40 ;          # Cell 크기
  SYMMETRY X Y ;
  SITE CoreSite ;
  
  # 핀 정의
  PIN A
    DIRECTION INPUT ;
    USE SIGNAL ;
    PORT
      LAYER metal1 ;
        RECT 0.05 0.40 0.15 0.60 ;  # Metal1에 위치
    END
  END A
  
  PIN Y
    DIRECTION OUTPUT ;
    USE SIGNAL ;
    PORT
      LAYER metal1 ;
        RECT 0.23 0.40 0.33 0.60 ;
    END
  END Y
  
  PIN vdd
    DIRECTION INOUT ;
    USE POWER ;                # 전원 핀!
    PORT
      LAYER metal1 ;
        RECT 0.0 1.30 0.38 1.40 ;
    END
  END vdd
  
  PIN gnd
    DIRECTION INOUT ;
    USE GROUND ;               # 그라운드 핀!
    PORT
      LAYER metal1 ;
        RECT 0.0 0.0 0.38 0.10 ;
    END
  END gnd
  
  # Obstruction - 라우팅 금지 영역
  OBS
    LAYER metal1 ;
      RECT 0.10 0.20 0.28 1.20 ;
  END
END INVX1
```

---

## 3️⃣ Foundry PDK 구성

### 실제 Foundry가 제공하는 파일들

```
samsung_28nm_pdk/
├── tech/
│   ├── captable/              # RC 추출용 Capacitance Table
│   │   ├── typical.captable
│   │   ├── worst_case.captable
│   │   └── best_case.captable
│   │
│   ├── lef/                   # 물리 정보
│   │   ├── technology.lef     # 레이어 정의
│   │   ├── stdcells.lef       # Standard cell 물리 정보
│   │   └── io_pads.lef        # I/O pad 정보
│   │
│   ├── tlef/                  # Technology LEF
│   │   └── samsung28_10M.tlef # 10-metal 기술 파일
│   │
│   ├── qrc/                   # Quantus QRC (RC 추출)
│   │   ├── qrcTechFile        # RC 추출 기술 파일
│   │   ├── typical.tch
│   │   ├── worst.tch
│   │   └── best.tch
│   │
│   ├── milkyway/              # Synopsys IC Compiler
│   │   └── technology.tf
│   │
│   ├── drc/                   # Design Rule Check
│   │   ├── calibre.drc        # Mentor Graphics
│   │   ├── icv.drc           # Synopsys ICV
│   │   └── pvs.drc           # Cadence PVS
│   │
│   ├── lvs/                   # Layout vs Schematic
│   │   ├── calibre.lvs
│   │   └── pvs.lvs
│   │
│   └── antenna/               # Antenna rules
│       └── antenna.rules
│
├── libs/
│   ├── timing/                # Timing Library (.lib)
│   │   ├── typical/
│   │   │   ├── sc_typical_1v0_25c.lib
│   │   │   └── sc_typical_1v0_125c.lib
│   │   ├── slow/              # Worst case
│   │   │   └── sc_slow_0v9_125c.lib
│   │   └── fast/              # Best case
│   │       └── sc_fast_1v1_m40c.lib
│   │
│   ├── lef/                   # Cell LEF
│   │   └── sc_all_cells.lef
│   │
│   └── verilog/               # Behavioral models
│       └── sc_all_cells.v
│
└── docs/
    ├── design_rules.pdf       # 설계 규칙 문서
    ├── layer_stack.pdf        # 레이어 스택 정보
    └── process_spec.pdf       # 공정 스펙
```

---

## 4️⃣ 실제 삼성/TSMC PDK 레이어 스택

### A. **삼성 28nm 공정 예시**

```
# samsung_28nm_layer_stack.txt

=============================================================================
Layer Stack (Bottom to Top)
=============================================================================

Layer       Type      Direction   Width    Pitch    Usage            Height
                                  (nm)     (nm)                       (nm)
-----------------------------------------------------------------------------
M1          Routing   H           80       190      Signal/Local     370
M2          Routing   V           90       190      Signal           770
M3          Routing   H           90       190      Signal           1170
M4          Routing   V           140      285      Signal/Clock     1710
M5          Routing   H           140      285      Signal/Clock     2390
M6          Routing   V           140      285      Signal/Power     3070
M7          Routing   H           400      855      Power/Clock      4270
M8          Routing   V           400      855      Power            5970
M9          Routing   H           800      1710     Power            8130
M10 (Top)   Routing   V           800      1710     Power/Global     10640

=============================================================================
Typical Usage:
=============================================================================
M1-M3:      Local signal routing
M4-M6:      Intermediate routing, clock distribution
M7-M8:      Power stripes, long distance signals
M9-M10:     Power grid, global distribution

=============================================================================
Material Properties:
=============================================================================
Metal:      Copper (Cu)
Dielectric: Low-k (k=2.5-3.0)
Barrier:    TaN/Ta (5-10nm)
```

---

### B. **TSMC 7nm 공정 예시**

```
# tsmc_7nm_layer_stack.txt

=============================================================================
TSMC 7nm FinFET - 15 Metal Layers
=============================================================================

Layer   Type      Width    Pitch    Resistance   Usage
                  (nm)     (nm)     (mΩ/sq)
-----------------------------------------------------------------------------
M0A     Signal    18       40       2000         Ultra-local (within cell)
M0B     Signal    18       40       2000         Ultra-local

M1      Signal    28       48       850          Local routing
M2      Signal    28       48       850          Local routing
M3      Signal    28       48       850          Local routing

M4      Signal    36       64       420          Intermediate
M5      Signal    36       64       420          Intermediate
M6      Signal    36       64       420          Clock tree

M7      Signal    72       128      180          Long distance
M8      Signal    72       128      180          Power stripes
M9      Signal    72       128      180          Power stripes

M10     Power     144      256      80           Power grid
M11     Power     144      256      80           Power grid
M12     Power     288      512      40           Top power
M13     Top       288      512      40           RDL (Redistribution)

AP (Alucap)  Top   -       -        20           Top metal (thick)

=============================================================================
Design Rules Summary:
=============================================================================
Min Metal Width:        18nm  (M0)
Min Metal Spacing:      18nm  (M0)
Min Via Size:           18nm x 18nm
Max Aspect Ratio:       3:1   (Height/Width)

Recommended Power Layers:  M10-M13
Recommended Clock Layers:  M6-M9
Recommended Signal:        M1-M8
```

---

## 5️⃣ 레이어 할당 전략 (Innovus/ICC)

### A. **P&R 스크립트에서 레이어 할당**

```tcl
# scripts/innovus/pnr_flow.tcl

#===============================================================================
# Power Planning - 레이어 할당
#===============================================================================

# 전원 레이어 지정
set power_layers {metal9 metal10}
set signal_layers {metal1 metal2 metal3 metal4 metal5 metal6 metal7 metal8}

# Core Ring - 최상위 레이어 사용
addRing \
    -nets {vdd gnd} \
    -type core_rings \
    -layer {top metal10 bottom metal10 left metal9 right metal9} \
    -width {top 5.0 bottom 5.0 left 5.0 right 5.0} \
    -spacing {top 2.0 bottom 2.0 left 2.0 right 2.0} \
    -offset 10.0

# Power Stripes - 수직/수평 교차
addStripe \
    -nets {vdd gnd} \
    -layer metal9 \              # 수평 stripe
    -direction horizontal \
    -width 2.0 \
    -spacing 2.0 \
    -set_to_set_distance 50.0

addStripe \
    -nets {vdd gnd} \
    -layer metal10 \             # 수직 stripe
    -direction vertical \
    -width 2.0 \
    -spacing 2.0 \
    -set_to_set_distance 50.0

#===============================================================================
# Routing - 신호선 레이어 할당
#===============================================================================

# 레이어별 라우팅 방향 설정 (이미 LEF에 정의되어 있음)
setNanoRouteMode \
    -routeTopRoutingLayer metal8 \      # 신호선은 M8까지만
    -routeBottomRoutingLayer metal1 \   # M1부터 시작
    -drouteEndIteration 10 \
    -drouteUseMultiCutViaEffort high

# 클럭 라우팅 - 특정 레이어 선호
setCTSMode \
    -routeTopPreferredLayer metal7 \
    -routeBottomPreferredLayer metal3 \
    -routeLeafTopLayer metal5 \
    -routeLeafBottomLayer metal2

#===============================================================================
# 레이어별 용도 제한
#===============================================================================

# Metal 1-3: 짧은 local routing만
setLayerPreference metal1 -isRoutingDir horizontal -effort low
setLayerPreference metal2 -isRoutingDir vertical -effort low
setLayerPreference metal3 -isRoutingDir horizontal -effort low

# Metal 4-6: 중간 거리 routing, clock 가능
setLayerPreference metal4 -isRoutingDir vertical -effort medium
setLayerPreference metal5 -isRoutingDir horizontal -effort medium
setLayerPreference metal6 -isRoutingDir vertical -effort high

# Metal 7-8: 긴 거리 routing
setLayerPreference metal7 -isRoutingDir horizontal -effort high
setLayerPreference metal8 -isRoutingDir vertical -effort high

# Metal 9-10: 전원 전용 (신호 라우팅 금지)
# routeTopRoutingLayer를 metal8로 설정했으므로 자동으로 제외됨
```

---

## 6️⃣ Foundry가 제공하는 가이드 문서

### A. **Design Rule Manual (DRM)**

```
Samsung 28nm Design Rule Manual (DRM)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Layer Stack Information
   - 레이어 수: 10 metal layers
   - 레이어 두께, 간격, 저항, 정전용량
   - Via 크기 및 저항

2. Minimum Design Rules
   Rule        Metal1   Metal2   ...   Metal9   Metal10
   ───────────────────────────────────────────────────
   Min Width   80nm     90nm           400nm    800nm
   Min Space   80nm     90nm           400nm    800nm
   Min Area    0.0064   0.0081         0.16     0.64 um²

3. Via Rules
   - M1-M2 via: 70nm x 70nm
   - M9-M10 via: 400nm x 400nm
   - Via resistance: 4-8 ohm

4. Density Rules
   - Min metal density: 20%
   - Max metal density: 80%
   - Check window: 100um x 100um

5. Antenna Rules
   - Antenna ratio: < 400:1 (Metal1-3)
   - Antenna ratio: < 800:1 (Metal4-10)

6. Power Grid Guidelines
   - Use M9-M10 for power grid
   - Stripe width: > 2um
   - Stripe spacing: < 100um
```

---

### B. **Process Design Kit (PDK) User Guide**

```
TSMC 7nm FinFET PDK User Guide
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Chapter 5: Metal Stack Recommendation

5.1 Signal Routing
    ✓ M1-M8:   General signal routing
    ✓ M4-M6:   Clock distribution (prefer M6)
    ✓ M7-M8:   Long distance signals
    ✗ M9-M13:  Do NOT use for signals (power only)

5.2 Power Distribution
    ✓ M10-M13: Core power grid
    ✓ M9:      Power stripes
    ✓ M7-M8:   Local power distribution
    ✗ M1-M6:   Insufficient for power (too thin)

5.3 Clock Distribution
    Recommended: M4, M5, M6
    - Low RC for better skew
    - Medium layers for balanced routing
    - Use M6 for global clock trunk
    - Use M4-M5 for local clock distribution

5.4 Via Guidelines
    - Double cut via: recommended for critical paths
    - Single cut via: acceptable for non-critical
    - Redundant via: mandatory for power/ground

5.5 Metal Density
    Target: 40-60% per layer
    - Use metal fill for compliance
    - Automated by PVS/ICV tools
```

---

## 7️⃣ 실제 작업 플로우

### Step 1: Foundry PDK 받기
```bash
# NDA 계약 후 다운로드 (예: 삼성)
samsung_pdk_portal.com
├── Login with NDA account
├── Select process: 28nm FD-SOI
├── Download PDK package (50-100 GB)
└── Install license files
```

### Step 2: PDK Import
```bash
# Innovus에서 PDK 설정
cd /project/tech

# Technology LEF 복사
cp $PDK_HOME/tech/lef/samsung28_10M.tlef ./lef/

# Timing library 복사
cp $PDK_HOME/libs/timing/typical/*.lib ./lib/

# QRC tech file 복사
cp $PDK_HOME/tech/qrc/typical.tch ./qrc/
```

### Step 3: MMMC 설정
```tcl
# mmmc.tcl - 레이어 정보 자동으로 LEF에서 로드됨

# RC corner에 QRC tech file 연결
create_rc_corner -name RC_TYP \
    -qrc_tech $PDK_HOME/tech/qrc/typical.tch \
    -temperature 25

# Multi-corner 설정
create_rc_corner -name RC_WORST \
    -qrc_tech $PDK_HOME/tech/qrc/worst.tch \
    -temperature 125

create_rc_corner -name RC_BEST \
    -qrc_tech $PDK_HOME/tech/qrc/best.tch \
    -temperature -40
```

---

## 8️⃣ 레이어 선택 기준 요약

| 레이어 범위 | 주 용도 | 선폭 | 저항 | 비고 |
|-------------|---------|------|------|------|
| **M1-M3** | Local routing | 좁음 | 높음 | Cell 내부, 짧은 연결 |
| **M4-M6** | Intermediate | 중간 | 중간 | Clock tree, 중거리 신호 |
| **M7-M8** | Long distance | 넓음 | 낮음 | 긴 신호선, 일부 전원 |
| **M9-M10+** | Power grid | 매우 넓음 | 매우 낮음 | 전원/그라운드 전용 |

---

## 📌 핵심 정리

1. **SDC는 타이밍만!** 레이어 설정과 무관
2. **LEF 파일**에서 모든 레이어 속성 정의
3. **Foundry PDK**가 모든 정보 제공
4. **삼성/TSMC** 등은 상세한 가이드와 함께 PDK 제공
5. **P&R Tool**에서 레이어별 용도 할당

---

**참고 문서**: 
- [TIMING_ANALYSIS.md](computer:///mnt/user-data/outputs/TIMING_ANALYSIS.md)
- Cadence LEF/DEF Language Reference Manual
- TSMC Design Rule Manual (NDA 필요)
- Samsung Foundry PDK User Guide (NDA 필요)
