#!/bin/bash

# 设置网络服务名称（你可以通过 'networksetup -listallnetworkservices' 查看你的网络服务）
NETWORK_SERVICE="Wi-Fi"
PROXY_SERVER="10.22.51.64"
PROXY_PORT="7890"
ACTION=$1


enable_proxy() {
    networksetup -setwebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    networksetup -setsecurewebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    echo "Proxy Enable"
}

disable_proxy() {
    networksetup -setwebproxystate "$NETWORK_SERVICE" off
    networksetup -setsecurewebproxystate "$NETWORK_SERVICE" off
    echo "Proxy Disable"
}

configure_proxy() {
    networksetup -setwebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    networksetup -setsecurewebproxy "$NETWORK_SERVICE" "$PROXY_SERVER" "$PROXY_PORT"
    echo "Proxy Configured：$PROXY_SERVER:$PROXY_PORT"
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
