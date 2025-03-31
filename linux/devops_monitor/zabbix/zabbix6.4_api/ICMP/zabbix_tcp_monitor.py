import requests
import json

# Zabbix API 服务器信息
ZABBIX_URL = "http://10.22.51.65/api_jsonrpc.php"
USERNAME = "Admin"
PASSWORD = "zabbix"

# 监控主机信息
HOST_NAME = "Zabbix Server"         # 目标主机
TARGET_IP = "10.10.200.254"         # 需要监控的 IP 地址
ITEM_NAME = f"Ping-{TARGET_IP}"     # 监控项名称
TRIGGER_NAME = f"总部→上海网络心跳"  # 触发器名称
SEVERITY = 3                        # 告警等级：Average


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


def verify_host_name(auth_token):
    """获取所有主机名称，检查 'Zabbix Server' 是否存在"""
    payload = {
        "jsonrpc": "2.0",
        "method": "host.get",
        "params": {
            "output": ["hostid", "host", "name"]
        },
        "auth": auth_token,
        "id": 6
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()

    print(f"🔍 获取的所有主机信息: {json.dumps(result, indent=2, ensure_ascii=False)}")
    return [host["name"] for host in result.get("result", [])]


def get_existing_item(auth_token, host_id):
    """检查主机是否已有相同 key_ 的监控项"""
    payload = {
        "jsonrpc": "2.0",
        "method": "item.get",
        "params": {
            "output": ["itemid", "name", "key_"],
            "hostids": host_id,
            "search": {"key_": f"icmppingsec[{TARGET_IP},4,10000,32,10000]"}
        },
        "auth": auth_token,
        "id": 5
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()

    print(f"🔍 item.get API 响应: {json.dumps(result, indent=2, ensure_ascii=False)}")
    return result.get("result", [])


def create_tcp_ping_item(auth_token, host_id):
    """创建 TCP 监控项 (icmppingsec)"""
    payload = {
        "jsonrpc": "2.0",
        "method": "item.create",
        "params": {
            "name": ITEM_NAME,
            "key_": f"icmppingsec[{TARGET_IP},4,10000,32,10000]",
            "hostid": host_id,
            "type": 3,  # Simple check
            "value_type": 0,  # Float (响应时间)
            "delay": "30s",
            "history": "7d",
            "trends": "30d"
        },
        "auth": auth_token,
        "id": 3
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()

    print(f"🔍 item.create API 响应: {json.dumps(result, indent=2, ensure_ascii=False)}")

    return result.get("result", {}).get("itemids", [None])[0]


def create_trigger(auth_token, host_name, item_key):
    """创建告警触发器"""
    expression = f"{{{host_name}:{item_key}.last()}}=0"

    payload = {
        "jsonrpc": "2.0",
        "method": "trigger.create",
        "params": {
            "description": TRIGGER_NAME,
            "expression": expression,
            "priority": SEVERITY,
            "status": 0,
            "type": 0
        },
        "auth": auth_token,
        "id": 4
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)

    print(f"🔍 trigger.create API 响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
    return response.json()


def main():
    auth_token = zabbix_login()
    if not auth_token:
        print("❌ Zabbix 登录失败")
        return

    print("✅ 认证成功")

    all_host_names = verify_host_name(auth_token)
    print(f"✅ Zabbix 服务器上的主机名称列表: {all_host_names}")

    host_id = get_host_id(auth_token, HOST_NAME)
    if not host_id:
        print(f"❌ 主机 '{HOST_NAME}' 未找到")
        return

    print(f"🔍 获取到主机 ID: {host_id}")

    existing_items = get_existing_item(auth_token, host_id)
    if existing_items:
        item_id = existing_items[0]["itemid"]
        item_key = existing_items[0]["key_"]  # 赋值 item_key
        print(f"✅ 监控项已存在，复用 ID: {item_id}, key_: {item_key}")
    else:
        item_id = create_tcp_ping_item(auth_token, host_id)
        if not item_id:
            print("❌ 创建 TCP 监控项失败")
            return
        print(f"✅ 监控项创建成功，ID: {item_id}")

        # **添加 `item_key` 赋值**
        item_key = f"icmppingsec[{TARGET_IP},4,10000,32,10000]"
        print(f"✅ 新创建监控项 key_: {item_key}")

    # 确保 item_key 已赋值后再调用 create_trigger
    trigger_response = create_trigger(auth_token, HOST_NAME, item_key)



if __name__ == "__main__":
    main()
