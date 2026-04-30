---
title: "RAG 管線詳解"
document_type: technical-deep-dive
version: 1.0
language: zh-TW
pipeline_stages:
  - stage: 離線建構
    input: etf.xlsx
    output: ChromaDB 向量集合
    tool: build_vector_db.py
  - stage: 使用者輸入
    input: 投資組合 DNA
    output: JSON 請求
    tool: Flutter Stepper
  - stage: 動態提示工程
    input: DNA 物件
    output: 自然語言 Prompt
    tool: _buildDynamicPrompt()
  - stage: 查詢建構
    input: DNA 物件
    output: 中文查詢語句
    tool: _buildChromaQuery()
  - stage: 向量搜尋
    input: 查詢語句
    output: 相關 ETF 文件
    tool: OpenAI Embedding + ChromaDB
  - stage: AI 生成
    input: Prompt + RAG 上下文
    output: AI JSON 報告
    tool: GPT-4o
  - stage: 防禦性轉換
    input: AI 原始 JSON
    output: 標準化 JSON
    tool: _transformAiResponse()
related_documents:
  - 01_PHILOSOPHY.md
  - 02_ARCHITECTURE.md
  - 06_BACKEND.md
tags: [RAG, pipeline, embedding, ChromaDB, GPT-4o, dynamic-prompt]
---

# RAG 管線詳解

> 這是專案最核心的技術。從使用者按下「開始分析」到看到報告，資料穿過七個階段。每一個階段都有明確的輸入和輸出。

## 階段零：離線建構（一次性）

在做任何分析之前，需要先把 ETF 數據饋入向量資料庫。

```
etf.xlsx
  │
  ▼
build_vector_db.py
  │
  ├── 1. 讀取 Excel (Pandas)
  │   └── 每一行 ETF → 所有欄位合併為文字描述
  │       例如：「ETF代號: 0050, ETF名稱: 元大台灣50, 類別: 市值型,
  │             基金規模: 3000億, 科技占比: 60%, 年化殖利率: 2.5%,
  │             Beta: 1.02, 夏普值: 0.85, 主要持股: 台積電(30%)...」
  │
  ├── 2. 建立 LangChain Documents
  │   └── page_content = 合併文字描述
  │   └── metadata = {etf_code, etf_name, theme}
  │
  ├── 3. 向量化 (OpenAI text-embedding-3-small)
  │   └── 每份 Document → 1536 維度浮點數向量
  │
  └── 4. 存入 ChromaDB
      └── Collection: etf_collection
      └── 包含所有 ETF 的向量 + 原始文件
```

**關鍵設計**：每份 ETF 不是只存名稱和代碼，是存**所有欄位**的完整文字描述。這讓語意搜尋可以根據任何面向找到相關 ETF——不只是名稱相似，還有 Beta 值、夏普值、成分股等。

## 階段一：使用者輸入

使用者在 Flutter Stepper 中設定投資組合 DNA：

```dart
{
  "risk_profile": "moderate",           // 保守/穩健/積極
  "theme_weights": {
    "high_dividend": 0.6,               // 高股息 60%
    "tech_semiconductor": 0.4,          // 科技半導體 40%
    "market_cap": 0.0,                  // 市值型 0%
    "esg": 0.0                          // ESG 0%
  },
  "filters": {
    "beta_max": 1.2,                    // Beta 上限 1.2
    "sharpe_min": 0.5                   // 夏普值下限 0.5
  },
  "portfolio_size": 4                   // 推薦 4 檔 ETF
}
```

Flutter 前端把這個 JSON POST 到 `http://localhost:8080/advanced_recommendation`。

## 階段二：動態提示工程

後端收到 DNA 後，`_buildDynamicPrompt()` 把它翻譯成自然語言：

```dart
String _buildDynamicPrompt(Map<String, dynamic> dna) {
  final buffer = StringBuffer();
  
  // 風險偏好翻譯
  buffer.write('這位投資者的風險承受度為「穩健型」，');
  buffer.write('追求風險與回報的平衡。');
  
  // 主題權重翻譯
  buffer.write('偏好高股息主題（佔 60%），');
  buffer.write('以及科技/半導體主題（佔 40%）。');
  
  // 量化篩選翻譯
  buffer.write('篩選條件：Beta 值不超過 1.2，');
  buffer.write('夏普值不低於 0.5。');
  
  // 組合規模
  buffer.write('請推薦 4 檔 ETF 組成的投資組合。');
  
  return buffer.toString();
}
```

**為什麼不直接把 JSON 丟給 GPT**：自然語言 Prompt 讓 GPT 更精準地理解投資者的意圖，而不是讓它自己解讀 JSON 欄位的含義。

## 階段三：查詢建構

`_buildChromaQuery()` 把 DNA 轉成 ChromaDB 能搜尋的查詢語句：

