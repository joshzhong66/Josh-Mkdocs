import requests
import json

def get_weather(cityNm, alapi_key):
    url = "https://v2.alapi.cn/api/weather"
    payload = {
        "token": alapi_key,
        "city": cityNm
    }

    print(f"请求URL: {url}")
    print(f"请求参数: {payload}")

    try:
        response = requests.post(url, data=payload)
        weather_info = response.json()
        print(f"API 响应: {weather_info}")
        if weather_info['code'] == 200:  # 验证请求是否成功
            return json.dumps(weather_info, ensure_ascii=False, indent=4)
        else:
            print(f"get_weather失败，错误信息：{weather_info}")
            return None
    except Exception as e:
        print(f"get_weather失败，错误信息：{e}")
        return None

# 测试函数
city_name = "深圳"
alapi_key = "nuV2P5VgEpbZIzAD"
weather_info = get_weather(city_name, alapi_key)
print(weather_info)
