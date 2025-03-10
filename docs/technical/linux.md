# linux

## 常用快捷键

```
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



## 关机重启

```
shutdown -r now		# 重启
reboot				# 重启
init 6				# 重启

shutdown -h now		# 关机
init 0				# 关机
```





## 服务器管理常用命令

```
du -h --max-depth=1 /                         						# 列出 / 目录下所有文件夹的大小
du -h --max-depth=1 / | sort -hr              						# 查找系统中占用大量空间的文件和目录
cat /dev/urandom | md5sum                     						# 调高内存
yum -y install dos2unix && dos2unix install-mysql-5.7.43.sh  		# 脚本格式转换
ps aux | head -1 ; ps aux | sort -rn -k3 | head -10  				# 获取占用 CPU 最高 10 个进程
ps aux | head -1; ps aux | sort -rn -k4 | head -10  				# 获取内存占用最高前 10 个进程
awk '/^PRETTY_NAME=/' /etc/*-release 2>/dev/null | awk -F'=' '{gsub("\"","");print $2}'  		# 获取 PRETTY_NAME
netstat -ant | grep 'ESTABLISHED' | wc -l							# 总连接数量
netstat -ant | awk '/^tcp/ {print $4}' | cut -d: -f2 | sort | uniq -c							# 连接的端口
iostat -x 1 2 | grep -A 1 'Device' | tail -n 1						# 磁盘 I/O 读和写
ifstat -i eth0 1 1 | tail -n 1										# 数据流量的上传和下载
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'		# CPU使用率
top -bn1 | grep "MiB Mem" | awk '{print $8/$4 * 100"%"}'			# 内存使用率
ps aux --sort=-%cpu | head -n 11									# CPU排名前 10 的应用
ps aux --sort=-%mem | head -n 11									# MEM排名前 10 的应用
netstat -ant | awk '/^tcp/ {printf "%-20s %-20s %s\n", $5, $4, $6}'	# 查看详细连接信息（IP + 端口 + 状态）
netstat -ant | awk '$5 ~ /10.18.10.22/ {print $5}' | cut -d: -f1 | sort | uniq -c				# 筛选指定 IP 的连接
```

## 搜索常用

```
find /var/lib -type f -size +100M -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'  		# 查找 >100MB 的文件
find / -type f -size +1G -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'  				# 查找 >1GB 的文件
```

## 进程管理命令

```
ps -p 16005 -o pid,cwd,cmd    	# 查看进程的工作目录和启动命令
readlink /proc/22889/exe       	# 查看进程可执行文件的路径
top                            	# 实时查看系统资源使用情况
htop                           	# `top` 的增强版，提供更直观的图形界面
pstree                         	# 显示进程树，查看进程之间的父子关系
lsof                           	# 列出当前系统打开的文件和相应的进程
pgrep pure-ftpd                	# 根据进程名称查找进程 ID
kill 22889                      # 发送信号终止进程
nice -n 10 command             	# 设置进程的优先级（负数为高优先级，正数为低优先级）
renice -n 10 -p 22889          	# 修改正在运行进程的优先级
strace -p 22889                	# 跟踪进程的系统调用和信号
vmstat                         	# 查看系统的虚拟内存、进程、I/O 等统计信息
```

## 文本编辑命令

### vim

```
vim工作模式
格式：
        vim   文件名 

在命令模式下，进入插入模式：
            i        i在光标所在字符前插入
            a        输入a表示在光标所在字符后插入
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

替换和取消
            r              取消光标所在处字符
            R              从光标所在处开始替换字符
            u              取消上一步操作
            
搜索和搜索替换
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
             
保存退出
            esc            退出编辑模式
            :w             保存修改
            :w new_filename        另存为指定文件
            :wq            保存退出
            :wq!           保存修改并退出
            ZZ             保存修改并退出快捷键
            :q!            退出命令模式，不保存文件
            :q!            不保存退出


导入命令
            :r 文件名      可以将一个文件导入到vi中
            :!   命令      可不退出vim下执行其他命令
            :! date       查看当前时间
            :r !date      将当前时间导入到光标所在处（写完脚本记录时间）
            :map ctrl+v ctrl+p I#<Esc>    使用快捷键注释行首

批量注释：

<1>         :1,10s/^/#/g        #注释1-0行
            :1,10normal I#      #建议用这种方式注释，第一种方式注释以后会出现第一列颜色改变
            :1,10s/^#//g        #取消注释
            :noh                #取消高亮
 
<2>
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

