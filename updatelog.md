# Code Update Log

This document tracks significant changes, feature additions, and bug fixes applied to the project's source code.

---

### **Update: 2025-09-20**
**Author**: Python Programmer
**Files Changed**: `app.py`

**Description**:
-   **Feature**: Implemented a major enhancement to the analysis report.
-   **UI/UX**: Refactored the Streamlit UI for a cleaner layout.

---

### **Update: 2025-09-20**
**Author**: Test Engineer, Python Programmer
**Files Changed**: `app.py`

**Description**:
-   **Bug Fix**: Corrected a critical `SyntaxError`.

---

### **Update: 2025-09-20**
**Author**: Dart Backend Engineer, System Architect
**Files Created/Changed**: `dart_backend/pubspec.yaml`, `dart_backend/routes/recommend.dart`, `run_dev_server.bat`

**Description**:
-   **Architecture Migration**: Initiated Phase 2, rebuilding the backend in Dart.
-   **Environment Setup**: Resolved Android toolchain and Dart CLI path issues.
-   **Backend Implementation**: Re-implemented the RAG logic in Dart.

---

### **Update: 2025-09-20**
**Author**: Project Manager, System Architect
**Files Created/Changed/Deleted**: `agents/project_manager.md`, `project.md` (Created), `project_log.md` (Deleted), `project_summary.md` (Deleted), `README.md`, `PROJECT_STRUCTURE.md`, `run_dev_server.bat` (Deleted), `build_and_start.bat`

**Description**:
-   **Documentation Overhaul**: Streamlined project documentation to five core files.
-   **Architecture Clarification**: Formally documented the two-server runtime architecture.
-   **Tooling & Cleanup**: Finalized the `build_and_start.bat` script.

---

### **Update: 2025-09-21**
**Author**: Entire Agent Team
**Files Created/Changed**: `chroma_v2_api.md` (Created), `dart_backend/routes/recommend.dart`

**Description**:
-   **Root Cause Analysis**: Identified a fundamental API version mismatch (`/api/v1` vs `/api/v2`).
-   **API Discovery & Documentation**: Discovered and documented the correct `/api/v2` URL structure.
-   **Definitive Code Fix**: Updated `recommend.dart` with the correct v2 API URL.

---

### **Update: 2025-09-21 (Late Night Session)**
**Author**: Entire Agent Team
**Files Changed**: `dart_backend/routes/recommend.dart`, `test_retriever.py`

**Description**:
-   **Deep Debugging & Iterative Refinement**: Engaged in a deep debugging session to resolve a series of subsequent v2 API errors.
-   **Key Discoveries & Fixes**: Identified and corrected issues related to UUIDs, collection names, and JSON body structures.

---

### **Update: 2025-09-21 (Stalled)**
**Author**: Project Manager, Entire Agent Team
**Files Changed**: None

**Description**:
-   **Critical Issue**: The project has stalled due to a persistent `Collection [langchain] does not exist` error.
-   **Problem Statement**: The recurring error indicated a fundamental misunderstanding of the interaction between the data persistence mechanism and the server's data loading process.

---

### **Update: 2025-09-21 (Breakthrough)**
**Author**: System Architect, Project Manager, User
**Files Changed**: `build_vector_db.py`, `README.md`, `agents/architect.py`, `agents/project_manager.py`

**Description**:
-   **Definitive Root Cause Identified**: The user correctly identified the absolute root cause of all `Collection not found` errors: the `chroma run` command was being executed from the wrong directory.
-   **Process Correction**: The team established the definitive, correct workflow for database creation and server launch.
-   **Code & Documentation Hardening**:
    -   The `build_vector_db.py` script was hardened to use a client-server model (`HttpClient`).
    -   The `README.md` was updated with the final, correct, step-by-step instructions.
    -   Agent responsibilities were updated to enforce stricter adherence to established procedures.

---

### **Update: 2025-09-21 (Arbitration Test & Final Verdict)**
**Author**: Entire Agent Team
**Files Changed**: `dart_backend/pubspec.yaml`, `dart_backend/routes/recommend.dart`, `agents/dart_backend_engineer.md`, `agents/project_manager.md`

**Description**:
-   **Arbitration Test**: At the user's direction, the team conducted a final, definitive test to arbitrate the viability of the `package:chromadb` Dart client.
-   **Final Verdict**: The test conclusively proved that `package:chromadb` is fundamentally incompatible with the latest version of the ChromaDB server.
-   **Strategic Decision**: Based on this verdict, the team has made the final and permanent decision to abandon the `package:chromadb` client.
-   **Path Forward**: The project will now proceed exclusively with the manual `http` client implementation.

---

### **Update: 2025-09-21 (Final Implementation)**
**Author**: Project Manager, Dart Backend Engineer
**Files Changed**: `dart_backend/pubspec.yaml`, `dart_backend/routes/recommend.dart`

**Description**:
-   **Code Finalization**: Following the arbitration verdict, the `recommend.dart` file and `pubspec.yaml` have been permanently set to the manual `http` client implementation.

---

### **Update: 2025-09-21 (Frontend Integration & CORS)**
**Author**: Flutter UI/UX Engineer, Dart Backend Engineer, Project Manager
**Files Created/Changed**: `etf_advisor_frontend/lib/main.dart`, `etf_advisor_frontend/pubspec.yaml`, `dart_backend/routes/_middleware.dart`

**Description**:
-   **Phase 3 Kick-off**: Officially started the Flutter frontend development phase.
-   **UI Implementation**: Created the initial user interface in Flutter.
-   **Frontend-Backend Integration**: Implemented the `http` call from the Flutter app to the Dart backend.
-   **CORS Resolution**: Successfully diagnosed and resolved a critical CORS preflight request issue by implementing a global middleware in the Dart Frog backend.
-   **SUCCESS**: Achieved a full end-to-end connection from the Flutter frontend to the Dart backend.

---

### **Update: 2025-09-21 (UI/UX Polish & Theming)**
**Author**: Flutter UI/UX Engineer
**Files Changed**: `etf_advisor_frontend/lib/main.dart`, `etf_advisor_frontend/pubspec.yaml`

**Description**:
-   **State Management**: Integrated the `provider` package to manage the application's theme state.
-   **Theming Engine**:
    -   Implemented a robust light/dark mode switching functionality.
    -   Designed and implemented a custom, VS Code-inspired dark theme with a professional color palette (purple, orange, deep grays) and gradient effects.
    -   Refined the light theme with a blue and orange color scheme.
    -   Set the light theme as the default on application startup as per user request.
-   **UI Refinement**:
    -   Removed the "debug" banner.
    -   Increased the size and prominence of titles for better visual hierarchy.
    -   Refined the layout using Cards and a Floating Action Button to create a more polished and modern user experience.
-   **Bug Fix**: Corrected a `CardTheme` vs `CardThemeData` type mismatch error.
-   **Final State**: The Flutter application has reached its initial design and functionality milestone, providing a polished and user-friendly interface for the AI advisor.
---
