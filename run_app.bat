@echo off
setlocal enabledelayedexpansion

echo ===================================================
echo     NAMMA OORU AI - LAUNCHER
echo ===================================================

cd /d "%~dp0"
set "PATH=C:\Program Files\Git\cmd;F:\flutter\bin;%PATH%"
set "PYTHONPATH=%~dp0backend"

:: Check if backend is already listening on port 8000
netstat -ano | findstr :8000 >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [OK] Backend server is already running on port 8000.
) else (
    echo [STARTING] Launching FastAPI Backend Server on port 8000...
    start "Namma Ooru AI Backend Server" /min "%~dp0backend\venv\Scripts\python.exe" -m uvicorn app.main:app --app-dir "%~dp0backend" --host 0.0.0.0 --port 8000
    
    :: Wait up to 10 seconds for backend to become ready
    echo [WAITING] Waiting for backend health check...
    set count=0
    :wait_loop
    timeout /t 1 /nobreak >nul
    curl -s http://127.0.0.1:8000/health | findstr "healthy" >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo [OK] Backend is healthy and ready on http://127.0.0.1:8000!
        goto start_flutter
    )
    set /a count+=1
    if !count! leq 10 goto wait_loop
    echo [WARNING] Backend startup is taking longer than usual, proceeding to launch app.
)

:start_flutter
echo.
echo [STARTING] Opening Namma Ooru AI Application...
echo Target options:
echo 1. Chrome (Default)
echo 2. Edge
echo 3. Windows Desktop
echo.

if "%1"=="" (
    flutter run -d chrome
) else (
    flutter run -d %1
)
