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

:: 适用于win操作系统，在cmd输入ipconfig/all确认网卡名称
:: 右键-以管理员身份运行即可，以太网改为你的网络名称

:: 设置IP地址
:main
set /p choice=请选择设置类型(1:固定内网IP / 2:自动获取IP / 3:临时固定IP ):
echo.

if "%choice%"=="1" goto ip1
if "%choice%"=="2" goto ip2
if "%choice%"=="3" goto ip3
goto main

:ip1
echo 固定内网IP自动设置开始...
echo.

echo 正在设置固定内网IP及子网掩码...
netsh interface ip set address name="WLAN" source=static addr=10.18.88.135 mask=255.255.255.0 gateway=10.18.88.1 gwmetric=1

echo 正在设置固定内网DNS服务器...
netsh interface ip add dnsservers name="WLAN" address=8.8.8.8 index=1 >nul
netsh interface ip add dnsservers name="WLAN" address=114.114.114.114 index=2 >nul

echo.
echo 固定内网IP设置完成。

if errorlevel 1 goto main
if errorlevel 0 goto end

:ip2
echo 自动获取IP自动设置开始...
echo.

echo 正在设置自动获取IP地址...
netsh interface ip set address name="WLAN" source=dhcp

echo 正在设置自动获取DNS服务器...
netsh interface ip set dns name="WLAN" source=dhcp

echo 自动获取IP设置完成。

if errorlevel 1 goto main
if errorlevel 0 goto end

:ip3
echo 临时固定IP自动设置开始...
echo.

echo 正在设置临时固定IP及子网掩码...
set /p ip=请输入需要配置的IP地址:
set /p ym=请输入需要配置的子网掩码:
set /p gt=请输入需要配置的网关:
netsh interface ip set address name="WLAN" source=static addr="%ip%" mask="%ym%" gateway="%gt%" gwmetric=1

echo 正在设置内网DNS服务器...
netsh interface ip add dnsservers name="WLAN" address=8.8.8.8 index=1 >nul
netsh interface ip add dnsservers name="WLAN" address=114.114.114.114 index=2 >nul

echo.
echo 临时固定IP设置完成。

if errorlevel 1 goto main
if errorlevel 0 goto end

:end
pause
exit /b 0