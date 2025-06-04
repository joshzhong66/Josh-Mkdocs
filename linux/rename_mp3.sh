#!/bin/bash

echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}
echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}
echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}


target_dir="/tmp/硅谷来信2谷歌方法论"
output_dir="/tmp/mp3"
zip_file="/tmp/硅谷来信2谷歌方法论.zip"

if ! command -v unzip &>/dev/null; then
    yum -y install unzip
    echo_log_info "已安装 unzip"
fi

if [ ! -d "$target_dir" ]; then
    if [ -f "$zip_file" ]; then
        echo_log_warn "目录不存在，尝试解压 $zip_file"
        unrar x "$zip_file" /tmp/ || echo_log_error "解压失败"
    else
        echo_log_error "目录和压缩包都不存在！"
    fi
fi

# 创建输出目录
mkdir -p "$output_dir" || echo_log_error "无法创建输出目录：$output_dir"

# 建立 jpg -> 新名字 的映射
declare -A rename_map

# 遍历 jpg 文件，建立重命名映射
find "$target_dir" -type f -name "*.jpg" | while read -r jpg_path; do
    jpg_file=$(basename "$jpg_path")
    prefix="${jpg_file:0:6}"
    new_name="${jpg_file%.*}.mp3"
    rename_map["$prefix"]="$new_name"
done

# 遍历所有 mp3 文件
find "$target_dir" -type f -name "*.mp3" | while read -r mp3_path; do
    mp3_file=$(basename "$mp3_path")
    dir_path=$(dirname "$mp3_path")
    prefix="${mp3_file:0:6}"

    # 判断是否有对应重命名规则
    if [[ -n "${rename_map[$prefix]}" && "${rename_map[$prefix]}" != "$mp3_file" ]]; then
        new_mp3="${rename_map[$prefix]}"
        echo_log_info "重命名: $mp3_file -> $new_mp3"
    else
        new_mp3="$mp3_file"
        echo_log_info "保持原名: $mp3_file"
    fi

    # 若文件重名则追加随机后缀防冲突
    if [ -f "$output_dir/$new_mp3" ]; then
        base="${new_mp3%.*}"
        ext="${new_mp3##*.}"
        rand=$(date +%s%N | md5sum | head -c 6)
        new_mp3="${base}_$rand.$ext"
        echo_log_warn "目标文件已存在，自动改名为 $new_mp3"
    fi

    # 移动文件
    mv "$mp3_path" "$output_dir/$new_mp3" && \
        echo_log_info "已移动: $new_mp3 -> $output_dir" || \
        echo_log_warn "移动失败: $mp3_file"
done

echo_log_info "所有 mp3 文件已处理完成，已统一放入：$output_dir"
