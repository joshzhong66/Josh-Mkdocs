@echo off
chcp 65001 >nul

:: Windows 11 初始化脚本
:: 版本: 1.0
:: 作者: 
:: 日期: %date%

:: ============================================
:: 初始化设置
:: ============================================
setlocal enabledelayedexpansion
color 0a
title Windows 11 初始化工具

:: 检查管理员权限
net session >nul 2>&1 || (
    echo.
    echo 错误: 请以管理员身份运行此脚本!
    echo.
    pause
    exit /b 1
)

:: ============================================
:: 主菜单
:: ============================================
:menu
cls
echo.
echo ============================================
echo    Windows 11 系统初始化工具
echo ============================================
echo.
echo 1. 基础设置 (更新+必备软件)
echo 2. 系统优化 (服务+性能)
echo 3. 隐私保护 (禁用遥测+广告)
echo 4. 开发环境 (WSL+工具)
echo 5. 安全加固 (防火墙+SMB)
echo 6. 执行全部初始化
echo 7. 退出
echo.
set /p choice=请选择要执行的操作 (1-7):

if "%choice%"=="1" goto basic
if "%choice%"=="2" goto optimize
if "%choice%"=="3" goto privacy
if "%choice%"=="4" goto dev
if "%choice%"=="5" goto security
if "%choice%"=="6" goto all
if "%choice%"=="7" exit

goto menu

:: ============================================
:: 功能模块
:: ============================================
:basic
call :update_system
call :install_software
goto menu

:optimize
call :disable_services
call :power_settings
goto menu

:privacy
call :disable_telemetry
call :disable_ads
goto menu

:dev
call :setup_wsl
call :install_dev_tools
goto menu

:security
call :enable_firewall
call :disable_smbv1
goto menu

:all
call :update_system
call :install_software
call :disable_services
call :power_settings
call :disable_telemetry
call :disable_ads
call :setup_wsl
call :install_dev_tools
call :enable_firewall
call :disable_smbv1
goto menu

:: ============================================
:: 基础设置 (更新+必备软件)
:: ============================================
:update_system
echo.
echo [1/3] 正在检查系统更新...
wuauclt /detectnow
echo [2/3] 正在修复系统映像...
dism /online /cleanup-image /restorehealth
echo [3/3] 正在扫描系统文件...
sfc /scannow
echo 系统更新完成!
pause
goto :eof

:install_software
echo.
echo 正在安装必备软件...
winget install --id=Google.Chrome -e --silent
winget install --id=Microsoft.VisualStudioCode -e --silent
winget install --id=7zip.7zip -e --silent
echo 软件安装完成!
pause
goto :eof


:: ============================================
:: 系统优化模块 - 服务与性能调整
:: ============================================
:system_optimization
cls
echo.
echo ============================================
echo    Windows 11 系统优化 - 服务与性能调整
echo ============================================
echo.
echo 注意: 此操作将修改系统关键设置
echo 建议在执行前创建系统还原点
echo.
set /p proceed=是否继续? (Y/N): 
if /i "%proceed%" neq "Y" goto :eof

:: 创建还原点(需要管理员权限)
echo 正在创建系统还原点...
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Before Optimization", 100, 7

:: ====================
:: 1. 禁用不必要的服务
:: ====================
echo.
echo [1/6] 正在优化系统服务...

:: 服务列表(可根据需要增减)
set services=(
    "diagnosticshub.standardcollector.service"  "Microsoft 诊断中心标准收集器服务"
    "DiagTrack"                                "诊断跟踪服务"
    "dmwappushservice"                        "设备管理无线应用协议推送服务"
    "lfsvc"                                   "地理位置服务"
    "MapsBroker"                              "地图服务"
    "NetTcpPortSharing"                       "Net.Tcp端口共享服务"
    "RemoteRegistry"                          "远程注册表服务"
    "SysMain"                                 "SuperFetch服务"
    "TrkWks"                                  "分布式链接跟踪客户端"
    "WMPNetworkSvc"                           "Windows Media Player网络共享服务"
    "WSearch"                                 "Windows搜索服务"
)

for /f "tokens=1,2 delims=}" %%i in ('echo %services%') do (
    echo 正在处理服务: %%j
    sc config "%%i" start= disabled >nul 2>&1
    if errorlevel 1 (
        echo [警告] 无法禁用服务: %%i (%%j)
    ) else (
        echo [成功] 已禁用服务: %%i (%%j)
    )
)

:: ====================
:: 2. 性能相关注册表调整
:: ====================
echo.
echo [2/6] 正在调整性能相关注册表...

:: 禁用NTFS最后访问时间标记(减少磁盘写入)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d 1 /f

:: 优化系统响应速度
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_DWORD /d 2000 /f
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_DWORD /d 2000 /f
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_DWORD /d 2000 /f

:: 禁用Windows错误报告
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f

:: ====================
:: 3. 电源计划设置
:: ====================
echo.
echo [3/6] 正在配置高性能电源计划...

:: 设置高性能电源计划
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

:: 禁用显示器关闭和睡眠
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0

:: ====================
:: 4. 网络性能优化
:: ====================
echo.
echo [4/6] 正在优化网络设置...

:: 禁用TCP/IP自动调谐(可改善某些网络环境下的性能)
netsh interface tcp set global autotuninglevel=restricted

:: 增加TCP连接数限制
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpNumConnections" /t REG_DWORD /d 16777214 /f

:: ====================
:: 5. 内存管理优化
:: ====================
echo.
echo [5/6] 正在优化内存管理...

:: 禁用内存压缩(对16GB以上内存系统有益)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 1 /f

:: ====================
:: 6. 视觉效果调整
:: ====================
echo.
echo [6/6] 正在调整视觉效果...

:: 调整为最佳性能
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f

:: 禁用动画效果
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f

:: 禁用透明效果
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f

:: ====================
:: 完成提示
:: ====================
echo.
echo 系统优化完成!
echo 部分设置需要重启后才能生效
echo.
pause
goto :eof


:: ============================================
:: 脚本结束
:: ============================================
:exit
echo.
echo 初始化完成! 建议重启计算机以使所有更改生效。
pause
exit