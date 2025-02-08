import os
import requests
from bs4 import BeautifulSoup

def download_douban_doc_rankings(max_pages=10):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    }
    
    base_url = "https://www.douban.com/doulist/49285703/?start={}"
    ranking = []
    page = 0  # 分页参数，每页 25 条
    rank = 1  # 记录全局排名

    while page < max_pages:
        url = base_url.format(page * 25)  # 生成不同分页 URL
        print(f"Fetching: {url}")  # 显示当前正在爬取的页面
        
        try:
            response = requests.get(url, headers=headers, timeout=5)
            if not response.ok:
                raise Exception("Failed to fetch data.")
                
            soup = BeautifulSoup(response.text, 'html.parser')
            items = soup.select('.doulist-item')
            
            # 如果本页没有内容，说明到达最后一页，停止爬取
            if not items:
                print("No more pages to fetch.")
                break
            
            for doc in items:
                title_tag = doc.select_one('.title a')
                title = title_tag.text.strip() if title_tag else 'No Title'
                
                ranking.append({"rank": rank, "name": title})
                rank += 1  # 递增排名
                
        except Exception as e:
            print(f"Page {page + 1} failed due to: {str(e)}")
        
        page += 1  # 增加分页
     
    # 获取脚本所在目录并保存文件
    script_directory = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_directory, "douban_doc_ranking.txt")
    print(f'保存路径: {file_path}')
    
    with open(file_path, "w", encoding='utf-8') as f:
        for item in ranking:
            f.write(f"{item['rank']:4d} {item['name']}\n")
    
    return ranking

# 运行代码
result = download_douban_doc_rankings(max_pages=10)  # 爬取最多 10 页
print("Downloaded top documentaries:\n")
for item in result:
    print(f"{item['rank']:4d} {item['name']}")
