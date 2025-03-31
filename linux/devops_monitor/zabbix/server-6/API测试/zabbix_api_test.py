import requests

ZABBIX_URL = "http://10.22.51.65/api_jsonrpc.php"
USERNAME = "Admin"
PASSWORD = "zabbix"

def zabbix_login():
    auth_payload = {
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

    response = requests.post(ZABBIX_URL, json=auth_payload, headers=headers)
    result = response.json()

    if "result" in result:
        print(f"✅ 认证成功, 获取的 auth token: {result['result']}")
        return result["result"]
    else:
        print(f"❌ 认证失败: {result}")
        return None

# 运行测试
auth_token = zabbix_login()



