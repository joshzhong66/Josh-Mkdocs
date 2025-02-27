#!/bin/bash


DOMAIN=sunline.cn
HOST=www
HOST_IP=10.22.51.66
CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
. /etc/os-release

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

quit() {
    echo_log_info "Exit Script!"
}


install_bind () {
    if [ $ID = 'centos' -o $ID = 'rocky' ];then
	    yum install -y  bind bind-utils
	elif [ $ID = 'ubuntu' ];then
        echo_log_error "不支持Ubuntu操作系统，退出!"
	    #apt update
	    #apt install -y  bind9 bind9-utils
	else
	    echo_log_error "不支持此操作系统，退出!"
	fi

    sed -i -e '/listen-on/s/127.0.0.1/localhost/' -e '/allow-query/s/localhost/any/' /etc/named.conf
    cat >> 	/etc/named.rfc1912.zones <<EOF
zone "$DOMAIN" IN {
    type master;
    file  "$DOMAIN.zone";
};
EOF

   cat > /var/named/$DOMAIN.zone <<EOF
\$TTL 1D
@	IN SOA	master admin (
					1	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
	        NS	 master
master      A    `hostname -I`         
$HOST     	A    $HOST_IP
EOF

    chmod 640 /var/named/$DOMAIN.zone
    chgrp named /var/named/$DOMAIN.zone

    systemctl enable --now named
	systemctl is-active named.service
	if [ $? -eq 0 ] ;then 
        echo_log_info "DNS 服务安装成功!"
    else 
        echo_log_error "DNS 服务安装失败!"
    fi   
}


uninstall_bind () {
    systemctl stop named
    systemctl disable named
    rm -rf /etc/named.conf /etc/named.rfc1912.zones /var/named/$DOMAIN.zone
    yum remove -y bind bind-utils
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m Bind Install Tool\033[0m
———————————————————————————
1. 安装 Bind DNS
2. 卸载 Bind DNS
3. 退出脚本\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) (install_bind) ;;
    2) (uninstall_bind) ;;
    3) (quit) ;;
    *) (main) ;;
    esac
}


main


