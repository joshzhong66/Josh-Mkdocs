# linux管理常用命令



## 一、常用快捷键

```bash
##############################################################################
# 常用快捷键（默认使用 Emacs 键位）
##############################################################################

CTRL+B              # 向前移动
CTRL+F              # 向后移动
CTRL+A              # 移动到行首
CTRL+E              # 移动到行尾
CTRL+C              # 结束当前命令
CTRL+H              # 删除光标左边的字符
CTRL+K              # 删除光标位置到行末的内容
CTRL+L              # 清屏并重新显示
CTRL+N              # 移动到命令历史的下一行，同 <Down>
CTRL+O              # 类似回车，但是会显示下一行历史
CTRL+P              # 移动到命令历史的上一行，同 <Up>
CTRL+T              # 交换前后两个字符
CTRL+U              # 删除字符到行首
CTRL+W              # 删除光标左边的一个单词

ALT+数字			   # 切换窗口
```



## 二、系统常用命令

```bash
printenv			# 查看当前系统的环境变量
shutdown -r now		# 重启（init 6、reboot）
shutdown -h now		# 关机（init 0）
```



## 三、服务器管理常用命令

```bash
du -sh /opt							# 查看 /opt 目录总大小（-s 表示 "summarize"（汇总），只显示每个参数的总大小，不递归显示子目录的详细信息）
du -sh /var/*						# 查/var下所有子目录及子文件大小
du -h --max-depth=1 /data			# 查看 /data 下各子目录大小
du -sh --exclude="cache" /data		# 查看 /data 目录总大小，并排除缓存文件
du -h --max-depth=1 /				# 列出 / 目录下所有文件夹的大小
du -h --max-depth=1 / | sort -hr	# 查找系统中占用大量空间的文件和目录
docker system df --format "{{.Type}}: {{.Size}} {{.Reclaimable}}" | grep -v '0B'	# 查看docker镜像占用


dos2unix install-mysql-5.7.43.sh	# 脚本格式转换（yum -y install dos2unix）
cat /dev/urandom | md5sum			# 调高内存

# CPU使用率
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'	
ps aux --sort=-%cpu | head -n 11	# CPU排名前 10 的应用
ps aux | head -1 ; ps aux | sort -rn -k3 | head -10				# 获取占用 CPU 最高 10 个进程

	
ps aux --sort=-%mem | head -n 11	# 内存排名前 10 的应用
ps aux | head -1; ps aux | sort -rn -k4 | head -10				# 获取内存占用最高前 10 个进程
top -bn1 | grep "KiB Mem" | awk '{print $8/$4 * 100"%"}'		# 内存使用率


netstat -ant | grep 'ESTABLISHED' | wc -l									# 总连接数量
netstat -ant | awk '/^tcp/ {print $4}' | cut -d: -f2 | sort | uniq -c		# 连接的端口

# 查看详细连接信息（IP + 端口 + 状态）
netstat -ant | awk '/^tcp/ {printf "%-20s %-20s %s\n", $5, $4, $6}'			
# 筛选指定 IP 的连接
netstat -ant | awk '$5 ~ /10.18.10.22/ {print $5}' | cut -d: -f1 | sort | uniq -c


iostat -x 1 2 | grep -A 1 'Device' | tail -n 1		# 磁盘 I/O 读和写
ifstat -i eth0 1 1 | tail -n 1						# 数据流量的上传和下载


awk '/^PRETTY_NAME=/' /etc/*-release 2>/dev/null | awk -F'=' '{gsub("\"","");print $2}'		# 获取 PRETTY_NAME

cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l	# 查看物理cpu个数
cat /proc/cpuinfo | grep "cpu cores" | wc -l		# 查看每个物理CPU的核心
```



## 四、搜索常用命令

```bash
# 查找 /var/lib 目录下 >100MB 的文件
find /var/lib -type f -size +100M -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
# 查找 根目录下 >1GB 的文件
find / -type f -size +1G -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
```



## 五、进程管理命令

```bash
ps -p 16005 -o pid,cwd,cmd    	# 查看进程的工作目录和启动命令
readlink /proc/22889/exe       	# 查看进程可执行文件的路径
top                            	# 实时查看系统资源使用情况
htop                           	# `top` 的增强版，提供更直观的图形界面
pstree                         	# 显示进程树，查看进程之间的父子关系
lsof                           	# 列出当前系统打开的文件和相应的进程
pgrep pure-ftpd                	# 根据进程名称查找进程 ID
kill 22889                      # 发送信号终止进程
pkill -9 -f "zabbix_agentd"		# 通过进程名批量终止
nice -n 10 command             	# 设置进程的优先级（负数为高优先级，正数为低优先级）
renice -n 10 -p 22889          	# 修改正在运行进程的优先级
strace -p 22889                	# 跟踪进程的系统调用和信号
vmstat                         	# 查看系统的虚拟内存、进程、I/O 等统计信息
```



## 六、服务管理命令

```bash
systemctl list-units --type=service --state=running        # 列出已启动的服务
systemctl list-units --type=service                        # 列出所有服务（包含已停止的）
systemctl list-unit-files --type=service | grep enabled    # 列出所有开机启动的服务
```



## 七、内核命令

```bash
grubby --default-kernel    		# 当前启动的内核
```



## 八、安全防火墙命令

