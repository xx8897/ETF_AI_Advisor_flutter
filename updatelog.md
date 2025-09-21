# 程式碼更新日誌

本文件旨在追蹤專案原始碼的重大變更、功能新增以及錯誤修復。

---

### **更新日期: 2025-09-20**
**作者**: Python 工程師
**變更檔案**: `app.py`

**說明**:
-   **功能**: 為分析報告實作了一項重大功能增強。
-   **UI/UX**: 重構了 Streamlit 的使用者介面，使其版面更為簡潔。

---

### **更新日期: 2025-09-20**
**作者**: 測試工程師, Python 工程師
**變更檔案**: `app.py`

**說明**:
-   **錯誤修復**: 修正了一個關鍵的 `SyntaxError` (語法錯誤)。

---

### **更新日期: 2025-09-20**
**作者**: Dart 後端工程師, 系統架構師
**建立/變更檔案**: `dart_backend/pubspec.yaml`, `dart_backend/routes/recommend.dart`, `run_dev_server.bat`

**說明**:
-   **架構遷移**: 啟動第二階段，使用 Dart 重建後端。
-   **環境設定**: 解決了 Android 工具鏈和 Dart CLI 的路徑問題。
-   **後端實作**: 在 Dart 中重新實現了 RAG 核心邏輯。

---

### **更新日期: 2025-09-20**
**作者**: 專案經理, 系統架構師
**建立/變更/刪除檔案**: `agents/project_manager.md`, `project.md` (建立), `project_log.md` (刪除), `project_summary.md` (刪除), `README.md`, `PROJECT_STRUCTURE.md`, `run_dev_server.bat` (刪除), `build_and_start.bat`

**說明**:
-   **文件重構**: 將專案文件精簡為五個核心檔案。
-   **架構釐清**: 正式將雙伺服器運行架構寫入文件。
-   **工具與清理**: 完成了 `build_and_start.bat` 腳本的最終版本。

---

### **更新日期: 2025-09-21**
**作者**: 全體 Agent 團隊
**建立/變更檔案**: `chroma_v2_api.md` (建立), `dart_backend/routes/recommend.dart`

**說明**:
-   **根本原因分析**: 發現了一個根本性的 API 版本不匹配問題 (`/api/v1` vs `/api/v2`)。
-   **API 探索與文件化**: 發現並記錄了正確的 `/api/v2` URL 結構。
-   **確定性程式碼修復**: 使用正確的 v2 API URL 更新了 `recommend.dart`。

---

### **更新日期: 2025-09-21 (深夜)**
**作者**: 全體 Agent 團隊
**變更檔案**: `dart_backend/routes/recommend.dart`, `test_retriever.py`

**說明**:
-   **深度除錯與迭代優化**: 進行了一次深度除錯會議，以解決一系列後續的 v2 API 錯誤。
-   **關鍵發現與修復**: 識別並修正了與 UUID、集合名稱和 JSON 主體結構相關的問題。

---

### **更新日期: 2025-09-21 (停滯)**
**作者**: 專案經理, 全體 Agent 團隊
**變更檔案**: 無

**說明**:
-   **關鍵問題**: 由於持續出現 `Collection [langchain] does not exist` (集合 [langchain] 不存在) 的錯誤，專案陷入停滯。
-   **問題陳述**: 反覆出現的錯誤表明，團隊對於資料持久化機制和伺服器資料載入過程之間的互動存在根本性的誤解。

---

### **更新日期: 2025-09-21 (突破)**
**作者**: 系統架構師, 專案經理, 使用者
**變更檔案**: `build_vector_db.py`, `README.md`, `agents/architect.py`, `agents/project_manager.py`

**說明**:
-   **確定根本原因**: 使用者正確地指出了所有 `Collection not found` (集合未找到) 錯誤的絕對根本原因：`chroma run` 命令在錯誤的目錄下執行。
-   **流程修正**: 團隊建立了最終的、正確的資料庫建立與伺服器啟動工作流程。
-   **程式碼與文件強化**:
    -   強化了 `build_vector_db.py` 腳本，使其使用客戶端-伺服器模型 (`HttpClient`)。
    -   使用最終正確的、逐步的指令更新了 `README.md`。
    -   更新了 Agent 的職責，以強制更嚴格地遵守已建立的程序。

