#!/bin/bash

PACKAGE_NAME=""
INSTALL_PATH="/usr/local"
DOWNLOAD_PATH="/usr/local/src"

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
    exit 1
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
      return 0
    else
      return 1
    fi
}

download_package() {
    local PACKAGE_NAME=$1
    local DOWNLOAD_PATH=$2
    shift 2 

    for url in "$@"; do
        if check_url "$url"; then
            echo_log_info "Downloading $PACKAGE_NAME from $url ..."
            wget -P "$DOWNLOAD_PATH" "$url" &>/dev/null && {
                echo_log_info "Download $PACKAGE_NAME Success"
                return 0
            }
            echo_log_error "$url Download failed"
        else
            echo_log_warn "$url is invalid"
        fi
    done
    echo_log_error "All download links are invalid. Download failed!"
    return 1
}

check_package() {
    SOFTWARE_INSTALL_PATH="$INSTALL_PATH/$PACKAGE_NAME"
    echo_log_info "Checking $SOFTWARE_INSTALL_PATH ..."
    if [ -d "$SOFTWARE_INSTALL_PATH" ]; then
        echo_log_error "Installation directory '$SOFTWARE_INSTALL_PATH' already exists. Please uninstall $PACKAGE_NAME before proceeding!"
    elif which $PACKAGE_NAME &>/dev/null; then
        echo_log_error "$PACKAGE_NAME is already installed. Please uninstall it before installing the new version!"
    fi
}

set_yum_centos6(){
    [ ! -f /etc/yum.repos.d/base.repo ] && mkdir -p /etc/yum.repos.d/backup
    if compgen -G "/etc/yum.repos.d/*.repo" > /dev/null; then
        mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/
        echo_log_info "Centos`version` yum源 文件已备份!"
    fi
    cat > /etc/yum.repos.d/base.repo <<EOF
[base]
name=base
baseurl=https://mirrors.cloud.tencent.com/centos/\$releasever/os/\$basearch/
        http://mirrors.sohu.com/centos/\$releasever/os/\$basearch/
        https://mirrors.aliyun.com/centos-vault/\$releasever.10/os/\$basearch/ 
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever

[epel]
name=epel
baseurl=https://mirrors.cloud.tencent.com/epel/\$releasever/\$basearch/
gpgcheck=1
gpgkey=https://mirrors.cloud.tencent.com/epel/RPM-GPG-KEY-EPEL-\$releasever

[extras]
name=extras
baseurl=https://mirrors.cloud.tencent.com/centos/\$releasever/os/\$basearch/
        http://mirrors.sohu.com/centos/\$releasever/extras/\$basearch/
        https://mirrors.aliyun.com/centos-vault/\$releasever.10/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever

[updates]
name=updates
baseurl=https://mirrors.cloud.tencent.com/centos/\$releasever/os/\$basearch/
        http://mirrors.sohu.com/centos/\$releasever/updates/\$basearch/
        https://mirrors.aliyun.com/centos-vault/\$releasever.10/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever

[centosplus]
name=centosplus
baseurl=https://mirrors.cloud.tencent.com/centos/\$releasever/os/\$basearch/
        http://mirrors.sohu.com/centos/\$releasever/centosplus/\$basearch/
        https://mirrors.aliyun.com/centos-vault/\$releasever.10/centosplus/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever
EOF
    yum clean all > /dev/null 2>&1
    yum repolist > /dev/null 2>&1                                                                                               
    echo_log_info "Centos`version` yum 设置完成!"
}

