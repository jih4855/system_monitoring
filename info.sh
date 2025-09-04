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
    
    local required_files=("python_scripts/system_info.py" "config.yaml" ".env")
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

# 파이썬 패키지 확인 및 설치
check_python_packages() {
    log_info "Python 패키지 의존성 확인 중..."
    
    # 가상환경에서 패키지 확인
    if ! venv/bin/pip show pyyaml >/dev/null 2>&1; then
        log_warning "PyYAML 패키지가 설치되지 않았습니다. 설치 중..."
        venv/bin/pip install pyyaml
    fi
    
    if ! venv/bin/pip show python-dotenv >/dev/null 2>&1; then
        log_warning "python-dotenv 패키지가 설치되지 않았습니다. 설치 중..."
        venv/bin/pip install python-dotenv
    fi
    
    log_success "Python 패키지 의존성 확인 완료"
}

# 메인 실행 함수
run_system_info() {
    local start_time=$(date +%s)
    
    echo -e "${PURPLE}╔══════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║        시스템 정보 수집 도구          ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════╝${NC}"
    echo ""
    
    show_progress 1 4
    check_and_activate_venv
    
    show_progress 2 4
    check_dependencies
    
    show_progress 3 4
    check_python_packages
    
    show_progress 4 4
    log_info "시스템 정보 수집 실행 중..."
    
    # Python 스크립트 실행
    if venv/bin/python python_scripts/system_info.py; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_success "시스템 정보 수집이 성공적으로 완료되었습니다! (소요시간: ${duration}초)"
    else
        log_error "시스템 정보 수집 중 오류가 발생했습니다."
        exit 1
    fi
}

# 도움말 표시
show_help() {
    echo -e "${CYAN}사용법:${NC}"
    echo "  ./info.sh [옵션]"
    echo ""
    echo -e "${CYAN}옵션:${NC}"
    echo "  -h, --help     이 도움말 표시"
    echo "  -v, --verbose  상세한 출력 표시"
    echo "  -q, --quiet    최소한의 출력만 표시"
    echo ""
    echo -e "${CYAN}예시:${NC}"
    echo "  ./info.sh              # 기본 실행"
    echo "  ./info.sh --verbose    # 상세 출력과 함께 실행"
    echo "  ./info.sh --quiet      # 조용한 모드로 실행"
}

# 명령행 인자 처리
VERBOSE=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            show_help
            exit 1
            ;;
    esac
done

# 조용한 모드 설정
if [ "$QUIET" = true ]; then
    exec > /dev/null 2>&1
elif [ "$VERBOSE" = true ]; then
    log_info "상세 모드로 실행합니다."
    set -x
fi


# 메인 실행
run_system_info