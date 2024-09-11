import paramiko
import sys
import mysql.connector

def get_server_info_from_db():
    db = mysql.connector.connect(
        host="192.168.31.223",  
        user="root",            
        password="123456",      
        database="ip_info"     
    )
    cursor = db.cursor()

    query = "SELECT ip, name, password, port FROM servers" 
    cursor.execute(query)
    results = cursor.fetchall()
    
    servers = {}
    for result in results:
        ip, name, password, port = result
        servers[ip] = {
            "username": name,
            "password": password,
            "port": port
        }
    
    cursor.close()
    db.close()
    
    print("成功从数据库调取server_info") 
    return servers

def sshExeCMD(ip, username, password, port, command):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    print("连接服务器%s中..." % ip)
    try:
        ssh_client.connect(
            hostname=ip,
            port=port,
            username=username,
            password=password
        )
    except Exception as e:
        print("连接服务器%s失败,请检查ip地址和端口是否正确!" % ip)
        print(e)
        sys.exit(1)

    stdin, stdout, stderr = ssh_client.exec_command(command)
    print("服务器%s执行结果：" % ip)
    print(stdout.read().decode('utf-8'))
    ssh_client.close()

if __name__ == '__main__':
    servers = get_server_info_from_db()  
    command_to_execcute = "netstat -tnlp" 
    for ip, info in servers.items():
        sshExeCMD(
            ip=ip,
            username=info.get("username"),
            password=info.get("password"),
            port=info.get("port"),
            command=command_to_execcute
        )