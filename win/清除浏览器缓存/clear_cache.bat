@echo off
echo 正在清理 Edge / Chrome / Brave / Opera 的缓存...
taskkill /F /IM chrome.exe /IM msedge.exe /IM opera.exe /IM brave.exe 2>nul
timeout /t 2 >nul

:: 清除缓存
rd /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
rd /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache"
rd /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache"
rd /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Code Cache"
rd /s /q "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache"
rd /s /q "%LocalAppData%\Opera Software\Opera Stable\Cache"

:: 重新创建缓存目录
md "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
md "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache"
md "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache"
md "%LocalAppData%\Opera Software\Opera Stable\Cache"

echo 清理完成！
pause
exit
