import uvicorn
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from core_logic import generate_recommendation, AVAILABLE_THEMES
from fastapi.middleware.cors import CORSMiddleware

# 1. 初始化 FastAPI 应用
app = FastAPI(
    title="ETF AI Advisor API",
    description="为 ETF 智能理财顾问 Flutter 应用提供后端服务。",
    version="1.0.0"
)

# 2. 配置 CORS 中间件
# 允许所有来源的跨域请求，这在开发阶段非常方便
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 允许所有来源
    allow_credentials=True,
    allow_methods=["*"],  # 允许所有方法 (GET, POST, etc.)
    allow_headers=["*"],  # 允许所有请求头
)

# 3. 定义 API 请求的数据模型
class ThemesRequest(BaseModel):
    themes: List[str]

# 4. 定义 API 端点 (Endpoints)
@app.get("/themes", summary="获取所有可用的投资主题")
def get_themes():
    """
    回传一个包含所有可用投资主题的字串列表。
    """
    return {"themes": AVAILABLE_THEMES}

@app.post("/generate_recommendation", summary="根据主题生成投资建议")
def create_recommendation(request: ThemesRequest):
    """
    接收使用者选择的主题列表，并回传一份由 AI 生成的完整投资分析报告。
    """
    report = generate_recommendation(request.themes)
    return report

# 5. (可选) 定义根路径
@app.get("/", summary="API 根路径")
def read_root():
    return {"message": "欢迎使用 ETF AI Advisor API"}

# 6. 启动服务器 (用于直接运行此文件进行测试)
if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
