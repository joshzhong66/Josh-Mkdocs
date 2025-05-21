# iStoreOS软路由安装使用

> 官网：https://github.com/istoreos
>
> 官方文档：https://doc.istoreos.com/zh/guide/istoreos/install.html
>
> 旁路由上网：https://shdvgj.github.io/2023/07/06/2023/07/bridge-mode-starter-istoreos/
>
> iStoreos Ova下载链接：https://file.joshzhong.top/4_Install/iStoreos_OVA/istor-p-221118-password.ova  （此镜像初始无密码）
>
> iStoreos Ova 默认账号：**`root`**  root密码：**`password`**



## 一、如何修改LAN口IP

![image-20250518124130281](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518124130281.png)

尝试访问

```
C:\Users\joshz>ping 192.168.1.119

正在 Ping 192.168.1.119 具有 32 字节的数据:
来自 192.168.1.119 的回复: 字节=32 时间<1ms TTL=64
来自 192.168.1.119 的回复: 字节=32 时间<1ms TTL=64
来自 192.168.1.119 的回复: 字节=32 时间<1ms TTL=64
来自 192.168.1.119 的回复: 字节=32 时间<1ms TTL=64
```



## 2、修改密码

passwd，输入密码：`xxxxxx`

![image-20250518124429901](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518124429901.png)

## 3、网页登录

打开浏览器，输入`http://192.168.1.119/`，输入root的密码进行登录

![image-20250518124402879](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518124402879.png)

## 四、配置旁路由

点击【网络向导】——【配置为旁路由】

![image-20250518125017033](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518125017033.png)



![image-20250518125029919](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518125029919.png)



IP地址：192.168.1.119（当前istoreos路由的IP）

掩码：默认

网关：192.168.1.1

DNS：223.5.5.5

DHCP：关闭此选项

![image-20250518125338799](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518125338799.png)

首页右上角显示【已连接互联网】

>如果出现软件源错误：可以设置为openwrt的试试



![image-20250518125441748](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518125441748.png)



## 五、安装PassWall

>下载`iStore软件包`，存在多个，可以安装`OpenClash`,或者安装`PassWall`

### 1.下载PassWall

- iStoreOS自带的iStore，没有PassWall，去往[Github下载的Are-u-ok](https://github.com/AUK9527/Are-u-ok)下载。

- 选择`x86_64`平台

  ![image-20250518130010356](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518130010356.png)

- 下载`PassWall`

  点击：[PassWall_25.5.8](https://github.com/AUK9527/Are-u-ok/raw/main/x86/all/PassWall_25.5.8_x86_64_all_sdk_22.03.7.run)进行下载

  ![image-20250518130025021](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518130025021.png)

### 2.通过`iStore`手动安装

- 下载的这是一个**`run后缀的包`**，打开**`iStore`**，选择【手动安装】

  ![image-20250518130125370](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518130125370.png)

### 3.通过命令安装

```
wget https://raw.githubusercontent.com/AUK9527/Are-u-ok/main/x86/all/PassWall_25.5.8_x86_64_all_sdk_22.03.7.run

sh PassWall_25.5.8_x86_64_all_sdk_22.03.7.run
```



### 4.安装成功截图

>安装如果失败，大概率是网络问题导致，则需要配置全局代理，ssh登录root，执行如下，再重新上传安装即可：
>
>```
>echo 'export http_proxy="http://代理服务器ip:7890"' >> ~/.bashrc 
>echo 'export https_proxy="http://代理服务器ip:7890"' >> ~/.bashrc 
>echo 'export all_proxy="socks5://代理服务器ip:7890"' >> ~/.bashrc 
>source ~/.bashrc
>```

![image-20250518130856463](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518130856463.png)

## 六、配置PassWall

### 1.添加节点订阅

打开【服务】-【PassWall】- 【节点订阅】

![image-20250518132120223](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518132120223.png)

下拉到底部，点击【添加】，设置`订阅备注（机场）`的名称：【自定义】，订阅网址：【你的代理连接】

![image-20250518132736734](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518132736734.png)



### 2.配置防火墙



![image-20250518132918297](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518132918297.png)



- 在自定义规则里，添加一行`iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE`

## 七、上网设备配置走旁路由

- 修改ipv4为手动，ip地址填入和旁路由同一网段的ip，子网掩码填255.255.255.0
- 修改路由器为旁路由IP
- 添加DNS为旁路由IP

![image-20250518133820236](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250518133820236.png)



