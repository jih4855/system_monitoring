#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수들
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 진행률 표시 함수
show_progress() {
    local current=$1
    local total=$2
    local progress=$((current * 100 / total))
    echo -e "${CYAN}진행률: ${progress}% (${current}/${total})${NC}"
}

# 권한 확인 함수
check_sudo_access() {
    if [ "$REQUIRE_SUDO" = true ]; then
        log_info "관리자 권한이 필요한 작업을 수행합니다."
        if ! sudo -v; then
            log_error "관리자 권한을 얻을 수 없습니다."
            exit 1
        fi
        log_success "관리자 권한 확인 완료"
    fi
}

# 백업 생성 함수
create_backup() {
    local backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    log_info "백업 디렉토리 생성: $backup_dir"
    mkdir -p "$backup_dir"
    
    # 중요 설정 파일들 백업
    if [ -f "/etc/apt/sources.list" ] && [ "$os_type" = "ubuntu" ]; then
        sudo cp /etc/apt/sources.list "$backup_dir/" 2>/dev/null || true
    fi
    
    log_success "백업이 생성되었습니다: $backup_dir"
    echo "$backup_dir" > .last_backup_path
}

# 가상환경 확인 및 활성화
check_and_activate_venv() {
    if [ ! -d "venv" ]; then
        log_error "가상환경(venv)이 존재하지 않습니다."
        log_info "가상환경을 생성하시겠습니까? (y/n)"
        read -r create_venv
        if [ "$create_venv" = "y" ] || [ "$create_venv" = "Y" ]; then
            log_info "가상환경 생성 중..."
            python3 -m venv venv
            log_success "가상환경이 생성되었습니다."
        else
            log_error "가상환경 없이는 스크립트를 실행할 수 없습니다."
            exit 1
        fi
    fi
    
    if [ ! -f "venv/bin/python" ]; then
        log_error "가상환경의 Python 실행 파일이 없습니다."
        exit 1
    fi
    
    log_success "가상환경 확인 완료"
}

# 의존성 확인
check_dependencies() {
    log_info "필요한 의존성 확인 중..."
    
    local required_files=("python_scripts/update_system.py" "config.yaml" ".env")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        log_error "다음 필수 파일들이 누락되었습니다:"
        for file in "${missing_files[@]}"; do
            echo -e "  ${RED}✗${NC} $file"
        done
        exit 1
    fi
    
    log_success "모든 필수 파일 확인 완료"
}

# 시스템 종류 감지
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "ubuntu"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# 업데이트 전 시스템 상태 확인
pre_update_check() {
    log_info "업데이트 전 시스템 상태 확인 중..."
    
    # 디스크 공간 확인
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        log_warning "디스크 사용량이 ${disk_usage}%입니다. 공간 확보를 권장합니다."
    fi
    
    # 메모리 상태 확인 (macOS 기준)
    if [ "$(detect_os)" = "macos" ]; then
        local memory_pressure=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
        if [ -n "$memory_pressure" ] && [ "$memory_pressure" -lt 10 ]; then
            log_warning "시스템 메모리가 부족할 수 있습니다."
        fi
    fi
    
    log_success "시스템 상태 확인 완료"
}

# 메인 업데이트 실행 함수
run_system_update() {
    local start_time=$(date +%s)
    local os_type=$(detect_os)
    
    echo -e "${PURPLE}╔══════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║        시스템 업데이트 도구          ║${NC}"
    echo -e "${PURPLE}║          OS: $(printf "%-20s" "$os_type")      ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════╝${NC}"
    echo ""
    
    show_progress 1 6
    check_and_activate_venv
    
    show_progress 2 6
    check_dependencies
    
    show_progress 3 6
    check_sudo_access
    
    show_progress 4 6
    pre_update_check
    
    show_progress 5 6
    if [ "$CREATE_BACKUP" = true ]; then
        create_backup
    fi
    
    show_progress 6 6
    log_info "시스템 업데이트 정보 수집 실행 중..."
    
    # Python 스크립트 실행
    if venv/bin/python python_scripts/update_system.py; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_success "시스템 업데이트 수집이 성공적으로 완료되었습니다! (소요시간: ${duration}초)"
        
        # 업데이트 후 정리 작업
        if [ "$CLEANUP_AFTER" = true ]; then
            log_info "업데이트 후 정리 작업 실행 중..."
            case $os_type in
                ubuntu)
                    sudo apt autoremove -y >/dev/null 2>&1 || true
                    sudo apt autoclean >/dev/null 2>&1 || true
                    ;;
                macos)
                    brew cleanup >/dev/null 2>&1 || true
                    ;;
            esac
            log_success "정리 작업 완료"
        fi
    else
        log_error "시스템 업데이트 수집 중 오류가 발생했습니다."
        exit 1
    fi
}

