@echo off
setlocal

echo [INFO] Stopping backend (port 8080)...
set "FOUND="
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8080" ^| findstr "LISTENING"') do (
    set "FOUND=1"
    taskkill /f /pid %%a >nul 2>nul
)

echo [INFO] Stopping nginx...
taskkill /f /im nginx.exe >nul 2>nul

if not defined FOUND (
    echo [INFO] No backend running on port 8080.
)

echo [INFO] Done.
pause
