# docker 部署SmokePing



> 参考文档：
>
> 开源地址：https://github.com/oetiker/SmokePing
>
> 参考文档：https://blog.csdn.net/wbsu2004/article/details/120315178
>
> 全国DNS服务器大全：https://dnsdaquan.com/

## 一、SmokePing介绍

### 1.概述

Smokeping 是一个网络监控工具，用于测量和记录网络延迟、丢包率以及网络连接的其他相关性能指标。它通过发送定期的网络探测（例如 ICMP Ping、DNS 查询等）来获取网络性能数据，并以图形化方式呈现这些数据，帮助用户了解网络的健康状态。

### 2.核心功能

1. **延迟测量**：Smokeping 通过定期发送探测包来测量网络延迟（Round-Trip Time, RTT），并记录这些延迟的中位数、平均值、最大值和最小值。
2. **丢包监控**：它能够检测和记录网络包丢失情况，帮助识别网络不稳定的问题。
3. **多探测器支持**：Smokeping 支持多种探测方式，包括 ICMP Ping（FPing）、TCP Ping（TCPPing）、DNS 查询等。用户可以根据需求选择不同的探测器。
4. **图形化报告**：Smokeping 使用 RRDTool 来生成图表，这些图表可以显示从短期到长期（例如从几小时到几年的时间跨度）的网络性能数据。
5. **多目标监控**：可以配置多个目标，按组或层级组织监控对象，并针对不同的网络节点或服务进行独立的监控。
6. **告警功能**：Smokeping 支持基于延迟和丢包率的告警配置，用户可以设置告警规则，当网络性能指标超出阈值时触发通知。

### 3.典型使用场景

1. **互联网服务监控**：监控到互联网网站（如 Google、Facebook 等）的连接延迟，确保外部服务的可用性。
2. **内部网络监控**：监控企业内部网络设备（如路由器、交换机、DNS 服务器等）的性能，及时发现并解决潜在的网络问题。
3. **DNS 监控**：测量 DNS 解析的延迟和稳定性，确保 DNS 服务的可靠性。
4. **网络性能基准测试**：为网络性能优化和故障排除提供基准数据，通过历史数据的对比，分析网络性能的变化趋势。

### 4.工作原理

1. **探测器（Probes）**：Smokeping 使用不同的探测器来监控网络连接。FPing 是最常用的探测器，它使用 ICMP Echo 请求来测量往返时间（RTT）。其他探测器如 TCPPing 和 DNS 可以用于监控特定服务的响应时间。
2. **数据存储**：Smokeping 使用 RRDTool 来存储和处理收集到的监控数据。RRDTool 会自动处理数据的存储和老化，从而保持数据库大小的恒定。
3. **数据展示**：通过生成图表，Smokeping 以图形化的方式展示网络性能数据。用户可以通过 Web 界面实时查看这些数据。
4. **告警系统**：Smokeping 支持基于延迟和丢包率的告警规则。用户可以设置复杂的条件，当监控到的指标超过预设阈值时触发告警，并通过邮件或其他方式通知相关人员。

Smokeping 是一个功能强大且灵活的网络监控工具，特别适合需要持续监控网络延迟和丢包的场景。它的图形化报告功能能够直观地展示网络性能问题，为网络维护和优化提供重要的数据支持。



## 二、安装fping

部署Smokeping之前需要先安装fping探测器，这里通过源码进行安装：

```bash
# 下载并解压 fping 源码包
cd /usr/local/src
wget https://github.com/schweikert/fping/releases/download/v5.1/fping-5.1.tar.gz
tar -xzf fping-5.1.tar.gz

# 配置、编译并安装fping
cd fping-5.1
./configure
make -j $(nproc)
make install
```

安装完成后，可执行`find`命令查找`fping`执行文件所在路径：

```bash
find / -name "*fping*"
# 显示路径
/usr/local/sbin/fping               # 可执行文件
/usr/local/share/man/man8/fping.8   # 手册页
```

验证`fping`版本：

```bash
fping --version
# 显示版本
fping: Version 5.1
```



## 三、docker部署SmokePing

### 1.拉取SmokePing镜像

```bash
docker pull linuxserver/smokeping
```

### 2.创建挂载目录