```bash
# SELinux 是重要的安全层，禁用后系统更易受提权攻击或服务漏洞影响
Disabled - 完全禁用
Permissive - 宽容模式（仅记录不拦截）
Enforcing - 强制模式（完全启用）

sestatus               # 查看SELinux 状态
getenforce             # 查看SELinux 状态
setenforce 0 		   # 临时关闭SELinux（无需关机）

sed -ri 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config		# 永久关闭SELinux

sed -i 's/^SELINUX=.*/SELINUX=enforcing/g' /etc/selinux/config			# 永久启用 SELinux
reboot

firewall-cmd --state   # 查看防火墙状态
```



## 九、文本编辑命令

```bash
vim工作模式
格式：
        vim   文件名 

在命令模式下，进入插入模式：
            i        i在光标所在字符前插入
            a        a在光标所在字符后插入
            I        I在光标所在行行首插入
            A        A在光标所在行尾插入
            o        o在光标下插入新行
            O        O在光标上插入新行
            C        删除光标之后的行内容，并且进入插入模式

在命令模式下，进入编辑模式：
            :        输入:冒号进入编辑模式，命令以回车结束运行

定位命令：
            :set nu       设置行号
            :set nonu     取消行号
             gg           到第一行
             G            到最后一行
             nG           到第n行
             :n           到第n行
             $            移至行尾

复制和剪切：
            yy             复制当前行
            nyy            复制当前行以下n行
            dd             剪切当前行
            ndd            剪切当前行以下n行
            p              粘贴在当前光标所在行下或行上

替换和取消：
            r              取消光标所在处字符
            R              从光标所在处开始替换字符
            u              取消上一步操作

搜索和搜索替换：
            /              搜索指定字符串
            n              搜索指定字符串的下一个出现位置，
            :%old/new/g         全文替换字符串
            :n1.n2s/old/new/g   在一定范围内替换指定字符串

删除命令：
              x            删除光标所在处字符
             nx            删除光标所在处后n个字符
             dd            删除光标所在行
             ndd           删除n行
             dG            删除光标所在行到文件末尾内容

保存退出：
            esc            退出编辑模式
            :w             保存修改
            :w new_filename        另存为指定文件
            :wq            保存退出
            :wq!           保存修改并退出
            ZZ             保存修改并退出快捷键
            :q!            退出命令模式，不保存文件
            :q!            不保存退出

导入命令：
            :r 文件名      可以将一个文件导入到vi中
            :!   命令      可不退出vim下执行其他命令
            :! date       查看当前时间
            :r !date      将当前时间导入到光标所在处（写完脚本记录时间）
            :map ctrl+v ctrl+p I#<Esc>    使用快捷键注释行首

批量注释：
            :1,10s/^/#/g        #注释1-0行
            :1,10normal I#      #建议用这种方式注释，第一种方式注释以后会出现第一列颜色改变
            :1,10s/^#//g        #取消注释
            :noh                #取消高亮

添加注释：
            Ctrl + v 进入块选择模式；
            移动光标选中你要注释的行；
            再按大写的 I 进入行首插入模式输入注释符号如 // 或 #；
            输入完毕之后，按两下 ESC；

取消注释：
            Ctrl + v 进入块选择模式，
            选中你要删除的行首的注释符号，
            如果是//，键盘箭头左右调整，选中两列，按 d 即可删除注释


:编辑模式  map 快捷键设置为ctrl+p   在代码首行按快捷键，就会自动注释
:map ctrl+v ctrl+H  980521387@qq.com<ESC>   将邮箱设置为快捷键

也可以把快捷键存放在用户的配置文件/.vimrc下，重启也不会失效，
root   /root/.vimrc
user   /home/username/.vimrc
```



## 十、网络常用命令

```bash
ip link set eth0 up                     # 启用名为 eth0 的网络接口
ip addr del 10.22.51.66/24 dev eth0     # 为 eth0 接口删除 IP 地址和子网掩码（临时配置）
ip addr add 10.22.51.65/24 dev eth0     # 为 eth0 接口添加 IP 地址和子网掩码（临时配置）
ip route add default via 10.22.51.254   # 添加默认网关路由

# NetworkManager 命令行工具
nmcli connection reload       # 重新加载配置文件
nmcli connection up ens33     # 重启ens33网卡
```



## 十一、初始化命令

```bash
systemctl disable --now NetworkManager	# NetworkManager 是管理网络连接的主要服务，适用于动态网络环境（如 Wi-Fi、VPN、移动热点等）
systemctl disable --now firewalld		# firewalld 是默认的动态防火墙管理服务（- disable：禁止 NetworkManager 开机自启）
systemctl disable --now rsyslog			# rsyslogd 是系统日志服务，负责收集和管理系统及应用程序的日志
systemctl disable --now kdump			# kdump 是内核崩溃转储服务，用于在系统发生内核崩溃时收集调试信息
systemctl disable --now postfix			# postfix 是默认的邮件传输代理（MTA）服务（- --now：同时立即停止当前运行的服务（相当于 stop））

# auditd 是 Linux 审计系统（audit subsystem）的核心守护进程，用于记录系统安全事件
sed -i 's/RefuseManualStop=yes/RefuseManualStop=no/g' /usr/lib/systemd/system/auditd.service
systemctl daemon-reload && systemctl disable --now auditd &>/dev/null	

# 禁用 SSH 连接时的 DNS 反向解析功能
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config && systemctl restart sshd
```





