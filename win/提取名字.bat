@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 获取当前目录
set "current_dir=%cd%"

:: 设置输出文件名
set "output_file=%current_dir%\file_list.txt"

:: 创建一个存储文件名的文件，并输出标题
echo. > "%output_file%"
echo 文件和目录列表: >> "%output_file%"

:: 遍历当前目录下的所有文件和目录并输出到文件
echo [目录] >> "%output_file%"
for /d %%d in (*) do (
    echo %%d >> "%output_file%"
)

echo. >> "%output_file%"
echo [文件] >> "%output_file%"
for %%f in (*) do (
    if "%%f" neq "file_list.txt" (
		if "%%f" neq "提取名字.bat" (
			if not exist "%%f\" (
				echo %%~nf >> "%output_file%"
			)
        )
    )
)

:: 提示完成
echo 文件和目录名已输出到 %output_file%
pause