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



echo 获取计算机信息，请稍候...

echo.
echo [CPU信息]
echo -----------------------------------------
wmic cpu get name,CurrentClockSpeed,MaxClockSpeed /format:list | findstr "="

echo.
echo [内存信息]
echo -----------------------------------------
echo     插槽      容量(GB)        速度(MHz)
for /f "tokens=1,2 delims==" %%a in ('wmic MEMORYCHIP get BankLabel^,Capacity^,Speed /format:list ^| findstr "="') do (
	REM 获取内存的插槽标签
    if "%%a"=="BankLabel" set "bank=%%b"

	REM 获取内存的容量内存，并计算为GB为单位
    if "%%a"=="Capacity" for /f %%x in ('powershell -Command "[math]::truncate(%%b / 1073741824)"') do set "size=%%x"
	
	REM 获取内存的速度
    if "%%a"=="Speed" set "speed=%%b"
	
    if defined size if defined speed if defined bank (
        echo !bank!		!size!GB		!speed!
        set "size="
        set "speed="
        set "bank="
    )
)

echo.
echo [显卡信息]
echo -----------------------------------------
wmic path win32_videocontroller get name /format:list | findstr "="

echo.
echo [硬盘信息]
echo -----------------------------------------
wmic diskdrive get model,size /format:list | findstr "Model="
for /f "tokens=2 delims==" %%s in ('wmic diskdrive get size /format:list ^| findstr "Size="') do (
    for /f %%x in ('powershell -Command "[math]::truncate(%%s / 1073741824)"') do set "disksize=%%x"
    echo 硬盘容量: !disksize! GB
)

echo.
echo [系统信息]
echo -----------------------------------------
systeminfo | findstr /C:"OS Name" /C:"OS Version" /C:"System Manufacturer" /C:"System Model" /C:"System Type" /C:"BIOS Version"

echo.
echo 信息获取完毕。
pause