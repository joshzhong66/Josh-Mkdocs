@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 设置要创建的目录数量
set /p num_folders=请输入要创建的目录数量：

:: 检查是否输入了要创建的目录数量
if "%num_folders%"=="" (
    echo 未输入要创建的目录数量。
	pause
    exit /b 1
)

:: 设置是否需要自定义目录名
echo.
set /p yes_no=是否需要自定义目录名（请输入y或n）：

:: 检查是否输入了是否需要自定义目录名
if "%yes_no%"=="" (
    echo 未输入是否需要自定义目录名。
	pause
    exit /b 1
)

:: 检查是否输入了正确的是否需要自定义目录名
if "%yes_no%" neq "y" if "%yes_no%" neq "n" (
    echo 输入的是否需要自定义目录名不是有效的选项。
	pause
    exit /b 1
)

:: 循环创建目录
echo.
if "%yes_no%"=="y" (
    for /l %%i in (1, 1, %num_folders%) do (
	    set /p folder_name=请输入第%%i个目录名：
		
		:: 检查是否输入了目录名
		:loop
		if "!folder_name!"=="" (
			set /p folder_name=请勿输入空名，重新输入：
			goto :loop
		)
		md "!folder_name!"
	)
) else (
    for /l %%i in (1, 1, %num_folders%) do (
		set "folder_name=第%%i个目录"
	    md "!folder_name!"
	)
)

pause