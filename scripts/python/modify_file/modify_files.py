import os
import glob
import re

def replace_line(line):
    if re.match(r'\d+、', line.strip()):
        return '### ' + line
    return line

desktop_path = os.path.join(os.path.expanduser('~'), 'Desktop')

for md_file in glob.glob(os.path.join(desktop_path, '*.md')):
    with open(md_file, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    modified_lines = [replace_line(line) for line in lines]

    with open(md_file, 'w', encoding='utf-8') as file:
        file.writelines(modified_lines)

print("所有 .md 文件已更新。")
