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

quit() {
    echo_log_info "退出脚本"
    exit 0
}

version() {
    sed -rn 's#^.* ([0-9]+)\..*#\1#p' /etc/redhat-release
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m Linux 运维工具\033[0m
———————————————————————————
1. 系统设置
2. 安装服务
3. 退出\n"

    read -rp "请输入序号并回车：" num
    case "$num" in
    1) system_settings ;;   # 进入系统设置
    2) install_service ;;   # 进入安装服务
    3) quit ;;              # 退出脚本
    *) echo_log_warn "无效选项，请重新选择。" && main ;;
    esac
}


system_settings() {
    echo -e "———————————————————————————
\033[32m 系统设置工具\033[0m
———————————————————————————
0. 返回上一级
1. 修改IP
2. 设置别名
3. 修改主机名
4. 关闭防火墙
5. 关闭Selinux
6. 安装基础软件
6. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;              # 返回上一级，即主菜单
    1) change_ip ;;         # 修改IP
    2) change_alias ;;      # 设置别名
    3) change_hostname ;;   # 修改主机名
    4) disable_firewall ;;  # 关闭防火墙
    5) disable_selinux ;;   # 关闭Selinux
    6) install_basesoft ;;  # 安装基础软件
    6) quit ;;              # 退出脚本
    *) echo_log_warn "无效选项，请重新选择。" && system_settings ;;
    esac
}


install_service() {
    echo -e "———————————————————————————
\033[32m 安装服务工具\033[0m
———————————————————————————
0. 返回上一级
1. 安装mysql
2. 安装python
3. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;              # 返回上一级，即主菜单
    1) in
    1) install_mysql ;;     # 安装MySQL
    2) install_python ;;    # 安装Python
    3) quit ;;              # 退出脚本
    *) echo_log_warn "无效选项，请重新选择。" && install_service ;;
    esac
}


change_ip() {
    # Network configuration file
    echo_log_info "准备修改 IP 地址..."
    ethfile="/etc/sysconfig/network-scripts/ifcfg-eth0"
    ipzz="^([0-9]\.|[1-9][0-9]\.|1[0-9][0-9]\.|2[0-4][0-9]\.|25[0-5]\.){3}([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$"
    # Modify IP
    while :
    do
    read -p "Input IP address: " new_ip
            if [ -z $new_ip ]; then
                    echo_log_info "IP address can't be empty, please re-enter!"
            elif [[  $new_ip =~ $ipzz ]]; then
                    break
            else
                    echo_log_info "IP address format is wrong, please re-enter!"
            fi
    done
    # Modify gateway
    while :
    do
    read -p "Input Gateway address: " new_gw
            if [ -z $new_gw ]; then
                    echo_log_info "Gateway address can't be empty,please re-enter!"
            elif [[ $new_gw =~ $ipzz ]]; then
                    break
            else
                    echo_log_info "Gateway address format is wrong, please re-enter!"
            fi
    done
    # Write network card configuration file
    echo "
    TYPE=Ethernet
    BOOTPROTO=none
    DEFROUTE=yes
    IPV4_FAILURE_FATAL=no
    IPV6INIT=no
    NAME=eth0
    DEVICE=eth0
    ONBOOT=yes
    IPADDR=$new_ip
    PREFIX=24
    GATEWAY=$new_gw
    DNS1=223.5.5.5
    IPV6_PRIVACY=no
    " > $ethfile
    #
    sleep 3
    service network restart > /dev/null 2>&1
    system_settings
}

change_alias() {
    echo_log_info "正在设置别名..."
    cat >>~/.bashrc <<EOF
alias cdnet="cd /etc/sysconfig/network-scripts"
alias vimeth1="vim /etc/sysconfig/network-scripts/ifcfg-eth0"
alias scandisk="echo '- - -' > /sys/class/scsi_host/host0/scan;echo '- - -' > /sys/class/scsi_host/host1/scan;echo '- - -' > /sys/class/scsi_host/host2/scan"
alias yy='yum -y install'
alias ys='yum search'
alias yc='yum clean all'
alias yu='yum -y update'
alias yd='yum -y remove'
alias fd='systemctl stop firewalld.service'
alias fdd='systemctl disable --now firewalld.service'
alias fw='firewall-cmd --state'
alias fo='systemctl start firewalld.service'
alias fr='systemctl restart firewalld.service'
alias net='service network restart'
alias sr='systemctl restart'
alias ss='systemctl start '
alias st='systemctl stop'
alias sd='systemctl daemon-reload'
alias sa='systemctl status'
alias sn='systemctl enable --now'
alias yp='yum provides'
alias ss='netstat'
alias dp='docker pull'
alias dr='docker rmi'
alias ds='docker search'
alias dr='docker restart'
alias de='docker exec -it'
alias da='docker ps -a'
EOF
    echo_log_info -e "centos`version` 别名设置完成！ \033[0m"
    source ~/.bashrc
    system_settings
}

change_hostname(){
    read -p "请输入主机名: " HOST
    [ -z "$HOST" ] && { echo_log_error "主机名不能为空！" ; return; }

    hostnamectl set-hostname "$HOST"
    [ $? -eq 0 ] && echo_log_info "主机名设置为 $HOST ！" || { echo_log_error "主机名设置失败！"; return; }
    system_settings
}

disable_firewall() {
    echo_log_info "正在关闭 防火墙服务..."
    systemctl stop firewalld 2>/dev/null
    systemctl disable firewalld 2>/dev/null
    echo_log_info "防火墙服务已关闭。"
    system_settings
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
    system_settings
}



install_mysql() {
    echo_log_info "MySQL 安装功能正在开发中。"
    install_service
}

install_python() {
    echo_log_info "Python 安装功能正在开发中。"
    install_service
}


main