import re

output = """
314psecOS# aaaa user user search key-word description show-type page key-value 31
0
aaaa user user add name 31314 account-type local passwd-type cipher passwd 7577a
da17cb8a7c3de70c1adcee3847eb58c86b68f92e7daa1d0d0eb89f2968f99c6caee9fa1f1e505909
8cc9a04a59daba7a8cfacb509f815a1f7d8fc17b9b2 mail zhongjinlin31314@sunline.cn pho
ne null sv-ip 172.21.8.13 vip-user no appoint-user no sdp-parse-second no hwid-l
ist null invalid no description 钟锦林31314 group Manager^root inherit-role yes
inherit-attr yes cert_serialnumber null cert_idnumber null company null get_secr
et no associated_roles null pri-start-time null pri-end-time null h3cimcpasswd n
ull deleteflag null
"""

# 正则表达式用于捕获 "description" 到 "group" 字段之间的内容
description_pattern = re.compile(r'description\s+.*?([\u4e00-\u9fa5\w]+)(?=\sgroup)', re.DOTALL | re.IGNORECASE)

description_match = description_pattern.search(output)
if description_match:
    description = ' '.join(description_match.group(1).strip().split())  # 清理多余空格并格式化
    print(f'Description: {description}')
else:
    print('Description not found')
