@echo off & chcp 65001 >nul & setlocal enabledelayedexpansion

:: 函数：检查管理员权限
:CheckAdmin
openfiles >nul 2>nul || (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c ""%~f0""' -Verb RunAs"
    exit /b
)

:: 函数：系统版本检测
:CheckVersion
set "is_pro=false"
for /f "tokens=2 delims=[]" %%i in ('wmic os get caption /value ^| find "Caption"') do (
    set "os_caption=%%i"
    if not "%%i" == "!os_caption:专业版=!" set is_pro=true
)

:: 设置路径
::set "bat_path=D:\eas\client\bin\client.bat"
::set "ico_path=D:\eas\client\bin\client.ico"
::set "shortcut_name=EAS9.lnk"

::set "bat_path=E:\Kingdee9\eas\client\bin\client.bat"
::set "ico_path=E:\Kingdee9\eas\client\bin\client.ico"
::set "shortcut_name=EAS9.0.lnk"

:: 添加调试信息
echo 正在检测路径，请稍候...

:: 三级路径检测（增加超时和错误重试）
:RetryPath
if exist "D:\eas\client\bin\client.bat" (
    echo 检测到[路径1] D:\eas\client\bin\client.bat 存在
    set "bat_path=D:\eas\client\bin\client.bat"
    set "ico_path=D:\eas\client\bin\client.ico"
    set "shortcut_name=EAS9.lnk"
    goto PathConfirmed
)

if exist "D:\Kingdee9\eas\client\bin\client.bat" (
    echo 检测到[路径2] D:\Kingdee9\eas\client\bin\client.bat 存在
    set "bat_path=D:\Kingdee9\eas\client\bin\client.bat"
    set "ico_path=D:\Kingdee9\eas\client\bin\client.ico"
    set "shortcut_name=EAS9.0.lnk"
    goto PathConfirmed
)

:: 添加驱动器准备检测
echo 正在检查E盘可用性...
vol E: >nul 2>&1 && (
    if exist "E:\Kingdee9\eas\client\bin\client.bat" (
        echo 检测到[路径3] E:\Kingdee9\eas\client\bin\client.bat 存在
        set "bat_path=E:\Kingdee9\eas\client\bin\client.bat"
        set "ico_path=E:\Kingdee9\eas\client\bin\client.ico"
        set "shortcut_name=EAS9.0.lnk"
        goto PathConfirmed
    )
) || (
    echo E盘不可用，等待5秒后重试...
    timeout /t 5 >nul
    goto RetryPath
)

:: 错误处理（含路径回显）
echo 错误：未找到任何有效路径，请检查以下位置：
echo [路径1] D:\eas\client\bin\client.bat
echo [路径2] D:\Kingdee9\eas\client\bin\client.bat
echo [路径3] E:\Kingdee9\eas\client\bin\client.bat
echo 将在10秒后自动退出...
timeout /t 10 >nul
exit /b 1

:PathConfirmed
echo 已确认使用路径：%bat_path%


:: 公共函数：创建快捷方式
:CreateShortcut
:: 使用PowerShell获取桌面路径
for /f "delims=" %%D in ('powershell -Command "[Environment]::GetFolderPath('Desktop')"') do set "desktop_dir=%%D"

:: 校验必要文件存在
if not exist "%bat_path%" (
    echo 错误: 找不到批处理文件 %bat_path%
    pause
    exit /b
)

if not exist "%ico_path%" (
    echo 警告: 找不到图标文件 %ico_path%
    set "ico_cmd="
) else (
    set "ico_cmd= $sc.IconLocation = '%ico_path%,0';"
)

:: 创建快捷方式核心命令
powershell -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut('%desktop_dir%\%shortcut_name%'); $sc.TargetPath = '%bat_path%'; $sc.WorkingDirectory = '%~dp0';%ico_cmd% $sc.Save();"

:: 结果验证
if exist "%desktop_dir%\%shortcut_name%" (
    echo 成功创建快捷方式：%desktop_dir%\%shortcut_name%
) else (
    echo 快捷方式创建失败，请检查：
    echo 1. 目标路径是否存在
    echo 2. 管理员权限是否生效
    echo 3. 安全软件是否拦截
)

pause
exit /b