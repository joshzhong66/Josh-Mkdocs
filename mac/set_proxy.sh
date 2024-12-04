#!/bin/bash

# 设置网络服务名称（你可以通过 'networksetup -listallnetworkservices' 查看你的网络服务）
NETWORK_SERVICE="Wi-Fi"

# 代理服务器地址和端口
PROXY_SERVER="10.22.51.64"
PROXY_PORT="7890"

# 操作类型：开启代理、关闭代理或配置代理
ACTION=$1

# 函数：开启代理
enable_proxy() {
    echo "开启代理..."
    networksetup -setwebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    networksetup -setsecurewebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    echo "代理已开启"
}

# 函数：关闭代理
disable_proxy() {
    echo "关闭代理..."
    networksetup -setwebproxystate "$NETWORK_SERVICE" off
    networksetup -setsecurewebproxystate "$NETWORK_SERVICE" off
    echo "代理已关闭"
}

# 函数：配置代理
configure_proxy() {
    echo "配置代理..."
    networksetup -setwebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    networksetup -setsecurewebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    echo "代理已配置：$PROXY_SERVER:$PROXY_PORT"
}

# 根据传入的参数执行不同操作
case "$ACTION" in
    enable)
        enable_proxy
        ;;
    disable)
        disable_proxy
        ;;
    configure)
        configure_proxy
        ;;
    *)
        echo "用法：$0 {enable|disable|configure}"
        exit 1
        ;;
esac
