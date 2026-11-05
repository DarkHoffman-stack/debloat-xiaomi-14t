@echo off
REM debloat - from this device's debloat list, one pm call per package
REM requires: adb in PATH (https://developer.android.com/tools/releases/platform-tools)
setlocal enabledelayedexpansion
set /p DEV="Device (IP:PORT for network adb, or USB serial): "
echo.
echo === debloat on %DEV% ===
for /f "usebackq eol=# tokens=1 delims= " %%P in ("debloat.txt") do (
  echo - %%P
  if "debloat"=="debloat" (
    adb -s %DEV% shell "pm disable-user --user 0 %%P" >nul 2>&1
    if errorlevel 1 adb -s %DEV% shell "pm uninstall -k --user 0 %%P"
  ) else (
    adb -s %DEV% shell "pm install-existing %%P" >nul 2>&1
    if errorlevel 1 adb -s %DEV% shell "pm enable --user 0 %%P"
  )
)
echo.
echo Done. Press any key to close.
pause >nul
