@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 正在检查Windows系统激活时间...
echo.
cscript //nologo C:\Windows\System32\slmgr.vbs /xpr

pause