---
title: "架構地圖"
document_type: architecture
version: 1.0
language: zh-TW
modules:
  - name: Flutter 前端
    role: 跨平台 UI，Stepper 精靈 + 結果頁
    dependency_direction: "HTTP → Dart Frog 後端"
  - name: Dart Frog 後端
    role: API 伺服器，RAG 流程 + 防禦性轉換
    dependency_direction: "HTTP → OpenAI API + ChromaDB + etf.xlsx"
  - name: ChromaDB
    role: 向量資料庫，ETF 文件的語意搜尋
    dependency_direction: "被 Dart Frog 查詢"
  - name: Python 腳本
    role: 資料處理，Excel → 向量資料庫的 ETL
    dependency_direction: "讀取 etf.xlsx → 寫入 ChromaDB"
  - name: etf.xlsx
    role: 單一事實來源
    dependency_direction: "被 Python 腳本和 Dart 後端同時讀取"
data_flow: "使用者 DNA → Dart Frog → OpenAI Embedding → ChromaDB 搜尋 → GPT-4o → 防禦性轉換 → Flutter 報告"
entry_points:
  - etf_advisor_frontend/lib/main.dart (前端入口)
  - dart_backend/routes/advanced_recommendation.dart (主要 API)
  - scripts/build_vector_db.py (資料建構)
related_documents:
  - 00_OVERVIEW.md
  - 03_RAG_PIPELINE.md
  - 06_BACKEND.md
tags: [architecture, modules, data-flow, RAG, Flutter, Dart-Frog]
---

# 架構地圖

> 四個服務同時運行：ChromaDB、Dart 後端、Flutter 前端、OpenAI API。使用者偏好穿過這四層，變成一組個人化的 ETF 推薦。

## 全局架構

```
┌───────────────────────────────────────────────────────────────┐
│                     Flutter 前端 (Dart)                        │
│                                                               │
│   main.dart                                                   │
│   ├── ThemeProvider (淺色/深色主題切換)                         │
│   ├── AdvisorHomePage (3 步精靈)                               │
│   │   ├── Step 1: 風險偏好 (保守/穩健/積極)                     │
│   │   ├── Step 2: 主題權重 (4 個滑桿，總和 100%)               │
│   │   └── Step 3: 進階設定 (組合規模 + 量化篩選)                │
│   └── ResultPage (AI 報告頁)                                   │
│       ├── PortfolioPieChart (資產配置圓餅圖)                    │
│       ├── ETF 卡片列表 (code, name, allocation, reason)        │
│       ├── EtfDetailsDialog (ETF 詳細持股與指標)                │
│       └── ExpansionTile (投資組合總覽 - 加權持股)               │
│                                                               │
│   部署: Flutter Web / Windows Desktop                         │
└───────────────┬───────────────────────────────────────────────┘
                │ HTTP POST
                ▼
┌───────────────────────────────────────────────────────────────┐
│               Dart Frog 後端 (Dart)                            │
│                                                               │
│   routes/                                                     │
│   ├── _middleware.dart           ← CORS 中介軟體              │
│   ├── advanced_recommendation.dart ← ★ 主要 API                │
│   │   ├── _buildDynamicPrompt()   ← 動態提示工程               │
│   │   ├── _buildChromaQuery()     ← DNA → 查詢語句             │
│   │   ├── _queryChromaDB()        ← 向量搜尋                   │
│   │   ├── _callOpenAI()           ← GPT-4o 生成報告            │
│   │   └── _transformAiResponse()  ← 防禦性回應轉換             │
│   ├── recommend.dart             ← 簡單推薦 API (v1)          │
│   ├── portfolio_holdings.dart    ← 投資組合加權持股 API         │
│   └── etf_details/[etf_code].dart ← ETF 詳細資訊 API          │
│                                                               │
│   運行: http://localhost:8080                                  │
│   依賴: dart_frog, http, dotenv, excel                        │
└───────┬───────────────┬───────────────┬───────────────────────┘
        │               │               │
        │ HTTP          │ HTTP          │ 讀取 .xlsx
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────────────────┐
│  OpenAI API  │ │  ChromaDB    │ │  etf.xlsx               │
│              │ │              │ │  (單一事實來源)           │
│ Embedding:   │ │ 向量搜尋:    │ │                          │
│ text-embed-  │ │ etf_         │ │ 包含: ETF 代碼、名稱、   │
│ ding-3-small│ │ collection    │ │ 類別、規模、Beta、       │
│              │ │              │ │ 夏普值、殖利率、         │
│ Chat:        │ │ 運行:        │ │ 成分股、持股比例...      │
│ gpt-4o       │ │ localhost:   │ │                          │
│              │ │ 8000         │ │ 被 Python 和 Dart 同時   │
│ 運行: OpenAI │ │              │ │ 讀取                     │
│ 雲端         │ │ Python 建立  │ └──────────────────────────┘
└──────────────┘ │              │
                 ▼              │
          ┌──────────────────┐  │
          │  Python 腳本      │  │
          │                  │  │
          │ build_vector_db │──┘
          │ .py              │
          │                  │
          │ Excel → Pandas → │
          │ LangChain Doc → │
          │ ChromaDB         │
          │                  │
          │ 運行: build_db  │
          │ .bat (一次性)    │
          └──────────────────┘
```

