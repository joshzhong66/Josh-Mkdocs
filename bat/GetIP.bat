::关闭回显
@echo off
::防止中文乱码
chcp 65001
::hostname

::%%i是for语句里面特有的变量，只有在批处理里面才写两个%%号表示变量(用1个会报错)，在cmd中则只用一个%号(用2个会报错)
::批处理中之所以用两个%%是因为编译器编译的时候要屏蔽一个%
for /f %%i in ('curl -s ifconfig.io')  do  ( set wanip=%%i )

::%%~表示删除引号
for /f "tokens=1,2,3 delims=={,}" %%a in ('wmic NICCONFIG where "IPEnabled='TRUE'" get DefaultIPGateway^,DNSServerSearchOrder^,IPAddress^,IPSubnet /value^|findstr "={"') do (
	if "%%a"=="DefaultIPGateway" (set "Gate=%%~b"
	) else if "%%a"=="DNSServerSearchOrder" (set "DNS1=%%~b"&set "DNS2=%%~c"
	) else if "%%a"=="IPAddress" (set "IP=%%~b"
	) else if "%%a"=="IPSubnet" (set "Mask=%%~b")
	if defined Gate if defined Mask goto :show	
)

:show
	echo; 计算机名: %USERDOMAIN%
	echo; 用户名：%USERNAME%
	echo; 本机内网IP: %IP%
	echo; 子网掩码: %Mask%
	echo; 默认网关: %Gate%
	echo; 首选 DNS: %DNS1%
	echo; 备用 DNS: %DNS2%
	echo; 公网出口IP: %wanip%
                  
pause
