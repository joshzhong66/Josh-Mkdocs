@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 设置 hosts 文件路径
set hosts_file=%SystemRoot%\System32\drivers\etc\hosts
:: 设置域名解析 IP 列表文件路径
set domain_file=domain_ip.txt

echo.>> %hosts_file%

:: 遍历列表文件内容到 hosts 文件
for /f "tokens=*" %%a in (%domain_file%) do (
    echo %%a>> %hosts_file%
)

echo 已成功写入到 hosts 文件
pause
