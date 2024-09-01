# 2.update_headers.sh

```
#!/bin/bash

# 遍历当前目录下的所有 Markdown 文件
for file in *.md; do
  # 从文件名中提取编号和标题
  if [[ $file =~ ^([0-9]+)\.(.*)\.md$ ]]; then
    number="${BASH_REMATCH[1]}"
    title="${BASH_REMATCH[2]}"
    
    # 生成新的第一行内容
    new_header="# ${number}. ${title}"
    
    # 创建一个临时文件
    tmp_file=$(mktemp)
    
    # 将新的第一行写入临时文件
    echo "$new_header" > "$tmp_file"
    
    # 跳过原文件的第一行，并将剩余内容追加到临时文件中
    tail -n +2 "$file" >> "$tmp_file"
    
    # 将临时文件覆盖原文件
    mv "$tmp_file" "$file"
    
    echo "Updated '$file' with new header '$new_header'"
  else
    echo "Skipped '$file' (no match for the pattern)"
  fi
done


```

