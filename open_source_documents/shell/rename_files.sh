#!/bin/bash


#脚本说明:移除/tmp目录下所有关于"001-002_test.sh'的001-002_

# 设置目标文件夹
target_dir="/tmp/"

# 设置需要移除的字符串
remove_str="001-002_"

# 遍历目标文件夹及其所有子文件夹下的所有文件
find "$target_dir" -type f | while read -r file; do
    echo "Processing: $file"  # 打印当前处理的文件名

    # 使用 sed 命令删除文件名中的指定部分
    new_file=$(echo "$file" | sed "s/$remove_str//g")

    # 如果新旧文件名不同，则重命名文件
    if [[ "$file" != "$new_file" ]]; then
        mv "$file" "$new_file"
        echo "Renamed: $file -> $new_file"
    else
        echo "No change needed for: $file"
    fi
done

