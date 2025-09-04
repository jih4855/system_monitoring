import google.generativeai as genai
import ollama

class LLMHandler:
    def __init__(self, model_name, api_key, system_prompt, user_input, provider):
        self.model_name = model_name
        self.api_key = api_key
        self.system_prompt = system_prompt
        self.user_input = user_input
        self.provider = provider

    def load_llm(self):
        if self.provider == "gemini":
            try:
                genai.configure(api_key=self.api_key)
                model = genai.GenerativeModel(self.model_name)
                prompt = f"시스템 프롬프트 : {self.system_prompt}\n\n 유저 프롬프트 : {self.user_input}"
                response = model.generate_content(prompt)
                return response.text
            except Exception as e:
                return f"Error generating response with Gemini: {e}"
        elif self.provider == "ollama":
            try:
                # messages 리스트 먼저 구성
                messages = [
                    {"role": "system", "content": self.system_prompt},
                    {"role": "user", "content": self.user_input}
                ]
                # 한 번만 호출
                response = ollama.chat(model=self.model_name, messages=messages)
                return response["message"]["content"]
            except Exception as e:
                return f"Error generating response with Ollama: {e}"
        else:
            return "Unsupported provider"