在 `/data` 目录中，创建目录名为 `smokeping`，并在 `smokeping` 中建两个子目录，分别命名为 `config` 和 `data`：

```bash
mkdir -p /data/smokeping/data     # 存储数据库和应用数据目录
mkdir -p /data/smokeping/config   # 存储配置文件目录
```

### 3.校验当前时区

部署前需要先校正时间，执行 `timedatectl` 命令查看时区是否为上海：

```bash
timedatectl
# 显示信息
      Local time: Tue 2024-08-20 10:12:05 CST
  Universal time: Tue 2024-08-20 02:12:05 UTC
        RTC time: Tue 2024-08-20 02:12:05
       Time zone: Asia/Shanghai (CST, +0800)
     NTP enabled: yes
NTP synchronized: no
 RTC in local TZ: no
      DST active: n/a
```

如果时区不是上海，设置该时区为中国标准时间（CST，Asia/Shanghai 时区）：

```bash
timedatectl set-timezone Asia/Shanghai
```

使用 `hwclock` 命令显示系统硬件时钟的当前时间：

```bash
hwclock --show
```

使用 `ntpdate` 命令更新系统时间：

```bash
ntpdate ntp.aliyun.com
```

### 4.部署SmokePing

```bash
docker run -d \
--name=smokeping \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=Asia/Shanghai \
-p 9080:80 \
-v /data/smokeping/config:/config \
-v /data/smokeping/data:/data \
--restart unless-stopped \
linuxserver/smokeping
```

脚本安装（未做尝试）：

```
bash -c "$(curl -L https://github.com/jiuqi9997/smokeping/raw/main/main.sh)"
```



## 四、配置SmokePing

### 1.配置文件介绍

配置文件存放路径 `/data/smokeping/config`，配置文件表如下：

|    文件名    |         用途          |
| :----------: | :-------------------: |
|    Alerts    |       报警设置        |
|   Database   |     采样频率设置      |
|   General    |       常规设置        |
|  httpd.conf  | Apache Web 服务器设置 |
|  pathnames   |       路径设置        |
| Presentation |       模板文件        |
|    Probes    |       探针设置        |
|    Slaves    | 主从模式时，从机设置  |
|  ssmtp.conf  |    邮件服务器设置     |
|   Targets    |     监控目标设置      |

### 2.Database配置文件

编辑 `Database` 配置文件：`vim /data/smokeping/config/Database`

```bash
*** Database ***

step     = 300		#300 秒(默认)
pings    = 20		#ping 20次（默认值）

# consfn mrhb steps total

AVERAGE  0.5   1  1008
AVERAGE  0.5  12  4320
    MIN  0.5  12  4320
    MAX  0.5  12  4320
AVERAGE  0.5 144   720
    MAX  0.5 144   720
    MIN  0.5 144   720
```

### 3.Probes配置文件

编辑 `Probes` 配置文件：`vim /data/smokeping/config/Probes `

```bash
*** Probes ***

+ FPing
binary = /usr/sbin/fping

+ FPing6
binary = /usr/sbin/fping
protocol = 6

+ DNS
binary = /usr/bin/dig
lookup = google.com		# 需要ping的域名，其他可以默认（可以使用百度或者163）,如：lookup = baidu.com

pings = 5
step = 300

+ TCPPing
binary = /usr/bin/tcpping
forks = 10
offset = random
pings = 5
port = 80
```

这里修改了 `Probes` 配置文件内容：

```bash
lookup = baidu.com
```

### 4.ssmtp.conf配置文件

编辑 `ssmtp.conf` 邮件报警配置文件：`vim /data/smokeping/config/ssmtp.conf`，这里先备份了原来的配置文件：

```bash
cp ssmtp.conf ssmtp.conf_bak
```

然后修改新的配置文件内容如下：

```bash
cat > ssmtp.conf <<'EOF'
Debug=YES
root=hongzelong@sunline.cn
mailhub=smtp.qq.com:465
AuthUser=416685476@qq.com
AuthPass=mklsqltwhsuhbjfi
UseSTARTTLS=NO
UseTLS=YES
rewriteDomain=qq.com
hostname=linuxserver-smokeping1
FromLineOverride=YES
EOF
```

