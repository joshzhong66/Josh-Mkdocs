#!/bin/bash

# 需要的最低 Go 版本
REQUIRED_GO_VERSION="1.16"

# 获取已安装的 Go 版本
check_go_version() {
    if ! command -v go &>/dev/null; then
        echo "Go 未安装"
        return 2  # 2 代表未安装
    fi

    INSTALLED_GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    if [[ $(echo -e "$INSTALLED_GO_VERSION\n$REQUIRED_GO_VERSION" | sort -V | head -n1) == "$REQUIRED_GO_VERSION" ]]; then
        echo "Go 已安装，版本满足要求：$INSTALLED_GO_VERSION"
        return 0  # 0 代表符合要求
    else
        echo "Go 版本过低，当前版本：$INSTALLED_GO_VERSION，需升级至 $REQUIRED_GO_VERSION 或更高"
        return 1  # 1 代表版本过低
    fi
}

# 执行检查
check_go_version
