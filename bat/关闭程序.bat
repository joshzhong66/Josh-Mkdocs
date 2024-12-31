@echo off
::将禁用批处理脚本中的默认ANSI编码，同时设置编码为UTF-8（chcp 65001）
chcp 65001

:: 关闭程序(.exe是您要关闭的程序的文件名。如果您要关闭不同的程序，请替换成相应的文件名。)
taskkill /f /im cloudmusic.exe
echo 网易云音乐已关闭

taskkill /f /im DingtalkLauncher.exe
echo 钉钉已关闭

taskkill /f /im QQScLauncher.exe
echo qq已关闭


taskkill /f /im WeChat.exe
echo 微信已关闭

taskkill /f /im 有道云笔记.exe
echo 有道云笔记已关闭

taskkill /f /im Snipaste.exe
taskkill /f /im Everything.exe
taskkill /f /im Foxmail.exe


echo 所有程序已成功关闭
pause