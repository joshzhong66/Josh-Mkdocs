import requests
import json

def search_bing_time(query, subscription_key):
    endpoint = "https://api.bing.microsoft.com/v7.0/search"
    params = {
        'q': query,
        'mkt': 'zh-CN',
        'count': 1
    }
    headers = {'Ocp-Apim-Subscription-Key': subscription_key}

    try:
        response = requests.get(endpoint, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        time_info = data.get('webPages', {}).get('value', [])
        if time_info:
            return time_info[0].get('snippet')
        else:
            print("No time information found")
            return None
    except Exception as e:
        print(f"search_bing_time failed: {e}")
        return None

# 测试函数
query = "现在是几点"
subscription_key = "c8585588f0cd4a63989bcc374018a9be"
time_info = search_bing_time(query, subscription_key)
print(time_info)
