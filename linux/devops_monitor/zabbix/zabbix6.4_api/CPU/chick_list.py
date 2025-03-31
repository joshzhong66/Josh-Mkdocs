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

def get_hosts_in_group(auth_token, group_id):
    """获取指定群组下的主机"""
    payload = {
        "jsonrpc": "2.0",
        "method": "host.get",
        "params": {
            "output": ["hostid", "host"],
            "groupids": group_id
        },
        "auth": auth_token,
        "id": 3
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    return response.json()

def get_item_id(auth_token, host_id, item_key):
    """获取主机的监控项 ID"""
    payload = {
        "jsonrpc": "2.0",
        "method": "item.get",
        "params": {
            "output": ["itemid"],
            "hostids": host_id,
            "search": {"key_": item_key}
        },
        "auth": auth_token,
        "id": 4
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()
    return result["result"][0]["itemid"] if result.get("result") else None

def get_latest_data(auth_token, item_id):
    """获取监控项最新数据"""
    payload = {
        "jsonrpc": "2.0",
        "method": "history.get",
        "params": {
            "output": "extend",
            "history": 0,
            "itemids": item_id,
            "sortfield": "clock",
            "sortorder": "DESC",
            "limit": 1
        },
        "auth": auth_token,
        "id": 5
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()
    return result["result"][0]["value"] if result.get("result") else "N/A"

def main():
    auth_token = zabbix_login()
    if not auth_token:
        print("❌ Zabbix 登录失败")
        return
    
    print("✅ 认证成功")
    group_id = "2"  # 服务器群组 ID
    hosts_response = get_hosts_in_group(auth_token, group_id)
    hosts = hosts_response.get("result", [])
    
    if not hosts:
        print("⚠️ 该群组下没有找到主机")
        return
    
    for host in hosts:
        host_id = host["hostid"]
        host_name = host["host"]
        host_ip = host["interfaces"][0]["ip"]
        
        cpu_item_id = get_item_id(auth_token, host_id, "system.cpu.util")
        mem_item_id = get_item_id(auth_token, host_id, "vm.memory.utilization")
        
        if not cpu_item_id or not mem_item_id:
            print(f"⚠️ 无法找到主机 {host_name} 的 CPU 或内存监控项")
            continue
        
        cpu_usage = get_latest_data(auth_token, cpu_item_id)
        mem_usage = get_latest_data(auth_token, mem_item_id)
        
        print(f"\nServer Name(服务器): {host_name},服务器ip: {host_ip}")
        print("CPU utilization 24h(利用率):")
        print(f"- Max(最大): {cpu_usage}%")
        print(f"- Min(最小): {cpu_usage}%")
        print(f"- AVG(平均): {cpu_usage}%")
        print(f"- Current(当前): {cpu_usage}%")
        print("\nMemory utilization 24h(内存利用率):")
        print(f"- Max(最大): {mem_usage}%")
        print(f"- Min(最小): {mem_usage}%")
        print(f"- AVG(平均): {mem_usage}%")
        print(f"- Current(当前): {mem_usage}%")

if __name__ == "__main__":
    main()