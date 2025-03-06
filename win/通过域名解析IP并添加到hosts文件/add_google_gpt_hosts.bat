@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 > nul

:: 设置 hosts 文件路径
set HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts

:: 写入内容到 hosts 文件
echo.>> %HOSTS_FILE%
echo #-------Goolge--------                                   >> %HOSTS_FILE%
echo 142.250.71.238 docs.google.com                           >> %HOSTS_FILE%
echo 142.250.71.170 addons-pa.clients6.google.com             >> %HOSTS_FILE%
echo 142.250.71.142 apps.google.com                           >> %HOSTS_FILE%
echo 142.250.71.142 ogs.google.com                            >> %HOSTS_FILE%
echo 142.250.71.142 sheets.google.com                         >> %HOSTS_FILE%
echo 142.250.71.131 google.com.hk                             >> %HOSTS_FILE%
echo 142.250.76.3 www.google.com.hk                           >> %HOSTS_FILE%
echo 142.250.76.238 ogs.google.com.hk                         >> %HOSTS_FILE%
echo 142.250.76.238 translate.google.com                      >> %HOSTS_FILE%
echo 142.250.76.238 translate.google.com.hk                   >> %HOSTS_FILE%
echo 142.250.196.196 google.com                               >> %HOSTS_FILE%
echo 142.250.196.196 www.google.com                           >> %HOSTS_FILE%
echo 142.250.197.170 ogads-pa.clients6.google.com             >> %HOSTS_FILE%
echo 142.250.197.206 calendar.google.com                      >> %HOSTS_FILE%
echo 142.250.197.14 apis.google.com                           >> %HOSTS_FILE%
echo 142.250.197.163 id.google.com                            >> %HOSTS_FILE%
echo 142.250.197.163 id.google.com.hk                         >> %HOSTS_FILE%
echo 142.250.197.110 meet.google.com                          >> %HOSTS_FILE%
echo 142.250.197.238 drive.google.com                         >> %HOSTS_FILE%
echo 142.250.197.206 lh3.google.com                           >> %HOSTS_FILE%
echo 142.250.198.123 storage.googleapis.com                   >> %HOSTS_FILE%
echo 142.250.198.142 clients6.google.com                      >> %HOSTS_FILE%
echo 142.250.198.138 youtube.googleapis.com                   >> %HOSTS_FILE%
echo 142.250.198.106 feedback-pa.clients6.google.com          >> %HOSTS_FILE%
echo 142.250.198.65 lh3.googleusercontent.com                 >> %HOSTS_FILE%
echo 142.250.198.78 slides.google.com                         >> %HOSTS_FILE%
echo 142.250.198.78 gds.google.com                            >> %HOSTS_FILE%
echo 142.250.198.78 play.google.com                           >> %HOSTS_FILE%
echo 142.250.198.74 people-pa.clients6.google.com             >> %HOSTS_FILE%
echo 142.250.198.65 drive-thirdparty.googleusercontent.com    >> %HOSTS_FILE%
echo 142.250.198.110 dl.google.com                            >> %HOSTS_FILE%
echo 142.250.217.110 workspace.google.com                     >> %HOSTS_FILE%
echo 142.250.198.110 developers.google.com                    >> %HOSTS_FILE%
echo 142.250.217.74 drivefrontend-pa.clients6.google.com      >> %HOSTS_FILE%
echo 142.250.217.74 waa-pa.clients6.google.com                >> %HOSTS_FILE%
echo 142.250.217.106 ogads-pa.googleapis.com                  >> %HOSTS_FILE%
echo 142.250.217.106 signaler-pa.clients6.google.com          >> %HOSTS_FILE%
echo 142.250.198.202 scone-pa.clients6.google.com             >> %HOSTS_FILE%
echo 142.250.157.94 accounts.google.com.hk                    >> %HOSTS_FILE%
echo 64.233.188.84 myaccount.google.com                       >> %HOSTS_FILE%
echo 64.233.189.84 accounts.google.com                        >> %HOSTS_FILE%
echo 113.108.239.225 fonts.googleapis.com                     >> %HOSTS_FILE%
echo #-------Google Meet WebRTC:3478--------                  >> %HOSTS_FILE%
echo #142.250.82.223                                          >> %HOSTS_FILE%
echo #142.250.82.249                                          >> %HOSTS_FILE%
echo #142.250.82.252                                          >> %HOSTS_FILE%
echo #142.250.82.219                                          >> %HOSTS_FILE%
echo #142.250.82.215                                          >> %HOSTS_FILE%
echo #142.250.82.211                                          >> %HOSTS_FILE%
echo #74.125.250.247                                          >> %HOSTS_FILE%
echo #74.125.250.255                                          >> %HOSTS_FILE%
echo #-------ChatGPT--------                                  >> %HOSTS_FILE%
echo 104.18.33.45  openai.com                                 >> %HOSTS_FILE%
echo 104.18.32.47 chatgpt.com                                 >> %HOSTS_FILE%
echo 104.18.32.47 ab.chatgpt.com                              >> %HOSTS_FILE%
echo 104.18.41.241 auth.openai.com                            >> %HOSTS_FILE%
echo 104.18.35.28 auth0.openai.com                            >> %HOSTS_FILE%
echo 104.18.41.158 cdn.oaistatic.com                          >> %HOSTS_FILE%
echo 104.18.95.41 challenges.cloudflare.com                   >> %HOSTS_FILE%
echo 13.33.183.51 tcr9i.chat.openai.com                       >> %HOSTS_FILE%

echo 已成功写入到 hosts 文件
pause
