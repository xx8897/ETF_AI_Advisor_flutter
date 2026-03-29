from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

def create_presentation():
    """
    Generates a PowerPoint presentation for the ETF AI Advisor project.
    """
    print("--- [Step 4/4] Generating PowerPoint Presentation ---")
    
    prs = Presentation()
    
    # Define slide layouts
    title_slide_layout = prs.slide_layouts[0]
    title_and_content_layout = prs.slide_layouts[1]
    section_header_layout = prs.slide_layouts[2]
    two_content_layout = prs.slide_layouts[3]
    blank_slide_layout = prs.slide_layouts[6]

    # --- Slide 1: Title Slide ---
    slide = prs.slides.add_slide(title_slide_layout)
    title = slide.shapes.title
    subtitle = slide.placeholders[1]
    title.text = "ETF AI 智能顧問"
    subtitle.text = """專案成果與技術架構報告
2025-09-22"""

    # --- Slide 2: Project Vision (User Story) ---
    slide = prs.slides.add_slide(title_and_content_layout)
    title = slide.shapes.title
    content = slide.placeholders[1]
    title.text = "專案願景：解決投資痛點"
    tf = content.text_frame
    tf.clear()
    p = tf.paragraphs[0]
    p.text = "使用者故事"
    p.font.bold = True
    p.font.size = Pt(24)
    
    p = tf.add_paragraph()
    p.text = """身為一位剛接觸投資的小資族，
我希望能在一个引導式的介面中，表達我「希望穩健、但又不想錯過科技股趨勢」的模糊想法，
以便於得到一份我能看得懂的、包含 3-4 檔 ETF 的具體投資組合建議，讓我能更有信心地踏出第一步。"""
    p.font.size = Pt(18)

    # --- Slide 3: Core Feature - Portfolio DNA ---
    slide = prs.slides.add_slide(two_content_layout)
    title = slide.shapes.title
    title.text = "核心功能 (1): 投資組合 DNA"
    
    # Left side: Text
    left_ph = slide.placeholders[1].text_frame
    left_ph.text = """使用者可透過引導式流程，深度客製化個人投資偏好：

- 風險承受度
- 主題權重
- 進階量化篩選
- 投資組合規模"""
    
    # Right side: Image
    right_ph = slide.placeholders[2]
    slide.shapes.add_picture('pic/1.png', right_ph.left, right_ph.top, width=right_ph.width)

    # --- Slide 4: Core Feature - AI Report ---
    slide = prs.slides.add_slide(two_content_layout)
    title.text = "核心功能 (2): AI 分析報告"
    
    # Left side: Image
    left_ph = slide.placeholders[1]
    slide.shapes.add_picture('pic/4.png', left_ph.left, left_ph.top, width=left_ph.width)

    # Right side: Text
    right_ph = slide.placeholders[2].text_frame
    right_ph.text = """AI 生成圖文並茂的分析報告：

- 互動式持股圓餅圖
- 關鍵指標表格
- 投資組合總覽"""

    # --- Slide 5: Architecture Diagram ---
    slide = prs.slides.add_slide(title_and_content_layout)
    title = slide.shapes.title
    title.text = "技術架構總覽"
    # Assuming pic/6.png is the architecture diagram
    img_path = 'pic/6.png'
    slide.shapes.add_picture(img_path, Inches(1), Inches(1.5), width=Inches(8))

    # --- Slide 6 & 7: Future Roadmap ---
    slide = prs.slides.add_slide(title_and_content_layout)
    title.text = "未來藍圖 (1): 非同步與即時更新"
    content = slide.placeholders[1].text_frame
    content.text = """目標：徹底解決 AI 分析時的長等待時間問題。

- 後端重構為非同步背景任務
- 引入 WebSocket 主動推送結果
- 前端實現無須等待的 UI"""

    slide = prs.slides.add_slide(title_and_content_layout)
    title.text = "未來藍圖 (2): 雲端部署與對話式 AI"
    content = slide.placeholders[1].text_frame
    content.text = """目標：將應用推向公開，並賦予 AI 對話能力。

- 容器化 (Docker) 並部署至 GCP Cloud Run
- 實現對話式介面，讓使用者可對報告進行微調"""

    # --- Slide 8: Thank You ---
    slide = prs.slides.add_slide(section_header_layout)
    title = slide.shapes.title
    title.text = """感謝聆聽
Q&A"""
    title.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

    # --- Save Presentation ---
    file_path = "ETF_AI_Advisor_Presentation.pptx"
    prs.save(file_path)
    print(f"\nSUCCESS: Presentation saved to '{file_path}'")

if __name__ == "__main__":
    create_presentation()
