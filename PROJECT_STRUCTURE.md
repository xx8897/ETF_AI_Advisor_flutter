# 專案結構

本文件旨在提供「ETF AI 智能顧問」專案的資料夾與檔案結構總覽，由系統架構師負責維護。

## 系統運行架構

本專案採用微服務架構，需要同時運行兩個獨立的伺服器程序，才能使應用程式完整運作：

1.  **ChromaDB 伺服器 (Python)**:
    -   此伺服器作為我們的向量資料庫層。
    -   透過 `chroma run --path chroma_db` 指令啟動。
    -   負責將 `chroma_db/` 目錄中的 ETF 資料，以本地網路 API (通常是 `http://localhost:8000`) 的形式提供服務。

2.  **Dart 後端伺服器 (Dart)**:
    -   此伺服器是我們的核心應用邏輯層，以 Dart Frog 框架建構。
    -   負責處理來自前端的請求、查詢 ChromaDB 伺服器以獲取資料、與 OpenAI API 溝通，並回傳最終的分析結果。

---

## 根目錄

-   `.env`: **(不追蹤)** 包含私密的環境變數，例如 `OPENAI_API_KEY`。
-   `.env.example`: `.env` 檔案的範本。
-   `.gitignore`: 指定 Git 應忽略的檔案與資料夾。
-   `requirements.txt`: 列出資料處理腳本所需的 Python 依賴套件。
-   `build_db.bat`: 用於從來源 Excel 檔案建立向量資料庫的工具腳本。
-   `build_and_start.bat`: 用於建置並啟動 Dart 後端伺服器的工具腳本。
-   `start_frontend.bat`: 用於啟動 Flutter 前端應用的工具腳本。
-   `chroma_db/`: 包含 Chroma 向量資料庫檔案的目錄，是我們 RAG 系統的「知識庫」。

### 核心應用

-   `dart_backend/`: 後端伺服器的根目錄。
-   `etf_advisor_frontend/`: Flutter 前端應用的根目錄。

### Python 腳本與資料

-   `scripts/`: 包含所有 Python 工具腳本。
    -   `build_vector_db.py`: 建立並填充 Chroma 向量資料庫。
    -   `test_retriever.py`: 用於測試從 ChromaDB 檢索資料的工具。
    -   `debug_env.py`: 用於除錯 Python 環境。
    -   `data/`: 包含來源資料檔案。
        -   `etf.xlsx`: **(單一事實來源)** 包含所有 ETF 屬性、因子及持股數據的整合 Excel 檔案。

### 專案管理與文件

-   `README.md`: 專案的主要說明文件。
-   `task.md`: 高階的專案開發藍圖。
-   `updatelog.md`: 重大程式碼變更的日誌。
-   `project.md`: 官方的功能變更日誌。
-   `PROJECT_STRUCTURE.md`: **(本檔案)** 專案的檔案結構總覽。

### Agent Personas

-   `agents/`: 包含各 AI agent 的定義檔案。

---
*本文件由系統架構師積極維護。*
