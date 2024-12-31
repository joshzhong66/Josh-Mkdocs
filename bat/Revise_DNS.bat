#创建文件 dns.bat
#右键-以管理员身份运行即可，以太网改为你的网络名称
#关闭360杀毒软件

@echo off
chcp 65001
netsh interface ip set dnsservers "以太网" static 114.114.114.114 primary
netsh interface ip add dnsservers "以太网" 8.8.8.8 index=2 
ipconfig /flushdns
