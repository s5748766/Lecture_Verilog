#!/bin/csh
###############################################################################
# 설계 흐름 상태 체크 스크립트
# check_status.csh
###############################################################################

set DESIGN_NAME = "tt_um_Jsilicon"

echo "=========================================="
echo " JSilicon Design Flow Status Check"
echo " Design: $DESIGN_NAME"
echo "=========================================="
echo ""

###############################################################################
# 1. Synthesis 상태
###############################################################################
echo "1. Synthesis Status"
echo "-------------------"

if ( -f results/netlist/${DESIGN_NAME}_synth.v ) then
    echo "  ✓ Synthesis COMPLETED"
    ls -lh results/netlist/${DESIGN_NAME}_synth.v
    
    if ( -f reports/synthesis/qor.rpt ) then
        echo ""
        echo "  QoR Summary (마지막 20줄):"
        tail -20 reports/synthesis/qor.rpt | sed 's/^/    /'
    endif
    
    if ( -f reports/synthesis/timing.rpt ) then
        echo ""
        echo "  Timing Summary:"
        grep -A 5 "Timing Summary" reports/synthesis/timing.rpt | sed 's/^/    /'
    endif
    
    if ( -f reports/synthesis/area.rpt ) then
        echo ""
        echo "  Area Summary:"
        grep -A 10 "Instance.*Area" reports/synthesis/area.rpt | head -15 | sed 's/^/    /'
    endif
else
    echo "  ✗ Synthesis NOT completed"
    echo "    Run: cd work/synthesis && genus -f ../../scripts/genus/synthesis.tcl"
endif

echo ""

###############################################################################
# 2. Place & Route 상태
###############################################################################
echo "2. Place & Route Status"
echo "-----------------------"

if ( -f results/def/${DESIGN_NAME}.def ) then
    echo "  ✓ P&R COMPLETED"
    ls -lh results/def/${DESIGN_NAME}.def
    
    if ( -f results/netlist/${DESIGN_NAME}_final.v ) then
        echo "  ✓ Final netlist exists"
        ls -lh results/netlist/${DESIGN_NAME}_final.v
    endif
    
    if ( -f reports/pnr/summary.rpt ) then
        echo ""
        echo "  P&R Summary (마지막 30줄):"
        tail -30 reports/pnr/summary.rpt | sed 's/^/    /'
    endif
    
    if ( -f reports/pnr/timing.rpt ) then
        echo ""
        echo "  Post-PNR Timing:"
        grep -E "WNS|TNS|Setup|Hold" reports/pnr/timing.rpt | head -10 | sed 's/^/    /'
    endif
    
    if ( -f reports/pnr/density.rpt ) then
        echo ""
        echo "  Cell Density:"
        tail -10 reports/pnr/density.rpt | sed 's/^/    /'
    endif
else
    echo "  ✗ P&R NOT completed"
    echo "    Run: cd work/pnr && innovus -init ../../scripts/innovus/pnr_flow.tcl"
endif

echo ""

###############################################################################
# 3. STA 상태
###############################################################################
echo "3. Static Timing Analysis Status"
echo "--------------------------------"

if ( -f reports/sta/timing_summary.rpt ) then
    echo "  ✓ STA COMPLETED"
    
    echo ""
    echo "  Timing Violations:"
    grep -E "Setup|Hold|WNS|TNS" reports/sta/timing_summary.rpt | sed 's/^/    /'
    
    echo ""
    echo "  Critical Paths (Top 5):"
    grep -A 20 "Critical Path" reports/sta/timing_summary.rpt | head -25 | sed 's/^/    /'
else
    echo "  ✗ STA NOT completed or reports not found"
    echo "    Run: cd work/pnr && tempus -f ../../scripts/tempus/sta.tcl"
endif

echo ""

###############################################################################
# 4. Physical Design 상태
###############################################################################
echo "4. Physical Design Files"
echo "------------------------"

if ( -f results/gds/${DESIGN_NAME}.gds ) then
    echo "  ✓ GDS file exists (Ready for tapeout!)"
    ls -lh results/gds/${DESIGN_NAME}.gds
else
    echo "  ✗ GDS file not found"
    echo "    Generate in Innovus with: streamOut"
endif

if ( -f results/def/${DESIGN_NAME}_filled.def ) then
    echo "  ✓ Filled DEF exists"
    ls -lh results/def/${DESIGN_NAME}_filled.def
endif

if ( -f results/${DESIGN_NAME}.lef ) then
    echo "  ✓ LEF abstract exists"
    ls -lh results/${DESIGN_NAME}.lef
endif

echo ""

###############################################################################
# 5. 로그 파일 체크
###############################################################################
echo "5. Log Files Status"
echo "-------------------"

set logs = (work/synthesis/synthesis.log work/pnr/pnr.log work/pnr/sta.log)

foreach log ($logs)
    if ( -f $log ) then
        set errors = `grep -i "error" $log | wc -l`
        set warnings = `grep -i "warning" $log | wc -l`
        
        echo "  `basename $log`:"
        echo "    Errors:   $errors"
        echo "    Warnings: $warnings"
        
        if ( $errors > 0 ) then
            echo "    ⚠ Check errors in: $log"
        endif
    endif
end

echo ""

###############################################################################
# 6. Next Steps 제안
###############################################################################
echo "=========================================="
echo "Next Steps:"
echo "=========================================="

if ( ! -f results/netlist/${DESIGN_NAME}_synth.v ) then
    echo "  1. Run Synthesis first"
    echo "     cd work/synthesis"
    echo "     genus -f ../../scripts/genus/synthesis.tcl |& tee synthesis.log"
else if ( ! -f results/def/${DESIGN_NAME}.def ) then
    echo "  1. Run Place & Route"
    echo "     cd work/pnr"
    echo "     innovus -init ../../scripts/innovus/pnr_flow.tcl |& tee pnr.log"
else if ( ! -f results/gds/${DESIGN_NAME}.gds ) then
    echo "  1. Generate GDS for tapeout"
    echo "     In Innovus GUI or add to TCL:"
    echo "     streamOut ${DESIGN_NAME}.gds -mapFile gds.map -libName $DESIGN_NAME"
else
    echo "  ✓ All major steps completed!"
    echo "  1. Run DRC: calibre -drc drc.rule"
    echo "  2. Run LVS: calibre -lvs lvs.rule"
    echo "  3. Review all timing reports"
    echo "  4. Prepare tapeout package"
endif

echo ""
echo "=========================================="
