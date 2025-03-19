#!/bin/bash

DEFAULT_VERSION="6.0.4"
PACKAGE_NAME="zabbix"
VER_URL=https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.4.tar.gz

check_version_exists() {
    local version=$1
    echo_log_info "正在验证版本 v${version} 是否存在..."
    
    # 检查GitHub Release标签
    if ! curl -sSLI -o /dev/null -w "%{http_code}" $VER_URL | grep -q 200; then
        echo_log_error "版本 v${version} 不存在于官方仓库"
        return 2
    fi
    echo_log_info "版本 v${version} 存在于官方仓库"
}

check_version_exists $DEFAULT_VERSION