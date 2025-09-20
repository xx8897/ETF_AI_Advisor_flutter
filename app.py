import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
from core_logic import generate_recommendation, AVAILABLE_THEMES

# --- 頁面設定 ---
st.set_page_config(
    page_title="ETF主題式智能理財顧問",
    page_icon="💡",
    layout="wide"
)

# --- 主標題 ---
st.title("💡 ETF 主題式智能理財顧問")
st.write("您好，我是您的理財顧問。請從下方選擇您感興趣的投資主題，我將為您生成一份客製化的 ETF 投資組合建議。")

# --- 步驟 1: 使用者輸入 ---
st.subheader("步驟一：請選擇您感興趣的投資主題")
selected_themes = st.multiselect(
    label="您可以複選感興趣的主題：",
    options=AVAILABLE_THEMES,
    default=None, # 預設不選中任何項目
    placeholder="請選擇主題..."
)
st.write(f"您已選擇: {', '.join(selected_themes) if selected_themes else '尚未選擇'}")

# --- 步驟 2: 生成報告按鈕 ---
st.subheader("步驟二：生成您的分析報告")
if st.button("生成分析報告", type="primary"):
    if not selected_themes:
        st.warning("請至少選擇一個投資主題！")
    else:
        with st.spinner("AI 顧問正在為您客製化分析報告，請稍候..."):
            try:
                # 呼叫核心邏輯
                report = generate_recommendation(selected_themes)

                if "error" in report:
                    st.error(f"報告生成失敗: {report['error']}")
                    st.code(report.get('raw_output', ''))
                else:
                    st.success("您的客製化投資分析報告已生成！")
                    
                    # 提取報告內容
                    analysis = report.get("report", {}).get("overall_analysis", "N/A")
                    portfolio = report.get("report", {}).get("portfolio", [])

                    # --- 步驟 3: 顯示報告 ---
                    st.subheader("📈 整體投資組合分析")
                    st.write(analysis)

                    st.subheader("📊 建議投資組合配置")
                    
                    if portfolio:
                        # 建立 DataFrame 以便顯示和繪圖
                        df = pd.DataFrame(portfolio)
                        df['allocation'] = pd.to_numeric(df['allocation'])

                        col1, col2 = st.columns([0.6, 0.4])

                        with col1:
                            st.dataframe(df, hide_index=True, use_container_width=True)

                        with col2:
                            # 繪製圓餅圖
                            plt.style.use('ggplot')
                            fig, ax = plt.subplots()
                            ax.pie(df['allocation'], labels=df['etf_code'], autopct='%1.1f%%', startangle=90)
                            ax.axis('equal')  #確保圓餅圖是圓的
                            st.pyplot(fig)

                        # 逐一顯示推薦的ETF細節
                        st.subheader("ETF 推薦詳情")
                        for item in portfolio:
                            with st.container(border=True):
                                st.markdown(f"#### {item['etf_name']} ({item['etf_code']})")
                                st.markdown(f"**建議配置比例：** `{item['allocation']}%`")
                                st.markdown(f"**推薦原因：** {item['reason']}")
                    else:
                        st.write("抱歉，根據您的選擇，目前沒有足夠的資料可生成投資組合。")

            except Exception as e:
                st.error(f"處理過程中發生預期外的錯誤: {e}")