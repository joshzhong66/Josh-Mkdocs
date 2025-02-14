#!/bin/bash

#./proxy_manage.sh enable    # 启用代理
#./proxy_manage.sh disable   # 禁用代理

set_proxy() {
    ipzz="^([0-9]\.|[1-9][0-9]\.|1[0-9][0-9]\.|2[0-4][0-9]\.|25[0-5]\.){3}([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$"
    while :; do
        local proxy_ip=$(read -rp "请输入代理 IP 地址: " && echo $REPLY)
        if [ -z $proxy_ip ]; then
            echo "IP 地址不能为空，请重新输入!"
        elif [[  $proxy_ip =~ $ipzz ]]; then
            break
        else
            echo "IP 地址格式错误，请重新输入!"
        fi
    done

    sed -i '/http_proxy=/d' /etc/profile
    sed -i '/https_proxy=/d' /etc/profile
    sed -i '/ftp_proxy=/d' /etc/profile
    sed -i '/export http_proxy https_proxy ftp_proxy/d' /etc/profile

    cat >> /etc/profile <<EOF
http_proxy="http://${proxy_ip}:7890/"
https_proxy="http://${proxy_ip}:7890/"
ftp_proxy="http://${proxy_ip}:7890/"
export http_proxy https_proxy ftp_proxy
EOF

    source /etc/profile

    echo "Proxy enabled in /etc/profile."
}

unset_proxy() {
    sed -i '/http_proxy=/d' /etc/profile
    sed -i '/https_proxy=/d' /etc/profile
    sed -i '/ftp_proxy=/d' /etc/profile
    sed -i '/export http_proxy https_proxy ftp_proxy/d' /etc/profile

    source /etc/profile

    echo "Proxy disabled in /etc/profile."
}

case "$1" in
    enable)
        set_proxy
        ;;
    disable)
        unset_proxy
        ;;
    *)
        echo "Usage: $0 {enable|disable}"
        exit 1
        ;;
esac