set_yum_centos7(){
    [ ! -f /etc/yum.repos.d/base.repo ] && mkdir -p /etc/yum.repos.d/backup
    if compgen -G "/etc/yum.repos.d/*.repo" > /dev/null; then
        mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/
        echo_log_info "Centos`version` yum源 文件已备份!"
    fi
    cat > /etc/yum.repos.d/base.repo <<EOF
[base]
name=base
baseurl=https://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/ 
        https://mirrors.huaweicloud.com/centos/\$releasever/os/\$basearch/ 
        https://mirrors.cloud.tencent.com/centos/\$releasever/os/\$basearch/
        https://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/os/\$basearch/
        http://mirrors.163.com/centos/\$releasever/os/\$basearch/
        http://mirrors.sohu.com/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever

[epel]
name=epel
baseurl=https://mirrors.aliyun.com/epel/\$releasever/\$basearch/
        https://mirrors.huaweicloud.com/epel/\$releasever/\$basearch/
        https://mirrors.cloud.tencent.com/epel/\$releasever/\$basearch/
        https://mirrors.tuna.tsinghua.edu.cn/epel/\$releasever/\$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-\$releasever

[extras]
name=extras
baseurl=https://mirrors.aliyun.com/centos/\$releasever/extras/\$basearch/
        https://mirrors.huaweicloud.com/centos/\$releasever/extras/\$basearch/
        https://mirrors.cloud.tencent.com/centos/\$releasever/extras/\$basearch/
        https://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/extras/\$basearch/
        http://mirrors.163.com/centos/\$releasever/extras/\$basearch/
        http://mirrors.sohu.com/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever

[updates]
name=updates
baseurl=https://mirrors.aliyun.com/centos/\$releasever/updates/\$basearch/
        https://mirrors.huaweicloud.com/centos/\$releasever/updates/\$basearch/
        https://mirrors.cloud.tencent.com/centos/\$releasever/updates/\$basearch/
        https://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/updates/\$basearch/
        http://mirrors.163.com/centos/\$releasever/updates/\$basearch/
        http://mirrors.sohu.com/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever

[centosplus]
name=centosplus
baseurl=https://mirrors.aliyun.com/centos/\$releasever/centosplus/\$basearch/
        https://mirrors.huaweicloud.com/centos/\$releasever/centosplus/\$basearch/
        https://mirrors.cloud.tencent.com/centos/\$releasever/centosplus/\$basearch/
        https://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/centosplus/\$basearch/
        http://mirrors.163.com/centos/\$releasever/centosplus/\$basearch/
        http://mirrors.sohu.com/centos/\$releasever/centosplus/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever
EOF
    yum clean all > /dev/null 2>&1
    yum repolist > /dev/null 2>&1
    echo_log_info "centos`version` yum 设置完成!"
}

set_yum_centos8(){
    [ ! -f /etc/yum.repos.d/base.repo ] && mkdir -p /etc/yum.repos.d/backup
    if compgen -G "/etc/yum.repos.d/*.repo" > /dev/null; then
        mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/
        echo_log_info "Centos`version` yum源 文件已备份!"
    fi
    cat > /etc/yum.repos.d/base.repo <<EOF
[BaseOS]
name=BaseOS
baseurl=https://mirrors.aliyun.com/centos/\$releasever/BaseOS/\$basearch/os/
        https://mirrors.huaweicloud.com/centos/\$releasever/BaseOS/\$basearch/os/
        https://mirrors.cloud.tencent.com/centos/\$releasever/BaseOS/\$basearch/os/
        https://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/BaseOS/\$basearch/os/
        http://mirrors.163.com//centos/\$releasever/BaseOS/\$basearch/os/
        http://mirrors.sohu.com/centos/\$releasever/BaseOS/\$basearch/os/ 
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[AppStream]
name=AppStream
baseurl=https://mirrors.aliyun.com/centos/\$releasever/AppStream/\$basearch/os/
        https://mirrors.huaweicloud.com/centos/\$releasever/AppStream/\$basearch/os/
        https://mirrors.cloud.tencent.com/centos/\$releasever/AppStream/\$basearch/os/
        https://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/AppStream/\$basearch/os/
        http://mirrors.163.com/centos/\$releasever/AppStream/\$basearch/os/
        http://mirrors.sohu.com/centos/\$releasever/AppStream/\$basearch/os/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[EPEL]
name=EPEL
baseurl=https://mirrors.aliyun.com/epel/\$releasever/Everything/\$basearch/
        https://mirrors.huaweicloud.com/epel/\$releasever/Everything/\$basearch/
        https://mirrors.cloud.tencent.com/epel/\$releasever/Everything/\$basearch/
        https://mirrors.tuna.tsinghua.edu.cn/epel/\$releasever/Everything/\$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-\$releasever

[extras]
name=extras
baseurl=https://mirrors.aliyun.com/centos/\$releasever/extras/\$basearch/os/
        https://mirrors.huaweicloud.com/centos/\$releasever/extras/\$basearch/os/
        https://mirrors.cloud.tencent.com/centos/\$releasever/extras/\$basearch/os/
        https://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/extras/\$basearch/os/
        http://mirrors.163.com/centos/\$releasever/extras/\$basearch/os/
        http://mirrors.sohu.com/centos/\$releasever/extras/\$basearch/os/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
enabled=1

[centosplus]
name=centosplus
baseurl=https://mirrors.aliyun.com/centos/\$releasever/centosplus/\$basearch/os/
        https://mirrors.huaweicloud.com/centos/\$releasever/centosplus/\$basearch/os/
        https://mirrors.cloud.tencent.com/centos/\$releasever/centosplus/\$basearch/os/
        https://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/centosplus/\$basearch/os/
        http://mirrors.163.com/centos/\$releasever/centosplus/\$basearch/os/
        http://mirrors.sohu.com/centos/\$releasever/centosplus/\$basearch/os/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF
    dnf clean all > /dev/null 2>&1
    dnf repolist > /dev/null 2>&1
    echo_log_info "centos`version` yum 设置完成!"
}





