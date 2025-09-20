import os
from dotenv import load_dotenv
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_community.vectorstores import Chroma
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain

# --- 1. 可用投資主題 (Available Investment Themes) ---
# 根據我們的資料和金融顧問的建議，定義可供使用者選擇的主題
AVAILABLE_THEMES = [
    "高股息",
    "科技/半導體",
    "市值型",
    "ESG",
    "債券型",
    "低波動"
]

# --- 2. 核心推薦邏輯 (Core Recommendation Logic) ---
import json

def generate_recommendation(selected_themes: list[str]):
    """
    接收使用者選擇的主題，並生成投資建議報告。
    """
    print(f"接收到使用者選擇的主題: {selected_themes}")
    
    # 步驟 1: 載入環境變數與向量資料庫
    print("步驟 1: 載入環境變數與向量資料庫...")
    load_dotenv()
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("OpenAI API Key not found.")
        
    embeddings = OpenAIEmbeddings(api_key=api_key, model="text-embedding-3-small")
    persist_directory = 'chroma_db'
    if not os.path.exists(persist_directory):
        raise FileNotFoundError(f"向量資料庫 '{persist_directory}' 不存在。")
        
    vectordb = Chroma(persist_directory=persist_directory, embedding_function=embeddings)
    print(" -> 向量資料庫載入成功。")

    # 步驟 2: 根據主題從資料庫檢索相關 ETF
    query = f"尋找關於 '{'、'.join(selected_themes)}' 的高股息或科技類ETF"
    print(f"步驟 2: 根據查詢 '{query}' 檢索相關 ETF...")
    retrieved_docs = vectordb.similarity_search(query, k=10)
    print(f" -> 成功檢索到 {len(retrieved_docs)} 筆相關文件。")
    
    # 步驟 3: 設計 Prompt 並請求 LLM 生成報告
    print("步驟 3: 設計 Prompt 並請求 LLM 生成報告...")

    # 將檢索到的文件內容轉換為一個字串上下文
    context = "\n\n---\n\n".join([doc.page_content for doc in retrieved_docs])

    # 根據 task.md 設計的 Prompt 範本
    prompt_template = """
    你是一位專業、謹慎且值得信賴的ETF投資顧問。
    
    使用者的投資偏好是: {themes}

    根據以下我提供的多檔ETF資料作為你的知識庫:
    ---
    {context}
    ---
    
    請為使用者從上述資料中，挑選出 2-3 檔最符合其投資偏好的ETF，並提供一份完整的投資組合建議。

    你的分析報告必須包含以下內容：
    1.  **整體分析 (overall_analysis)**: 對於為何推薦這個組合的整體說明，以及這個組合如何滿足使用者的偏好。
    2.  **投資組合 (portfolio)**: 一個包含推薦的ETF的列表。每個ETF項目應包含:
        - `etf_code`: ETF 代號
        - `etf_name`: ETF 名稱
        - `allocation`: 建議的資金配置百分比 (例如 40，不需要%符號)
        - `reason`: 推薦此檔ETF的簡短原因

    你的回覆必須是嚴格的 JSON 格式，不包含任何 JSON 格式以外的文字或註解。JSON 的根鍵應為 "report"。
    請確保 portfolio 中所有 ETF 的 allocation 總和為 100。

    JSON 格式範例如下:
    {{ 
      "report": {{
        "overall_analysis": "...",
        "portfolio": [
          {{
            "etf_code": "...",
            "etf_name": "...",
            "allocation": 50,
            "reason": "..."
          }},
          {{
            "etf_code": "...",
            "etf_name": "...",
            "allocation": 50,
            "reason": "..."
          }}
        ]
      }}
    }}
    """

    # 初始化 LLM 和 Prompt
    llm = ChatOpenAI(model_name="gpt-4o", temperature=0, api_key=api_key)
    prompt = PromptTemplate(template=prompt_template, input_variables=["themes", "context"])
    chain = LLMChain(llm=llm, prompt=prompt)

    # 執行 Chain
    response = chain.invoke({
        "themes": '、'.join(selected_themes),
        "context": context
    })
    
    llm_output = response['text']
    print(" -> LLM 已生成回應。")

    # 步驟 4: 解析 LLM 回應並回傳
    print("步驟 4: 解析 LLM 回應並回傳...")
    try:
        # 移除可能存在於開頭結尾的 markdown 標記
        if llm_output.startswith("```json"):
            llm_output = llm_output[7:]
        if llm_output.endswith("```"):
            llm_output = llm_output[:-3]
        
        report_data = json.loads(llm_output)
        print(" -> JSON 解析成功。")
        return report_data
    except json.JSONDecodeError as e:
        print(f" -> JSON 解析失敗: {e}")
        print(f" -> 原始輸出: {llm_output}")
        return {"error": "Failed to parse LLM output.", "raw_output": llm_output}

# --- 3. 主執行流程 (for testing) ---
if __name__ == '__main__':
    print("測試核心推薦邏輯...")
    
    user_selection = ["高股息", "科技/半導體"]
    
    final_report = generate_recommendation(user_selection)
    
    print("\n--- 測試完成 ---")
    # Pretty print the JSON output
    print(json.dumps(final_report, indent=2, ensure_ascii=False))
