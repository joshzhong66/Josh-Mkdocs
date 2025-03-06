@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
setlocal enabledelayedexpansion

echo 正在尝试启动Windows Installer服务...
echo.

REM 检查Windows Installer服务是否正在运行
sc queryex msiserver | find "RUNNING">nul

if !errorlevel! equ 0 (
    echo Windows Installer服务已经在运行
	echo.
    pause
    exit /b 0
) else (
	REM 尝试启动Windows Installer服务	
	echo 尝试启动Windows Installer服务...
	echo.
	
    net start msiserver >nul

	if !errorlevel! equ 0 (
	    echo Windows Installer服务启动成功
	) else (
		echo 无法启动Windows Installer服务
	)
	
	pause
    exit /b 0
)