# 대화형 모드
interactive_mode() {
    echo -e "${PURPLE}╔══════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║          대화형 업데이트 모드        ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}다음 옵션들을 선택하세요:${NC}"
    echo "1) 관리자 권한이 필요한 업데이트 포함"
    echo "2) 백업 생성"
    echo "3) 업데이트 후 정리 작업 실행"
    echo ""
    
    read -p "관리자 권한이 필요한 업데이트를 포함하시겠습니까? (y/n): " sudo_choice
    [ "$sudo_choice" = "y" ] || [ "$sudo_choice" = "Y" ] && REQUIRE_SUDO=true
    
    read -p "백업을 생성하시겠습니까? (y/n): " backup_choice
    [ "$backup_choice" = "y" ] || [ "$backup_choice" = "Y" ] && CREATE_BACKUP=true
    
    read -p "업데이트 후 정리 작업을 실행하시겠습니까? (y/n): " cleanup_choice
    [ "$cleanup_choice" = "y" ] || [ "$cleanup_choice" = "Y" ] && CLEANUP_AFTER=true
    
    echo ""
    log_info "설정이 완료되었습니다. 업데이트를 시작합니다..."
}

# 도움말 표시
show_help() {
    echo -e "${CYAN}사용법:${NC}"
    echo "  ./update.sh [옵션]"
    echo ""
    echo -e "${CYAN}옵션:${NC}"
    echo "  -h, --help        이 도움말 표시"
    echo "  -i, --interactive 대화형 모드로 실행"
    echo "  -v, --verbose     상세한 출력 표시"
    echo "  -q, --quiet       최소한의 출력만 표시"
    echo "  -s, --sudo        관리자 권한이 필요한 업데이트 포함"
    echo "  -b, --backup      실행 전 백업 생성"
    echo "  -c, --cleanup     업데이트 후 정리 작업 실행"
    echo "  --dry-run         실제 업데이트 없이 확인만 수행"
    echo ""
    echo -e "${CYAN}예시:${NC}"
    echo "  ./update.sh                    # 기본 실행"
    echo "  ./update.sh --interactive      # 대화형 모드로 실행"
    echo "  ./update.sh --sudo --backup    # 관리자 권한과 백업을 포함하여 실행"
    echo "  ./update.sh --dry-run          # 업데이트 가능한 패키지만 확인"
}

# 명령행 인자 처리
VERBOSE=false
QUIET=false
INTERACTIVE=false
REQUIRE_SUDO=false
CREATE_BACKUP=false
CLEANUP_AFTER=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -s|--sudo)
            REQUIRE_SUDO=true
            shift
            ;;
        -b|--backup)
            CREATE_BACKUP=true
            shift
            ;;
        -c|--cleanup)
            CLEANUP_AFTER=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            show_help
            exit 1
            ;;
    esac
done

# 환경 변수 export
export REQUIRE_SUDO
export CREATE_BACKUP
export CLEANUP_AFTER
export DRY_RUN

# 조용한 모드 설정
if [ "$QUIET" = true ]; then
    exec > /dev/null 2>&1
elif [ "$VERBOSE" = true ]; then
    log_info "상세 모드로 실행합니다."
    set -x
fi

# 메인 실행
if [ "$INTERACTIVE" = true ]; then
    interactive_mode
fi

run_system_update