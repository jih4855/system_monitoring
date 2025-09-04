# Linux Scripts 프로젝트

## 프로젝트 구조
```
linux_scripts/
├── info.sh                 # 시스템 정보 수집 쉘 스크립트
├── python_scripts/
│   └── linux_info.py      # 시스템 정보 수집 파이썬 스크립트
├── module/
│   ├── __init__.py
│   └── llm.py            # LLM 관련 모듈
└── venv/                 # 파이썬 가상환경
```

## 실행 방법
```bash
# 스크립트 실행 권한 부여
chmod +x info.sh

# 스크립트 실행
./info.sh
```

## 주요 기능
- 시스템 정보 수집 및 출력
- 가상환경 자동 활성화
- 에러 처리 및 상태 표시
- 학습 위주
- 코드 추천
- 파일변경 금지

## 개발 환경
- Python 3.x
- 가상환경 사용
- google-generativeai 라이브러리 필요

## 테스트 명령어
```bash
# 스크립트 직접 실행
./info.sh

# 파이썬 스크립트 직접 실행 (가상환경 내에서)
source venv/bin/activate
python3 python_scripts/linux_info.py
```