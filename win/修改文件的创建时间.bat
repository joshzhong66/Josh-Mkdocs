@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 设置要修改创建时间的文件路径
:loop
set file_path=
set /p file_path=请输入修改创建时间的文件路径：
echo.

:: 检查是否输入了要修改创建时间的文件路径
if "!file_path!"=="" (
    echo 未输入修改创建时间的文件路径。
	echo.

    :loop2
    set exit_script=
    set /p exit_script=是否需要重新输入（y或n）：
	echo.

    if /i "!exit_script!"=="y" (
        goto loop
    ) else if /i "!exit_script!"=="n" (
        echo 退出脚本.
        pause
        exit /b 0
    ) else (
        goto loop2
    )
)

:: 判断文件路径是否存在
if exist "!file_path!" (
    echo 文件存在于系统中！准备执行修改创建时间...
    echo.
) else (
    echo 文件不存在于系统中！请检查路径是否正确！
    echo.
    goto loop
)

:: 输入要修改的指定时间
:time_input
set new_creation_time=
set /p new_creation_time=请输入要修改的指定时间（格式： yyyy-MM-dd HH:mm:ss ）：
echo.

:: 调用 PowerShell 检查时间格式是否正确
powershell -command ^
"$pattern = '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'; ^
if ('!new_creation_time!' -match $pattern) { ^
    exit 0 ^
} else { ^
    exit 1 ^
}"

:: 检查 PowerShell 的返回值
if !errorlevel! neq 0 (
    echo 时间格式不正确，请重新输入。
    echo.
    goto time_input
)

:: 调用 powershell 执行修改创建时间命令
powershell -command "(Get-Item !file_path!).CreationTime = (Get-Date '!new_creation_time!')" >nul

if !errorlevel! neq 0 (
    echo 指定的时间不符合实际上的时间范围内，请重新输入。
    echo.
    goto time_input
)

echo 修改成功！指定的修改创建时间为 "!new_creation_time!"
pause
exit /b 0
