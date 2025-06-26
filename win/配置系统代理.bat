@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 检查是否以管理员身份运行
openfiles >nul 2>nul || (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c ""%~f0""' -Verb RunAs"
    exit /b
)

:main
set /p userChoice="输入1启动代理，输入2关闭代理: "

if "%userChoice%"=="1" goto enableProxy
if "%userChoice%"=="2" goto disableProxy
goto main

:enableProxy
REM 设置服务器地址和端口
set "proxyServer=10.22.51.64:20171"

REM 启用服务器
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >nul

REM 设置服务器地址和端口
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "%proxyServer%" /f >nul

REM 刷新设置
netsh winhttp import proxy source=ie >nul

echo.
echo 代理已修改为：%proxyServer%

goto end

:disableProxy
REM 关闭服务器
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul

REM 刷新设置
netsh winhttp reset proxy >nul

echo.
echo 已关闭代理。

:end
pause
exit /b 0