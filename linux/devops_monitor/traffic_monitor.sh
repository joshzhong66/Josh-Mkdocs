#!/bin/bash

# 获取流量排名前20的IP地址（按总流量降序排序）
get_high_traffic_ips() {
    sudo iftop -t -s 5 -n -B 2>/dev/null | awk '
    BEGIN {
        # traffic 保存每个 IP 的累计流量（单位为字节）
    }
    /=>|<=/ {
        # 去除行首空白
        gsub(/^[ \t]+/, "", $0)
        # 根据字段数判断行格式
        if (NF == 7) {
            # 编号行：例如
            # 1 10.1.12.3 => 499B 184B 184B 1.08KB
            ip = $2
            cumulative = $7
        } else if (NF == 6) {
            # 缩进行：例如
            # 183.240.240.189 <= 2.32KB 809B 809B 4.74KB
            ip = $1
            cumulative = $6
        } else {
            next
        }
        # 仅处理格式正确的 IPv4 地址
        if (ip !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/)
            next

        # 将累计流量转换为字节
        if (match(cumulative, /^([0-9.]+)([KMG]?B)$/, arr)) {
            value = arr[1] + 0
            unit = arr[2]
            if (unit == "B") {
                factor = 1
            } else if (unit == "KB") {
                factor = 1024
            } else if (unit == "MB") {
                factor = 1024*1024
            } else if (unit == "GB") {
                factor = 1024*1024*1024
            } else {
                factor = 1
            }
            bytes = value * factor
        } else {
            bytes = 0
        }
        traffic[ip] += bytes
    }
    END {
        for (ip in traffic) {
            if (traffic[ip] > 0)
                # 输出 IP 和累计流量（单位字节）
                printf "%s %d\n", ip, traffic[ip]
        }
    }' | sort -k2,2nr | head -n 20 | awk '{print $1}'
}



# 查询IP地址的归属地（中文显示）
get_ip_info() {
    local ip=$1
    curl -s "https://ipinfo.io/${ip}/json" 2>/dev/null | \
    jq -r '[.ip, .city // "N/A", .region // "N/A", .country // "N/A"] | @tsv' | \
    iconv -f utf-8 -t gbk 2>/dev/null | \
    awk -F'\t' '{printf "IP: %s\n城市: %s\n地区: %s\n国家: %s\n", $1, $2, $3, $4}'
}

# 监控流量前20的IP并显示信息
monitor_ips() {
    while true; do
        clear
        echo "$(date '+%Y-%m-%d %H:%M:%S') 流量排名前20的IP地址及归属地信息："
        echo "=============================================================="
        
        # 获取IP列表并处理归属地查询
        ips=()
        while IFS= read -r ip; do
            [[ -n "$ip" ]] && ips+=("$ip")
        done < <(get_high_traffic_ips)

        # 显示带排名的IP信息
        for i in "${!ips[@]}"; do
            echo "$((i+1)). IP: ${ips[i]}"
            get_ip_info "${ips[i]}"
            echo "----------------------------------------------"
        done
        
        sleep 60
    done
}

# 运行监控
monitor_ips