import os
import requests
import subprocess
import platform



def read_domains(file_path):
    """从文件中读取域列表"""
    with open(file_path, 'r') as file:
        domains = [line.strip() for line in file.readlines() if line.strip()]
    return domains



#ping 简单测试
'''
import os
os.system('ping -c 1 -w 1 10.18.10.254')
'''


# 两种ping的调用方式
'''
def ping_domain(domain):
    if platform.system().lower() == "windows":
        # Windows 的 ping 命令参数
        response = os.system(f"ping -n 3 {domain} > nul")
    else:
        # Linux 的 ping 命令参数
        response = os.system(f"ping -c 3 -w 3 {domain} > /dev/null 2>&1")
    return response == 0

'''


def ping_domain(domain):
    """Ping 一个域名，如果成功则返回 True，否则返回 False。"""
    try:
        if platform.system().lower() == "windows":
            result = subprocess.run(
                ["ping", "-n", "3", domain],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        else:
            result = subprocess.run(
                ["ping", "-c", "3", domain],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        return result.returncode == 0
    except FileNotFoundError:
        print("Ping command not found.")
        return False

def send_webhook_alert(domain):
    """如果 ping 失败，发送 webhook 警报"""
    webhook_url = "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=d575ce0e-6af6-4176-af18-56491df6b2e7"
    payload = {
        "msgtype": "text",
        "text": {
            "content": f"Ping  {domain} 失败!"
        }
    }
    response = requests.post(webhook_url, json=payload)
    if response.status_code == 200:
        print(f"Alert sent for {domain}")
    else:
        print(f"Failed to send alert for {domain}, status code: {response.status_code}")


def main():
    #file_path = '/root/scripts/domain.txt'
    file_path = r'E:\LearningNotes\Bat\Bat脚本\通过域名解析IP并添加到hosts文件\domain.txt'
    if not os.path.exists(file_path):
        print("File not found")
        return 1
    
    domains = read_domains(file_path)
    for domain in domains:
        if not ping_domain(domain):
            print(f"Ping failed for {domain}")
            send_webhook_alert(domain)
        else:
            print(f"Ping successful for {domain}")


if __name__ == "__main__":
    main()
