#适用于操作系统（win10），在cmd输入ipconfig/all确认网卡名称：

@echo off
chcp 65001
:: 设置IP地址
set /p choice=请选择设置类型(1:固定内网IP / 2:自动获取IP / 3:临时固定IP ):
echo.
if "%choice%"=="1" goto ip1
if "%choice%"=="2" goto ip2
if "%choice%"=="3" goto ip3
goto main
:ip1
echo 固定内网IP自动设置开始...
echo.
echo 正在设置固定内网IP及子网掩码
cmd /c netsh interface ip set address name="以太网" source=static addr=10.0.0.3 mask=255.255.255.0 gateway=10.0.0.1 gwmetric=1
echo 正在设置固定内网DNS服务器
cmd /c netsh interface ip add dnsservers name="以太网" address=10.0.0.35 index=1
cmd /c netsh interface ip add dnsservers name="以太网" address=114.114.114.114 index=2
echo 固定内网IP设置完成
pause
exit
if errorlevel 2 goto main
if errorlevel 1 goto end
:ip2
echo IP自动设置开始....
echo.
echo 自动获取IP地址....
netsh interface ip set address name = "以太网" source = dhcp
echo 自动获取DNS服务器....
netsh interface ip set dns name = "以太网" source = dhcp
@rem 设置自动获取IP
echo 设置完成
pause
exit
if errorlevel 2 goto main
if errorlevel 1 goto end
:ip3
echo 临时固定IP自动设置开始...
echo.
echo 正在设置临时固定IP及子网掩码
set /p ip=请输入需要配置的IP地址:
set /p ym=请输入需要配置的子网掩码:
set /p gt=请输入需要配置的网关:
cmd /c netsh interface ip set address name="以太网" source=static addr="%ip%" mask="%ym%" gateway="%gt%" gwmetric=1
echo 正在设置内网DNS服务器
cmd /c netsh interface ip add dnsservers name="以太网" address=114.114.114.114 index=1
cmd /c netsh interface ip add dnsservers name="以太网" address=8.8.8.8 index=2
echo 内网IP设置完成
pause
exit
if errorlevel 2 goto main
if errorlevel 1 goto end
:end