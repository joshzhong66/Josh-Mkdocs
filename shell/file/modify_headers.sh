#!/bin/bash


for file in *.md; do
    if [[ $file =~ ^([0-9]+)\.(.*)\.md$ ]]; then
        number="${BASH_REMATCH[1]}"
        title="${BASH_REMATCH[2]}"

        new_header="# ${number}. ${title}"

        tmp_file=$(mktemp)

        echo "$new_header" > "$tmp_file"
        tail -n +2 "$file" >> "$tmp_file"
        
        mv "$tmp_file" "$file"
        echo "Updated '$file' with new header '$new_header'"
    else
        echo "Skipped '$file' (no match for the pattern)"
    fi
done