install_os_base_rely() {
    set -e

    echo_log_info "开始安装基础依赖包..."

    packages=(
        vim-enhanced
        jq
        git
        nmap
        iftop
        lrzsz
        curl
        bind-utils
        make
        gcc
        autoconf
        gcc-c++
        glibc
        glibc-devel
        pcre
        pcre-devel
        openssl
        openssl-devel
        systemd-devel
        zlib-devel
        vim
        lrzsz
        tree
        tmux
        lsof
        wget
        curl
        rsync
        net-tools
        tcpdump
        traceroute
        iotop
        bc
        bzip2
        zip
        unzip
        nfs-utils
        man-pages
    )
    centos_version=$(rpm -q --qf "%{version}" centos-release)

    for package in "${packages[@]}"; do
        if rpm -q "$package" &>/dev/null || command -v "$package" &>/dev/null; then
            echo_log_info "$package 已安装，跳过安装。"
        else
            echo_log_info -e "安装 $package..."
            yum -y install "$package" >/dev/null 2>&1
        fi
    done

    echo_log_info "CentOS $centos_version 基础软件安装完成!"
}


yum_settings() {
    echo -e "———————————————————————————
\033[32m yum工具\033[0m
———————————————————————————
0. 返回上一级
1. 设置 centos6 yum
2. 设置 centos7 yum
3. 设置 centos8 yum
4. 设置 ubuntu yum
5. 安装系统基础依赖包
6. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;             
    1) set_yum_centos6 ;;
    2) set_yum_centos7 ;;
    3) set_yum_centos8 ;;
    4) set_yum_ubuntu ;;
    5) install_os_base_rely ;;
    6) quit ;;
    *) echo_log_warn "无效选项，请重新选择。" && yum_settings ;;
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

    error_message=$(setenforce 0 2>&1)
    if [ $? -eq 0 ]; then
        echo_log_info "SELinux 已临时关闭 (设置为 Permissive 模式)。"
    else
        echo_log_warn "临时关闭 SELinux 失败，请检查权限。错误详情：${error_message}"
    fi

    if grep -q "^SELINUX=" /etc/selinux/config; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
        echo_log_info "SELinux 已设置为永久关闭。请重启系统以生效。"
    else
        echo_log_error "SELinux 配置文件 /etc/selinux/config 不存在或格式异常。"
    fi
    system_settings
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
6. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;                              # 返回上一级，即主菜单
    1) docker_network_segment ;;            # 查看docker网段
    2) docker_segment_containersname ;;     # 查看docker网段详情
    3) docker_containersnameip ;;           # 查看docker容器IP
    4) docker_image_export ;;               # 导出与传输docker镜像
    5) manage_docker_proxy ;;               # 配置docker代理
    6) quit ;;                              # 退出脚本
    *) echo_log_warn "无效选项，请重新选择。" && docker_service ;;
    esac
}




