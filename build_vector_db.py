import os
import pandas as pd
import json
from dotenv import load_dotenv
from langchain_openai import OpenAIEmbeddings
from langchain.docstore.document import Document
import chromadb
from chromadb.utils import embedding_functions

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
    static_df = pd.read_csv('etf_static_data.csv')
    with open('etf_dynamic_data.json', 'r', encoding='utf-8') as f:
        dynamic_data = json.load(f)
    print("靜態與動態資料載入成功。")
    return static_df, dynamic_data

# --- 3. 資料整合與轉換 (Data Consolidation & Transformation) ---
def create_documents(static_df, dynamic_data):
    """
    將靜態和動態資料整合成 LangChain 的 Document 物件。
    """
    all_documents = []
    for index, row in static_df.iterrows():
        # Handle both numeric and alphanumeric ETF codes robustly
        etf_code_str = str(row['etf_code'])
        dynamic_info = dynamic_data.get(etf_code_str, {})
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
    透過 HTTP Client 連接到一個正在運行的 ChromaDB 伺服器，
    並將 Documents 進行向量化並存入。
    """
    if not documents:
        print("沒有可處理的 Documents，程序中止。")
        return

    # 初始化 ChromaDB HttpClient，連接到正在運行的伺服器
    print("正在連接到 ChromaDB 伺服器 (http://localhost:8000)...")
    client = chromadb.HttpClient(host='localhost', port=8000)

    # 檢查 Collection 是否已存在，若存在則刪除，確保每次都是全新建立
    try:
        print("正在刪除舊的 'etf_collection' (如果存在)...")
        client.delete_collection(name="etf_collection")
        print("舊的 Collection 已成功刪除。")
    except Exception as e:
        print(f"刪除舊 Collection 時發生錯誤 (可能是因為它不存在，這很正常): {e}")


    # 建立 OpenAI Embedding Function
    openai_ef = embedding_functions.OpenAIEmbeddingFunction(
        api_key=api_key,
        model_name="text-embedding-3-small"
    )

    # 建立一個新的 Collection
    print("正在建立新的 'etf_collection'...")
    collection = client.create_collection(
        name="etf_collection",
        embedding_function=openai_ef
    )

    # 將所有文件一次性加入 Collection
    print(f"正在將 {len(documents)} 份文件加入 Collection...")
    collection.add(
        ids=[doc.metadata['etf_code'] for doc in documents],
        documents=[doc.page_content for doc in documents],
        metadatas=[doc.metadata for doc in documents]
    )
    
    print(f"向量資料庫建立完成。所有資料已成功寫入 'etf_collection'。")

# --- 主執行流程 ---
if __name__ == "__main__":
    print("開始執行 RAG 核心引擎開發 - 步驟 1: 建立向量資料庫")
    api_key = setup_environment()
    if api_key:
        static_df, dynamic_data = load_data()
        documents = create_documents(static_df, dynamic_data)
        build_and_store_vectors(documents, api_key)
    print("任務完成！")
