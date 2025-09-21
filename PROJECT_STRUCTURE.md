# Project Structure

This document provides a high-level overview of the folder and file structure for the "ETF AI Advisor" project. It is maintained by the System Architect.

## System Runtime Architecture

The project uses a microservice-based approach, requiring two separate server processes to run simultaneously for full functionality:

1.  **ChromaDB Server (Python)**: This server acts as our vector database layer. It is launched using the `chroma run` command and serves the ETF data from the `chroma_db/` directory over a local network API (typically `http://localhost:8000`).

2.  **Dart Backend Server (Dart)**: This is the core application logic layer, built with Dart Frog. It handles incoming requests from the frontend, queries the ChromaDB server for data, communicates with the OpenAI API, and returns the final analysis.

---

## Root Directory

-   `.env`: **(Untracked)** Contains private environment variables, such as the `OPENAI_API_KEY`.
-   `.env.example`: An example template for the `.env` file.
-   `.gitignore`: Specifies files and folders to be ignored by Git.
-   `requirements.txt`: Lists the Python dependencies required for the data processing scripts.
-   `build_db.bat`: A utility script to build the vector database from the source Excel file.
-   `build_and_start.bat`: A utility script to build and start the Dart backend server.
-   `start_frontend.bat`: A utility script to launch the Flutter frontend.
-   `chroma_db/`: The directory containing the Chroma vector database files. This is the "knowledge base" for the RAG system.

### Core Application

-   `dart_backend/`: The root directory for the backend server.
-   `etf_advisor_frontend/`: The root directory for our Flutter frontend application.

### Python Scripts & Data

-   `scripts/`: Contains all Python utility scripts.
    -   `build_vector_db.py`: Creates and populates the Chroma vector database from the source data.
    -   `test_retriever.py`: A utility to test data retrieval from ChromaDB.
    -   `debug_env.py`: Helps in debugging the Python environment.
    -   `data/`: Contains the source data file.
        -   `etf.xlsx`: **(Single Source of Truth)** The consolidated Excel file containing all ETF attributes, factors, and holdings data.

### Project Management & Documentation

-   `README.md`: The main project README file.
-   `task.md`: The high-level project development roadmap.
-   `updatelog.md`: A log of significant code changes.
-   `project.md`: The official feature changelog.
-   `PROJECT_STRUCTURE.md`: **(This file)** An overview of the project's file structure.

### Agent Personas

-   `agents/`: Contains the definition files for each AI agent persona.

---
*This document is actively maintained by the System Architect.*