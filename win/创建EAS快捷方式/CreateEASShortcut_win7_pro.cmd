@echo off
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
set "shortcut_path=%desktop_dir%\%shortcut_name%"

:: 创建 VBScript 以创建快捷方式
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%temp%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut("%shortcut_path%") >> "%temp%\CreateShortcut.vbs"
echo oLink.TargetPath = "%bat_path%" >> "%temp%\CreateShortcut.vbs"
echo oLink.WorkingDirectory = "%~dp0" >> "%temp%\CreateShortcut.vbs"
echo oLink.IconLocation = "%ico_path%,0" >> "%temp%\CreateShortcut.vbs"
echo oLink.Save >> "%temp%\CreateShortcut.vbs"

:: 运行 VBScript
cscript //nologo "%temp%\CreateShortcut.vbs"

:: 验证结果
if exist "%shortcut_path%" (
    echo 快捷方式创建成功！
    del "%temp%\CreateShortcut.vbs"
    echo 按任意键退出...
    pause >nul
) else (
    echo 创建失败，请检查路径和权限
    pause
)

endlocal
