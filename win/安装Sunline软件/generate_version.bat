@echo off

setlocal enabledelayedexpansion

:: ����1���������
echo ���ڼ��������ͨ��...
ping -n 3 mirrors.sunline.cn >nul
if errorlevel 1 (
    echo [����] ��������ʧ�ܣ�
    pause
    exit /b
)

:: ����2��������ҳ
echo ����������ҳ����...
powershell -Command "Invoke-WebRequest -Uri 'https://mirrors.sunline.cn/application/360zip/win/' -UseBasicParsing -OutFile 'webpage.html'"
if not exist "webpage.html" (
    echo [����] ������ҳʧ�ܣ�
    pause
    exit /b
)

:: ����3����������
echo ���ڽ�����������...
powershell -Command "(Get-Content 'webpage.html') -replace '<[^>]+>', '' | Select-String -Pattern '360zip_.*?\.exe' -AllMatches | %%{ $_.Matches } | %%{ $_.Value }" > links.txt

:: ����4����ȡ���
set "exe_file="
for /f "delims=" %%a in (links.txt) do (
    set "exe_file=%%a"
    echo �ҵ��ļ�: %%a
)

:: ����5��������ʱ�ļ�
del webpage.html links.txt >nul 2>&1

:: ����6����ȡ�汾�ţ��ؼ������㣩
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

echo [�ɹ�] ���°汾Ϊ: !version!
pause