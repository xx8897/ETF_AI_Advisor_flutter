import os
from dotenv import load_dotenv
import chromadb
from chromadb.utils import embedding_functions
from langchain_openai import OpenAIEmbeddings

def run_retrieval_test():
    """
    Connects to a running ChromaDB server and performs an advanced retrieval test
    to validate the factor-augmented data in the vector database.
    """
    try:
        # --- 1. Setup Environment ---
        print("--- [Step 1/3] Setting up environment ---")
        dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
        load_dotenv(dotenv_path=dotenv_path)
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OpenAI API Key not found in the root .env file.")
        print("SUCCESS: Environment setup complete.")

        # --- 2. Connect to ChromaDB Server ---
        print("\n--- [Step 2/3] Connecting to ChromaDB server ---")
        client = chromadb.HttpClient(host='localhost', port=8000)
        # Get the collection and explicitly tell it which embedding function to use for queries
        collection_name = "etf_collection"
        openai_ef = embedding_functions.OpenAIEmbeddingFunction(
            api_key=api_key,
            model_name="text-embedding-3-small"
        )
        print(f"SUCCESS: Connected to ChromaDB. Attempting to get collection: '{collection_name}'")
        collection = client.get_collection(name=collection_name, embedding_function=openai_ef)
        
        # --- 3. Perform a Similarity Search based on New Data ---
        print(f"\n--- [Step 3/3] Performing similarity search ---")
        # This query is designed to test the new industry sector data
        query = "尋找在半導體和金融行業都有佈局，且科技股佔比(Tech_Exposure)高的ETF"
        print(f"Query: '{query}'")
        
        results = collection.query(
            query_texts=[query],
            n_results=3 # Get top 3 results
        )
        
        # --- Print Results ---
        print("\n--- [Retrieval Results] ---")
        if not results or not results.get('documents'):
            print("No relevant ETFs found.")
        else:
            docs = results['documents'][0]
            metadatas = results['metadatas'][0]
            distances = results['distances'][0]

            for i, (doc, meta, dist) in enumerate(zip(docs, metadatas, distances)):
                print(f"\n--- Result {i+1} (Distance: {dist:.4f}) ---")
                print(f"  ETF Code: {meta.get('etf_code', 'N/A')}")
                print(f"  ETF Name: {meta.get('etf_name', 'N/A')}")
                print(f"  Theme:    {meta.get('theme', 'N/A')}")
                
                # Print the full content to verify all data is present
                print(f"  Full Content:\n{doc}")

    except Exception as e:
        print(f"\nERROR: An error occurred during the retrieval test: {e}")
        print("Please ensure the ChromaDB server is running. You can start it with:")
        print("chroma run --path chroma_db")


if __name__ == "__main__":
    run_retrieval_test()