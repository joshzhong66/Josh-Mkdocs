@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
setlocal

:: 检查参数个数
if "%~1"=="" (
    set /p "ipAddress=请输入要删除凭据的IP地址: "
) else (
    set "ipAddress=%~1"
)

:: 检查是否输入了IP地址
if "%ipAddress%"=="" (
    echo 没有提供IP地址，脚本将退出。
    pause
    exit /b 1
)

:: 使用cmdkey列出凭据并寻找匹配的IP地址
for /f "tokens=1,* delims=: " %%a in ('cmdkey /list ^| findstr /i /c:"%ipAddress%"') do (
    set "credential=%%b"
)

:: 检查是否找到凭据
if not defined credential (
    echo 没有找到与IP地址 %ipAddress% 相关的凭据。
    pause
    exit /b 1
)

:: 删除凭据
cmdkey /delete:%credential%

:: 检查操作结果
if errorlevel 1 (
    echo 删除凭据失败。
    pause
    exit /b 1
) else (
    echo 已成功删除IP地址 %ipAddress% 的凭据。
    pause
    exit /b 0
)