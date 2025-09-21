# ETF AI Advisor (Flutter Edition)

这是一个由 Flutter 和 Dart 驱动的、拥有现代化使用者介面的智慧型 ETF 投资顾问。此应用程式根据使用者选择的投资主题，为台湾市场的 ETF 提供由 GPT-4o 生成的个人化投资组合建议。

---

## 核心功能

-   **现代化 UI**: 采用 Flutter 打造，提供流畅的、跨平台一致的使用者体验。
-   **浅色/深色主题**: 内建精致的、灵感来自 VS Code 的专业深色主题，以及一个干净的浅色主题，可随时切换。
-   **主题式投资**: 使用者可以从多个预设主题（如 "高股息", "科技/半导体" 等）中选择自己的投资偏好。
-   **动态投资组合生成**: AI 会根据使用者选择的主题，动态生成一个包含 2-3 档 ETF 的投资组合建议。
-   **个人化分析报告**: 报告中包含对整体投资组合的分析、推荐的 ETF 列表、建议的资金配置比例，以及推荐原因。

## 技术架构

本专案采用基于 Dart 和 Python 的微服务架构：

-   **前端**: **Flutter** (`etf_advisor_frontend/`)
    -   负责所有使用者介面和互动。
-   **后端**: **Dart** (`dart_backend/`)
    -   使用 **Dart Frog** 框架，负责处理业务逻辑和 API 请求。
-   **AI / LLM**: **OpenAI GPT-4o**
    -   负责生成最终的投资分析报告。
-   **向量资料库**: **ChromaDB** (Python)
    -   作为独立的伺服器运行，负责储存和检索 ETF 资料的向量。
-   **资料来源**: **本地 Excel 檔案** (`scripts/data/etf.xlsx`)
    -   专案唯一的、权威的资料来源，包含所有 ETF 的属性、因子和持股数据。

## 启动指南

本专案的运行，需要同时启动两个独立的伺服器，和一个 Flutter 应用程式。

### **第一步：环境设定 (只需执行一次)**

1.  **安装 Flutter 和 Python**: 确保您的环境中已正确安装 Flutter SDK 和 Python 3.9+。
2.  **克隆仓库**: `git clone <your-new-repo-url>`
3.  **安装 Python 依賴**: `pip install -r requirements.txt`
4.  **设定环境变数**: 复制 `.env.example` 为 `.env`，并填入您自己的 `OPENAI_API_KEY`。

### **第二步：建立向量资料库 (只需执行一次)**

1.  **在终端机 1**: 启动 ChromaDB 伺服器
    ```bash
    # 切换到专案根目录
    chroma run --path chroma_db
    ```
2.  **在终端机 2**: 执行资料库建立脚本
    ```bash
    # 切换到专案根目录
    python build_vector_db.py
    ```
    *(完成后，您可以关闭此终端机。)*

### **第三步：日常运行**

1.  **在终端机 1**: 启动 ChromaDB 伺服器
    ```bash
    # 切换到专案根目录
    chroma run --path chroma_db
    ```
2.  **在终端机 2**: 启动 Dart 后端伺服器
    ```bash
    # 切换到专案根目录
    build_and_start.bat
    ```
3.  **在终端机 3**: 启动 Flutter 应用程式

    我们提供了一个方便的互动式脚本来启动前端应用程式。

    **启动方法:**

    在专案根目录下，执行以下指令，然后根据选单提示选择要运行的平台。
    ```bash
    start_frontend.bat
    ```

---

## 专案文件导览

-   **`task.md`**: 专案的战略蓝图与任务清单。
-   **`PROJECT_STRUCTURE.md`**: 系统架构图。
-   **`updatelog.md`**: 详细的开发过程全貌。
-   **`project.md`**: 官方的功能变更日志。