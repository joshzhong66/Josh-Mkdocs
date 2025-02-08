import os
import requests
from bs4 import BeautifulSoup
import time

def fetch_and_save(url_generator, headers, parser_function, filename, max_items=100):
    items = []
    page = 0
    while len(items) < max_items:
        url = url_generator(page)
        try:
            response = requests.get(url, headers=headers, timeout=5)
            if not response.ok:
                raise Exception("Failed to fetch data.")
                
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # 判断是否需要传递start_rank参数
            if parser_function.__name__ == 'parse_movies':
                parsed_items = parser_function(soup)
            else:
                parsed_items = parser_function(soup, start_rank=len(items)+1)
            
            needed_count = max_items - len(items)
            items.extend(parsed_items[:needed_count])
            
            if len(parsed_items) < (25 if parser_function.__name__ == 'parse_movies' else 15):  # 假设每页至少有25或15项，如果不足则说明没有更多数据
                break
                
        except Exception as e:
            print(f"Fetching {filename} failed at page {page + 1} due to: {str(e)}")
            break
        
        page += 1
        time.sleep(1)  # 等待一秒以避免过于频繁的请求
    
    with open(filename, "w", encoding='utf-8') as f:
        for item in items:
            f.write(f"{item['rank']:4d} {item['name']}\n")
    
    print(f"Successfully saved first {len(items)} items to {filename}")

def parse_movies(soup):
    movies = []
    for movie in soup.find_all('div', class_='item'):
        title = movie.find('span', class_='title').get_text()
        rank = int(movie.find('em').get_text())
        movies.append({"rank": rank, "name": title})
    return movies

def parse_books(soup, start_rank=1):
    books = []
    for idx, book in enumerate(soup.find_all('tr', {'class': ['item', '']}, limit=25)):  # 只获取当前页面前25本书
        title_tag = book.find('a', title=True)
        if title_tag:
            title = title_tag.get('title')
            rank = start_rank + idx  # 计算正确的排名
            books.append({"rank": rank, "name": title})
    return books

def parse_tv(soup, start_rank=1):
    tv_shows = []
    search_results = soup.find_all('div', class_='result-list')[0].find_all('div', class_='content')
    for idx, show in enumerate(search_results):
        title = show.h3.a.get_text()  # 获取电视剧标题
        rank = start_rank + idx  # 计算排名
        tv_shows.append({"rank": rank, "name": title})
    return tv_shows

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
}

current_directory = os.getcwd()

# 抓取并保存电影排名
fetch_and_save(
    url_generator=lambda p: f"https://movie.douban.com/top250?start={p * 25}",
    headers=headers,
    parser_function=parse_movies,
    filename=os.path.join(current_directory, "douban_movie_ranking.txt"),
    max_items=100
)

# 抓取并保存书籍排名
fetch_and_save(
    url_generator=lambda p: f"https://book.douban.com/top250?start={p * 25}",
    headers=headers,
    parser_function=parse_books,
    filename=os.path.join(current_directory, "douban_book_ranking.txt"),
    max_items=100
)

# 抓取并保存电视剧排名（包含中国大陆和外国）
fetch_and_save(
    url_generator=lambda p: f"https://www.douban.com/search?cat=1002&q=电视剧&start={p * 15}",
    headers=headers,
    parser_function=parse_tv,
    filename=os.path.join(current_directory, "douban_tv_ranking.txt"),
    max_items=100
)

print("All data fetching and saving tasks completed successfully.")