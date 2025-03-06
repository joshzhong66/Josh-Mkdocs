@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001>nul
setlocal enabledelayedexpansion

:: 右键-以管理员身份运行即可，以太网改为你的网络名称
:: 关闭360杀毒软件

for /f "tokens=1,* delims= " %%a in ('netsh interface ip show config "WLAN" ^| findstr "配置的 DNS 服务器"') do (
    set "config_status=%%~a"
)

if "%config_status%"=="Statically" (
	echo 当前 DNS 为手动配置，将切换为自动获取DNS...
	
	netsh interface ip set dnsservers "WLAN" dhcp >nul
) else (
	echo 当前 DNS 为自动获取DNS，将切换为手动指定 8.8.8.8...
	
	netsh interface ip set dnsservers "WLAN" static 8.8.8.8 primary >nul
	netsh interface ip add dnsservers "WLAN" 223.5.5.5 index=2 >nul
	ipconfig /flushdns >nul
)

echo DNS 设置已更新并刷新 DNS 缓存。
pause
exit /b 0