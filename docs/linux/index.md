# Linux 常用命令分类总表

| 类别                   | 命令                                                         | 说明                                 |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------ |
| **文件与目录操作**     | `ls`, `cd`, `pwd`, `mkdir`, `rmdir`, `cp`, `mv`, `rm`, `touch`, `stat`, `tree`, `find`, `basename`, `dirname` | 浏览、创建、移动、删除、信息查看等   |
| **文件内容处理**       | `cat`, `tac`, `less`, `more`, `head`, `tail`, `cut`, `split`, `wc`, `nl`, `strings` | 查看、分割、计数、提取文本等         |
| **文本处理与分析**     | `grep`, `sed`, `awk`, `tr`, `sort`, `uniq`, `diff`, `cmp`, `comm`, `xargs`, `rev` | 查找、替换、格式化、排序、比较       |
| **文件权限与用户管理** | `chmod`, `chown`, `chgrp`, `umask`, `passwd`, `useradd`, `usermod`, `userdel`, `groupadd`, `groups`, `id` | 权限控制与用户组管理                 |
| **进程与作业管理**     | `ps`, `top`, `htop`, `nice`, `renice`, `kill`, `killall`, `jobs`, `fg`, `bg`, `nohup` | 查看、终止、后台运行进程等           |
| **系统信息查看**       | `uname`, `uptime`, `hostname`, `whoami`, `id`, `arch`, `vmstat`, `dmesg`, `lsb_release`, `free`, `lscpu`, `lsblk` | 显示系统信息、硬件信息               |
| **磁盘与存储管理**     | `df`, `du`, `mount`, `umount`, `fdisk`, `lsblk`, `blkid`, `parted`, `mkfs`, `fsck`, `tune2fs` | 磁盘使用、挂载、分区管理等           |
| **包管理（按发行版）** | `apt`, `dpkg`（Debian/Ubuntu），`yum`, `dnf`, `rpm`（RHEL/CentOS），`zypper`（openSUSE），`pacman`（Arch） | 安装、升级、删除软件包               |
| **网络工具**           | `ip`, `ifconfig`, `ping`, `traceroute`, `netstat`, `ss`, `dig`, `nslookup`, `curl`, `wget`, `nmap`, `iptables`, `ethtool`, `tcpdump`, `ntttcp`, `telnet`, `nc` | 网络配置、连接测试、抓包、端口扫描等 |
| **系统服务管理**       | `systemctl`, `journalctl`, `service`, `chkconfig`, `init`, `shutdown`, `reboot`, `poweroff` | 管理 systemd 或传统 init 服务        |
| **压缩与归档**         | `tar`, `gzip`, `gunzip`, `bzip2`, `xz`, `unzip`, `zip`, `7z` | 打包与压缩解压缩工具                 |
| **开发与编程辅助**     | `gcc`, `make`, `gdb`, `strace`, `lsof`, `nm`, `ldd`, `readelf`, `objdump`, `git`, `jq` | 编译、调试、查看依赖、版本控制等     |
| **权限提升与切换**     | `su`, `sudo`, `sudoedit`                                     | 权限切换与执行                       |
| **时间与调度**         | `date`, `cal`, `hwclock`, `crontab`, `at`                    | 查看时间、定时任务管理               |
| **环境管理与变量**     | `env`, `export`, `unset`, `set`, `alias`, `unalias`          | 环境变量设置与管理                   |
| **虚拟终端与会话**     | `screen`, `tmux`, `script`, `tty`, `who`, `w`, `login`, `logout` | 会话管理、多终端控制等               |
| **系统日志与监控**     | `journalctl`, `dmesg`, `logrotate`, `syslog`, `sar`, `iostat`, `iotop`, `vmstat` | 日志查看、性能监控工具               |
| **常用辅助工具**       | `which`, `whereis`, `type`, `time`, `yes`, `echo`, `expr`, `bc`, `sleep`, `watch`, `uptime`, `yes` | 日常辅助命令                         |



### 常见使用组合

| 场景               | 常用命令组合                                     |
| ------------------ | ------------------------------------------------ |
| 排查网络故障       | `ping` → `traceroute` → `ss/netstat` → `tcpdump` |
| 查看日志           | `journalctl` / `dmesg` / `less /var/log/*`       |
| 文件搜索与内容匹配 | `find` + `grep` + `xargs`                        |
| 后台运行任务       | `nohup` + `&` + `jobs` + `fg/bg`                 |
| 分析大文件         | `head` / `tail` / `wc` / `split` / `awk`         |
| JSON 数据处理      | `cat file.json                                   |