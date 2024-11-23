#!/bin/bash

echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}\033[0m] $*"
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

ping_ip() {
    # 正则表达式验证 IPv4 地址格式
    local ip_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

    while true; do
        read -rp "请输入需要 ping 的 IP 地址（多个地址用空格分隔）：" ips
        if [ -z "$ips" ]; then
            echo_log_info "IP 地址不能为空，请重新输入！"
        else
            # 验证每个 IP 地址的格式
            invalid_ips=0
            for ip in $ips; do
                if ! [[ $ip =~ $ip_pattern ]]; then
                    echo_log_warn "$ip 格式不正确，请重新输入！"
                    invalid_ips=1
                    break
                fi
            done

            # 如果所有 IP 地址格式都正确，退出循环
            if [ $invalid_ips -eq 0 ]; then
                break
            fi
        fi
    done

    while true; do
        for ip in $ips; do
            if ping -c 2 -W 2 "$ip" &>/dev/null; then
                echo_log_info "$ip 可达！"
            else
                echo_log_warn "$ip 不可达！"
            fi
        done
        #sleep 5  # 每轮循环后等待 5 秒
        read -t 5 input
        [ $? -eq 0 ] && { echo_log_info "ping IP 地址 $ips 完成！"; break; }
    done
}



ping_ip
