#!/bin/bash


DOWNLOAD_PATH="/usr/local/src"
clash_url="http://10.22.51.64/5_Linux/clash.tar.gz"

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

check_url() {
    local url=$1
    if curl --head --silent --fail "$url" > /dev/null; then
      return 0  # URL 有效
    else
      return 1  # URL 无效
    fi
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m Linux 运维工具\033[0m
———————————————————————————
1. 系统设置
2. docker服务
3. 安装常用基础软件
4. 卸载常用基础软件
5. 退出\n"

    read -rp "请输入序号并回车：" num
    case "$num" in
    1) system_settings ;;       # 进入系统设置
    2) docker_service ;;        # 进入docker服务
    3) install_commsoft ;;      # 安装常用基础软件
    4) uninstall_commsoft ;;    # 卸载常用基础软件
    5) quit ;;                  # 退出脚本
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
6. 获取cpu占用前10
7. 获取内存占用前10
8. ping_5s/次
9. 网段扫描
10. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;              # 返回上一级，即主菜单
    1) change_ip ;;         # 修改IP
    2) change_alias ;;      # 设置别名
    3) change_hostname ;;   # 修改主机名
    4) disable_firewall ;;  # 关闭防火墙
    5) disable_selinux ;;   # 关闭Selinux
    6) get_cpu  ;;          # 获取cpu占用前10
    7) get_memory ;;        # 获取内存占用前10
    8) ping ;;              # 每5秒ping1次
    9) scan_network ;;      # 网段扫描
    10) quit ;;             # 退出脚本
    *) echo_log_warn "无效选项，请重新选择。" && system_settings ;;
    esac
}


docker_service() {
    echo -e "———————————————————————————
\033[32m docker服务工具\033[0m
———————————————————————————
0. 返回上一级
1. 查看docker网段
2. 查看docker网段详情
3. 查看docker容器IP
4. 导出与传输docker镜像
5. 配置docker代理
5. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;                              # 返回上一级，即主菜单
    1) docker_network_segment ;;            # 查看docker网段
    2) docker_segment_containersname ;;     # 查看docker网段详情
    3) docker_containersnameip ;;           # 查看docker容器IP
    4) docker_image_export ;;               # 导出与传输docker镜像
    5) manage_docker_proxy ;;               # 配置docker代理
    5) quit ;;                              # 退出脚本
    *) echo_log_warn "无效选项，请重新选择。" && docker_service ;;
    esac
}



install_commsoft() {
    echo -e "———————————————————————————
\033[32m 安装常用基础软件\033[0m
———————————————————————————
0. 返回上一级
1. 安装clash
2. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;                              # 返回上一级，即主菜单
    1) install_clash ;;                     # 安装clash
    2) quit ;;                              # 退出脚本
    *) echo_log_warn "无效选项，请重新选择。" &&  install_commsoft ;;
    esac
}



uninstall_commsoft() {
    echo -e "———————————————————————————
\033[32m 卸载常用基础软件\033[0m
———————————————————————————
0. 返回上一级
1. 安装clash
2. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;                              # 返回上一级，即主菜单
    1) uninstall_clash ;;                     # 卸载clash
    2) quit ;;                              # 退出脚本
    *) echo_log_warn "无效选项，请重新选择。" &&  uninstall_commsoft ;;
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


