@echo off
setlocal
:retry
"C:\Users\Tawan\AppData\Local\Android\Sdk\platform-tools\adb.exe" -s 5QCUN25821G08229 reverse tcp:5000 tcp:5000 >nul 2>&1
timeout /t 5 /nobreak >nul
goto retry

