#!/usr/bin/env python3

#先安装pip3 install paramiko
import paramiko

# 创建SSH客户端
ssh_client = paramiko.SSHClient()

# 自动添加主机密钥（选项，根据需求使用）
ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

# 交换机的IP地址列表
switches = [
    # 用您实际的交换机IP地址替换这些
    	"192.168.100.1",
        "192.168.100.2",
        "192.168.100.3",
        "192.168.100.5",
        "192.168.100.10",
        "192.168.100.11",
        "192.168.100.12",
        "192.168.100.13",
        "192.168.100.14",
        "192.168.100.15",
        "192.168.100.16",
        "192.168.100.20",
        "192.168.100.21",
        "192.168.100.22",
        "192.168.100.23",
        "192.168.100.24",
        "192.168.100.25",
        "192.168.100.26",
        "192.168.100.27",
        "192.168.100.28",
        "192.168.100.30",
        "192.168.100.31",
        "192.168.100.40",
        "192.168.100.41",
        "192.168.100.50",
        "192.168.100.51",
        "192.168.100.52",
        "192.168.100.60",
        "192.168.100.63",
        "192.168.100.64",
        "192.168.100.65",
        "192.168.100.66",
    ]  


# SSH登录凭据，填交换机登录账户密码
username = "账号"
password = "密码"

# 连接每台交换机并执行命令
for switch_ip in switches:
    try:
        ssh_client.connect(switch_ip, username=username, password=password)
        ssh_shell = ssh_client.invoke_shell()

        # 执行命令
        ssh_shell.send("system-view\n")
        ssh_shell.send("info-center loghost 172.16.0.10\n")
        ssh_shell.send("info-center enable\n")
        ssh_shell.send("save force\n")

        # 等待命令执行完成
        while not ssh_shell.recv_ready():
            pass

        # 关闭连接
        ssh_client.close()

        print(f"Commands executed on {switch_ip}")
    except Exception as e:
        print(f"Failed to execute commands on {switch_ip}: {str(e)}")

# 关闭SSH客户端
ssh_client.close()

