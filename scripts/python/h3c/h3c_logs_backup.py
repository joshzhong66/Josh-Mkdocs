#!/usr/bin/env python3

import paramiko


ssh_client = paramiko.SSHClient()
ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())


switches = [
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



username = "user"
password = "password"

for switch_ip in switches:
    try:
        ssh_client.connect(switch_ip, username=username, password=password)
        ssh_shell = ssh_client.invoke_shell()
        ssh_shell.send("system-view\n")
        ssh_shell.send("info-center loghost 172.16.0.10\n")
        ssh_shell.send("info-center enable\n")
        ssh_shell.send("save force\n")
        while not ssh_shell.recv_ready():
            pass
        ssh_client.close()

        print(f"Commands executed on {switch_ip}")
    except Exception as e:
        print(f"Failed to execute commands on {switch_ip}: {str(e)}")

ssh_client.close()

