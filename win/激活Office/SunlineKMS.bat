@echo off
title Sunline KMS
mode con: cols=61 lines=40
color 0A
setlocal EnableDelayedExpansion

:: ����KMS������
set KMS_SERVER=kms2.sunline.cn
:: ��ȡϵͳ�汾��Ϣ
for /f "tokens=4-5 delims=[]. " %%i in ('ver') do (
    set VERSION=%%i.%%j
)
:: ��ȡϵͳ�汾�ַ���
for /f "tokens=*" %%i in ('wmic os get caption ^| findstr /i "Windows"') do (
    set OS_CAPTION=%%i
)

:MENU
cls
echo.
echo ===========================================================
echo                   Sunline KMS �����
echo.
echo    ��Ҫ�Թ���Ա��ʽ���д˹��ߣ�����������ϵ��Ϣ��ά��
echo ===========================================================
echo.
echo ��ǰϵͳ: !OS_CAPTION!
echo ϵͳ�汾��: !VERSION!
echo.
echo ��ѡ����Ҫ����İ汾��
echo.
echo 1. Windows 7 Professional
echo 2. Windows 10 Professional
echo 3. Windows 10 Enterprise
echo 4. Windows 11 Professional
echo 5. Windows 11 Enterprise
echo.
set /p choice=�������Ӧ���֣�1-5���� 

:: ���� GVLK
set "GVLK="
if "%choice%"=="1" set GVLK=FJ82H-XT6CR-J8D7P-XQJJ2-GPDD4
if "%choice%"=="2" set GVLK=W269N-WFGWX-YVC9B-4J6C9-T83GX
if "%choice%"=="3" set GVLK=NPPR9-FWDCX-D2C8J-H872K-2YT43
if "%choice%"=="4" set GVLK=W269N-WFGWX-YVC9B-4J6C9-T83GX
if "%choice%"=="5" set GVLK=NPPR9-FWDCX-D2C8J-H872K-2YT43

if not defined GVLK (
  echo.
  echo ѡ����Ч����������ȷ���֣�1-5��...
  pause
  goto MENU
)

:: ִ�м�������
echo.
echo ���� GVLK ��Կ: !GVLK!
cscript //nologo %windir%\system32\slmgr.vbs /ipk !GVLK!
ping =n 3 127.1 > nul
echo ���� KMS ��������ַ: %KMS_SERVER%
cscript //nologo %windir%\system32\slmgr.vbs /skms %KMS_SERVER%
ping =n 3 127.1 > nul
echo ���ڼ���...
cscript //nologo %windir%\system32\slmgr.vbs /ato
ping =n 3 127.1 > nul
echo.
echo ����״̬���£�
cscript //nologo %windir%\system32\slmgr.vbs /xpr

pause
exit
