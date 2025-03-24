import pandas as pd
import requests

# Zabbix API 服务器信息
ZABBIX_URL = "http://10.22.51.65/api_jsonrpc.php"
USERNAME = "Admin"
PASSWORD = "zabbix"

# 登录 Zabbix 获取 API 认证令牌
def zabbix_login():
    auth_payload = {
        "jsonrpc": "2.0",
        "method": "user.login",
        "params": {
            "username": USERNAME,
            "password": PASSWORD
        },
        "id": 1
    }
    response = requests.post(ZABBIX_URL, json=auth_payload)
    result = response.json()
    
    if "result" in result:
        return result["result"]
    else:
        print(f"认证失败: {result}")
        return None

# 创建用户
def create_user(auth_token, name, login, password, user_groups, role_id):
    user_payload = {
        "jsonrpc": "2.0",
        "method": "user.create",
        "params": {
            "username": login,  # 修改 alias 为 username
            "name": name,
            "passwd": password,
            "usrgrps": user_groups,  # 确保这里是 [{"usrgrpid": xxx}]
            "roleid": role_id
        },
        "auth": auth_token,
        "id": 1
    }
    response = requests.post(ZABBIX_URL, json=user_payload)
    return response.json()




# 创建用户组
def create_user_group(auth_token, group_name):
    group_payload = {
        "jsonrpc": "2.0",
        "method": "usergroup.create",
        "params": {
            "name": group_name
        },
        "auth": auth_token,
        "id": 1
    }
    response = requests.post(ZABBIX_URL, json=group_payload)
    result = response.json()
    
    if "result" in result and "usrgrpids" in result["result"]:
        return result["result"]["usrgrpids"][0]  # 确保返回用户组 ID
    else:
        print(f"创建用户组失败: {result}")
        return None


# 获取用户组 ID
def get_user_group_id(group_name, auth_token):
    group_payload = {
        "jsonrpc": "2.0",
        "method": "usergroup.get",
        "params": {
            "output": ["usrgrpid"],
            "filter": {
                "name": group_name
            }
        },
        "auth": auth_token,
        "id": 1
    }
    response = requests.post(ZABBIX_URL, json=group_payload)
    result = response.json()

    if "result" in result and result["result"]:
        return result["result"][0]["usrgrpid"]  # 确保返回 ID
    else:
        print(f"用户组 {group_name} 未找到")
        return None



# 读取 Excel 文件中的用户信息
def read_users_from_excel(file_path):
    df = pd.read_excel(file_path)
    users = []
    
    for _, row in df.iterrows():
        try:
            role_id = None
            if row["普通用户权限"] == 1 and pd.isnull(row["管理员权限"]):
                role_id = 4
            elif pd.isnull(row["普通用户权限"]) or row["管理员权限"] == 1:
                role_id = 3

            users.append({
                "department": str(row["部门"]).strip(),
                "user_id": str(row["工号"]).strip(),
                "name": str(row["姓名"]).strip(),
                "role_id": role_id
            })
        except Exception as e:
            print(f"解析 Excel 数据失败: {e}")
    
    return users

# 退出 Zabbix API
def zabbix_logout(auth_token):
    logout_payload = {
        "jsonrpc": "2.0",
        "method": "user.logout",
        "params": [],
        "auth": auth_token,
        "id": 1
    }
    response = requests.post(ZABBIX_URL, json=logout_payload)
    return response.json()

# 主函数
def main():
    auth_token = zabbix_login()
    if not auth_token:
        print("认证失败，退出程序")
        return

    users = read_users_from_excel(r"E:\Josh-Mkdocs\linux\devops_monitor\zabbix\zabbix6.4_api\创建用户\user.xlsx")

    for user in users:
        group_id = get_user_group_id(user["department"], auth_token)

        # 如果用户组不存在，创建新用户组
        if not group_id:
            group_id = create_user_group(auth_token, user["department"])
            if group_id:
                print(f"用户组 '{user['department']}' 创建成功，ID: {group_id}")
            else:
                print(f"创建用户组 '{user['department']}' 失败")
                continue

        user_groups = [{"usrgrpid": group_id}]  # 这里传递正确的 group_id
        role_id = user["role_id"]

        if role_id is not None:
            result = create_user(auth_token, user["name"], user["user_id"], "Zxcvbnm111", user_groups, role_id)
            print(f"创建用户 {user['name']} 的结果: {result}")
        else:
            print(f"用户 {user['name']} 的权限信息不完整，跳过创建")

    zabbix_logout(auth_token)

if __name__ == "__main__":
    main()