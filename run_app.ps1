# Namma Ooru AI - PowerShell App & Server Launcher
$ErrorActionPreference = "Continue"

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "    NAMMA OORU AI - SERVER & APP LAUNCHER          " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $rootDir

$env:PATH = "C:\Program Files\Git\cmd;F:\flutter\bin;$env:PATH"
$env:PYTHONPATH = "$rootDir\backend"

# 1. Check if backend is already running on port 8000
$portActive = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
if ($portActive) {
    Write-Host "[OK] Backend server is already running on port 8000." -ForegroundColor Green
} else {
    Write-Host "[STARTING] Launching FastAPI Backend Server on port 8000..." -ForegroundColor Yellow
    $pythonExe = "$rootDir\backend\venv\Scripts\python.exe"
    
    Start-Process -FilePath $pythonExe -ArgumentList "-m uvicorn app.main:app --app-dir `"$rootDir\backend`" --host 0.0.0.0 --port 8000" -WorkingDirectory $rootDir -WindowStyle Hidden
    
    # Wait for backend health check
    $healthy = $false
    for ($i = 0; $i -lt 10; $i++) {
        Start-Sleep -Seconds 1
        try {
            $res = Invoke-RestMethod -Uri "http://127.0.0.1:8000/health" -TimeoutSec 1
            if ($res.status -eq "healthy") {
                $healthy = $true
                break
            }
        } catch {}
    }

    if ($healthy) {
        Write-Host "[OK] Backend server is healthy on http://127.0.0.1:8000!" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Backend is taking time to initialize; launching app anyway." -ForegroundColor Yellow
    }
}

# 2. Launch Flutter App
param([string]$device = "chrome")
Write-Host "`n[STARTING] Launching Namma Ooru AI on $device..." -ForegroundColor Cyan
flutter run -d $device
