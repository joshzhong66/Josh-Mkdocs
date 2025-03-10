#!/bin/bash

# 获取当前连接的IP地址
get_connected_ips() {
    netstat -ntu | awk '{print $5}' | cut -d: -f1 | grep -v -e 'Address' -e '^$' -e '127.0.0.1' | sort | uniq
}

# 查询IP地址的归属地
get_ip_info() {
    local ip=$1
    curl -s "https://ipinfo.io/$ip/json"
}

# 监控连接的IP地址并查询归属地
monitor_ips() {
    while true; do
        echo "当前连接的IP地址和归属地信息："
        for ip in $(get_connected_ips); do
            echo "IP: $ip"
            get_ip_info $ip
            echo ""
        done
        echo "-----------------------------"
        sleep 60  # 每隔60秒检查一次
    done
}

# 运行监控
monitor_ips