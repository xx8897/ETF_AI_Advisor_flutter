import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import json
from core_logic import generate_recommendation, AVAILABLE_THEMES

# --- 頁面設定 ---
st.set_page_config(
    page_title="ETF主題式智能理財顧問",
    page_icon="💡",
    layout="wide"
)

# --- 靜態資源載入 ---
@st.cache_data
def load_dynamic_data():
    """載入並快取 ETF 動態資料"""
    with open('etf_dynamic_data.json', 'r', encoding='utf-8') as f:
        return json.load(f)

dynamic_data = load_dynamic_data()

# --- UI 介面 ---
st.title("💡 ETF 主題式智能理財顧問")
st.write("您好，我是您的理財顧問。請從下方選擇您感興趣的投資主題，我將為您生成一份客製化的 ETF 投資組合建議。")

# 步驟 1: 使用者輸入
st.subheader("步驟一：請選擇您感興趣的投資主題")
selected_themes = st.multiselect(
    label="您可以複選多個主題：",
    options=AVAILABLE_THEMES,
    default=None,
    placeholder="請選擇主題..."
)

# 步驟 2: 生成報告按鈕
st.divider()
if st.button("🚀 生成分析報告", type="primary", use_container_width=True):
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
                    
                    analysis = report.get("report", {}).get("overall_analysis", "N/A")
                    portfolio = report.get("report", {}).get("portfolio", [])

                    # --- 步驟 3: 顯示報告 ---
                    st.subheader("📈 整體投資組合分析")
                    st.write(analysis)
                    st.divider()

                    st.subheader("📊 建議投資組合配置")
                    
                    if portfolio:
                        df = pd.DataFrame(portfolio)
                        df['allocation'] = pd.to_numeric(df['allocation'])

                        col1, col2 = st.columns([0.6, 0.4])
                        with col1:
                            st.dataframe(df[['etf_code', 'etf_name', 'allocation', 'reason']], hide_index=True, use_container_width=True)
                        with col2:
                            fig, ax = plt.subplots()
                            ax.pie(df['allocation'], labels=df['etf_code'], autopct='%1.1f%%', startangle=90)
                            ax.axis('equal')
                            st.pyplot(fig)
                        
                        st.divider()
                        
                        # --- 功能增強: 顯示 ETF 成分股 ---
                        st.subheader("ETF 推薦詳情與成分股")
                        aggregated_holdings = {}
                        
                        for item in portfolio:
                            with st.expander(f"**{item['etf_name']} ({item['etf_code']})** - 配置 {item['allocation']}%"):
                                st.markdown(f"**推薦原因：** {item['reason']}")
                                
                                etf_code = item['etf_code']
                                holdings = dynamic_data.get(etf_code, {}).get('top_10_holdings', [])
                                
                                if holdings:
                                    holdings_df = pd.DataFrame(holdings)
                                    st.dataframe(holdings_df, hide_index=True, use_container_width=True)
                                    
                                    # 計算加權成分
                                    allocation_ratio = item['allocation'] / 100.0
                                    for holding in holdings:
                                        stock_name = holding['name']
                                        stock_weight = float(holding['weight'].replace('%', ''))
                                        weighted_stock_weight = stock_weight * allocation_ratio
                                        aggregated_holdings[stock_name] = aggregated_holdings.get(stock_name, 0) + weighted_stock_weight
                                else:
                                    st.write("此 ETF 無法查詢成分股資訊。")

                        # --- 功能增強: 顯示加權後的成分股總表 ---
                        st.divider()
                        st.subheader("📁 投資組合加權成分股總表")
                        st.write("這份總表顯示了根據建議的配置比例，您的資金在底層持股中的最終分佈情況。")
                        
                        if aggregated_holdings:
                            sorted_holdings = sorted(aggregated_holdings.items(), key=lambda x: x[1], reverse=True)
                            agg_df = pd.DataFrame(sorted_holdings, columns=['股票名稱', '佔總投資組合比例 (%)'])
                            agg_df['佔總投資組合比例 (%)'] = agg_df['佔總投資組合比例 (%)'].map('{:.2f}%'.format)
                            st.dataframe(agg_df, hide_index=True, use_container_width=True)
                        else:
                            st.write("無法計算加權成分股。")

                    else:
                        st.write("抱歉，根據您的選擇，目前沒有足夠的資料可生成投資組合。")

            except Exception as e:
                st.error(f"處理過程中發生預期外的錯誤: {e}")