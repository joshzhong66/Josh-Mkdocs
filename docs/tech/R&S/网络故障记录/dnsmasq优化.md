# dnsmasq优化



如果用国内的VPS来搭建本地DNS，响应的速度会更快，也更稳定。

**修改DNS配置及网络设置，以10.0.0.35为例，修改完经验证，访问国内外速度还不错，修改配置如下，仅供参考。**

1、vi /etc/sysconfig/network-scripts/ifcfg-em2 #修改网卡配置

![image-20240424152958846](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/b61ba2a046442df6be9ad69476faab50-image-20240424152958846-ab4328.png)



2、vi /etc/resolv.conf   #修改上游DNS配置

PS:以这个顺序测试是否国内速度也会变快

nameserver 8.8.8.8

nameserver 223.5.5.5

nameserver 8.8.4.4

~

![image-20240424153009517](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/e0f42f2fde37d6ee7c72f2a9c950e175-image-20240424153009517-934c83.png)



3、vi /etc/dnsmasq.conf   #修改dnsmasq配置

![image-20240424153015641](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/73ae990aa8572130ed44a3fc0a643e6d-image-20240424153015641-f6cc5f.png)



4、vi /etc/dnsmasq/hosts   #hosts修改   

PS：在10.0.0.30测试正常情况下，修改10.0.0.35dnsmasq、网卡及ros配置相同情况下，打开验证http://ip111.cn/，仍然无法从google测试获取到IP，最后将10.0.0.30host复制到10.0.0.35，重启dnsmasq，实现正常访问google。（10.0.0.30的hosts，删除了标#注释的dns条例，将有关于google等外网域名的所有条目删除，新增以下配置：）

server=/cn/114.114.114.114

server=/taobao.com/114.114.114.114

\#server=/taobaocdn.com/114.114.114.114

\#国外指定DNS

server=/google.com/8.8.8.8

（以上配置还未做验证，但不影响正常访问）



5、修改ros策略

在ros-ip-firewall-mangle处，将dns服务器的IP翻墙打开，目前国内走fenliu2，国外走fenliu10（sdwan）

![image-20240424153034082](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/665d1e488a1709f384e7beb8614e51ba-image-20240424153034082-0addbd.png)



6、验证：

http://ip111.cn/

DNS解析正常时，会显示出从google测试的IP（如不正常情况下，从谷歌测试显示空白，google.com也无法打开）

![image-20240424153042675](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/017441d0f72360031e59943606f5e9d6-image-20240424153042675-b659a8.png)