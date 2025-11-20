#!/bin/csh
###############################################################################
# JSilicon 모듈 완전 분석 (개선 버전)
# analyze_modules_v2.csh
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
        
        # 모든 가능한 모듈 이름 추출 (대문자로 시작하는 것들)
        set all_modules = `grep "^module" $files | awk '{print $2}' | sed 's/(.*$//' | sort -u`
        
        # 인스턴스 찾기 - 여러 패턴 지원
        # 패턴 1: module_name instance_name (
        # 패턴 2: module_name #(...) instance_name (
        
        echo "인스턴스:"
        set found_inst = 0
        
        foreach mod ( $all_modules )
            # 각 모듈의 인스턴스를 찾음
            set instances = `grep -E "^\s*$mod\s+" $file | grep -v "^module" | awk '{print $NF}' | sed 's/(.*$//' | sed 's/;.*$//'`
            
            if ( "$instances" != "" ) then
                foreach inst ( $instances )
                    if ( "$inst" != "" && "$inst" != "$mod" ) then
                        echo "  - $inst <- $mod"
                        set found_inst = 1
                    endif
                end
            endif
        end
        
        if ( $found_inst == 0 ) then
            echo "  없음 (Leaf 모듈)"
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

# 모든 모듈 이름 목록
set all_modules = `grep "^module" $files | awk '{print $2}' | sed 's/(.*$//' | sort -u`

# Level 1 인스턴스
echo "Level 1 인스턴스:"
set level1_list = ()
foreach mod ( $all_modules )
    set instances = `grep -E "^\s*$mod\s+" $top_file | grep -v "^module" | awk '{print $NF}' | sed 's/(.*$//' | sed 's/;.*$//'`
    
    if ( "$instances" != "" ) then
        foreach inst ( $instances )
            if ( "$inst" != "" && "$inst" != "$mod" ) then
                echo "  ├── $inst <- $mod"
                set level1_list = ( $level1_list $mod )
            endif
        end
    endif
end

# 마지막 항목의 ├── 를 └── 로 변경 (간단히 마지막에 표시)
echo ""

# 각 Level 1 모듈의 하위 확인
echo "Level 2+ 인스턴스:"
echo ""

foreach l1_module ( $level1_list )
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
        set found_sub = 0
        echo "  $l1_module 의 하위 인스턴스:"
        
        foreach mod ( $all_modules )
            set sub_instances = `grep -E "^\s*$mod\s+" $module_file | grep -v "^module" | awk '{print $NF}' | sed 's/(.*$//' | sed 's/;.*$//'`
            
            if ( "$sub_instances" != "" ) then
                foreach inst ( $sub_instances )
                    if ( "$inst" != "" && "$inst" != "$mod" ) then
                        echo "    ├── $inst <- $mod"
                        set found_sub = 1
                    endif
                end
            endif
        end
        
        if ( $found_sub == 0 ) then
            echo "    (Leaf 모듈)"
        endif
        echo ""
    endif
end

echo "=========================================="
echo "분석 완료"
echo "=========================================="
