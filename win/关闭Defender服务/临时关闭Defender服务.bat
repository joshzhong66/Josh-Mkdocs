@echo off
chcp 65001>nul

title 安全中心控制脚本

:: 获取管理员权限
%1 %2
ver|find "5.">nul&&goto :admin
mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :admin","","runas",1)(window.close)&exit
:admin

echo 正在关闭实时监控...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
if %errorlevel% equ 0 (
    echo [✓] 操作成功，实时监控已关闭（重启后自动恢复）
) else (
    echo [×] 操作失败，错误代码：%errorlevel%
)
timeout /t 5 >nul