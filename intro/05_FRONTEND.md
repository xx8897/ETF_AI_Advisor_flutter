---
title: "Flutter 前端"
document_type: reference
version: 1.0
language: zh-TW
frontend_stack:
  framework: Flutter (Dart)
  state_management: Provider (ChangeNotifier)
  charts: fl_chart
  themes: VS Code 風格深色主題 + Material 3 淺色主題
  routing: Navigator.push
files:
  - main.dart (入口 + 主題定義)
  - theme_provider.dart (淺色/深色切換)
  - home_page.dart (3 步設定精靈)
  - result_page.dart (AI 報告頁)
  - portfolio_pie_chart.dart (資產配置圓餅圖)
  - etf_details_dialog.dart (ETF 詳情對話框)
related_documents:
  - 02_ARCHITECTURE.md
  - 06_BACKEND.md
  - 03_RAG_PIPELINE.md
tags: [frontend, Flutter, Stepper, pie-chart, theme-switching]
---

# Flutter 前端

> 沒有 Redux，沒有 Bloc，沒有 Riverpod。一個 ChangeNotifier 就夠了。

## 檔案結構

```
etf_advisor_frontend/lib/
├── main.dart                        ← 入口點 + 主題定義 (240+ 行)
├── providers/
│   └── theme_provider.dart          ← 淺色/深色主題切換 (20 行)
├── screens/
│   ├── home_page.dart               ← 3 步設定精靈 (500+ 行)
│   └── result_page.dart             ← AI 報告頁 (400+ 行)
└── widgets/
    ├── portfolio_pie_chart.dart     ← 圓餅圖 (150 行)
    └── etf_details_dialog.dart      ← ETF 詳情對話框 (300+ 行)
```

## 入口點 — main.dart

`main.dart` 做三件事：

1. **Provider 注入**：用 `ChangeNotifierProvider<ThemeProvider>` 包裹整個 App
2. **主題定義**：定義兩套完整主題
   - 深色主題：靈感來自 VS Code，深紫色主色調，深灰背景
   - 淺色主題：標準 Material 3 淺色主題
3. **路由**：`AdvisorHomePage` 為首頁

```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}
```

## 主題切換 — ThemeProvider

最簡單的狀態管理：一個 `ChangeNotifier` 持有 `ThemeMode`。

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // 預設深色
  ThemeMode get themeMode => _themeMode;
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
```

在 `home_page.dart` 的 AppBar 上有一個切換按鈕，呼叫 `Provider.of<ThemeProvider>(context).toggleTheme()`。

## 3 步設定精靈 — AdvisorHomePage

`home_page.dart` 是使用者的主要互動頁面，使用 Flutter 的 `Stepper` 組件：

### Step 1：風險偏好

```
⬜ 保守型 — 追求穩定性，低風險低回報
⬛ 穩健型 — 平衡風險與回報（預設）
⬜ 積極型 — 追求高回報，承受高波動
```

三個 `RadioListTile`，預設選「穩健型」。

### Step 2：主題權重

四個 `Slider`，總和必須為 100%：

| 主題 | 預設 | 滑桿範圍 |
|------|------|---------|
| 高股息 | 50% | 0-100% |
| 科技/半導體 | 30% | 0-100% |
| 市值型 | 10% | 0-100% |
| ESG | 10% | 0-100% |

滑桿調整時即時計算總和，超過 100% 顯示紅色警告。

### Step 3：進階設定

- **組合規模**：3-8 檔 ETF（預設 4）
- **Beta 上限**：可選，滑桿
- **夏普值下限**：可選，滑桿

### 提交

按下「開始分析」後，發送 POST 請求到後端：

```dart
final response = await http.post(
  Uri.parse('http://localhost:8080/advanced_recommendation'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(dna),
);
```

成功後導航到 `ResultPage`。

## AI 報告頁 — ResultPage

`result_page.dart` 是分析結果的展示頁，包含：

### 1. 整體分析文字

AI 生成的 `overall_analysis` 文字，用卡片展示。

### 2. 資產配置圓餅圖

`PortfolioPieChart` 組件，使用 `fl_chart` 庫：

- 每檔 ETF 一個切片
- 切片顏色來自 `Colors.primaries`
- 觸摸切片時放大顯示
- 百分比標籤

### 3. ETF 卡片列表

每檔推薦的 ETF 一張卡片：

```
┌─────────────────────────────────────┐
│ 🟢 0056 元大高股息    配置: 35%     │
│ 理由: 高股息主題的核心配置...       │
│                              [ℹ️]  │
└─────────────────────────────────────┘
```

點擊 `[ℹ️]` 圖標觸發 `EtfDetailsDialog`。

### 4. 投資組合總覽（ExpansionTile）

可展開的區域，顯示所有 ETF 的**加權持股總覽**：

```
▸ 投資組合總覽（點擊展開）
  ┌──────────────────────────────────────┐
  │ 台積電          35.2%               │
  │ 中華電信         8.1%               │
  │ 鴻海             7.5%               │
  │ 其他            49.2%               │
  └──────────────────────────────────────┘
```

數據來自 `POST /portfolio_holdings` API。

## ETF 詳情對話框 — EtfDetailsDialog

呼叫 `GET /etf_details/<code>` 獲取 ETF 完整資訊，顯示：

1. **持股/持債圓餅圖**：前十大持股 + 「其他」類別
2. **關鍵指標表格**：ETF 代碼、名稱、類別、規模、科技占比、年化殖利率、配息頻率、1 年報酬率、Beta、夏普值

持股解析使用正則表達式：`([\s\S]+?)\((\d+\.\d+)%\)`

**注意**：這個解析邏輯和後端的 `portfolio_holdings.dart` 是重複的，兩邊必須保持同步。

## 設計特點

### VS Code 風格深色主題

不是一般的深色主題，是靈感來自 VS Code 的深色主題：

```dart
darkTheme: ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF7B68EE),    // 深紫色主色
  scaffoldBackgroundColor: const Color(0xFF1E1E1E), // VS Code 背景
  cardColor: const Color(0xFF252526),         // VS Code 側邊欄
  // ...
)
```

### 漸層背景

報告頁使用全螢幕漸層背景：

```dart
decoration: const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A237E), Color(0xFF0D1B2A)],
  ),
),
```

### 兩階段資料載入

- **第一階段**：報告資料從 `home_page.dart` 通過建構子傳入（已在 POST 回應中獲得）
- **第二階段**：持股總覽和 ETF 詳情在 `result_page.dart` 中按需從後端獲取