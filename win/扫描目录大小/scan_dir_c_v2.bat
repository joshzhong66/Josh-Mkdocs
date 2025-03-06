@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 获取当前用户目录
set "user_profile=%USERPROFILE%"
if not exist "%user_profile%" (
    echo 错误：用户目录不存在。
    pause
    exit /b 1
)

:: 初始化变量
set "total_bytes=0"
set "total_folders=0"
set "folder_info="

echo 正在扫描 %user_profile%...
echo =========================================

:: 过滤并遍历子文件夹
for /d %%a in ("%user_profile%\*") do (
    set "folder=%%~nxa"
    set "folder_path=%%a"
    
    :: 排除系统文件夹
    if /i not "!folder!"=="AppData" (
    if /i not "!folder!"=="Default" (
    if /i not "!folder!"=="公用" (
    if /i not "!folder!"=="Public" (
    if /i not "!folder!"=="All Users" (
    if /i not "!folder!"=="Default User" (
        :: 使用PowerShell计算文件夹大小
        for /f "delims=" %%b in ('powershell -Command "$size = (Get-ChildItem -LiteralPath '!folder_path!' -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum; if($size -eq $null){0}else{$size}"') do set "bytes=%%b"
        
        if "!bytes!"=="" set "bytes=0"
        
        :: 转换为GB并显示
        for /f %%g in ('powershell "[math]::Round(!bytes!/1GB, 2)"') do set "size_gb=%%g"
        echo !folder!：!size_gb! GB
        
        :: 将文件夹信息添加到数组
        set "folder_info=!folder_info!!bytes!,!folder!,!folder_path!;"
        
        set /a "total_bytes+=bytes"
        set /a "total_folders+=1"
    ))))))
)

:: 计算总大小
for /f "delims=" %%t in ('powershell -Command "$total = 0; '%folder_info%'.TrimEnd(';') -split ';' | ForEach-Object { $total += [long]($_ -split ',')[0] }; [math]::Round($total/1GB, 2)"') do set "total_gb=%%t"

:: 输出结果
echo.
echo =========================================
echo 总文件夹数：%total_folders%
echo 合计大小：%total_gb% GB
echo.
echo 按任意键退出...
pause >nul