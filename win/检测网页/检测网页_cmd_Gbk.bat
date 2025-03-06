@echo off
chcp 65001 >nul
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 936 >nul

set /a counter=0

:loop
echo.
set /p ="正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F..." < nul

echo.
curl -s -o NUL -w "%%{http_code}" https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F > result.txt

::type result.txt
set /p status=<result.txt

set /p ="收到的状态码：%status%" < nul
echo.

if not "%status%"=="200" (
    echo 状态码不是200，检查是否需要发送通知...
    set /p ="当前消息发送计数器：%counter%" < nul
    echo.
    if "%counter%"=="0" (
        set /p ="发送通知..." < nul
        echo.
        curl -H "Content-Type: application/json" -X POST -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%\"}}" https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f
        set /a counter=60
        set /p ="消息发送计数器设置为：%counter%" < nul
        echo.
    ) else (
        set /p ="未发送通知，仅减少计数器" < nul
        echo.
        set /a counter-=1
        set /p ="消息发送计数器减少，当前值：%counter%" < nul
        echo.
    )
) else (
    set /p ="网站正常访问，停止计数。" < nul
	echo.
    if "%counter%" neq "0" (
        set /a counter=0
        set /p ="消息发送计数器重置为：0" < nul
        echo.
    )
)

set /p ="等待1分钟后重新检测..." < nul
echo.
timeout /t 60

goto loop