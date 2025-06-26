#!/bin/bash

# 获取动态校验码
get_checksum() {
    local version="$1"
    version=${version#v}  # 去除可能存在的v前缀

    # 获取系统信息并转换格式
    local os arch
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)
    case "$arch" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *)       echo "不支持的架构: $arch"; return 1 ;;
    esac

    # 构造文件名
    local filename="node_exporter-${version}.${os}-${arch}.tar.gz"

    # 下载校验文件
    local url="https://github.com/prometheus/node_exporter/releases/download/v${version}/sha256sums.txt"
    if ! curl -fsSL -o /tmp/sha256sums.txt "$url"; then
        echo "无法下载校验文件: $url"
        return 1
    fi

    # 提取校验码
    local checksum
    if ! checksum=$(grep -F "$filename" /tmp/sha256sums.txt | awk '{print $1}'); then
        echo "未找到 ${filename} 的校验码"
        rm -f /tmp/sha256sums.txt
        return 1
    fi

    # 清理并输出结果
    rm -f /tmp/sha256sums.txt
    echo "$checksum"
}

# 使用示例
version="1.8.1"  # 支持带v或不带v的版本号
if checksum=$(get_checksum "$version"); then
    echo "版本 ${version} 的校验码: $checksum"
else
    echo "获取校验码失败"
    exit 1
fi