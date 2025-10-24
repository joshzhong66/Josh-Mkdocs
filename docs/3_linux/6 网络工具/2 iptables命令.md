# iptables命令



> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明 `iptables` 命令用法。

## 一、简介

`iptables` 是一种广泛使用的 Linux 防火墙工具，它提供了对网络流量的过滤和控制功能。通过使用 `iptables`，可以设置规则来控制入站、出站以及转发流量，进而保护服务器免受网络攻击。`iptables` 基于内核的 Netfilter 框架，通过匹配数据包的不同特征来决定是否允许或拒绝某个数据包。

1. **链 (Chain)**： `iptables` 中的规则被组织成链。每个链包含一组规则，规则按顺序匹配数据包。主要的链有：
   - **INPUT**：处理所有进入本机的数据包。
   - **OUTPUT**：处理从本机发出的数据包。
   - **FORWARD**：处理转发的数据包，即本机不是目的地的流量。
   - **PREROUTING** 和 **POSTROUTING**：处理数据包在路由决策前后的一些操作。
2. **表 (Table)**： `iptables` 提供了不同的表，用于不同类型的操作。常见的有：
   - **filter**：默认的表，用于过滤数据包，包含 `INPUT`、`OUTPUT` 和 `FORWARD` 链。
   - **nat**：网络地址转换表，用于处理地址转换相关的操作，如端口转发。
   - **mangle**：用于修改数据包的各种字段，如 TTL（生存时间）等。
   - **raw**：用于配置不进行状态跟踪的数据包。
3. **规则 (Rule)**： `iptables` 规则用于定义如何处理数据包，规则包含匹配条件（如源 IP、目标端口、协议等）和操作（如允许或拒绝）。常见的操作包括：
   - **ACCEPT**：允许数据包通过。
   - **DROP**：丢弃数据包，数据包不会返回任何响应。
   - **REJECT**：拒绝数据包并发送响应。
4. **目标 (Target)**： 规则中的目标决定了如何处理匹配的数据包。例如，目标可以是 `ACCEPT`（允许通过）、`DROP`（丢弃数据包）或 `RETURN`（跳到其他链继续检查）。



## 二、选项

```bash
匹配规则选项：
-i --in-interface    网络接口名>     指定数据包从哪个网络接口进入
-o --out-interface   网络接口名>     指定数据包从哪个网络接口输出
-p ---proto          协议类型        指定数据包匹配的协议，如TCP、UDP和ICMP等
-s --source          源地址或子网>    指定数据包匹配的源地址
   --sport           源端口号>       指定数据包匹配的源端口号
   --dport           目的端口号>     指定数据包匹配的目的端口号
-m --match           匹配的模块      指定数据包规则所使用的过滤模块
```



## 三、常用命令

> **PS：**`service iptables save ` 这条命令别用，与脚本不兼容。

### 1.查看当前规则

```bash
iptables -L
```

### 2.查看iptables状态

```bash
systemctl is-active iptables
```

- `inactive`：关闭状态。
- `active`：启用状态。

### 3.**添加iptables表项**

#### 3.1 开放22端口

不限制源地址和目的地址进行访问：

```bash
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
```

#### 3.2 开放445端口

限制源 IP 地址 `10.0.0.44` 可以访问，其他 IP 地址不能访问：

```bash
-A INPUT -s 10.0.0.44/32 -p tcp -m state --state NEW -m tcp --dport 445 -j ACCEPT
```

#### 3.3 查询规则22端口

```bash
grep "tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT" /etc/sysconfig/iptables
```

#### 3.4 查询规则IP和端口

```bash
grep "10.22.51.65/32 -p tcp -m state --state NEW -m tcp --dport 8083 -j ACCEPT" /etc/sysconfig/iptables
```

#### 3.5 禁用所有源流量

规则在它之下，所有从源出来的流量都会被禁止访问：

```bash
-A INPUT -j REJECT --reject-with icmp-host-prohibited
```

#### 3.6 禁用IP连接

```bash
-I INPUT -s 10.18.51.22 -j DROP
```

#### 3.7 禁止IP连接端口

```bash
-I INPUT -s 10.18.10.22 -p tcp --dport 22 -j DROP	    # 22端口
-I INPUT -s 10.18.10.22 -p tcp --dport 7890 -j DROP		# 7890端口
```

### 4.centos6启动

```bash
service iptables stop
service iptables start
service iptables restart
service iptables save	   # 保存设置
```

### 5.centos7启动

```bash
systemctl restart iptables
systemctl stop iptables
systemctl start iptables
systemctl enable iptables   # 设置开机启动
```



