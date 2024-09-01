```
@echo off
chcp 65001 >null
:: Git Account Switcher Script
:: Date: %date%

:: 定义账号信息
:: 在这里添加你的 Git 账号名称和对应的邮箱
setlocal EnableDelayedExpansion

:: 添加账号 - 格式：账号标识=用户名,邮箱
set accounts[1]=31314,zhongjinlin31314@sunline.cn
set accounts[2]=joshzhong66,josh.zhong66@gmail.com
set accounts[3]=YourPersonalName,personal@example.com

:: 显示可用账号
echo ===========================================
echo          Git Account Switcher
echo ===========================================
echo.
echo git账号列表如下:
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
set /p "selection=请选择要使用的账号 [0-3]: "

:: 验证输入
if "%selection%"=="0" (
    echo Exiting.
    goto end
) else if "%selection%"=="" (
    echo [Error] 请输入有效的数字.
    goto choice
) else if %selection% GTR 3 (
    echo [Error] 选择超出范围，请重新输入.
    goto choice
) else (
    set "selected_value=!accounts[%selection%]!"
    for /f "tokens=1,2 delims=," %%a in ("!selected_value!") do (
        set "selected_name=%%a"
        set "selected_email=%%b"
    )
)

:: 选择配置范围
echo.
echo Configuration Scope:
:: 1. 全局配置 (影响所有仓库)
echo   1. Global (affects all repositories)
:: 2. 当前仓库 (仅影响当前仓库)
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
echo [Success] 已将 Git 账号切换为:
echo   Name: %selected_name%
echo   Email: %selected_email%
echo.
echo Current Git configuration:
git config %config_scope% --list
echo.

:end
pause

```

