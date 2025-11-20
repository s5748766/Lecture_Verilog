#!/bin/csh
###############################################################################
# GDS 생성 및 테이프아웃 준비 스크립트
# generate_gds.csh
###############################################################################

set DESIGN_NAME = "tt_um_Jsilicon"
set PDK = "sky130"

echo "=========================================="
echo " GDS Generation & Tapeout Preparation"
echo " Design: $DESIGN_NAME"
echo " PDK: $PDK"
echo "=========================================="
echo ""

# 필수 파일 체크
echo "Step 1: Checking prerequisites..."

if ( ! -f results/def/${DESIGN_NAME}.def ) then
    echo "✗ Error: DEF file not found. Run P&R first."
    exit 1
endif

echo "✓ DEF file exists"

if ( ! -f results/netlist/${DESIGN_NAME}_final.v ) then
    echo "✗ Error: Final netlist not found. Run P&R first."
    exit 1
endif

echo "✓ Final netlist exists"
echo ""

###############################################################################
# Innovus에서 GDS 생성
###############################################################################
echo "Step 2: Generating GDS from Innovus..."
echo ""

# GDS 생성 TCL 스크립트 작성
cat > /tmp/generate_gds.tcl << 'EOF'
# GDS 생성 스크립트

# 디자인 로드 (이미 Innovus에서 P&R 완료된 상태라고 가정)
# 만약 새로 시작한다면:
# restoreDesign innovus_save.enc.dat $DESIGN_NAME

# Filler cell 추가 (아직 안했다면)
setFillerMode -corePrefix FILL -core "sky130_fd_sc_hd__fill_*"
addFiller

# DRC/LVS를 위한 antenna rule 체크
setNanoRouteMode -droutePostRouteSwapVia true
verifyGeometry -report results/pnr/geometry.rpt
verifyConnectivity -report results/pnr/connectivity.rpt

# Metal fill 추가 (옵션)
# addMetalFill -layer {metal1 metal2 metal3 metal4 metal5}

# GDS map 파일 설정 (PDK에 포함되어 있어야 함)
set gds_map_file "$env(PDK_ROOT)/$PDK/libs.tech/klayout/$PDK.gds.map"

if { [file exists $gds_map_file] } {
    puts "Using GDS map: $gds_map_file"
} else {
    puts "Warning: GDS map file not found, using default"
    set gds_map_file "gds.map"
}

# GDS 출력
streamOut results/gds/${DESIGN_NAME}.gds \
    -mapFile $gds_map_file \
    -libName ${DESIGN_NAME} \
    -structureName ${DESIGN_NAME} \
    -units 1000 \
    -mode ALL

puts "GDS generation completed!"

# LEF abstract 생성 (hierarchical design에 유용)
write_lef_abstract -specifyTopLayer metal5 results/${DESIGN_NAME}.lef

# 최종 DEF 저장 (filler 포함)
defOut -floorplan -netlist -routing results/def/${DESIGN_NAME}_final.def

puts "All outputs generated successfully!"
EOF

# Innovus 실행 (이미 열려있는 세션이 있다면)
echo "GDS generation TCL script created at /tmp/generate_gds.tcl"
echo ""
echo "To generate GDS:"
echo "  Option 1: If Innovus is already open with your design:"
echo "    innovus> source /tmp/generate_gds.tcl"
echo ""
echo "  Option 2: Generate from saved design:"

cat > scripts/innovus/generate_gds.tcl << 'GDSEOF'
#!/bin/tclsh
# GDS 생성을 위한 독립 실행 스크립트

set DESIGN_NAME "tt_um_Jsilicon"

# 저장된 디자인 복원
if { [file exists "work/pnr/${DESIGN_NAME}_final.enc.dat"] } {
    restoreDesign "work/pnr/${DESIGN_NAME}_final.enc.dat" $DESIGN_NAME
} else {
    puts "Error: Saved design not found. Run P&R first."
    exit 1
}

# Filler 추가
setFillerMode -corePrefix FILL -core "sky130_fd_sc_hd__fill_*"
addFiller

# Verification
verifyGeometry -report reports/pnr/geometry.rpt
verifyConnectivity -report reports/pnr/connectivity.rpt

# GDS 출력
set gds_map "$env(PDK_ROOT)/sky130/libs.tech/klayout/sky130.gds.map"
if { ![file exists $gds_map] } {
    set gds_map "gds.map"
}

streamOut results/gds/${DESIGN_NAME}.gds \
    -mapFile $gds_map \
    -libName ${DESIGN_NAME} \
    -structureName ${DESIGN_NAME} \
    -units 1000 \
    -mode ALL

# LEF 생성
write_lef_abstract -specifyTopLayer metal5 results/${DESIGN_NAME}.lef