>**解释说明：**
>
>- `Debug=YES`：启用调试模式，以便生成更详细的日志。
>- `root=hongzelong@sunline.cn`：此电子邮件地址将接收所有 User ID 小于 1000 的邮件。如果系统生成了某些自动邮件（例如 `cron` 作业的通知，系统错误报告等），而这些邮件没有指定明确的收件人时，这些邮件会默认发送到 `zhongjinlin31314@sunline.cn`。
>- `mailhub=smtp.qq.com:465`：设置 SMTP 服务器的地址和端口号。这里指定了 `smtp.qq.com` 作为邮件服务器，并使用 SSL 的 465 端口发送邮件。
>
>- `AuthUser=416685476@qq.com`：设置用于认证的邮箱用户名，即发送邮件的邮箱地址。
>- `AuthPass=mklsqltwhsuhbjfi` ：设置用于认证的邮箱密码或授权码。这个密码是用于认证的凭证，通常是邮箱提供的授权码，而不是邮箱的登录密码。
>- `UseSTARTTLS=NO`：禁用 STARTTLS，这是一种在普通端口上启用 TLS 加密的机制。如果服务器不支持 STARTTLS，或者你选择使用 SSL 而不是 STARTTLS，则将此项设置为 `NO`。
>- `UseTLS=YES`：启用 TLS（SSL）加密。这意味着邮件会通过加密的方式发送，确保传输的安全性。
>- `rewriteDomain=qq.com`：发送邮件时显示的发件域名。如果原始的发件人地址不是以 `qq.com` 结尾，`ssmtp` 会将其改写为 `qq.com`。
>- `hostname=linuxserver-smokeping1`：设置发送邮件时使用的主机名。这可以是你的服务器名或容器名，用于标识邮件的来源。
>- `FromLineOverride=YES`：允许 `ssmtp` 覆盖邮件的发件人地址。这意味着邮件的 `From` 字段将使用配置的发件人地址，而不是系统自动生成的地址。

修改完配置文件后，需要重启容器才生效：

```bash
systemctl restart smokeping
```

进入容器内进行 `Email` 发送调试：

```bash
docker exec -it smokeping /bin/bash
```

使用 `ssmtp` 命令进行发送，回车后还需要手动输入一些信息：

```bash
root@3cf805c2028b:/# ssmtp -v hongzelong@sunline.cn
To: hongzelong@sunline.cn
From: 416685476@qq.com
Subject: alert

#<回车2次>

[<-] 220 newxmesmtplogicsvrsza15-1.qq.com XMail Esmtp QQ Mail Server.
[->] EHLO 3cf805c2028b
[<-] 250 8BITMIME
[->] AUTH LOGIN
[<-] 334 VXNlcm5hbWU6
[->] NDE2Njg1NDc2QHFxLmNvbQ==
[<-] 334 UGFzc3dvcmQ6
[<-] 235 Authentication successful
[->] MAIL FROM:<416685476@qq.com>
[<-] 250 OK
[->] RCPT TO:<hongzelong@sunline.cn>
[<-] 250 OK
[->] DATA
[<-] 354 End data with <CR><LF>.<CR><LF>.
[->] Received: by 3cf805c2028b (sSMTP sendmail emulation); Tue, 20 Aug 2024 11:23:48 +0800
[->] Date: Tue, 20 Aug 2024 11:23:48 +0800
[->] To: hongzelong@sunline.cn
[->] From: 416685476@qq.com
[->] Subject: alert
[->] 
test123
[->] test123
# 执行<ctrl+D>
[->] .
[<-] 250 OK: queued as.
[->] QUIT
[<-] 221 Bye.
```

查看邮件信息：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/ef1c9c633d150086f3dfa454681f8261-image-20240820130757213-352568.png" alt="image-20240820130757213" style="zoom:50%;" />

### 5.Alerts配置文件

编辑 `Alerts` 配置文件：`vim /data/smokeping/config/Alerts`，这里先备份了原来的配置文件：

```bash
cp Alerts Alerts_bak
```

然后修改新的配置文件内容如下：

