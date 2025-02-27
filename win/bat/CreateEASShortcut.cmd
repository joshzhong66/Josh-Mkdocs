@echo off
chcp 65001 >null
setlocal

:: 请求管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 正在请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

:: 设置路径变量
set "bat_path=D:\Kingdee9\eas\client\bin\client.bat"
set "ico_path=D:\Kingdee9\eas\client\bin\client.ico"
set "desktop_dir=%USERPROFILE%\Desktop"
set "shortcut_name=EAS9.0.lnk"

:: 创建快捷方式
echo 正在创建桌面快捷方式...
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut('%desktop_dir%\%shortcut_name%'); $sc.TargetPath = '%bat_path%'; $sc.WorkingDirectory = '%~dp0'; $sc.IconLocation = '%ico_path%,0'; $sc.Save()"

:: 验证结果
if exist "%desktop_dir%\%shortcut_name%" (
    echo 快捷方式创建成功！
    echo 按任意键退出...
    pause >nul
) else (
    echo 创建失败，请检查路径和权限
    pause
)

endlocal