# Final DEF
defOut -floorplan -netlist -routing results/def/${DESIGN_NAME}_final.def

puts "GDS generation completed!"
exit
GDSEOF

chmod +x scripts/innovus/generate_gds.tcl

echo "    innovus -init scripts/innovus/generate_gds.tcl"
echo ""

###############################################################################
# GDS 검증
###############################################################################
echo "Step 3: GDS Verification (when ready)..."
echo ""

if ( -f results/gds/${DESIGN_NAME}.gds ) then
    echo "✓ GDS file exists!"
    ls -lh results/gds/${DESIGN_NAME}.gds
    
    # GDS 정보 확인 (klayout 사용)
    if ( `which klayout` != "" ) then
        echo ""
        echo "Checking GDS with KLayout..."
        klayout -zz -r scripts/klayout/check_gds.py results/gds/${DESIGN_NAME}.gds
    endif
    
    # Magic 사용 GDS 확인
    if ( `which magic` != "" ) then
        echo ""
        echo "To view GDS in Magic:"
        echo "  magic -dnull -noconsole results/gds/${DESIGN_NAME}.gds"
    endif
else
    echo "✗ GDS file not yet generated"
endif

echo ""

###############################################################################
# DRC 체크 준비
###############################################################################
echo "Step 4: DRC Check Preparation..."
echo ""

# Magic DRC 스크립트 생성
mkdir -p scripts/magic

cat > scripts/magic/run_drc.tcl << 'DRCEOF'
# Magic DRC 체크 스크립트

# GDS 로드
gds read results/gds/tt_um_Jsilicon.gds

# DRC 체크
drc on
drc check

# 결과 저장
drc catchup
set drc_count [drc list count total]
puts "Total DRC violations: $drc_count"

# DRC 리포트 저장
drc listall why > reports/drc/drc_violations.rpt

if { $drc_count == 0 } {
    puts "✓ DRC Clean!"
} else {
    puts "✗ DRC violations found. Check reports/drc/drc_violations.rpt"
}

quit
DRCEOF

echo "DRC script created: scripts/magic/run_drc.tcl"
echo ""
echo "To run DRC with Magic:"
echo "  mkdir -p reports/drc"
echo "  magic -dnull -noconsole -rcfile \$PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc \\"
echo "        scripts/magic/run_drc.tcl"
echo ""

###############################################################################
# 테이프아웃 체크리스트
###############################################################################
echo "=========================================="
echo " Tapeout Checklist"
echo "=========================================="
echo ""

set checklist_items = ( \
    "results/netlist/${DESIGN_NAME}_final.v:Final Netlist (LVS)" \
    "results/def/${DESIGN_NAME}_final.def:Final DEF" \
    "results/gds/${DESIGN_NAME}.gds:GDS Layout" \
    "results/${DESIGN_NAME}.lef:LEF Abstract" \
    "reports/pnr/timing.rpt:Timing Reports" \
    "reports/pnr/summary.rpt:P&R Summary" \
    "reports/drc/drc_violations.rpt:DRC Report" \
)

set all_ready = 1

foreach item ( $checklist_items )
    set file_path = `echo $item | cut -d: -f1`
    set file_desc = `echo $item | cut -d: -f2`
    
    if ( -f $file_path ) then
        echo "  ✓ $file_desc"
    else
        echo "  ✗ $file_desc (missing)"
        set all_ready = 0
    endif
end

echo ""

if ( $all_ready == 1 ) then
    echo "✓ All required files present - Ready for tapeout!"
else
    echo "✗ Some files are missing - Complete all steps first"
endif

echo ""
echo "=========================================="
echo " Next Steps for Tapeout"
echo "=========================================="
echo ""
echo "1. Run DRC (Design Rule Check):"
echo "   magic -dnull -noconsole -rcfile \$PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc \\"
echo "         scripts/magic/run_drc.tcl"
echo ""
echo "2. Run LVS (Layout vs Schematic):"
echo "   netgen -batch lvs \"results/gds/${DESIGN_NAME}.gds ${DESIGN_NAME}\" \\"
echo "               \"results/netlist/${DESIGN_NAME}_final.v ${DESIGN_NAME}\" \\"
echo "               \$PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl \\"
echo "               reports/lvs/lvs_report.txt"
echo ""
echo "3. Create tapeout package:"
echo "   - GDS file: results/gds/${DESIGN_NAME}.gds"
echo "   - LEF file: results/${DESIGN_NAME}.lef"
echo "   - Datasheet: docs/datasheet.pdf"
echo "   - All verification reports"
echo ""
echo "4. Submit to foundry/shuttle service"
echo ""
echo "=========================================="
