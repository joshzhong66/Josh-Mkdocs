# htop命令



> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明 `htop` 命令用法。

## 一、htop简介

`htop` 是一个非常强大的命令行工具，用于实时监视 Linux 系统的资源使用情况。与传统的 `top` 命令相比，`htop` 提供了一个更直观和交互式的界面。



## 二、安装 `htop`

```bash
yum install -y htop
```



## 三、启动 `htop`

直接在终端中输入 `htop` ，将启动 `htop` 并显示一个动态的资源使用情况界面：

```bash
[root@josh qcloud]# htop

  1  [||||                                                                      3.7%]   Tasks: 103, 563 thr; 1 running
  2  [||                                                                        1.9%]   Load average: 0.20 0.08 0.06 
  Mem[|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||1.99G/3.61G]   Uptime: 31 days, 21:02:46
  Swp[                                                                         0K/0K]

  PID USER      PRI  NI  VIRT   RES   SHR S CPU% MEM%   TIME+  Command
 4308 root       20   0 1008M 57068 19140 S  3.7  1.5  1:59.38 /usr/local/qcloud/YunJing/YDEyes/YDService
 3025 root       20   0  736M 16708  2584 S  1.9  0.4  5h58:24 barad_agent
15078 root       20   0 2473M  343M  2704 S  1.9  9.3  8:57.73 java -jar /app/bin/reader.jar
24595 root       20   0  122M  2812  1520 R  0.0  0.1  0:00.13 htop
18615 polkitd    20   0 1811M  456M  4480 S  0.0 12.4 44:40.82 mysqld
 3057 root       20   0  736M 16708  2584 S  0.0  0.4  1h21:06 barad_agent
 3024 root       20   0  161M  9444  1848 S  0.0  0.2 27:05.41 barad_agent
 4371 root       20   0 1008M 57068 19140 S  0.0  1.5  0:06.92 /usr/local/qcloud/YunJing/YDEyes/YDService
13031 root       20   0 1249M 62672  7944 S  0.0  1.7  0:18.79 /data/Mkdocs/venv/bin/python3 /data/Mkdocs/venv/bin/mkdocs serve --dev-addr 0.0.0.0:10090
 1004 root       20   0  560M 16028  2668 S  0.0  0.4  3:39.50 /usr/bin/python2 -Es /usr/sbin/tuned -l -P
19231 root       20   0 3506M  360M  9544 S  0.0  9.8  2:45.84 java -jar woodwhales-music.jar
 4346 root       20   0 1008M 57068 19140 S  0.0  1.5  0:20.55 /usr/local/qcloud/YunJing/YDEyes/YDService
 4311 root       20   0 1008M 57068 19140 S  0.0  1.5  0:21.12 /usr/local/qcloud/YunJing/YDEyes/YDService
 4370 root       20   0 1008M 57068 19140 S  0.0  1.5  0:11.35 /usr/local/qcloud/YunJing/YDEyes/YDService
 4672 root       20   0 1008M 57068 19140 S  0.0  1.5  0:10.81 /usr/local/qcloud/YunJing/YDEyes/YDService
19638 polkitd    20   0 1811M  456M  4480 S  0.0 12.4 32:08.22 mysqld
 1070 root       20   0 1757M 27556  4632 S  0.0  0.7  5:52.57 /usr/bin/containerd
 1025 root       20   0 1757M 27556  4632 S  0.0  0.7 30:48.13 /usr/bin/containerd
 4373 root       20   0 1008M 57068 19140 S  0.0  1.5  0:11.29 /usr/local/qcloud/YunJing/YDEyes/YDService
13154 root       20   0 1249M 62672  7944 S  0.0  1.7  0:11.20 /data/Mkdocs/venv/bin/python3 /data/Mkdocs/venv/bin/mkdocs serve --dev-addr 0.0.0.0:10090
18079 root       20   0 3034M 53308  7676 S  0.0  1.4  0:28.57 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
18816 root       20   0 1207M  6056  2212 S  0.0  0.2  3:23.25 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 42c45fd172c3b42fff976cfe753d175e24e318f03bea7dc76f8376a244c1
    1 root       20   0  186M  4112  2400 S  0.0  0.1  8:46.92 /usr/lib/systemd/systemd --switched-root --system --deserialize 22
  386 root       20   0 47256  7404  7068 S  0.0  0.2  0:52.47 /usr/lib/systemd/systemd-journald
  410 root       20   0  121M  1088   780 S  0.0  0.0  0:00.00 /usr/sbin/lvmetad -f
  423 root       20   0 45756  2064  1156 S  0.0  0.1  0:00.20 /usr/lib/systemd/systemd-udevd
  534 root       20   0 1216M 11548  4940 S  0.0  0.3  0:04.78 /usr/local/frp/frps -c /usr/local/frp/frps.toml
  535 root       20   0 1216M 11548  4940 S  0.0  0.3  0:02.88 /usr/local/frp/frps -c /usr/local/frp/frps.toml
```



## 四、`htop` 信息分析

`htop` 输出的信息展示了系统当前运行的进程和资源的使用情况，下面是对一些关键部分的分析：

### 1. CPU 使用情况

总共 2 个 CPU 核心：

- **第 1 核心**：使用了 3.7% 的 CPU。
- **第 2 核心**：使用了 1.9% 的 CPU。

当前系统 CPU 的负载较低（负载平均值 0.20、0.08 和 0.06 表示过去 1 分钟、5 分钟和 15 分钟的平均负载），并且只有 1 个进程在运行。

### 2. 内存和交换空间

- **内存使用**：总共 3.61 GB 内存，当前使用了 1.99 GB，大约是 55%。
- **交换空间**：没有使用交换空间，0 KB/0 KB。

### 3. 进程信息

- 系统上总共有 103 个任务（进程），其中 563 个线程，1 个正在运行。

- 主要进程：

  - `YDEyes` (PID 4308, 4371, 4370 等) 是 `/usr/local/qcloud/YunJing/YDEyes/YDService`，消耗的内存是 57068 KB，CPU 使用率较低（0.0% - 3.7%），可能是一些守护进程。
  - `barad_agent` (PID 3025, 3057, 3024) 是一个进程，使用了 736 MB 内存，CPU 使用在 0% 到 1.9% 之间，似乎是某个后台服务或监控程序。
  - `java -jar /app/bin/reader.jar` (PID 15078) 是一个 Java 进程，占用了 2473 MB 虚拟内存和 343 MB 物理内存，CPU 使用率为 1.9%。
  - `mysqld` (PID 18615, 19638) 是 MySQL 数据库服务，占用了较多内存（456 MB）。
  - `containerd` (PID 1070, 1025) 和 `dockerd` (PID 18079) 是 Docker 守护进程及其容器运行时，分别使用了 1757 MB 内存。
  - `frps` (PID 534, 535) 是 FRP（Fast Reverse Proxy）服务，使用了 1216 MB 内存，主要用于内网穿透。

### 4. 其它信息

- **系统运行时间**：已经运行了 31 天 21 小时。
- **负载平均值**：负载非常低，系统资源基本空闲。
- **进程状态**：大多数进程处于“睡眠（S）”状态，表示它们在等待 I/O 或其他任务。

总结： 系统总体负载非常低，内存和 CPU 使用较为轻松，主要的内存消耗来自 MySQL 数据库、Java 进程和 Docker。没有明显的性能瓶颈或资源紧张。