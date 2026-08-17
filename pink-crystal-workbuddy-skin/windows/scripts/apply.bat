@echo off
setlocal enabledelayedexpansion
title Pink Crystal WorkBuddy Theme Installer (Windows)
chcp 65001 >nul 2>&1

echo =============================================
echo  Pink Crystal WorkBuddy Theme Installer
echo  (asar inline CSS injection - Windows)
echo =============================================
echo.

REM ---- Mode: dynamic (default) / static ----
set "MODE=dynamic"
if /i "%~1"=="static"  set "MODE=static"
if /i "%~1"=="dynamic" set "MODE=dynamic"
echo Mode: %MODE%

REM ---- Locate WorkBuddy (Electron app under resources\app.asar) ----
REM Use WB_PATH env var first; otherwise check common install paths
if defined WB_PATH (
    if not exist "%WB_PATH%\WorkBuddy.exe" (
        echo [FAIL] WB_PATH set but WorkBuddy.exe not found: %WB_PATH%
        pause & exit /b 1
    )
    goto :found_wb
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
    echo        Checked: %%LOCALAPPDATA%%\Programs\WorkBuddy
    echo                %%ProgramFiles%%\WorkBuddy
    echo                D:\Program Files\WorkBuddy
    echo        If installed elsewhere, set WB_PATH manually before running:
    echo        set "WB_PATH=X:\your\path\WorkBuddy"
    pause & exit /b 1
)
:found_wb
set "ASAR=%WB_PATH%\resources\app.asar"
echo Found: %WB_PATH%\WorkBuddy.exe

REM ---- Locate skin.css (mode-based) ----
set "SKIN_CSS=%~dp0..\..\assets\%MODE%\skin.css"
if not exist "%SKIN_CSS%" (
    echo [FAIL] skin.css not found: %SKIN_CSS%
    pause & exit /b 1
)

REM ---- Locate inject.js (sibling of this script) ----
set "INJECT_JS=%~dp0inject.js"
if not exist "%INJECT_JS%" (
    echo [FAIL] inject.js not found: %INJECT_JS%
    pause & exit /b 1
)

REM ---- Locate Node.js (REQUIRED) ----
where node >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Node.js not found in PATH.
    echo        Download and install from https://nodejs.org ^(LTS^).
    echo        After install, reopen this command prompt and retry.
    pause & exit /b 1
)
for /f "delims=" %%i in ('where node') do set "NODE=%%i"
echo node = %NODE%

REM ---- Locate asar CLI (prefer local, then global, then npx) ----
set "ASAR_CMD="
if exist "%~dp0..\..\node_modules\.bin\asar" (
    set "ASAR_CMD=%~dp0..\..\node_modules\.bin\asar"
) else (
    where asar >nul 2>&1
    if not errorlevel 1 (
        for /f "delims=" %%i in ('where asar') do set "ASAR_CMD=%%i"
    )
)
if defined ASAR_CMD (
    echo asar = %ASAR_CMD%
) else (
    echo asar = npx --yes @electron/asar  ^(will fetch on first run; needs internet^)
    set "ASAR_CMD=npx --yes @electron/asar"
)
echo.

REM ---- Temp workspace ----
set "WORK=%TEMP%\wb_pink_%RANDOM%"
if exist "%WORK%" rmdir /s /q "%WORK%" >nul 2>&1
mkdir "%WORK%"

REM ---- [1/6] Extract ----
echo [1/6] Extracting app.asar...
%ASAR_CMD% extract "%ASAR%" "%WORK%"
if errorlevel 1 (
    echo [FAIL] Extract failed. If offline, install asar once: npm install -g @electron/asar
    rmdir /s /q "%WORK%" >nul 2>&1
    pause & exit /b 1
)

REM ---- [2/6] Find main CSS ----
for %%f in ("%WORK%\renderer\assets\index-*.css") do set "MAIN=%%f"
if not defined MAIN (
    echo [FAIL] Main stylesheet not found in renderer\assets\
    rmdir /s /q "%WORK%" >nul 2>&1
    pause & exit /b 1
)
echo Main CSS: %MAIN%

REM ---- [3/6] Strip previous skin + Inject new skin (via inject.js) ----
echo [2/6] Injecting %MODE% skin CSS (idempotent strip + inject)...
node "%INJECT_JS%" "%MAIN%" "%SKIN_CSS%" "%WORK%\renderer\index.html"
if errorlevel 1 (
    echo [FAIL] Injection failed.
    rmdir /s /q "%WORK%" >nul 2>&1
    pause & exit /b 1
)

REM ---- [4/6] Verify injection ----
findstr /c:"WORKBUDDY_SKIN" "%MAIN%" >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Skin injection verification failed.
    rmdir /s /q "%WORK%" >nul 2>&1
    pause & exit /b 1
)

REM ---- [5/6] Repack (size increase is normal due to base64 background) ----
echo [3/6] Repacking asar...
%ASAR_CMD% pack "%WORK%" "%TEMP%\new_app.asar"
if errorlevel 1 (
    echo [FAIL] Repack failed.
    rmdir /s /q "%WORK%" >nul 2>&1
    pause & exit /b 1
)

REM ---- Stop WorkBuddy ----
echo [4/6] Stopping WorkBuddy...
taskkill /IM WorkBuddy.exe /F >nul 2>&1
timeout /t 3 /nobreak >nul

REM ---- Backup original (timestamped, under user profile only) ----
if not exist "%USERPROFILE%\WorkBuddy" mkdir "%USERPROFILE%\WorkBuddy"
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "D=%%c%%a%%b"
for /f "tokens=1-2 delims=:." %%a in ('echo %time: =0%') do set "T=%%a%%b"
set "BAK=%USERPROFILE%\WorkBuddy\App_app.asar.bak.%D%_%T%"
copy /y "%ASAR%" "%BAK%" >nul
if errorlevel 1 (
    echo [FAIL] Backup failed: %BAK%
    rmdir /s /q "%WORK%" >nul 2>&1
    pause & exit /b 1
)
echo        Backup: %BAK%

REM ---- Replace ----
echo [5/6] Replacing app.asar...
copy /y "%TEMP%\new_app.asar" "%ASAR%" >nul
if errorlevel 1 (
    echo [FAIL] Replace failed. Restoring backup...
    copy /y "%BAK%" "%ASAR%" >nul
    rmdir /s /q "%WORK%" >nul 2>&1
    pause & exit /b 1
)

REM ---- Cleanup ----
rmdir /s /q "%WORK%" >nul 2>&1

REM ---- NOTE: Windows build needs NO codesign / xattr (unlike macOS) ----

REM ---- Restart ----
echo [6/6] Starting WorkBuddy...
start "" "%WB_PATH%\WorkBuddy.exe"

echo.
echo =============================================
echo  [OK] Pink Crystal %MODE% theme applied.
echo  Rollback: %BAK%
echo  ^(Run windows\scripts\rollback.bat to restore^)
echo =============================================
echo.
pause
