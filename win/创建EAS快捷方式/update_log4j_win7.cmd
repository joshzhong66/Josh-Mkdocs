@echo off
setlocal enabledelayedexpansion

:: 目标文件和目录
set "target_file=D:\Kingdee\eas\client\deploy\client\log4j.properties"
set "download_url=https://mirrors.sunline.cn/application/EAS/log4j.properties"
set "target_dir=D:\Kingdee\eas\client\deploy\client"

:: 创建目录（如果不存在）
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

:: 使用 wget 下载
echo 正在下载文件，请稍等...
wget -O "!target_dir!\log4j.properties" "!download_url!"

:: 检查下载是否成功
if exist "!target_dir!\log4j.properties" (
    echo 文件下载成功，已放入: !target_dir!
) else (
    echo 文件下载失败，请检查网络连接或下载地址
)

pause
