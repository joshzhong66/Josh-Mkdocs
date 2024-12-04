#!/bin/bash

# 设置网络服务名称（你可以通过 'networksetup -listallnetworkservices' 查看你的网络服务）
NETWORK_SERVICE="Wi-Fi"
PROXY_SERVER="10.22.51.64"
PROXY_PORT="7890"
ACTION=$1


enable_proxy() {
    echo "开启代理..."
    networksetup -setwebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    networksetup -setsecurewebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    echo "代理已开启"
}

disable_proxy() {
    echo "关闭代理..."
    networksetup -setwebproxystate "$NETWORK_SERVICE" off
    networksetup -setsecurewebproxystate "$NETWORK_SERVICE" off
    echo "代理已关闭"
}

configure_proxy() {
    echo "配置代理..."
    networksetup -setwebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    networksetup -setsecurewebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    echo "代理已配置：$PROXY_SERVER:$PROXY_PORT"
}

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
