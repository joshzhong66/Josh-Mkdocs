@echo off
chcp 65001
setlocal

:: 检查参数个数
if "%~1"=="" (
    echo 请提供要删除凭据的IP地址。
    exit /b 1
)

:: 设置IP地址变量
set "ipAddress=%~1"

:: 使用cmdkey列出凭据并寻找匹配的IP地址
for /f "tokens=1,* delims=: " %%a in ('cmdkey /list ^| findstr /i /c:"%ipAddress%"') do (
    set "credential=%%b"
)

:: 检查是否找到凭据
if not defined credential (
    echo 没有找到与IP地址 %ipAddress% 相关的凭据。
    exit /b 1
)

:: 删除凭据
cmdkey /delete:%credential%

:: 检查操作结果
if errorlevel 1 (
    echo 删除凭据失败。
    exit /b 1
) else (
    echo 已成功删除IP地址 %ipAddress% 的凭据。
    exit /b 0
)