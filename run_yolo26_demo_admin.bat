@echo off
setlocal EnableExtensions EnableDelayedExpansion

title YOLO26 Demo Launcher

set "PKG_DIR=%~dp0"
cd /d "%PKG_DIR%"

set "INUDEV_DIR=C:\Program Files\Inuitive\InuDev"
set "INUDEV_BIN=%INUDEV_DIR%\bin"
set "VCS_FILE=%INUDEV_DIR%\config\vcs_x64.txt"
set "CNN_PACKAGE_DIR=%INUDEV_DIR%\config\AI4100\cnn_bins"
set "BOOT_DIR=%INUDEV_DIR%\bin\NU4100\boot300"
set "BOOT_FILE=%BOOT_DIR%\cnn_boot_app.bin"
set "BOOT_BACKUP=%BOOT_DIR%\cnn_boot_app.bin_ORIGINAL"
set "DEMO_BOOT=%PKG_DIR%YOLO_NETS\cnn_boot_app.bin"
set "DEMO_EXE=%PKG_DIR%example_yolo26.exe"

set "BOOT_REPLACED=0"

echo ============================================================
echo              YOLO26 Demo Launcher  (NU4100)
echo ============================================================
echo.
echo Please run this batch file as Administrator.
echo.

net session >nul 2>&1
if errorlevel 1 (
    echo ERROR: This launcher must be run as Administrator.
    echo.
    echo Right-click this batch file and choose:
    echo   Run as administrator
    goto END_FAIL
)

echo Administrator permissions: OK
echo.

echo Checking package files...
call :CHECK_FILE "example_yolo26.exe" || goto END_FAIL
call :CHECK_FILE "opencv_world480.dll" || goto END_FAIL
call :CHECK_FILE "opencv_videoio_ffmpeg480_64.dll" || goto END_FAIL
call :CHECK_FILE "sw_graph_boot10311.xml" || goto END_FAIL
call :CHECK_FILE "demo_video.mp4" || goto END_FAIL
call :CHECK_FILE "demo_video_seg.mp4" || goto END_FAIL
call :CHECK_FILE "demo_pose.mp4" || goto END_FAIL
call :CHECK_FILE "demo_hand_pose.mp4" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\labels_80.txt" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\pose_labels_1.txt" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\palm_labels.txt" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\depth_labels.txt" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\nn_bin_yolov26_320.bin" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\nn_bin_yolov26_640.bin" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\nn_bin_yolov26n_320.bin" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\nn_bin_yolov26n_640.bin" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\nn_bin_yolov26n_seg.bin" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\nn_bin_yolov26n_pose.bin" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\nn_bin_yolov26n_palm.bin" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\nn_bin_yolov26n_depth.bin" || goto END_FAIL
call :CHECK_FILE "YOLO_NETS\cnn_boot_app.bin" || goto END_FAIL

echo Package files: OK
echo.

if not exist "%INUDEV_BIN%\InuStreams.dll" (
    echo ERROR: InuStreams.dll was not found.
    echo Expected location:
    echo   "%INUDEV_BIN%\InuStreams.dll"
    echo Please install the Inuitive InuDev SDK first.
    goto END_FAIL
)

set "PATH=%INUDEV_BIN%;%PATH%"

if not exist "%VCS_FILE%" (
    echo ERROR: InuDev version file not found:
    echo   "%VCS_FILE%"
    goto END_FAIL
)

set "INU_VERSION="
for /f "tokens=2 delims=/" %%V in ('findstr /R /C:"InuSpector/[0-9]" "%VCS_FILE%"') do (
    set "INU_VERSION=%%V"
)

if "%INU_VERSION%"=="" (
    echo WARNING: InuDev was found, but its version could not be detected.
) else (
    echo InuDev found, version: %INU_VERSION%
    echo %INU_VERSION% | findstr /B "4.39" >nul
    if errorlevel 1 (
        echo.
        echo WARNING: This demo was created and tested with InuDev version 4.39.
        echo The detected version is %INU_VERSION%.
        echo The demo may still work, but compatibility is not guaranteed.
        echo Some features may fail or work only partially.
    )
)

echo.

if not exist "%CNN_PACKAGE_DIR%" (
    echo WARNING: CNN package folder was not found:
    echo   "%CNN_PACKAGE_DIR%"
    echo The demo loads its networks from YOLO_NETS and usually works
    echo without it. Continuing anyway...
    echo.
)

if not exist "%BOOT_FILE%" (
    if exist "%BOOT_BACKUP%" (
        echo Found a leftover backup from a previous demo run.
        echo Restoring original boot file first...
        call :RESTORE_ORIGINAL
        if errorlevel 1 goto END_FAIL
    ) else (
        echo ERROR: Original cnn_boot_app.bin was not found:
        echo   "%BOOT_FILE%"
        goto END_FAIL
    )
)

