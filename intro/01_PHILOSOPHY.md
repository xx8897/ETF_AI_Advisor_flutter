---
title: "設計哲學"
document_type: philosophy
version: 1.0
language: zh-TW
core_philosophies:
  - name: "檢索增強生成（RAG）"
    summary: "AI 的建議必須基於真實 ETF 數據，不是憑空生成"
  - name: "投資組合 DNA"
    summary: "投資偏好不是單一主題，是多維度的組合"
  - name: "動態提示工程"
    summary: "每個使用者的偏好組合成獨一無二的 Prompt"
  - name: "防禦性回應處理"
    summary: "AI 的輸出不可預測，後端必須是最後一道防線"
  - name: "單一事實來源"
    summary: "一個 Excel 檔案，不再追逐外部 API"
design_decisions:
  - decision: "使用 RAG 而非直接問 GPT"
    rationale: "GPT 對台灣 ETF 的知識不完整且可能過時，RAG 確保建議基於真實數據"
  - decision: "投資組合 DNA 取代單一主題選擇"
    rationale: "真實投資者的偏好是多維度的，不是選一個主題就好"
  - decision: "Dart Frog 而非 Python FastAPI"
    rationale: "與 Flutter 前端同語言，減少技術棧碎片化"
  - decision: "單一 Excel 而非多源 API"
    rationale: "API 不完整、爬蟲不穩定、yfinance 深度不足"
  - decision: "防禦性 JSON 轉換而非信任 AI 輸出"
    rationale: "LLM 輸出格式不可預測，後端必須確保前端收到穩定格式"
related_documents:
  - 00_OVERVIEW.md
  - 03_RAG_PIPELINE.md
  - 04_DATA_SOURCE_JOURNEY.md
tags: [philosophy, RAG, dynamic-prompt, defensive-programming, single-source-of-truth]
---

# 設計哲學

> 這個專案最核心的問題是：怎麼讓 AI 的建議基於真實數據，而不是憑空捏造？答案是 RAG。怎麼讓使用者的偏好被 AI 真正理解？答案是投資組合 DNA。

## 一、檢索增強生成（RAG）— AI 的建議必須基於真實數據

### 問題

GPT-4o 對台灣 ETF 有一定的知識，但有幾個問題：

1. **知識截止**：GPT-4o 的訓練數據有截止日期，最新的 ETF 成分股和績效數據可能不是即時的
2. **幻覺風險**：直接問 GPT「推薦三檔科技 ETF」，它可能推薦不存在的或已下市的 ETF
3. **精度不足**：GPT 無法精確知道每一檔 ETF 的 Beta 值、夏普值、前十大持股比例

### 回答

RAG（Retrieval-Augmented Generation）的流程是：

```
使用者偏好 → 向量化查詢 → ChromaDB 相似度搜尋 → 相關 ETF 文件
    ↓
GPT-4o + 相關 ETF 文件 + 使用者偏好 → 個人化投資組合建議
```

AI 不是憑空生成建議，而是先從知識庫中檢索相關 ETF 數據，再基於這些真實數據生成報告。這大大降低了幻覺風險——AI 推薦的每一檔 ETF 都必須在檢索結果中存在。

### 碰撞點

RAG 的品質取決於向量資料庫的品質。如果 `etf.xlsx` 的數據不完整或過時，檢索結果就會偏離，AI 的建議也會偏離。RAG 解決了「憑空生成」的問題，但沒有解決「數據品質」的問題。

---

## 二、投資組合 DNA — 偏好不是單一主題

### 問題

第一版（v1.0）的推薦流程很簡單：使用者選一個主題（例如「高股息」），AI 推薦 2-3 檔相關 ETF。

這不夠好，因為：

1. **真實投資者的偏好是多維的** — 「我想要穩健，但也不想吃掉科技股的成長」
2. **風險承受度不同** — 同樣選「高股息」，保守型和積極型的配置應該不同
3. **量化篩選** — 有些使用者想知道 Beta 值和夏普值

### 回答

v2.1 引入了「投資組合 DNA」— 一個多維度的偏好組合：

| 維度 | 選項 | 影響 |
|------|------|------|
| 風險承受度 | 保守型 / 穩健型 / 積極型 | AI 的整體配置風格 |
| 主題權重 | 高股息 / 科技半導體 / 市值型 / ESG（滑桿，總和 100%） | AI 推薦的產業配置 |
| 量化篩選 | Beta 上限 / 夏普值下限（可選） | 硬性排除不符合條件的 ETF |
| 組合規模 | 3-8 檔 | AI 推薦的 ETF 數量 |

這不是選一個主題，而是定義一個完整的投資人格。AI 收到的不是「推薦高股息 ETF」，而是：

> 「為一位穩健型投資者，偏好高股息 60%、科技半導體 40%，Beta 上限 1.2，夏普值下限 0.5，建議 4 檔 ETF，提供個人化投資組合分析。」

### 碰撞點

維度越多，Prompt 越長，GPT-4o 的回應越難預測。投資組合 DNA 帶來了更精準的推薦，但也帶來了更複雜的 Prompt 工程和更難處理的 AI 輸出格式。

