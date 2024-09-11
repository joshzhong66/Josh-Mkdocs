#pip install itchat


import itchat
from itchat.content import TEXT
import requests

# Google Custom Search API 配置
GOOGLE_API_KEY = 'YOUR_GOOGLE_API_KEY'
GOOGLE_CSE_ID = 'YOUR_GOOGLE_CSE_ID'

# Bing Search API 配置
BING_SUBSCRIPTION_KEY = ''

def google_search(query):
    url = f"https://www.googleapis.com/customsearch/v1"
    params = {
        'q': query,
        'key': GOOGLE_API_KEY,
        'cx': GOOGLE_CSE_ID
    }
    response = requests.get(url, params=params)
    results = response.json()
    return results.get('items', [])

def bing_search(query):
    url = "https://api.bing.microsoft.com/v7.0/search"
    headers = {
        'Ocp-Apim-Subscription-Key': BING_SUBSCRIPTION_KEY,
    }
    params = {
        'q': query,
        'textDecorations': True,
        'textFormat': 'HTML'
    }
    response = requests.get(url, headers=headers, params=params)
    results = response.json()
    return results.get('webPages', {}).get('value', [])

@itchat.msg_register(TEXT)
def text_reply(msg):
    query = msg.text
    if query.startswith("Google:"):
        search_query = query[len("Google:"):].strip()
        results = google_search(search_query)
        if results:
            reply = "\n".join([f"{result['title']}: {result['link']}" for result in results[:5]])
        else:
            reply = "未找到相关的搜索结果。"
    elif query.startswith("Bing:"):
        search_query = query[len("Bing:"):].strip()
        results = bing_search(search_query)
        if results:
            reply = "\n".join([f"{result['name']}: {result['url']}" for result in results[:5]])
        else:
            reply = "未找到相关的搜索结果。"
    else:
        reply = "请输入 'Google: 查询词' 或 'Bing: 查询词' 进行搜索。"
    
    itchat.send(reply, toUserName=msg.fromUserName)

if __name__ == "__main__":
    itchat.auto_login(hotReload=True)
    itchat.run()
