import paramiko
import re

def sshExeCMD():

    ssh_client = paramiko.SSHClient()

    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy()) 
    
    ssh_client.connect(hostname="192.168.31.223",port=22,username="root",password="123456")

    '''
    1. 标准输入  用于实现交互命令
    2. 标准输出  用于实现命令的执行结果
    3. 标准错误  用于实现错误信息
    '''

    stdin,stdout,stderr = ssh_client.exec_command("hostname")
    print(stdout.read())

    ssh_client.close()

if __name__ == '__main__':
    sshExeCMD()