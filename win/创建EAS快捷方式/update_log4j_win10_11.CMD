@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

:: 设置目标文件和目录
::set "target_file=D:\Kingdee9\eas\client\deploy\client\log4j.properties"
set "target_file=D:\eas\client\deploy\client\log4j.properties"
set "download_url=https://mirrors.sunline.cn/application/EAS/log4j.properties"
::set "target_dir=D:\Kingdee\eas\client\deploy\client"
set "target_dir=D:\eas\client\deploy\client"

:: 如果目录不存在，则创建
if not exist "!target_dir!" (
    echo 目标目录不存在，正在创建...
    mkdir "!target_dir!"
)

:: 删除旧文件（如果存在）
if exist "!target_file!" (
    del /f /q "!target_file!"
    echo 旧文件已删除: !target_file!
) else (
    echo 旧文件不存在，无需删除
)

:: 下载新文件
powershell -Command "& {Invoke-WebRequest -Uri '!download_url!' -OutFile '!target_dir!\log4j.properties'}"

:: 检查下载是否成功
if exist "!target_dir!\log4j.properties" (
    echo 文件下载成功，已放入: !target_dir!
) else (
    echo 文件下载失败，请检查网络连接或下载地址
)

pause
