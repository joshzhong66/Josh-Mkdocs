#!/bin/bash

LOGFILE="/var/log/sys_monitor.log"

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

version() {
    sed -rn 's#^.* ([0-9]+)\..*#\1#p' /etc/redhat-release
}


check_packet() {
    local packages=(
        "mailx:mailx"
        "nss-tools:nss-tools"
    )
    for package in "${packages[@]}"; do
        local cmd="${package%%:*}"
        local pkg="${package##*:}"

        if ! command -v "$cmd" &> /dev/null; then
            echo_log_warn "$cmd 未安装，准备安装 $pkg..."
            yum -y install "$pkg" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo_log_info "$pkg 安装成功！"
            else
                echo_log_error "$pkg 安装失败！"
            fi
        fi
    done
}



mail_config() {
    rm -rf /etc/pki/nssdb/*
    certutil -N -d /etc/pki/nssdb --empty-password
    certutil -A -d /etc/pki/nssdb -n "QQ Mail CA" -t "CT,C,C" -i /etc/ssl/certs/ca-bundle.crt
    cat >~/.mailrc <<EOF
set from=980521387@qq.com
set smtp=smtps://smtp.qq.com:465
set smtp-auth-user=980521387@qq.com
set smtp-auth-password=obotxypzwkm  #smtp验证码
set smtp-auth=login
set ssl-verify=ignore
set nss-config-dir=/etc/pki/nssdb
EOF
    echo -e "\033[36mcentos`version` 邮箱服务设置完成！ \033[0m"
}


monitor_mail_send() {
    EMAIL="980521387@qq.com"

    # 创建日志文件并添加头部
    if [ ! -f "$LOGFILE" ]; then
        echo "Date,CPU Usage (%),Memory Usage (%),Disk Usage (%),Network In (KB/s),Network Out (KB/s)" > "$LOGFILE"
    fi
    while true; do
        # 获取当前日期和时间
        CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

        # 获取 CPU 使用率
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

        # 获取内存使用情况
        MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

        # 获取磁盘使用情况
        DISK_USAGE=$(df -h | grep '^/dev/' | awk '{sum += $5} END {print sum}')

        # 获取网络流量（假设使用 eth0）
        NET_IN=$(cat /proc/net/dev | grep eth0 | awk '{print $2}')
        NET_OUT=$(cat /proc/net/dev | grep eth0 | awk '{print $10}')


        # 将网络流量转换为 KB/s
        sleep 1  # 暂停 1 秒以计算流量
        NET_IN_NEW=$(cat /proc/net/dev | grep eth0 | awk '{print $2}')
        NET_OUT_NEW=$(cat /proc/net/dev | grep eth0 | awk '{print $10}')

        NET_IN_KB=$(( (NET_IN_NEW - NET_IN) / 1024 ))
        NET_OUT_KB=$(( (NET_OUT_NEW - NET_OUT) / 1024 ))

        # 将结果写入日志文件
        echo "$CURRENT_DATE,$CPU_USAGE,$MEMORY_USAGE,$DISK_USAGE,$NET_IN_KB,$NET_OUT_KB" >> "$LOGFILE"

        # 输出到控制台
        echo "$CURRENT_DATE - CPU Usage: $CPU_USAGE% - Memory Usage: $MEMORY_USAGE% - Disk Usage: $DISK_USAGE% - Network In: ${NET_IN_KB}KB/s - Network Out: ${NET_OUT_KB}KB/s"

        # 发送邮件（可选）
        if [ $(echo "$CPU_USAGE > 90" | bc) -eq 1 ]; then
            echo "High CPU Usage Alert: $CPU_USAGE%" | mail -s "CPU Usage Alert" "$EMAIL" > /dev/null 2>&1
        fi

        if [ $(echo "$MEMORY_USAGE > 90" | bc) -eq 1 ]; then
            echo "High Memory Usage Alert: $MEMORY_USAGE%" | mail -s "Memory Usage Alert" "$EMAIL" > /dev/null 2>&1
        fi

        if [ $(echo "$DISK_USAGE > 90" | bc) -eq 1 ]; then
            echo "High Disk Usage Alert: $DISK_USAGE%" | mail -s "Disk Usage Alert" "$EMAIL" > /dev/null 2>&1
        fi
    done
}


main() {
    version
    check_packet
    mail_config
    monitor_mail_send
}


main