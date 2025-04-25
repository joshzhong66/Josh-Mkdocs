@echo off
title Sunline KMS
mode con: cols=61 lines=40
color 0A
setlocal EnableDelayedExpansion

:: 设置KMS服务器
set KMS_SERVER=kms2.sunline.cn
:: 获取系统版本信息
for /f "tokens=4-5 delims=[]. " %%i in ('ver') do (
    set VERSION=%%i.%%j
)
:: 获取系统版本字符串
for /f "tokens=*" %%i in ('wmic os get caption ^| findstr /i "Windows"') do (
    set OS_CAPTION=%%i
)

:MENU
cls
echo.
echo ===========================================================
echo                   Sunline KMS 激活工具
echo.
echo    需要以管理员方式运行此工具，如有问题联系信息运维部
echo ===========================================================
echo.
echo 当前系统: !OS_CAPTION!
echo 系统版本号: !VERSION!
echo.
echo 请选择你要激活的版本：
echo.
echo 1. Windows 7 Professional
echo 2. Windows 10 Professional
echo 3. Windows 10 Enterprise
echo 4. Windows 11 Professional
echo 5. Windows 11 Enterprise
echo.
set /p choice=请输入对应数字（1-5）： 

:: 设置 GVLK
set "GVLK="
if "%choice%"=="1" set GVLK=FJ82H-XT6CR-J8D7P-XQJJ2-GPDD4
if "%choice%"=="2" set GVLK=W269N-WFGWX-YVC9B-4J6C9-T83GX
if "%choice%"=="3" set GVLK=NPPR9-FWDCX-D2C8J-H872K-2YT43
if "%choice%"=="4" set GVLK=W269N-WFGWX-YVC9B-4J6C9-T83GX
if "%choice%"=="5" set GVLK=NPPR9-FWDCX-D2C8J-H872K-2YT43

if not defined GVLK (
  echo.
  echo 选择无效，请输入正确数字（1-5）...
  pause
  goto MENU
)

:: 执行激活流程
echo.
echo 设置 GVLK 密钥: !GVLK!
cscript //nologo %windir%\system32\slmgr.vbs /ipk !GVLK!
ping =n 3 127.1 > nul
echo 设置 KMS 服务器地址: %KMS_SERVER%
cscript //nologo %windir%\system32\slmgr.vbs /skms %KMS_SERVER%
ping =n 3 127.1 > nul
echo 正在激活...
cscript //nologo %windir%\system32\slmgr.vbs /ato
ping =n 3 127.1 > nul
echo.
echo 激活状态如下：
cscript //nologo %windir%\system32\slmgr.vbs /xpr

pause
exit
