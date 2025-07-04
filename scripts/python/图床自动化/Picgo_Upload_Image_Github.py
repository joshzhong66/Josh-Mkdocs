import os
import re
import subprocess
from urllib.parse import urlparse
import shutil

'''
批量处理 Markdown 文件中的图片链接，它通过 PicGo 调用，将本地图片上传至GitHub，并将图片链接替换为Github图床返回新链接。
'''

MD_ROOT = r"E:\Josh-Mkdocs\docs\1_blog\test"                         # 指定 Markdown 文件的根目录
PICGO_CMD = r"C:\Program Files\nodejs\node_global\picgo.cmd"         # 指定 PicGo 的可执行路径
BACKUP_MD = False                                                    # 为 True，则修改 .md 文件前会生成 .bak 备份
image_pattern = r'!\[(.*?)\]\((.*?)\)'                               # 正则匹配 Markdown 图片语法 ![xxx](url)


# 判断一个路径是否是 HTTP/HTTPS 的网络链接
def is_url(path):
    return path.startswith("http://") or path.startswith("https://")


# 调用 PicGo 上传图片
def upload_image(image_path):
    env = os.environ.copy()
    try:
        result = subprocess.run([PICGO_CMD, 'upload', image_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
        output = result.stdout.decode('utf-8', errors='ignore').strip()

        match = re.search(r'(https?://[^\s]+)', output)
        if match:
            return match.group(1)
        else:
            print(f"PicGo 输出无法解析:\n{output}")
    except Exception as e:
        print(f"PicGo 调用失败: {e}")
    return None

# 处理单个 Markdown 文件
def process_md_file(file_path):
    print(f"\n正在处理文件: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    matches = re.findall(image_pattern, content)
    if not matches:
        print("未发现图片链接")
        return

    updated = False

    for alt_text, raw_path in matches:
        raw_path = raw_path.strip()

        # 上传*.md文件的图片到Github，无论图片是任意远程链接还是本地image均上传
        # if is_url(raw_path):
        #     print(f"远程图片: {raw_path}")
        #     new_url = upload_image(raw_path)
        # else:
        #     abs_image_path = os.path.normpath(os.path.join(MD_ROOT, raw_path))
        #     if not os.path.exists(abs_image_path):
        #         print(f"图片不存在: {abs_image_path}")
        #         continue
        #     print(f"上传本地图片: {abs_image_path}")
        #     new_url = upload_image(abs_image_path)


        # 上传*.md文件的图片到远程链接(但跳过Github或者指定图标的CDN)
        SKIP_PREFIXES = [
            "https://raw.githubusercontent.com/joshzhong66/Pibced/",
            "https://raw.githubusercontent.com/zyx3721/Picbed/"
            #"http://pic.joshzhong66.top/",
            #"http://pic.its.sunline.cn/"
        ]
        if is_url(raw_path):
            if any(raw_path.startswith(prefix) for prefix in SKIP_PREFIXES):
                print(f"跳过上传指定图床项目图片: {raw_path}")
                continue
            print(f"远程图片: {raw_path}")
            new_url = upload_image(raw_path)
        else:
            abs_image_path = os.path.normpath(os.path.join(MD_ROOT, raw_path))
            if not os.path.exists(abs_image_path):
                print(f"图片不存在: {abs_image_path}")
                continue
            print(f"上传本地图片: {abs_image_path}")
            new_url = upload_image(abs_image_path)

        if new_url:
            # 替换整个 Markdown 语法块
            pattern = re.escape(f']({raw_path})')
            replacement = f']({new_url})'
            content = re.sub(pattern, replacement, content)
            updated = True
            print(f"链接已替换: {raw_path} → {new_url}")

    if updated:
        if BACKUP_MD:
            shutil.copy(file_path, file_path + ".bak")
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"文件已更新: {file_path}")
    else:
        print("无需修改")

# 遍历 Markdown 文件目录
def walk_dir(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower().endswith(".md"):
                full_path = os.path.join(root, file)
                process_md_file(full_path)

if __name__ == '__main__':
    walk_dir(MD_ROOT)