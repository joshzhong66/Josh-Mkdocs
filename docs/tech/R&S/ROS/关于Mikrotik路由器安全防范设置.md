# 关于Mikrotik路由器安全防范设置



### 一、Mikrotik路由器安全设置

1、禁止外网ping 探测（已开启）

2、只保留安全服务，关闭不必要端口

3、修改管理员默认登录账号，并设置高强度的密码，设置登录允许的网段，禁止使用mac地址登录winbox



### 二、服务端口

通过nmap扫描的端口，其中open为开放服务，对已使用及已关闭服务进行登记

PORT STATE SERVICE VERSION

25/tcp filtered http smtp

53/tcp open  domain Mikrotik Routeros named or openDns Updater    #dns端口，上网必要使用

80/tcp filtered

135/tcp filtered msrpc

137/tcp filtered netbios-ns

138/tcp filtered netbios-dgm

139/tcp filtered netbios-ssn

443/tcp filtered https

445/tcp filtered microsoft-ds

593/tcp filtered http-rpc-epmap

1723/tcp  open pptp      					#已关闭pptp，/interface pptp-server server set enabled=no

2000/tcp  open  bandwidth-test krotik				#带宽测试用于测试MikroTik路由器的吞吐量，/tool bandwidth-server set enabled=no（测试时开启即可）

4343/tcp open ss1/unical1?   					#TCP 端口 4343 使用传输控制协议

4433/tcp open ssl/unknown					#深信服SSL VPN端口

4444/tcp filtered krb524					

6690/tcp open unknown						#NAS之间资源同步

8080/tcp filtered http-proxy					

8291/tcp open http unknown					#winbox通信协议端口，限制内网运维IP可以访问

12466/tcp open nginx    					#NAS的Nginx服务，已关闭该端口



其它安全设置

/interface pptp-server server set enabled=no			关闭pptp vpn服务

/interface sstp-server server set enabled=no			关闭sstp vpn服务

/ip service disable telnet,ftp,www,api,api-ssl			禁用Telnet，FTP，WWW，API，API-SSL

/tool mac-server mac-winbox set allowed-interface-list=none	禁用通过mac地址使用winbox服务

/ip proxy set enabled=no					关闭 Proxy

/ip socks set enabled=no					关闭Socks代理



端口测试：

![image-20240424160016212](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/750fa68ddd55a813cc5aeccf75ea45ac-image-20240424160016212-3de344.png)



/ip service print		#查看所有服务

/ip service disable telnet,ftp,www,api,api-ssl			禁用Telnet，FTP，WWW，API，API-SSL

![image-20240424160026218](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/0f13556cfec3008e8b7ca833d741d64e-image-20240424160026218-54feb4.png)



禁止SSH登录

/ ip firewall filter

add chain=input protocol=tcp dst-port=21-22src-address-list=!allow-addressescomment="SSH &FTP"disabled=no

action=drop

这里解释下:通过运行上面的命令之后，只有在 allow-addresses 列表里的IP 才允许 SSH登录的，其他的一概被禁止。





[https://www.sklinux.com/posts/secrity/mikrotik%E8%B7%AF%E7%94%B1%E5%AE%89%E5%85%A8%E9%98%B2%E8%8C%83%E8%AE%BE%E7%BD%AE/](https://www.sklinux.com/posts/secrity/mikrotik路由安全防范设置/)



https://wiki.mikrotik.com/wiki/Manual:Securing_Your_Router