# Windwos命令

## 快捷键

```bash
Win+i						# 打开系统设置
Win+v						# 剪切板快捷键（剪切板在系统设置 Win+u 打开搜索剪切板设置启用即可）
Win+ctrl+d					# win11新建虚拟桌面（可在任务栏的任务视图上查看所有虚拟桌面）
Win+ctrl+F4                 # 关闭当前虚拟桌面
Win+Ctrl+←/→                # 在虚拟桌面之间左右切换
ctrl+alt+←/→			    # 网易云切歌
Win聚焦位置
Win+Alt+G 		 			# Win10录屏
Win+R                       # 打开运行窗口

# 运行窗口下执行命令
cmd                         # 打开命令提示符（输入后按 ctrl+shift+enter 键可通过管理员运行）
compmgmt.msc				# 打开计算机本地管理
control firewall.cpl        # 打开防火墙设置
ncpa.cpl                    # 打开网络连接
intl.cpl                    # 打开区域设置
sysdm.cpl                   # 打开系统属性设置
msconfig                    # 打开系统配置
msinfo32                    # 查看系统详细信息（包含系统型号、制造商、BISO版本日期等）
slmgr.vbs -dlv              # 查询激活信息（包括激活ID、安装ID、激活截止日期等）
slmgr.vbs -dli              # 查询操作系统版本、部分产品密钥、许可证状态等
slmgr.vbs -xpr              # 查询win是否永久激活
winver                      # 査询系统内核版本，以及注册用户信息
```

## 文件夹操作

```bash
dir    # 查看文件夹内容

## 删除文件夹
takeown /F "E:\Code" /R /D Y                    # 将文件夹所有权转移到当前用户
icacls "E:\Code" /grant %username%:F /T         # 将文件夹权限授予当前用户
rmdir /S /Q "E:\Code"                           # 删除文件夹及其内容

## 文件夹赋权
whoami								# 查看当前用户
icacls "D:\example\folder"			# 查看某个文件夹权限
icacls "C:\Program Files (x86)\Base_Software" /grant sunline\sun:F /T /C		# 某文件夹权限授予权限给 sunline\sun
```



## 网络相关命令

```bash
ssh mengjia@192.168.3.79 -p 22  # windows远程linux服务器
ipconfig/flushdns               # 刷新DNS解析缓存
ipconfig/renew                  # 更新 DHCP 租约并重新获取 IP 地址
nslookup appstoreconnect.apple.com 218.85.152.99   # 测试域名解析结果
nslookup chatgpt.com 8.8.8.8 | findstr "Address" | findstr /v "8.8.8.8"    # 筛选
netsh winsock reset             # 重置 Winsock 目录，修复网络连接相关的问题（无法上网但网络连接正常、DNS 解析失败、某些程序无法联网、IP 地址获取异常）

ping -t 10.0.0.44 |Foreach{"{0} - {1}" -f (Get-Date),$_}  	# 使用powershell ping值带时间
ping -l 5000 10.0.0.44  									# ping发送大包，linux下使用-s

arp -a             				# 查看arp缓存表
arp -d             				# 清除arp缓存表
arp -d 10.0.0.4    				# 清除arp缓存时指定IP


telnet ip 端口				  # telnet 命令用法
按ctrl+]，再输入quit    			# 退出telent界面
```



## 常用命令

```bash
wmic bios get serialnumber		# 查看系统设备序列号
wmic							# 内存信息查询
memorychip						# 输入查询内存


# 时区设置
tzutil /g                        # 执行命令以查看当前时区设置
tzutil /s "China Standard Time"  # 调整时区设置，可使用命令

# 共享配置
net user                     # 查看samba连接情况
net use * /del               # 删除连接
net use \\10.0.0.4\sharing   # 删除缓存记录（切换用户）


net config workstation        # 查看计算机工作组信息
net localgroup sjrlfwb        # 查看用户组下的成员


# 关闭hyper-v服务
bcdedit /set hypervisorlaunchtype off				# 用于禁用 Hyper-V 虚拟化支持
bcdedit /set {current} hypervisorlaunchtype off		# 对当前启动项（当前系统运行的启动配置）设置该项为 off

```