---

## 三、動態提示工程 — 每個 Prompt 都是獨一無二的

### 問題

傳統的 AI 推薦系統使用固定 Prompt：「你是一個財務顧問，請推薦 N 檔 ETF」。使用者只能提供主題，AI 用同一個 Prompt 處理所有請求。

### 回答

動態提示工程就是：**根據使用者的投資組合 DNA，動態生成一個獨一無二的 Prompt。**

後端的 `_buildDynamicPrompt()` 函數把使用者的偏好翻譯成自然語言：

```
穩健型投資者 + 高股息 60% + 科技 40% + Beta < 1.2 + 夏普 > 0.5 + 4 檔 ETF

        ↓ 翻譯

「這位投資者的風險承受度為穩健型，偏好高股息主題（佔 60%）
和科技/半導體主題（佔 40%）。篩選條件：Beta 值不超過 1.2，
夏普值不低於 0.5。請推薦 4 檔 ETF 組成的投資組合，
確保高股息和科技主題的配置比例符合使用者偏好。」
```

這個翻譯過程不是簡單的字串拼接，是根據每個維度的值和它們的組合，生成有意義的自然語言描述。

### 碰撞點

動態 Prompt 的問題是：Prompt 越詳細，GPT 的回應格式越難預測。有時候 GPT 會用中文鍵名（`ETF代號`），有時候用英文（`etf_code`）。這就是為什麼需要防禦性回應處理。

---

## 四、防禦性回應處理 — AI 的輸出不可預測

### 問題

GPT-4o 的輸出是 JSON 格式（`response_format: json_object`），但 JSON 的鍵名和結構不可預測：

- 有時候回傳 `ETF代號`，有時候回傳 `etf_code`
- 有時候 `portfolio` 是一個列表，有時候是一個物件
- 有時候 `allocation` 是字串 `"30%"`，有時候是數字 `30`

### 回答

後端的 `_transformAiResponse()` 函數是「最後一道防線」：

1. **鍵名統一**：不管 AI 回傳 `ETF代號` 還是 `etf_code`，都轉換為 `etf_code`
2. **結構統一**：不管 `portfolio` 是 List 還是 Map，都轉換為 List
3. **型別統一**：不管 `allocation` 是字串還是數字，都轉換為適當的型別

```dart
// 防禦性轉換的簡化邏輯
if (portfolio is Map) {
    portfolio = [portfolio]; // 單一物件轉為列表
}
for (var item in portfolio) {
    result.add({
        'etf_code': item['etf_code'] ?? item['ETF代號'] ?? '',
        'etf_name': item['etf_name'] ?? item['ETF名稱'] ?? '',
        'allocation': (item['allocation'] ?? item['配置比例'] ?? 0).toDouble(),
        'reason': item['reason'] ?? item['理由'] ?? '',
    });
}
```

### 碰撞點

防禦性轉換永遠不可能覆蓋所有情況。如果 GPT-4o 回傳了一個完全意料之外的結構（比如巢狀了三層），轉換邏輯可能會失敗。這是所有依賴 LLM 輸出的系統的根本挑戰。

---

## 五、單一事實來源 — 不再追逐外部 API

### 問題

專案最初嘗試了四種外部資料來源：

1. **FinMind API** — 缺少 ETF 成分股和完整列表
2. **TWSE OpenAPI** — 資料不完整，缺成分股
3. **網頁爬蟲** — Goodinfo、MoneyDJ、Wantgoo、MacroMicro 全部有反爬蟲機制
4. **yfinance** — 台灣市場的深度資料不足

沒有任何一個外部 API 能提供所有需要的數據。

### 回答

**一個 Excel 檔案。** `scripts/data/etf.xlsx` 包含了所有 ETF 的基本資料、量化因子、成分股。這個檔案是專案的單一事實來源（Single Source of Truth）。

這個決策的代價是：數據需要手動更新。但好處是：數據完全可控、不需要處理 API 限流和爬蟲反制、向量資料庫的品質完全取決於這一個檔案的品質。

---

## 設計哲學的總結

ETF AI 智能顧問的五條設計哲學是在實作中長出來的：

| 哲學 | 來源 | 張力 |
|------|------|------|
| RAG | GPT 不了解台灣 ETF 的全部細節 | RAG 品質取決於數據品質 |
| 投資組合 DNA | 使用者偏好是多維的 | 維度越多 Prompt 越難控制 |
| 動態提示工程 | 固定 Prompt 無法捕捉個人偏好 | 詳細 Prompt 導致不可預測的回應格式 |
| 防禦性回應處理 | LLM 輸出格式不可預測 | 不可能覆蓋所有情況 |
| 單一事實來源 | 外部 API 和爬蟲都不可靠 | 數據需要手動更新 |

最核心的設計選擇是第一條——RAG。所有其他設計都是圍繞 RAG 流程展開的：投資組合 DNA 是為了生成更好的查詢和 Prompt，防禦性回應處理是為了處理 RAG + GPT 的輸出不確定性，單一事實來源是為了確保 RAG 的檢索品質。