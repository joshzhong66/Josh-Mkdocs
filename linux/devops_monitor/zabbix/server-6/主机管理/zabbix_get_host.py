import requests
import json

# Zabbix 服务器的 URL 和登录凭证
ZABBIX_URL = 'http://10.22.51.65/api_jsonrpc.php'
USERNAME = 'Admin'
PASSWORD = 'zabbix'

def zabbix_login():
    """
    登录 Zabbix，获取认证令牌
    """
    payload = {
        "jsonrpc": "2.0",
        "method": "user.login",
        "params": {
            "username": USERNAME,
            "password": PASSWORD
        },
        "id": 1
    }
    headers = {
        "Content-Type": "application/json-rpc"
    }
    response = requests.post(ZABBIX_URL, data=json.dumps(payload), headers=headers)
    result = response.json()
    if 'result' in result:
        return result['result']
    else:
        print(f"认证失败: {result}")
        return None

def get_hosts(auth_token):
    """
    获取所有主机信息
    """
    payload = {
        "jsonrpc": "2.0",
        "method": "host.get",
        "params": {
            "output": ["hostid", "host"]
        },
        "auth": auth_token,
        "id": 2
    }
    headers = {
        "Content-Type": "application/json-rpc"
    }
    response = requests.post(ZABBIX_URL, data=json.dumps(payload), headers=headers)
    result = response.json()
    if 'result' in result:
        return result['result']
    else:
        print(f"获取主机失败: {result}")
        return None

def main():
    auth_token = zabbix_login()
    if auth_token:
        hosts = get_hosts(auth_token)
        if hosts:
            for host in hosts:
                print(f"Host ID: {host['hostid']}, Host Name: {host['host']}")

if __name__ == "__main__":
    main()
