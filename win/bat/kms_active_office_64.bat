@echo off
chcp 65001 >nul
:: 检查是否以管理员身份运行
openfiles >nul 2>nul
if %errorlevel% neq 0 (
    echo 以管理员身份运行此批处理文件...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb runAs"
    exit /b
)

:: 确定 Office 版本安装目录（根据实际情况选择路径）
set OFFICE_DIR_32="C:\Program Files (x86)\Microsoft Office\Office16"
set OFFICE_DIR_64="C:\Program Files\Microsoft Office\Office16"

:: 检查 Office 安装目录是否存在
if exist %OFFICE_DIR_32% (
    set OFFICE_DIR=%OFFICE_DIR_32%
) else if exist %OFFICE_DIR_64% (
    set OFFICE_DIR=%OFFICE_DIR_64%
) else (
    echo 无法找到 Office 安装目录！请检查安装路径。
    exit /b
)

:: 进入 Office 安装目录
cd /d %OFFICE_DIR%

:: 设置 KMS 服务器地址和端口
echo 设置 KMS 服务器...
cscript ospp.vbs /sethst:10.22.51.64
cscript ospp.vbs /setprt:1688

:: 激活 Office
echo 激活 Office...
cscript ospp.vbs /act

:: 检查激活状态
echo 检查激活状态...
cscript ospp.vbs /dstatus

echo 完成激活。
pause
