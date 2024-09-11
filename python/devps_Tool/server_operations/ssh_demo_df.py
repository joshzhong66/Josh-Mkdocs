import paramiko
import sys

def sshExeCMD(ip,username,password,port):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())


    try:
        ssh_client.connect(hostname=ip,port=port,username=username,password=password)
    except Exception as e:
        print("连接服务器%s失败，请检查ip地址和端口是否正确！" % ip)
        print(e)
        sys.exit(1)

    stdin,stdout,stderr = ssh_client.exec_command("df -hT")
    print("服务器%s磁盘信息：" % ip)
    print(stdout.read().decode('utf-8'))

    ssh_client.close()

if __name__ == '__main__':
    servers = {
        "192.168.42.128":{
            "username":"root",
            "password":"123456",
            "port":22
        },
        "192.168.42.130":{
            "username":"root",
            "password":"123456",
            "port":22
        }
    }
    for ip,info in servers.items():
        sshExeCMD(
            ip = ip,
            username = info.get("username"),
            password = info.get("password"),
            port = info.get("port")
        )