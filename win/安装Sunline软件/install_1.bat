@echo off
setlocal enabledelayedexpansion
color 0A

:: cd %USERPROFILE%\Downloads
:: curl -o ChromeStandaloneSetup64.exe http://10.22.51.64/1_Software/Sunline_Base/ChromeStandaloneSetup64.exe
:: start /wait FileZilla_3.67.0_win64-setup.exe /S /D=D:\Software\FileZilla
:: mklink "%USERPROFILE%\Desktop\FileZilla.lnk" "D:\Software\FileZilla\filezilla.exe"

openfiles >nul 2>nul || (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c ""%~f0""' -Verb RunAs"
    exit /b
)

set "targetDir=D:\Program Files"

if not exist "%targetDir%" (
    echo 目录不存在，正在创建：%targetDir%
    mkdir "%targetDir%"
) else (
    echo 目录已存在：%targetDir%
)



cd %USERPROFILE%\Downloads

echo 正在下载软件...
curl -s -o ChromeStandaloneSetup64.exe http://10.22.51.64/1_Software/Sunline_Base/ChromeStandaloneSetup64.exe >nul
if %ERRORLEVEL%==0 (
    echo 下载ChromeStandaloneSetup64.exe成功！
) else (
    echo 下载ChromeStandaloneSetup64.exe失败！
)
echo 正在安装Google Chrome...
ChromeStandaloneSetup64.exe /silent /install

curl -s -o FileZilla_3.67.0_win64-setup.exe http://10.22.51.64/1_Software/Sunline_Base/FileZilla_3.67.0_win64-setup.exe >nul
if %ERRORLEVEL%==0 (
    echo 下载FileZilla_3.67.0_win64-setup.exe成功！
) else (
    echo 下载FileZilla_3.67.0_win64-setup.exe失败！
)
echo 正在安装FileZilla...
start /wait FileZilla_3.67.0_win64-setup.exe /S /D=D:\Program Files\FileZilla
:: 创建快捷方式
mklink "%USERPROFILE%\Desktop\FileZilla.lnk" "D:\Program Files\FileZilla\filezilla.exe"

curl -s -o FoxmailSetup_7.2.25.375.exe http://10.22.51.64/1_Software/Sunline_Base/FoxmailSetup_7.2.25.375.exe >nul
if %ERRORLEVEL%==0 (
    echo 下载FoxmailSetup_7.2.25.375.exe成功！
) else (
    echo 下载FoxmailSetup_7.2.25.375.exe失败！
)
echo 正在安装Foxmail...
start /wait FoxmailSetup_7.2.25.375.exe D:\Program Files\Foxmail -silent

curl -s -o 360zip_setup_4.0.0.1470.exe http://10.22.51.64/1_Software/Sunline_Base/360zip_setup_4.0.0.1470.exe >nul
if %ERRORLEVEL%==0 (
    echo 下载360zip_setup_4.0.0.1470.exe成功！
) else (
    echo 下载360zip_setup_4.0.0.1470.exe失败！
)
echo 正在安装360zip...
start /wait 360zip_setup_4.0.0.1470.exe /S 

curl -s -o WPS_Setup_20784-12.1.0.20784.exe http://10.22.51.64/1_Software/Sunline_Base/WPS_Setup_20784-12.1.0.20784.exe >nul
if %ERRORLEVEL%==0 (
    echo 下载WPS_Setup_20784-12.1.0.20784.exe成功！
) else (
    echo 下载WPS_Setup_20784-12.1.0.20784.exe失败！

)
echo 正在安装WPS...
WPS_Setup_20784-12.1.0.20784.exe /S -agreelicense /D="D:\Program Files\WPS"

curl -s -o WeChatSetup-3.9.12.exe http://10.22.51.64/1_Software/Sunline_Base/WeChatSetup-3.9.12.exe >nul
if %ERRORLEVEL%==0 (
    echo 下载WeChatSetup-3.9.12.exe成功！
) else (
    echo 下载WeChatSetup-3.9.12.exe失败！
)
echo 正在安装微信...
start /wait WeChatSetup-3.9.12.exe /S

curl -s -o WeCom_4.1.36.6012.exe http://10.22.51.64/1_Software/Sunline_Base/WeCom_4.1.36.6012.exe >nul
if %ERRORLEVEL%==0 (
    echo 下载WeCom_4.1.36.6012.exe成功！
) else (
    echo 下载WeCom_4.1.36.6012.exe失败！
)
echo 正在安装企业微信...
start /wait WeCom_4.1.36.6012.exe /S

curl -s -o sogou_pinyin_guanwang_15.3a.exe http://10.22.51.64/1_Software/Sunline_Base/sogou_pinyin_guanwang_15.3a.exe >nul
if % ERRORLEVEL%==0 (
    echo 下载sogou_pinyin_guanwang_15.3a.exe成功！
) else (
    echo 下载sogou_pinyin_guanwang_15.3a.exe失败！
)
echo 正在安装搜狗输入法...
start /wait sogou_pinyin_guanwang_15.3a.exe /S

curl -s -o sysdiag-all-x64-6.0.5.6-2025.04.12.2.exe http://10.22.51.64/1_Software/Sunline_Base/sysdiag-all-x64-6.0.5.6-2025.04.12.2.exe >nul
if %ERRORLEVEL%==0 (
    echo 下载sysdiag-all-x64-6.0.5.6-2025.04.12.2.exe成功！
) else (
    echo 下载sysdiag-all-x64-6.0.5.6-2025.04.12.2.exe失败！
)
echo 正在安装火绒
start /wait sysdiag-all-x64-6.0.5.6-2025.04.12.2.exe /S

pause