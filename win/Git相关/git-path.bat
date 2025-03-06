@echo off
chcp 65001 >null
:: Git Account Switcher Script
:: Date: %date%

:: 定义账号信息和对应的路径
setlocal EnableDelayedExpansion

:: 添加账号 - 格式：账号标识=用户名,邮箱,路径
set accounts[1]=31314,zhongjinlin31314@sunline.cn,E:\GitHub\devp_scripts
set accounts[2]=YourPersonalName,personal@example.com,C:\Path\To\Your\Other\Repo
set accounts[3]=joshzhong66,josh.zhong66@gmail.com,E:\GitHub\LearningNotes

:: 显示可用账号
echo ===========================================
echo          Git Account Switcher
echo ===========================================
echo.
echo Available accounts:
for %%i in (1,2,3) do (
    set "value=!accounts[%%i]!"
    for /f "tokens=1,2 delims=," %%a in ("!value!") do (
        echo   %%i. %%a [%%b]
    )
)
echo.
echo   0. Exit
echo.

:: 提示用户选择
:choice
set /p "selection=Select an account [0-3]: "

:: 验证输入
if "%selection%"=="0" (
    echo Exiting.
    goto end
) else if "%selection%"=="" (
    echo [Error] Please enter a valid number.
    goto choice
) else if %selection% GTR 3 (
    echo [Error] Selection out of range, please enter a number between 0 and 3.
    goto choice
) else (
    set "selected_value=!accounts[%selection%]!"
    for /f "tokens=1,2,3 delims=," %%a in ("!selected_value!") do (
        set "selected_name=%%a"
        set "selected_email=%%b"
        set "selected_path=%%c"
    )
)

:: 切换到对应的仓库目录
echo.
echo [Info] Changing directory to %selected_path%
cd /d "%selected_path%"

:: 检查当前目录是否为 Git 仓库
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [Error] This directory is not a Git repository.
    goto end
)

:: 选择配置范围
echo.
echo Configuration Scope:
echo   1. Global (affects all repositories)
echo   2. Current Repository (only affects this repository)
echo.
:scope_choice
set /p "scope=Select a configuration scope [1-2]: "

if "%scope%"=="1" (
    set "config_scope=--global"
) else if "%scope%"=="2" (
    set "config_scope="
) else (
    echo [Error] Please enter a valid option.
    goto scope_choice
)

:: 应用配置
git config %config_scope% user.name "%selected_name%"
git config %config_scope% user.email "%selected_email%"

:: 显示结果
echo.
echo [Success] Git account switched to:
echo   Name: %selected_name%
echo   Email: %selected_email%
echo.
echo Current Git configuration:
git config %config_scope% --list
echo.

:end
pause
