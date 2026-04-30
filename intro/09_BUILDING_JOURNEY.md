---
title: "建構旅程"
document_type: narrative
version: 1.0
language: zh-TW
phases:
  - phase: "v0.1 Python 原型"
    scope: "Streamlit + Python + ChromaDB，驗證 RAG 可行性"
    key_insight: "RAG 流程可行，但 Streamlit 是原型工具不是產品"
  - phase: "v1.0 Flutter 重寫"
    scope: "Dart Frog 後端 + Flutter 前端，從原型到產品"
    key_insight: "跨平台 UI 是目標，同語言前後端是策略"
  - phase: "v2.0 資料來源探索"
    scope: "FinMind → TWSE → 爬蟲 → yfinance → Excel，四條路都走過"
    key_insight: "外部數據不可靠，回歸單一事實來源"
  - phase: "v2.1 投資組合 DNA"
    scope: "多維度偏好設定、動態提示工程、防禦性回應轉換"
    key_insight: "使用者偏好是多維的，AI 輸出是不可預測的"
pivotal_moments:
  - moment: "ChromaDB v1→v2 API 的痛苦除錯"
    impact: "發現 v1 API 已被棄用，必須使用 v2 的 tenant/database/UUID 路徑"
  - moment: "package:chromadb 的不相容"
    impact: "放棄 Dart 客戶端，改用原始 HTTP 呼叫"
  - moment: "四種外部資料來源全部失敗"
    impact: "回歸單一 Excel 檔案，確定了架構的簡潔性"
  - moment: "chroma run 路徑錯誤"
    impact: "使用者指出了根本原因，建立了正確的資料庫建構流程"
  - moment: "CORS 問題的解決"
    impact: "前端和後端可以在不同埠正常通訊"
  - moment: "投資組合 DNA 的引入"
    impact: "從簡單主題推薦進化為多維度個人化分析"
related_documents:
  - 01_PHILOSOPHY.md
  - 04_DATA_SOURCE_JOURNEY.md
  - 07_AGENT_GOVERNANCE.md
tags: [journey, phases, pivotal-moments, evolution, RAG]
---

# 建構旅程

> 從 Streamlit 原型到 Flutter 產品，從 FinMind API 到 Excel 檔案，從單一主題到投資組合 DNA。每一步都是在前一步的教訓上做出選擇。

## v0.1 — Python 原型（2025-09 初）

### 做了什麼

用 Python + Streamlit 快速搭建了一個可運作的概念驗證：

- **前端**：Streamlit 網頁介面
- **後端**：`app.py` — 所有邏輯在一個文件
- **RAG**：`core_logic.py` — 核心檢索增強生成流程
- **資料庫**：ChromaDB 作為向量儲存

### 思考

原型的目標是驗證一個假設：**用 RAG 讓 AI 推薦台股 ETF 是否可行？**

答案是可行的。Streamlit 讓原型在幾天內就可以運作，使用者選一個主題，AI 從 ChromaDB 檢索相關 ETF，GPT-4o 生成報告。核心流程跑通了。

### 留下的問題

Streamlit 是原型工具，不是產品工具：
- UI 自定義能力有限
- 跨平台部署困難
- 效能瓶頸明顯

---

## v1.0 — Flutter 重寫（2025-09-20~21）

### 做了什麼

- 徹底重寫後端：Python → Dart Frog
- 徹底重寫前端：Streamlit → Flutter
- 實作 CORS 中介軟體
- 實作圓餅圖視覺化（`fl_chart`）
- 實作 ETF 詳情對話框
- 實作淺色/深色主題切換

### 思考

**為什麼選 Dart + Flutter**：

1. **同語言前後端**：後端和前端都用 Dart，減少技術棧碎片化
2. **跨平台**：Flutter 可以同時輸出 Web、Windows、macOS、Linux
3. **UI 品質**：Flutter 的 UI 能力遠超 Streamlit

這個選擇的代價是 Dart 生態圈比 Python 小，特別是在資料處理和 AI 領域。但對於一個主要做 HTTP 呼叫和 JSON 處理的後端，Dart 完全夠用。

### 關鍵事件：CORS 問題

Flutter Web 在 `localhost:xxxx`，Dart Frog 在 `localhost:8080`。瀏覽器的同源策略阻止了跨域請求。解決方案是在 `_middleware.dart` 中添加 CORS 標頭。

這是一個典型的「看起來簡單但花了很多時間」的問題——因為 Dart Frog 的中介軟體寫法和一般的 HTTP handler 不同。

---

## v2.0 — 資料來源的艱難探索（2025-09-21）

這是專案最曲折的階段。完整的故事在 `04_DATA_SOURCE_JOURNEY.md` 中，這裡簡述：

### 嘗試順序

1. **FinMind API v4** → 缺少 ETF 成分股和完整列表
2. **TWSE OpenAPI** → 數據不完整，缺成分股
3. **網頁爬蟲**（Goodinfo、MoneyDJ、Wantgoo、MacroMicro）→ 反爬蟲機制
4. **yfinance** → 台灣市場深度不足
5. **使用者提供的 etf.xlsx** → ✅ 單一、完整、權威

### 關鍵決策

