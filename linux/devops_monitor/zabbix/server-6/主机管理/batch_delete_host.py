import requests
import json

# Zabbix API 服务器信息
ZABBIX_URL = "http://10.22.51.65/api_jsonrpc.php"
USERNAME = "Admin"
PASSWORD = "zabbix"

# 需要删除的主机列表
HOSTS_TO_DELETE = [
    {"hostname": "test51", "ip": "10.22.51.51"}, 
    {"hostname": "test66", "ip": "10.22.51.66"}, 
    {"hostname": "test67", "ip": "10.22.51.67"}, 
    {"hostname": "test68", "ip": "10.22.51.68"},
    {"hostname": "Zabbix Server", "ip": "127.0.0.1"}
]

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

def get_host_id(auth_token, host_name):
    """获取主机 ID"""
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

def delete_hosts(auth_token, host_ids):
    """批量删除指定主机"""
    if not host_ids:
        return {"error": "没有找到要删除的主机"}
    
    payload = {
        "jsonrpc": "2.0",
        "method": "host.delete",
        "params": host_ids,
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

    # 收集所有要删除的主机 ID
    host_ids = []
    for host in HOSTS_TO_DELETE:
        host_id = get_host_id(auth_token, host["hostname"])
        if host_id:
            print(f"🛑 发现主机 '{host['hostname']}'，准备删除...")
            host_ids.append(host_id)
        else:
            print(f"ℹ️ 未找到主机 '{host['hostname']}'，跳过删除")
    
    # 批量删除主机
    if host_ids:
        delete_response = delete_hosts(auth_token, host_ids)
        if "error" in delete_response:
            print(f"❌ 删除失败: {delete_response['error']}")
            return
        print("✅ 所有指定主机删除成功")
    else:
        print("ℹ️ 无需删除主机")

if __name__ == "__main__":
    main()