PACKAGE_NAME="nginx"
NGINX_VERSION="1.21.6"
NGINX_TAR="nginx-$NGINX_VERSION.tar.gz"
DOWNLOAD_PATH="/usr/local/src"
NGINX_INSTALL_PATH="$INSTALL_PATH/$PACKAGE_NAME"
INTERNAL_NGINX_URL="http://mirrors.sunline.cn/nginx/linux/$NGINX_TAR"
EXTERNAL_NGINX_URL="http://nginx.org/download/$NGINX_TAR"

NGX_TAR="ngx-fancyindex-0.5.2.tar.xz"
INTERNAL_NGX_FANCYINDEX="http://mirrors.sunline.cn/nginx/linux/ngx-fancyindex-0.5.2.tar.xz"
EXTERNAL_NGX_FANCYINDEX="https://github.com/aperezdc/ngx-fancyindex/releases/download/v0.5.2/ngx-fancyindex-0.5.2.tar.xz"



install_nginx() {
    check_package
    echo_log_info "Start Install Rely Package..."
    yum install -y wget make gcc gcc-c++ pcre-devel openssl-devel geoip-devel zlib-devel >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Rely Package Install Successful" || echo_log_error "Rely Package Install Failed"

    if [ -f "$DOWNLOAD_PATH/$NGINX_TAR" ]; then
        echo_log_info "The $PACKAGE_NAME source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package $PACKAGE_NAME $DOWNLOAD_PATH "$INTERNAL_NGINX_URL" "$EXTERNAL_NGINX_URL"
    fi

    tar -zxf ${DOWNLOAD_PATH}/${NGINX_TAR} -C $DOWNLOAD_PATH >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $PACKAGE_NAME Failed" || echo_log_info "Unarchive $PACKAGE_NAME Successful"

    cat /etc/passwd | grep $PACKAGE_NAME >/dev/null 2>&1 || useradd -M -s /sbin/nologin $PACKAGE_NAME
    [  $? -eq 0 ] && echo_log_info "Add $PACKAGE_NAME User Successful" || echo_log_error "Add $PACKAGE_NAME User Failed"

    cd ${DOWNLOAD_PATH}/nginx-$NGINX_VERSION
    ./configure \
    --prefix=/usr/local/nginx \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_geoip_module \
    --with-mail \
    --with-mail_ssl_module \
    >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Configure nginx Successfully!" || echo_log_error "Configure nginx Failed!"
    
    make -j $(nproc) >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Make nginx Successfully!" || echo_log_error "Make nginx Failed!"

    make install >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Install nginx Successfully!" || echo_log_error "Install nginx Failed!"

    ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
    [ $? -eq 0 ] && echo_log_info "Add nginx to /usr/bin/nginx Successfully!" || echo_log_error "Add nginx to /usr/bin/nginx Failed!"

    cat > /etc/systemd/system/nginx.service <<'EOF'
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    [ $? -eq 0 ] && echo_log_info "add /etc/systemd/system/nginx.service successfully!" || echo_log_error "Failed to add /etc/systemd/system/nginx.service"
    
    systemctl daemon-reload
    systemctl start nginx && systemctl enable nginx >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "nginx Start successfully!" || echo_log_error "nginx Start Failed!"

    rm -rf "$DOWNLOAD_PATH/nginx-${NGINX_VERSION}"
    echo_log_info "Install nginx Successfully!"
}


