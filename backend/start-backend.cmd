@echo off
setlocal
cd /d "%~dp0"
:restart
node src/server.js >> "%~dp0backend-runtime.log" 2>>&1
timeout /t 5 /nobreak >nul
goto restart

