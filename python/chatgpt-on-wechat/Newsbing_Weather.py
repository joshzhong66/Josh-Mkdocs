import requests
import json

def search_bing_weather(query, subscription_key):
    endpoint = "https://api.bing.microsoft.com/v7.0/search"
    params = {
        'q': query,
        'mkt': 'zh-CN',
        'count': 10
    }
    headers = {'Ocp-Apim-Subscription-Key': subscription_key}

    try:
        response = requests.get(endpoint, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        weather_info = data.get('webPages', {}).get('value', [])
        if weather_info:
            return weather_info[0].get('snippet')
        else:
            print("No weather information found")
            return None
    except Exception as e:
        print(f"search_bing_weather failed: {e}")
        return None

# 测试函数
query = "今天深圳天气怎么样"
subscription_key = "c8585588f0cd4a63989bcc374018a9be"
weather_info = search_bing_weather(query, subscription_key)
print(weather_info)
