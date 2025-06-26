import requests
import pandas as pd
from bs4 import BeautifulSoup

def fetch_web_data(url):
    """获取网页 HTML"""
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.encoding = response.apparent_encoding  # 自动检测编码
        response.raise_for_status()  # 确保请求成功
        return response.text
    except Exception as e:
        print(f"请求失败: {str(e)}")
        return None

def parse_table_to_markdown(html):
    """解析网页表格并转换为 Markdown"""
    soup = BeautifulSoup(html, 'html.parser')
    
    # 直接用 pandas 读取 HTML 中的所有表格
    tables = pd.read_html(str(soup))

    markdown_tables = []
    
    for df in tables:
        md_table = df.to_markdown(index=False)  # 转换为 Markdown 表格格式
        markdown_tables.append(md_table)

    return "\n\n".join(markdown_tables)

def save_to_md(data, filename):
    """保存 Markdown 表格到文件"""
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(data)
        print(f"数据已成功写入 {filename}")
    except Exception as e:
        print(f"写入文件失败: {str(e)}")

if __name__ == "__main__":
    target_url = "https://www.mydrivers.com/zhuanti/tianti/gpu/index_nvidia.html#gf30"
    output_file = "gpu_data.md"

    html_content = fetch_web_data(target_url)
    if html_content:
        markdown_data = parse_table_to_markdown(html_content)
        if markdown_data:
            save_to_md(markdown_data, output_file)
        else:
            print("未找到有效表格数据")
    else:
        print("网页内容获取失败")
