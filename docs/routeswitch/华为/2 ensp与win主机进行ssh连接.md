# ensp与win主机进行ssh连接



### **<1>云-连接完成，进行配置**

### **<2>交换机IP配置**

```
vlan 10
inter g0/0/1
port link-type access
port default vlan 10
quit
inter vlanif 10
ip add 192.168.56.2
```

### **<3>两端互通测试**

配置完成，ping主机192.168.56.1测试

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/d2ceccd62e6a40c8979b7b85c7ff6033-image-20240424140513759-9d4ee7.png" alt="image-20240424140513759" style="zoom:67%;" />

**<4>配置SSH进行登录**

```
u t m 
system-view


#创建本地钥匙对
rsa local-key-pair create    

#进入aaa
aaa

#创建用户admin，设置密码
local-user admin password cipher 123456

#配置用户登录类型为ssh
local-user admin service-type ssh

quit

#创建登录接口并进入
user-interface vty 0 4

#设置身份验证模式为aaa认证
authentication-mode aaa

#配置用户级别为最高级
user privilege level 15

#允许ssh协议访问
protocol inbound ssh
quit

#开启ssh服务
stelnet server enable

#指定认证模式为password
ssh user admin authentication-type password

#设置ssh用户服务类型
ssh user admin service-type stelnet

#使能客户端首次登录
ssh client first-time enable 

#修改ssh登录端口
ssh server port 2222
```

登录界面：

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/8af61076d5a95e5bf8fe19f3cbc5a03d-image-20240424140538233-4857d7.png" alt="image-20240424140538233" style="zoom: 50%;" />

配置：

```
一、注意事项：
1、首次使用console登陆，默认用户名：admin密码：admin@huawei.com，首次登陆要求修改密码。
2、除了console口，还可以使用miniUSB接口来登陆设备，速率9600，流控全无，不校验，停止位1，数据位8，缺省用户名与密码（与console一致）。
3、连接eth管理接口，缺省web登陆IP 192.168.1.253（pc与交换机处于同一网段）。

二、基本配置
[HUAWEI] sysname Switch #设置设备名称。

[HUAWEI] clock timezone Beijing add 08:00:00 #配置设备所在地区及其对应的时区。

<HUAWEI> clock datetime 08:00:00 2018-12-01  #设置当前时间和日期。
配置设备管理IP地址，执行命令ip route-static，配置设备缺省网关。对于有管理网口的设备，在管理网口下配置管理IP地址。
[HUAWEI] interface MEth 0/0/1
[HUAWEI-MEth0/0/1] ip address 10.10.10.2 255.255.255.0    //设备管理IP 
[HUAWEI] ip route-static 0.0.0.0 0 10.10.10.1    //设备缺省网关 

对于没有管理网口的设备，在Vlanif接口下配置管理IP地址。
<HUAWEI> system-view
[HUAWEI] interface Vlanif 10
[HUAWEI-Vlanif10] ip address 10.10.10.2 255.255.255.0    //设备管理IP 
[HUAWEI-Vlanif10] quit 
[HUAWEI] ip route-static 0.0.0.0 0 10.10.10.1    //设备缺省网关 
执行命令ssh user，配置SSH用户相关参数；执行命令local-user，配置本地用户相关参数，实现通过SSH协议登录设备。

<HUAWEI> system-view
[HUAWEI] user-interface vty 0 4
[HUAWEI-ui-vty0-4] authentication-mode aaa    //配置VTY用户认证方式为AAA认证
[HUAWEI-ui-vty0-4] protocol inbound ssh    //VTY用户界面所支持的协议缺省为SSH协议。
[HUAWEI-ui-vty0-4] quit
[HUAWEI] aaa
[HUAWEI-aaa] local-user admin password irreversible-cipher admin@123    //创建与SSH用户同名的本地用户和对应的登录密码
[HUAWEI-aaa] local-user admin service-type ssh terminal    //配置本地用户的服务方式
[HUAWEI-aaa] local-user admin privilege level 15    //配置本地用户级别
[HUAWEI-aaa] quit
[HUAWEI] ssh user admin    //创建SSH用户
[HUAWEI] ssh user admin authentication-type password    //配置SSH用户的认证方式为password
[HUAWEI] ssh user admin service-type stelnet    //配置SSH用户的服务方式
[HUAWEI] stelnet server enable    //使能设备的STelnet服务器功能
```

