import requests
import json


url = "http://10.22.51.64:8127/v1/chat/completions"

# Authorization Token
token = "8OZJC+ow2IRpK9JIgTGZ5ygANfgzBnefL3mx0VIYJqqQtvGeQQszqTHXBRwXrCfB"


headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {token}"
}

data = {
    "model": "deepseek",
    "messages": [
        {
            "role": "user",
            "content": "你是deepseek v3模型吗？"
        }
    ],
    "stream": False
}

response = requests.post(url, headers=headers, data=json.dumps(data))


if response.status_code == 200:
    print("响应成功:")
    print(response.json())  # 打印返回的 JSON 数据
else:
    print(f"请求失败，状态码: {response.status_code}")
    print(response.text)  # 打印错误信息