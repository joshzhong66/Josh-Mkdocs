@echo off
chcp 65001 >nul
color 0a
setlocal enabledelayedexpansion

echo ============================================
echo         自动安装 360浏览器
echo ============================================

:: 调用 PowerShell 脚本获取安装包文件名
for /f "delims=" %%i in ('powershell -ExecutionPolicy Bypass -File "%~dp0get_installer_name.ps1"') do (
    set "installer_name=%%i"
)

:: 判断
if not defined installer_name (
    echo 无法获取安装包名，请检查网络或脚本
    pause
    exit /b
)

echo 获取到的安装包: !installer_name!

:: 拼接路径
set "base_url=https://mirrors.sunline.cn/application/360zip/"
set "download_url=!base_url!!installer_name!"
set "install_path=%TEMP%\!installer_name!"

echo 下载链接: !download_url!
echo 保存路径: !install_path!

:: 下载
powershell -Command "(New-Object Net.WebClient).DownloadFile('!download_url!', '!install_path!')"

if not exist "!install_path!" (
    echo 下载失败！
    pause
    exit /b
)

:: 安装
start /wait "" "!install_path!" /S

:: 清理
del "!install_path!"
echo 安装完成！
pause >nul
