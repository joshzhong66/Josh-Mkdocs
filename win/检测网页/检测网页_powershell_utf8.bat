@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 > nul

set /a counter=0

:loop
echo.
echo 正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F...

echo.
curl -s -o NUL -w "%%{http_code}" https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F > result.txt

::type result.txt
set /p status=<result.txt

echo 收到的状态码：%status%


if not "%status%"=="200" (
    echo 状态码不是200，检查是否需要发送通知...
    echo 当前消息发送计数器：%counter%
	
    if "%counter%"=="0" (
        echo 发送通知...
		
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$OutputEncoding = New-Object System.Text.UTF8Encoding; Invoke-RestMethod -Uri 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f' -Method Post -ContentType 'application/json' -Body (@{msgtype='text'; text=@{content='The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%'}} | ConvertTo-Json)"
		set /a counter=60
		
        echo 消息发送计数器设置为：%counter%
    ) else (
        echo 未发送通知，仅减少计数器
		
        set /a counter-=1
		
        echo 消息发送计数器减少，当前值：%counter%
    )
) else (
    echo 网站正常访问，停止计数。
	
    if "%counter%" neq "0" (
        set /a counter=0
		
		echo 消息发送计数器重置为：0
    )
)

echo 等待1分钟后重新检测...

timeout /t 60

goto loop