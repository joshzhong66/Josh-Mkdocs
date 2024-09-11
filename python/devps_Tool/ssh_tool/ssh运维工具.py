import os.path
import re
import time
from tkinter.ttk import Combobox

import paramiko
from ttkbootstrap import Window, Frame, Label, Entry, Text, Button, Style, Progressbar
from ttkbootstrap.dialogs import Messagebox
from ttkbootstrap.constants import *
from tkinter import StringVar
from tkinter.scrolledtext import ScrolledText


def log_error(message):
    Messagebox.show_error(message, title="错误信息！", alert=True)

def log_info(message):
    Messagebox.show_info(message, title="提示信息", alert=False)


class SHHServer(Frame):
    def __init__(self, master=None):
        super().__init__(master, padding=(20, 10))
        self.pack(fill=BOTH, expand=YES)
        self.hostname = StringVar()
        self.port = StringVar()
        self.port.set("22")
        self.username = StringVar()
        self.username.set("yunwei")
        self.password = StringVar()
        self.password.set("Sun%2020")
        self.done_txt = StringVar()

        self.create_form_frame()
        self.create_info_frame()

        self.command.insert("1.0", "ls -l")

    def create_form_frame(self):
        container = Frame(self)
        container.pack(fill=BOTH, expand=YES, padx=(300, 0))
        # 服务器IP
        ssh_hostname_lbl = Label(master=container, text="服务器IP：")
        ssh_hostname_lbl.grid(row=0, column=0, padx=(10, 0), pady=10)
        ssh_hostname_input = Entry(master=container, width=30, textvariable=self.hostname)
        ssh_hostname_input.grid(row=0, column=1, columnspan=3, padx=(0, 10), ipadx=60)
        ssh_hostname_input.focus_set()    # 将焦点设置到这个文本输入框
        ssh_hostname_lbl2 = Label(master=container, text="提示：多ip可用,/;三种符号隔开", style=DANGER)
        ssh_hostname_lbl2.grid(row=0,column=4, columnspan=3)
        # 服务端口
        ssh_password_lbl = Label(master=container, text="服务端口：")
        ssh_password_lbl.grid(row=1, column=0, padx=(10, 0), pady=10)
        ssh_password_input = Entry(master=container, width=30, textvariable=self.port)
        ssh_password_input.grid(row=1, column=1, columnspan=3, padx=(0, 10), ipadx=60)
        # 用户名
        ssh_username_lbl = Label(master=container, text="用户名：")
        ssh_username_lbl.grid(row=2, column=0, padx=(10, 0), pady=10)
        ssh_username_input = Entry(master=container, width=30, textvariable=self.username)
        ssh_username_input.grid(row=2, column=1, columnspan=3, padx=(0, 10), ipadx=60)
        # 密码
        ssh_password_lbl = Label(master=container, text="密码：")
        ssh_password_lbl.grid(row=3, column=0, padx=(10, 0), pady=10)
        ssh_password_input = Entry(master=container, width=30, show="*", textvariable=self.password)
        ssh_password_input.grid(row=3, column=1, columnspan=3, padx=(0, 10), ipadx=60)
        # 执行命令
        ssh_command_lbl = Label(master=container, text="执行命令：")
        ssh_command_lbl.grid(row=4, column=0, padx=(10, 0), pady=10, sticky=N)
        self.command = Text(master=container, width=30, height=8)
        self.command.grid(row=4, column=1, columnspan=3, padx=(0, 10), ipadx=60)
        # 执行脚本
        ssh_script_lbl = Label(master=container, text="执行脚本：")
        ssh_script_lbl.grid(row=5, column=0, padx=(10, 0), pady=10)
        self.script = Combobox(master=container, width=28, values=('修改root密码', '创建挂载磁盘'), state=READONLY)
        self.script.grid(row=5, column=1, columnspan=3, padx=(0, 10), ipadx=60)
        self.script.bind("<1>", self.script.event_generate('<<ComboboxSelected>>'))  # <1>指鼠标左键，点击任意地方均可触发
        # 执行命令按钮
        submit_btn = Button(master=container, text="执行命令", width=10, bootstyle=SUCCESS, command=self.on_submit_command)
        submit_btn.grid(row=6, column=1, padx=(0, 10), pady=20)
        # 执行脚本按钮
        submit_btn = Button(master=container, text="执行脚本", width=10, bootstyle=SUCCESS, command=self.on_submit_script)
        submit_btn.grid(row=6, column=2, padx=(0, 10), pady=20)
        # 退出
        quit_btn = Button(master=container, text="退出程序", width=10, bootstyle=DANGER, command=self.on_quit)
        quit_btn.grid(row=6, column=3, padx=(0, 10), pady=20)

    def create_info_frame(self):
        container1 = Frame(self)
        container1.pack(fill=BOTH, expand=True)
        # 日志信息
        log = Label(master=self, text="日志信息：", width=100, style=SUCCESS)
        log.pack(fill=X, pady=10)
        style = Style()
        self.textbox = ScrolledText(
            master=self,
            highlightcolor=(style.colors.primary),
            highlightbackground=(style.colors.border),
            highlightthickness=1,
            height=20,
            width=30)
        self.textbox.pack(fill=X, pady=10)

        container2 = Frame(self)
        container2.pack(fill=BOTH, expand=True)
        # 已完成
        ssh_done = Label(master=container2, text="已完成:", style=DANGER)
        ssh_done.pack(padx=5, side=LEFT)
        # 进度条方框
        self.done_bar = Progressbar(
            master=container2,
            orient=HORIZONTAL,
            value=0,
            bootstyle=(SUCCESS, STRIPED))
        self.done_bar.pack(fill=X, pady=5, expand=YES, side=LEFT)
        # 进度条加载
        ssh_txt_done = Label(master=container2, textvariable=self.done_txt, style=SUCCESS)
        ssh_txt_done.pack(side=LEFT, padx=5)

    def on_quit(self):
        self.quit()

    def on_submit_command(self):
        hostnames = re.split(r"[,/;]",self.hostname.get())
        port = self.port.get()
        username = self.username.get()
        password = self.password.get()
        command = self.command.get("1.0", "end-1c")

        if not any(hostnames):
            log_error("服务器IP不能为空！")
            return
        elif not port:
            log_error("服务端口不能为空！")
            return
        elif not username:
            log_error("用户名不能为空！")
            return
        elif not password:
            log_error("密码不能为空！")
            return
        elif not command:
            log_error("执行命令不能为空！")
            return

        self.textbox.delete("1.0", END)
        # 在每台服务器上执行相同命令
        i = 0
        for hostname in hostnames:
            i += 1
            self.execute_command(hostname, port, username, password, command, i, len(hostnames))
            if not hostnames.index(hostname) == len(hostnames) - 1:
                self.textbox.insert(END,'\n')

    def on_submit_script(self):
        hostnames = re.split(r"[,/;]", self.hostname.get())
        port = self.port.get()
        username = self.username.get()
        password = self.password.get()
        script = self.script.get()

        if not any(hostnames):
            log_error("服务器IP不能为空！")
            return
        elif not port:
            log_error("服务端口不能为空！")
            return
        elif not username:
            log_error("用户名不能为空！")
            return
        elif not password:
            log_error("密码不能为空！")
            return
        elif not script:
            log_error("执行脚本不能为空！")
            return

        # 获取选择脚本的脚本路径
        local_script_path = ''
        remote_script_path = ''
        if script == '修改root密码':
            local_script_path = os.path.join(os.path.dirname(__file__), 'setpwd.sh')
            remote_script_path = '/home/yunwei/setpwd.sh'
        elif script == '创建挂载磁盘':
            local_script_path = os.path.join(os.path.dirname(__file__), 'fdisk.sh')
            remote_script_path = '/home/yunwei/fdisk.sh'
        self.textbox.delete("1.0", END)
        # 在每台服务器上执行相同命令
        i = 0
        for hostname in hostnames:
            i += 1
            self.execute_script(hostname, port, username, password, local_script_path, remote_script_path, i, len(hostnames))
            if not hostnames.index(hostname) == len(hostnames) - 1:
                self.textbox.insert(END, '\n')

    def execute_command(self, hostname, port, username, password, command, j, count):
        client = paramiko.SSHClient()  # 创建SSH对象
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())  # 自动添加服务器的SSH密钥

        try:
            client.connect(hostname, port, username, password)  # 连接服务器
            # 判断command命令是否有多条命令执行
            if '\n' in command:
                command_list = command.split('\n')
            else:
                command_list = [command]
            for com in command_list:
                stdin, stdout, stderr = client.exec_command(com)  # 执行命令
                output = stdout.read().decode('utf-8')
                stderr = stderr.read().decode()
                if not output == '':
                    self.textbox.insert(END, f"({hostname})#{com}\n{output}")
                elif not stderr == '':
                    self.textbox.insert(END, f"({hostname})#{com}\n{stderr}")
                else:
                    self.textbox.insert(END, f"({hostname})#{com}\n")
                self.textbox.see(END)  # 自动滚动到最后一行

            self.done_bar["value"] = int(j / count * 100)
            self.done_txt.set(f"{j}/{count}")
            self.textbox.update()  # 实时更新最新的文本框状态
            time.sleep(2)  # 2秒后再继续执行

        except Exception as e:
            self.textbox.insert(END, f"连接到 {hostname} 失败：{str(e)}")

        finally:
            client.close()

    def execute_script(self, hostname, port, username, password, local_script_path, remote_script_path, j, count):
        client = paramiko.SSHClient()  # 创建SSH对象
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())  # 自动添加服务器的SSH密钥

        try:
            client.connect(hostname, port, username, password)  # 连接服务器

            # 上传本地脚本路径到远程服务器
            sftp = client.open_sftp()
            sftp.put(local_script_path, remote_script_path)
            sftp.close()

            # 判断是否多个服务器，若是则生成随机密码
            if count > 1 and 'setpwd.sh' in remote_script_path:
                stdin, stdout, stderr = client.exec_command(f'sh {remote_script_path} r')  # 执行脚本文件
            else:
                stdin, stdout, stderr = client.exec_command(f'sh {remote_script_path}')  # 执行脚本文件

            # 删除上传后的脚本
            client.exec_command(f'rm {remote_script_path}')

            output = stdout.read().decode('utf-8')
            stderr = stderr.read().decode()
            if not output == '':
                self.textbox.insert(END, f"({hostname}):\n{output}")
            elif not stderr == '':
                self.textbox.insert(END, f"({hostname}):\n{stderr}")
            else:
                self.textbox.insert(END, f"({hostname}):\n")
            self.textbox.see(END)  # 自动滚动到最后一行

            self.done_bar["value"] = int(j / count * 100)
            self.done_txt.set(f"{j}/{count}")
            self.textbox.update()  # 实时更新最新的文本框状态
            time.sleep(2)  # 2秒后再继续执行

        except Exception as e:
            self.textbox.insert(END, f"连接到 {hostname} 失败：{str(e)}")

        finally:
            client.close()


if __name__ == "__main__":
    app = Window("ssh自动化运维", "pulse", resizable=(False, False))
    SHHServer(app)
    app.mainloop()
