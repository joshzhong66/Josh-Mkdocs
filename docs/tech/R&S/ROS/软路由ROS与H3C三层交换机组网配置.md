# 软路由ROS与H3C三层交换机组网配置



### **网络拓扑图**

![image-20240424161423825](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/c2f733f88a5ddf080385e43c258118a8-image-20240424161423825-f1ac19.png)



### **ROS的配置**

#### **第一步：定义Ros的WAN口及LAN口**

将ether1定义为WAN口，连接光猫

![image-20240424161413221](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/f009263f4d8e94a09eefabda6b31761a-image-20240424161413221-0d67fb.png)

ether2定义为LAN口，连接三层交换机

![image-20240424161429295](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/28958d7c2edfb3602216d2de50cc0219-image-20240424161429295-7c594b.png)

#### **第二步 ：在Ros上添加PPPOE Client**

在Interface接口视图下，选择" + " 添加一个PPPOE Client 

![image-20240424161440726](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/a6211811494ddddd7cdaee74dd1cf1d8-image-20240424161440726-d6cdcd.png)

在General窗口，修改name及Interface两项

name ：PPPOE的名称（可自定义）

Interface ：选择WAN口（WAN口）

![image-20240424161447533](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/933958c1141f2590040d8bb17bb5d74a-image-20240424161447533-f46b9f.png)

在Dial Out窗口下，输入user 及 password

User：PPPOE账号

Password：PPPOE密码

默认勾选User peer DNS（DNS服务器）  及 Add Default Route（默认路由）），勾选后，无需手动添加DNS及静态路由，即可访问Internet。

![image-20240424161453603](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/2588bb4700a883665557b0a3257ca6b9-image-20240424161453603-6c3f50.png)

在**IP**视图的**Addresses**窗口，单击 " **+** " 添加 **ether2-LAN**的接口地址：**192.168.10.1/24**

![image-20240424161503382](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/460633890c3f61752617d3382af491a4-image-20240424161503382-3a551d.png)

#### **第三步： 伪装（NAT）**

在IP接口视图下，打开**Firewall**窗口的NAT，选择” + “ 添加

分别需要为每个网段都设置一条NAT

![image-20240424161514218](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/5d27719f2eb41ef91fe8fd9977399cbb-image-20240424161514218-ea1f3b.png)

为192.168.200.0/24网段添加一条伪装

![image-20240424161519881](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/86959e30648954f847676220be98b540-image-20240424161519881-099480.png)

masquerade 伪装

![image-20240424161531343](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/c63863445cc76ecd71fe7882e15f9508-image-20240424161531343-14f814.png)

#### **第四步 ： 添加回程路由**

在IP-Routes视图下，

DST address(目标网段)：192.168.100.0/24

Gatway（LAN口及LAN口IP），相当于下一跳地址。：LAN

需要分别为每个网段添加回程路由（否则流量无法到达该VLAN，会导致出去的包回不来哦）

![image-20240424161543158](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/75d44c45b63fa63f47c879b9fe398c63-image-20240424161543158-01591f.png)



### **H3C三层交换机配置**

第一步：创建3个VLAN 10 100 200，设置vlan虚接口的IP（网关）

```
VLAN 100                      #创建VLAN
interface vlan-interface 10   #vlan虚接口10
ip address 192.168.10.1/24    #配置接口IP
```

第二步：将接口加入VLAN，设置为Access口

```
inter g1/0/20               #进入接口20
port link-type access       #接口类型设置为access
port access vlan 100        #接口加入VLAN100
```

第三步：配置一条默认路由（将所以流量交给下一跳地址192.168.10.1）

```
ip route-static 0.0.0.0 0 192.168.10.1  #静态路由
```

交换机配置如下：

```

#
 version 5.20, Release 2222P10
#
 sysname H3C
#
 irf mac-address persistent timer
 irf auto-update enable
 undo irf link-delay
#
 domain default enable system
#
 web idle-timeout 30
#
 password-recovery enable
#
vlan 1
#
vlan 10
#
vlan 100
#
vlan 200
#
domain system   
 access-limit disable
 state active   
 idle-cut disable
 self-service-url disable
#               
dhcp server ip-pool 10
 network 192.168.10.0 mask 255.255.255.0
 gateway-list 192.168.10.1
#               
user-group system
 group-attribute allow-guest
#               
local-user abc  
 password cipher $c$3$3O3TRePwLP0yAqW37DGX1h4rfkdIGQ==
 authorization-attribute level 3
 service-type ftp
local-user admin
 password cipher $c$3$Zn/sUTHSf0+ria4SnwGKiPjLfdwXUt7C
 authorization-attribute level 3
 service-type web
local-user root 
 password cipher $c$3$4eOQFNifn3uQrpYkYQovG6LThLqFT2Rcc0VD
 service-type telnet
 service-type web
#               
vlan-group n1   
#               
interface NULL0 
#               
interface Vlan-interface1
 ip address 172.16.1.1 255.255.255.0
 undo dhcp select server global-pool
#               
interface Vlan-interface10
 ip address 192.168.10.2 255.255.255.0
#               
interface Vlan-interface100
 ip address 192.168.100.1 255.255.255.0
#               
interface Vlan-interface200
 ip address 192.168.200.1 255.255.255.0
#               
interface GigabitEthernet1/0/1
#               
interface GigabitEthernet1/0/2
#               
interface GigabitEthernet1/0/3
#               
interface GigabitEthernet1/0/4
#               
interface GigabitEthernet1/0/5
#               
interface GigabitEthernet1/0/6
#               
interface GigabitEthernet1/0/7
#               
interface GigabitEthernet1/0/8
#               
interface GigabitEthernet1/0/9
#               
interface GigabitEthernet1/0/10
#               
interface GigabitEthernet1/0/11
 port access vlan 200
#               
interface GigabitEthernet1/0/12
 port access vlan 100
#               
interface GigabitEthernet1/0/13
#               
interface GigabitEthernet1/0/14
#               
interface GigabitEthernet1/0/15
#               
interface GigabitEthernet1/0/16
#               
interface GigabitEthernet1/0/17
#               
interface GigabitEthernet1/0/18
#               
interface GigabitEthernet1/0/19
#               
interface GigabitEthernet1/0/20
 port access vlan 10
#               
interface GigabitEthernet1/0/21
#               
interface GigabitEthernet1/0/22
#               
interface GigabitEthernet1/0/23
#               
interface GigabitEthernet1/0/24
 port link-type trunk
 port trunk permit vlan all
#               
interface GigabitEthernet1/0/25
 shutdown       
#               
interface GigabitEthernet1/0/26
 shutdown       
#               
interface GigabitEthernet1/0/27
 shutdown       
#               
interface GigabitEthernet1/0/28
 shutdown       
#               
rip 1           
 network 192.168.101.0
 network 192.168.102.0
 network 192.168.103.0
 network 10.0.0.0
#               
 ip route-static 0.0.0.0 0.0.0.0 10.0.8.1
 ip route-static 0.0.0.0 0.0.0.0 192.168.10.1
#               
 dhcp enable    
#               
 ftp server enable
#               
 load xml-configuration
#               
user-interface aux 0
 authentication-mode password
 set authentication password cipher $c$3$KcMReVoIeZfuRWS6GZQmpte0jZycfXExsQ==
user-interface vty 0 15
#               
return   
```



最终，测试每个网段互通的问题，全部互通