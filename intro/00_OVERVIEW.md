---
title: "專案全貌"
subtitle: "ETF AI 智能顧問 — 讓 AI 根據你的投資 DNA 推薦台股 ETF 組合"
document_type: overview
version: 1.0
language: zh-TW
related_concepts:
  - RAG_pipeline
  - portfolio_DNA
  - dynamic_prompt_engineering
  - single_source_of_truth
  - Gemini_agents
related_documents:
  - 01_PHILOSOPHY.md
  - 03_RAG_PIPELINE.md
  - 08_STRENGTHS_AND_GAPS.md
tags: [overview, entry-point, ETF, AI, RAG]
---

# 專案全貌

> 不是選一檔 ETF，是讓 AI 根據你的風險偏好、主題信念、量化指標，推薦一整個投資組合。

## 一句話定位

**ETF AI 智能顧問**是一個基於 RAG（檢索增強生成）的台股 ETF 投資組合推薦工具。使用者設定「投資組合 DNA」，AI 從向量資料庫檢索相關 ETF，結合 GPT-4o 生成個人化的投資組合建議報告。

## 解決什麼問題

台灣散戶投資人面對 200+ 檔 ETF，不知道怎麼選。傳統的做法是：

- **看排行榜** — 但排行榜只看過去績效，不看你的風險偏好
- **聽明牌** — 但明牌不了解你的投資信念
- **自己研究** — 但 ETF 的成分股、Beta 值、夏普值分散在不同網站

ETF AI 智能顧問的回答是：**讓你定義完整的投資偏好，讓 AI 幫你從知識庫中檢索、分析、推薦。**

## 核心價值

| 價值 | 實現方式 |
|------|---------|
| **投資組合 DNA** | 不只選主題，而是一組多維度的偏好：風險承受度、主題權重、量化篩選、組合規模 |
| **RAG 檢索增強** | AI 的建議基於真實 ETF 數據（ChromaDB 向量檢索），不是憑空生成 |
| **動態提示工程** | 每個使用者的偏好組合成獨一無二的 Prompt，GPT-4o 的回應真正客製化 |
| **防禦性回應處理** | 後端驗證和轉換 AI 的 JSON 回應，確保前端永遠收到穩定格式 |
| **互動式報告** | 圓餅圖視覺化資產配置、ETF 詳細持股、投資組合總覽 |

## 使用者故事

> **身為一位** 剛接觸投資的小資族（Alex），
> **我希望** 能在一個引導式的介面中，表達我「希望穩健、但又不想錯過科技股趨勢」的模糊想法，
> **以便於** 得到一份我能看得懂的、包含 3-4 檔 ETF 的具體投資組合建議，讓我能更有信心地踏出第一步。

## 技術棧

| 層 | 技術 | 說明 |
|----|------|------|
| 前端 | Flutter (Dart) | 跨平台 UI，VS Code 風格深色主題 |
| 後端 | Dart Frog (Dart) | 輕量 API 伺服器，處理 RAG 流程 |
| AI 核心 | OpenAI GPT-4o | 生成投資組合建議報告 |
| 向量資料庫 | ChromaDB (Python) | 儲存 ETF 向量，提供相似度搜尋 |
| 資料來源 | etf.xlsx | 單一事實來源，包含所有 ETF 數據 |
| 向量化 | OpenAI text-embedding-3-small | 將 ETF 描述轉為高維向量 |

## 幾個關鍵數字

- **4 個 API 端點** — `/advanced_recommendation`、`/recommend`、`/etf_details`、`/portfolio_holdings`
- **3 步精靈** — 風險偏好、主題權重、進階設定
- **1 個 Excel 檔案** — 所有 ETF 數據的單一事實來源
- **8 個 AI Agent** — 專案經理、架構師、後端工程師、前端工程師、金融顧問、Python 工程師、測試工程師、使用者 persona
- **2 次語言模型呼叫** — 1 次 Embedding + 1 次 GPT-4o
- **1 次資料來源探索的失敗** — FinMind API、TWSE OpenAPI、網頁爬蟲、yfinance 全部試過，最終回到 Excel

## 讀法建議

```
你想了解什麼？                → 去哪裡
─────────────────────────────────────────
為什麼用 RAG 不用直接問 AI    → 01_PHILOSOPHY.md
整體架構怎麼串                → 02_ARCHITECTURE.md
RAG 管線每一步怎麼跑          → 03_RAG_PIPELINE.md
資料來源探索的曲折故事         → 04_DATA_SOURCE_JOURNEY.md
前端怎麼架構的                → 05_FRONTEND.md
後端四個路由怎麼分工           → 06_BACKEND.md
AI Agent 治理層是什麼          → 07_AGENT_GOVERNANCE.md
這專案強在哪、弱在哪           → 08_STRENGTHS_AND_GAPS.md
每個版本做了什麼               → 09_BUILDING_JOURNEY.md
```

## 授權

專案使用 OpenAI API（需自備 API Key）。ETF 數據來自使用者提供的 `etf.xlsx`。