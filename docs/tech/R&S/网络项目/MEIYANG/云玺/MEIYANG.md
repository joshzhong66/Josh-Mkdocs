

设备基础配置

```
undo password-control aging enable
undo password-control length enable
undo password-control history enable
undo password-control composition enable
undo password-control complexity user-name check
undo password-control change-password first-login enable 


ip http enable
ip https enable
ssh server enable
telnet server enable 


user-interface 	vty 0 63
authentication-mode scheme 
user-role level-15


local-user meiyang class manage
password simple Meiyang123..
service-type telnet ssh terminal http https
authorization-attribute user-role network-admin

```





### 网段规划

```
28F网段（暂未配置）
192.168.0.0/24--Vlan10		192.168.0.1/24


群晖服务器IP--排除，dns设置两个
192.168.0.162


29F网段
192.168.1.0/24--Vlan11		192.168.1.1/24

30F网段
192.168.2.0/24--Vlan12		192.168.2.1/24	


31F网段
192.168.3.0/24--Vlan13		192.168.3.1/24



监控网段
192.168.6.0/24--Vlan16		192.168.6.1/24

无线网段
192.168.40.0/23--Vlan400		192.168.40.1/23


路由网段----VLAN100
192.168.10.2 ---核心G1/0/1接路由器g2/1


设备管理网段(VLAN1000)
192.168.10.1   主路由地址
192.168.100.1 ---30F核心交换机管理地址
192.168.100.2 ---30F核心交换机2管理地址
192.168.100.3 ---ac无线管理地址
192.168.100.4 ---29F核心交换机管理地址



WiFi账户：MEIYANG
密码：my666888

```





### 主路由接口

```python
<Router-30F>disp inter br
Brief information on interfaces in route mode:
Link: ADM - administratively down; Stby - standby
Protocol: (s) - spoofing
Interface            Link Protocol Primary IP      Description                
Dia0                 UP   UP       100.64.11.253   
Dia1                 UP   UP       100.64.123.122  
Dia2                 UP   UP       100.64.69.140   
Dia3                 UP   DOWN     --              
GE0/0                UP   UP       --              Multiple_Line1
GE0/1                UP   UP       --              Multiple_Line2
GE0/2                UP   UP       --              Multiple_Line3
GE0/3                UP   UP       --              Multiple_Line4
GE0/4                DOWN DOWN     --              
GE0/5                DOWN DOWN     --              
InLoop0              UP   UP(s)    --              
NULL0                UP   UP(s)    --              
REG0                 UP   --       --              
Vlan1                DOWN DOWN     --              LAN-interface
Vlan100              UP   UP       192.168.10.1    

Brief information on interfaces in bridge mode:
Link: ADM - administratively down; Stby - standby
Speed: (a) - auto
Duplex: (a)/A - auto; H - half; F - full
Type: A - access; T - trunk; H - hybrid
Interface            Link Speed     Duplex Type PVID Description                
GE2/0                DOWN auto      A      A    1    
GE2/1                UP   1G(a)     F(a)   A    100  
GE2/2                DOWN auto      A      A    1    
GE2/3                DOWN auto      A      A    1 
```





### 30F核心接口

```python
g1/0/1  				接主路由
g1/0/2  				接29核心
g1/0/3  				接ac无线控制器
g1/0/4					接30F核心2
g1/0/5 to g1/0/6    	无线WiFi
g1/0/7  				监控
g1/0/8 to g1/0/15  		30楼办公网络
g1/0/16 to g1/0/24 		31楼办公网络





```



### 30F核心2接口

```python
g1/0/1					接核心1
g1/0/2					群晖

g1/0/3 to g1/0/5		WiFi
g1/0/6					监控




```









### 29F核心接口

```python
Core_29F	G1/0/1	---	Core_30F 	G1/0/2

Core_29F	G1/0/2	---	Core_28F 	暂未配置

Core_29F	G1/0/3 to G1/0/6	---	WLAN（无线）

Core_29F	G1/0/7 to G1/0/24	---	工位		VLAN11



Core_29F 管理地址：192.168.100.4
```











### ac控制器

控制器改本地转发，业务流量由核心直接转发

![image-20240114214659676](C:\Users\Josh\AppData\Roaming\Typora\typora-user-images\image-20240114214659676.png)



### 缺省vlan id改成vlan1



### 核心网段修改：

```
Pool name: vlan400
  Network: 192.168.40.0 mask 255.255.254.0 
  dns-list 218.85.152.99 218.85.157.99 
  expired day 1 hour 0 minute 0 second 0
  gateway-list 192.168.40.1 
  option 138 ip-address 192.168.100.3
```





### AP的POE修改

```
interface GigabitEthernet1/0/3
 port link-mode bridge
 port link-type trunk
 port trunk permit vlan all
 port trunk pvid vlan 400
```





2.设备管理地址与账号密码

<1>路由器 -192.168.10.1- admin Meiyang123..

<2>30核心1 -192.168.100.1-meiyang Meiyang123..

<3> 30核心2 -- meiyang Meiyang123..

<4>29核心 --meiyang Meiyang123..

<5>无线ac --admin Meiyang123.. 
