#!/bin/bash

<< 'COMMENT'
comment：
1）移除/tmp目录下所有关于"001-002_test.sh"的"001-002_"前缀
COMMENT


TARGET_DIR="/tmp/"
REMOVE_STR="001-002_"

find "$TARGET_DIR" -type f | while read -r file; do
    #
    new_file=$(echo "$file" | sed "s|$REMOVE_STR||g")

    if [[ "$file" != "$new_file" ]]; then
        echo "Processing: $file"
        mv "$file" "$new_file"
        echo "Renamed: $file -> $new_file"
    fi
done