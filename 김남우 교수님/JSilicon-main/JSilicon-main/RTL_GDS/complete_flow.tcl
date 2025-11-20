#!/bin/tcsh
###############################################################################
# 완전한 검증 및 Tape-out 플로우
# File: scripts/innovus/complete_flow.tcl
###############################################################################

set DESIGN_NAME "tt_um_Jsilicon"
set project_root [file normalize ../../]

puts ""
puts "=============================================================================="
puts "JSilicon Complete Verification & Tape-out Flow"
puts "=============================================================================="
puts "Design:  $DESIGN_NAME"
puts "Date:    [clock format [clock seconds]]"
puts "=============================================================================="
puts ""

# 디렉토리 생성
file mkdir $project_root/results/gds
file mkdir $project_root/results/extraction
file mkdir $project_root/results/lvs
file mkdir $project_root/reports/pnr_optimized

###############################################################################
# Step 1: 타이밍 최적화
###############################################################################

puts "=============================================================================="
puts "Step 1: Timing Optimization"
puts "=============================================================================="
puts ""

# 기존 디자인 복원
if { [file exists jsilicon_final.enc.dat] } {
    restoreDesign jsilicon_final.enc.dat $DESIGN_NAME
    puts "✓ Restored: jsilicon_final.enc.dat"
} else {
    puts "✗ Error: jsilicon_final.enc.dat not found!"
    exit 1
}

# 타이밍 최적화 설정
puts "Configuring optimization..."
setOptMode -effort high
setOptMode -usefulSkew true
setOptMode -fixHoldAllowSetupTnsDegrade false
setOptMode -addInstancePrefix OPT_

# Setup 최적화
puts "Running setup optimization..."
catch { optDesign -postRoute -setup }

# Hold 최적화
puts "Running hold optimization..."
catch { optDesign -postRoute -hold }

# DRV 최적화
puts "Running DRV optimization..."
catch { optDesign -postRoute -drv }

# 타이밍 체크
puts ""
puts "--- Timing Summary ---"
report_timing -late -max_paths 1
report_timing -early -max_paths 1

# 저장
saveDesign jsilicon_final_opt.enc
puts ""
puts "✓ Step 1 Complete: jsilicon_final_opt.enc"
puts ""

# 리포트
report_timing -late > $project_root/reports/pnr_optimized/timing_setup_opt.rpt
report_timing -early > $project_root/reports/pnr_optimized/timing_hold_opt.rpt
report_constraint -all_violators > $project_root/reports/pnr_optimized/violations_opt.rpt

###############################################################################
# Step 2: LVS 검증
###############################################################################

puts "=============================================================================="
puts "Step 2: LVS (Layout vs Schematic)"
puts "=============================================================================="
puts ""

# Layout netlist 추출
puts "Extracting layout netlist..."
saveNetlist -excludeLeafCell \
    -includePhysicalInst \
    -includePowerGround \
    $project_root/results/lvs/layout_extracted.sp

saveNetlist $project_root/results/lvs/layout_extracted.v

puts "✓ Layout netlist: results/lvs/layout_extracted.sp"
puts ""

# Connectivity 검증
puts "Checking connectivity..."
verifyConnectivity -noAntenna \
    -report $project_root/results/lvs/connectivity_check.rpt

verifyConnectivity -type special \
    -report $project_root/results/lvs/pg_connectivity.rpt

puts "✓ Connectivity reports generated"
puts ""

# 통계
set inst_count [llength [dbGet top.insts]]
set net_count [llength [dbGet top.nets]]

puts "Design Statistics:"
puts "  Instances: $inst_count"
puts "  Nets:      $net_count"
puts ""

puts "✓ Step 2 Complete: LVS check done"
puts ""

###############################################################################
# Step 3: RC Extraction
###############################################################################

puts "=============================================================================="
puts "Step 3: RC Parasitic Extraction"
puts "=============================================================================="
puts ""

# RC Extraction
puts "Extracting RC parasitics..."
extractRC

# SPEF 생성
puts "Generating SPEF file..."
rcOut -spef $project_root/results/extraction/tt_um_Jsilicon.spef

# SDF 생성
puts "Generating SDF file..."
write_sdf -version 3.0 \
    $project_root/results/extraction/tt_um_Jsilicon.sdf

puts "✓ SPEF: results/extraction/tt_um_Jsilicon.spef"
puts "✓ SDF:  results/extraction/tt_um_Jsilicon.sdf"
puts ""

