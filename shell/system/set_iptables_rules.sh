#!/bin/bash

# -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT                                          # 放行22端口
# -A INPUT -s 10.0.0.44 -m state --state NEW -m tcp -p tcp --dport 445 -j ACCEPT                            # 放行指定IP的TCP端口445
# -A INPUT -j REJECT --reject-with icmp-host-prohibited                                                     # 拒绝所有其他连接
# service iptables save                                                                                     # 保存规则
# grep "tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT" /etc/sysconfig/iptables                       # 查询规则  22端口
# grep "10.22.51.65/32 -m state --state NEW -m tcp -p tcp --dport 8083 -j ACCEPT" /etc/sysconfig/iptables   # 查询规则  ip和端口

ACTION="$1"         # 操作：add 或 del
IP="${2%/*}"        # 目标IP地址
MASK="${2#*/}"      # 掩码
PORT="$3"           # 目标端口
PROTOCOL="$4"       # 默认协议是 tcp，如果指定了则使用指定协议

IPTABLES_FILES="/etc/sysconfig/iptables"
REJECT_RULE="-A INPUT -j REJECT --reject-with icmp-host-prohibited"


RULE="-A INPUT -p $PROTOCOL -m state --state NEW -m $PROTOCOL --dport $PORT -j ACCEPT"
QUERY_RULE="$PROTOCOL -m state --state NEW -m $PROTOCOL --dport $PORT -j ACCEPT"


IP_PORT_RULE="-A INPUT -s $IP/$MASK -m state --state NEW -m $PROTOCOL -p $PROTOCOL --dport $PORT -j ACCEPT"
IP_PORT_QUERY_RULE="$IP/$MASK -m state --state NEW -m $PROTOCOL -p $PROTOCOL --dport $PORT -j ACCEPT"



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

is_valid_ip() {
    [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]   # 使用正则表达式判断是否是有效的IP地址
}

is_valid_port() {
    [[ "$PORT" -ge 1 && "$PORT" -le 65535 ]]          # 校验端口是否在有效范围内（1-65535）
}

allow_rule() {
    if ! is_valid_ip "$IP"; then
        echo_log_error "无效的IP地址: $IP"
    fi

    if ! is_valid_port "$PORT"; then
        echo_log_error "无效的端口: $PORT"
    fi
    if ! grep "$QUERY_RULE" $IPTABLES_FILES >/dev/null 2>&1; then
        echo_log_info "正在添加规则: $RULE"
        sed -i "/$REJECT_RULE/i $RULE" $IPTABLES_FILES
        
        systemctl restart iptables
        echo_log_info "规则已添加并重启iptables服务。"
    else
        echo_log_error "规则已存在: $RULE"
    fi
}

deny_rule() {
    if ! is_valid_ip "$IP"; then
        echo_log_error "无效的IP地址: $IP"
    fi

    if ! is_valid_port "$PORT"; then
        echo_log_error "无效的端口: $PORT"
    fi
    if ! grep "$QUERY_RULE" $IPTABLES_FILES >/dev/null 2>&1; then
        echo_log_error "未找到规则: $RULE"
    else
        sed -i "\|$RULE|d" $IPTABLES_FILES
        echo_log_info "正在删除规则: $RULE"
        
        systemctl restart iptables
        echo_log_info "规则已删除并重启iptables服务。"
    fi
}


allow_ip_port_rule() {
    if ! is_valid_ip "$IP"; then
        echo_log_error "无效的IP地址: $IP"
    fi

    if ! is_valid_port "$PORT"; then
        echo_log_error "无效的端口: $PORT"
    fi

    if ! grep "$IP_PORT_QUERY_RULE" $IPTABLES_FILES >/dev/null 2>&1; then
        echo_log_info "正在添加规则: $IP_PORT_RULE"
        sed -i "/$REJECT_RULE/i $IP_PORT_RULE" $IPTABLES_FILES
        
        systemctl restart iptables
        echo_log_info "规则已添加并重启iptables服务。"
    else
        echo_log_error "规则已存在: $IP_PORT_RULE"
    fi
}

deny_ip_port_rule() {
    if ! is_valid_ip "$IP"; then
        echo_log_error "无效的IP地址: $IP"
    fi

    if ! is_valid_port "$PORT"; then
        echo_log_error "无效的端口: $PORT"
    fi

    if ! grep "$IP_PORT_QUERY_RULE" $IPTABLES_FILES >/dev/null 2>&1; then
        echo_log_error "未找到规则: $IP_PORT_RULE"
    else
        sed -i "\|$IP_PORT_RULE|d" $IPTABLES_FILES
        echo_log_info "正则删除规则: $IP_PORT_RULE"
        
        systemctl restart iptables
        echo_log_info "规则已删除并重启iptables服务。"
    fi
}

main() {
    if [ $# -lt 3 ]; then
        echo "用法: $0 <add|del|addip|delip > <ip/mask> <port> <protocol>"
        exit 1
    fi
    
    # 根据操作选择调用相应的函数
    case "$ACTION" in
        add) 
        allow_rule "$IP" "$PORT" "$PROTOCOL"
        ;;
        del) 
        deny_rule "$IP" "$PORT" "$PROTOCOL"
        ;;
        addip) 
        allow_ip_port_rule "$IP/$MASK" "$PORT" "$PROTOCOL"
        ;;
        delip) 
        deny_ip_port_rule "$IP/$MASK" "$PORT" "$PROTOCOL"
        ;;
    esac
}

main "$@"