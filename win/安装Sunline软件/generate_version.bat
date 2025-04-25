@echo off

setlocal enabledelayedexpansion

:: 步骤1：检查网络
echo 正在检查网络连通性...
ping -n 3 mirrors.sunline.cn >nul
if errorlevel 1 (
    echo [错误] 网络连接失败！
    pause
    exit /b
)

:: 步骤2：下载网页
echo 正在下载网页内容...
powershell -Command "Invoke-WebRequest -Uri 'https://mirrors.sunline.cn/application/360zip/win/' -UseBasicParsing -OutFile 'webpage.html'"
if not exist "webpage.html" (
    echo [错误] 下载网页失败！
    pause
    exit /b
)

:: 步骤3：解析链接
echo 正在解析下载链接...
powershell -Command "(Get-Content 'webpage.html') -replace '<[^>]+>', '' | Select-String -Pattern '360zip_.*?\.exe' -AllMatches | %%{ $_.Matches } | %%{ $_.Value }" > links.txt

:: 步骤4：读取结果
set "exe_file="
for /f "delims=" %%a in (links.txt) do (
    set "exe_file=%%a"
    echo 找到文件: %%a
)

:: 步骤5：清理临时文件
del webpage.html links.txt >nul 2>&1

:: 步骤6：提取版本号（关键修正点）
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

echo [成功] 最新版本为: !version!
pause