import os
from dotenv import load_dotenv

# Load environment variables from .env file
# We capture the return value to see if the file was even found.
load_success = load_dotenv()

print(f"偵錯資訊：.env 檔案是否被找到並載入? -> {load_success}")

# Get the API key from the environment
api_key = os.getenv("OPENAI_API_KEY")

if api_key:
    # For security, we only print partial information
    print("偵錯結果：成功找到 API Key！")
    print(f"金鑰開頭: {api_key[:5]}...")
    print(f"金鑰結尾: ...{api_key[-4:]}")
else:
    print("偵錯結果：在環境變數中找不到名為 OPENAI_API_KEY 的金鑰。")
