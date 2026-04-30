---
title: "AI Agent 治理層"
document_type: reference
version: 1.0
language: zh-TW
agents:
  - name: user_persona
    role: "使用者人格 — 投資新手 Alex"
    focus: "定義使用者需求、引導所有 UI/UX 決策"
  - name: project_manager
    role: "專案經理"
    focus: "任務管理、代理協調、提交審批"
    critical_rules: ["提交前必須提案等待批准", "永遠不推送", "永遠不啟停伺服器"]
  - name: architect
    role: "系統架構師"
    focus: "整體架構、維護 PROJECT_STRUCTURE.md、编码標準"
  - name: dart_backend_engineer
    role: "Dart 後端工程師"
    focus: "Dart Frog 路由、API 端點、OpenAI/ChromaDB 整合"
    critical_rules: ["提交前必須自我審查（語法、邏輯、依賴一致性）"]
  - name: flutter_ui_ux_engineer
    role: "Flutter UI/UX 工程師"
    focus: "Flutter 前端、Provider 狀態管理、HTTP 整合、UI 打磨"
    critical_rules: ["提交前必須自我審查（null safety、型別安全、語法）"]
  - name: financial_advisor
    role: "金融顧問"
    focus: "驗證金融邏輯、ETF 數據解讀、確保輸出準確"
  - name: python_programmer
    role: "Python 程式師與資料分析師"
    focus: "Python 腳本、資料管線、分析"
  - name: test_engineer
    role: "測試工程師"
    focus: "單元測試、整合測試、E2E 測試、Bug 追蹤"
related_documents:
  - 09_BUILDING_JOURNEY.md
tags: [agents, governance, multi-agent, AI-development]
---

# AI Agent 治理層

> 這個專案是用 8 個 AI Agent 協作開發的。每個 Agent 有明確的角色、職責、和不可違反的規則。

## 什麼是 Agent 治理層

`agents/` 目錄包含 8 個定義文件，每個文件描述了一個 AI Agent 的角色、職責、和約束。這些 Agent 在開發過程中分工協作：

```
┌───────────────────────────────────────────────────────────────┐
│                     專案經理 (PM)                               │
│   任務管理、代理協調、提交審批                                   │
│   關鍵規則：提交前必須提案等待批准、永不推送、永不啟停伺服器     │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│   │  系統架構師  │  │  金融顧問    │  │  測試工程師  │      │
│   │  架構決策    │  │  驗證金融邏輯│  │  品質保證    │      │
│   └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│   ┌──────────────────────┐  ┌──────────────────────────┐    │
│   │  Dart 後端工程師     │  │  Flutter 前端工程師       │    │
│   │  路由、API、RAG      │  │  UI、狀態管理、主題      │    │
│   │  自我審查規則        │  │  自我審查規則            │    │
│   └──────────────────────┘  └──────────────────────────┘    │
│                                                               │
│   ┌──────────────────────┐                                    │
│   │  Python 程式師      │                                    │
│   │  資料管線、分析      │                                    │
│   └──────────────────────┘                                    │
│                                                               │
│   ┌──────────────────────┐                                    │
│   │  使用者 Persona Alex │  ←  引導所有決策                    │
│   │  投資新手、怕風險    │                                    │
│   └──────────────────────┘                                    │
└───────────────────────────────────────────────────────────────┘
```

## 8 個 Agent 詳解

### 1. user_persona.md — 使用者人格 Alex

**角色**：投資新手 Alex，剛接觸投資的小資族。

**引導原則**：
- 不了解技術術語，需要白話解釋
- 想要「穩健但不想錯過科技股」的模糊想法
- 需要看得懂的、3-4 檔 ETF 的具體建議

**作用**：所有 UI/UX 決策都以 Alex 的需求為準。如果功能對 Alex 沒有價值，就不做。

### 2. project_manager.md — 專案經理

**角色**：任務管理和代理協調。

**關鍵規則**：
- 提交前必須提案（propose commit message），等待批准
- 永遠不推送（never push）
- 永遠不啟動/停止/重啟伺服器
- 除錯前必須查閱 `updatelog.md`
- 維護不可變的、僅追加的日誌

**作用**：PM 是代理之間的協調者，確保其他人不會同時修改同一個文件。

### 3. architect.py — 系統架構師

**角色**：整體架構決策和編碼標準。

**職責**：
- 維護 `PROJECT_STRUCTURE.md` 作為架構的單一事實來源
- 定義編碼標準和最佳實踐
- 審查所有架構變更

### 4. dart_backend_engineer.md — Dart 後端工程師

**角色**：Dart Frog 伺服器開發。

**關鍵規則**：提交前必須自我審查——語法檢查、邏輯檢查、依賴一致性檢查。

**職責**：
- 實作和維護所有 API 路由
- OpenAI 和 ChromaDB 整合
- RAG 流程實作
- 防禦性回應轉換

### 5. flutter_ui_ux_engineer.md — Flutter 前端工程師

**角色**：Flutter 應用開發。

**關鍵規則**：提交前必須自我審查——null safety、型別安全、語法檢查。

**職責**：
- 實作和維護 Flutter 頁面和組件
- Provider 狀態管理
- HTTP 整合
- UI/UX 打磨和主題系統

### 6. financial_advisor.md — 金融顧問

**角色**：驗證金融邏輯和數據解釋。

**職責**：
- 確保 ETF 數據的解釋正確
- 驗證投資組合建議的合理性
- 確保 AI 輸出的金融術語準確

### 7. python_programmer.py — Python 程式師

**角色**：Python 腳本開發和資料分析。

**職責**：
- `build_vector_db.py` — 向量資料庫建構
- `test_retriever.py` — 檢索驗證
- `inspect_excel.py` — Excel 檢查
- 其他資料處理腳本

### 8. test_engineer.py — 測試工程師

**角色**：品質保證。

**職責**：
- 建立和維護單元測試、整合測試、E2E 測試
- Bug 追蹤和分類
- 自動化測試流程

## Agent 治理的觀察

### 好的地方

1. **角色清晰**：每個 Agent 有明確的職責邊界，不會越界
2. **關鍵規則有效**：PM 的「永不推送」規則避免了意外推送
3. **使用者導向**：Alex persona 確保所有決策以使用者需求為中心
4. **金融驗證**：金融顧問確保 AI 輸出的金融術語準確

### 值得反思的地方

1. **Agent 治理是開發時的輔助**，不是運行時的架構。這些 Agent 定義文件是在 AI 輔助開發過程中使用的，不是應用程式的一部分。
2. **PM 的「提案等待批准」規則**假設有人類在最終批准。如果完全自主開發，這個規則需要調整。
3. **測試工程師的定義存在，但測試覆蓋率不高**。`dart_backend/test/` 和 `etf_advisor_frontend/test/` 目錄存在，但沒有看到完整的�試套件。
4. **金融顧問的角色是驗證性的**，不是生成性的。驗證 AI 輸出的金融準確性是一個持續的挑戰。