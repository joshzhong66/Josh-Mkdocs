@echo off
: 删除凭据 与 清理网络驱动器 和 远程桌面连接
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 初始化索引
set "index=0"

:: 精准解析Domain类型凭据
echo 正在扫描Domain类型凭据...
for /f "tokens=1,* delims==" %%a in (
    'cmdkey /list ^| findstr /i /c:"Domain:target="'
) do (
    set "target=%%b"
    set "target=!target: =!"
    set /a index+=1
    set "domain[!index!]=!target!"
    echo [!index!] 目标IP: !target!
)

:: 无凭据时退出
if %index% equ 0 (
    echo 未找到Domain类型凭据。
    pause
    exit /b 1
)

:: 用户选择操作
:input
echo.
set /p "choice=请输入要删除的序号 (1-%index%) / 输入 all 删除全部 / 输入 0 取消: "

:: 处理取消
if "%choice%"=="0" (
    echo 操作已取消。
    pause
    exit /b 0
)

:: 处理全部删除
if /i "%choice%"=="all" (
    echo 正在删除全部Domain凭据...
    for /l %%i in (1,1,%index%) do (
        call :clean_connections "!domain[%%i]!"
        cmdkey /delete "Domain:target=!domain[%%i]!" >nul
        echo 已删除: Domain:target=!domain[%%i]!
    )
    pause
    exit /b 0
)

:: 验证输入合法性
echo %choice%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo 错误：请输入数字！
    goto input
)
if %choice% lss 1 (
    echo 错误：序号不能小于1！
    goto input
)
if %choice% gtr %index% (
    echo 错误：序号不能超过%index%！
    goto input
)

:: 执行删除操作
set "targetIP=!domain[%choice%]!"
call :clean_connections "%targetIP%"
echo 正在删除: Domain:target=%targetIP%
cmdkey /delete "Domain:target=%targetIP%" >nul
if errorlevel 1 (
    echo 删除失败！请以管理员身份运行。
) else (
    echo 成功删除凭据！
)
pause
exit /b 0

:clean_connections
set "checkIP=%~1"
echo.
echo 正在清理 %checkIP% 相关连接...

:: 清理网络驱动器
echo 1. 检查网络驱动器映射...
for /f "tokens=2,3 delims= " %%a in ('net use ^| findstr /i "\\%checkIP%\\"') do (
    echo 发现驱动器 %%a 映射到 %%b
    net use %%a /delete /y >nul
    echo 已删除网络驱动器: %%a
)

:: 清理远程桌面连接
echo 2. 检查远程桌面连接...
powershell -Command "$IP='%checkIP%'; $Cons=@(Get-NetTCPConnection -RemoteAddress $IP -RemotePort 3389 -State Established -ErrorAction 0); if($Cons){$Cons|%%{Stop-Process -Id $_.OwningProcess -Force}; echo '已终止RDP进程'} else {echo '未发现活跃连接'}" 

echo 清理完成&echo.
exit /b 0


