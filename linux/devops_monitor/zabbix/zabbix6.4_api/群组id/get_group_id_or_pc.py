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

def get_all_hostgroups(auth_token):
    """获取所有主机群组"""
    payload = {
        "jsonrpc": "2.0",
        "method": "hostgroup.get",
        "params": {
            "output": ["groupid", "name"]
        },
        "auth": auth_token,
        "id": 2
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    return response.json()

def get_host_count_in_group(auth_token, group_id):
    """获取指定群组下的主机数量"""
    payload = {
        "jsonrpc": "2.0",
        "method": "host.get",
        "params": {
            "groupids": group_id,
            "countOutput": True  # 仅返回主机数量
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
            group_id = group["groupid"]
            group_name = group["name"]
            host_count_response = get_host_count_in_group(auth_token, group_id)
            host_count = host_count_response.get("result", 0)
            print(f"🔹 名称: {group_name}, ID: {group_id}, 主机数量：{host_count}")

if __name__ == "__main__":
    main()