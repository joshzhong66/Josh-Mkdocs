import requests
import json

# Zabbix API 服务器地址
ZABBIX_URL = "http://10.22.51.65/api_jsonrpc.php"
USERNAME = "Admin"
PASSWORD = "zabbix"

# 共享密钥（PSK）相关配置
PSK_IDENTITY = "psk01"                                                          # PSK 识别码
PSK_VALUE = "f03a84aa7cc6ea8c13d9e01f2a704705bad15fd26a535dd8bf322c3b5c38d493"  # PSK 值（必须为32字节十六进制字符串）

# 批量添加主机信息（填写主机名称+IP地址）
HOSTS_TO_ADD = [
    {"hostname": "test51", "ip": "10.22.51.51"}, 
    {"hostname": "test66", "ip": "10.22.51.66"}, 
    {"hostname": "test67", "ip": "10.22.51.67"}, 
    {"hostname": "test68", "ip": "10.22.51.68"}
]

GROUP_NAMES = ["Discovered hosts", "Linux servers"]     # 主机群组
TEMPLATE_NAME = "Linux by Zabbix agent"                 # 监控模板

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

def get_group_ids(auth_token, group_names):
    """获取主机群组的 ID"""
    payload = {
        "jsonrpc": "2.0",
        "method": "hostgroup.get",
        "params": {
            "output": ["groupid"],
            "filter": {"name": group_names}
        },
        "auth": auth_token,
        "id": 2
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()
    return [{"groupid": group["groupid"]} for group in result.get("result", [])]

def get_template_id(auth_token, template_name):
    """获取模板 ID"""
    payload = {
        "jsonrpc": "2.0",
        "method": "template.get",
        "params": {
            "output": ["templateid"],
            "filter": {"host": [template_name]}
        },
        "auth": auth_token,
        "id": 3
    }
    headers = {"Content-Type": "application/json-rpc"}
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    result = response.json()
    templates = result.get("result", [])
    return templates[0]["templateid"] if templates else None

def create_host(auth_token, host_name, ip_address, group_ids, template_id):
    """创建 Zabbix 监控主机"""
    payload = {
        "jsonrpc": "2.0",
        "method": "host.create",
        "params": {
            "host": host_name,
            "interfaces": [{
                "type": 1,      # Agent 接口
                "main": 1,
                "useip": 1,
                "ip": ip_address,
                "dns": "",
                "port": "10050"
            }],
            "groups": group_ids,
            "templates": [{"templateid": template_id}],
            "tls_connect": 2,   # 2 = 仅使用 PSK 连接
            "tls_accept": 2,    # 2 = 仅接受 PSK（取消非加密）
            "tls_psk_identity": PSK_IDENTITY,
            "tls_psk": PSK_VALUE
        },
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

    # 获取主机群组 ID
    group_ids = get_group_ids(auth_token, GROUP_NAMES)
    if not group_ids:
        print(f"❌ 无法找到群组 {GROUP_NAMES}")
        return
    print(f"📌 获取到主机群组 ID: {group_ids}")

    # 获取模板 ID
    template_id = get_template_id(auth_token, TEMPLATE_NAME)
    if not template_id:
        print(f"❌ 无法找到模板 '{TEMPLATE_NAME}'")
        return
    print(f"📌 获取到模板 ID: {template_id}")

    # 遍历主机列表，批量创建主机
    for host in HOSTS_TO_ADD:
        hostname = host["hostname"]
        ip_address = host["ip"]
        
        response = create_host(auth_token, hostname, ip_address, group_ids, template_id)
        
        if "error" in response:
            print(f"❌ 主机 '{hostname}' 创建失败: {response['error']}")
        else:
            print(f"✅ 主机 '{hostname}' 创建成功，ID: {response['result']['hostids'][0]}")

if __name__ == "__main__":
    main()
