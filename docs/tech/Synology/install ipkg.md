#### 初衷：

群晖上没有yum，只能用ipkg作为下载。

#### （1）创建目录

```python
mkdir /volume2/data/ipkg
cd /volume2/data/ipkg
```



#### （2）下载脚本

```
wget http://ipkg.nslu2-linux.org/feeds/optware/syno-i686/cross/unstable/syno-i686-bootstrap_1.2-7_i686.xsh
```

> --2024-05-12 16:47:19--  http://ipkg.nslu2-linux.org/feeds/optware/syno-i686/cross/unstable/syno-i686-bootstrap_1.2-7_i686.xsh
> Resolving ipkg.nslu2-linux.org... 23.141.224.193, 2620:139:a000::c1
> Connecting to ipkg.nslu2-linux.org|23.141.224.193|:80... connected.
> HTTP request sent, awaiting response... 200 OK
> Length: 249507 (244K) [text/plain]
> Saving to: 'syno-i686-bootstrap_1.2-7_i686.xsh'
>
> syno-i686-bootstrap_1.2-7_i686 100%[==================================================>] 243.66K   297KB/s    in 0.8s    
>
> 2024-05-12 16:47:21 (297 KB/s) - 'syno-i686-bootstrap_1.2-7_i686.xsh' saved [249507/249507]



#### （3）赋权

```
chmod +x syno-i686-bootstrap_1.2-7_i686.xsh
```



#### （4）执行安装

```
 sh syno-i686-bootstrap_1.2-7_i686.xsh
```

> Optware Bootstrap for syno-i686.
> Extracting archive... please wait
> 1216+1 records in
> 1216+1 records out
> 249302 bytes (249 kB, 243 KiB) copied, 0.002228 s, 112 MB/s
> bootstrap/
> bootstrap/bootstrap.sh
> bootstrap/ipkg-opt.ipk
> bootstrap/ipkg.sh
> bootstrap/optware-bootstrap.ipk
> bootstrap/wget.ipk
> Creating temporary ipkg repository...
> Installing optware-bootstrap package...
> Unpacking optware-bootstrap.ipk...Done.
> Configuring optware-bootstrap.ipk...Modifying /etc/rc.local
> Done.
> Installing ipkg...
> Unpacking ipkg-opt.ipk...Done.
> Configuring ipkg-opt.ipk...Done.
> Removing temporary ipkg repository...
> Installing wget...
> Installing wget (1.12-2) to root...
> Configuring wget
> Successfully terminated.
> Creating /opt/etc/ipkg/cross-feed.conf...
> Setup complete.
> root@Could:/volume2/data/ipkg# ipkg
> ipkg: ipkg must have one sub-command argument
> ipkg version 0.99.163
> usage: ipkg [options...] sub-command [arguments...]
> where sub-command is one of:



#### （5）ipkg安装软件

```
#更新可用的包列表
ipkg update

#更新可能已安装的包到最新版本
ipkg upgrade

#查找要安装的包
ipkg list *包名*

#查看已安装的包
ipkg list_installed

#一般会安装以下的包
ipkg install lrzsz lsof mlocate less man netcat

#设置并测试mlocate包
#更新数据库
time updatedb
#查看数据库信息
locate -S
#查找文件nginx.conf
locate nginx.conf
```



#### （6）安装lrzsz，

> #### 默认路径（ /opt/bin/）

```
#安装lrzsz
ipkg install lrzsz


#设置lrzsz
ln -s /opt/bin/lrz /opt/bin/rz
ln -s /opt/bin/lsz /opt/bin/sz
```

