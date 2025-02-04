@echo off
chcp 65001 >nul
:: 安装office2021_专业增强版_批量许可证.iso 
openfiles >nul 2>nul
if %errorlevel% neq 0 (
    echo 以管理员身份运行此批处理文件...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb runAs"
    exit /b
)

:: 进入 Office 目录并执行命令
cd "C:\Program Files\Microsoft Office\Office16"

:: 设置 KMS 服务器地址和端口
cscript ospp.vbs /sethst:kms.0t.net.cn
cscript ospp.vbs /setprt:1688

:: 激活 Office
cscript ospp.vbs /act

echo 命令执行完成。
pause
