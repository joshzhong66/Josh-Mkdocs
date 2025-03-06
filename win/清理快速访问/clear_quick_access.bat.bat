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

:: 清理现有自动生成的快速访问历史
del /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*" 2>nul

:: 禁止系统自动跟踪常用位置（核心设置）
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_SearchApps" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_ShowRecent" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_ShowFrequent" /t REG_DWORD /d 0 /f

:: 重启资源管理器使设置生效
taskkill /f /im explorer.exe >nul
start explorer.exe
echo 已禁止自动添加快速访问，仅保留手动添加项！
pause