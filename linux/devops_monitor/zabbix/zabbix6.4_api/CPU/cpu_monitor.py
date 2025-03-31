import requests
import json

# Zabbix API 服务器信息
ZABBIX_URL = "http://10.22.51.65/api_jsonrpc.php"
USERNAME = "Admin"
PASSWORD = "zabbix"

# 需要监控的主机列表
HOSTS_TO_MONITOR = [
    {"hostname": "test51"}, 
    {"hostname": "test66"}, 
    {"hostname": "test67"}, 
    {"hostname": "test68"},
    {"hostname": "Zabbix Server"}
]

TRIGGER_EXPRESSION = "last(/$HOSTNAME/system.cpu.load[percpu,avg1])>90"


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

def create_cpu_trigger(auth_token, host_id, host_name):
    """为主机创建 CPU 使用率超过 90% 的告警触发器"""
    expression = TRIGGER_EXPRESSION.replace("$HOSTNAME", host_name)
    payload = {
        "jsonrpc": "2.0",
        "method": "trigger.create",
        "params": [{
            "description": f"CPU 使用率过高 ({host_name})",
            "expression": expression,
            "priority": 4  # 高优先级
        }],
        "auth": auth_token,
        "id": 4
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
    
    for host in HOSTS_TO_MONITOR:
        host_id = get_host_id(auth_token, host["hostname"])
        if host_id:
            print(f"⚡ 为主机 '{host['hostname']}' 创建 CPU 监控触发器...")
            trigger_response = create_cpu_trigger(auth_token, host_id, host["hostname"])
            if "error" in trigger_response:
                print(f"❌ 创建失败: {trigger_response['error']}")
            else:
                print(f"✅ 主机 '{host['hostname']}' 触发器创建成功")
        else:
            print(f"ℹ️ 未找到主机 '{host['hostname']}'，跳过")

if __name__ == "__main__":
    main()
