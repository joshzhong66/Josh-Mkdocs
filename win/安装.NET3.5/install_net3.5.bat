@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 检查是否以管理员身份运行
openfiles >nul 2>nul || (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c ""%~f0""' -Verb RunAs"
    exit /b
)

:: 配置参数
set "TARGET_DIR=C:\NetFX3"
set "CAB_FILE=Microsoft-Windows-NetFx3-OnDemand-Package~31bf3856ad364e35~amd64~~.cab"
set "CAB_URL=http://mirrors.sunline.cn/tools/Bat/%%E5%%AE%%89%%E8%%A3%%85.NET-3.5"

:: 创建目录
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%" >nul 2>&1

:: 下载前删除旧文件
if exist "%TARGET_DIR%\%CAB_FILE%" del "%TARGET_DIR%\%CAB_FILE%" >nul 2>&1

:: 判断系统版本
systeminfo | findstr /i /c:"OS Name" | findstr /i /c:"Windows 11" >nul 2>&1
if %errorlevel% equ 0 (
    set "TARGET_FILE=Win11.cab"
) else (
    set "TARGET_FILE=Win10.cab"
)

:: 下载文件
curl -o "%TARGET_DIR%\%CAB_FILE%" "%CAB_URL%/%TARGET_FILE%" >nul 2>&1
if %errorlevel% neq 0 (
    del "%TARGET_DIR%\%CAB_FILE%" >nul 2>&1
    echo 下载失败，请检查网络或URL路径。
    pause
    exit 1
)

:: 安装 .NET Framework 3.5
dism /online /enable-feature /featurename:NetFX3 /Source:"%TARGET_DIR%" /LimitAccess

:: 清理目录
del "%TARGET_DIR%" >nul 2>&1

echo 安装完成。
pause