if exist "%BOOT_BACKUP%" (
    echo WARNING: Previous backup file already exists.
    echo Restoring original boot file before starting...
    call :RESTORE_ORIGINAL
    if errorlevel 1 goto END_FAIL
)

if not exist "%BOOT_FILE%" (
    echo ERROR: Original cnn_boot_app.bin was not found:
    echo   "%BOOT_FILE%"
    goto END_FAIL
)

echo Backing up original cnn_boot_app.bin...
ren "%BOOT_FILE%" "cnn_boot_app.bin_ORIGINAL"
if errorlevel 1 (
    echo ERROR: Failed to backup original cnn_boot_app.bin.
    goto END_FAIL
)

echo Copying demo cnn_boot_app.bin...
copy /Y "%DEMO_BOOT%" "%BOOT_FILE%" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy demo cnn_boot_app.bin.
    call :RESTORE_ORIGINAL
    goto END_FAIL
)

set "BOOT_REPLACED=1"
echo Boot file replaced successfully.
echo.

call :RESTART_SERVICE
if errorlevel 1 (
    echo ERROR: InuService restart failed after boot replacement.
    call :RESTORE_ORIGINAL
    goto END_FAIL
)

echo.
echo ============================================================
echo Starting YOLO26 demo session...
echo.
echo Menu: 1-8 live camera, 9-16 video-inject.
echo Click the video window once so it receives keyboard input.
echo.
echo Switch demo: press Q or ESC in the video window - the demo
echo app exits and this launcher returns you to its menu, so you
echo can pick another example right away.
echo End session : press Q or ESC in the demo, then Q here.
echo ============================================================
echo.

:DEMO_LOOP
"%DEMO_EXE%"

echo.
echo Demo app exited. Boot file stays replaced during the session.
choice /C CQ /N /M "Press C for another demo, Q to finish and restore: "
if errorlevel 2 goto DEMO_DONE
timeout /t 2 /nobreak >nul
goto DEMO_LOOP

:DEMO_DONE
echo.
echo Finishing demo session.
echo Restoring original cnn_boot_app.bin...
call :RESTORE_ORIGINAL
if errorlevel 1 (
    echo.
    echo ERROR: Failed to restore the original boot file.
    echo Run restore_boot_admin.bat to fix this manually.
    goto END_FAIL
)

call :RESTART_SERVICE
if errorlevel 1 (
    echo ERROR: InuService restart failed after restoring original boot file.
    echo Run restore_boot_admin.bat and try again.
    goto END_FAIL
)

echo.
echo ============================================================
echo Demo completed. Original InuDev boot file restored.
echo ============================================================
goto END_OK


:CHECK_FILE
if not exist "%~1" (
    echo ERROR: Missing required file:
    echo   %~1
    exit /b 1
)
exit /b 0


:RESTORE_ORIGINAL
echo Restoring original boot file...

if exist "%BOOT_FILE%" (
    del /F /Q "%BOOT_FILE%" >nul 2>&1
)

if not exist "%BOOT_BACKUP%" (
    echo ERROR: Backup file not found:
    echo   "%BOOT_BACKUP%"
    exit /b 1
)

ren "%BOOT_BACKUP%" "cnn_boot_app.bin"
if errorlevel 1 (
    echo ERROR: Failed to restore original cnn_boot_app.bin.
    exit /b 1
)

set "BOOT_REPLACED=0"
echo Original boot file restored.
exit /b 0


:RESTART_SERVICE
echo.
echo Restarting InuService...

net stop InuService >nul 2>&1
if errorlevel 1 (
    echo NET STOP did not report success. Trying taskkill...
    taskkill /F /IM InuService.exe >nul 2>&1
)

timeout /t 5 /nobreak >nul

net start InuService >nul 2>&1
if errorlevel 1 (
    echo NET START did not report success. Trying manual start...
    start "" "%INUDEV_DIR%\bin\InuService.exe"
)

timeout /t 5 /nobreak >nul

sc query InuService | findstr /I "RUNNING" >nul
if errorlevel 1 (
    echo ERROR: InuService is not running.
    echo Make sure the InuDev SDK is installed and try starting it manually:
    echo   net start InuService
    exit /b 1
)

echo InuService is running.
exit /b 0


:END_FAIL
echo.
echo ============================================================
echo FAILED. Please send this terminal text/screenshot for support.
echo If you ever see "cnn_boot_app.bin_ORIGINAL" left in
echo %BOOT_DIR%
echo run restore_boot_admin.bat from this folder to recover.
echo ============================================================
echo.
echo Press any key to close this window...
pause >nul
exit /b 1


:END_OK
echo.
echo Press any key to close this window...
pause >nul
exit /b 0
