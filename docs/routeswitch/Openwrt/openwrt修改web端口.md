# openwrt修改web端口



如何修改openwrt路由器的web访问端口号？

在OpenWrt路由器上，如何修改Web访问端口号，通常涉及到修改HTTP服务器的配置文件。默认情况下，OpenWrt使用的HTTP服务器是uHTTPd。

以下是修改Web访问端口号的步骤：

### **一、通过SSH登录路由器**

​		使用SSH客户端连接到路由器。如果你的路由器上没有安装SSH服务器，你可能需要通过Web界面或其他方式启用SSH。

​		或者windows的cmd进行连接：
<img src="https://cdn.nlark.com/yuque/0/2024/png/40407567/1711723240736-f9ffff81-315f-4dfb-a5b7-cffceb921d83.png#averageHue=%23222120&clientId=u281f42a2-d720-4&from=paste&id=u39df5c89&originHeight=639&originWidth=1120&originalType=url&ratio=1.25&rotation=0&showTitle=false&size=97442&status=done&style=none&taskId=u548cc994-7357-4b2e-bc7b-ac0861be9ff&title=" alt="image.png" style="zoom: 50%;" />

### **二、编辑uHTTPd配置文件**

执行命令vi /etc/config/uhttpd以编辑uHTTPd的配置文件。你可以使用vi文本编辑器：

```python
root@BleachWrt:~# vi /etc/config/uhttpd

找到并修改端口号：在打开的配置文件中，找到类似以下行的配置（默认端口号为80）：
config uhttpd 'main'
        list listen_http '0.0.0.0:80'
        list listen_http '[::]:80'
        list listen_https '0.0.0.0:443'
        list listen_https '[::]:443'
        option redirect_https '0'
        option home '/www'
        option rfc1918_filter '1'
        option max_connections '100'
        option cert '/etc/uhttpd.crt'
        option key '/etc/uhttpd.key'
        option cgi_prefix '/cgi-bin'
        list lua_prefix '/cgi-bin/luci=/usr/lib/lua/luci/sgi/uhttpd.lua'
        option network_timeout '30'
        option http_keepalive '20'
        option tcp_keepalive '1'
        option ubus_prefix '/ubus'
        option script_timeout '3600'
        list index_page 'cgi-bin/luci'
        option max_requests '50'


修改list list listen_http行中的端口号为你想要的新端口号。例如，将端口号修改为8080：
config uhttpd 'main'
        list listen_http '0.0.0.0:80'


修改后：
config uhttpd 'main'
        list listen_http '0.0.0.0:8080'
        list listen_http '[::]:8080'
```
如果使用vi编辑器，按下esc，然后输入:wq，并按Enter保存并退出：

### **三、重新启动uHTTPd服务**

为了使更改生效，需要重新启动uHTTPd服务。执行以下命令：

```python
/etc/init.d/uhttpd restart 
```
或者使用service命令：
```python
service uhttpd restart 
```
如果你使用了防火墙，你可能还需要更新防火墙规则以允许新的端口上的流量。