---

### **更新日期: 2025-09-21 (仲裁測試與最終結論)**
**作者**: 全體 Agent 團隊
**變更檔案**: `dart_backend/pubspec.yaml`, `dart_backend/routes/recommend.dart`, `agents/dart_backend_engineer.md`, `agents/project_manager.md`

**說明**:
-   **仲裁測試**: 在使用者的指導下，團隊進行了最後一次決定性的測試，以裁定 `package:chromadb` Dart 客戶端的 可行性。
-   **最終結論**: 測試最終證明 `package:chromadb` 與最新版本的 ChromaDB 伺服器存在根本性的不相容。
-   **戰略決策**: 基於此結論，團隊做出最終且永久性的決定：放棄使用 `package:chromadb` 客戶端。
-   **未來方向**: 專案現在將完全採用手動的 `http` 客戶端實現。

---

### **更新日期: 2025-09-21 (最終實作)**
**作者**: 專案經理, Dart 後端工程師
**變更檔案**: `dart_backend/pubspec.yaml`, `dart_backend/routes/recommend.dart`

**說明**:
-   **程式碼定案**: 根據仲裁測試的結論，`recommend.dart` 檔案和 `pubspec.yaml` 已被永久設定為使用手動 `http` 客戶端的實現。

---

### **更新日期: 2025-09-21 (前端整合與 CORS)**
**作者**: Flutter UI/UX 工程師, Dart 後端工程師, 專案經理
**建立/變更檔案**: `etf_advisor_frontend/lib/main.dart`, `etf_advisor_frontend/pubspec.yaml`, `dart_backend/routes/_middleware.dart`

**說明**:
-   **第三階段啟動**: 正式開始 Flutter 前端開發階段。
-   **UI 實作**: 在 Flutter 中建立了初始的使用者介面。
-   **前後端整合**: 實現了從 Flutter 應用到 Dart 後端的 `http` 呼叫。
-   **CORS 問題解決**: 成功診斷並解決了一個關鍵的 CORS 預檢請求問題。
-   **成功**: 實現了從 Flutter 前端到 Dart 後端的完整端對端連接。

---

### **更新日期: 2025-09-21 (UI/UX 優化與主題化)**
**作者**: Flutter UI/UX 工程師
**變更檔案**: `etf_advisor_frontend/lib/main.dart`, `etf_advisor_frontend/pubspec.yaml`

**說明**:
-   **狀態管理**: 整合了 `provider` 套件。
-   **主題引擎**: 實現了一個強大的淺色/深色模式切換功能，以及一個客製化的、受 VS Code 啟發的深色主題。
-   **UI 優化**: 使用 Card 和 Floating Action Button 優化了版面配置。
-   **錯誤修復**: 修正了 `CardTheme` 與 `CardThemeData` 的類型不匹配錯誤。

---

### **更新日期: 2025-09-21 (功能增強與重構)**
**作者**: Flutter UI/UX 工程師, 系統架構師, Dart 後端工程師
**建立/變更檔案**: `etf_advisor_frontend/lib/**`, `dart_backend/routes/etf_details/[etf_code].dart`

**說明**:
-   **功能：圓餅圖視覺化**:
    -   將 `fl_chart` 套件整合到 Flutter 前端。
    -   成功實現了 `PortfolioPieChart` 小工具。
-   **功能：ETF 詳細視圖 (後端)**:
    -   在 Dart 後端建立了一個新的動態 API 端點 (`/etf_details/{etf_code}`)。
-   **架構重構 (前端)**:
    -   為了更好的組織和可維護性，對 Flutter 前端程式碼庫進行了重大重構，建立了清晰的目錄結構 (`providers`, `screens`, `widgets`)。
-   **錯誤修復**:
    -   修正了圓餅圖標題中的一個多行字串語法錯誤。
