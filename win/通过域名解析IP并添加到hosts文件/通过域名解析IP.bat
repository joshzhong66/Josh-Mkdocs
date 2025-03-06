@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 设置输入文件和输出文件路径
set inputFile=domain.txt
set outputFile=domain_ip.txt

:: 读取每个域名并查询 IP 地址
for /f "tokens=*" %%a in (%inputFile%) do (
    set domain=%%a
    :: 用于标记是否已经找到并输出了第一个 IP 地址
    set found=0

    :: 使用 PowerShell 查询域名的 IP 地址
    for /f "delims=" %%b in ('powershell -Command "Resolve-DnsName !domain! -Server 8.8.8.8 | Where-Object { $_.IPAddress -match '^\d{1,3}(\.\d{1,3}){3}$' } | Select-Object -ExpandProperty IPAddress"') do (
        :: 如果找到第一个 IPv4 地址，进入 if 语句
        if !found! == 0 (
            set ip=%%b
            echo 域名 !domain! 解析为：!ip!
            echo !ip!    !domain!>> %outputFile%
            :: 标记为 1，丢弃其他 IPv4 地址
            set found=1
        )
    )
)

echo.
echo 解析完成，结果已保存到 %outputFile%
pause