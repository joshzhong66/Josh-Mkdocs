import tkinter as tk
import paramiko

def login_to_vpn():
    vpn_ip = vpn_ip_entry.get()
    username = username_entry.get()
    password = password_entry.get()

    try:
        # 建立SSH连接
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(vpn_ip, 22, username, password)
        login_status_label.config(text="Login successful", fg="green")
        ssh_client.close()
    except Exception as e:
        login_status_label.config(text="Login failed", fg="red")

def execute_commands():
    commands = commands_text.get("1.0", tk.END)

    vpn_ip = vpn_ip_entry.get()
    username = username_entry.get()
    password = password_entry.get()

    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(vpn_ip, 22, username, password)

        for command in commands.splitlines():
            stdin, stdout, stderr = ssh_client.exec_command(command)
            output = stdout.read().decode()
            result_text.insert(tk.END, f"Command: {command}\n{output}\n")

        ssh_client.close()
    except Exception as e:
        result_text.insert(tk.END, f"Error executing commands: {str(e)}\n")

# 创建GUI窗口
root = tk.Tk()
root.title("VPN Command Executor")

# VPN连接信息输入
vpn_ip_label = tk.Label(root, text="Server IP:")
vpn_ip_label.pack()
vpn_ip_entry = tk.Entry(root, width=30)
vpn_ip_entry.pack()

username_label = tk.Label(root, text="Username:")
username_label.pack()
username_entry = tk.Entry(root, width=30)
username_entry.pack()

password_label = tk.Label(root, text="Password:")
password_label.pack()
password_entry = tk.Entry(root, show="*", width=30)
password_entry.pack()

# 登录按钮
login_button = tk.Button(root, text="Login", command=login_to_vpn)
login_button.pack(pady=10)

# 登录状态
login_status_label = tk.Label(root, text="", fg="black")
login_status_label.pack()

# 输入多条命令
commands_label = tk.Label(root, text="Enter commands (one per line):")
commands_label.pack()
commands_text = tk.Text(root, height=5, width=50)
commands_text.pack()

# 执行按钮
execute_button = tk.Button(root, text="执行命令", command=execute_commands)
execute_button.pack(pady=10)

# 显示结果的文本框
result_text = tk.Text(root, height=20, width=50)
result_text.pack()

root.mainloop()
