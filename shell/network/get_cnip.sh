#!/bin/bash

DATE=$(date +'%Y%m%d')
OUTPUT_FILE="address-list_${DATE}.rsc"
DELEGATED_FILE="delegated-apnic-latest"

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
}

if wget -q -O $DELEGATED_FILE http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest; then
    {
        echo_log_info "/ip firewall address-list"
        
        # 筛选出 CN ipv4 地址并进行网段计算
        grep "|CN|ipv4" "$DELEGATED_FILE" | \
        awk -F'|' '{
            ip = $4
            num_ips = $5
            prefix = 32 - int(log(num_ips)/log(2))
            #print "add address=" ip "/" prefix " disabled=no list=zh-ip"   # MikroTik_Ros路由，CN_IP网段格式
            print ip "/" prefix    # 获取CN网段/掩码
        }'
    } > "$OUTPUT_FILE"
    
    rm -f "$DELEGATED_FILE"
else
    echo_log_error "下载失败，请检查网络连接或 URL 是否正确。"
fi
