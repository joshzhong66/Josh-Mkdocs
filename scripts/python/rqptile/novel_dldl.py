import requests
from lxml import etree
from urllib.parse import urljoin  # 导入urljoin

# 初始URL
url = 'https://www.51shucheng.net/wangluo/douluodalu/21750.html'

while True:
    #用户代理头
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'
    }

    # 发送GET请求
    resp = requests.get(url, headers=headers)

    # 设置编码
    resp.encoding = 'utf-8'

    # 解析HTML响应
    e = etree.HTML(resp.text)
    info = ' '.join(e.xpath('//div/p//text()'))
    title = e.xpath('//h1/text()')[0]

    # 打印和保存章节内容
    print(title)
    with open('斗罗大陆1.pdf', 'a', encoding='utf-8') as f:
        f.write(title + '\n\n' + info + '\n\n')

    # 使用urljoin查找下一章的URL
    next_chapter_url = e.xpath('//*[@id="BookNext"]/@href')
    if not next_chapter_url:
        print("没有更多章节可用。")
        break

    # 使用urljoin更新下一个URL，以确保正确构建URL
    url = urljoin(url, next_chapter_url[0])

print("已经抓取并保存了所有章节到斗罗大陆.txt文件中。")