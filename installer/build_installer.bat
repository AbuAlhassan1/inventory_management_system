@echo off
REM Batch script to build Flutter app and create installer automatically

echo ========================================
echo LIPS Installer Builder
echo ========================================
echo.

echo Step 1: Cleaning previous builds...
call flutter clean
echo.

echo Step 2: Getting dependencies...
call flutter pub get
echo.

echo Step 3: Building Windows release...
call flutter build windows --release
if %errorlevel% neq 0 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)
echo.

echo Step 4: Creating installer...
set INNO_PATH="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist %INNO_PATH% (
    set INNO_PATH="C:\Program Files\Inno Setup 6\ISCC.exe"
)
if not exist %INNO_PATH% (
    echo.
    echo WARNING: Inno Setup not found at default locations.
    echo Please install Inno Setup from: https://jrsoftware.org/isinfo.php
    echo Or manually compile installer\lips_installer.iss using Inno Setup Compiler.
    echo.
    pause
    exit /b 1
)

if not exist %INNO_PATH% (
    echo ERROR: Inno Setup not found!
    echo Please install Inno Setup from: https://jrsoftware.org/isinfo.php
    echo Or update the INNO_PATH in this script.
    pause
    exit /b 1
)

%INNO_PATH% installer\lips_installer.iss
if %errorlevel% neq 0 (
    echo ERROR: Installer creation failed!
    pause
    exit /b 1
)
echo.

echo ========================================
echo SUCCESS!
echo ========================================
echo Installer created at: installer\output\LIPS_Setup_0.1.0.exe
echo.
pause
