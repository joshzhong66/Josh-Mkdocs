#!/usr/bin/python3

# 导入必要的库
import time
import requests
from requests.auth import HTTPBasicAuth

# 登录时先进行身份认证的账号密码
auth_username = "sunline"
auth_password = "sunline"

# 登录域名和SSL证书监控系统的账号密码
admin_username = "admin"
admin_password = "dream13889"

# 系统的登录URL和域名列表URL
login_url = 'https://domain.jerion.cn/api/login'
domain_list_url = 'https://domain.jerion.cn/api/getDomainList'
cert_info_url = 'https://domain.jerion.cn/api/getCertInformation'

# 创建认证对象
auth = HTTPBasicAuth(auth_username, auth_password)

# 准备登录请求的负载
login_payload = {
    "username": admin_username,
    "password": admin_password
}

# 发送登录请求并处理响应
login_response = requests.post(login_url, json=login_payload, auth=auth)
if login_response.status_code == 200:
    login_data = login_response.json()
    token = login_data.get('data', {}).get('token')
    if token:
        print("登录成功，获取到 Token")

	# 设置请求头和准备获取域名列表的请求体
        headers = {
            "Content-Type": "application/json",
            "X-TOKEN": token
        }
        domain_list_payload = {
            "page": 1,
            "size": 10  # 可调整获取更多域名
        }

        # 发送获取域名列表的请求并处理响应
        domain_response = requests.post(domain_list_url, headers=headers, json=domain_list_payload, auth=auth)
        if domain_response.status_code == 200:
            domain_data = domain_response.json()
            domain_list = domain_data.get('data', {}).get('list', [])
            if domain_list:
                file_path = '/tmp/certificates.txt'
                with open(file_path, 'w') as file:
                    for domain_info in domain_list:
                        domain = domain_info.get('domain')
                        print(f"获取域名: {domain}")
                        time.sleep(1)
                        
                        # 循环处理每个域名，获取其证书信息并写入文件
                        cert_payload = {
                            "domain": domain
                        }
                        cert_response = requests.post(cert_info_url, headers=headers, json=cert_payload, auth=auth)
                        
                        if cert_response.status_code == 200:
                            data = cert_response.json()
                            print(f"证书响应: {data}")
                            time.sleep(1)

                            if data.get('code') == 0:
                                cert_info = data.get('data', {})
                                parsed_cert = cert_info.get('parsed_cert', {})
                                domain_name = cert_info.get('resolve_domain')
                                issuer = parsed_cert.get('issuer', {})
                                start_date = parsed_cert.get('notBefore')
                                expire_date = parsed_cert.get('notAfter')
                                subject = parsed_cert.get('subject', {})

                                try:
                                    file.write(f"Domain: {domain_name}\n")
                                    file.write(f"Issuer: {issuer}\n")
                                    file.write(f"Start Date: {start_date}\n")
                                    file.write(f"Expire Date: {expire_date}\n")
                                    file.write(f"Subject: {subject}\n")
                                    file.write("\n")
                                    print(f"写入文件: Domain: {domain_name}, Issuer: {issuer}, Start Date: {start_date}, Expire Date: {expire_date}, Subject: {subject}")
                                except Exception as e:
                                    print(f"写入文件失败: {e}")
                            else:
                                print(f"获取 {domain} 的证书信息失败。返回消息: {data.get('msg')}")
                        else:
                            print(f"获取 {domain} 的证书信息失败。状态码: {cert_response.status_code}, 响应: {cert_response.text}")
                        print()
                        time.sleep(2)
            else:
                print("未找到任何域名。")
        else:
            print(f"获取域名列表失败。状态码: {domain_response.status_code}, 响应: {domain_response.text}")
    else:
        print("登录失败，未能获取到 Token")
else:
    print(f"登录失败。状态码: {login_response.status_code}, 响应: {login_response.text}")

print("获取证书信息执行结束！")
