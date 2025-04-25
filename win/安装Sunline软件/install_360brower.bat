@echo off
setlocal enabledelayedexpansion

echo 正在检查网络连通性...
ping -n 3 mirrors.sunline.cn >nul
if errorlevel 1 (
    echo [错误] 网络连接失败！
    pause
    exit /b
)

echo 正在下载网页内容...
powershell -Command "Invoke-WebRequest -Uri 'https://mirrors.sunline.cn/application/360brower/' -UseBasicParsing -OutFile 'webpage.html'"

if not exist "webpage.html" (
    echo [错误] 下载网页失败！
    pause
    exit /b
)


echo 正在解析下载链接...
powershell -Command "(Get-Content 'webpage.html') -replace '<[^>]+>', '' | Select-String -Pattern '360se[^\s]*?\.exe' -AllMatches | %%{ $_.Matches } | %%{ $_.Value }" > links.txt


set "exe_file="
for /f "delims=" %%a in (links.txt) do (
    set "exe_file=%%a"
    echo 找到文件: %%a
)

del webpage.html links.txt >nul 2>&1

if defined exe_file (
    for /f "tokens=3 delims=_" %%v in ("%exe_file%") do (
        set "version=%%v"
        set "version=!version:.exe=!"
        echo 提取的版本号: !version!
    )
) else (
    echo [错误] 未找到有效的exe文件！
    pause
    exit /b
)

echo 正在下载安装程序...
set "download_url=https://mirrors.sunline.cn/application/360brower/%exe_file%"
powershell -Command "Start-BitsTransfer -Source '!download_url!' -Destination '!exe_file!'"

::powershell -Command "Invoke-WebRequest -Uri '!download_url!' -OutFile '!exe_file!'"
if not exist "!exe_file!" (
    echo [错误] 安装程序下载失败！
    pause
    exit /b
)

echo 正在安装 360浏览器...
start /wait "" "!exe_file!" /S

:: 安装后删除安装包
echo 删除安装包
del "!exe_file!" >nul 2>&1

echo [成功] 已完成 360浏览器 安装！版本: !version!
pause