## 目錄結構

```
ETF_AI_Advisor/
├── .env.example                  ← OPENAI_API_KEY 模板
├── requirements.txt              ← Python 依賴 (8 個)
├── build_db.bat                  ← 建構向量資料庫腳本
├── build_and_start.bat           ← 建構並啟動 Dart 後端
├── start_frontend.bat            ← 啟動 Flutter 前端
│
├── dart_backend/                 ← Dart Frog 後端
│   ├── pubspec.yaml              ← Dart 依賴
│   ├── routes/
│   │   ├── _middleware.dart      ← CORS 中介軟體
│   │   ├── index.dart            ← 歡迎頁
│   │   ├── recommend.dart        ← v1 簡單推薦 API
│   │   ├── advanced_recommendation.dart  ← ★ v2 進階推薦 API
│   │   ├── portfolio_holdings.dart      ← 加權持股 API
│   │   └── etf_details/[etf_code].dart  ← ETF 詳細資訊 API
│   └── test/
│
├── etf_advisor_frontend/         ← Flutter 前端
│   ├── pubspec.yaml              ← Flutter 依賴
│   ├── lib/
│   │   ├── main.dart             ← 入口點 + 主題定義
│   │   ├── providers/
│   │   │   └── theme_provider.dart ← 淺色/深色切換
│   │   ├── screens/
│   │   │   ├── home_page.dart    ← 3 步設定器
│   │   │   └── result_page.dart  ← AI 報告頁
│   │   └── widgets/
│   │       ├── portfolio_pie_chart.dart   ← 圓餅圖
│   │       └── etf_details_dialog.dart     ← ETF 詳情對話框
│   ├── web/                      ← Flutter Web 部署
│   ├── windows/                  ← Windows 桌面部署
│   └── linux/, macos/            ← 其他平台部署
│
├── scripts/                      ← Python 資料處理
│   ├── build_vector_db.py        ← ★ 建構向量資料庫
│   ├── test_retriever.py          ← 驗證檢索結果
│   ├── inspect_excel.py          ← 檢查 Excel 欄位
│   ├── create_presentation.py    ← 生成 PPT 簡報
│   ├── debug_env.py               ← 環境除錯
│   └── data/
│       └── etf.xlsx               ← ★ 單一事實來源
│
├── chroma_db/                     ← ChromaDB 資料庫檔案
│   ├── chroma.sqlite3
│   └── <uuid>/                    ← 向量集合
│
├── agents/                        ← AI Agent 治理層
│   ├── user_persona.md            ← 使用者 persona (Alex)
│   ├── project_manager.md         ← 專案經理
│   ├── architect.py               ← 系統架構師
│   ├── dart_backend_engineer.md   ← Dart 後端工程師
│   ├── flutter_ui_ux_engineer.md  ← Flutter 前端工程師
│   ├── financial_advisor.md       ← 金融顧問
│   ├── python_programmer.py       ← Python 程式師
│   └── test_engineer.py           ← 測試工程師
│
├── README.md                      ← 專案說明
├── PROJECT_STRUCTURE.md           ← 結構文件
├── project.md                     ← 功能變更日誌
├── task.md                        ← 開發藍圖
├── updatelog.md                   ← 程式碼更新日誌
├── chroma_v2_api.md                ← ChromaDB v2 API 參考
└── ETF-AI.pptx                    ← 專案簡報
```