check_packet() {
    # 定义需要检查的命令及其安装包名
    local packages=(
        "jq:jq"
        "sshpass:sshpass"
        "rsync:rsync"
        "parallel:parallel"
    )
    for package in "${packages[@]}"; do
        # 分割命令和对应包名
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

get_cpu() {
    echo -e "No.\tPID\tCPU(%)\t线程数\t进程名"

    temp_output=""
    for pid in $(ps -eo pid --no-headers); do
        cpu_usage=$(ps -p ${pid} -o %cpu --no-headers)    # 获取进程的CPU使用率
        threads=$(cat /proc/${pid}/status 2>/dev/null | grep Threads | awk '{print $2}')    # 获取进程的线程数
        process_name=$(ps -p ${pid} -o comm --no-headers)    # 获取进程的名称

        # 处理进程状态文件可能不存在的情况（跳过）
        if [[ -z "$threads" ]]; then
            threads=0
        fi

        #  将数据添加到临时变量中
        temp_output+="${pid}\t${cpu_usage}\t${threads}\t${process_name}\n"
    done

    # 对结果按CPU使用率排序并加序号
    echo -e "$temp_output" | sort -rn -k2 | head -n 10 | awk -v count=1 '{printf "%d\t%s\n", count++, $0}' | while read line; do
        echo -e "$line"
    done
}

get_memory() {
    echo -e "\nNo.\tPID\tMem(%)\t线程数\t进程名"

    temp_output=""
    for pid in $(ps -eo pid --no-headers); do
        memory_usage=$(ps -p ${pid} -o %mem --no-headers)    # 获取进程的内存使用率
        threads=$(cat /proc/${pid}/status 2>/dev/null | grep Threads | awk '{print $2}')    # 获取进程的线程数
        process_name=$(ps -p ${pid} -o comm --no-headers)    # 获取进程的名称

        # 处理进程状态文件可能不存在的情况（跳过）
        if [[ -z "$threads" ]]; then
            threads=0
        fi
        
        #  将数据添加到临时变量中
        temp_output+="${pid}\t${memory_usage}\t${threads}\t${process_name}\n"
    done
    
    # 对结果按 CPU 使用率排序并加序号
    echo -e "$temp_output" | sort -k2 -rn | head -n 10 | awk -v count=1 '{printf "%d\t%s\n", count++, $0}' | while read line; do
        echo -e "$line"
    done
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

scan_network() {
    output_file="/tmp/Scan_Online.out"

    calc_hosts() {
        local cidr=$1
        echo $((2 ** (32 - cidr) - 2))  # 子网主机数量，减去网络号和广播地址
    }

    ip_to_int() {
        local ip=$1
        local a b c d
        IFS=. read -r a b c d <<< "$ip"
        echo "$((a << 24 | b << 16 | c << 8 | d))"
    }

    int_to_ip() {
        local int_ip=$1
        echo "$((int_ip >> 24 & 255)).$((int_ip >> 16 & 255)).$((int_ip >> 8 & 255)).$((int_ip & 255))"
    }

    scan_network() {
        local ipzz="^([0-9]\.|[1-9][0-9]\.|1[0-9][0-9]\.|2[0-4][0-9]\.|25[0-5]\.){3}([02468]|[1-9][02468]|1[0-9][02468]|2[0-4][02468]|25[024])/([0-9]|[1-2][0-9]|3[0-2])$"
        while true; do
            read -p "请输入要扫描的网段 (例如 10.22.51.16/28): " input

            if [[ $input =~ $ipzz ]]; then
                ip_part=$(echo "$input" | cut -d'/' -f1)
                cidr_part=$(echo "$input" | cut -d'/' -f2)
                echo_log_info "网段格式正确，开始计算 $input 网段的主机范围..."
                break
            else
                echo "输入的网段格式不正确，请重新输入。"
            fi
        done

        # 计算主机数量
        host_count=$(calc_hosts "$cidr_part")
        echo_log_info "网段中共有 $host_count 个可用主机。"

        # 计算网络地址的整数形式
        network_int=$(ip_to_int "$ip_part")

        # 计算起始IP地址（网络地址 + 1，避免网络地址本身）
        start_ip_int=$((network_int + 1))
        start_ip=$(int_to_ip "$start_ip_int")

        # 计算结束IP地址（起始IP + 主机数量）
        end_ip_int=$((network_int + host_count))
        end_ip=$(int_to_ip "$end_ip_int")

        echo_log_info "扫描的主机范围从 $start_ip 到 $end_ip。"

        echo "开始扫描 $input 网段，从 $start_ip 到 $end_ip..." > "$output_file"
        echo | tee -a $output_file


        temp_lock=$(mktemp)   # 创建临时锁文件

        export -f scan_ip     # 导出 scan_ip 函数供 parallel 使用
        export -f int_to_ip   # 导出 int_to_ip 函数供 parallel 使用
        
        # 使用 GNU Parallel 执行扫描
        seq "$start_ip_int" "$end_ip_int" | parallel -j 10 scan_ip {} "$output_file" "$temp_lock"

        rm -f $temp_lock

        echo && echo_log_info "扫描完成。所有在线IP的端口扫描结果已保存到 $output_file，并在上方打印。"
    }

    scan_ip() {
        local current_ip_int=$1
        local current_ip=$(int_to_ip $current_ip_int)
        local output_file=$2
        local temp_lock=$3
        temp_file=$(mktemp)
        trap 'rm -f $temp_file' EXIT  # 保证退出时删除临时文件

        # 检查IP是否在线
        if ping -c 3 -W 5 "$current_ip" &> /dev/null; then
            echo "$current_ip 在线，正在检测所有端口..." | tee -a "$temp_file"
            # 扫描所有端口
            local scan_result=$(nmap -p- --open -T4 --host-timeout 10s "$current_ip" | awk 'BEGIN {printf "%-13s %-8s %-15s\n", "PORT", "STATE", "SERVICE"} /^[0-9]+\/tcp/ {printf "%-13s %-8s %-15s\n", $1, $2, $3}')
            if [[ "$scan_result" =~ "tcp" ]]; then
                echo "$scan_result" >> "$temp_file"
            else
                echo "检测不到任何端口，可能被拦截了." >> "$temp_file"
            fi
        else
            echo "$current_ip 不在线." | tee -a "$temp_file"
        fi
        echo >> "$temp_file"
        flock $temp_lock -c "cat '$temp_file' >> '$output_file'"    # 使用flock确保只有一个进程写入并插入空行
    }

    check_packet
    scan_network
}

docker_network_segment() {
    docker network ls -q | xargs -I {} docker network inspect --format '{{.Name}}: {{range .IPAM.Config}}{{.Subnet}}{{end}}' {}
    docker_service
}

docker_segment_containersname() {
    docker network ls -q | while read network; do
        echo "Network: $(docker network inspect --format '{{.Name}}' $network)"
        echo "Subnet: $(docker network inspect --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' $network)"
        docker network inspect --format '{{range $k, $v := .Containers}}{{$v.Name}} {{end}}' $network | xargs -n 1 echo "Container: "
        echo
    done
    docker_service
}



docker_containersnameip() {
    docker network ls -q | while read network; do
        #echo "Network: $(docker network inspect --format '{{.Name}}' $network)"
        #echo "Subnet: $(docker network inspect --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' $network)"
        docker network inspect $network --format '{{json .Containers}}' | jq -r 'to_entries[] | "\(.value.Name): \(.value.IPv4Address)"' | sed 's/\/.*//'
        #echo
    done
    docker_service
}


docker_image_export() {
    docker_dir="/usr/local/src"
    
    list_images(){
        echo_log_info "查看可用的 Docker 镜像："
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}" | tail -n +2 | nl
    }

    export_image(){
        read -p "请输入要导出的镜像编号: " image_number
        image_name=$(docker images --format "{{.Repository}}:{{.Tag}}" | sed -n "${image_number}p")
        [ -z "$image_name" ] && echo_log_error "无效的编号，请重新运行脚本。" && return
        sanitized_image_name=$(echo "$image_name" | tr '/' '_' | tr ':' '_')	#镜像名的/和:替换成下划线
        [ ! -w "$docker_dir" ] && echo_log_error "当前目录不可写，请检查权限或切换目录。"
        if [ -f "${docker_dir}/${sanitized_image_name}.tar.gz" ]; then
            while [[ "$answer" != "y" && "$answer" != "n" ]]; do
                echo_log_warn "文件已存在，是否重新导出？(y/n)"
                read -r answer
            done
            [[ $answer == "n" ]] && return || rm -f ${docker_dir}/${sanitized_image_name}.tar.gz
        fi
        echo_log_info "导出镜像: $image_name"
        docker save "$image_name" | gzip > "${docker_dir}/${sanitized_image_name}.tar.gz"
        [ $? -ne 0 ] && echo_log_error "镜像导出失败！"
        echo_log_info "镜像已导出为 ${sanitized_image_name}.tar.gz"
    }

    validate_ip() {
        local ip=$1
        if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
            IFS='.' read -r -a octets <<< "$ip"
            for octet in "${octets[@]}"; do
                if ((octet < 0 || octet > 255)); then
                    return 1
                fi
            done
            if [[ "$ip" == "0.0.0.0" || "$ip" == "255.255.255.255" || "$ip" =~ ^127\. || "$ip" =~ ^255\. ]]; then
                return 1
            fi
            return 0
        else
            return 1
        fi
    }

    copy_image_to_remote() {
        while true; do
            read -p "请输入远程服务器的IP地址: " remote_ip
            if validate_ip "$remote_ip"; then
                break
            else
                echo_log_warn "无效的IP地址，请重新输入。"
            fi
        done
        read -p "请输入远程服务器的用户名: " remote_user
        read -s -p "请输入远程服务器的密码: " remote_password
        echo 
        sshpass -p "${remote_password}" rsync -avz --progress "${docker_dir}/${sanitized_image_name}.tar.gz" "${remote_user}@${remote_ip}:${docker_dir}"    #用rsync显示进度条
        #sshpass -p "${remote_password}" scp -v "${docker_dir}/${sanitized_image_name}.tar.gz" "${remote_user}@${remote_ip}:${docker_dir}"  #使用sshpass配合scp不会显示进度条
        [ $? -eq 0 ] && echo_log_info "镜像文件已传输到 ${remote_ip}:${docker_dir}" || { echo_log_error "文件传输失败！"; }
    }

    # 在远程服务器上加载镜像并修改名称
    remote_operations() {
        echo_log_info "正在复制镜像 ${sanitized_image_name}.tar.gz 到远程服务器 ${remote_ip}..."
        sshpass -p "${remote_password}" ssh "$remote_user@$remote_ip" >/dev/null 2>&1 << EOF
cd "${docker_dir}"
gunzip -c "${sanitized_image_name}.tar.gz" | docker load
EOF
        [ $? -eq 0 ] && echo_log_info "镜像${sanitized_image_name}加载成功！" || { echo_log_error "镜像${sanitized_image_name}加载失败！" ; }
    }
    check_packet
    list_images
    export_image
    copy_image_to_remote
    remote_operations
}


manage_docker_proxy() {
    set_proxy() {
        read -rp "Please input proxy IP：" proxy_ip

        sed -i '/Environment="HTTP_PROXY/d' /usr/lib/systemd/system/docker.service
        sed -i '/Environment="HTTPS_PROXY/d' /usr/lib/systemd/system/docker.service
        sed -i '/Environment="NO_PROXY/d' /usr/lib/systemd/system/docker.service

        sed -i "/\[Install\]/i\Environment=\"HTTP_PROXY=http://${proxy_ip}:7890/\"\nEnvironment=\"HTTPS_PROXY=http://${proxy_ip}:7890/\"\nEnvironment=\"NO_PROXY=localhost,127.0.0.1,.example.com\"" /usr/lib/systemd/system/docker.service

        systemctl daemon-reload && systemctl restart docker

        echo "Docker proxy enabled"
    }

    unset_proxy() {
        sed -i '/Environment="HTTP_PROXY/d' /usr/lib/systemd/system/docker.service
        sed -i '/Environment="HTTPS_PROXY/d' /usr/lib/systemd/system/docker.service
        sed -i '/Environment="NO_PROXY/d' /usr/lib/systemd/system/docker.service

        systemctl daemon-reload && systemctl restart docker

        echo "Docker proxy disabled"
    }
    read -rp "请输入 enable 或 disable 以启用禁用代理" state
    case "$state" in
        enable)
        set_proxy ;;
        disable)
        unset_proxy ;;
    esac
}


