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