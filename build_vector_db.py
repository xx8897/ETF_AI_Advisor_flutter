import os
import pandas as pd
import json
from dotenv import load_dotenv
from langchain_openai import OpenAIEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain.docstore.document import Document

# --- 1. 環境設定 (Environment Setup) ---
def setup_environment():
    """
    載入環境變數，特別是 OpenAI API Key。
    """
    load_dotenv()
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("OpenAI API Key not found. Please check your .env file.")
    print("環境設定完成，API Key 已載入。")
    return api_key

# --- 2. 資料載入 (Data Loading) ---
def load_data():
    """
    從 CSV 和 JSON 檔案中載入 ETF 資料。
    """
    static_df = None
    dynamic_data = None

    try:
        static_df = pd.read_csv('etf_static_data.csv')
        print("靜態資料 etf_static_data.csv 載入成功。")
    except FileNotFoundError:
        print(f"錯誤：找不到靜態資料檔案 etf_static_data.csv。")
        return None, None
    except Exception as e:
        print(f"讀取 etf_static_data.csv 時發生錯誤: {e}")
        return None, None

    try:
        with open('etf_dynamic_data.json', 'r', encoding='utf-8') as f:
            dynamic_data = json.load(f)
        print("動態資料 etf_dynamic_data.json 載入成功。")
    except FileNotFoundError:
        print(f"錯誤：找不到動態資料檔案 etf_dynamic_data.json。")
        return None, None
    except json.JSONDecodeError as e:
        print(f"解析 etf_dynamic_data.json 時發生錯誤: {e}")
        return None, None
    except Exception as e:
        print(f"讀取 etf_dynamic_data.json 時發生錯誤: {e}")
        return None, None

    print("靜態與動態資料載入成功。")
    return static_df, dynamic_data

# --- 3. 資料整合與轉換 (Data Consolidation & Transformation) ---
def create_documents(static_df, dynamic_data):
    """
    將靜態和動態資料整合成 LangChain 的 Document 物件。
    每個 Document 代表一檔 ETF 的完整資訊。
    """
    all_documents = []
    for index, row in static_df.iterrows():
        etf_code = row['etf_code']
        # 確保 ETF 代號是字串且格式正確 (例如 0050)
        etf_code_str = f"{etf_code:04}" if isinstance(etf_code, int) else str(etf_code)

        dynamic_info = dynamic_data.get(etf_code_str, {})
        
        # 組合文字內容，使其豐富且易於搜尋
        content = f"""
        ETF 代號: {etf_code_str}
        ETF 名稱: {row['etf_name']}
        投資主題: {row['investment_theme']}
        追蹤指數: {row['tracking_index']}
        經理費: {row['management_fee']}% 
        保管費: {row['custody_fee']}% 
        目前淨值: {dynamic_info.get('net_asset_value', 'N/A')}
        最新年化配息率: {dynamic_info.get('annualized_dividend_yield', 'N/A')}% 
        近期績效: 一個月 {dynamic_info.get('performance', {}).get('1m', 'N/A')}%, 三個月 {dynamic_info.get('performance', {}).get('3m', 'N/A')}%, 一年 {dynamic_info.get('performance', {}).get('1y', 'N/A')}% 
        前十大成分股: {", ".join([f'{h["name"]} ({h["weight"]})' for h in dynamic_info.get('top_10_holdings', [])])}
        """
        
        # 建立 Document 物件
        doc = Document(
            page_content=content.strip(),
            metadata={
                'etf_code': etf_code_str,
                'etf_name': row['etf_name'],
                'theme': row['investment_theme']
            }
        )
        all_documents.append(doc)
    
    print(f"成功為 {len(all_documents)} 檔 ETF 建立 Document 物件。")
    return all_documents

# --- 4. 向量化與儲存 (Vectorization & Storage) ---
def build_and_store_vectors(documents, api_key):
    """
    將 Documents 進行向量化並存入 ChromaDB。
    """
    if not documents:
        print("沒有可處理的 Documents，程序中止。")
        return

    # 初始化 Embedding 模型
    embeddings = OpenAIEmbeddings(api_key=api_key, model="text-embedding-3-small")
    
    # 定義向量資料庫的路徑
    persist_directory = 'chroma_db'
    
    # 建立 ChromaDB 並存入向量
    # from_documents 會自動處理 chunking 和 embedding
    print("開始建立向量資料庫，可能需要一些時間...")
    vectordb = Chroma.from_documents(
        documents=documents,
        embedding=embeddings,
        persist_directory=persist_directory
    )
    
    # 持久化資料庫
    vectordb.persist()
    print(f"向量資料庫建立完成並已存放在 '{persist_directory}' 資料夾。")

# --- 主執行流程 ---
if __name__ == "__main__":
    print("開始執行 RAG 核心引擎開發 - 步驟 1: 建立向量資料庫")
    
    api_key = setup_environment()
    
    if api_key:
        static_df, dynamic_data = load_data()
        if static_df is not None and dynamic_data is not None:
            documents = create_documents(static_df, dynamic_data)
            build_and_store_vectors(documents, api_key)
            
    print("任務完成！")