-   **最終狀態**: Flutter 應用程式現在功能更豐富，並擁有更穩健和可擴展的架構。
---

### **更新日期: 2025-09-21 (戰略定義)**
**作者**: 專案經理 & 系統架構師
**變更檔案**: `project.md`, `README.md`, `task.md`, `updatelog.md`

**說明**:
-   **戰略決策**: 正式定義並記錄了將 FinMind API 與核心 RAG 架構整合的策略。
-   **說明**: 已明確記錄 FinMind API 將作為主要資料來源，以豐富 ChromaDB 向量資料庫。此方法透過提供更高品質的即時數據，增強了 RAG 流程中的「檢索」環節，從而產生更準確的 AI 建議。此決策鞏固了即將到來的 v2.0 功能的資料流程。
---

### **更新日期: 2025-09-21 (資料策略轉向)**
**作者**: 全體 Agent 團隊
**變更檔案**: `project.md`, `task.md`, `updatelog.md`, `TWSE_API_Reference.md` (建立)

**說明**:
-   **技術探勘結論**: 針對 FinMind API v4 的技術探勘完成。結論是，該 API 無法提供專案所需的核心資料，特別是「ETF 完整列表」、「ETF 成分股」與「相關費用」。
-   **戰略轉向**: 基於上述結論，團隊決定轉向一個更穩健的**混合資料策略**。
-   **新策略**:
    -   **主要來源**: **台灣證券交易所 (TWSE) OpenAPI** 將作為獲取核心靜態資料 (ETF列表、成分股、費用) 的主要來源。
    -   **次要來源**: **FinMind API v4** 將繼續用於獲取其已驗證可行的動態資料 (每日股價、歷史配息)。
-   **文件化**: 建立了 `TWSE_API_Reference.md` 來記錄證交所的 API 端點，並更新了所有相關文件以反映此策略轉向。
---

### **更新日期: 2025-09-22 (ETF 詳細視圖最終實作)**
**作者**: Flutter UI/UX 工程師, 金融顧問
**變更檔案**: `etf_advisor_frontend/lib/widgets/etf_details_dialog.dart`, `task.md`

**說明**:
-   **功能完成**: 成功實作了「ETF 詳細資訊」視圖的最終版本。
-   **迭代優化**: 根據使用者的回饋，進行了多輪的 UI/UX 精細化調整，包含：
    -   實作了一個互動式的**持股/持債圓餅圖**，可響應滑鼠懸停，並能正確處理股票與債券型 ETF 的不同數據格式。
    -   為確保圖表能準確反映整體分佈，加入了「**其他**」類別的計算邏輯。
    -   與金融顧問合作，定義了一份**關鍵指標白名單**，並使用 `Wrap` 佈局，將其以美觀的兩列式卡片呈現。
-   **範圍變更**: 根據使用者的最終決策，移除了原計畫中的「行業類別圓餅圖」，以保持介面的簡潔與專注。
-   **最終狀態**: 此功能已達到使用者滿意的、可交付的狀態。
---

### **更新日期: 2025-09-22 (投資組合總覽功能)**
**作者**: Dart 後端工程師, Flutter UI/UX 工程師
**變更檔案**: `dart_backend/routes/portfolio_holdings.dart`, `etf_advisor_frontend/lib/screens/home_page.dart`

**說明**:
-   **功能：合併持股分析 (後端)**: 成功在 Dart 後端建立了全新的 `/portfolio_holdings` API 端點。此 API 能接收前端傳來的投資組合（ETF 代碼與配置比例），並即時、準確地計算出加權後的合併持股總覽。
-   **功能：合併持股呈現 (前端)**: Flutter 前端已完成對接。在 AI 報告生成後，會自動呼叫新的 API，並在報告下方以一個可展開的 `ExpansionTile` 視圖，向使用者清晰地展示其投資組合在底層持股的最終分佈情況。
-   **整合**: 此功能的完成，實現了一個完整的端對端（Backend + Frontend）的投資組合分析流程。
---