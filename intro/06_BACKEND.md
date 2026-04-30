---
title: "Dart Frog 後端"
document_type: reference
version: 1.0
language: zh-TW
routes:
  - path: "/advanced_recommendation"
    method: POST
    purpose: "進階推薦 API（主要端點）"
    input: "投資組合 DNA JSON"
    output: "AI 分析報告 JSON"
  - path: "/recommend"
    method: POST
    purpose: "簡單推薦 API（v1，向後兼容）"
    input: "主題列表"
    output: "AI 分析報告 JSON"
  - path: "/etf_details/<etf_code>"
    method: GET
    purpose: "ETF 詳細資訊"
    input: "ETF 代碼"
    output: "ETF 完整資訊 JSON"
  - path: "/portfolio_holdings"
    method: POST
    purpose: "投資組合加權持股查詢"
    input: "投資組合配置"
    output: "加權持股分佈 JSON"
middleware: CORS 中介軟體（允許 Flutter 前端跨域請求）
dependencies: [dart_frog, http, dotenv, excel]
related_documents:
  - 02_ARCHITECTURE.md
  - 03_RAG_PIPELINE.md
  - 05_FRONTEND.md
tags: [backend, Dart-Frog, API, CORS, defensive-transformation]
---

# Dart Frog 後端

> 四個路由，一個中介軟體，一個核心功能：把 AI 的不可預測輸出變成前端可以信賴的 JSON。

## 路由架構

```
dart_backend/routes/
├── _middleware.dart              ← CORS 中介軟體
├── index.dart                   ← GET / (歡迎頁)
├── recommend.dart               ← POST /recommend (v1 簡單推薦)
├── advanced_recommendation.dart ← ★ POST /advanced_recommendation (v2 進階推薦)
├── portfolio_holdings.dart      ← POST /portfolio_holdings (加權持股)
└── etf_details/
    └── [etf_code].dart           ← GET /etf_details/<code> (ETF 詳情)
```

Dart Frog 使用檔案系統作為路由：檔案路徑 = API 路徑。`[etf_code].dart` 中的方括號表示動態路由參數。

## CORS 中介軟體

`_middleware.dart` 為所有回應添加 CORS 標頭，讓 Flutter Web 可以從不同埠訪問後端。

```dart
Handler middleware(Handler handler) {
  return (RequestContext context) async {
    if (context.request.method == HttpMethod.options) {
      return Response(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      );
    }
    final response = await handler(context);
    return response.copyWith(headers: {
      'Access-Control-Allow-Origin': '*',
      ...response.headers,
    });
  };
}
```

這是在 Flutter 整合時遇到 CORS 問題後添加的——瀏覽器的同源策略阻止了從 `localhost:xxxx` 到 `localhost:8080` 的請求。

## ★ /advanced_recommendation — 進階推薦 API

這是主要端點，完整實現了 RAG 流程。

### 請求格式

```json
{
  "risk_profile": "moderate",
  "theme_weights": {
    "high_dividend": 0.6,
    "tech_semiconductor": 0.4,
    "market_cap": 0.0,
    "esg": 0.0
  },
  "filters": {
    "beta_max": 1.2,
    "sharpe_min": 0.5
  },
  "portfolio_size": 4
}
```

### 處理流程（5 個步驟）

```
advanced_recommendation.dart

1. _buildDynamicPrompt(dna)
   └── DNA → 自然語言 Prompt

2. _buildChromaQuery(dna)
   └── DNA → 中文查詢語句

3. _queryChromaDB(queryText)
   ├── 向 OpenAI Embedding API 請求查詢向量
   ├── 向 ChromaDB v2 API 查詢相似 ETF
   └── 回傳 15 份相關 ETF 文件

4. _callOpenAI(systemPrompt, userMessage)
   └── GPT-4o → AI JSON 報告

5. _transformAiResponse(aiResponse)
   └── 統一鍵名、結構、型別
```

### 防禦性回應轉換

`_transformAiResponse()` 處理三種不確定性：

| 問題 | 解決方式 |
|------|---------|
| GPT 回傳 `ETF代號` 而非 `etf_code` | 逐一檢查兩種鍵名 |
| `portfolio` 是 Map 而非 List | 強制轉為 List |
| `allocation` 是 `"35%"` 而非 `35` | 字串解析 + 型別轉換 |

### ChromaDB v2 API 的發現過程

這是專案中一段痛苦的除錯經歷：

1. 最初使用 `package:chromadb` Dart 客戶端 → 與最新版 ChromaDB 不相容
2. 嘗試 `/api/v1/...` 端點 → 已被棄用
3. 最終發現必須使用 `/api/v2/tenants/{tenant}/databases/{database}/collections/{uuid}/query`
4. 需要先查詢集合 UUID（因為 v2 API 使用 UUID 而非名稱）

這段經歷被記錄在 `chroma_v2_api.md` 中，作為內部參考文件。

## /recommend — 簡單推薦 API（v1）

v1 版本的推薦端點，只接受主題列表，不支援投資組合 DNA。保留是為了向後兼容。

與 `/advanced_recommendation` 的差異：

| | /recommend | /advanced_recommendation |
|---|---|---|
| 輸入 | 主題列表 | 完整投資組合 DNA |
| Prompt | 固定 | 動態生成 |
| 查詢 | 簡單主題詞 | 多維度偏好詞 |
| 檢索數量 | 10 | 15 |
| 防禦性轉換 | 基本 | 完整 |

## /etf_details/<etf_code> — ETF 詳情

動態路由，讀取 `etf.xlsx` 並返回指定 ETF 的所有欄位。

```dart
// 檔案系統路由：etf_details/[etf_code].dart
// URL：GET /etf_details/0050

Future<Response> _onGet(RequestContext context, String etfCode) async {
  final excel = Excel.decodeBytes(File(excelPath).readAsBytesSync());
  final sheet = excel.tables['etf'];
  
  for (var row in sheet.rows) {
    if (row[0]?.value.toString().startsWith(etfCode) ?? false) {
      // 找到匹配的 ETF，返回所有欄位
      return Response.json(body: rowData);
    }
  }
  return Response.json(body: {'error': 'ETF not found'});
}
```

使用 `startsWith` 匹配是因為有些 ETF 代碼帶有 `.TW` 後綴。

## /portfolio_holdings — 加權持股

接收投資組合配置，計算所有 ETF 加權後的合併持股。

```dart
// 請求
{
  "portfolio": [
    {"etf_code": "0056", "allocation": 0.35},
    {"etf_code": "00891", "allocation": 0.25},
    ...
  ]
}

// 回應
{
  "portfolio_holdings": [
    {"name": "台積電", "weight": 35.2},
    {"name": "中華電信", "weight": 8.1},
    ...
  ]
}
```

持股解析使用正則表達式：`([\s\S]+?)\((\d+\.\d+)%\)`

**注意**：這個解析邏輯和前端 `etf_details_dialog.dart` 是重複的。

## 環境變數

每個路由獨立從 `.env` 讀取 `OPENAI_API_KEY`：

```dart
final apiKey = dotenv.env['OPENAI_API_KEY'];
```

沒有共享的配置模組——每個路由自己讀取環境變數。這是簡單但不理想的設計，五個路由有五份 `dotenv.load()` 呼叫。