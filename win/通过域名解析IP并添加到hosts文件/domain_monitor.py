import os
import requests
import subprocess
import platform


def read_domains(file_path):
    # 从文件中读取域名列表
    with open(file_path, 'r') as file:
        # 去除每行的前后空白字符，且只保留非空行
        domains = [line.strip() for line in file.readlines() if line.strip()]
    return domains


# 两种ping的调用方式
'''
def ping_domain(domain):
    # 判断当前操作系统
    if platform.system().lower() == "windows":
        # Windows 的 ping 命令参数
        response = os.system(f"ping -n 3 {domain} > nul")
    else:
        # Linux 的 ping 命令参数
        response = os.system(f"ping -c 3 -w 3 {domain} > /dev/null 2>&1")
    return response == 0
'''


def ping_domain(domain):
    # Ping 一个域名，如果成功则返回 True，否则返回 False。
    try:
        if platform.system().lower() == "windows":
            result = subprocess.run(
                ["ping", "-n", "3", domain],   # Windows ping 命令
                stdout=subprocess.DEVNULL,          # 丢弃标准输出
                stderr=subprocess.DEVNULL           # 丢弃标准错误
            )
        else:
            result = subprocess.run(
                ["ping", "-c", "3", domain],   # Linux ping 命令
                stdout=subprocess.DEVNULL,          # 丢弃标准输出
                stderr=subprocess.DEVNULL           # 丢弃标准错误
            )
        return result.returncode == 0     # 如果返回码是 0，表示 ping 成功
    except FileNotFoundError:
        # 捕获 FileNotFoundError，表示系统找不到 ping 命令
        print("Ping command not found.")
        return False


def send_webhook_alert(domain):
    # 如果 ping 失败，发送 webhook 警报
    webhook_url = "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=d575ce0e-6af6-4176-af18-56491df6b2e7"
    payload = {
        "msgtype": "markdown",
        "markdown": {
            "content": f"> <font color=warning>Ping域名[{domain}]失败！</font>"
        }
    }
    response = requests.post(webhook_url, json=payload)
    if not response.status_code == 200:
        print(f"为域名[{domain}]发送告警失败，错误码：{response.status_code}")


def main():
    # file_path = r'E:\LearningNotes\Bat\Bat脚本\通过域名解析IP并添加到hosts文件\domain.txt'
    file_path = '/data/scripts/domain.txt'
    if not os.path.exists(file_path):
        print("未找到域名列表文件！")
        return 1
    
    domains = read_domains(file_path)
    for domain in domains:
        if not ping_domain(domain):
            print(f"Ping域名[{domain}]失败！")
            send_webhook_alert(domain)
        else:
            print(f"Ping域名[{domain}]成功！")


if __name__ == "__main__":
    main()
