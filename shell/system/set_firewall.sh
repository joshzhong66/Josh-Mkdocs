#!/bin/bash

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

disable_firewall() {
    echo_log_info "正在关闭 防火墙服务..."
    systemctl stop firewalld 2>/dev/null
    systemctl disable firewalld 2>/dev/null
    echo_log_info "防火墙服务已关闭。"
}

enable_firewall() {
    echo_log_info "正在启动 防火墙服务..."
    systemctl start firewalld 2>/dev/null
    systemctl enable firewalld 2>/dev/null
    echo_log_info "防火墙服务已启动。"
}

disable_selinux() {
    echo_log_info "正在关闭 Selinux..."

    setenforce 0 2>/dev/null
    [ $? -eq 0 ] && echo_log_info "SELinux 已临时关闭 (设置为 Permissive 模式)。" || { echo_log_error "临时关闭 SELinux 失败，请检查权限。"; return; }

    if grep -q "^SELINUX=" /etc/selinux/config; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
        echo_log_info "SELinux 已设置为永久关闭。请重启系统以生效。"
    else
        echo_log_error "SELinux 配置文件 /etc/selinux/config 不存在或格式异常。"
    fi
}

enable_selinux() {
    echo_log_info "正在启用 Selinux..."

    setenforce 1 2>/dev/null
    [ $? -eq 0 ] && echo_log_info "SELinux 已临时启用。" || { echo_log_error "临时启用 SELinux 失败，请检查权限。"; return; }

    if grep -q "^SELINUX=" /etc/selinux/config; then
        sed-i 's/^SELINUX=.*/SELIN
        INUX=enforcing/' /etc/selinux/config
        echo_log_info "SELinux 已永久启用。"
    else
        echo "SELINUX=enforcing" >> /etc/selinux/config
        echo_log_info "SELinux 已永久启用。"
    fi
}

enable_iptables() {
    packages=(iptables iptables-services)
    for package in "${packages[@]}"; do
        if rpm -q "$package" &>/dev/null || command -v "$package" &>/dev/null; then
            echo_log_info "$package 已安装，跳过安装."
        else
            echo_log_info -e "安装 $package..."
            yum -y install "$package" >/dev/null 2>&1
        fi
    done

    if systemctl is-active --quiet iptables; then
        echo "iptables is running"
    else
        echo "iptables is not running"
        systemctl start iptables.service && systemctl enable iptables.service >/dev/null 2>&1
    fi

}

open_iptables_port() {
    
}

disable_iptables() {
    echo -e "\033[34m开始关闭 iptables...\033[0m"
    systemctl stop iptables.service && systemctl disable iptables.service >/dev/null 2>&1
    echo -e "\033[36miptables 关闭完成！\033[0m"
}



main() {
    clear
    echo -e "———————————————————————————
\033[32m Firewalld Tool\033[0m
———————————————————————————
1. Disable Firewalld
2. Enable Firewalld
3. Disable Selinux
4. Enable Selinux
5. Disable Iptables
6. Enable Iptables
7. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter:" num
    case "$num" in
    1) disable_firewall ;;
    2) enable_firewall ;;
    3) disable_selinux ;;
    4) enable_selinux ;;
    5) disable_iptables ;;
    6) enable_iptables ;;
    7) quit ;;

    *) main ;;
    esac
}

main