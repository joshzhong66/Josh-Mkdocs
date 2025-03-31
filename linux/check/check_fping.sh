#!/bin/bash


# 检查 fping 是否已安装，并获取版本号
check_fping_version() {
    local REQUIRED_FPING_VERSION="4.0"  # 需要的最低 fping 版本
    if ! command -v fping &>/dev/null; then
        echo "fping 未安装"
        return 2  # 2 代表未安装
    fi

    INSTALLED_FPING_VERSION=$(fping -v 2>&1 | head -n1 | awk '{print $2}')
    
    if [[ $(echo -e "$INSTALLED_FPING_VERSION\n$REQUIRED_FPING_VERSION" | sort -V | head -n1) == "$REQUIRED_FPING_VERSION" ]]; then
        echo "fping 已安装，版本满足要求：$INSTALLED_FPING_VERSION ,可以继续安装 Zabbix"
        return 0  # 0 代表符合要求
    else
        echo "fping 版本过低，当前版本：$INSTALLED_FPING_VERSION，需升级至 $REQUIRED_FPING_VERSION 或更高"
        return 1  # 1 代表版本过低
    fi
}

check_fping_version