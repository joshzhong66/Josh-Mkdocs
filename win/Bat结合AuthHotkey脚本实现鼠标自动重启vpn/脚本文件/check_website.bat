@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 失败次数
set fail_count=1

:: 重置次数
set ahk_fail_count=1

:: 最大重试次数
set max_retries=20

set /p = < nul > status_log.txt

:loop
echo.
set /p ="正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F..." < nul

echo.
curl -s -o NUL -w "%%{http_code}" https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F > result.txt

::type result.txt
set /p status=<result.txt

set /p ="收到的状态码：!status!" < nul
set /p ="收到的状态码：!status!" < nul >> status_log.txt
echo.
echo.  >> status_log.txt
echo.  >> status_log.txt

if not "!status!"=="200" (
    echo 状态码不是200，启动AutoHotkey脚本...
    start "" "C:\Program Files\AutoHotkey\AutoHotkey.exe" "C:\Users\Administrator\Desktop\check_vpn_window_and_click.ahk"
    timeout /t 40

    if "%ahk_fail_count%"=="1" (
        echo AutoHotkey脚本刚开始启动，发送一条通知...
        curl -s -o NUL -w "%%{http_code}" https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F > result.txt
        set /p status=<result.txt
        curl -H "Content-Type: application/json" -X POST -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Now Status code: !status!. AWS VPN has been reconnected.\"}}" https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f
        echo.
    )

    set /a ahk_fail_count+=1

    if %ahk_fail_count% geq %max_retries% (
        echo AutoHotkey脚本启动次数达到%max_retries%次，检查是否需要发送通知...
        curl -H "Content-Type: application/json" -X POST -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Now Status code: !status!. AWS VPN has been reconnected multiple times.\"}}" https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f
        set ahk_fail_count=1
        echo.
    )
    
    if not "%fail_count%"=="1" (
        echo 当前失败次数：%fail_count%
    )else (
        echo 当前失败次数：0或1
    )
    set /a fail_count+=1

)else (
    set fail_count=1
    set ahk_fail_count=1
)

set /p ="等待1分钟后重新检测..." < nul
echo.
timeout /t 60

goto loop

goto :eof