import requests
import json

# Zabbix API 服务器信息
ZABBIX_URL = "http://10.22.51.65/api_jsonrpc.php"
USERNAME = "Admin"
PASSWORD = "zabbix"

# 监控项参数
HOST_NAME = "Zabbix Server"        # 监控的主机
TARGET_IP = "10.10.200.254"       # 目标 IP
ITEM_NAME = f"Ping-{TARGET_IP}-上海隧道网关"
ITEM_KEY = f"icmppingsec[{TARGET_IP},4,1000,32,10000,avg]"
TRIGGER_NAME = "IPSEC VPN总部->上海测试"
GRAPH_NAME = "IPSEC VPN总部->上海测试"
DASHBOARD_NAME = "IPSEC VPN总部->上海测试"
SEVERITY = 3  # 告警等级: Average

# 认证登录
def zabbix_login():
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
    return response.json().get("result")

# 获取主机 ID
def get_host_id(auth_token, host_name):
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

# 获取已有监控项
def get_existing_item(auth_token, host_id, key_):
    payload = {
        "jsonrpc": "2.0",
        "method": "item.get",
        "params": {
            "output": ["itemid"],
            "hostids": host_id,
            "search": {"key_": key_}
        },
        "auth": auth_token,
        "id": 3
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()
    return result.get("result", [])

# 创建监控项
def create_item(auth_token, host_id):
    payload = {
        "jsonrpc": "2.0",
        "method": "item.create",
        "params": {
            "name": ITEM_NAME,
            "key_": ITEM_KEY,
            "hostid": host_id,
            "type": 3,  # Simple check
            "value_type": 0,  # Float (响应时间)
            "delay": "30s",
            "history": "7d",
            "trends": "30d"
        },
        "auth": auth_token,
        "id": 4
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    return response.json().get("result", {}).get("itemids", [None])[0]

# 创建触发器
def create_trigger(auth_token, host_name, item_key):
    expression = f"avg(/{host_name}/{item_key},1m)=0"
    payload = {
        "jsonrpc": "2.0",
        "method": "trigger.create",
        "params": {
            "description": TRIGGER_NAME,
            "expression": expression,
            "priority": SEVERITY
        },
        "auth": auth_token,
        "id": 5
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    return response.json()

# 创建图形
def create_graph(auth_token, host_id, item_id):
    payload = {
        "jsonrpc": "2.0",
        "method": "graph.create",
        "params": {
            "name": GRAPH_NAME,
            "width": 900,
            "height": 200,
            "gitems": [
                {
                    "itemid": item_id,
                    "color": "00AA00"  # 绿色
                }
            ]
        },
        "auth": auth_token,
        "id": 6
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    return response.json()

# 创建仪表盘
def create_dashboard(auth_token, dashboard_name, graph_name):
    payload = {
        "jsonrpc": "2.0",
        "method": "dashboard.create",
        "params": {
            "name": dashboard_name,
            "widgets": [
                {
                    "type": "graph",
                    "name": "总部电信出口",
                    "fields": [
                        {"type": "graph", "name": graph_name}
                    ]
                }
            ]
        },
        "auth": auth_token,
        "id": 7
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    return response.json()

# 主函数
def main():
    auth_token = zabbix_login()
    if not auth_token:
        print("❌ Zabbix 登录失败")
        return

    print("✅ 认证成功")

    host_id = get_host_id(auth_token, HOST_NAME)
    if not host_id:
        print(f"❌ 主机 '{HOST_NAME}' 未找到")
        return

    print(f"🔍 获取到主机 ID: {host_id}")

    existing_items = get_existing_item(auth_token, host_id, ITEM_KEY)
    if existing_items:
        item_id = existing_items[0]["itemid"]
        print(f"✅ 监控项已存在，复用 ID: {item_id}")
    else:
        item_id = create_item(auth_token, host_id)
        if not item_id:
            print("❌ 创建监控项失败")
            return
        print(f"✅ 监控项创建成功，ID: {item_id}")

    trigger_response = create_trigger(auth_token, HOST_NAME, ITEM_KEY)
    print(f"🔍 触发器创建结果: {json.dumps(trigger_response, indent=2, ensure_ascii=False)}")

    graph_response = create_graph(auth_token, host_id, item_id)
    print(f"🔍 图形创建结果: {json.dumps(graph_response, indent=2, ensure_ascii=False)}")

    dashboard_response = create_dashboard(auth_token, DASHBOARD_NAME, GRAPH_NAME)
    print(f"🔍 仪表盘创建结果: {json.dumps(dashboard_response, indent=2, ensure_ascii=False)}")

if __name__ == "__main__":
    main()
