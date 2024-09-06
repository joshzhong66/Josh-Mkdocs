# 源码编译openwrt



## **Openwrt软路由安装配置**

### **1、Openwrt软路由设备信息**

<1>登录信息：

IP：10.4.1.1

账号：root

密码：mjMJ@2020



<2>设备配置：

主机名    Openwrt

型号  ASUSTeK COMPUTER INC. Z9PA-U8 Series

CPU 型号 Intel(R) Xeon(R) CPU E5-2620 v2 @ 2.10GHz

CPU 规格 核心: 6 / 线程: 12

CPU 主频 1217.85MHz

固件版本  Openwrt Koolshare mod V2.36 r14941-67f6fa0a30

内核版本  5.4.52

内存      32GB



 <3>接口互联

 LAN<–> ROS-eth8（ros-eth8设置IP：10.4.1.10/24，配置上网、fenliu6）

 WAN<->PPPOE



### **2、Openwrt安装**

<1>安装并打开balenaEtcher

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/365f22b58bfa6ecae695fcdcb1635afb-image-20240424144500741-0202cb.png" alt="image-20240424144500741" style="zoom: 67%;" />

选择openwrt版本：

![image-20240424144509086](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/2b33cd1d917379b190a7338fee7c97aa-image-20240424144509086-9428a9.png)

<2>选择安装硬盘（u盘安装启动或硬盘写入：windows主机使用外接硬盘盒连接，删除原有全部分区，无需重新分区，直接写入），Flash直至完成即可。

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/5666662590e0b4a3aabeda18913b5c2d-image-20240424144523548-14e4b0.png" alt="image-20240424144523548" style="zoom:67%;" />

PS：<1>装载到主机，选择从该磁盘启动即可；    

​		<2>如弹出是否将磁盘格式化，取消就好。



### **3、配置登录**

```
Vi /etc/config/network  #更改网卡配置
LAN
Eth0
IP：10.4.1.1
netmask：255.255.255.0
dns：114.114.114.114
WAN：
                    Eth1
                    Proto：pppoe
                    Username：拨号账号
                    Password：拨号密码

ifup            #
etho 更新网络配置（字母o）
```



### **4、登录**

<1>通过web登录：网页访问10.4.1.1

<2>通过ssh登录：系统-管理权-SSH访问，接口：Lan，端口：22，保存应用；



### **5、安装Shadowsocks(影梭)**

PS：前提确保10.4.1.1可正常上网

先安装 shadowsocks-libev UDP-Relay 功能的依赖包 iptables-mod-tproxy

```
opkg update
```

```
opkg install iptables-mod-tproxy 
```

由于 OpenWrt 内建的 wget 不支持 TLS，无法下载 HTTPS 网站上的软件包，因此还要安装好整版的 wget 和 CA 证书软件，前者负责下载链接，后者提供 HTTPS 连接所需的根证书：

```
opkg install wget ca-certificates
```



安装 Shadowsocks：

​    wget http://openwrt-dist.sourceforge.net/packages/openwrt-dist.pub



​    opkg-key add openwrt-dist.pub

添加软件源到配置文件，注意务必将 x86_64 替换为你自己硬件的 CPU 架构名

```
opkg print-architecture  #用该命令查询CPU 架构名
```

架构如下：

```
arch x86_64 10   #X86_64为系统架构
vi /etc/opkg/customfeeds.conf  #将软件源添加至配置文件
src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/x86_64
src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci
```

安装shadowsocks-libev、luci-app-shadowsocks：

```
opkg update
opkg install shadowsocks-libev
opkg install luci-app-shadowsocks
```

安装如下软件包：

```
opkg install shadowsocks-libev-ss-local shadowsocks-libev-ss-redir shadowsocks-libev-ss-rules shadowsocks-libev-ss-tunnel
```

如果需要 Luci Web 界面还要安装：

```
opkg install luci-app-shadowsocks-libev
```



### **6、安装ChinaDNS**

用软件源安装 如果先前安装

shadowsocks-libev 时已添加了 openwrt-dist 源 ，可直接命令行安装 ChinaDNS

```
opkg install ChinaDNS
opkg install luci-app-chinadns
```

安装完成后立即更新

ChinaDNS 的国内 IP 路由表 /etc/chinadns_chnroute.txt

 ipip.net：

```
wget https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt
```

使用

crontab -e 命令编辑 cron 任务计划，每月（1 号凌晨 3 点）更新

chinadns_chnroute.txt，编辑内容如下：

```
#For ipip.net
0 3 1 * *    wget https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt
```

编辑完成后启用 cron 程序：

```
/etc/init.d/cron start
/etc/init.d/cron enable
```

验证

crontab 任务是否正确执行：

```
logread | grep crond
```



### 7、配置上网

<1>编辑配置文件，输入shadowsocks服务器信息

```
	vi /etc/config/shadowsocks
config
servers
  option
alias '8.210.121.126'
  option
group 'Default'
  option
type 'ss'
  option
fast_open '0'
  option
no_delay '0'
  option
server '8.210.121.126'
  option
server_port '11888'
  option
timeout '60'
  option
password 'jeff.123'
  option encrypt_method 'aes-256-gcm'
```

- 网络－> DHCP/DNS，基本设置里将本地服务器更改为：127.0.0.1#5353，HOSTS和解析文件里勾选“忽略解析文件”和“忽略HOSTS文件”
- 服务－> ChinaDNS里ChinaDNS上游服务器更改为：114.114.114.114,127.0.0.1:5300     
- 服务-影梭-透明代理-选择<主服务器>，UPD服务停用