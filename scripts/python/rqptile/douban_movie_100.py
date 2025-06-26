import os
import time
import requests
from bs4 import BeautifulSoup

def download_douban_rankings(max_pages=4):
    """
    使用Python爬虫技术下载豆瓣排序前100的电影数据。
    max_pages=4,因为1页只显示25个，所以需要翻4页
    """
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    }
    
    ranking = []
    page_count = 0
    
    while page_count < max_pages:
        try:
            url = f"https://movie.douban.com/top250?start={page_count * 25}"
            
            response = requests.get(url, headers=headers, timeout=5)
            if not response.ok:
                raise Exception("Failed to fetch data.")
                
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # 假设每个电影条目都在一个特定的div中，class_='item'。请根据实际网页结构调整选择器。
            for movie in soup.find_all('div', class_='item'):
                title = movie.find('span', class_='title').get_text()
                rank = int(movie.find('em').get_text())
                ranking.append({"rank": rank, "name": title})
                
        except Exception as e:
            print(f"Page {page_count + 1} failed due to: {str(e)}")
        
        page_count += 1
        time.sleep(1)  # 等待一秒以避免过于频繁的请求

    script_directory = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_directory, "douban_movie_ranking.txt")
    print(f'保存路径: {file_path}')

    with open(file_path, "w", encoding='utf-8') as f:
        for item in ranking:
            f.write(f"{item['rank']:4d} {item['name']}\n")
    
    return ranking

# 调用函数并显示结果
result = download_douban_rankings()
print("Downloaded top movies:\n")
for item in result:
    print(f"{item['rank']:4d} {item['name']}")