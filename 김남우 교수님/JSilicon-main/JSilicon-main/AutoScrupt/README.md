# JSilicon Auto Script


## 📚 목차 (Table of Contents)

1. [Miniconda 설치](#1-miniconda-설치)  
2. [사전준비](#2-사전준비)  
3. [프로젝트 생성 및 Auto Script 실행](#3-프로젝트-생성-및-auto-script-실행)
4. [SDC (Synopsys Design Constraints) 제약 조건 가이드](#-SDC-(Synopsys-Design-Constraints)-제약-조건-가이드)


## 1. miniconda 설치

```
wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
```

```
--2025-11-19 11:32:11--  https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
Resolving repo.anaconda.com (repo.anaconda.com)... 104.16.191.158, 104.16.32.241, 2606:4700::6810:bf9e, ...
Connecting to repo.anaconda.com (repo.anaconda.com)|104.16.191.158|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 73134376 (70M) [application/x-sh]
Saving to: 'Miniconda3-py310_23.3.1-0-Linux-x86_64.sh'

100%[====================================================================================================================================================================>] 73,134,376  10.9MB/s   in 6.3s

2025-11-19 11:32:17 (11.1 MB/s) - 'Miniconda3-py310_23.3.1-0-Linux-x86_64.sh' saved [73134376/73134376]
```

```
[student018@gjchamber ~]$ bash Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
Welcome to Miniconda3 py310_23.3.1-0

In order to continue the installation process, please review the license
agreement.
Please, press ENTER to continue
>>>

```

```
======================================
End User License Agreement - Miniconda
======================================

Copyright 2015-2023, Anaconda, Inc.

All rights reserved under the 3-clause BSD License:

This End User License Agreement (the "Agreement") is a legal agreement between you and Anaconda, Inc. ("Anaconda") and governs your use of Miniconda.

Subject to the terms of this Agreement, Anaconda hereby grants you a non-exclusive, non-transferable license to:

  * Install and use the Miniconda,
  * Modify and create derivative works of sample source code delivered in Miniconda subject to the Terms of Service for the Repository (as defined hereinafter) available at https://www.anaconda.com/terms-of
-service, and
  * Redistribute code files in source (if provided to you by Anaconda as source) and binary forms, with or without modification subject to the requirements set forth below.

Anaconda may, at its option, make available patches, workarounds or other updates to Miniconda. Unless the updates are provided with their separate governing terms, they are deemed part of Miniconda license
d to you as provided in this Agreement. This Agreement does not entitle you to any support for Miniconda.

Anaconda reserves all rights not expressly granted to you in this Agreement.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of Anaconda nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

You acknowledge that, as between you and Anaconda, Anaconda owns all right, title, and interest, including all intellectual property rights, in and to Miniconda and, with respect to third-party products dis
tributed with or through Miniconda, the applicable third-party licensors own all right, title and interest, including all intellectual property rights, in and to such products. If you send or transmit any c
ommunications or materials to Anaconda suggesting or recommending changes to the software or documentation, including without limitation, new features or functionality relating thereto, or any comments, que
stions, suggestions or the like ("Feedback"), Anaconda is free to use such Feedback. You hereby assign to Anaconda all right, title, and interest in, and Anaconda is free to use, without any attribution or
compensation to any party, any ideas, know-how, concepts, techniques or other intellectual property rights contained in the Feedback, for any purpose whatsoever, although Anaconda is not required to use any
 Feedback.

DISCLAIMER
==========

THIS SOFTWARE IS PROVIDED BY ANACONDA AND ITS CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULA
R PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ANACONDA BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GO
ODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) AR
ISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

TO THE MAXIMUM EXTENT PERMITTED BY LAW, ANACONDA AND ITS AFFILIATES SHALL NOT BE LIABLE FOR ANY SPECIAL, INCIDENTAL, PUNITIVE OR CONSEQUENTIAL DAMAGES, OR ANY LOST PROFITS, LOSS OF USE, LOSS OF DATA OR LOSS
 OF GOODWILL, OR THE COSTS OF PROCURING SUBSTITUTE PRODUCTS, ARISING OUT OF OR IN CONNECTION WITH THIS AGREEMENT OR THE USE OR PERFORMANCE OF MINICONDA, WHETHER SUCH LIABILITY ARISES FROM ANY CLAIM BASED UP
ON BREACH OF CONTRACT, BREACH OF WARRANTY, TORT (INCLUDING NEGLIGENCE), PRODUCT LIABILITY OR ANY OTHER CAUSE OF ACTION OR THEORY OF LIABILITY. IN NO EVENT WILL THE TOTAL CUMULATIVE LIABILITY OF ANACONDA AND
 ITS AFFILIATES UNDER OR ARISING OUT OF THIS AGREEMENT EXCEED 10.00 U.S. DOLLARS.

Miscellaneous
=============

If you want to terminate this Agreement, you may do so by discontinuing use of Miniconda. Anaconda may, at any time, terminate this Agreement and the license granted hereunder if you fail to comply with any
 term of this Agreement. Upon any termination of this Agreement, you agree to promptly discontinue use of the Miniconda and destroy all copies in your possession or control. Upon any termination of this Agr
eement all provisions survive except for the licenses granted to you.

This Agreement is governed by and construed in accordance with the internal laws of the State of Texas without giving effect to any choice or conflict of law provision or rule that would require or permit t
he application of the laws of any jurisdiction other than those of the State of Texas. Any legal suit, action, or proceeding arising out of or related to this Agreement or the licenses granted hereunder by
--More--




You must comply with all domestic and international export laws and regulations that apply to the software, which include restrictions on destinations, end users, and end use. Miniconda includes cryptograph
ic software. The country in which you currently reside may have restrictions on the import, possession, use, and/or re-export to another country, of encryption software. BEFORE using any encryption software
, please check your country's laws, regulations and policies concerning the import, possession, or use, and re-export of encryption software, to see if this is permitted. See the Wassenaar Arrangement http:
//www.wassenaar.org/ for more information.

Anaconda has self-classified this software as Export Commodity Control Number (ECCN) EAR99, which includes mass market information security software using or performing cryptographic functions with asymmetr
ic algorithms. No license is required for export of this software to non-embargoed countries.

The Intel Math Kernel Library contained in Miniconda is classified by Intel as ECCN 5D992.c with no license required for export to non-embargoed countries.

The following packages listed on https://www.anaconda.com/cryptography are included in the Repository accessible through Miniconda that relate to cryptography.

Last updated March 21, 2022


Do you accept the license terms? [yes|no]
[no] >>> yes 

```

* 질문에 yes 및 Enter로 확인할것.

```
Do you accept the license terms? [yes|no]
[no] >>> yes <======== yes 입력

Miniconda3 will now be installed into this location:
/home/student018/miniconda3

  - Press ENTER to confirm the location
  - Press CTRL-C to abort the installation
  - Or specify a different location below

[/home/student018/miniconda3] >>> <======== Enter 입력
PREFIX=/home/student018/miniconda3
Unpacking payload ...

Installing base environment...


Downloading and Extracting Packages


Downloading and Extracting Packages

Preparing transaction: done
Executing transaction: done
installation finished.
Do you wish the installer to initialize Miniconda3
by running conda init? [yes|no]
[no] >>> yes <======== yes 입력
no change     /home/student018/miniconda3/condabin/conda
no change     /home/student018/miniconda3/bin/conda
no change     /home/student018/miniconda3/bin/conda-env
no change     /home/student018/miniconda3/bin/activate
no change     /home/student018/miniconda3/bin/deactivate
no change     /home/student018/miniconda3/etc/profile.d/conda.sh
no change     /home/student018/miniconda3/etc/fish/conf.d/conda.fish
no change     /home/student018/miniconda3/shell/condabin/Conda.psm1
no change     /home/student018/miniconda3/shell/condabin/conda-hook.ps1
no change     /home/student018/miniconda3/lib/python3.10/site-packages/xontrib/conda.xsh
no change     /home/student018/miniconda3/etc/profile.d/conda.csh
modified      /home/student018/.bashrc

==> For changes to take effect, close and re-open your current shell. <==

If you'd prefer that conda's base environment not be activated on startup,
   set the auto_activate_base parameter to false:

conda config --set auto_activate_base false

Thank you for installing Miniconda3!
[student018@gjchamber ~]$

```

* 최종확인

```
[student018@gjchamber ~]$ source ~/.cshrc
```

```
[student018@gjchamber ~]$ python --version
Python 3.10.10

```
  
## 2. 사전준비

```
vi ~/.cshrc
```

 
* 각자 위치가 다른 부분이 있으니 수정할것.
```
setenv PATH /tools/cadence/XCELIUMMAIN2409/tools/bin:${PATH}
setenv PATH /home/student001/miniconda3/bin:${PATH} <== 각자 위치가 다름
setenv PATH /tools/cadence/DDI231/GENUS231/bin:${PATH}
setenv PATH /tools/cadence/DDI231/INNOVUS231/bin:${PATH}
```

```
source ~/.cshrc
```


## 3. 프로젝트 생성 및 Auto Script 실행

```
makedir JSilicon2
cp AutoScrupt.tar JSilicon2
cd JSilicon2
tar -xvf AutoScrupt.tar
```

```
chmod +x run_rtl2gds.csh
./run_rtl2gds.csh
```

# SDC (Synopsys Design Constraints) 제약 조건 가이드

## 📋 목차
1. [타이밍 제약 (Timing Constraints)](#타이밍-제약-timing-constraints)
2. [면적 제약 (Area Constraints)](#면적-제약-area-constraints)
3. [전력 제약 (Power Constraints)](#전력-제약-power-constraints)
4. [물리적 제약 (Physical Constraints)](#물리적-제약-physical-constraints)
5. [설계 규칙 제약 (Design Rule Constraints)](#설계-규칙-제약-design-rule-constraints)
6. [JSilicon 프로젝트 적용 예시](#jsilicon-프로젝트-적용-예시)

## JSilicon에서 SDC에서 타이밍 Constraint를 수정하려면?

```
8번 라인:
tclcreate_clock -name clk -period 5.0 [get_ports clk]

- **Period: 5.0 ns** = 1/5ns = **200 MHz** ✓

주석(3번 라인)에도 명시되어 있습니다:

# Target: 200 MHz (5ns period)
만약 다른 주파수로 변경하고 싶으시다면:

100 MHz: period 10.0
250 MHz: period 4.0
500 MHz: period 2.0
1 GHz: period 1.0
```

## 타이밍 제약 (Timing Constraints)

### 1. Clock 정의

```tcl
# 기본 클럭 생성 (200 MHz = 5ns period)
create_clock -name clk -period 5.0 [get_ports clk]

# 여러 클럭 정의
create_clock -name clk_fast -period 2.0 [get_ports clk_fast]
create_clock -name clk_slow -period 10.0 [get_ports clk_slow]

# Generated clock (PLL 출력 등)
create_generated_clock -name clk_div2 \
    -source [get_ports clk] \
    -divide_by 2 \
    [get_pins divider/Q]
```

### 2. Clock Uncertainty (Jitter & Skew)
```tcl
# Clock uncertainty 설정 (jitter + skew 고려)
set_clock_uncertainty 0.5 [get_clocks clk]

# Setup/Hold 각각 설정
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold 0.1 [get_clocks clk]
```

### 3. Clock Latency (지연)
```tcl
# Source latency (클럭 소스에서 디자인까지)
set_clock_latency -source -min 0.5 [get_clocks clk]
set_clock_latency -source -max 1.0 [get_clocks clk]

# Network latency (클럭 트리 내부)
set_clock_latency -min 0.2 [get_clocks clk]
set_clock_latency -max 0.5 [get_clocks clk]
```

### 4. Input/Output Delays
```tcl
# Input delay (외부에서 입력 신호 도착 시간)
set_input_delay -clock clk -max 1.5 [all_inputs]
set_input_delay -clock clk -min 0.5 [all_inputs]

# Output delay (출력 신호가 외부 디바이스에 도착해야 하는 시간)
set_output_delay -clock clk -max 1.5 [all_outputs]
set_output_delay -clock clk -min 0.5 [all_outputs]

# 특정 포트만 설정
set_input_delay -clock clk -max 2.0 [get_ports data_in*]
```

### 5. Clock Transition (Slew)
```tcl
# 클럭 신호의 transition time 제한
set_clock_transition 0.1 [get_clocks clk]
set_clock_transition -rise 0.1 [get_clocks clk]
set_clock_transition -fall 0.15 [get_clocks clk]
```

### 6. False Path & Multicycle Path
```tcl
# False path (타이밍 체크 안함)
set_false_path -from [get_ports rst_n]
set_false_path -from [get_clocks clk1] -to [get_clocks clk2]

# Multicycle path (여러 사이클에 걸쳐 전달)
set_multicycle_path -setup 2 -from [get_pins reg1/Q] -to [get_pins reg2/D]
set_multicycle_path -hold 1 -from [get_pins reg1/Q] -to [get_pins reg2/D]
```

### 7. Clock Groups
```tcl
# 비동기 클럭 그룹 정의
set_clock_groups -asynchronous \
    -group [get_clocks clk_sys] \
    -group [get_clocks clk_usb]

# 배타적 클럭 (동시에 활성화 안됨)
set_clock_groups -physically_exclusive \
    -group [get_clocks clk_mode1] \
    -group [get_clocks clk_mode2]
```

---

## 면적 제약 (Area Constraints)

### 1. 최대 면적 제한
```tcl
# 전체 디자인 면적 제한 (단위: um^2)
set_max_area 10000

# 0으로 설정하면 최소 면적으로 합성
set_max_area 0
```

### 2. Cell 인스턴스 제한
```tcl
# 특정 셀 사용 금지
set_dont_use [get_lib_cells */CLKBUF*]
set_dont_use [get_lib_cells */DELAY*]

# 특정 셀만 사용
set_dont_use [get_lib_cells */*]
remove_attribute [get_lib_cells */NAND2*] dont_use
remove_attribute [get_lib_cells */NOR2*] dont_use
```

### 3. Utilization (배치 밀도)
```tcl
# Note: SDC가 아닌 합성/P&R 툴에서 설정
# Genus에서:
# set_db syn_map_effort high
# Innovus에서:
# floorPlan -r 1.0 0.70  # 70% utilization
```

---

## 전력 제약 (Power Constraints)

### 1. 최대 전력 제한
```tcl
# 동적 전력 제한 (단위: mW)
set_max_dynamic_power 100 mW

# 누설 전력 제한
set_max_leakage_power 10 mW

# 전체 전력 제한
set_max_total_power 110 mW
```

### 2. Clock Gating
```tcl
# Clock gating 활성화 (SDC가 아닌 합성 옵션)
# Genus에서:
# set_db lp_insert_clock_gating true
```

### 3. Multi-Vt (Threshold Voltage) 셀 사용
```tcl
# 특정 경로에 Low-Vt 셀 사용 (빠르지만 전력 큼)
set_threshold_voltage_group_type -type low_vt [get_cells critical_path/*]

# High-Vt 셀 사용 (느리지만 전력 작음)
set_threshold_voltage_group_type -type high_vt [get_cells non_critical/*]
```

---

## 물리적 제약 (Physical Constraints)

### 1. Driving Cell (입력 구동력)
```tcl
# 모든 입력에 대한 구동 셀 지정
set_driving_cell -lib_cell BUFX2 -library gscl45nm [all_inputs]

# 특정 입력만 설정
set_driving_cell -lib_cell BUFX4 -library gscl45nm [get_ports critical_input]
```

### 2. Load (출력 부하)
```tcl
# 출력 포트의 부하 용량 (단위: pF)
set_load 0.05 [all_outputs]
set_load 0.1 [get_ports high_fanout_out]

# Wire load 설정
set_load 0.02 [get_nets internal_net]
```

### 3. Input Transition
```tcl
# 입력 신호의 transition time
set_input_transition 0.2 [all_inputs]
set_input_transition -rise 0.15 [get_ports fast_input]
set_input_transition -fall 0.25 [get_ports fast_input]
```

### 4. Port Fanout
```tcl
# 포트별 fanout 제한
set_fanout_load 8 [get_ports data_out]
```

---

## 설계 규칙 제약 (Design Rule Constraints)

### 1. Max Transition Time
```tcl
# 전체 디자인의 최대 transition time
set_max_transition 0.5 [current_design]

# 특정 net/port에만 적용
set_max_transition 0.3 [all_outputs]
set_max_transition 0.2 [get_nets critical_net]
```

### 2. Max Fanout
```tcl
# 전체 디자인의 최대 fanout
set_max_fanout 20 [current_design]

# 특정 port/net에만 적용
set_max_fanout 10 [get_ports data_in*]
```

### 3. Max Capacitance
```tcl
# 최대 커패시턴스 (단위: pF)
set_max_capacitance 0.5 [all_outputs]
set_max_capacitance 0.2 [get_ports critical_out]
```

### 4. Min Capacitance
```tcl
# 최소 커패시턴스 (너무 작으면 신호 integrity 문제)
set_min_capacitance 0.01 [all_outputs]
```

### 5. Operating Conditions
```tcl
# PVT (Process, Voltage, Temperature) 조건
set_operating_conditions -max WORST -max_library gscl45nm
set_operating_conditions -min BEST -min_library gscl45nm

# Typical corner
set_operating_conditions -max TYPICAL -max_library gscl45nm
```

### 6. Wire Load Model
```tcl
# Wire load model 설정 (작은 디자인)
set_wire_load_mode top
set_wire_load_model -name small -library gscl45nm

# 큰 디자인
set_wire_load_model -name large -library gscl45nm
```

---

## JSilicon 프로젝트 적용 예시

### 기본 설정 (constraints/jsilicon.sdc)

```tcl
###############################################################################
# JSilicon Timing Constraints
# Target: 200 MHz (5ns period)
# FreePDK45 Process (45nm)
# Author: JSilicon Team
# Date: 2025
###############################################################################

#==============================================================================
# 1. CLOCK DEFINITION
#==============================================================================

# Primary clock: 200 MHz
create_clock -name clk -period 5.0 [get_ports clk]

# Clock uncertainty (jitter + skew)
set_clock_uncertainty 0.5 [get_clocks clk]

# Clock transition (slew rate)
set_clock_transition 0.1 [get_clocks clk]

# Clock latency (estimated pre-CTS)
set_clock_latency -source -min 0.5 [get_clocks clk]
set_clock_latency -source -max 1.0 [get_clocks clk]

#==============================================================================
# 2. INPUT/OUTPUT DELAYS
#==============================================================================

# Input delays (30% of clock period)
set_input_delay -clock clk -max 1.5 [all_inputs]
set_input_delay -clock clk -min 0.5 [all_inputs]

# Output delays (30% of clock period)
set_output_delay -clock clk -max 1.5 [all_outputs]
set_output_delay -clock clk -min 0.5 [all_outputs]

# Remove delays from clock and reset ports
remove_input_delay [get_ports clk]
remove_output_delay [get_ports clk]

if { [sizeof_collection [get_ports rst_n]] > 0 } {
    remove_input_delay [get_ports rst_n]
}

#==============================================================================
# 3. PHYSICAL CONSTRAINTS
#==============================================================================

# Driving cell for inputs (medium strength buffer)
set_driving_cell -lib_cell BUFX2 -library gscl45nm [all_inputs]

# Load on outputs (50 fF = 0.05 pF)
set_load 0.05 [all_outputs]

# Input transition time
set_input_transition 0.2 [all_inputs]

#==============================================================================
# 4. DESIGN RULE CONSTRAINTS
#==============================================================================

# Maximum transition time (500 ps)
set_max_transition 0.5 [current_design]

# Maximum fanout
set_max_fanout 20 [current_design]

# Maximum capacitance on outputs (500 fF)
set_max_capacitance 0.5 [all_outputs]

# Minimum capacitance (avoid signal integrity issues)
set_min_capacitance 0.01 [all_outputs]

#==============================================================================
# 5. OPERATING CONDITIONS
#==============================================================================

# Typical corner (for 45nm process)
set_operating_conditions -max TYPICAL -max_library gscl45nm

#==============================================================================
# 6. AREA CONSTRAINTS
#==============================================================================

# Minimize area (0 = smallest possible)
set_max_area 0

# Alternative: Set specific area limit (in um^2)
# set_max_area 5000

#==============================================================================
# 7. POWER CONSTRAINTS (Optional)
#==============================================================================

# Maximum dynamic power (mW)
# set_max_dynamic_power 50 mW

# Maximum leakage power (mW)
# set_max_leakage_power 5 mW

#==============================================================================
# 8. FALSE PATHS (Optional)
#==============================================================================

# Reset is asynchronous - no timing check needed
if { [sizeof_collection [get_ports rst_n]] > 0 } {
    set_false_path -from [get_ports rst_n]
}

# Example: Async paths between different clock domains
# set_false_path -from [get_clocks clk1] -to [get_clocks clk2]

#==============================================================================
# 9. MULTICYCLE PATHS (Optional)
#==============================================================================

# Example: Some paths take 2 cycles
# set_multicycle_path -setup 2 -from [get_pins reg1/Q] -to [get_pins reg2/D]
# set_multicycle_path -hold 1 -from [get_pins reg1/Q] -to [get_pins reg2/D]

#==============================================================================
# 10. DON'T USE CELLS (Optional)
#==============================================================================

# Prevent use of certain cells (delay cells, clock buffers in signal path)
# set_dont_use [get_lib_cells */CLKBUF*]
# set_dont_use [get_lib_cells */DELAY*]

###############################################################################
# End of constraints
###############################################################################
```

### 고성능 설정 (constraints/jsilicon_high_performance.sdc)

```tcl
###############################################################################
# JSilicon High Performance Configuration
# Target: 500 MHz (2ns period) - Aggressive timing
###############################################################################

# Clock: 500 MHz
create_clock -name clk -period 2.0 [get_ports clk]

# Tighter uncertainty for high speed
set_clock_uncertainty 0.2 [get_clocks clk]
set_clock_transition 0.05 [get_clocks clk]

# Tighter I/O delays (20% of period)
set_input_delay -clock clk -max 0.4 [all_inputs]
set_input_delay -clock clk -min 0.2 [all_inputs]
set_output_delay -clock clk -max 0.4 [all_outputs]
set_output_delay -clock clk -min 0.2 [all_outputs]

remove_input_delay [get_ports clk]
remove_output_delay [get_ports clk]

# Stronger driving cells
set_driving_cell -lib_cell BUFX4 -library gscl45nm [all_inputs]
set_load 0.03 [all_outputs]

# Tighter design rules
set_max_transition 0.2 [current_design]
set_max_fanout 10 [current_design]
set_max_capacitance 0.3 [all_outputs]

# Area is secondary - prioritize speed
# set_max_area 10000

# Higher power budget for performance
# set_max_dynamic_power 100 mW
```

### 저전력 설정 (constraints/jsilicon_low_power.sdc)

```tcl
###############################################################################
# JSilicon Low Power Configuration
# Target: 100 MHz (10ns period) - Power optimized
###############################################################################

# Clock: 100 MHz
create_clock -name clk -period 10.0 [get_ports clk]

# Relaxed timing for power savings
set_clock_uncertainty 0.8 [get_clocks clk]
set_clock_transition 0.3 [get_clocks clk]

# Relaxed I/O delays (40% of period)
set_input_delay -clock clk -max 4.0 [all_inputs]
set_input_delay -clock clk -min 1.0 [all_inputs]
set_output_delay -clock clk -max 4.0 [all_outputs]
set_output_delay -clock clk -min 1.0 [all_outputs]

remove_input_delay [get_ports clk]
remove_output_delay [get_ports clk]

# Weaker driving cells (lower power)
set_driving_cell -lib_cell BUFX1 -library gscl45nm [all_inputs]
set_load 0.05 [all_outputs]

# Relaxed design rules
set_max_transition 1.0 [current_design]
set_max_fanout 30 [current_design]
set_max_capacitance 1.0 [all_outputs]

# Minimize area for lower leakage
set_max_area 0

# Strict power limits
# set_max_dynamic_power 20 mW
# set_max_leakage_power 2 mW
```

### 면적 최적화 설정 (constraints/jsilicon_area_optimized.sdc)

```tcl
###############################################################################
# JSilicon Area Optimized Configuration
# Target: 150 MHz (6.67ns period) - Area minimized
###############################################################################

# Clock: 150 MHz (balanced)
create_clock -name clk -period 6.67 [get_ports clk]

set_clock_uncertainty 0.6 [get_clocks clk]
set_clock_transition 0.15 [get_clocks clk]

# Standard I/O delays
set_input_delay -clock clk -max 2.0 [all_inputs]
set_input_delay -clock clk -min 0.5 [all_inputs]
set_output_delay -clock clk -max 2.0 [all_outputs]
set_output_delay -clock clk -min 0.5 [all_outputs]

remove_input_delay [get_ports clk]
remove_output_delay [get_ports clk]

# Standard driving cells
set_driving_cell -lib_cell BUFX2 -library gscl45nm [all_inputs]
set_load 0.05 [all_outputs]

# Standard design rules
set_max_transition 0.5 [current_design]
set_max_fanout 25 [current_design]
set_max_capacitance 0.5 [all_outputs]

# CRITICAL: Minimize area aggressively
set_max_area 0

# Allow using all available cells for area reduction
# Don't restrict any cells unless absolutely necessary

# Operating conditions
set_operating_conditions -max TYPICAL -max_library gscl45nm
```

---

## 📊 제약 조건 비교표

| 항목 | 고성능 | 표준 | 저전력 | 면적최적화 |
|------|--------|------|--------|------------|
| **주파수** | 500 MHz | 200 MHz | 100 MHz | 150 MHz |
| **Period** | 2.0 ns | 5.0 ns | 10.0 ns | 6.67 ns |
| **Uncertainty** | 0.2 ns | 0.5 ns | 0.8 ns | 0.6 ns |
| **Max Transition** | 0.2 ns | 0.5 ns | 1.0 ns | 0.5 ns |
| **Max Fanout** | 10 | 20 | 30 | 25 |
| **Driving Cell** | BUFX4 | BUFX2 | BUFX1 | BUFX2 |
| **Max Area** | 10000 um² | 0 (min) | 0 (min) | 0 (min) |
| **Power Budget** | 100 mW | - | 20 mW | - |
| **적용** | 고성능 CPU | 범용 | IoT/센서 | ASIC |

---

## 🔍 제약 조건 검증 방법

### Genus (합성 후)
```tcl
# QoR 리포트 확인
report_qor
report_timing -nworst 10
report_area
report_power
report_constraint -all_violators
```

### Innovus (P&R 후)
```tcl
# 타이밍 검증
report_timing -late    # Setup
report_timing -early   # Hold

# 면적 확인
report_area

# 전력 확인
report_power

# DRC 위반 확인
verifyGeometry
verifyConnectivity
```

---

## 💡 실전 팁

### 1. Clock Period 설정
```tcl
# 보수적 접근: 목표 주파수의 80% 여유
# 목표 200MHz → 250MHz로 합성 → 여유 확보
create_clock -name clk -period 4.0 [get_ports clk]
```

### 2. Input/Output Delay 가이드라인
```tcl
# 일반적 규칙: 클럭 주기의 20-40%
# 5ns 주기 → 1.0~2.0ns delay
set_input_delay -clock clk -max [expr $CLK_PERIOD * 0.3] [all_inputs]
```

### 3. 조건부 제약
```tcl
# 포트 존재 여부 확인 후 적용
if { [sizeof_collection [get_ports rst_n]] > 0 } {
    set_false_path -from [get_ports rst_n]
}

# 특정 모듈에만 적용
if { [sizeof_collection [get_cells uart_module]] > 0 } {
    set_multicycle_path -setup 2 -through [get_cells uart_module]
}
```

### 4. 단계적 최적화
```tcl
# 1단계: 느슨한 제약으로 합성 성공 확인
create_clock -period 10.0 [get_ports clk]

# 2단계: 점진적으로 타이밍 강화
create_clock -period 7.0 [get_ports clk]

# 3단계: 목표 주파수 도달
create_clock -period 5.0 [get_ports clk]
```

---

## 📚 참고 자료

- [Synopsys SDC User Guide](https://www.synopsys.com)
- [Cadence Genus Documentation](https://www.cadence.com)
- FreePDK45 Design Kit Documentation
- IEEE 1364 (Verilog) / IEEE 1666 (SystemVerilog)


# ============================

## 실행방법

```
cd /home/student018/JSilicon2

# 실행
chmod +x run_rtl2gds.csh
./run_rtl2gds.csh
```

## 실행결과

* Log 파일 참조

### innovus 확인

```
cd ~/JSilicon2/work/pnr

innovus

restoreDesign  jsilicon_final.enc.dat tt_um_Jsilicon
```

### 결과 체크

```
[student018@gjchamber ~/JSilicon2]$ ./check_status.csh
==========================================
 JSilicon Design Flow Status Check
 Design: tt_um_Jsilicon
==========================================

1. Synthesis Status
-------------------
  ✓ Synthesis COMPLETED
-rw-r--r-- 1 student018 student018 105K Nov 19 13:47 results/netlist/tt_um_Jsilicon_synth.v

  QoR Summary (마지막 20줄):
    Hierarchical Instance Count       2

    Area
    ----
    Cell Area                          2301.447
    Physical Cell Area                 0.000
    Total Cell Area (Cell+Physical)    2301.447
    Net Area                           1566.517
    Total Area (Cell+Physical+Net)     3867.964

    Max Fanout                         42 (clk)
    Min Fanout                         0 (n_3)
    Average Fanout                     1.8
    Terms to net ratio                 2.8538
    Terms to instance ratio            3.0538
    Runtime                            125.89702899999999 seconds
    Elapsed Runtime                    128 seconds
    Genus peak memory usage            2006.21
    Innovus peak memory usage          no_value
    Hostname                           localhost

  Timing Summary:

  Area Summary:
           Instance        Module  Cell-Count  Cell-Area  Net-Area   Total-Area
    ----------------------------------------------------------------------------
    tt_um_Jsilicon        NA              799   2301.447  1566.516     3867.964
      core_inst_uart_inst UART_TX         193    718.968   346.223     1065.191
      dec_inst            DECODER           3     13.610     1.355       14.965

2. Place & Route Status
-----------------------
  ✓ P&R COMPLETED
-rw-r--r-- 1 student018 student018 586K Nov 19 13:50 results/def/tt_um_Jsilicon.def
  ✓ Final netlist exists
-rw-r--r-- 1 student018 student018 96K Nov 19 13:50 results/netlist/tt_um_Jsilicon_final.v

  P&R Summary (마지막 30줄):
    ==============================
    Wire Length Distribution
    ==============================
    Total metal1 wire length: 216.0675 um
    Total metal2 wire length: 2688.7775 um
    Total metal3 wire length: 2817.0900 um
    Total metal4 wire length: 514.1700 um
    Total metal5 wire length: 49.5900 um
    Total metal6 wire length: 0.0000 um
    Total metal7 wire length: 0.0000 um
    Total metal8 wire length: 0.0000 um
    Total metal9 wire length: 0.0000 um
    Total metal10 wire length: 0.0000 um
    Total wire length: 6285.6950 um
    Average wire length/net: 7.4830 um
    Area of Power Net Distribution:
        ------------------------------
        Area of Power Net Distribution
        ------------------------------
        Layer Name  Area of Power Net  Routable Area  Percentage
        metal1  90.1056  3292.1395  2.7370%
        metal2  0.0000  3292.1395  0.0000%
        metal3  0.0000  3292.1395  0.0000%
        metal4  0.0000  3292.1395  0.0000%
        metal5  0.0000  3292.1395  0.0000%
        metal6  0.0000  3292.1395  0.0000%
        metal7  0.0000  3292.1395  0.0000%
        metal8  170.4300  3292.1395  5.1769%
        metal9  0.0000  3292.1395  0.0000%
        metal10  0.0000  3292.1395  0.0000%  For more information click here

3. Static Timing Analysis Status
--------------------------------
  ✗ STA NOT completed or reports not found
    Run: cd work/pnr && tempus -f ../../scripts/tempus/sta.tcl

4. Physical Design Files
------------------------
  ✓ GDS file exists (Ready for tapeout!)
-rw-r--r-- 1 student018 student018 711K Nov 19 13:50 results/gds/tt_um_Jsilicon.gds

5. Log Files Status
-------------------

==========================================
Next Steps:
==========================================
  ✓ All major steps completed!
  1. Run DRC: calibre -drc drc.rule
  2. Run LVS: calibre -lvs lvs.rule
  3. Review all timing reports
  4. Prepare tapeout package

==========================================
[student018@gjchamber ~/JSilicon2]$

```
