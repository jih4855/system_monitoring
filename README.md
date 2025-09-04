# Linux Scripts

크로스 플랫폼 시스템 모니터링 및 업데이트 도구

## 지원 운영체제

- Ubuntu/Debian Linux
- macOS 
- Windows (WSL 또는 Git Bash)

## 프로젝트 구조

```
linux_scripts/
├── info.sh                    # 시스템 정보 수집 스크립트
├── update.sh                  # 시스템 업데이트 스크립트
├── python_scripts/
│   ├── linux_info.py         # 시스템 정보 수집 Python 스크립트
│   └── update_system.py      # 시스템 업데이트 Python 스크립트
├── module/
│   ├── __init__.py
│   ├── llm.py               # LLM 통신 모듈
│   └── discord.py           # Discord 웹훅 모듈
├── config.yaml              # 설정 파일
├── .env                     # 환경 변수 (API 키 등)
└── venv/                    # Python 가상환경
```

## 설치 및 설정

### 1. 저장소 복제
```bash
git clone <repository-url>
cd linux_scripts
```

### 2. 가상환경 설정
```bash
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# 또는
venv\Scripts\activate     # Windows
```

### 3. 의존성 설치
```bash
pip install -r requirements.txt
```

### 4. 환경 변수 설정
`.env` 파일 생성 후 API 키 설정:
```
API_KEY=your_gemini_api_key_here
```

### 5. 설정 파일 편집
`config.yaml`에서 운영체제와 Discord 웹훅 URL 설정

## 사용법

### 시스템 정보 수집

```bash
# 기본 실행
./info.sh

# 상세 출력
./info.sh --verbose

# 조용한 모드
./info.sh --quiet

# 도움말
./info.sh --help
```

### 시스템 업데이트

```bash
# 기본 실행
./update.sh

# 대화형 모드
./update.sh --interactive

# 백업과 함께 실행
./update.sh --backup

# 관리자 권한으로 실행
./update.sh --sudo

# 정리 작업 포함
./update.sh --cleanup

# 확인만 수행 (실제 업데이트 안함)
./update.sh --dry-run
```

## 운영체제별 설정

### Ubuntu/Debian
- apt 패키지 관리자 사용
- systemctl 서비스 상태 확인
- snap, flatpak 패키지 지원

### macOS
- Homebrew 패키지 관리자 사용
- 시스템 프로파일러로 하드웨어 정보 수집
- 배터리 상태 모니터링

### Windows
- winget 패키지 관리자 사용
- Windows 서비스 상태 확인
- systeminfo 명령어로 시스템 정보 수집

## 주요 기능

### 시스템 정보 수집 (info.sh)
- CPU, 메모리, 디스크 사용량
- 네트워크 인터페이스 정보
- 시스템 가동 시간
- 실행 중인 프로세스 현황
- 실패한 서비스 목록

### 시스템 업데이트 (update.sh)
- 패키지 관리자별 업데이트 확인
- 사용자 레벨 패키지 업데이트
- 시스템 레벨 패키지 업데이트 (선택적)
- 업데이트 전 백업 생성
- 업데이트 후 정리 작업

## 설정 파일 (config.yaml)

```yaml
LLM:
  model: "gemini-2.5-flash"
  provider: "gemini"
  
Discord:
  url: "your_discord_webhook_url"
  
System:
  os_type: "ubuntu"  # ubuntu, macos, windows
  
Update:
  os_type: "ubuntu"  # ubuntu, macos, windows
```

## 필수 요구사항

- Python 3.7 이상
- pip 패키지 관리자
- 해당 운영체제의 패키지 관리자
  - Ubuntu: apt
  - macOS: brew
  - Windows: winget

## 문제 해결

### 권한 오류
스크립트 실행 권한 부여:
```bash
chmod +x info.sh update.sh
```

### Python 패키지 오류
가상환경 재생성:
```bash
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### API 키 오류
`.env` 파일에 올바른 API 키 설정 확인

## 라이센스

MIT License

## 기여

버그 리포트나 기능 제안은 이슈로 등록해주세요.
=======
