@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Restore InuDev Boot File

set "INUDEV_DIR=C:\Program Files\Inuitive\InuDev"
set "BOOT_DIR=%INUDEV_DIR%\bin\NU4100\boot300"
set "BOOT_FILE=%BOOT_DIR%\cnn_boot_app.bin"
set "BOOT_BACKUP=%BOOT_DIR%\cnn_boot_app.bin_ORIGINAL"

echo ============================================================
echo        Restore Original InuDev cnn_boot_app.bin
echo ============================================================
echo.
echo Use this tool only if the YOLO26 demo ended abnormally and the
echo original boot file was not restored automatically, i.e. you still
echo see cnn_boot_app.bin_ORIGINAL in:
echo   %BOOT_DIR%
echo.

net session >nul 2>&1
if errorlevel 1 (
    echo ERROR: This tool must be run as Administrator.
    echo.
    echo Right-click this batch file and choose:
    echo   Run as administrator
    goto END_FAIL
)

echo Administrator permissions: OK
echo.

if not exist "%BOOT_BACKUP%" (
    if exist "%BOOT_FILE%" (
        echo No backup file found, but cnn_boot_app.bin exists.
        echo Nothing to restore - the system is already in its original state.
        goto END_OK
    ) else (
        echo ERROR: Neither cnn_boot_app.bin nor its backup was found in:
        echo   "%BOOT_DIR%"
        echo The InuDev installation may be damaged - reinstall InuDev.
        goto END_FAIL
    )
)

echo Restoring original boot file...

if exist "%BOOT_FILE%" (
    del /F /Q "%BOOT_FILE%" >nul 2>&1
)

ren "%BOOT_BACKUP%" "cnn_boot_app.bin"
if errorlevel 1 (
    echo ERROR: Failed to restore original cnn_boot_app.bin.
    echo Close any program that may lock the file and try again.
    goto END_FAIL
)

echo Original boot file restored.
echo.

echo Restarting InuService...
net stop InuService >nul 2>&1
taskkill /F /IM InuService.exe >nul 2>&1
timeout /t 5 /nobreak >nul
net start InuService >nul 2>&1
timeout /t 5 /nobreak >nul

sc query InuService | findstr /I "RUNNING" >nul
if errorlevel 1 (
    echo ERROR: InuService is not running.
    echo Try starting it manually:
    echo   net start InuService
    goto END_FAIL
)

echo InuService is running.
goto END_OK


:END_FAIL
echo.
echo ============================================================
echo FAILED. Please send this terminal text/screenshot for support.
echo ============================================================
echo.
echo Press any key to close this window...
pause >nul
exit /b 1


:END_OK
echo.
echo ============================================================
echo Done. Original InuDev boot file is in place.
echo ============================================================
echo.
echo Press any key to close this window...
pause >nul
exit /b 0
