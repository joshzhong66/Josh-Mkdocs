#!/bin/bash

IFACE="eth0"
PORT="7890"
TC_FILE="/tmp/tc.txt"
CLASH_LOG="/var/log/messages"


IPTABLES_FILES="/etc/sysconfig/iptables"
QUERY_RULE='tcp --dport 7890 -j LOG --log-prefix "Clash-Connection: "'
REJECT_RULE="-A INPUT -j REJECT --reject-with icmp-host-prohibited"
RULE='-A INPUT -p tcp --dport 7890 -j LOG --log-prefix "Clash-Connection: "'

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

check_port() {
    if netstat -tuln | grep -q ":$PORT"; then
        echo_log_warn "Port $PORT 已开启."
    else
        echo_log_error "Port $PORT 未启用."
    fi
}

add_iptables_rule() {
    check_port
    if ! grep "$QUERY_RULE" $IPTABLES_FILES >/dev/null 2>&1; then
        echo_log_info "正在添加规则: $RULE"
        sed -i "/$REJECT_RULE/i $RULE" $IPTABLES_FILES
        
        systemctl restart iptables
        echo_log_info "规则已添加并重启iptables服务。"
    else
        echo_log_error "规则已存在: $RULE"
    fi

    if [ ! -f $TC_FILE ]; then
        grep "clash-linux-amd64" ${CLASH_LOG} | grep -oP '\[TCP\] \K\d{1,3}(\.\d{1,3}){3}' | sort | uniq > $TC_FILE
        echo_log_info "已生成 $TC_FILE"
    else
        echo_log_info "已存在 $TC_FILE"
    fi
}

add_tc_rule() {
    add_iptables_rule
    
    tc qdisc del dev $IFACE root                                                    # 删除现有队列规则
    tc qdisc add dev $IFACE root handle 1: htb default 30                           # 添加根队列规则
    tc class add dev $IFACE parent 1: classid 1:1 htb rate 30mbit ceil 30mbit       # 添加根分类，限制总流量为 30 Mbps
    CLASS_ID=10                                                                     # 初始化子分类ID

    # 读取每个IP地址并为每个地址添加tc规则
    while read IP; do
        # 为每个IP地址添加独立的子分类，假设每个IP限制3 Mbps
        tc class add dev $IFACE parent 1:1 classid 1:$CLASS_ID htb rate 3mbit ceil 3mbit
        # 为每个IP地址添加过滤规则，将流量导向对应的子分类
        tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 match ip dst $IP flowid 1:$CLASS_ID
        echo_log_info "已添加tc规则: tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 match ip dst $IP flowid 1:$CLASS_ID"
        
        # 增加子分类ID
        ((CLASS_ID++))
    done < $TC_FILE

    # 设置默认分类，限制未匹配的流量为 3 Mbps
    tc class add dev $IFACE parent 1:1 classid 1:30 htb rate 3mbit ceil 3mbit
    tc filter add dev $IFACE protocol ip parent 1:0 prio 2 u32 match ip dst 0.0.0.0/0 flowid 1:30

    # 删除临时文件
    rm $TC_FILE
    echo_log_info "已删除 $TC_FILE"
}


del_tc_rule() {
    tc qdisc del dev $IFACE root
    echo_log_info "已删除tc规则"


    if ! grep "$QUERY_RULE" $IPTABLES_FILES >/dev/null 2>&1; then
        echo_log_error "未找到规则: $RULE"
    else
        sed -i "\|$RULE|d" $IPTABLES_FILES
        echo_log_info "正在删除规则: $RULE"
        
        systemctl restart iptables
        echo_log_info "规则已删除并重启iptables服务。"
    fi
    
}


main() {
    clear
    echo -e "———————————————————————————
\033[32m Clash_Tc 流量限制 Tool\033[0m
———————————————————————————
1. 添加TC规则
2. 删除TC规则
3. 退出脚本\n"

    read -rp "请输入序列号并按 Enter：" num
    case "$num" in
    1) add_tc_rule ;;
    2) del_tc_rule ;;
    3) quit ;;
    *) main ;;
    esac
}

main