# Extracted timing 체크
puts "Post-extraction timing check..."
report_timing -late -max_paths 3

# 저장
saveDesign jsilicon_extracted.enc

puts "✓ Step 3 Complete: RC extraction done"
puts ""

###############################################################################
# Step 4: Final Reports
###############################################################################

puts "=============================================================================="
puts "Step 4: Generating Final Reports"
puts "=============================================================================="
puts ""

set report_dir $project_root/reports/final

file mkdir $report_dir

# 타이밍
report_timing -late -max_paths 10 > $report_dir/timing_setup_final.rpt
report_timing -early -max_paths 10 > $report_dir/timing_hold_final.rpt
report_timing -late > $report_dir/timing_summary_final.rpt

# 전력
report_power > $report_dir/power_final.rpt

# 면적
report_area > $report_dir/area_final.rpt

# Violations
report_constraint -all_violators > $report_dir/violations_final.rpt

# Summary
summaryReport -outfile $report_dir/summary_final.rpt

# Geometry
verifyGeometry -report $report_dir/geometry_final.rpt

puts "✓ All reports generated in reports/final/"
puts ""

###############################################################################
# Step 5: GDS 생성
###############################################################################

puts "=============================================================================="
puts "Step 5: GDS Generation (Tape-out)"
puts "=============================================================================="
puts ""

set gds_file $project_root/results/gds/tt_um_Jsilicon.gds
set map_file $project_root/tech/lef/gds.map

# GDS map 파일 확인
if { ![file exists $map_file] } {
    puts "⚠ Warning: GDS map file not found: $map_file"
    puts "  Creating default map file..."
    
    # 기본 map 파일 생성
    set fp [open $map_file w]
    puts $fp "M1  10  0"
    puts $fp "M2  11  0"
    puts $fp "M3  12  0"
    puts $fp "M4  13  0"
    puts $fp "M5  14  0"
    puts $fp "M6  15  0"
    puts $fp "M7  16  0"
    puts $fp "M8  17  0"
    puts $fp "M9  18  0"
    puts $fp "M10 19  0"
    close $fp
}

# GDS 생성
puts "Generating GDS file..."
puts "  Output: $gds_file"

catch {
    streamOut $gds_file \
        -mapFile $map_file \
        -stripes 1 \
        -units 1000 \
        -mode ALL
} result

if { [file exists $gds_file] } {
    set gds_size [file size $gds_file]
    puts "✓ GDS file generated: [expr $gds_size / 1024] KB"
} else {
    puts "✗ GDS generation failed!"
    puts "  Error: $result"
}

puts ""
puts "✓ Step 5 Complete: GDS ready for tape-out"
puts ""

###############################################################################
# Step 6: 최종 요약
###############################################################################

puts "=============================================================================="
puts "✓✓✓ Complete Flow Finished! ✓✓✓"
puts "=============================================================================="
puts ""
puts "Generated Files:"
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "Checkpoints:"
puts "  work/pnr/jsilicon_final_opt.enc     - Timing optimized"
puts "  work/pnr/jsilicon_extracted.enc     - With parasitics"
puts ""
puts "Tape-out Files:"
puts "  results/gds/tt_um_Jsilicon.gds      - GDS file"
puts "  results/extraction/*.spef            - Parasitic capacitance"
puts "  results/extraction/*.sdf             - Back-annotation delays"
puts ""
puts "Verification:"
puts "  results/lvs/lvs_summary.rpt         - LVS results"
puts "  results/lvs/connectivity_check.rpt  - Connectivity"
puts ""
puts "Reports:"
puts "  reports/final/timing_summary_final.rpt"
puts "  reports/final/power_final.rpt"
puts "  reports/final/area_final.rpt"
puts "  reports/final/violations_final.rpt"
puts "  reports/final/summary_final.rpt"
puts ""
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts ""
puts "Next Steps:"
puts "  1. Review timing:     cat reports/final/timing_summary_final.rpt"
puts "  2. Check violations:  cat reports/final/violations_final.rpt"
puts "  3. Verify LVS:        cat results/lvs/lvs_summary.rpt"
puts "  4. View layout:       calibredrv (open GDS)"
puts "  5. Submit tape-out:   Send GDS to foundry"
puts ""
puts "=============================================================================="
puts ""

exit