```bash
cat > Alerts <<'EOF'
*** Alerts ***
to = hongzelong@sunline.cn
from = 416685476@qq.com

+rttdetect
type = rtt
pattern = <20,<20,<20,<20,<20,>20,>20,>20
comment = 连续3次延时20以上

+lossdetect
type = loss
pattern = ==0%,==0%,==0%,==0%,==0%,>0%,>0%,>0%
comment = 突然有丢包
EOF
```

> **解释说明：**
>
> 这段配置文件是 Smokeping 的一个警报配置（`Alerts`），用于检测网络延迟（RTT）和丢包情况，并在满足特定条件时触发警报。
>
> - **基础设置：**
>
>   - `to`：接收报警的邮箱，也可以是自定义脚本。
>
>   - `from`：发送报警信息的邮箱，也就是上一步在 `ssmtp.conf` 中设置的邮箱。
>
> - **警报规则：**
>
>   - `+rttdetect`：
>     - `type = rtt`：这个警报类型是基于 RTT（Round Trip Time，往返时间）的检测。
>     - `pattern = <20,<20,<20,<20,<20,>20,>20,>20`：
>       - 该模式表示连续 5 次 RTT 小于 20ms，然后连续 3 次 RTT 大于 20ms。
>       - 如果检测到这种模式变化，表示网络延迟突然增加，将触发警报。
>     - `comment = 连续3次延时20以上`：这是对这个警报的注释，描述了警报的条件和含义。
>   - `+lossdetect`：
>     - `type = loss`：这个警报类型是基于网络丢包率的检测。
>     - `pattern = ==0%,==0%,==0%,==0%,==0%,>0%,>0%,>0%`：
>       - 该模式表示连续 5 次没有丢包，然后连续 3 次出现丢包（丢包率大于 0%）。
>       - 如果检测到这种模式变化，表示网络突然出现丢包，将触发警报。
>     - `comment = 突然有丢包`：这是对这个警报的注释，描述了警报的条件和含义。

修改完配置文件后，需要重启容器才生效：

```bash
systemctl restart smokeping
```

### 6.Targets配置文件

`Internet Sites` 基本上是正常无法访问的站点，所以需要进行修改，不然会没有数据。

编辑 `Targets` 配置文件：`vim /data/smokeping/config/Targets`，这里先备份了原来的配置文件：

```bash
cp Targets Targets_bak
```

然后修改新的配置文件内容如下：

