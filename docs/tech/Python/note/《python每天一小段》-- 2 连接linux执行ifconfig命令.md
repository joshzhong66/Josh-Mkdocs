## 《Python每天一小段》--（2）使用Paramiko库，操作多Linux服务器

本文介绍了如何使用Paramiko库建立SSH连接并执行命令获取多个Linux服务器的磁盘信息。通过这个例子，你可以学习到如何使用Python自动化操作远程服务器。

### 代码解析

以下是代码的详细解释：

```python
import paramiko
import sys

def sshExeCMD(ip, username, password, port):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        ssh_client.connect(hostname=ip, port=port, username=username, password=password)
    except Exception as e:
        print("连接服务器%s失败，请检查IP地址和端口是否正确！" % ip)
        print(e)
        sys.exit(1)

    stdin, stdout, stderr = ssh_client.exec_command("df -hT")
    print("服务器%s磁盘信息：" % ip)
    print(stdout.read().decode('utf-8'))

    ssh_client.close()

if __name__ == '__main__':
    servers = {
        "192.168.31.223": {
            "username": "root",
            "password": "123456",
            "port": 22
        },
        "192.168.31.162": {
            "username": "root",
            "password": "123456",
            "port": 22
        }
    }
    for ip, info in servers.items():
        sshExeCMD(
            ip=ip,
            username=info.get("username"),
            password=info.get("password"),
            port=info.get("port")
        )
```

### 代码说明

1. 导入必要的模块：`paramiko`用于SSH连接，`sys`用于系统相关操作。

2. 定义了一个名为`sshExeCMD`的函数，用于执行SSH连接和命令执行操作。函数接受四个参数：`ip`（服务器的IP地址），`username`（用户名），`password`（密码）和`port`（SSH端口号）。

3. 在函数内部，创建了一个SSH客户端对象`ssh_client`，并使用`paramiko.AutoAddPolicy()`设置了自动添加服务器主机密钥到本地`known_hosts`文件的策略。

4. 使用`ssh_client.connect()`方法连接到指定的服务器。如果连接失败，打印错误信息并退出程序。

5. 如果连接成功，使用`ssh_client.exec_command()`方法执行命令`df -hT`，该命令用于获取磁盘信息。返回的结果包括标准输入、标准输出和标准错误。

6. 打印服务器IP和磁盘信息。

7. 关闭SSH连接。

8. 在`__name__ == '__main__'`的条件下，定义了一个包含多个服务器信息的字典`servers`。

9. 使用`for`循环遍历`servers`字典中的每个服务器信息。

10. 调用`sshExeCMD`函数，并传入服务器的IP地址、用户名、密码和端口号作为参数。

### 总结

本文介绍了如何使用Paramiko库在Python中操作多个Linux服务器。通过建立SSH连接并执行命令，我们可以获取远程服务器的磁盘信息。这个例子展示了Python在自动化操作服务器方面的强大能力，为服务器管理和维护提供了便利。

希望本文对你理解Paramiko库的使用以及Python操作远程服务器有所帮助！