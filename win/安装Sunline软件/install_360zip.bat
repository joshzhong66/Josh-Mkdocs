@echo off
setlocal enabledelayedexpansion

:: ����Ƿ���й���ԱȨ��
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo �������ԱȨ��...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

echo ���ڼ��������ͨ��...
ping -n 3 mirrors.sunline.cn >nul
if errorlevel 1 (
    echo [����] ��������ʧ�ܣ�
    pause
    exit /b
)

echo ����������ҳ����...
powershell -Command "Invoke-WebRequest -Uri 'https://mirrors.sunline.cn/application/360zip/win/' -UseBasicParsing -OutFile 'webpage.html'"
if not exist "webpage.html" (
    echo [����] ������ҳʧ�ܣ�
    pause
    exit /b
)

echo ���ڽ�����������...
powershell -Command "(Get-Content 'webpage.html') -replace '<[^>]+>', '' | Select-String -Pattern '360zip_.*?\.exe' -AllMatches | %%{ $_.Matches } | %%{ $_.Value }" > links.txt

set "exe_file="
for /f "delims=" %%a in (links.txt) do (
    set "exe_file=%%a"
    echo �ҵ��ļ�: %%a
)

del webpage.html links.txt >nul 2>&1

if defined exe_file (
    for /f "tokens=3 delims=_" %%v in ("%exe_file%") do (
        set "version=%%v"
        set "version=!version:.exe=!"
        echo ��ȡ�İ汾��: !version!
    )
) else (
    echo [����] δ�ҵ���Ч��exe�ļ���
    pause
    exit /b
)

echo �������ذ�װ����...
set "download_url=https://mirrors.sunline.cn/application/360zip/win/%exe_file%"
powershell -Command "Start-BitsTransfer -Source '!download_url!' -Destination '!exe_file!'"

::powershell -Command "Invoke-WebRequest -Uri '!download_url!' -OutFile '!exe_file!'"
if not exist "!exe_file!" (
    echo [����] ��װ��������ʧ�ܣ�
    pause
    exit /b
)

echo ���ڰ�װ 360ѹ��...
start /wait "" "!exe_file!" /S

:: ��ѡ����װ��ɾ����װ��
del "!exe_file!" >nul 2>&1

echo [�ɹ�] ����� 360ѹ�� ��װ���汾: !version!
pause
