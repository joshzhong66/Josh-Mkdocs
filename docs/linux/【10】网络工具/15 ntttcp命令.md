# 15 ntttcp命令



> 欢迎阅读《每天一个Linux命令》系列 ！在本篇文章中，将说明iftop命令用法。

## 一、简介

`ntttcp` 是一个网络性能测试工具，特别适用于 Windows 和 Linux 系统，它的全称是 "New TTCP"，基于经典的 TTCP 工具（测试 TCP 性能）。微软开发了 `ntttcp` 来帮助评估网络硬件和软件的传输性能，尤其是高带宽和低延迟的场景。

**主要功能：**

- 测量 TCP 和 UDP 的网络吞吐量。
- 在多核 CPU 上生成多线程负载。
- 测试网络链路和设备的性能。
- 支持 IPv4 和 IPv6 协议。



## 二、安装ntttcp

### 1.下载并解压ntttcp源码包

```bash
cd /usr/local/src
wget https://github.com/microsoft/ntttcp-for-linux/archive/refs/tags/1.4.0.tar.gz
tar -xzf 1.4.0.tar.gz
```

### 2.编译并安装ntttcp

```bash
cd ntttcp-for-linux-1.4.0/src
make -j$(nproc)
make install
```

### 3.验证安装

安装成功后，运行以下命令确认 `ntttcp` 是否安装成功：

```bash
iftop -h
```
如果显示帮助信息，表示安装成功。



## 三、使用iftop

### 1.常用参数说明

`iftop` 有许多参数和选项可以帮助你显示网络吞吐量、延迟、丢包率等性能指标，有助于你了解网络连接的性能状况。

常用参数：

- `-s`：客户端发送模式。
- `-r`：服务器接收模式。
- `-m`：定义线程数和 CPU 绑定选项。
- `-t`：定义测试运行的时间（秒），默认是 20 秒。
- `-p`：定义端口号。

### 2.使用示例

先在接收方启用接收模式：

```bash
[root@localhost ~]# ntttcp -r
NTTTCP for Linux 1.4.0
---------------------------------------------------------
22:54:34 INFO: 17 threads created
```

接着在发送方启用发送模式，并指定接收方的IP地址：

```bash
[root@localhost src]# ntttcp -s 10.22.51.51
NTTTCP for Linux 1.4.0
---------------------------------------------------------
22:59:30 INFO: 64 threads created
22:59:30 INFO: 64 connections created in 9355 microseconds
22:59:30 INFO: Network activity progressing...
```

默认情况下，工具会进行为期1分钟的吞吐量测试，可以在终端上实时看到当前的吞吐量：

- 接收方：

```
[root@localhost ~]# ntttcp -r
NTTTCP for Linux 1.4.0
---------------------------------------------------------
22:59:37 INFO: 17 threads created
22:59:40 INFO: Network activity progressing...
Real-time throughput: 941.50Mbps
```

- 发送方：

```bash
[root@localhost ~]# ntttcp -s 10.22.51.51
NTTTCP for Linux 1.4.0
---------------------------------------------------------
22:59:30 INFO: 64 threads created
22:59:30 INFO: 64 connections created in 9355 microseconds
22:59:30 INFO: Network activity progressing...
Real-time throughput: 947.02Mbps
```

测试完成后，双方都会生成吞吐量测试报告，在报告中显示，测试持续了1分钟，总共发送了约 7.0 G的流量，平均吞吐量为 955 Mbps：

- 接收方：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/10/13/eeaa9a84eee15f4da5bdf53fa74be67c-image-20241013230337181-029806.png" alt="image-20241013230337181" style="zoom:50%;" />

- 发送方：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/10/13/33af525b57cdf3e199abafd1b23af98a-image-20241013230301107-b60ece.png" alt="image-20241013230301107" style="zoom:50%;" />

> 测试时，接收方最好关闭防火墙。