install_clash() {
    if [ -x "$(command -v clash)" ]; then
        echo_log_warn "Clash Already installed, no need to reinstall."
        exit 1
    fi
    check_url "$clash_url"
    wget "$clash_url" -P "$DOWNLOAD_PATH" >/dev/null 2>&1
    tar -zxf "$DOWNLOAD_PATH"/clash.tar.gz -C /data/ >/dev/null 2>&1
    cd /data/clash
    gunzip clash-linux-amd64-v1.7.1.gz  >/dev/null 2>&1
    mv clash-linux-amd64-v1.7.1 clash-linux-amd64 >/dev/null 2>&1
    chmod +x clash-linux-amd64
    ln -s /data/clash/clash-linux-amd64 /usr/bin/clash

    # 创建 Clash systemd 服务
    cat > /etc/systemd/system/clash.service << EOF
[Unit]
Description=Clash daemon, A rule-based proxy in Go.
After=network.target

[Service]
Type=simple
Restart=always
ExecStart=/data/clash/clash-linux-amd64 -d /data/clash

[Install]
WantedBy=multi-user.target
EOF

    echo -e "export http_proxy=http://127.0.0.1:7890\nexport https_proxy=http://127.0.0.1:7890" | tee /etc/profile.d/clash.sh
    source /etc/profile.d/clash.sh

    systemctl daemon-reload
    systemctl enable --now clash.service >/dev/null 2>&1
}

uninstall_clash() {
    systemctl stop clash && systemctl disable clash >/dev/null 2>&1
    rm -rf /data/clash
    rm -rf /etc/profile.d/clash.sh
    rm -rf /etc/systemd/system/clash.service
    rm -rf /usr/bin/clash
}


main