@echo off
echo 正在尝试启动Windows Installer服务...
echo.

REM 检查Windows Installer服务是否正在运行
sc queryex msiserver | find "RUNNING">nul
if %errorlevel% equ 0 (
    echo Windows Installer服务已经在运行
	echo.
    pause
    exit
) else (
	REM 尝试启动Windows Installer服务	
    net start msiserver
)

pause