# Process Design Kit (PDK) 종합 가이드
## 반도체 공정 기술과 PDK 완벽 이해

[![PDK](https://img.shields.io/badge/Topic-PDK-blue.svg)]()
[![Education](https://img.shields.io/badge/Purpose-Education-green.svg)]()
[![Updated](https://img.shields.io/badge/Updated-2025--11-orange.svg)]()

---

## 📚 목차

1. [PDK란 무엇인가?](#-pdk란-무엇인가)
2. [PDK의 구성 요소](#-pdk의-구성-요소)
3. [오픈소스 PDK](#-오픈소스-pdk)
4. [상용 PDK](#-상용-pdk)
5. [PDK 비교표](#-pdk-비교표)
6. [PDK 선택 가이드](#-pdk-선택-가이드)
7. [실습 및 교육용 PDK](#-실습-및-교육용-pdk)
8. [FAQ](#-자주-묻는-질문)

---

## 🎓 PDK란 무엇인가?

### 정의

**PDK (Process Design Kit)**는 특정 반도체 제조 공정에서 칩을 설계하기 위해 필요한 모든 기술 정보와 도구를 포함한 패키지입니다.

```
┌─────────────────────────────────────────────────┐
│                    PDK                          │
│  (Process Design Kit)                           │
├─────────────────────────────────────────────────┤
│                                                 │
│  📊 Technology Files    (공정 파라미터)          │
│  📐 Design Rules        (설계 규칙)             │
│  📚 Device Models       (소자 모델)             │
│  🎨 Physical Libraries  (물리 라이브러리)        │
│  📖 Documentation       (문서)                  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### PDK의 역할

| 역할 | 설명 | 예시 |
|------|------|------|
| **기술 정보 제공** | 공정 파라미터, 특성 | 금속층 개수, 최소 선폭 |
| **설계 규칙** | Layout 설계 제약 | DRC (Design Rule Check) |
| **소자 모델** | 트랜지스터 특성 | SPICE 모델, BSIM |
| **표준 셀 라이브러리** | 미리 설계된 게이트 | NAND, NOR, FF 등 |
| **검증 도구** | DRC, LVS 룰 덱 | Calibre, PVS 룰 |

---

## 🔧 PDK의 구성 요소

### 1. Technology Files

공정 기술 정보를 담은 파일들:

```
Technology Files
├── Technology LEF (.tlef)
│   ├─ Metal layer 정보 (개수, 두께, 저항)
│   ├─ Via 정보
│   └─ Site 정의
│
├── Technology Library (.lib)
│   ├─ 타이밍 정보
│   ├─ 전력 정보
│   └─ PVT variation
│
└── Technology File (.tf)
    ├─ Cadence Virtuoso용
    └─ Layer 정의, 색상 등
```

**주요 파라미터:**
- **최소 선폭 (Minimum Width)**: 7nm, 14nm, 28nm, 45nm, 130nm...
- **금속층 개수**: 4~15층
- **전원 전압**: 0.7V ~ 1.8V
- **온도 범위**: -40°C ~ 125°C

### 2. Design Rule Manual (DRM)

레이아웃 설계 시 지켜야 할 규칙:

```
Design Rules
├── Minimum Width       (최소 선폭)
├── Minimum Spacing     (최소 간격)
├── Minimum Enclosure   (최소 둘러싸기)
├── Minimum Area        (최소 면적)
├── Density Rules       (밀도 규칙)
└── Antenna Rules       (안테나 규칙)
```

**예시 (FreePDK45):**
```
Metal 1:
  Minimum Width:    0.065 um
  Minimum Spacing:  0.065 um
  Minimum Area:     0.0676 um²

Metal 2:
  Minimum Width:    0.07 um
  Minimum Spacing:  0.07 um
```

### 3. Device Models

트랜지스터 및 수동 소자의 전기적 특성:

| 모델 타입 | 용도 | 파일 형식 |
|-----------|------|-----------|
| **SPICE Model** | Analog 시뮬레이션 | .spi, .cir |
| **BSIM Model** | 디지털 시뮬레이션 | .lib |
| **Verilog-A** | Mixed-signal | .va |
| **Liberty (.lib)** | 타이밍 분석 | .lib |

**MOSFET 모델 예시:**
```spice
.model nmos nmos (
+    level   = 54
+    lmin    = 5e-08
+    wmin    = 1e-07
+    tox     = 1.8e-09
+    vth0    = 0.45
+    ...
)
```

### 4. Standard Cell Library

미리 설계된 디지털 논리 게이트:

```
Standard Cell Library
├── Combinational Cells
│   ├─ NAND2, NAND3, NAND4
│   ├─ NOR2, NOR3, NOR4
│   ├─ AND, OR, XOR
│   ├─ INV (Inverter)
│   └─ MUX, AOI, OAI
│
├── Sequential Cells
│   ├─ DFF (D Flip-flop)
│   ├─ DFFR (with Reset)
│   ├─ LATCH
│   └─ SDFF (Scan FF)
│
└── Special Cells
    ├─ FILL (Filler)
    ├─ DECAP (Decoupling)
    ├─ TIE (Tie high/low)
    └─ ANTENNA
```

**셀 정보 형식:**
- **LEF (Library Exchange Format)**: 물리 정보
- **Liberty (.lib)**: 타이밍/전력 정보
- **GDS/OASIS**: 실제 레이아웃
- **Verilog**: 기능 모델

### 5. I/O Pads

칩과 외부를 연결하는 패드:

| 패드 타입 | 기능 | 특징 |
|-----------|------|------|
| **Input Pad** | 신호 입력 | ESD 보호 포함 |
| **Output Pad** | 신호 출력 | 큰 구동 능력 |
| **Bidirectional Pad** | 양방향 | I/O 겸용 |
| **Power Pad** | 전원/접지 | 큰 전류 용량 |
| **Corner Pad** | 코너 보호 | 기계적 강도 |

### 6. Verification Decks

설계 검증을 위한 룰 파일:

```
Verification
├── DRC (Design Rule Check)
│   └─ Calibre/PVS 룰 파일
│
├── LVS (Layout vs Schematic)
│   └─ 넷리스트 비교 룰
│
├── PEX (Parasitic Extraction)
│   └─ RC 추출 룰
│
└── Antenna Check
    └─ 안테나 효과 검증
```

---

## 🌍 오픈소스 PDK

### 1. FreePDK45

#### 개요
- **공정**: 45nm (Predictive)
- **개발**: North Carolina State University
- **라이선스**: Open Source
- **용도**: 교육 및 연구

#### 특징

```yaml
Technology: 45nm CMOS
Metal Layers: 10 (M1~M10)
Minimum Width: 65nm (Metal 1)
Supply Voltage: 1.1V
Gate Length: 45nm
Standard Cells: ~200개
I/O Voltage: 1.1V / 2.5V
```

#### 장점
- ✅ **무료 사용**: 라이선스 불필요
- ✅ **교육용 최적**: 대학 강의에 적합
- ✅ **잘 문서화**: 상세한 매뉴얼
- ✅ **툴 지원**: Cadence, Synopsys 호환

#### 단점
- ❌ **제조 불가**: Predictive model
- ❌ **제한된 라이브러리**: 기본 셀만 제공
- ❌ **구식 공정**: 현대 공정 대비 낮은 성능

#### 파일 구조
```
FreePDK45/
├── ncsu_basekit/
│   ├── techfile/
│   ├── models/
│   └── doc/
├── osu_soc/
│   ├── lib/
│   │   ├── files/
│   │   │   ├── gscl45nm.lib    (Liberty)
│   │   │   └── gscl45nm.lef    (LEF)
│   │   └── source/
│   └── flow/
└── README
```

#### 사용 예시
```bash
# JSilicon 프로젝트에서 사용
cp FreePDK45/osu_soc/lib/files/gscl45nm.lib tech/lib/
cp FreePDK45/osu_soc/lib/files/gscl45nm.lef tech/lef/
```

#### 다운로드
```bash
git clone https://github.com/baichen318/FreePDK45.git
```

---

### 2. SkyWater SKY130

#### 개요
- **공정**: 130nm CMOS
- **개발**: SkyWater Technology + Google
- **라이선스**: Apache 2.0
- **용도**: **실제 제조 가능** 🎉

#### 특징

```yaml
Technology: 130nm CMOS/SOI
Metal Layers: 5 (M1~M5)
Minimum Width: 150nm
Supply Voltage: 1.8V / 3.3V / 5.0V
Standard Cells: 1000+ 개
Analog Components: Yes
Mixed-Signal: Yes
Special Features:
  - High Voltage (20V)
  - SRAM
  - Resistors, Capacitors
  - Varactors
```

#### 장점
- ✅ **실제 제조 가능**: Shuttle program 통해 제조
- ✅ **무료 오픈소스**: Apache 2.0
- ✅ **풍부한 라이브러리**: 1000+ 표준 셀
- ✅ **Analog 지원**: Mixed-signal 설계 가능
- ✅ **활발한 커뮤니티**: Google, efabless 지원
- ✅ **완전한 PDK**: 실제 파운드리 수준

#### 단점
- ❌ **구형 공정**: 130nm (성능 제한)
- ❌ **복잡한 구조**: 초보자에게 어려움
- ❌ **큰 용량**: 수십 GB

#### 주요 컴포넌트

| 카테고리 | 항목 | 수량 |
|----------|------|------|
| **Digital** | Standard Cells (HD) | 400+ |
| | Standard Cells (HS) | 400+ |
| | Standard Cells (MS) | 300+ |
| | Standard Cells (LS) | 300+ |
| **Analog** | Primitives | 100+ |
| **I/O** | Pads | 50+ |
| **Special** | SRAM | Multiple sizes |
| | ESD Protection | Yes |

**셀 라이브러리 종류:**
- **sky130_fd_sc_hd**: High Density (기본)
- **sky130_fd_sc_hs**: High Speed
- **sky130_fd_sc_ms**: Medium Speed
- **sky130_fd_sc_ls**: Low Speed (저전력)
- **sky130_fd_sc_hdll**: High Density Low Leakage

#### 파일 구조
```
skywater-pdk/
├── libraries/
│   ├── sky130_fd_sc_hd/        (Standard Cells)
│   │   ├── latest/
│   │   │   ├── cells/          (각 셀별 GDS, LEF)
│   │   │   ├── timing/         (Liberty 타이밍)
│   │   │   └── techlef/        (Technology LEF)
│   │   └── docs/
│   ├── sky130_fd_io/           (I/O Cells)
│   ├── sky130_fd_pr/           (Primitives)
│   └── sky130_sram/            (SRAM)
├── scripts/
└── docs/
```

#### 제조 방법 (Tapeout)
```
설계 → efabless Platform → Caravel SoC → Google Shuttle
                                              ↓
                                         실제 칩 제조!
                                      (무료 또는 저렴)
```

**제조 프로그램:**
- **Google Open MPW**: 무료 (선발)
- **efabless ChipIgnite**: 유료 (~$10,000)

#### 사용 예시
```bash
# PDK 설치
git clone https://github.com/google/skywater-pdk.git
cd skywater-pdk
git submodule update --init libraries/sky130_fd_sc_hd/latest

# OpenLane으로 합성
make mount
./flow.tcl -design spm
```

#### 지원 도구
- **OpenLane**: 완전 오픈소스 RTL-to-GDS
- **Magic**: Layout editor
- **KLayout**: GDS viewer/editor
- **Xschem**: Schematic editor
- **ngspice**: SPICE simulator

#### 다운로드
```bash
git clone https://github.com/google/skywater-pdk.git
# 또는
git clone https://github.com/RTimothyEdwards/open_pdks.git
```

#### 참고 링크
- 공식 저장소: https://github.com/google/skywater-pdk
- 문서: https://skywater-pdk.readthedocs.io/
- efabless: https://efabless.com/

---

### 3. ASAP7

#### 개요
- **공정**: 7nm FinFET (Predictive)
- **개발**: Arizona State University
- **라이선스**: Educational
- **용도**: 연구 및 교육 (최신 공정)

#### 특징

```yaml
Technology: 7nm FinFET
Metal Layers: 9 (M1~M9)
Minimum Pitch: 48nm (M2)
Supply Voltage: 0.7V
Gate Pitch: 54nm
Fin Pitch: 27nm
Standard Cells: 500+
Advanced Features:
  - FinFET modeling
  - Multi-Vt cells
  - Advanced DFM
```

#### 장점
- ✅ **최신 공정**: 7nm FinFET
- ✅ **FinFET 학습**: 현대 트랜지스터 구조
- ✅ **무료 교육용**: 연구/교육 가능
- ✅ **현실적 모델**: Industry calibrated

#### 단점
- ❌ **제조 불가**: Predictive model
- ❌ **복잡함**: FinFET 이해 필요
- ❌ **제한적 지원**: 일부 툴만 지원

#### 파일 구조
```
asap7/
├── asap7libs/
│   ├── asap7sc7p5t_27/     (Standard Cell)
│   │   ├── LIB/
│   │   ├── LEF/
│   │   ├── GDS/
│   │   └── CDL/
│   └── asap7sc7p5t_28/
├── techlef/
├── models/
└── doc/
```

#### 다운로드
```bash
# 등록 필요
http://asap.asu.edu/asap/
```

---

### 4. FreePDK15

#### 개요
- **공정**: 15nm FinFET (Predictive)
- **개발**: North Carolina State University
- **라이선스**: Open Source
- **용도**: 교육 및 연구

#### 특징

```yaml
Technology: 15nm FinFET
Metal Layers: 10
Supply Voltage: 0.8V
Standard Cells: 200+
FinFET: Yes
```

#### 장점
- ✅ **FinFET 교육**: FreePDK45보다 현대적
- ✅ **무료**: 라이선스 불필요
- ✅ **FreePDK 호환**: 45nm 경험자에게 친숙

#### 단점
- ❌ **제한적 지원**: 덜 성숙함
- ❌ **제조 불가**: Predictive

---

## 🏢 상용 PDK

### 1. TSMC PDK

#### 개요
- **회사**: Taiwan Semiconductor Manufacturing Company
- **시장 점유율**: ~60% (세계 1위)
- **주요 고객**: Apple, NVIDIA, AMD, Qualcomm

#### 제공 공정

| 노드 | 기술 | 상태 | 주요 제품 |
|------|------|------|-----------|
| **3nm** | N3E FinFET | 양산 | Apple A17 Pro, M3 |
| **5nm** | N5, N5P | 양산 | Apple A14~A16, M1~M2 |
| **7nm** | N7, N7P, N7+ | 양산 | AMD Ryzen 3000/5000 |
| **16nm** | N16 FinFET+ | 양산 | 중급 프로세서 |
| **28nm** | 28HPC+, 28LP | 성숙 | IoT, MCU |
| **40nm** | 40LP, 40G | 성숙 | 범용 IC |

#### PDK 구성

```
TSMC PDK
├── Technology Files
│   ├─ TLU+ (Interconnect RC)
│   ├─ ITF (Interconnect Tech File)
│   └─ NXTGRD (Advanced routing)
│
├── Device Models
│   ├─ HSPICE
│   ├─ Spectre
│   └─ BSIM
│
├── Standard Cell Libraries
│   ├─ TCBN (Core)
│   ├─ TCBN9 (9-track)
│   ├─ TCBN7 (7-track)
│   └─ Special variants
│
├── Memory Compilers
│   ├─ SRAM
│   ├─ Register File
│   └─ ROM
│
└── I/O Libraries
    ├─ GPIO
    ├─ High-Speed I/O
    └─ Analog I/O
```

#### 특징

**기술적 우위:**
- ✅ 최첨단 공정 (3nm, 2nm 개발 중)
- ✅ 풍부한 IP 라이브러리
- ✅ 우수한 수율 (Yield)
- ✅ 완벽한 EDA 툴 지원

**비즈니스:**
- 💰 **높은 비용**: 마스크 세트 ~$5M (5nm)
- 💰 **NRE 비용**: ~$50M (전체 tapeout)
- 📋 **엄격한 NDA**: 비공개 정보
- 🎓 **교육 프로그램**: 대학에 제한적 제공

#### 접근 방법

1. **상용 설계**: Fabless 회사로 직접 계약
2. **교육**: University Program (제한적)
3. **MPW**: Multi-Project Wafer (공유)
4. **Shuttle**: CMP (Circuit Multi-Projet)

---

### 2. Samsung Foundry PDK

#### 개요
- **회사**: 삼성전자
- **시장 점유율**: ~17% (세계 2위)
- **주요 고객**: Qualcomm, IBM, NVIDIA

#### 제공 공정

| 노드 | 기술 | 상태 | 특징 |
|------|------|------|------|
| **3nm** | GAA (MBCFET) | 양산 | Gate-All-Around |
| **4nm** | 4LPP | 양산 | Qualcomm 8 Gen 2 |
| **5nm** | 5LPE, 5LPP | 양산 | Exynos 2100 |
| **7nm** | 7LPP | 양산 | - |
| **8nm** | 8LPP | 양산 | NVIDIA GPU |
| **14nm** | 14LPC, 14LPP | 양산 | - |
| **28nm** | 28FDS | 성숙 | FD-SOI |

#### 특징

**혁신적 기술:**
- ✅ **GAA 기술**: 3nm부터 Gate-All-Around
- ✅ **FD-SOI**: 28nm FD-SOI (저전력)
- ✅ **RF 공정**: RF 특화 PDK

**한국 장점:**
- ✅ 국내 기업 접근성 좋음
- ✅ 정부 지원 프로그램
- ✅ 대학 협력 활발

**비용:**
- 💰 TSMC와 유사한 수준
- 📋 NDA 필요

#### 접근 방법

1. **IDEC**: 한국 대학/연구소 지원
   - IC Design Education Center
   - MPW 프로그램
   - 무료/저비용 제조

2. **Samsung Foundry Direct**: 상용

---

### 3. Intel PDK

#### 개요
- **회사**: Intel Corporation
- **전략**: IDM → Foundry 전환 중
- **프로그램**: Intel Foundry Services (IFS)

#### 제공 공정

| 노드 | 이름 | 상태 | 특징 |
|------|------|------|------|
| **Intel 4** | 7nm 급 | 양산 | Meteor Lake |
| **Intel 3** | 5nm 급 | 개발 | - |
| **Intel 20A** | 2nm 급 | 개발 | GAA + PowerVia |
| **Intel 18A** | 1.8nm 급 | 개발 | - |
| **22FFL** | 22nm | 양산 | 저전력 IoT |

#### 특징

**차별화:**
- ✅ **RibbonFET**: Intel의 GAA
- ✅ **PowerVia**: 뒷면 전원 공급
- ✅ **EMIB, Foveros**: 3D 패키징

**접근:**
- 🔒 제한적 (Foundry 사업 초기)
- 💰 높은 비용

---

### 4. GlobalFoundries (GF) PDK

#### 개요
- **회사**: GlobalFoundries
- **전략**: 선단 공정 포기, 특화 공정 집중
- **시장**: 성숙 공정 전문

#### 제공 공정

| 노드 | 기술 | 용도 |
|------|------|------|
| **12nm** | 12LP+ | 고성능 |
| **14nm** | 14LPP | - |
| **22nm** | 22FDX | FD-SOI (저전력) |
| **28nm** | 28SLP | 범용 |
| **40nm** | 40LP | 범용 |
| **45nm** | 45RFSOI | RF, Analog |
| **55nm** | 55LPe | 전력 IC |
| **90nm** | 90LP | 성숙 |
| **130nm** | 130nm | Analog |
| **180nm** | 180nm | 전력, Analog |

#### 특징

**강점:**
- ✅ **FD-SOI**: 22FDX (초저전력)
- ✅ **RF/Analog**: 특화 공정
- ✅ **Automotive**: 차량용 인증
- ✅ **안정적 공급**: 성숙 공정

**비용:**
- 💰 선단 공정 대비 저렴
- 🎓 대학 MPW 지원

---

### 5. UMC (United Microelectronics) PDK

#### 개요
- **회사**: 대만 UMC
- **시장 점유율**: ~7%
- **전략**: 성숙 공정 전문

#### 제공 공정

```
28nm: 28HPC+, 28LP
40nm: 40LP, 40LL
55nm: 55LLP, 55ULP
65nm: 65LP
90nm: 90SP, 90G
110nm: 110LL
130nm: 130HS
180nm: 180G
```

#### 특징
- ✅ 성숙 공정 안정적
- ✅ 비용 효율적
- ✅ 아시아 foundry

---

## 📊 PDK 비교표

### 종합 비교

| PDK | 공정 | 제조 가능 | 비용 | 난이도 | 용도 | 추천 대상 |
|-----|------|-----------|------|--------|------|-----------|
| **FreePDK45** | 45nm | ❌ | 무료 | ⭐⭐ | 교육 | 대학생, 입문자 |
| **SKY130** | 130nm | ✅ | 무료~저가 | ⭐⭐⭐ | 교육, 실습 | 취미, 스타트업 |
| **ASAP7** | 7nm | ❌ | 무료 | ⭐⭐⭐⭐ | 연구 | 대학원, 연구소 |
| **TSMC** | 3~180nm | ✅ | 매우 높음 | ⭐⭐⭐⭐⭐ | 상용 | Fabless 회사 |
| **Samsung** | 3~28nm | ✅ | 매우 높음 | ⭐⭐⭐⭐⭐ | 상용 | Fabless 회사 |
| **Intel** | Intel 4~22nm | ✅ | 높음 | ⭐⭐⭐⭐⭐ | 상용 | 대기업 |
| **GF** | 12~180nm | ✅ | 중간~높음 | ⭐⭐⭐⭐ | 특수 | Automotive, RF |

### 기술 스펙 비교

| 항목 | FreePDK45 | SKY130 | ASAP7 | TSMC 5nm | Samsung 5nm |
|------|-----------|--------|-------|----------|-------------|
| **최소 선폭** | 65nm | 150nm | 48nm | ~30nm | ~32nm |
| **금속층** | 10 | 5 | 9 | 15+ | 13+ |
| **전압** | 1.1V | 1.8V | 0.7V | 0.75V | 0.75V |
| **트랜지스터** | Planar | Planar | FinFET | FinFET | FinFET |
| **표준 셀** | 200+ | 1000+ | 500+ | 10000+ | 10000+ |
| **SRAM** | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Analog** | Limited | ✅ | Limited | ✅ | ✅ |
| **I/O Voltage** | 2.5V | 5V | 0.7V | 1.8V | 1.8V |

### 성능 비교 (동일 설계 기준)

| PDK | 주파수 | 전력 | 면적 | 트랜지스터 밀도 |
|-----|--------|------|------|-----------------|
| **FreePDK45** | 1.0x | 1.0x | 1.0x | 1.0x |
| **SKY130** | 0.3x | 2.5x | 6.5x | 0.15x |
| **ASAP7** | 3.0x | 0.3x | 0.05x | 20x |
| **TSMC 5nm** | 2.8x | 0.4x | 0.06x | 16x |
| **Samsung 5nm** | 2.7x | 0.45x | 0.07x | 14x |

*기준: FreePDK45 = 1.0x*

### 비용 비교 (Tapeout)

| PDK | Mask Cost | Wafer Cost | NRE | Total (200 chips) |
|-----|-----------|------------|-----|-------------------|
| **FreePDK45** | N/A | N/A | $0 | **$0** (제조 불가) |
| **SKY130** | ~$10K | ~$25K | ~$10K | **~$45K** |
| **TSMC 28nm** | ~$300K | ~$3K/ea | ~$500K | **~$800K** |
| **TSMC 7nm** | ~$3M | ~$16K/ea | ~$10M | **~$13M** |
| **TSMC 5nm** | ~$5M | ~$18K/ea | ~$50M | **~$55M** |
| **Samsung 5nm** | ~$4M | ~$17K/ea | ~$45M | **~$49M** |

*NRE: Non-Recurring Engineering*

---

## 🎯 PDK 선택 가이드

### 의사결정 트리

```
PDK 선택
    │
    ├─ 제조가 필요한가?
    │   ├─ YES ──→ 실제 칩 필요
    │   │           │
    │   │           ├─ 예산 있음 ($50M+) → TSMC/Samsung 선단
    │   │           ├─ 예산 중간 ($1M+) → TSMC 28nm, GF
    │   │           └─ 예산 적음 (<$100K) → SKY130
    │   │
    │   └─ NO ───→ 교육/연구만
    │               │
    │               ├─ 최신 공정 배우기 → ASAP7
    │               ├─ 기초 배우기 → FreePDK45
    │               └─ 실습 중심 → SKY130
    │
    └─ 무엇을 만들까?
        │
        ├─ Digital IC → TSMC, Samsung (고성능)
        │               FreePDK45 (교육)
        │
        ├─ Mixed-Signal → SKY130, GF
        │                  TSMC (상용)
        │
        ├─ RF/Wireless → GF 45RFSOI
        │                 Samsung RF
        │
        ├─ Automotive → GF, TSMC
        │
        └─ IoT/Low Power → Samsung FD-SOI
                            GF 22FDX
```

### 용도별 추천

#### 1. 대학 교육

**추천: FreePDK45**
```
✓ 무료
✓ 간단한 구조
✓ 잘 문서화됨
✓ 빠른 시뮬레이션
✓ 대부분의 EDA 툴 지원

수업 예시:
- VLSI 설계 입문
- 디지털 IC 설계
- RTL-to-GDS 플로우
```

**보조: SKY130**
```
✓ 실제 제조 가능
✓ 오픈소스 툴 사용
✓ 풍부한 컴포넌트

프로젝트 예시:
- Senior Capstone
- 실습 프로젝트
```

#### 2. 대학원 연구

**추천: ASAP7**
```
✓ 최신 공정 (7nm FinFET)
✓ 논문 발표용
✓ 선단 공정 연구

연구 주제:
- Low power design
- Machine learning accelerator
- Novel architecture
```

**대안: TSMC University Program**
```
✓ 실제 foundry PDK
✓ MPW 프로그램
✗ 승인 필요
```

#### 3. 스타트업 / 소규모 회사

**추천: SKY130**
```
✓ 낮은 진입 장벽
✓ 실제 제조 가능
✓ 빠른 프로토타이핑

적합 제품:
- IoT 센서
- 교육용 칩
- Open hardware
```

**성장 후: TSMC 28nm/40nm**
```
✓ 성능 개선
✓ 대량 생산
✗ 높은 초기 비용
```

#### 4. 중견 Fabless

**추천: TSMC 28nm ~ 7nm**
```
✓ 검증된 공정
✓ 좋은 수율
✓ 풍부한 IP

제품 예시:
- SoC
- Processor
- ASIC
```

**고려: Samsung, GF**
```
✓ 다변화
✓ 협상력
```

#### 5. 대기업

**추천: TSMC/Samsung 5nm 이하**
```
✓ 최고 성능
✓ 경쟁력
✓ 브랜드 가치

제품:
- Flagship SoC
- AI accelerator
- HPC
```

---

## 🎓 실습 및 교육용 PDK

### 교육 목적별 선택

| 학습 목표 | 추천 PDK | 이유 |
|-----------|----------|------|
| **VLSI 기초** | FreePDK45 | 간단, 빠름 |
| **RTL-to-GDS 플로우** | FreePDK45 | 전체 플로우 체험 |
| **FinFET 이해** | ASAP7 | 최신 트랜지스터 |
| **실제 칩 제작** | SKY130 | Tapeout 가능 |
| **Analog 설계** | SKY130 | 풍부한 analog IP |
| **Mixed-signal** | SKY130 | ADC, PLL 등 |
| **상용 툴 사용** | FreePDK45 + TSMC (교육용) | 산업 표준 |

### 난이도별 학습 경로

```
Level 1 (초급): FreePDK45
  └─ RTL 작성 → 합성 → P&R → 검증
     (JSilicon 같은 간단한 프로세서)

Level 2 (중급): SKY130
  └─ OpenLane 사용
     오픈소스 툴 체인 학습
     실제 제조 경험

Level 3 (고급): ASAP7
  └─ FinFET 설계
     최신 기술 논문 작성
     Advanced DFM

Level 4 (전문가): TSMC/Samsung (회사/대학 제공)
  └─ 상용 프로젝트
     실제 제품 개발
```

---

## 🔬 PDK 기술 트렌드

### 공정 로드맵

```
Past          Present       Future
│              │              │
180nm ────── 7nm ────────── 2nm ────────→ 1nm
130nm         5nm            1.4nm         Sub-1nm
90nm          3nm            (2027)        (2030+)
65nm          (2024)
45nm
28nm (성숙)
```

### 주요 기술 혁신

#### 1. Gate-All-Around (GAA)

```
Planar MOSFET (~ 28nm)
     Gate
      │
   ───┴───
   Source  Drain

FinFET (7nm ~ 3nm)
      Gate
       ║
   ━━━╬━━━
   S  Fin  D

GAA / MBCFET (3nm ~)
      Gate
    ┌─┼─┐
    │Nano│
    │sheet│
    └─┼─┘
```

**장점:**
- Better gate control
- Lower leakage
- Higher drive current

**적용:**
- Samsung 3nm (MBCFET)
- TSMC 2nm (Nanosheet)
- Intel 20A (RibbonFET)

#### 2. Backside Power Delivery

```
Traditional:
┌─────────────────┐
│ Metal (Signal)  │
│ Metal (Power)   │ ← 전원 배선이 신호와 경쟁
│ Transistors     │
└─────────────────┘

PowerVia / BSPDN:
┌─────────────────┐
│ Metal (Signal)  │ ← 신호용으로만 사용
│ Transistors     │
│ Metal (Power)   │ ← 뒷면에서 전원 공급
└─────────────────┘
```

**장점:**
- IR drop 감소
- 더 많은 신호 배선
- 고성능

**적용:**
- Intel 20A (PowerVia)
- TSMC 연구 중
- Imec 개발

#### 3. 3D IC

```
Monolithic 3D:
┌─────────────┐
│  Logic 2    │
├─────────────┤ ← TSV (Through-Silicon Via)
│  Logic 1    │
└─────────────┘

Hybrid Bonding:
┌─────────────┐
│   Memory    │
├─────────────┤ ← Direct Cu-Cu bonding
│  Processor  │
└─────────────┘
```

**기술:**
- Intel Foveros
- TSMC SoIC
- Samsung X-Cube

#### 4. EUV Lithography

```
DUV (Deep UV): 193nm
  ├─ Multi-patterning (복잡)
  └─ 28nm ~ 7nm

EUV (Extreme UV): 13.5nm
  ├─ Single patterning (간단)
  └─ 7nm ~ future
```

**장점:**
- 간단한 공정
- 더 미세한 패턴
- 비용 절감 (장기적)

---

## ❓ 자주 묻는 질문

### Q1. PDK 없이 칩을 설계할 수 있나요?

**A:** 아니요. PDK는 필수입니다.

```
PDK 없이는:
❌ 표준 셀이 없음 → 합성 불가
❌ Design rule 모름 → Layout 불가
❌ 소자 모델 없음 → 시뮬레이션 부정확
❌ 제조 불가능
```

### Q2. FreePDK45로 실제 칩을 만들 수 있나요?

**A:** 아니요, Predictive model이라 제조 불가능합니다.

```
Predictive PDK:
✓ 교육/연구용
✓ 빠른 시뮬레이션
✗ 실제 foundry와 무관
✗ 제조 불가

실제 제조하려면:
→ SKY130 (오픈소스)
→ TSMC, Samsung (상용)
```

### Q3. SKY130으로 어떻게 칩을 만드나요?

**A:** efabless platform 사용:

```
1. 설계 (OpenLane)
   └─ RTL → GDS

2. efabless에 제출
   └─ Caravel SoC에 통합

3. Google Shuttle 참여
   ├─ Open MPW (무료, 선발)
   └─ ChipIgnite (유료)

4. 제조 및 수령
   └─ 2~6개월 소요
```

**비용:**
- Open MPW: 무료 (경쟁률 높음)
- ChipIgnite: ~$10,000
- Direct: ~$25,000

### Q4. TSMC PDK는 어떻게 구하나요?

**A:** 세 가지 방법:

```
1. 회사로서 직접 계약
   ├─ NDA 서명
   ├─ 계약 조건 협의
   └─ PDK 다운로드
   💰 매우 높은 비용

2. 대학 프로그램
   ├─ University Program 신청
   ├─ 교수 승인 필요
   └─ 교육용 제한
   💰 무료 (제한적)

3. Design Service Company
   ├─ 중개 회사 이용
   └─ MPW 프로그램
   💰 중간 비용
```

### Q5. PDK 버전은 왜 중요한가요?

**A:** 버전에 따라 규칙과 성능이 다릅니다.

```
예시: TSMC N7
├─ N7 (v1.0): 초기 버전
├─ N7P (v2.0): 성능 개선 (+10%)
└─ N7+ (v3.0): EUV 적용 (+15%)

버전 차이:
- Design rule 변경
- 표준 셀 개선
- 수율 향상
- 전력 효율 개선

⚠️ 호환성 주의:
- 같은 노드라도 버전이 다르면 재설계 필요
```

### Q6. 어떤 PDK를 배워야 취업에 유리한가요?

**A:** 단계별 추천:

```
대학생 (학부):
1. FreePDK45
   └─ 기초 개념 학습
2. SKY130
   └─ 실습 경험

대학원생:
1. ASAP7
   └─ 연구/논문
2. TSMC (교육용)
   └─ 실무 경험

취업 준비:
✓ 여러 PDK 경험 (versatility)
✓ 상용 툴 사용 경험
✓ 완성된 프로젝트 (portfolio)

💡 중요한 것:
PDK 자체보다 설계 방법론과
플로우 이해가 더 중요!
```

### Q7. 오픈소스 툴로도 상용 PDK를 사용할 수 있나요?

**A:** 제한적으로 가능:

```
오픈소스 툴:
├─ Yosys (합성)
├─ OpenROAD (P&R)
├─ Magic (Layout)
└─ KLayout (Viewer)

상용 PDK 지원:
✓ SKY130: 완벽 지원
△ TSMC: 비공식 지원
△ Samsung: 거의 없음
✗ Intel: 없음

권장:
교육/취미: 오픈소스 툴 + SKY130
상용: Cadence/Synopsys + TSMC/Samsung
```

### Q8. PDK 파일 크기는 얼마나 되나요?

**A:** PDK마다 다름:

```
FreePDK45:     ~100 MB
  └─ 기본 파일만

SKY130:        ~50 GB
  └─ 전체 라이브러리 포함

ASAP7:         ~10 GB
  └─ FinFET 모델 포함

TSMC 7nm:      ~500 GB
  └─ 모든 PVT corner, IP 포함

💡 디스크 공간:
최소 100GB 여유 권장
SSD 사용 권장 (빠른 access)
```

### Q9. 다른 공정으로 포팅하기 쉬운가요?

**A:** 매우 어렵습니다:

```
어려운 이유:
1. Design rule 다름
   └─ Layout 재작업

2. 표준 셀 다름
   └─ 타이밍 재분석

3. 전압/성능 다름
   └─ RTL 수정 필요

4. I/O 다름
   └─ 패드 재설계

예상 노력:
- 같은 노드 다른 foundry: 3~6개월
- 다른 노드: 6~12개월
- 전혀 다른 기술: 새로 설계

💡 포팅 최소화:
- Portable RTL 작성
- Foundry-specific 코드 분리
- 파라미터화
```

### Q10. PDK를 공부하는 순서는?

**A:** 추천 학습 경로:

```
Step 1: 기초 (2주)
└─ FreePDK45
   ├─ RTL 작성
   ├─ 합성 실습
   └─ 간단한 P&R

Step 2: 실습 (1개월)
└─ SKY130
   ├─ OpenLane 사용
   ├─ 전체 플로우
   └─ 실제 설계

Step 3: 심화 (2개월)
└─ ASAP7
   ├─ FinFET 이해
   ├─ Advanced 기법
   └─ 논문 작성

Step 4: 실무 (프로젝트)
└─ TSMC/Samsung (회사/대학)
   ├─ 상용 툴
   ├─ 실제 제품
   └─ Tapeout 경험

병행 학습:
- VLSI 이론
- EDA 툴 사용법
- Digital design 최적화
```

---

## 📚 참고 자료

### 공식 문서

1. **FreePDK45**
   - GitHub: https://github.com/baichen318/FreePDK45
   - Paper: "FreePDK: An Open-Source Variation-Aware Design Kit"

2. **SkyWater SKY130**
   - 공식 사이트: https://github.com/google/skywater-pdk
   - 문서: https://skywater-pdk.readthedocs.io/
   - efabless: https://efabless.com/

3. **ASAP7**
   - 공식 사이트: http://asap.asu.edu/asap/
   - Paper: "ASAP7: A 7-nm finFET predictive PDK"

4. **TSMC**
   - 공식 사이트: https://www.tsmc.com/
   - OIP: https://www.tsmc.com/english/dedicatedFoundry/oip

5. **Samsung Foundry**
   - 공식 사이트: https://www.samsungfoundry.com/
   - SAFE: https://www.samsungfoundry.com/safe

### 교재

1. **"CMOS VLSI Design"** - Weste & Harris
   - PDK 기초 개념
   - Design methodology

2. **"Digital Integrated Circuits"** - Rabaey
   - Process technology
   - Device physics

3. **"Nanometer CMOS ICs"** - Chandrakasan
   - Advanced nodes
   - Low power design

### 온라인 강의

1. **NPTEL - VLSI Design**
   - IIT 교수진
   - 무료

2. **Coursera - VLSI CAD**
   - University of Illinois
   - PDK 사용법 포함

3. **edX - Hardware Security**
   - MIT
   - Chip design basics

### 커뮤니티

1. **Reddit**
   - r/FPGA
   - r/chipdesign
   - r/AskElectronics

2. **Discord**
   - OpenROAD
   - efabless

3. **Forums**
   - EDABoard
   - Electronics Stack Exchange

---

## 🎯 결론

### PDK 선택 요약

| 목적 | 1순위 | 2순위 | 예산 |
|------|-------|-------|------|
| **학부 교육** | FreePDK45 | SKY130 | $0 |
| **대학원 연구** | ASAP7 | TSMC (교육) | $0 |
| **취미/오픈HW** | SKY130 | - | $0~$50K |
| **스타트업** | SKY130 | TSMC 28nm | $50K~$1M |
| **중견 기업** | TSMC 28nm | GF, Samsung | $1M~$10M |
| **대기업** | TSMC 5nm | Samsung 5nm | $50M+ |

### 핵심 포인트

✅ **교육 시작**: FreePDK45로 기초 다지기
✅ **실습 경험**: SKY130으로 실제 제조 경험
✅ **최신 기술**: ASAP7로 FinFET 학습
✅ **상용 경험**: TSMC/Samsung 기회 찾기

### 미래 전망

```
2025-2027: 2nm 양산
  ├─ TSMC N2
  ├─ Samsung 2nm GAA
  └─ Intel 18A

2027-2030: 1nm 개발
  ├─ High-NA EUV
  ├─ CFET (Complementary FET)
  └─ Atomic layer deposition

Beyond 2030:
  ├─ 3D monolithic
  ├─ Carbon nanotube
  └─ Quantum devices?
```

---

## 📞 문의 및 기여

- **GitHub Issues**: 질문 및 버그 리포트
- **Pull Requests**: 내용 개선 및 추가
- **Email**: your.email@university.edu

---

**Last Updated**: 2025-11-17  
**Version**: 1.0  
**Maintainer**: JSilicon Team

---

**Happy Learning! 🎓🔬**
