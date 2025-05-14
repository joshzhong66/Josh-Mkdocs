#!/bin/bash



FRP_VERSION="0.61.1"
PACKAGE_NAME="frp"
REPO="stilleshan/frps"
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH="/usr/local/frp"



if [ $(uname -m) = "x86_64" ]; then
    PLATFORM=amd64
fi

if [ $(uname -m) = "aarch64" ]; then
    PLATFORM=arm64
fi

FILE_NAME=frp_${FRP_VERSION}_linux_${PLATFORM}
INTERNAL_URL="http://10.22.51.64/5_Linux/${FILE_NAME}.tar.gz"
EXTERNAL_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}.tar.gz"

echo $EXTERNAL_URL

echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}
echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}
echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}

quit() {
    echo_log_info "Exit Script!"
}



check_url() {
    local url=$1
    if curl -f -s --connect-timeout 5 "$url" &>/dev/null; then
        return 0
    else
        return 1
    fi
}



download_package() {
    local PACKAGE_NAME=$1
    local DOWNLOAD_PATH=$2
    shift 2 

    # 尝试从内网下载
    if check_url "$INTERNAL_URL"; then
        echo_log_info "从内网下载$PACKAGE_NAME..."
        if wget -P "$DOWNLOAD_PATH" "$INTERNAL_URL" &>/dev/null; then
            echo_log_info "下载$PACKAGE_NAME成功"
            return 0
        else
            echo_log_error "从内网下载失败"
        fi
    else
        echo_log_warn "内网地址不可访问，尝试外网地址..."
    fi

    # 尝试从外网下载
    if check_url "$EXTERNAL_URL"; then
        echo_log_info "从外网下载$PACKAGE_NAME..."
        if wget -P "$DOWNLOAD_PATH" "$EXTERNAL_URL" &>/dev/null; then
            echo_log_info "下载$PACKAGE_NAME成功"
            return 0
        else
            echo_log_error "从外网下载失败"
        fi
    else
        echo_log_error "外网地址也不可用，下载失败！"
        return 1
    fi
}


download_package