uninstall_nginx() {
    if [ -d $NGINX_INSTALL_PATH ]; then
        systemctl stop nginx && systemctl disable nginx >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "Stop $PACKAGE_NAME successfully!" || echo_log_error "nginx Stop Failed!"

        rm -rf $NGINX_INSTALL_PATH
        [ $? -eq 0 ] && echo_log_info "Remove $NGINX_INSTALL_PATH Successfully!" || echo_log_error "Remove $NGINX_INSTALL_PATH Failed!"

        rm -f /usr/bin/nginx
        [ $? -eq 0 ] && echo_log_info "Remove /usr/bin/nginx Successfully!" || echo_log_error "Remove /usr/bin/nginx Failed!"

        rm -f /etc/systemd/system/nginx.service
        [ $? -eq 0 ] && echo_log_info "Remove /etc/systemd/system/nginx.service Successfully!" || echo_log_error "Remove /etc/systemd/system/nginx.service Failed!"

        #rm -rf "$DOWNLOAD_PATH/nginx-${NGINX_VERSION}"
        #[ $? -eq 0 ] && echo_log_info "Remove $DOWNLOAD_PATH/nginx-${NGINX_VERSION} Successfully!" || echo_log_error "Remove $DOWNLOAD_PATH/nginx-${NGINX_VERSION} Failed!"
        
        echo_log_info "Uninstall nginx Successfully!"
    fi
}


add_ngx_fancyindex_model() {
    if [ -f "$DOWNLOAD_PATH/$NGINX_TAR" ]; then
        echo_log_info "The $PACKAGE_NAME or $PACKAGE_NAME.tar source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package $PACKAGE_NAME $DOWNLOAD_PATH "$INTERNAL_NGINX_URL" "$EXTERNAL_NGINX_URL"
    fi
    
    tar -zxf ${DOWNLOAD_PATH}/${NGINX_TAR} -C $DOWNLOAD_PATH >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $PACKAGE_NAME Failed" || echo_log_info "Unarchive $PACKAGE_NAME Successful"

    if [ -f "$DOWNLOAD_PATH/$NGX_TAR" ]; then
        echo_log_info "The $NGX_TAR source package already exists！"
    else
        echo_log_info "Start downloading the $$NGX_TAR source package..."
        wget $INTERNAL_NGX_FANCYINDEX -P $DOWNLOAD_PATH >/dev/null 2>&1
    fi

    tar -xJf $DOWNLOAD_PATH/ngx-fancyindex-0.5.2.tar.xz -C $DOWNLOAD_PATH>/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $NGX_FANCYINDEX Failed" || echo_log_info "Unarchive $NGX_FANCYINDEX Successful"

    cd "$DOWNLOAD_PATH/nginx-${NGINX_VERSION}"
    ./configure --with-compat --add-dynamic-module=$DOWNLOAD_PATH/ngx-fancyindex-0.5.2 >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Configure $PACKAGE_NAME Failed" || echo_log_info "Configure $PACKAGE_NAME Successful"
    
    make modules >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Make modules $PACKAGE_NAME Failed" || echo_log_info "Make modules $PACKAGE_NAME Successful"

    [ ! -d $NGINX_INSTALL_PATH/modules ] && mkdir -p /usr/local/nginx/modules
    [ $? -eq 0 ] && echo_log_info "Successfully mkdir /usr/local/nginx/modules" || echo_log_error "Failed to create directories"

    cp $DOWNLOAD_PATH/nginx-${NGINX_VERSION}/objs/ngx_http_fancyindex_module.so /usr/local/nginx/modules
    [ $? -eq 0 ] && echo_log_info "Successfully cp objs/ngx_http_fancyindex_module.so" || echo_log_error "Failed to copy files"

    systemctl restart nginx
    [ $? -eq 0 ] && echo_log_info "Successfully restart nginx" || echo_log_error "Failed to restart nginx"

    echo_log_info "Installation completed successfully!"
}

nginx_tool() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${NGINX_VERSION} Install Tool\033[0m
———————————————————————————
1. Install $PACKAGE_NAME${NGINX_VERSION}
2. Uninstall $PACKAGE_NAME${NGINX_VERSION}
3. Add ngx_fancyindex_model
4. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) install_nginx ;;
    2) uninstall_nginx ;;
    3) add_ngx_fancyindex_model ;;
    4) quit ;;
    *) main ;;
    esac
}


PACKAGE_NAME="tunasync"
TUNASYNC_VERSION="0.8.0"
MIRRORS_PATH="/data/mirrors"
SOFTWARE_INSTALL_PATH="/usr/local/tunasync"
PROFILE_FILE="/etc/profile"
TUNASYNC_TAR="tunasync-linux-amd64-bin.tar.gz"
INTERNAL_TUNASYNC_URL="http://mirrors.sunline.cn/source/tunasync/tunasync-linux-amd64-bin.tar.gz"
EXTERNAL_TUNASYNC_URL="https://github.com/tuna/tunasync/releases/download/v0.8.0/tunasync-linux-amd64-bin.tar.gz"


