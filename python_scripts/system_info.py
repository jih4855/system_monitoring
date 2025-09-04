#os 상태 점검
import os
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from module.llm import LLMHandler
from module.discord import Discord
import yaml
import dotenv
import psutil
import platform
import time

# .env 파일 로드
dotenv.load_dotenv()

# config.yaml 파일 경로
config_path = os.path.join(os.path.dirname(__file__), '..', 'config.yaml')

def get_system_info():
    """시스템 상태를 점검하는 함수"""
    basic_info={
        "OS": platform.platform(),
        "Hostname": platform.node(),
        "Uptime": f"{round((time.time() - psutil.boot_time()) / 3600, 1)} hours",
        "CPU": f"{platform.processor()} ({psutil.cpu_count(logical=True)} cores)",
        "CPU Usage": f"{psutil.cpu_percent(interval=1)}%",
        "Memory": f"{round(psutil.virtual_memory().total / (1024 ** 3), 2)} GB",
        "Memory Usage": f"{psutil.virtual_memory().percent}%",
        "Disk": f"{round(psutil.disk_usage('/').total / (1024 ** 3), 2)} GB",
        "Disk Usage": f"{psutil.disk_usage('/').percent}%"
    }
    return basic_info


def main():
    with open(config_path, 'r') as config_file:
        config = yaml.safe_load(config_file)
    info = get_system_info()
    llm_handler = LLMHandler(config['LLM']['model'],
                             os.getenv("API_KEY"),
                             config['LLM']['system_prompt'],
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