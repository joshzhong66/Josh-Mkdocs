#!/bin/bash

docker_dir="/usr/local/src"

function echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}

function echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}


function echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}


function echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}

function list_images() {
    echo_log_info "可用的 Docker 镜像："
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}" | tail -n +2 | nl
}

function export_image() {
    read -p "请输入要导出的镜像编号: " image_number
    image_name=$(docker images --format "{{.Repository}}:{{.Tag}}" | sed -n "${image_number}p")

    [ -z "$image_name" ] && echo_log_error "无效的编号，请重新运行脚本。" && return

    sanitized_image_name=$(echo "$image_name" | tr '/' '_' | tr ':' '_')	#镜像名的/和:替换成下划线

    [ ! -w "$docker_dir" ] && echo_log_error "当前目录不可写，请检查权限或切换目录。"

    if [ -f "${docker_dir}/${sanitized_image_name}.tar.gz" ]; then
        while [[ "$answer" != "y" && "$answer" != "n" ]]; do
            echo_log_warn "文件已存在，是否重新导出？(y/n)"
            read -r answer
        done
        [[ $answer == "n" ]] && return || rm -f ${docker_dir}/${sanitized_image_name}.tar.gz
    fi
	
    echo_log_info "导出镜像: $image_name"
    docker save "$image_name" | gzip > "${docker_dir}/${sanitized_image_name}.tar.gz"
    [ $? -ne 0 ] && echo_log_error "镜像导出失败！"
    echo_log_info "镜像已导出为 ${sanitized_image_name}.tar.gz"
}

list_images
export_image
