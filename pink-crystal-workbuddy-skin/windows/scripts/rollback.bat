@echo off
setlocal enabledelayedexpansion
title Pink Crystal WorkBuddy Theme Rollback

echo =============================================
echo  Pink Crystal WorkBuddy Theme Rollback
echo =============================================
echo.

REM ---- Locate WorkBuddy ----
if defined WB_PATH (
    if not exist "%WB_PATH%\WorkBuddy.exe" (
        echo [FAIL] WB_PATH set but WorkBuddy.exe not found: %WB_PATH%
        pause & exit /b 1
    )
    goto :found_wb_rb
)
set "WB_PATH="
if exist "%LOCALAPPDATA%\Programs\WorkBuddy\WorkBuddy.exe" (
    set "WB_PATH=%LOCALAPPDATA%\Programs\WorkBuddy"
) else if exist "%ProgramFiles%\WorkBuddy\WorkBuddy.exe" (
    set "WB_PATH=%ProgramFiles%\WorkBuddy"
) else if exist "D:\Program Files\WorkBuddy\WorkBuddy.exe" (
    set "WB_PATH=D:\Program Files\WorkBuddy"
) else (
    echo [FAIL] WorkBuddy installation not found.
    echo        If installed elsewhere, set WB_PATH manually before running.
    pause & exit /b 1
)
:found_wb_rb
set "ASAR=%WB_PATH%\resources\app.asar"

REM ---- Find latest backup ----
set "BAK="
for /f "delims=" %%i in ('dir /b /o-d "%USERPROFILE%\WorkBuddy\App_app.asar.bak.*" 2^>nul') do (
    if not defined BAK set "BAK=%USERPROFILE%\WorkBuddy\%%i"
)
if "%BAK%"=="" (
    echo [FAIL] No backup found: %%USERPROFILE%%\WorkBuddy\App_app.asar.bak.*
    echo        Run the installer first to create a backup.
    pause & exit /b 1
)
echo Restoring: %BAK%

REM ---- Kill WorkBuddy ----
taskkill /IM WorkBuddy.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

REM ---- Replace ----
copy /y "%BAK%" "%ASAR%" >nul
if errorlevel 1 (
    echo [FAIL] Restore failed. WorkBuddy may still be running.
    echo        Close WorkBuddy and retry.
    pause & exit /b 1
)

REM ---- Restart ----
echo.
echo Starting WorkBuddy...
start "" "%WB_PATH%\WorkBuddy.exe"

echo.
echo [OK] Theme rolled back to default.
echo.
pause