```dart
String _buildChromaQuery(Map<String, dynamic> dna) {
  final parts = <String>[];
  
  // 風險轉換為描述
  if (dna['risk_profile'] == 'conservative') {
    parts.add('低風險 穩定 配息');
  } else if (dna['risk_profile'] == 'moderate') {
    parts.add('平衡 成長 配息');
  } else {
    parts.add('高成長 科技 高報酬');
  }
  
  // 主題轉換為關鍵詞
  final weights = dna['theme_weights'] as Map;
  if (weights['high_dividend'] > 0) {
    parts.add('高股息 配息');
  }
  if (weights['tech_semiconductor'] > 0) {
    parts.add('科技 半導體');
  }
  // ...
  
  return '為一位${riskLabel}的投資者，尋找關於${themes}的 ETF';
}
```

## 階段四：向量搜尋

```
_buildChromaQuery() 的查詢語句
  │
  ▼
OpenAI text-embedding-3-small API
  │
  ▼ (查詢語句 → 1536 維度向量)
  │
ChromaDB v2 API
  POST /api/v2/tenants/default_tenant/databases/default_database
       /collections/<uuid>/query
  {
    "query_embeddings": [[0.1, 0.2, -0.05, ..., 0.n]],
    "n_results": 15
  }
  │
  ▼
  15 份最相關的 ETF 文件（原始文字描述）
```

**為什麼取 15 份**：使用者要求 3-8 檔 ETF，但 AI 需要更多選擇空間。取 15 份相關文件，讓 GPT-4o 從中挑選最適合的 3-8 檔，而不是只看 3-8 份然後強制選擇。

## 階段五：AI 生成

```
OpenAI Chat Completion API
  │
  ├── System Prompt:
  │   「你是一位專業的台股 ETF 投資顧問。根據以下 ETF 資料和使用者偏好，
  │     提供一份個人化的投資組合建議。必須以 JSON 格式回應...」
  │
  ├── User Message:
  │   「[動態 Prompt] + [RAG 上下文：15 份 ETF 文件]」
  │
  ├── Parameters:
  │   model: gpt-4o
  │   response_format: { type: "json_object" }
  │   temperature: 0.7
  │
  └── Output:
      {
        "overall_analysis": "基於您穩健型投資偏好...",
        "portfolio": [
          {"ETF代號": "0056", "ETF名稱": "元大高股息", "配置比例": "35%", "理由": "..."},
          {"ETF代號": "00891", "ETF名稱": "國泰台灣5G+", "配置比例": "25%", "理由": "..."},
          ...
        ]
      }
```

**注意**：GPT-4o 使用了中文鍵名（`ETF代號`、`配置比例`），這不是前端期望的英文鍵名（`etf_code`、`allocation`）。這就是下一步的原因。

## 階段六：防禦性回應轉換

`_transformAiResponse()` 是最後一道防線：

```dart
Map<String, dynamic> _transformAiResponse(Map<String, dynamic> aiResponse) {
  final result = <String, dynamic>{};
  
  // 1. 整體分析：直接傳遞
  result['overall_analysis'] = aiResponse['overall_analysis'] ?? '';
  
  // 2. 投資組合：統一為列表格式
  var portfolio = aiResponse['portfolio'] ?? aiResponse['投資組合'] ?? [];
  if (portfolio is Map) portfolio = [portfolio]; // 單一物件轉列表
  if (portfolio is! List) portfolio = [];
  
  // 3. 每個 ETF：鍵名統一
  final normalized = <Map<String, dynamic>>[];
  for (var item in portfolio) {
    normalized.add({
      'etf_code': item['etf_code'] ?? item['ETF代號'] ?? '',
      'etf_name': item['etf_name'] ?? item['ETF名稱'] ?? '',
      'allocation': _parseAllocation(item['allocation'] ?? item['配置比例'] ?? 0),
      'reason': item['reason'] ?? item['理由'] ?? '',
    });
  }
  
  result['portfolio'] = normalized;
  return result;
}
```

這個函數處理了三種不確定性：

1. **鍵名不確定**：`etf_code` 或 `ETF代號` → 統一為 `etf_code`
2. **結構不確定**：`portfolio` 可能是 List 或 Map → 統一為 List
3. **型別不確定**：`allocation` 可能是字串 `"35%"` 或數字 `35` → 統一為數字

## 完整管線時間估算

| 階段 | 預估時間 | 瓶頸 |
|------|---------|------|
| 使用者輸入 | 0ms | — |
| 動態提示工程 | <1ms | 純字串操作 |
| 查詢建構 | <1ms | 純字串操作 |
| OpenAI Embedding | 200-500ms | 網路延遲 |
| ChromaDB 搜尋 | 50-100ms | 本地搜尋 |
| GPT-4o 生成 | 3-10秒 | ★ 最大瓶頸 |
| 防禦性轉換 | <1ms | 純 JSON 操作 |
| **總計** | **4-12秒** | GPT-4o 生成 |

GPT-4o 的生成時間佔整個管線的 80%+。這就是為什麼 v2.2 計畫引入 WebSocket 和非同步分析。