install_tunasync() {
    check_package
    mkdir -p "${SOFTWARE_INSTALL_PATH}"/{bin,etc,logs,db}
    if [ $? -eq 0 ]; then
        echo_log_info "Successfully mkdir ${SOFTWARE_INSTALL_PATH}"
    else
        echo_log_error "Failed to create directories"
    fi

    mkdir -p $MIRRORS_PATH
    [ $? -eq 0 ] && echo_log_info "Successfully mkdir $MIRRORS_PATH"
    
    if ! command -v rsync >/dev/null 2>&1; then
        echo_log_info "Rsync is not installed, installing..."

        yum -y install rsync >>/tmp/install.log 2>&1
        if [ $? -eq 0 ]; then
            echo_log_info "Rsync installed successfully!"
        else
            echo_log_error "Rsync installation failed! Error log: /tmp/install.log"
            cat /tmp/install.log
        fi
    else
        echo_log_info "Rsync is installed."
    fi

    if [ -f "$DOWNLOAD_PATH/$TUNASYNC_TAR" ]; then
        echo_log_info "The $PACKAGE_NAME source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package
    fi

    tar -zxf ${DOWNLOAD_PATH}/${TUNASYNC_TAR} -C $INSTALL_PATH/bin >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $PACKAGE_NAME Failed" || echo_log_info "Unarchive $PACKAGE_NAME Successful"

    cat >> /etc/profile <<'EOF'
# tunasync
export PATH=/usr/local/tunasync/bin:$PATH
EOF

    source /etc/profile
    [ $? -eq 0 ] && echo_log_info "Add environment variables successfully!" || echo_log_error "Failed to add environment variables"

    cat > /usr/local/tunasync/etc/manager.conf <<'EOF'
debug = false

[server]
addr = "127.0.0.1"
port = 14242
ssl_cert = ""
ssl_key = ""

[files]
db_type = "bolt"
db_file = "/usr/local/tunasync/db/manager.db"
ca_cert = ""
EOF
    [ $? -eq 0 ] && echo_log_info "add /usr/local/tunasync/etc/manager.conf successfully!"

    cat > /usr/local/tunasync/etc/worker.conf <<'EOF'
[global]
name = "tunworker"
log_dir = "/usr/local/tunasync/logs/{{.Name}}"   # 日志存储位置
mirror_dir = "/data/mirrors"                     # 仓库存储位置
concurrent = 10                                  # 线程数
interval = 1440                                  # 同步周期，单位分钟

[manager]
api_base = "http://localhost:14242"              # manager的API地址
token = ""
ca_cert = ""

[cgroup]
enable = false
base_path = "/sys/fs/cgroup"
group = "tunasync"

[server]
hostname = "localhost"
listen_addr = "127.0.0.1"
listen_port = 16010
ssl_cert = ""
ssl_key = ""

[[mirrors]]
name = "openeuler"
mirror_dir = "/data/mirrors/openeuler/openEuler-22.03-LTS-SP4/"
provider = "rsync"
upstream = "rsync://mirrors.tuna.tsinghua.edu.cn/openeuler/openEuler-22.03-LTS-SP4/"
rsync_options = [ "--include", "/virtual_machine_img", "--exclude", "/*" ]
interval = 1440
use_ipv6 = false
delete = false
delete-after = false
delay-updates = true
EOF
    [ $? -eq 0 ] && echo_log_info "add /usr/local/tunasync/etc/worker.conf successfully!"

    cat > /usr/lib/systemd/system/tunasync-manager.service <<'EOF'
[Unit]
Description = TUNA mirrors sync manager
After=network.target
Requires=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/tunasync/bin/tunasync manager -c /usr/local/tunasync/etc/manager.conf --with-systemd

[Install]
WantedBy=multi-user.target
EOF
    [ $? -eq 0 ] && echo_log_info "add /usr/lib/systemd/system/tunasync-manager.service successfully!"

    systemctl daemon-reload && systemctl start tunasync-manager >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Tunasync-manager.service Start successfully!"
}


