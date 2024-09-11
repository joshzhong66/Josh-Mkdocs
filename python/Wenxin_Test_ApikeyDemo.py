import requests
import json

API_KEY = "QOYbOixs7dLFe9mA2A5qKGF4"
SECRET_KEY = "RXL3tbaCyQTfoNZDQizQiZVOq8v1AsQX"


def main():
    url = "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions_pro?access_token=" + get_access_token()

    payload = json.dumps({
        "messages": [
            {
                "role": "user",
                "content": "你好,你是文心大模型几？"
            }
        ]
    })
    headers = {
        'Content-Type': 'application/json'
    }
    response = requests.request("POST", url, headers=headers, data=payload)
    print(json.dumps(json.loads(response.text), indent=4, ensure_ascii=False))


def get_access_token():
    url = "https://aip.baidubce.com/oauth/2.0/token"
    params = {"grant_type": "client_credentials", "client_id": API_KEY, "client_secret": SECRET_KEY}
    return str(requests.post(url, params=params).json().get("access_token"))


if __name__ == '__main__':
    main()

