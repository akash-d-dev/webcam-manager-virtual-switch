@echo off
title Camera Toggle

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as administrator, checking camera status...
    goto :check_status
) else (
    echo Requesting administrator privileges...
    goto :elevate
)

:elevate
:: Create a temporary VBS script to handle UAC elevation
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\elevate_toggle_camera.vbs"
echo UAC.ShellExecute "%~f0", "", "", "runas", 1 >> "%temp%\elevate_toggle_camera.vbs"
echo WScript.Quit >> "%temp%\elevate_toggle_camera.vbs"

:: Run the VBS script to elevate privileges
cscript //nologo "%temp%\elevate_toggle_camera.vbs"

:: Clean up the temporary VBS script
del "%temp%\elevate_toggle_camera.vbs"

:: Exit if user cancelled UAC prompt
if %errorLevel% == 5 (
    echo Administrator privileges were denied.
    pause
    exit /b 1
)

:: Exit this instance since we'll be running elevated
exit /b

:check_status
:: Now running as administrator, check camera status
echo Checking camera status...
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0scripts\check_camera_status.ps1"
set camera_status=%errorLevel%

echo.
if %camera_status% == 0 (
    echo Cameras are currently ENABLED - Disabling them...
    powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0scripts\disable_camera.ps1"
) else if %camera_status% == 1 (
    echo Cameras are currently DISABLED - Enabling them...
    powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0scripts\enable_camera.ps1"
) else if %camera_status% == 2 (
    echo No camera devices found on the system.
) else (
    echo An error occurred while checking camera status.
)

echo.
echo Camera toggle operation completed.
pause 