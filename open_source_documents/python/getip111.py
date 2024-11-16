import requests
from bs4 import BeautifulSoup

# 设置用户代理，模拟浏览器
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36'
}

# 获取主页面
response = requests.get("https://ip111.cn", headers=headers)
soup = BeautifulSoup(response.text, 'html.parser')

# 提取国内测试的 IP 信息
domestic_div = soup.find("div", class_="card-header", string="从国内测试")
if domestic_div:
    domestic_ip = domestic_div.find_next("p").get_text(strip=True)
    print("从国内测试:", domestic_ip)
else:
    print("无法找到国内测试的 IP 信息")

# 提取国外测试 iframe 中的 URL 并获取内容
foreign_iframe = soup.find("iframe", src=True, string="从国外测试")
if foreign_iframe:
    foreign_iframe_url = foreign_iframe["src"]
    foreign_response = requests.get(foreign_iframe_url, headers=headers)
    foreign_ip = BeautifulSoup(foreign_response.text, 'html.parser').get_text(strip=True)
    print("从国外测试:", foreign_ip)
else:
    print("无法找到国外测试的 iframe")

# 提取谷歌测试 iframe 中的 URL 并获取内容
google_iframe = soup.find("iframe", src=True, string="从谷歌测试")
if google_iframe:
    google_iframe_url = google_iframe["src"]
    google_response = requests.get(google_iframe_url, headers=headers)
    google_ip = BeautifulSoup(google_response.text, 'html.parser').get_text(strip=True)
    print("从谷歌测试:", google_ip)
else:
    print("无法找到谷歌测试的 iframe")
