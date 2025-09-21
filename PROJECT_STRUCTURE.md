# Project Structure

This document provides a high-level overview of the folder and file structure for the "ETF Adviser" project. It is maintained by the System Architect and will be updated as the project evolves.

## System Runtime Architecture

A critical aspect of this project's design is its microservice-based approach, which requires two separate server processes to be running simultaneously for the application to be fully functional:

1.  **ChromaDB Server (Python)**: This server acts as our vector database layer. It is launched using the `chroma run` command and is responsible for serving the ETF data from the `chroma_db/` directory over a local network API (typically `http://localhost:8000`).

2.  **Dart Backend Server (Dart)**: This is the core application logic layer, built with Dart Frog. It handles incoming requests from the frontend, queries the ChromaDB server for data, communicates with the OpenAI API, and returns the final analysis.

This separation ensures that our specialized database tasks are handled by the mature and robust Python ecosystem, while our application logic benefits from the performance and scalability of Dart.

## Project Strategy

The project is currently in a transitional phase, migrating from a Python-based implementation (using Streamlit) to a more robust, cross-platform solution using Dart and Flutter.

-   **Legacy Reference (Python)**: The Python files (`app.py`, `core_logic.py`, etc.) are intentionally kept in the repository. They serve as a functional reference and a clear blueprint for the logic being implemented in the new Dart backend.
-   **Active Development (Dart/Flutter)**: The `dart_backend` directory and the upcoming Flutter frontend represent the current and future state of the application.

---

## Root Directory

-   `.env`: **(Untracked)** Contains private environment variables, such as the `OPENAI_API_KEY`.
-   `.env.example`: An example template for the `.env` file.
-   `.gitignore`: Specifies files and folders to be ignored by Git.
-   `run_dev_server.bat`: A wrapper script to launch the Dart Frog development server from the root.
-   `requirements.txt`: Lists the Python dependencies for the legacy reference implementation.

### Legacy Reference (Python)

-   `app.py`: The main entry point for the legacy Streamlit web application.
-   `core_logic.py`: Contains the core RAG (Retrieval-Augmented Generation) logic in Python. This is the primary reference for the Dart backend rewrite.
-   `build_vector_db.py`: A utility script to create and populate the Chroma vector database from the source CSV files.
-   `test_retriever.py`: A script for testing the data retrieval functionality from the ChromaDB.
-   `debug_env.py`: A utility script for debugging Python environment issues.
-   `__pycache__/`: Python's bytecode cache directory.

### Data & Database

-   `etf_list.csv`: A list of the core ETFs to be included in the analysis.
-   `etf_static_data.csv`: Contains static, unchanging data about each ETF.
-   `etf_dynamic_data.json`: Contains dynamic, frequently updated data about each ETF.
-   `chroma_db/`: The directory containing the Chroma vector database files. This is the "knowledge base" for the RAG system.

### Active Development (Dart)

-   `dart_backend/`: The root directory for the new backend server, built with the Dart Frog framework.
    -   `routes/`: Contains the API endpoint definitions.
        -   `index.dart`: The default `/` route.
        -   `recommend.dart`: The core API endpoint (`/recommend`) that implements the RAG logic in Dart.
    -   `pubspec.yaml`: The Dart package manager configuration file, defining project dependencies.
    -   `test/`: Contains tests for the Dart backend.

### Active Development (Flutter)

-   `etf_advisor_frontend/`: The root directory for our new Flutter frontend application.
    -   `lib/main.dart`: The main entry point for the Flutter application, containing the UI and application logic.
    -   `pubspec.yaml`: The Flutter package manager configuration file.

### Project Management & Documentation

-   `README.md`: The main project README file.
-   `task.md`: The high-level project development roadmap and task list.
-   `updatelog.md`: A log of significant code changes and feature additions.
-   `project_log.md`: A narrative log of the development process, challenges, and solutions.
-   `project_summary.md`: A concise summary of the project's goals and status.
-   `PROJECT_STRUCTURE.md`: **(This file)** An overview of the project's file structure.

### Agent Personas

-   `agents/`: Contains the definition files for each AI agent persona involved in the project.
    -   `architect.py`: Defines the System Architect's role and responsibilities.
    -   `...`: Other agent definitions.

---
*This document is actively maintained by the System Architect.*
