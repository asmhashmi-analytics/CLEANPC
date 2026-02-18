@echo off
title CLEANPC - Windows Governance Engine

REM ============================================
REM  CLEANPC.cmd - Double-click launcher
REM ============================================

REM Get the directory of this script
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Check for PowerShell
where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo PowerShell not found. CLEANPC requires Windows PowerShell.
    echo.
    pause
    exit /b 1
)

REM Check if running as Administrator
whoami /groups | find "S-1-5-32-544" >nul 2>&1
if errorlevel 1 (
    echo CLEANPC needs to run as Administrator.
    echo Requesting elevation...
    echo.

    powershell -NoProfile -Command ^
        "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"

    exit /b
)

REM Launch CLEANPC.ps1 with ExecutionPolicy bypass
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%CLEANPC.ps1"

echo.
echo CLEANPC has finished. You may close this window.
echo.
pause
