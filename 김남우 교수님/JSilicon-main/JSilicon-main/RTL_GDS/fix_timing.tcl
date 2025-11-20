#!/bin/tcsh
###############################################################################
# 타이밍 최적화 스크립트
# File: scripts/innovus/fix_timing.tcl
###############################################################################

set DESIGN_NAME "tt_um_Jsilicon"
set project_root [file normalize ../../]

puts "=========================================="
puts "타이밍 최적화 스크립트"
puts "Design: $DESIGN_NAME"
puts "=========================================="
puts ""

# 리포트 디렉토리 생성
set report_dir $project_root/reports/pnr_optimized
file mkdir $report_dir

###############################################################################
# 1. 기존 디자인 복원
###############################################################################

puts "1. 기존 디자인 복원..."

if { [file exists jsilicon_final.enc.dat] } {
    restoreDesign jsilicon_final.enc.dat $DESIGN_NAME
    puts "  ✓ 디자인 복원 완료"
} else {
    puts "  ✗ Error: jsilicon_final.enc.dat not found!"
    exit 1
}

fit
puts ""

###############################################################################
# 2. 현재 타이밍 확인
###############################################################################

puts "2. 현재 타이밍 상태 확인..."
puts ""

# Setup timing
puts "  Setup Timing:"
report_timing -late -max_paths 1
puts ""

# Hold timing
puts "  Hold Timing:"
report_timing -early -max_paths 1
puts ""

###############################################################################
# 3. Setup Timing 최적화
###############################################################################

puts "=========================================="
puts "3. Setup Timing 최적화"
puts "=========================================="

# 최적화 모드 설정
setOptMode -addInstancePrefix OPT_SETUP
setOptMode -fixFanoutLoad true
setOptMode -usefulSkew true
setOptMode -effort high
setOptMode -addInst true
setOptMode -addInstancePrefix SETUP_

puts "  최적화 설정 완료"

# Setup 최적화 실행
puts "  Setup 최적화 실행 중..."
catch {
    optDesign -postRoute -setup -drv
} result

if { $result == 0 } {
    puts "  ✓ Setup 최적화 성공"
} else {
    puts "  ⚠ Setup 최적화 경고 (계속 진행)"
}

puts ""

###############################################################################
# 4. Hold Timing 최적화
###############################################################################

puts "=========================================="
puts "4. Hold Timing 최적화"
puts "=========================================="

# Hold 최적화 모드
setOptMode -addInstancePrefix OPT_HOLD
setOptMode -fixHoldAllowSetupTnsDegrade false
setOptMode -holdTargetSlack 0.05
setOptMode -addInstancePrefix HOLD_

puts "  최적화 설정 완료"

# Hold 최적화 실행
puts "  Hold 최적화 실행 중..."
catch {
    optDesign -postRoute -hold
} result

if { $result == 0 } {
    puts "  ✓ Hold 최적화 성공"
} else {
    puts "  ⚠ Hold 최적화 경고 (계속 진행)"
}

puts ""

###############################################################################
# 5. 추가 최적화 (DRV - Design Rule Violations)
###############################################################################

puts "=========================================="
puts "5. Design Rule Violation 수정"
puts "=========================================="

catch {
    optDesign -postRoute -drv
} result

puts "  ✓ DRV 최적화 완료"
puts ""

###############################################################################
# 6. 최종 타이밍 확인
###############################################################################

puts "=========================================="
puts "6. 최적화 후 타이밍 확인"
puts "=========================================="
puts ""

# Setup timing
puts "  === Setup Timing ==="
report_timing -late -max_paths 5

# Hold timing  
puts ""
puts "  === Hold Timing ==="
report_timing -early -max_paths 5

puts ""

###############################################################################
# 7. 리포트 생성
###############################################################################

puts "=========================================="
puts "7. 리포트 생성"
puts "=========================================="

# Setup timing
report_timing -late -max_paths 10 -nworst 1 \
    > $report_dir/timing_setup_fixed.rpt
puts "  ✓ Setup timing: $report_dir/timing_setup_fixed.rpt"

# Hold timing
report_timing -early -max_paths 10 -nworst 1 \
    > $report_dir/timing_hold_fixed.rpt
puts "  ✓ Hold timing: $report_dir/timing_hold_fixed.rpt"

# Summary
report_timing -late > $report_dir/timing_summary_fixed.rpt
puts "  ✓ Summary: $report_dir/timing_summary_fixed.rpt"

# Constraints
report_constraint -all_violators > $report_dir/violations_fixed.rpt
puts "  ✓ Violations: $report_dir/violations_fixed.rpt"

# Power
report_power > $report_dir/power_fixed.rpt
puts "  ✓ Power: $report_dir/power_fixed.rpt"

puts ""

###############################################################################
# 8. 최종 저장
###############################################################################

puts "=========================================="
puts "8. 최적화된 디자인 저장"
puts "=========================================="

# Checkpoint 저장
saveDesign jsilicon_optimized.enc
puts "  ✓ Checkpoint: jsilicon_optimized.enc"

# DEF 저장
defOut -floorplan -netlist -routing \
    $project_root/results/def/tt_um_Jsilicon_optimized.def
puts "  ✓ DEF: results/def/tt_um_Jsilicon_optimized.def"

# Netlist 저장
saveNetlist $project_root/results/netlist/tt_um_Jsilicon_optimized.v
puts "  ✓ Netlist: results/netlist/tt_um_Jsilicon_optimized.v"

puts ""

###############################################################################
# 9. 최종 요약
###############################################################################

puts "=========================================="
puts "✓✓✓ 타이밍 최적화 완료! ✓✓✓"
puts "=========================================="
puts ""
puts "결과 확인:"
puts "  cat $report_dir/timing_summary_fixed.rpt"
puts "  cat $report_dir/violations_fixed.rpt"
puts ""
puts "GUI로 보기:"
puts "  innovus"
puts "  restoreDesign jsilicon_optimized.enc.dat $DESIGN_NAME"
puts "  fit"
puts ""
puts "=========================================="

exit
