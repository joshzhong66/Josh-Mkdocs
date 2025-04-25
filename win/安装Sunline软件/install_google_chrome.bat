@echo off
setlocal enabledelayedexpansion
color 0A

echo Goole Chrome URL：https://mirrors.sunline.cn/application/chrome/win/ChromeStandaloneSetup64.exe

set "NAME=Google Chrome浏览器"
set "PACKAGE_NAME=ChromeStandaloneSetup64.exe"
set "GENERAL_URL=https://mirrors.sunline.cn/application/"

:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)



echo 正在检查网络连通性...
ping -n 3 mirrors.sunline.cn >nul
if errorlevel 1 (
    echo [错误] 网络连接失败！
    pause
    exit /b
)

echo 正在下载网页内容...
powershell -Command "Invoke-WebRequest -Uri '"%GENERAL_URL%"chrome/win/' -UseBasicParsing -OutFile 'webpage.html'"

if not exist "webpage.html" (
    echo [错误] 下载网页失败！
    pause
    exit /b
)


echo 正在解析下载链接...
powershell -Command "(Get-Content 'webpage.html') -replace '<[^>]+>', '' | Select-String -Pattern 'ChromeStandalone[^\s]*?\.exe' -AllMatches | %%{ $_.Matches } | %%{ $_.Value }" > links.txt


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
set "download_url=%GENERAL_URL%chrome/win/%exe_file%"
powershell -Command "Start-BitsTransfer -Source '!download_url!' -Destination '!exe_file!'"

::powershell -Command "Invoke-WebRequest -Uri '!download_url!' -OutFile '!exe_file!'"
if not exist "!exe_file!" (
    echo [错误] 安装程序下载失败！
    pause
    exit /b
)

echo "正在安装%NAME%..."
start /wait "" "!exe_file!" /S

:: 安装后删除安装包
echo "删除%NAME%"
del "!exe_file!" >nul 2>&1

echo "[成功] 已完成 %NAME%！版本: !version!"
pause
