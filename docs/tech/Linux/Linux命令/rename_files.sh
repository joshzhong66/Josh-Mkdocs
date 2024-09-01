#!/bin/bash

# 遍历当前目录下的所有 Markdown 文件
for file in *.md; do
  # 使用正则表达式提取文件名中的编号和标题
  if [[ $file =~ ^《每天一个Linux命令》\ --\ \(([0-9]+)\)\ (.*)\.md$ ]]; then
    # 提取文件名中的编号
    number="${BASH_REMATCH[1]}"
    
    # 提取文件名中的标题
    title="${BASH_REMATCH[2]}"
    
    # 生成新文件名
    new_name="${number}.${title}.md"
    
    # 重命名文件
    mv "$file" "$new_name"
    
    echo "Renamed '$file' to '$new_name'"
  else
    echo "Skipped '$file' (already renamed or no match)"
  fi
done