```bash
cat > Targets <<'EOF'
*** Targets ***
probe = FPing
menu = Top
title = Network Latency Monitoring
remark = 欢迎来到 Sunline 公司的 SmokePing 网站。 \
         这里是有关我们网络延迟的所有信息。


+ InternetSites
menu = Internet Sites
title = Internet Sites

++ Baidu
menu = Baidu
title = Baidu
host = baidu.com

++ 163
menu = 163
title = 163
host = 163.com

++ Facebook
menu = Facebook
title = Facebook
host = facebook.com

++ Google
menu = Google
title = Google
host = google.com

++ YouTube
menu = YouTube
title = YouTube
host = youtube.com


+ DNS
menu = DNS Monitoring
title = DNS Servers

++ GoogleDNS
menu = Google DNS
title = Google DNS (8.8.8.8)
host = 8.8.8.8

++ AliyunDNS
menu = Aliyun DNS
title = Aliyun DNS (223.5.5.5)
host = 223.5.5.5

++ InternalDNS
menu = Internal DNS
title = Internal DNS (10.22.50.5)
host = 10.22.50.5



+ Other
menu = 三大网络监控
title = 监控统计

++ dianxin
menu = 电信网络监控
title = 电信网络监控列表
host = /Other/dianxin/dianxin-bj /Other/dianxin/dianxin-hlj /Other/dianxin/dianxin-tj /Other/dianxin/dianxin-sc /Other/dianxin/dianxin-sh /Other/dianxin/dianxin-gz

+++ dianxin-bj
menu = 北京电信
title = 北京电信
host = 202.96.199.133
alerts = rttdetect,lossdetect

+++ dianxin-hlj
menu = 黑龙江电信
title = 黑龙江电信
host = 219.147.198.230
alerts = rttdetect,lossdetect

+++ dianxin-tj
menu = 天津电信
title = 天津电信
host = 219.146.0.132
alerts = rttdetect,lossdetect

+++ dianxin-sc
menu = 四川电信
title = 四川电信
host = 61.139.2.69
alerts = rttdetect,lossdetect

+++ dianxin-sh
menu = 上海电信
title = 上海电信
host = 202.96.209.133
alerts = rttdetect,lossdetect

+++ dianxin-gz
menu = 广东电信
title = 广东电信
host = 202.96.134.133
alerts = rttdetect,lossdetect

++ liantong
menu = 联通网络监控
title = 联通网络监控列表
host = /Other/liantong/liantong-bj /Other/liantong/liantong-hlj /Other/liantong/liantong-tj /Other/liantong/liantong-sc /Other/liantong/liantong-sh /Other/liantong/liantong-gz

+++ liantong-bj
menu = 北京联通
title = 北京联通
host = 61.135.169.121
alerts = rttdetect,lossdetect

+++ liantong-hlj
menu = 黑龙江联通
title = 黑龙江联通
host = 202.97.224.69
alerts = rttdetect,lossdetect

+++ liantong-tj
menu = 天津联通
title = 天津联通
host = 202.99.96.68
alerts = rttdetect,lossdetect

+++ liantong-sc
menu = 四川联通
title = 四川联通
host = 119.6.6.6
alerts = rttdetect,lossdetect

+++ liantong-sh
menu = 上海联通
title = 上海联通
host = 210.22.84.3
alerts = rttdetect,lossdetect

+++ liantong-gz
menu = 广东联通
title = 广东联通
host = 221.5.88.88
alerts = rttdetect,lossdetect

++ yidong
menu = 移动网络监控
title = 移动网络监控列表
host = /Other/yidong/yidong-bj /Other/yidong/yidong-hlj /Other/yidong/yidong-tj /Other/yidong/yidong-sc /Other/yidong/yidong-sh /Other/yidong/yidong-gz

+++ yidong-bj
menu = 北京移动
title = 北京移动
host = 221.130.33.52
alerts = rttdetect,lossdetect

+++ yidong-hlj
menu = 黑龙江移动
title = 黑龙江移动
host = 218.203.59.216
alerts = rttdetect,lossdetect

+++ yidong-tj
menu = 天津移动
title = 天津移动
host = 211.137.160.5
alerts = rttdetect,lossdetect

+++ yidong-sc
menu = 四川移动
title = 四川移动
host = 218.201.4.3
alerts = rttdetect,lossdetect

+++ yidong-sh
menu = 上海移动
title = 上海移动
host = 211.136.112.50
alerts = rttdetect,lossdetect

+++ yidong-gz
menu = 广东移动
title = 广东移动
host = 211.136.192.6
alerts = rttdetect,lossdetect
EOF
```

格式一目了然，采用了是分层结构，用 `+` 表示，例如第一层 `+`，第二层 `++` 依次类推，可以增加也可以修改。

修改完配置文件后，需要重启容器才生效：

```bash
systemctl restart smokeping
```

#### 6.1 全局配置

```bash
*** Targets ***

probe = FPing
menu = Top
title = Network Latency Grapher
remark = 欢迎来到 Sunline 公司的 SmokePing 网站。 \
         这里是有关我们网络延迟的所有信息。
```

**配置解释：**

- `\**\* Targets \**\*`：这是目标配置段的开始标志。
- `probe = FPing`：定义了默认的探测方法为 `FPing`，用于通过 ICMP ping 探测目标。
- `menu = Top`：设置在 Smokeping Web 界面中的顶层菜单名称。
- `title = Network Latency Grapher`：定义了顶层的标题。
- `remark`：显示在 Smokeping Web 界面上的一段介绍性文本。

#### 6.2 目标组和目标配置

```bash
+ InternetSites
menu = Internet Sites
title = Internet Sites

++ Facebook
menu = Facebook
title = Facebook
host = facebook.com

++ Google
menu = Google
title = Google
host = google.com

++ YouTube
menu = YouTube
title = YouTube
host = youtube.com

```

**配置解释：**

- `+ InternetSites`：定义了一个目标组 `InternetSites`。

- `menu = Internet Sites`：设置了在 Web 界面上的菜单显示名称为 `Internet Sites`。

