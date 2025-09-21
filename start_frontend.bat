@echo off
setlocal

:menu
cls
echo ==================================================
echo      ETF AI Advisor - Flutter Frontend Launcher
echo ==================================================
echo.
echo  Please select a platform to run on:
echo.
echo    1. Chrome (Web)
echo    2. Edge (Web)
echo    3. Windows (Desktop)
echo.
echo ==================================================
echo.

set /p "choice=Enter your choice (1-3) or press Enter for Chrome: "

set DEVICE=chrome
if "%choice%"=="1" set DEVICE=chrome
if "%choice%"=="2" set DEVICE=edge
if "%choice%"=="3" set DEVICE=windows

echo.
echo Changing directory to etf_advisor_frontend...
cd etf_advisor_frontend

echo.
echo Starting Flutter app on '%DEVICE%'...
echo Please wait, this may take a moment...
echo.
flutter run -d %DEVICE%

endlocal