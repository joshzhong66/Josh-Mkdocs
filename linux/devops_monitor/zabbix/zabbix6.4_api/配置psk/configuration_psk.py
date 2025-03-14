import requests
import json

# Zabbix 服务器 API 地址
ZABBIX_URL = "http://10.22.51.65/api_jsonrpc.php"
USERNAME = "Admin"
PASSWORD = "zabbix"

# 共享密钥（PSK）相关配置
PSK_IDENTITY = "psk01"                                                          # 配置的 PSK 识别码
PSK_VALUE = "f03a84aa7cc6ea8c13d9e01f2a704705bad15fd26a535dd8bf322c3b5c38d493"  # 配置的 PSK 值（32字节十六进制）

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
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()
    return result.get("result")

def get_host_id(auth_token, host_name):
    """
    获取指定主机的 ID
    """
    payload = {
        "jsonrpc": "2.0",
        "method": "host.get",
        "params": {
            "output": ["hostid"],
            "filter": {"host": [host_name]}
        },
        "auth": auth_token,
        "id": 2
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()
    hosts = result.get("result", [])
    return hosts[0]["hostid"] if hosts else None

def update_host_encryption(auth_token, host_id):
    """
    配置主机的加密设置：
    - 连接主机：PSK
    - 从主机连接：PSK
    - 关闭非加密
    - 设置 PSK 识别码 & PSK 值
    """
    payload = {
        "jsonrpc": "2.0",
        "method": "host.update",
        "params": {
            "hostid": host_id,
            "tls_connect": 2,   # 2 = PSK
            "tls_accept": 2,    # 2 = 仅接受 PSK 连接（不勾选非加密）
            "tls_psk_identity": PSK_IDENTITY,
            "tls_psk": PSK_VALUE
        },
        "auth": auth_token,
        "id": 3
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    return response.json()

def main():
    auth_token = zabbix_login()
    if auth_token:
        print("✅ 认证成功")
        host_id = get_host_id(auth_token, "Zabbix server")
        if host_id:
            print(f"🔍 找到主机 ID: {host_id}")
            update_response = update_host_encryption(auth_token, host_id)
            print("🔐 配置加密结果:", update_response)
        else:
            print("❌ 主机 'Zabbix server' 未找到")

if __name__ == "__main__":
    main()
