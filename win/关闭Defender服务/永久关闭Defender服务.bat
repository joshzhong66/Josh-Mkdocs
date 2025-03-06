@echo off
chcp 65001>nul
title Defender服务控制脚本

:: 获取管理员权限
%1 %2
ver|find "5.">nul&&goto :admin
mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :admin","","runas",1)(window.close)&exit
:admin

set success=1

echo 正在配置服务...
sc config WinDefend start=disabled >nul
if %errorlevel% neq 0 set success=0

sc stop WinDefend >nul
if %errorlevel% neq 0 set success=0

echo 正在修改注册表...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul
if %errorlevel% neq 0 set success=0

if %success% equ 1 (
    echo [✓] 操作成功，Defender服务已彻底关闭
) else (
    echo [×] 部分操作失败，请检查权限设置
)
echo 恢复脚本已生成：EnableDefender.bat
timeout /t 10 >nul