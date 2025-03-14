import requests
import json

# Zabbix 服务器 API 信息
ZABBIX_URL = "http://10.22.51.65/api_jsonrpc.php"                                   # API_URL
USERNAME = "Admin"                                                                  # 管理员              
PASSWORD = "zabbix"                                                                 # 管理员密码
PSK_IDENTITY = "psk01"                                                              # 共享密钥 PSK 识别码
PSK_VALUE = "f03a84aa7cc6ea8c13d9e01f2a704705bad15fd26a535dd8bf322c3b5c38d493"      # PSK 值

def zabbix_login():
    """登录 Zabbix 获取认证令牌"""
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

def get_all_hosts(auth_token):
    """获取所有主机的 ID 和名称"""
    payload = {
        "jsonrpc": "2.0",
        "method": "host.get",
        "params": {
            "output": ["hostid", "host"]  # 只获取 hostid 和主机名
        },
        "auth": auth_token,
        "id": 2
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()
    return result.get("result", [])

def update_host_encryption(auth_token, host_id, host_name):
    """批量配置主机的加密设置"""
    payload = {
        "jsonrpc": "2.0",
        "method": "host.update",
        "params": {
            "hostid": host_id,
            "tls_connect": 2,   # 2 = 仅使用 PSK 连接
            "tls_accept": 2,    # 2 = 仅接受 PSK（取消非加密）
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
    if not auth_token:
        print("❌ Zabbix 登录失败")
        return

    print("✅ 认证成功")
    
    # 获取所有主机信息
    hosts = get_all_hosts(auth_token)
    
    if not hosts:
        print("❌ 没有找到任何主机")
        return

    print(f"🔍 找到 {len(hosts)} 台主机，开始批量更新加密设置...")

    # 遍历所有主机，批量更新加密配置
    for host in hosts:
        host_id = host["hostid"]
        host_name = host["host"]
        response = update_host_encryption(auth_token, host_id, host_name)
        
        if "error" in response:
            print(f"⚠️ 主机 {host_name} (ID: {host_id}) 更新失败: {response['error']}")
        else:
            print(f"✅ 主机 {host_name} (ID: {host_id}) 加密设置已更新")

if __name__ == "__main__":
    main()
