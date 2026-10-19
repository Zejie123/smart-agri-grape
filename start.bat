@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

REM ================= 可配置项 =================
REM 后端 jar（不存在时自动构建）
set "JAR=target\smart-agri-grape-0.0.1-SNAPSHOT.jar"
REM nginx 安装目录（按本机实际路径修改）
set "NGINX_DIR=D:\develop\nginx-1.22.0-web\nginx-1.22.0-web"
REM 前端访问地址
set "APP_URL=http://localhost/"
REM =============================================

echo ============================================
echo   Smart Agriculture Platform - Launcher
echo ============================================

REM ---- 1. 检查 java ----
where java >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Java not found. Install JDK 8+ and add to PATH.
    pause
    exit /b 1
)

REM ---- 2. 后端 jar 不存在则构建 ----
if not exist "%JAR%" (
    echo [INFO] Backend jar not found, building...
    where mvn >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] Maven not found in PATH.
        pause
        exit /b 1
    )
    call mvn -q clean package -DskipTests
    if errorlevel 1 (
        echo [ERROR] Backend build failed.
        pause
        exit /b 1
    )
)

REM ---- 3. 前端 dist 不存在则构建 ----
if not exist "frontend\dist\index.html" (
    echo [INFO] Frontend dist not found, building...
    pushd frontend
    call npm install
    call npm run build
    popd
    if errorlevel 1 (
        echo [ERROR] Frontend build failed.
        pause
        exit /b 1
    )
)

REM ---- 4. 检查 nginx ----
if not exist "%NGINX_DIR%\nginx.exe" (
    echo [ERROR] nginx not found at:
    echo        %NGINX_DIR%\nginx.exe
    echo        Please edit NGINX_DIR in start.bat.
    pause
    exit /b 1
)

REM ---- 5. 应用 nginx 配置 ----
copy /y "nginx.conf" "%NGINX_DIR%\conf\nginx.conf" >nul

REM ---- 6. 停止已有实例（避免端口占用）----
taskkill /f /im nginx.exe >nul 2>nul
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8080" ^| findstr "LISTENING"') do (
    taskkill /f /pid %%a >nul 2>nul
)

REM ---- 7. 启动后端 ----
echo [INFO] Starting backend  http://localhost:8080/api ...
start "SmartAgri Backend" java -jar "%JAR%"

REM ---- 8. 启动 nginx ----
echo [INFO] Starting nginx  (frontend at http://localhost/) ...
start "SmartAgri Nginx" /d "%NGINX_DIR%" "%NGINX_DIR%\nginx.exe"

REM ---- 9. 等待并打开浏览器 ----
echo [INFO] Waiting for services to start...
ping -n 13 127.0.0.1 >nul
start "" "%APP_URL%"

echo.
echo ============================================
echo   Backend  : http://localhost:8080/api
echo   Frontend : http://localhost/
echo   Stop     : double-click stop.bat
echo ============================================
echo.
pause
