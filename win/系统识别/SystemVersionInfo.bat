@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 获取 ProductName
for /f "tokens=2,*" %%a in (
    'reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul ^| findstr /i "Windows"'
) do (
    set "ProductName=%%b"
)

:: 获取 EditionID
for /f "tokens=2,*" %%a in (
    'reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul'
) do (
    set "EditionID=%%b"
)

:: 获取 CurrentBuild
for /f "tokens=2,*" %%a in (
    'reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul'
) do (
    set "Build=%%b"
)

:: 判断主版本
if !Build! GEQ 22000 (
    set "OSMajor=Windows 11"
) else (
    set "OSMajor=Windows 10"
)

:: 设置完整系统信息
set "FullVersion=!OSMajor! !EditionID! (Build !Build!)"

:: 识别中文友好名称
set "DisplayName=未知版本"

if /i "!OSMajor!"=="Windows 11" (
    if /i "!EditionID!"=="Professional" set "DisplayName=Windows 11 专业版"
    if /i "!EditionID!"=="Core" set "DisplayName=Windows 11 家庭版"
    if /i "!EditionID!"=="CoreCountrySpecific" set "DisplayName=Windows 11 家庭中文版"
    if /i "!EditionID!"=="Education" set "DisplayName=Windows 11 教育版"
    if /i "!EditionID!"=="Enterprise" set "DisplayName=Windows 11 企业版"
)

if /i "!OSMajor!"=="Windows 10" (
    if /i "!EditionID!"=="Professional" set "DisplayName=Windows 10 专业版"
    if /i "!EditionID!"=="Core" set "DisplayName=Windows 10 家庭版"
    if /i "!EditionID!"=="CoreCountrySpecific" set "DisplayName=Windows 10 家庭中文版"
    if /i "!EditionID!"=="Education" set "DisplayName=Windows 10 教育版"
    if /i "!EditionID!"=="Enterprise" set "DisplayName=Windows 10 企业版"
)

:: 输出信息
echo 系统信息: !FullVersion!
echo 中文版本: !DisplayName!

:: 保持窗口打开
timeout /t -1 >nul
endlocal