clone_tunasync_theme() {
    echo_log_info "Cloning tunasync-theme..."

    cd /data/mirrors

    if ! command -v git >/dev/null 2>&1; then
        echo_log_info "Git is not installed, installing..."

        yum -y install git >>/tmp/install.log 2>&1
        if [ $? -eq 0 ]; then
            echo_log_info "Git installed successfully!"
        else
            echo_log_error "Git installation failed! Error log: /tmp/install.log"
            cat /tmp/install.log
        fi
    else
        echo_log_info "Git is installed."
    fi

    git clone https://github.com/marioplus/nginx-fancyindex-theme.git >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Clone tunasync-theme successfully!" || echo_log_error "Clone tunasync-theme failed!"
    mv /data/mirrors/nginx-fancyindex-theme /data/mirrors/fancyindex

    file="/data/mirrors/fancyindex/js/FileBrowserContext.js"
    sed -i "s|root = new FileContext('home', '/download/', 'home', true)|root = new FileContext('home', '/', 'home', true)|g" "$file"
    [ $? -eq 0 ] && echo_log_info "Modify tunasync-theme successfully!" || echo_log_error "Modify tunasync-theme failed!"

    cat > /usr/local/nginx/conf/modules.conf <<'EOF'
load_module modules/ngx_http_fancyindex_module.so;
EOF
    [ $? -eq 0 ] &&  echo_log_info "Add nginx module successfully!" || echo_log_error "Add nginx module failed!"

    nginx_conf="/usr/local/nginx/conf/nginx.conf"
    config_line="load_module   /usr/local/nginx/modules/ngx_http_fancyindex_module.so;"

    sed -i "1i $config_line" "$nginx_conf"
    
    confd="/usr/local/nginx/conf.d"
    confd_line="   include       $confd/*.conf;"
    [ ! -d $confd ] && mkdir -p $confd
    if grep -q "http {" "$nginx_conf"; then
        sed -i "/http {/a \ $confd_line" "$nginx_conf"
        echo_log_info "The configuration has been added to the beginning of the http block"
    else
        echo_log_error "The http block does not exist and cannot be added to the configuration"
    fi

    cat > /usr/local/nginx/conf.d/tunasync-fancyindex.conf << 'EOF'
server {
  listen 8083;
  server_name  localhost;

  location / {
    root /data/mirrors;
    charset utf-8,gbk;
    fancyindex on;
    fancyindex_localtime on;
    fancyindex_exact_size off;
    fancyindex_name_length 256;
    fancyindex_show_path on;
    fancyindex_time_format "%Y-%m-%d %T";
    fancyindex_header "/fancyindex/header.html";
    fancyindex_footer "/fancyindex/footer.html";
    fancyindex_ignore "^fancyindex" "^favicon.ico";
  }
  
  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
    root html;
  }
}
EOF
    [ $? -eq 0 ] && echo_log_info "Create a tunasync site configuration file Successfully!" || echo_log_error "Create a tunasync site configuration file Failed!"

    nginx -s reload 2>/dev/null
    [ $? -eq 0 ] && echo_log_info "Reload nginx Successfully!" || echo_log_error "Reload nginx Failed!"

    head_file="/data/mirrors/fancyindex/header.html"
    sed -i 's#<title>File Browser</title>#<title>Sunline软件镜像站|Sunline Mirrors</title>#' "$head_file"
    [ $? -eq 0 ] && echo_log_info "Modify the header.html Successfully!" || echo_log_error "Modify the header.html Failed!"

    sed -i 's|Fancyindex|Mirrors|' /data/mirrors/fancyindex/header.html
    [ $? -eq 0 ] && echo_log_info "Modify the header.html Successfully!" || echo_log_error "Modify the header.html Failed!"]


    echo_log_info "Clone_tunasync_theme Successfully!"

}


