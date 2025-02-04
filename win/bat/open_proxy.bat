@echo off
chcp 65001
set /p userChoice="输入1启动代理，输入2关闭代理: "

if "%userChoice%"=="1" goto enableProxy
if "%userChoice%"=="2" goto disableProxy
goto eof

:enableProxy
REM 设置服务器地址和端口
set "proxyServer=10.22.51.64:7890"

REM 启用服务器
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f

REM 设置服务器地址和端口
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "%proxyServer%" /f

REM 刷新设置
netsh winhttp import proxy source=ie

echo 代理已修改为：%proxyServer%

ipconfig /all

goto eof

:disableProxy
REM 关闭服务器
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f

REM 刷新设置
netsh winhttp reset proxy

echo 已关闭代理。

:eof
