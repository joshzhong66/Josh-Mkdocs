@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 日志文件路径
set "logfile=%temp%\DockRestart.log"
echo [%date% %time%] 脚本开始执行 > "%logfile%"

:: 请求管理员权限
whoami /groups | find "S-1-16-12288" >nul
if %errorLevel% neq 0 (
    echo [%date% %time%] 正在请求管理员权限... >> "%logfile%"
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

:: 定义进程列表（按依赖顺序：子进程在前，主进程在后）
set processes=Dockmod.exe Dockmod64.exe Dock_64.exe

:: 预获取所有进程路径到临时文件
set "temp_file=%temp%\proc_paths.tmp"
echo [%date% %time%] 开始收集进程路径信息 >> "%logfile%"
(
    for %%p in (%processes%) do (
        echo 正在查询 %%p 路径...
        wmic process where "name like '%%%%%%p'" get ExecutablePath /format:csv 2>&1 | findstr /i "%%p"
    )
) > "%temp_file%"

:: 终止所有进程
echo [%date% %time%] 开始终止进程 >> "%logfile%"
for %%p in (%processes%) do (
    taskkill /IM "%%p" /F >nul 2>&1
    if errorlevel 1 (
        echo [%date% %time%] 错误：终止 %%p 失败（可能进程不存在） >> "%logfile%"
    ) else (
        echo [%date% %time%] 成功终止 %%p >> "%logfile%"
    )
)

timeout /t 5 /nobreak >nul
echo [%date% %time%] 所有进程已终止，等待 5 秒 >> "%logfile%"

:: 重启进程（关键修复部分）
echo [%date% %time%] 开始重启进程 >> "%logfile%"
for /f "tokens=1,* delims=," %%a in ('type "%temp_file%"') do (
    if "%%b" neq "" (
        set "exe=%%b"
        :: 去除 WMIC 输出中的回车符
        set "exe=!exe:~0,-1!"
        echo 尝试启动进程：路径="!exe!"
        if exist "!exe!" (
            start "" "!exe!" >nul 2>&1
            if errorlevel 1 (
                echo [%date% %time%] 错误：启动失败 "!exe!"（代码：!errorlevel!） >> "%logfile%"
            ) else (
                echo [%date% %time%] 成功启动 "!exe!" >> "%logfile%"
            )
        ) else (
            echo [%date% %time%] 错误：无效路径 "!exe!" >> "%logfile%"
        )
    )
)

:: 清理临时文件
del "%temp_file%" >nul 2>&1
echo [%date% %time%] 脚本执行结束 >> "%logfile%"
echo 操作完成，详细日志见：%logfile%
notepad "%logfile%"
pause