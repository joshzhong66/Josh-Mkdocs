@echo off
: 只删除凭据
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

:: 执行删除
set "targetIP=!domain[%choice%]!"
echo 正在删除: Domain:target=!targetIP!
cmdkey /delete "Domain:target=!targetIP!" >nul
if errorlevel 1 (
    echo 删除失败！请以管理员身份运行。
) else (
    echo 成功删除凭据！
)
pause