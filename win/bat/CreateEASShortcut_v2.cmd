:: v2版本调整
::✅ 修正了 PowerShell 语法问题
::✅ 调整了 desktop_dir 变量获取方式，避免不同 Windows 版本路径不一致
::✅ 调整 chcp 936 避免编码导致的乱码问题
::✅ 更稳定的管理员权限检测方式



@echo off
chcp 65001 >nul
::chcp 936 >nul
setlocal

:: 请求管理员权限
whoami /groups | find "S-1-16-12288" >nul
if %errorLevel% neq 0 (
    echo 正在请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

:: 设置路径变量
set "bat_path=D:\Kingdee9\eas\client\bin\client.bat"
set "ico_path=D:\Kingdee9\eas\client\bin\client.ico"
for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop') do set "desktop_dir=%%B"
set "shortcut_name=EAS9.0.lnk"

:: 创建快捷方式
echo 正在创建桌面快捷方式...
powershell -Command ^
"$ws = New-Object -ComObject WScript.Shell; ^
$sc = $ws.CreateShortcut('%desktop_dir%\%shortcut_name%'); ^
$sc.TargetPath = '%bat_path%'; ^
$sc.WorkingDirectory = '%~dp0'; ^
$sc.IconLocation = '%ico_path%,0'; ^
$sc.Save()"

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
