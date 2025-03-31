#!/bin/bash
# https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.4.tar.gz.sha256

# 手动
# curl -fsSL -o zabbix_checksum.txt "https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.4.tar.gz.sha256"
# cat zabbix_checksum.txt


PACKAGE_NAME="zabbix"
DEFAULT_VERSION="6.0.4"

# 获取CHECKSUM_MAP值
get_expected_checksum() {
    local version=$1
    echo "Checking version: $version"

    local filename="${PACKAGE_NAME}-${version}.tar.gz"
    local checksum_url="https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-${version}.tar.gz.sha256"

    if ! tmpfile=$(mktemp); then
        echo "无法创建临时文件"
        return 2
    fi

    for i in {1..3}; do
        if curl -fsSL -o "$tmpfile" "$checksum_url"; then
            break
        elif [ $i -eq 3 ]; then
            echo "校验文件下载失败: $checksum_url"
            rm -f "$tmpfile"
            return 3
        fi
        sleep 2
    done

    local checksum
    checksum=$(awk '{print $1}' "$tmpfile")  # 直接获取校验值

    if [[ -z "$checksum" ]]; then
        echo "未找到 ${filename} 的校验码"
        rm -f "$tmpfile"
        return 4
    fi

    rm -f "$tmpfile"
    echo "SHA256校验值: $checksum"
}


get_expected_checksum "$DEFAULT_VERSION"