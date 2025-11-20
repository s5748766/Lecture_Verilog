#!/bin/csh
###############################################################################
# JSilicon RTL-to-GDS 완전 자동화 스크립트
# run_full_flow.csh
###############################################################################

set PROJECT_ROOT = `pwd`
set DESIGN_NAME = "tt_um_Jsilicon"

echo "=========================================="
echo " JSilicon RTL-to-GDS Full Flow"
echo " Design: $DESIGN_NAME"
echo "=========================================="
echo ""

# 디렉토리 체크
if ( ! -d src ) then
    echo "Error: src directory not found. Run from project root."
    exit 1
endif

# 작업 디렉토리 생성
echo "Step 0: Creating work directories..."
mkdir -p work/synthesis
mkdir -p work/pnr
mkdir -p reports/synthesis
mkdir -p reports/pnr
mkdir -p reports/sta
mkdir -p results/netlist
mkdir -p results/def
mkdir -p results/gds
echo "✓ Directories created"
echo ""

###############################################################################
# Step 1: RTL Synthesis (Genus)
###############################################################################
echo "=========================================="
echo "Step 1: RTL Synthesis (Genus)"
echo "=========================================="

if ( ! -f scripts/genus/synthesis.tcl ) then
    echo "Error: scripts/genus/synthesis.tcl not found"
    exit 1
endif

cd work/synthesis
echo "Running Genus synthesis..."
genus -f ../../scripts/genus/synthesis.tcl |& tee synthesis.log

if ( $status != 0 ) then
    echo "✗ Synthesis failed!"
    exit 1
endif

cd $PROJECT_ROOT

# Synthesis 결과 확인
echo ""
echo "=== Synthesis Results ==="
if ( -f results/netlist/${DESIGN_NAME}_synth.v ) then
    echo "✓ Synthesized netlist generated"
    ls -lh results/netlist/${DESIGN_NAME}_synth.v
else
    echo "✗ Synthesized netlist not found!"
    exit 1
endif

if ( -f reports/synthesis/qor.rpt ) then
    echo ""
    echo "=== QoR Summary ==="
    tail -50 reports/synthesis/qor.rpt
endif

echo ""
read -p "Continue to P&R? (y/n): " answer
if ( "$answer" != "y" ) then
    echo "Stopped at synthesis stage."
    exit 0
endif

###############################################################################
# Step 2: Floorplan & Power Planning
###############################################################################
echo ""
echo "=========================================="
echo "Step 2: Floorplan & Power Planning"
echo "=========================================="

cd work/pnr

if ( ! -f ../../scripts/innovus/pnr_flow.tcl ) then
    echo "Error: scripts/innovus/pnr_flow.tcl not found"
    exit 1
endif

echo "Running Innovus floorplan..."
innovus -init ../../scripts/innovus/pnr_flow.tcl |& tee pnr.log

if ( $status != 0 ) then
    echo "✗ P&R failed!"
    exit 1
endif

cd $PROJECT_ROOT

# P&R 결과 확인
echo ""
echo "=== P&R Results ==="

if ( -f results/def/${DESIGN_NAME}.def ) then
    echo "✓ DEF file generated"
    ls -lh results/def/${DESIGN_NAME}.def
else
    echo "✗ DEF file not found!"
endif

if ( -f results/netlist/${DESIGN_NAME}_final.v ) then
    echo "✓ Final netlist generated"
    ls -lh results/netlist/${DESIGN_NAME}_final.v
else
    echo "✗ Final netlist not found!"
endif

if ( -f reports/pnr/summary.rpt ) then
    echo ""
    echo "=== P&R Summary ==="
    tail -50 reports/pnr/summary.rpt
endif

echo ""
read -p "Continue to STA? (y/n): " answer
if ( "$answer" != "y" ) then
    echo "Stopped at P&R stage."
    exit 0
endif

###############################################################################
# Step 3: Static Timing Analysis (Tempus)
###############################################################################
echo ""
echo "=========================================="
echo "Step 3: Static Timing Analysis (Tempus)"
echo "=========================================="

if ( ! -f scripts/tempus/sta.tcl ) then
    echo "Warning: scripts/tempus/sta.tcl not found, skipping STA"
    goto step4
endif

cd work/pnr

echo "Running Tempus STA..."
tempus -f ../../scripts/tempus/sta.tcl |& tee sta.log

cd $PROJECT_ROOT

if ( -f reports/sta/timing_summary.rpt ) then
    echo ""
    echo "=== Timing Summary ==="
    tail -50 reports/sta/timing_summary.rpt
endif

step4:
###############################################################################
# Step 4: DRC/LVS Verification
###############################################################################
echo ""
echo "=========================================="
echo "Step 4: DRC/LVS Check (Optional)"
echo "=========================================="

if ( -f results/gds/${DESIGN_NAME}.gds ) then
    echo "✓ GDS file exists"
    ls -lh results/gds/${DESIGN_NAME}.gds
    
    echo ""
    echo "To run DRC/LVS, use:"
    echo "  Calibre: calibre -drc drc.rule"
    echo "  Magic:   magic -dnull -noconsole -rcfile sky130.magicrc"
else
    echo "Note: GDS file not generated yet"
    echo "Generate GDS in Innovus: streamOut command"
endif

###############################################################################
# Final Summary
###############################################################################
echo ""
echo "=========================================="
echo " Flow Completion Summary"
echo "=========================================="
echo ""

echo "Design: $DESIGN_NAME"
echo ""

# Check all outputs
echo "Generated Files:"
echo "----------------"

set files_to_check = ( \
    "results/netlist/${DESIGN_NAME}_synth.v:Synthesis Netlist" \
    "results/netlist/${DESIGN_NAME}_final.v:Final Netlist" \
    "results/def/${DESIGN_NAME}.def:DEF Layout" \
    "results/gds/${DESIGN_NAME}.gds:GDS Layout" \
)

foreach file_info ( $files_to_check )
    set file_path = `echo $file_info | cut -d: -f1`
    set file_desc = `echo $file_info | cut -d: -f2`
    
    if ( -f $file_path ) then
        echo "  ✓ $file_desc"
        ls -lh $file_path | awk '{printf "    Size: %s, Date: %s %s\n", $5, $6, $7}'
    else
        echo "  ✗ $file_desc (not found)"
    endif
end

echo ""
echo "Reports:"
echo "--------"

foreach dir (reports/synthesis reports/pnr reports/sta)
    if ( -d $dir ) then
        set rpt_count = `ls $dir/*.rpt 2>/dev/null | wc -l`
        if ( $rpt_count > 0 ) then
            echo "  ✓ `basename $dir`: $rpt_count reports"
        endif
    endif
end

echo ""
echo "=========================================="
echo "Flow completed!"
echo "=========================================="
