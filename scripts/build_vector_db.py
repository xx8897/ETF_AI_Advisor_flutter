import os
import pandas as pd
from dotenv import load_dotenv
from langchain_openai import OpenAIEmbeddings
from langchain.docstore.document import Document
import chromadb
from chromadb.utils import embedding_functions
import warnings

# Suppress openpyxl warnings
warnings.filterwarnings('ignore', category=UserWarning, module='openpyxl')

# --- 1. 環境設定 (Environment Setup) ---
def setup_environment():
    dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
    load_dotenv(dotenv_path=dotenv_path)
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("OpenAI API Key not found in the root .env file.")
    print("環境設定完成，API Key 已載入。")
    return api_key

# --- 2. 資料載入 (Data Loading) ---
def load_data_from_excel():
    """
    從最終的 etf.xlsx 檔案中載入所有 ETF 資料。
    """
    data_path = os.path.join(os.path.dirname(__file__), 'data', 'etf.xlsx')
    df = pd.read_excel(data_path, sheet_name='etf')
    print("ETF 精華資料從 Excel 載入成功。")
    return df

# --- 3. 資料整合與轉換 (Data Consolidation & Transformation) ---
def create_documents(df):
    """
    將 DataFrame 中的每一行轉換為一個 LangChain Document 物件。
    """
    print("\n--- [Debug] First 5 rows of the loaded DataFrame ---")
    print(df.head())
    print("----------------------------------------------------\n")

    all_documents = []
    # Iterate directly over each row, as each row is a unique ETF
    for index, row in df.iterrows():
        try:
            # 將所有欄位轉換為一個詳細的文字描述
            content_parts = []
            for col in df.columns:
                # Ensure all data is treated as string to avoid errors
                content_parts.append(f"{col}: {str(row[col])}")
            
            content = "\n".join(content_parts)
            
            etf_code = str(row['ETF代號'])
            etf_name = str(row['ETF名稱'])
            theme = str(row['類別'])

            doc = Document(
                page_content=content.strip(),
                metadata={
                    'etf_code': etf_code,
                    'etf_name': etf_name,
                    'theme': theme
                }
            )
            all_documents.append(doc)
        except Exception as e:
            print(f"Skipping row {index} due to error: {e}")
            
    print(f"成功為 {len(all_documents)} 檔 ETF 建立 Document 物件。")
    return all_documents

# --- 4. 向量化與儲存 (Vectorization & Storage) ---
def build_and_store_vectors(documents, api_key):
    if not documents:
        print("沒有可處理的 Documents，程序中止。")
        return

    print("正在連接到 ChromaDB 伺服器 (http://localhost:8000)...")
    client = chromadb.HttpClient(host='localhost', port=8000)
    collection_name = "etf_collection"

    try:
        client.delete_collection(name=collection_name)
        print(f"舊的 Collection '{collection_name}' 已成功刪除。")
    except Exception:
        print(f"舊的 Collection '{collection_name}' 不存在，將直接建立新的。")

    openai_ef = embedding_functions.OpenAIEmbeddingFunction(
        api_key=api_key,
        model_name="text-embedding-3-small"
    )

    collection = client.create_collection(
        name=collection_name,
        embedding_function=openai_ef
    )

    print(f"正在將 {len(documents)} 份文件加入 Collection...")
    ids = [doc.metadata['etf_code'] for doc in documents]
    collection.add(
        ids=ids,
        documents=[doc.page_content for doc in documents],
        metadatas=[doc.metadata for doc in documents]
    )
    
    print(f"向量資料庫建立完成。所有資料已成功寫入 '{collection_name}'。")

# --- 主執行流程 ---
if __name__ == "__main__":
    print("開始執行向量資料庫建立腳本...")
    try:
        api_key = setup_environment()
        df = load_data_from_excel()
        documents = create_documents(df)
        build_and_store_vectors(documents, api_key)
        print("任務完成！")
    except Exception as e:
        print(f"執行過程中發生錯誤: {e}")