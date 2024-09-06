# Mikrotik路由器命令



..			回到上一级

interface print		查看端口状态

ip address print	查看接口ip地址

ip address print	查看licese

ip address print	查看路由表

/log print		查看日志

![image-20240424155421775](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/de329e7360a1c4207e39df1e68bca360-image-20240424155421775-4415c6.png)

#### **系统备份**

system backup  >save name=test     #将当前配置保存到test

file print  #查看保存的文件

system backup > load name=test  #导入备份文件test



#### 系统复位

/system> reset-configuration #清除掉路由器的所有配置，包括登陆的账号和密码（恢复为“admin“和空密码）IP 地址和其他配置将会被抹去，在reset 指令执行后路由器将会重启。RouterOS v3.x 后版本，在复位后默认的ether1 接口IP 地址将设置为192.168.88.1/24



#### 系统重启与关机

system reboot

system shutdown

**查看修改Ros名称**

system identity print   #查看ros名称

system identity set name=Gateway    #修改ros名称