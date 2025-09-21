import os
from dotenv import load_dotenv
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma

def main():
    """
    主函式，用於載入向量資料庫並執行檢索測試。
    """
    try:
        # 1. 載入環境變數
        load_dotenv()
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OpenAI API Key not found. Please check your .env file.")
        print("1. 環境變數載入成功。")

        # 2. 初始化 Embedding 模型
        embeddings = OpenAIEmbeddings(api_key=api_key, model="text-embedding-3-small")
        print("2. Embedding 模型初始化成功。")

        # 3. 載入已存在的向量資料庫
        persist_directory = 'chroma_db'
        if not os.path.exists(persist_directory):
            raise FileNotFoundError(f"向量資料庫 '{persist_directory}' 不存在。請先執行 build_vector_db.py。")
        
        vectordb = Chroma(persist_directory=persist_directory, embedding_function=embeddings)
        print(f"3. 從 '{persist_directory}' 載入向量資料庫成功。")

        # 4. 定義查詢並生成 Embedding
        query = "我想找跟AI或半導體相關的ETF"
        print(f"\n4. 執行查詢: '{query}'")
        
        # 手動生成 Embedding 並印出
        embedding_vector = embeddings.embed_query(query)
        print("\n--- LangChain 生成的 Embedding Vector (前10個維度預覽) ---")
        print(embedding_vector[:10])
        print(f"總維度: {len(embedding_vector)}")
        print("-" * 20)

        # 使用向量進行相似度搜尋
        similar_docs = vectordb.similarity_search_by_vector(embedding_vector, k=5)
        
        # 5. 打印結果
        print("\n5. 檢索結果：")
        if not similar_docs:
            print("找不到相關的 ETF。")
        else:
            for i, doc in enumerate(similar_docs):
                print(f"--- 結果 {i+1} ---")
                print(f"ETF 代號: {doc.metadata.get('etf_code', 'N/A')}")
                print(f"ETF 名稱: {doc.metadata.get('etf_name', 'N/A')}")
                # 移除換行符號，讓輸出更簡潔
                content_preview = ' '.join(doc.page_content.splitlines())
                print(f"相關性內容片段: {content_preview[:250]}...")
                print("-" * 20)

    except Exception as e:
        print(f"執行過程中發生錯誤: {e}")


if __name__ == "__main__":
    main()
