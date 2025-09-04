#우분투 상태 점검
import os
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from module.llm import LLMHandler
from module.discord import Discord
import yaml
import dotenv
import subprocess
import shlex
import platform
import logging

# .env 파일 로드
dotenv.load_dotenv()

# config.yaml 파일 경로
config_path = os.path.join(os.path.dirname(__file__), '..', 'config.yaml')

def setup_logging():
    """로깅 설정"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler('system_update.log'),  # 파일에 저장
            logging.StreamHandler()  # 콘솔에도 출력
        ]
    )
    return logging.getLogger(__name__)

logger = setup_logging()
def system_update_info():
    """시스템 업데이트 상태를 점검하는 함수"""
    system = platform.system()
    logger.info(f'현재 OS: {system}')

    try:
        if system == "Linux":
            # 우분투/Debian 계열
            cmd = "apt list --upgradable"
            logger.info(f'실행 명령어: {cmd}:log')
            result = subprocess.run(shlex.split(cmd), capture_output=True, text=True, timeout=60)
            updates = result.stdout.strip().split('\n')[1:]  # 첫 줄은 헤더이므로 제외
            if updates:
                update_info = "업데이트 가능한 패키지:\n" + "\n".join(updates)
            else:
                update_info = "모든 패키지가 최신 상태입니다."
        elif system == "Darwin":
            # macOS
            cmd = "softwareupdate -l"
            logger.info(f'실행 명령어: {cmd}:log')
            result = subprocess.run(shlex.split(cmd), capture_output=True, text=True, timeout=60)
            updates = [line for line in result.stdout.strip().split('\n') if '*' in line]
            if updates:
                update_info = "업데이트 가능한 항목:\n" + "\n".join(updates)
            else:
                update_info = "모든 소프트웨어가 최신 상태입니다."
        elif system == "Windows":
            # Windows
            cmd = "powershell -Command \"Get-WindowsUpdate -AcceptAll -IgnoreReboot\""
            logger.info(f'실행 명령어: {cmd}:log')
            result = subprocess.run(cmd, capture_output=True, text=True, shell=True, timeout=60)
            updates = result.stdout.strip().split('\n')
            if updates:
                update_info = "업데이트 가능한 항목:\n" + "\n".join(updates)
            else:
                update_info = "모든 소프트웨어가 최신 상태입니다."
        else:
            update_info = f"{system} 시스템은 지원되지 않습니다."
    except Exception as e:
        update_info = f"업데이트 상태 점검 중 오류 발생: {e}"

    return update_info

def main():
    with open(config_path, 'r') as config_file:
        config = yaml.safe_load(config_file)
    info = system_update_info()
    print("업데이트 시스템 정보:")
    print(info)
    llm_handler = LLMHandler(config['LLM']['model'],
                             os.getenv("API_KEY"),
                             config['LLM']['update_system_prompt'],
                             info,
                             config['LLM']['provider'])    
    response = llm_handler.load_llm()
    print("LLM 응답:")
    print(response)
    discord = Discord(os.getenv("Discord"), "상태 점검 결과:\n" + response)
    messages = discord.split_message()
    for msg in messages:
        discord.message = msg
        discord.send_message()


if __name__ == "__main__":
    main()