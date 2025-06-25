@echo off
title Camera Manager

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as administrator, launching camera manager...
    goto :launch
) else (
    echo Requesting administrator privileges...
    goto :elevate
)

:elevate
:: Create a temporary VBS script to handle UAC elevation
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\elevate_camera_manager.vbs"
echo UAC.ShellExecute "%~f0", "", "", "runas", 1 >> "%temp%\elevate_camera_manager.vbs"
echo WScript.Quit >> "%temp%\elevate_camera_manager.vbs"

:: Run the VBS script to elevate privileges
cscript //nologo "%temp%\elevate_camera_manager.vbs"

:: Clean up the temporary VBS script
del "%temp%\elevate_camera_manager.vbs"

:: Exit if user cancelled UAC prompt
if %errorLevel% == 5 (
    echo Administrator privileges were denied.
    pause
    exit /b 1
)

:: Exit this instance since we'll be running elevated
exit /b

:launch
:: Now running as administrator, launch the camera manager
echo Starting Camera Manager...
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0scripts\camera_manager.ps1"

:: Keep window open if there was an error
if %errorLevel% neq 0 (
    echo.
    echo Camera Manager exited with error code: %errorLevel%
    pause
) 