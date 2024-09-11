# python http协议调用



# 代码思路：有报错就加try，之后判断返回值，返回值不对就继续try

# 可以多线程，写个日志，报错多就减少线程数量

# 请使用国内ip，速度快

import requests

url = 'https://gtapi.xiaoerchaoren.com:8932/v1/chat/completions'

headers = {

    'Content-Type': 'application/json',

    'Authorization': 'sk-eK6x5gvjgS5p2ZptDb26856847B8420a8aE72a3791C52956'#输入网站发给你的转发key

}

data = {

    "model": "gpt-3.5-turbo",

    "messages": [{

        "role": "user",

        "content": "你好"

    }],

    "stream": False

}

response = requests.post(url, json=data, headers=headers)

print(response.json())