uninstall_tunasync() {
    systemctl stop tunasync-manager && systemctl disable tunasync-manager >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Stop tunasync-manager Successfully!" || echo_log_error "Stop tunasync-manager Failed!"]

    rm -rf $SOFTWARE_INSTALL_PATH && rm -rf $MIRRORS_PATH
    [ $? -eq 0 ] && echo_log_info "Uninstall tunasync-manager Successfully!" || echo_log_error "Uninstall tunasync-manager Failed!"]

    rm -f /usr/lib/systemd/system/tunasync-manager.service
    [ $? -eq 0 ] && echo_log_info "Remove tunasync-manager.service Successfully!" || echo_log_error "Remove tunasync-manager.service Failed!"]

    sed -i '/# tunasync/,+1d' "$PROFILE_FILE" && source "$PROFILE_FILE"
    [ $? -eq 0 ] && echo_log_info "Remove tunasync-manager from profile Successfully!" || echo_log_error "Remove tunasync-manager from profile Failed!"]
    
    [ $? -eq 0 ] && echo_log_info "Tunasync Unistall successfully!"
}


tunasync_tool() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${TUNASYNC_VERSION} Install Tool\033[0m
———————————————————————————
1. Install $PACKAGE_NAME${TUNASYNC_VERSION}
2. Uninstall $PACKAGE_NAME${TUNASYNC_VERSION}
3. Clone Tunasync_Theme
4. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter:" num
    case "$num" in
    1) install_tunasync ;;
    2) uninstall_tunasync ;;
    3) clone_tunasync_theme ;;
    4) quit ;;
    *) main ;;
    esac
}





source_install() {
    echo -e "———————————————————————————
\033[32m 软件安装工具\033[0m
———————————————————————————
0. 返回上一级
1. Nginx Tool
2. TunaSync Tool
3. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;
    1) nginx_tool ;;
    2) tunasync_tool ;;
    3) quit ;;
    *) echo_log_warn "无效选项，请重新选择。" && main ;;
    esac
}












init_os() {
    version | while read ov2 ; do
        if [ $ov2 -eq 8 ]; then
		    set_yum_centos8
	    elif [ $ov2 -eq 7 ]; then    
		    set_yum_centos7
	    else
		    set_yum_centos6    
	    fi
    done

    echo_log_info "Disable SELinux"
    disable_selinux

    echo_log_info "Disable Firewall"
    disable_firewall

    # Disable DNS 反向查找,提高 SSH 登录速度
    if [ "$(cat < /etc/ssh/sshd_config |grep -c 'UseDNS no')" -eq 0 ]; then
        sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
        systemctl restart sshd
        echo_log_info "Disable DNS 反向查找,提高 SSH 登录速度"
    fi

    if [ "$(cat < /etc/security/limits.conf | grep -c 65535)" -eq 0 ]; then
        sed -i '$d' /etc/security/limits.conf
        cat >> /etc/security/limits.conf <<'EOF'
* soft nofile 65535
* hard nofile 65535
* soft noproc 65535
* hard noproc 65535

# End of file
EOF
        echo_log_info "Set nofile limit to 65535"
    fi

    # profile config
    if [ "$(cat < /etc/profile | grep -c 'PS1')" -eq 0 ]; then
        cat >> /etc/profile <<'EOF'
#
export TMOUT=900
export HISTTIMEFORMAT="%F %T `whoami` $ "
export PS1='[\[\e[34;40m\]\u@\[\e[32;40m\]\h\[\e[0m\] \[\e[31;40m\]$PWD\[\e[0m\]]# '
#
EOF
    fi
    source /etc/profile

    # Disable IPv6
    cat >> /etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
    sysctl -p

    echo_log_info "Install os base rely"
    install_os_base_rely
}






main() {
    clear
    echo -e "———————————————————————————
\033[32m Linux Devps Init Tool\033[0m
———————————————————————————
1. 设置yum源
2. 设置系统配置
3. Docker服务
4. 源码安装软件
5. 初始化系统
6. 退出脚本\n"

    read -rp "请输入序号并回车：" num
    case "$num" in
    1) yum_settings ;;
    2) system_settings ;;
    3) docker_service ;;
    4) source_install ;;
    5) init_os ;;
    6) quit ;; 
    *) echo_log_warn "无效选项，请重新选择。" && main ;;
    esac
}


main