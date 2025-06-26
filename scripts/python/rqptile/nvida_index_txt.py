import requests
from bs4 import BeautifulSoup

def fetch_web_data(url):
    """发送HTTP请求获取网页内容"""
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.encoding = response.apparent_encoding  # 自动检测编码
        response.raise_for_status()  # 检查HTTP状态码
        return response.text
    except Exception as e:
        print(f"请求失败: {str(e)}")
        return None

def parse_data(html):
    """解析HTML并提取数据"""
    soup = BeautifulSoup(html, 'html.parser')
    
    # 示例选择器：适用于表格类型数据
    data_list = []
    tables = soup.find_all('table')
    
    for table in tables:
        rows = table.find_all('tr')
        for row in rows:
            cols = [col.get_text(strip=True) for col in row.find_all(['th', 'td'])]
            data_list.append(" | ".join(cols))  # 用竖线分隔列
    
    return data_list

def save_to_txt(data, filename):
    """将数据写入txt文件"""
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            f.write("\n".join(data))
        print(f"数据已成功写入 {filename}")
    except Exception as e:
        print(f"写入文件失败: {str(e)}")

if __name__ == "__main__":
    target_url = "https://www.mydrivers.com/zhuanti/tianti/gpu/index_nvidia.html#gf30"
    output_file = "gpu_data.txt"
    
    # 执行爬取流程
    html_content = fetch_web_data(target_url)
    if html_content:
        parsed_data = parse_data(html_content)
        if parsed_data:
            save_to_txt(parsed_data, output_file)
        else:
            print("未找到有效数据")
    else:
        print("网页内容获取失败")