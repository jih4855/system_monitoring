import os
import json
import logging                   

class Discord:
    def __init__(self, url, message, max_length=2000):
        self.url = url
        self.message = message
        self.max_length = max_length

    def send_message(self):
        try:
            import requests
            headers = {
                'Content-Type': 'application/json',
            }
            data = {
                'content': self.message,
            }
            response = requests.post(self.url, headers=headers, data=json.dumps(data))
            if response.status_code == 204:
                logging.info("Discord 메시지 전송 성공")
            else:
                logging.error(f"Discord 메시지 전송 실패: {response.status_code}, {response.text}")
        except Exception as e:
            logging.error(f"Discord 메시지 전송 중 오류 발생: {e}")

    def split_message(self):
        """메시지를 최대 길이에 맞게 분할하는 함수"""
        if len(self.message) <= self.max_length:
            return [self.message]
        else:
            # 메시지를 최대 길이에 맞게 분할
            return [self.message[i:i + self.max_length] for i in range(0, len(self.message), self.max_length)]
