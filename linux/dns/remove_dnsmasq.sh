#!/bin/bash
# 删除 dnsmasq

set -e

echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}
echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}


if [ $(netstat -tunlp | grep ":53 " | wc -l) -gt 0 ]; then
    echo_log_info "处理开启的53端口"

    if [ $(rpm -qa | grep dnsmasq | wc -l) -gt 0 ]; then
        for i in $(netstat -tunlp | grep ":53 " | awk '{print $7}' | awk -F "/" '{print $1}'); do
            echo_log_info "kill -9 $i 进程"
            kill -9 $i
        done
        rpm -e $(rpm -qa | grep dnsmasq | grep -v "help") --nodeps
        echo_log_info "删除 dnsmasq 服务"
    fi

    if [ $(netstat -tunlp | grep ":53 " | wc -l) -gt 0 ]; then
        echo_log_info "ERROR 53 端口已经占用，请查看原因"
        netstat -tunlp | grep ":53 "
    fi
fi
