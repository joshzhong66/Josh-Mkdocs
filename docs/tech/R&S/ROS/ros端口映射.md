# ros端口映射



打开winbox客户端登陆之后，找到“ip”--”firewall”防火墙设置，如下图

![image-20240424160917266](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/68345499f788a91ec0a69eec0057a78c-image-20240424160917266-6860b7.png)

找到防火墙规则，nat里面点击“+”添加规则如下图

![image-20240424160926071](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/78277b53555a6c3288f20ba70cde1e2d-image-20240424160926071-ce493e.png)

**设置端口映射**

在一般“general”菜单中，如下图设置。 Chain选择 dstnat ，协议protocl默认即可。 DST port是目标端口就是需要映射的端口外网端口访问的，接着是入口选择上网的公网接口

![image-20240424160934367](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/dee0f17df24c8332b1d9b1600137a7b4-image-20240424160934367-e00b18.png)

然后在执行动作action选项设置，选择dst-nat

选好之后，出现的地址to address里面也就是需要映射的服务器的IP地址，

然后是端口号（一般来说都是内网11对应，如果不一致注意这里是内网的端口）

![image-20240424160941007](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/7a45806b1e228d4760eb745e52fdbd11-image-20240424160941007-9ed53e.png)

设置好之后，点击应用apply，然后在nat里面就能看到刚刚设置的项目了。