- `title = Internet Sites`：定义了该组的标题。

- `++ Facebook`：在 `InternetSites` 组下定义了一个子组 `Facebook`。

- `host = facebook.com`：设置了要监控的目标为 `facebook.com`

类似的结构用于其他互联网网站，例如 `YouTube`、`Google` 等。

这种方法，使得`Facebook`、`Google` 和 `YouTube` 子组分别生成独立的监控图表。这种方式适合你希望分别查看每个域名的延迟监控情况。

#### 6.3 DNS 和 DNSProbes配置

```bash
+ DNS
menu = DNS Monitoring
title = DNS Servers

++ GoogleDNS
menu = Google DNS
title = Google DNS (8.8.8.8)
host = 8.8.8.8

++ AliyunDNS
menu = Aliyun DNS
title = Aliyun DNS (223.5.5.5)
host = 223.5.5.5

++ InternalDNS
menu = Internal DNS
title = Internal DNS (10.22.50.5)
host = 10.22.50.5

```

**配置解释：**

- `+ DNS`：定义了一个目标组 `DNS`，用于监控不同的 DNS 服务器。

- `++ GoogleDNS`：在 `DNS` 组下定义了一个子目标 `GoogleDNS`，用于监控 Google 的 `8.8.8.8` DNS 服务器。

`GoogleDNS`、`AliyunDNS` 和 `InternalDNS` 子组分别生成独立的监控图表。这种方式适合你希望分别查看每个域名的延迟监控情况。



## 五、访问SmokePing

浏览器上访问【http://10.22.51.66:9080】，首页如下：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/f80e5a85581f37648587f062ae059417-image-20240820140823260-642f6e.png" alt="image-20240820140823260" style="zoom:50%;" />

查看内网DNS监控信息：

![image-20240820133745133](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/38ec515e7561e094056d2f0ce5db494c-image-20240820133745133-509591.png)

**图表结构：**图表被分成四个部分，分别显示了不同时间跨度内的延迟情况：

1. **左上角图表：** 显示了最近 3 小时内的延迟。
2. **右上角图表：** 显示了最近 30 小时内的延迟。
3. **左下角图表：** 显示了最近 10 天内的延迟。
4. **右下角图表：** 显示了最近 360 天内的延迟。

**图表内容解析：**每个图表显示的信息包括以下几个部分：

1. **图表顶部**：
   - **时间轴**：每个图表都有一个时间轴，表示监控数据的时间跨度。
   - **延迟**：Y 轴表示响应时间，以秒或毫秒为单位。
2. **图表中间**：
   - **绿色/红色条形**：这些颜色的条形表示每个时间段的平均延迟。颜色表示不同的延迟水平（如图例所示）。
   - **灰色区域**：表示该时间段没有足够的数据。
3. **图表底部的统计信息**：
   - **median rtt**：中位数的往返时间（RTT）。
   - **avg rtt**：平均往返时间（RTT）。
   - **max rtt**：最大往返时间（RTT）。
   - **min rtt**：最小往返时间（RTT）。
   - **packet loss**：丢包率，表示在这个时间段内的丢包百分比。
   - **loss color**：图例，表示不同颜色的条形对应的丢包率。
   - **probe**：探测方式和频率。这里表示使用了 20 个 ICMP Echo Pings（Ping）每 300 秒执行一次探测。

**当前图表中的数据：**从这些图表中可以观察到以下情况：

- **最近 3 小时内的延迟：** 在图表的左上部分，显示了从 `221f513be6e3` 主机到 `10.22.50.5` 的 DNS 服务器的延迟情况。图中显示最近 3 小时的平均延迟约为 `313.7us`，丢包率为 `0.00%`。
- **最近 10 天和 360 天的延迟：** 这些部分的数据（左下和右下图表）尚未累计足够的数据，图表中显示的值为 `-nan`，表示数据不足或未采集。

**结论：**当前的监控显示了 `10.22.50.5` 这个 DNS 服务器在最近几个小时内的响应时间非常稳定，延迟很低，且没有丢包。长期图表由于数据不足，还无法提供有效的统计信息。继续运行 Smokeping 来累积更多数据，这样长期图表会逐渐显示出更多有价值的信息。



