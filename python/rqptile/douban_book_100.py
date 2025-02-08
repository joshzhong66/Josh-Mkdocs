import os
import time
import requests
from bs4 import BeautifulSoup


def download_douban_book_rankings(max_pages=4):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    }
    
    ranking = []
    page_count = 0
    
    while page_count < max_pages:
        try:
            url = f"https://book.douban.com/top250?start={page_count * 25}"
            
            response = requests.get(url, headers=headers, timeout=5)
            if not response.ok:
                raise Exception("Failed to fetch data.")
                
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # 查找每本书的信息
            for idx, book in enumerate(soup.find_all('div', class_='pl2')):
                title = book.find('a').get('title')  # 获取书籍标题
                rank = page_count * 25 + idx + 1  # 计算排名
                
                ranking.append({"rank": rank, "name": title})
                
        except Exception as e:
            print(f"Page {page_count + 1} failed due to: {str(e)}")
        
        page_count += 1
        time.sleep(1)  # 等待一秒以避免过于频繁的请求

    script_directory = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_directory, "douban_book_ranking.txt")
    print(f'保存路径: {file_path}')
        
    with open(file_path, "w", encoding='utf-8') as f:
        for item in ranking:
            f.write(f"{item['rank']:4d} {item['name']}\n")
    
    return ranking

# 调用函数并显示结果
result = download_douban_book_rankings()
print("Downloaded top books:\n")
for item in result:
    print(f"{item['rank']:4d} {item['name']}")