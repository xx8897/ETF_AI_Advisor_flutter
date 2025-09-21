@echo off
echo ==================================================
echo      Building Chroma Vector Database...
echo ==================================================
echo.
echo This script will process the Excel files in 'scripts/data'
echo and build a new vector database in 'chroma_db'.
echo.
echo Make sure your ChromaDB server is running in a separate terminal
echo using the command: chroma run --path chroma_db
echo.
echo Press any key to start the build process...
pause > nul

echo.
echo Starting Python script...
echo.

python scripts/build_vector_db.py

echo.
echo ==================================================
echo      Database build process finished.
echo ==================================================
echo.
echo Please review the output above for any errors.
echo Press any key to exit.
pause > nul
