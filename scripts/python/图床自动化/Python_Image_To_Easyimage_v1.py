import os
import re
import shutil
import requests

'''
配置EasyImage API密钥和上传地址,将所有md文件中的图片链接替换为EasyImage的图片链接
'''

MD_ROOT = r"E:\Josh-Mkdocs\docs\1_blog\test"
BACKUP_MD = False
BACKUP_DIR = r"E:\Josh-Mkdocs\docs\back"
EASYIMAGE_URL = "https://pic.joshzhong.top/api/index.php"
EASYIMAGE_TOKEN = "1c17b11693cb5ec63859b091c5b9c1b2"


SKIP_PREFIXES = [
    #"https://raw.githubusercontent.com/joshzhong66/Pibced/",
    #"https://raw.githubusercontent.com/zyx3721/Picbed/",
    "http://pic.joshzhong66.top/",
    #"http://pic.its.sunline.cn/"
]

markdown_pattern = r'!\[(.*?)\]\((.*?)\)'
html_img_pattern = r'<img\s+[^>]*src="([^"]+)"[^>]*>'
image_pattern = re.compile(f"{markdown_pattern}|{html_img_pattern}")

def is_url(path):
    return path.startswith("http://") or path.startswith("https://")

def is_easyimage_url(url):
    return "pic.joshzhong.top" in url

def should_skip_url(url):
    return any(url.startswith(prefix) for prefix in SKIP_PREFIXES)

def upload_to_easyimage(image_path):
    try:
        with open(image_path, 'rb') as img:
            files = {'image': img}
            data = {'token': EASYIMAGE_TOKEN}
            response = requests.post(EASYIMAGE_URL, files=files, data=data)
            json_data = response.json()
            if "url" in json_data:
                return json_data["url"]
            else:
                print(f"上传失败: {json_data}")
    except Exception as e:
        print(f"请求错误: {e}")
    return None

def process_md_file(file_path):
    print(f"\n正在处理: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    matches = image_pattern.findall(content)
    if not matches:
        print("未发现图片链接，跳过")
        return

    updated = False

    for match in matches:
        raw_path = match[1] if match[1] else match[2]
        if not raw_path:
            continue
        raw_path = raw_path.strip()

        if is_easyimage_url(raw_path) or should_skip_url(raw_path):
            print(f"跳过指定链接: {raw_path}")
            continue

        if is_url(raw_path):
            print(f"远程图片: {raw_path}")
            try:
                img_data = requests.get(raw_path).content
                temp_path = os.path.join(os.path.dirname(file_path), "temp_upload.jpg")
                with open(temp_path, 'wb') as temp:
                    temp.write(img_data)
                new_url = upload_to_easyimage(temp_path)
                os.remove(temp_path)
            except Exception as e:
                print(f"下载远程图片失败: {e}")
                continue
        else:
            abs_image_path = os.path.normpath(os.path.join(MD_ROOT, raw_path))
            if not os.path.exists(abs_image_path):
                print(f"图片不存在: {abs_image_path}")
                continue
            print(f"上传本地图片: {abs_image_path}")
            new_url = upload_to_easyimage(abs_image_path)

        if new_url:
            escaped = re.escape(raw_path)
            content = re.sub(f'(?<=\\]\\(){escaped}(?=\\))', new_url, content)  # Markdown
            content = re.sub(f'(?<=src="){escaped}(?=")', new_url, content)    # HTML
            print(f"替换成功: {raw_path} → {new_url}")
            updated = True
        else:
            print(f"上传失败: {raw_path}")

    if updated:
        if BACKUP_MD:
            relative_path = os.path.relpath(file_path, MD_ROOT)
            backup_path = os.path.join(BACKUP_DIR, relative_path + ".bak")
            os.makedirs(os.path.dirname(backup_path), exist_ok=True)
            shutil.copy(file_path, backup_path)
            print(f"已备份至: {backup_path}")

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"文件已更新: {file_path}")
    else:
        print("无需更新")

def walk_md_files(root):
    for dirpath, _, filenames in os.walk(root):
        for file in filenames:
            if file.lower().endswith(".md"):
                process_md_file(os.path.join(dirpath, file))

if __name__ == "__main__":
    walk_md_files(MD_ROOT)
