@echo off
: 结束PicGo.exe
: wmic process where "name='Dock_64.exe'" get ExecutablePath    # 查询进程exe文件路径

chcp 65001 >nul

:: 请求管理员权限
whoami /groups | find "S-1-16-12288" >nul
if %errorLevel% neq 0 (
    echo [%date% %time%] 正在请求管理员权限... >> "%logfile%"
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

:: 查找并结束 Mydock.exe 进程
tasklist | findstr /i "PicGo.exe" >nul
if %errorlevel% equ 0 (
    echo 正在结束 PicGo.exe 进程...
    taskkill /IM PicGo.exe /F >nul
    if %errorlevel% equ 0 (
        echo PicGo.exe 进程已成功结束。
    ) else (
        echo 无法结束 PicGo.exe 进程，请检查。
        pause
        exit /b
    )
) else (
    echo 未找到 PicGo.exe 进程。
)

:: 重新启动 PicGo.exe
echo 正在重新启动 PicGo.exe...
start "" "C:\Software\PicGo\PicGo.exe" >nul
if %errorlevel% equ 0 (
    echo PicGo.exe 已成功启动。
) else (
    echo 无法启动 PicGo.exe，请检查路径是否正确。
)

pause