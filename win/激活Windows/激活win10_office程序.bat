@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
setlocal enabledelayedexpansion

for /l %%i in (1,1,7) do echo.

echo 正在启动 PowerShell 来激活 Windows 和 Office...
echo.

echo 激活程序加载中，请在弹出的页面进行操作。
echo.

echo 输入数字键选择激活内容:
echo 1 激活 Windows
echo 2 激活 Office
echo.

powershell -Command "irm https://get.activated.win | iex"

echo 请根据弹出的菜单选择激活选项。
echo.
pause