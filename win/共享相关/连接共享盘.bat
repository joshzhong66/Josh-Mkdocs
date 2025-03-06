@echo off
chcp 65001 >nul

REM 保存网络路径的凭据
cmdkey /add:10.24.1.105 /user:zhsm /pass:zxRRVwzF

REM 取消映射指定的网络驱动器（如果已经存在）
net use K: /delete /y >nul 2>&1
net use H: /delete /y >nul 2>&1
net use L: /delete /y >nul 2>&1

REM 使用指定的网络路径、用户名和密码映射网络驱动器并设置持久化
net use K: \\10.24.1.105\咨询项目文件  /persistent:yes >nul 2>&1
net use H: \\10.24.1.105\共享服务部  /persistent:yes >nul 2>&1
net use L: \\10.24.1.105\行政服务部  /persistent:yes >nul 2>&1

REM 检查是否映射成功
if %errorlevel% neq 0 (
    echo 映射网络驱动器失败！
) else (
    echo 网络驱动器已成功!
)

pause
