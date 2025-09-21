# Project Log & Feature Changelog

This document serves as the official record for the project's major features, historical milestones, and core technical decisions.

---

## 1. Project Summary (as of Python Implementation Completion)

The project's core Python-based functionalities were fully developed and operational. The application successfully integrated a RAG (Retrieval-Augmented Generation) pipeline to provide AI-driven ETF investment advice through a Streamlit web interface. All foundational data, vector databases, and core AI logic were completed, with the primary challenge being local environment setup for end-users.

---

## 2. Feature Changelog

*(This section will be updated only when a core feature is added, modified, or removed.)*

-   **[2025-09-21]**: **Flutter Prototype v1.0 Completed**.
    -   **Feature**: Successfully migrated the entire backend logic to a high-performance Dart server.
    -   **Feature**: Developed a fully functional Flutter frontend that is end-to-end connected to the backend.
    -   **Feature**: Implemented a polished, themeable user interface with both light and dark modes, inspired by professional development tools.
    -   **Modification**: The project has transitioned from a Python-only proof-of-concept to a robust, cross-platform application foundation.
-   **[YYYY-MM-DD]**: Initial project setup.

---

## 3. Project History & Core Technical Deep Dive

This section contains a narrative of the development process, challenges encountered, and detailed explanations of the core technologies implemented.

### 3.1. Initial State & Python Implementation

The project was initially built with a Python stack:
-   **Frontend**: Streamlit (`app.py`) for rapid UI development.
-   **Backend Logic**: A core RAG pipeline (`core_logic.py`).
-   **Database**: ChromaDB (`chroma_db/`) for vector storage and retrieval.
-   **AI Core**: The system dynamically generates investment reports, including asset allocation, based on user-selected themes, powered by OpenAI's GPT-4o model.

### 3.2. Technical Challenge: Environment PATH Resolution

During the initial deployment phase, a significant challenge was the system's inability to locate the `streamlit` executable. This was traced to `pip` installing packages in a user-level `Scripts` directory that was not part of the system's `PATH` environment variable.

**Resolution**:
The user-level `Scripts` path (`C:\Users\xx8897\AppData\Roaming\Python\Python313\Scripts`) was identified using `python -m site` and manually added to the system's `PATH`, resolving the issue for future terminal sessions.

### 3.3. Core Technology Explained: How Asset Allocation is Calculated

A key feature of this project is the dynamic calculation of asset **allocation percentages**. This is not achieved through hard-coded formulas but is delegated to the Large Language Model (LLM).

**RAG Workflow**:
1.  **User Input**: The user selects investment themes (e.g., "High Dividend").
2.  **Retrieval**: The system performs a similarity search in the Chroma vector database to find the most relevant ETF data based on the user's themes.
3.  **Prompt Engineering**: The retrieved data is combined with a carefully crafted prompt that instructs the LLM to act as a professional financial advisor.
4.  **LLM Decision-Making**: The LLM is tasked to:
    -   Select 2-3 of the most suitable ETFs from the provided data.
    -   **Determine the investment allocation for each ETF**, ensuring the total sums to 100%. The LLM simulates expert considerations like risk balancing and thematic relevance.
5.  **Structured Output**: The final analysis is returned in a strict JSON format, ready for frontend rendering.

This entire process is dependent on a valid `OPENAI_API_KEY` being present in the `.env` file.
