@echo off
chcp 65001 >nul
set "logfile=%~dp0clean_quickaccess.log"

:: 请求管理员权限
whoami /groups | find "S-1-16-12288" >nul
if %errorLevel% neq 0 (
    echo [%date% %time%] 正在请求管理员权限... >> "%logfile%"
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0'" -Verb RunAs
    exit /b
)

:: 清理快速访问历史文件
del /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*" 2>nul

:: 删除StartPage2（存在时）
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage2" 2>nul
if %errorlevel%==0 (
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage2" /f
)

:: 删除RunMRU（可选，根据需求决定是否保留）
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" 2>nul
if %errorlevel%==0 (
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f
)

:: 重启资源管理器
taskkill /f /im explorer.exe >nul
start explorer.exe
echo 快速访问已清除！
pause