import requests
import json

# Zabbix API 服务器信息
ZABBIX_URL = "http://10.22.51.65/api_jsonrpc.php"
USERNAME = "Admin"
PASSWORD = "zabbix"

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

def get_hostgroup_id(auth_token, group_name):
    """获取指定主机群组 ID"""
    payload = {
        "jsonrpc": "2.0",
        "method": "hostgroup.get",
        "params": {
            "output": ["groupid", "name"],  # 获取群组 ID 和名称
            "filter": {"name": [group_name]}  # 过滤指定名称的群组
        },
        "auth": auth_token,
        "id": 2
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()
    groups = result.get("result", [])
    
    return groups[0]["groupid"] if groups else None

def get_all_hostgroups(auth_token):
    """获取所有主机群组"""
    payload = {
        "jsonrpc": "2.0",
        "method": "hostgroup.get",
        "params": {
            "output": ["groupid", "name"]  # 仅返回群组 ID 和名称
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
    
    # 获取所有主机群组
    groups_response = get_all_hostgroups(auth_token)
    groups = groups_response.get("result", [])
    
    if not groups:
        print("⚠️ 没有找到任何主机群组")
    else:
        print("📋 获取到的主机群组列表：")
        for group in groups:
            print(f"🔹 名称: {group['name']}, ID: {group['groupid']}")

    # 获取特定主机群组 ID
    group_name = "Discovered hosts"  # 你要查询的群组名称
    group_id = get_hostgroup_id(auth_token, group_name)
    
    if group_id:
        print(f"✅ 群组 '{group_name}' 的 ID: {group_id}")
    else:
        print(f"❌ 未找到群组 '{group_name}'")

if __name__ == "__main__":
    main()