## 四個服務

同時運行四個服務才能讓應用程式完整運作：

| 服務 | 技術 | 啟動方式 | 埠 |
|------|------|---------|-----|
| ChromaDB 伺服器 | Python | `chroma run --path chroma_db` | 8000 |
| Dart 後端 | Dart Frog | `build_and_start.bat` | 8080 |
| Flutter 前端 | Flutter | `start_frontend.bat` | 預設 |
| OpenAI API | 外部服務 | API Key | — |

## 依賴方向

```
Flutter 前端
  └──→ Dart Frog 後端 (HTTP API)
        ├──→ OpenAI API (Embedding + Chat)
        ├──→ ChromaDB (向量搜尋)
        └──→ etf.xlsx (直接讀取)

Python 腳本 (離線)
  └──→ etf.xlsx → ChromaDB (一次性建構)
```

關鍵觀察：**etf.xlsx 被兩個地方讀取**：
1. `build_vector_db.py`：Python 腳本讀取 Excel，轉為向量，存入 ChromaDB
2. `portfolio_holdings.dart` 和 `etf_details/[etf_code].dart`：Dart 後端直接讀取 Excel，用於 ETF 詳情和加權持股計算

這是單一事實來源的體現——所有數據都來自同一個檔案，只是使用方式不同。

## 資料流全景

```
1. 離線建構（一次性）
   etf.xlsx → Pandas → LangChain Documents → OpenAI Embedding → ChromaDB

2. 使用者請求（每次分析）
   使用者投資組合 DNA
     → POST /advanced_recommendation
     → _buildDynamicPrompt(DNA)         ← 動態提示工程
     → _buildChromaQuery(DNA)           ← DNA → 查詢語句
     → OpenAI text-embedding-3-small    ← 查詢向量化
     → ChromaDB 相似度搜尋              ← 檢索相關 ETF 文件
     → GPT-4o (prompt + RAG context)    ← 生成投資組合報告
     → _transformAiResponse()           ← 防禦性回應轉換
     → JSON 回傳給前端

3. 詳情請求（按需）
   使用者點擊 ETF 卡片
     → GET /etf_details/<code>
     → 讀取 etf.xlsx
     → 回傳 ETF 完整資訊

4. 持股請求（按需）
   使用者展開投資組合總覽
     → POST /portfolio_holdings
     → 讀取 etf.xlsx
     → 計算加權持股
     → 回傳合併持股分佈
```

## 無資料庫架構

這個專案沒有傳統的關聯式資料庫。所有資料存儲在兩個地方：

1. **ChromaDB**：ETF 的向量表示，用於語意搜尋
2. **etf.xlsx**：ETF 的原始數據，用於詳情和持股計算

沒有 PostgreSQL、MySQL、MongoDB。ChromaDB 不是資料庫，是向量索引。etf.xlsx 不是資料庫，是試算表。

這帶來了簡潔性（不需要管理資料庫伺服器、遷移、備份），也帶來了限制（每次請求都讀取 Excel、沒有快取、沒有使用者資料的持久化）。