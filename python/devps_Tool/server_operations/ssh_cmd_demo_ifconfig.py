#pip install paramiko
import paramiko

def sshExeCMD():
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy()) 

    try:
        ssh_client.connect(
            hostname="192.168.42.130",
            port=22,username="root",
            password="123456")
        stdin, stdout, stderr = ssh_client.exec_command("ifconfig ens33")
        for line in stdout:
            print('Line: ', line.strip('\n')) 
            print(line.strip('\n'))
    except paramiko.AuthenticationException as auth_error:
        print("Authentication failed:",auth_error)
    except paramiko.SSHException as ssh_error:
        print("SSH connection failed:",ssh_error)
    except Exception as e:
        print("An error occurred:",e)
    finally:
        print("SSH connection closed.")
        ssh_client.close()

if __name__ == '__main__':
    sshExeCMD()
