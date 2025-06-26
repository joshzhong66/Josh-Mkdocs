import os
import requests

def download_bilibili_doc_rankings(max_pages=5): # 假设每页有20部纪录片，总共抓取前100部
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    }

    ranking = []
    base_url = "https://api.bilibili.com/pgc/season/index/result"

    params = {
        'type': 1,
        'order': 4,      # 按综合排序
        'style_id': -1,  # 不限制类型
        'producer_id': -1,
        'release_date': -1,
        'season_status': -1,
        'sort': 0,       # 排序方式
        'page': 1,
        'season_type': 3, # 纪录片
        'pagesize': 20,
    }

    for page in range(1, max_pages + 1):
        params['page'] = page
        
        try:
            response = requests.get(base_url, headers=headers, params=params)
            if not response.ok:
                raise Exception("Failed to fetch data.")

            data = response.json().get('data', {})
            for idx, doc in enumerate(data.get('list', [])):
                title = doc.get('title', 'No Title')
                rank = (page - 1) * params['pagesize'] + idx + 1
                ranking.append({"rank": rank, "name": title})

        except Exception as e:
            print(f"Page {page} failed due to: {str(e)}")
            break

    script_directory = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_directory, "bilibili_doc_ranking.txt")
    print(f'保存路径: {file_path}')

    with open(file_path, "w", encoding='utf-8') as f:
        for item in ranking:
            f.write(f"{item['rank']:4d} {item['name']}\n")

    return ranking

result = download_bilibili_doc_rankings()
print("Downloaded top documentaries:\n")
for item in result:
    print(f"{item['rank']:4d} {item['name']}")