**回歸單一事實來源**。這不是妥協，是經過四條路都走不通之後的理性選擇。Excel 的好處是數據品質可控，壞處是需要手動更新。在台灣 ETF 只有 200+ 檔的情況下，手動更新是可接受的。

### 副產品

探索過程中產生了 `TWSE_API_Reference.md`、FinMind 測試腳本、爬蟲原型等文件。這些經驗記錄在 `updatelog.md` 中。

---

## v1.0 → v2.0 之間的除錯插曲

### ChromaDB v1→v2 API 的痛苦

Dart 後端最初使用 `package:chromadb` Dart 客戶端。但最新版的 ChromaDB 伺服器與此客戶端根本不相容：

1. 舊版使用 `/api/v1/...` 端點
2. 新版使用 `/api/v2/tenants/{tenant}/databases/{database}/collections/{uuid}/...` 端點
3. `package:chromadb` 仍在使用 v1 API
4. v1 API 已被完全棄用

除錯過程：
- `Collection [langchain] does not exist` 錯誤（因為集合名稱和 UUID 的混淆）
- `chroma run` 在錯誤目錄下執行（使用者指出了根本原因）
- 仲裁測試證明 `package:chromadb` 不可使用

最終決策：**放棄 Dart 客戶端，改用原始 HTTP 呼叫**。這意味著每個路由都要手動構建 HTTP 請求，但至少是確定性的。

這段經歷產生了 `chroma_v2_api.md`——一份內部參考文件，記錄了正確的 v2 API 端點結構。

---

## v2.1 — 投資組合 DNA（2025-09-22）

### 做了什麼

- 後端：全新的 `/advanced_recommendation` API，動態提示工程
- 前端：Stepper 精靈改造（風險偏好 + 主題權重 + 進階設定）
- 結果頁全面美化
- 防禦性回應轉換

### 思考

v1.0 的推薦是「選一個主題，推薦 2-3 檔 ETF」。v2.1 的推薦是「定義你的投資 DNA，AI 根據你的風險偏好、主題信念、量化指標，推薦個人化投資組合」。

這是從「工具」到「平台」的進化。使用者不再是選一個標籤然後等待結果，而是參與一個引導式的設定流程，表達自己的投資偏好。

### 動態提示工程的影響

之前 AI 收到的 Prompt 是固定的：「你是一個財務顧問，推薦 N 檔 ETF」。

現在 AI 收到的 Prompt 是根據使用者的 DNA 動態生成的，包含了風險偏好的描述、主題權重的分配、量化篩選的條件。這讓 AI 的回應從泛泛而談變為針對個人需求。

但也帶來了新的挑戰：Prompt 越詳細，GPT-4o 的回應格式越難預測。這就是防禦性回應轉換存在的原因。

---

## 版本演化時間線

```
v0.1 (2025-09 初)
  ├─ Streamlit + Python 原型
  ├─ RAG 核心流程驗證
  └─ 單一主題推薦

v1.0 (2025-09-20~21)
  ├─ Dart Frog 後端重寫
  ├─ Flutter 前端重寫
  ├─ CORS 中介軟體
  ├─ 圓餅圖視覺化
  ├─ ETF 詳情對話框
  ├─ 投資組合總覽
  └─ 淺色/深色主題切換

v2.0 (2025-09-21)
  ├─ ★ 回歸單一 Excel 資料來源 ★
  ├─ FinMind API 探勘（失敗）
  ├─ TWSE API 探勘（失敗）
  ├─ 網頁爬蟲探勘（失敗）
  ├─ yfinance 探勘（失敗）
  └─ ChromaDB v1→v2 除錯

v2.1 (2025-09-22)
  ├─ ★ 投資組合 DNA ★
  ├─ /advanced_recommendation API
  ├─ 動態提示工程
  ├─ 防禦性回應轉換
  ├─ Stepper 精靈 UI
  └─ 結果頁全面美化

未來 (v2.2~v3.0)
  ├─ v2.2: WebSocket + 非同步分析（計畫中）
  ├─ v2.3: 對話式微調（計畫中）
  └─ v3.0: Docker + GCP 部署（計畫中）
```

**星號標記的是關鍵轉折點**——回歸單一資料來源和引入投資組合 DNA，這兩個決策定義了專案的最終形態。

## Agent 在開發中的角色

整個開發過程中，8 個 AI Agent 各司其職：

- **PM** 協調任務、記錄更新日誌、在關鍵除錯會議中保持秩序
- **架構師** 定義和維護 `PROJECT_STRUCTURE.md`，在 v2.0 資料來源轉向時提供方向
- **Dart 後端工程師** 實作所有 API 路由，解決 ChromaDB v2 API 和 CORS 問題
- **Flutter 前端工程師** 實作所有 UI 組件和主題系統
- **金融顧問** 定義 ETF 詳情的關鍵指標白名單
- **Python 工程師** 實作 `build_vector_db.py`
- **測試工程師** 定義測試計畫（但完整測試套件尚未實作）
- **使用者 Persona Alex** 引導所有 UI/UX 決策

最有影響力的時刻是 ChromaDB 除錯過程中，**使用者自己指出了根本原因**：`chroma run` 在錯誤目錄下執行。這提醒了團隊，有時候人類的直覺比 AI 的系統性除錯更有效。