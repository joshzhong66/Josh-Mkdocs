@echo off
chcp 936 >nul

:: 检查是否以管理员身份运行
openfiles >nul 2>nul || (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c ""%~f0""' -Verb RunAs"
    exit /b
)

:: 确定 Office 版本安装目录（根据实际情况选择路径）
set OFFICE_DIR_32="%ProgramFiles%\Microsoft Office\Office14"
set OFFICE_DIR_64="%ProgramFiles%\Microsoft Office\Office14"

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
cscript ospp.vbs /sethst:kms2.sunline.cn
cscript ospp.vbs /setprt:1688

:: 激活 Office
echo 激活 Office...
cscript ospp.vbs /act

:: 检查激活状态
echo 检查激活状态...
cscript ospp.vbs /dstatus

echo 完成激活。
pause