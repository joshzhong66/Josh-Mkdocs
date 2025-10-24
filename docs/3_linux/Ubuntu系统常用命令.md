# ubuntu常用命令



```bash
apt-get
apt-get update                			# 更新包管理工具
sudo apt-get install openssh-server    	# 安装openssh-server远程

开关防火墙
sudo apt-get install ufw    			# 安装防火墙
sudo ufw enable            				# 启用防火墙
sudo ufw disable        				# 关闭防火墙
sudo ufw status            				# 查看防火墙状态
sudo ufw default deny        			# 默认的 incoming 策略更改为 “deny”
sudo ufw allow smtp        				# 允许所有的外部IP访问本机的25/tcp (smtp)端口
sudo ufw allow 22/tcp        			# 允许所有的外部IP访问本机的22/tcp (ssh)端口


sudo -i									# 获取root权限


sudo vim /etc/network/interfaces		# 配置静态IP
auto ens3
iface ens3 inet static
address 192.168.31.161
netmask 255.255.255.0
gateway 192.168.31.1
reboot
```

