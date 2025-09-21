# 專案開發藍圖：ETF 智能理財顧問 (Flutter 全面改造版)

**專案目標**：打造一個基於 Google 技術棧 (Dart + Flutter) 的、擁有原生級體驗的跨平台 ETF 智能理財應用。

---
## 專案設定 (Project Settings)

*   **GitHub Repo**: `https://github.com/xx8897/ETF_AI_Advisor_flutter.git`

---
### **第一階段：地基與資料準備 (Phase 1: Foundation & Data)**

*   **狀態**: ✅ **已完成**
*   **任務**:
    *   定義核心 ETF 池 (`etf_list.csv`)。
    *   建立靜態資料庫 (`etf_static_data.csv`)。
    *   建立動態資料來源 (`etf_dynamic_data.json`)。
    *   使用 Python (`build_vector_db.py`) 完成資料向量化，並已成功建立 `chroma_db` 向量資料庫。

---
### **第二階段：架構轉型與後端重建 (Phase 2: Architecture Migration & Backend Reconstruction)**

*   **狀態**: ✅ **已完成**
*   **目標**: 將原有的 Python 核心邏輯，用 Dart 重建成一個獨立、高效的後端 API 伺服器。
*   **任務**:
    *   **環境設定**: 已成功修復 Flutter/Dart 開發環境，`flutter doctor` 顯示一切正常。
    *   **建立 Dart 後端專案**: 已成功在 `dart_backend` 目錄中，建立了一個功能完整的 Dart Frog 專案。
    *   **用 Dart 重寫核心 AI 邏輯**: 已成功地、手動使用 `http` 客戶端，重新實現了與 ChromaDB v2 API 和 OpenAI API 互動的完整 RAG 流程。

---
### **第三階段：Flutter 前端開發 (Phase 3: Flutter Frontend Development)**

*   **狀態**: ✅ **已完成 (v1.0)**
*   **目標**: 打造一個美觀、流暢且使用者體驗絕佳的 Flutter 前端應用。
*   **任務**:
    *   **建立 Flutter 專案**: 已成功在 `etf_advisor_frontend` 目錄中，初始化了一個新的 Flutter 專案。
    *   **UI/UX 設計與實作**: 已根據使用者回饋，完成了一個具備專業質感、支援淺色/深色模式切換、且佈局清晰的 UI 原型。
    *   **API 整合**: 已成功將 Flutter 前端與 Dart 後端 API 進行端對端連接，應用程式功能完整。

---
### **第四階段：功能增強 (Phase 4: Feature Enhancement)**

*   **狀態**: ⏳ **待開始**
*   **目標**: 將 Python 版本中所有强大的资料分析功能，都移植到 Flutter 前端，提供更丰富、更深入的投资洞察。
*   **任务**:
    1.  **图表视觉化**:
        *   **未来任务**: 在分析报告中，新增一个圆饼图 (Pie Chart)，用来视觉化地展示推荐投资组合的资产配置比例。
    2.  **详细持股清单**:
        *   **未来任务**: 为每一档被推荐的 ETF，新增一个可展开的详细视图，显示其前 20 大成分股及其权重。
    3.  **投资组合整体持股分析**:
        *   **未来任务**: 新增一个「投资组合总览」功能，计算并显示所有被推荐的 ETF 合并后的、加权的整体成分股列表。

---
### **第五階段：打包與交付 (Phase 5: Packaging & Delivery)**

*   **狀態**: ⏳ **待開始**
*   **目標**: 将应用程式打包成易于分发和部署的格式。
*   **任务**:
    *   **未来任务**: 将 Flutter 应用打包成独立的 Windows `.exe` 桌面应用程式。
    *   **未来任务**: 将 Flutter 应用打包成可以被部署到网页伺服器的 Web 版本。
    *   **未来任务**: (可选) 将 Dart 后端和 ChromaDB 伺服器，容器化 (Dockerize) 并部署到云端平台。
