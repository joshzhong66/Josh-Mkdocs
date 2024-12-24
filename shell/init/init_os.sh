#!/bin/bash

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


set_yum_centos6(){
    mkdir /etc/yum.repos.d/backup
    mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup
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
    yum clean all
    yum repolist                                                                                                
    echo_log_info "Centos`version` 设置完成!"
}

set_yum_centos7(){
    mkdir /etc/yum.repos.d/backup
    mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup
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
    yum clean all
    yum repolist
    echo_log_info -e "centos`version` 设置完成!"
}

set_yum_centos8(){
    mkdir /etc/yum.repos.d/backup
    mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup
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
    dnf clean all
    dnf repolist
    echo_log_info "centos`version` 设置完成!"
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
1. Set_Yum_Centos6
2. Set_Yum_Centos7
3. Set_Yum_Centos8
4. Set_Yum_Ubuntu
5. Install_OS_Base_RELY
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
10. 系统初始化
11. 退出\n"

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
    10) init_os ;;          # 系统初始化
    11) quit ;;             # 退出脚本
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





















source_install() {
    echo -e "———————————————————————————
\033[32m docker服务工具\033[0m
———————————————————————————
0. 返回上一级
1. Install Nginx
2. Install MySQL8
3. Install Openssl1.1.1w
4. Install Apache
5. Install Clash
6. Install TunaSync
7. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;
    1) install_nginx ;;
    2) install_mysql8 ;;
    3) install_openss ;;
    4) install_apache ;;
    5) install_clash ;;
    6) install_tunasync ;;
    7) quit ;;
    *) echo_log_warn "无效选项，请重新选择。" && docker_service ;;
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
1. Yum_Settings
2. System_Settings
3. Docker_Service
4. Source_Install
5. init_OS
6. Quit Scripts\n"

    read -rp "请输入序号并回车：" num
    case "$num" in
    1) yum_settings ;;
    2) system_settings ;;
    3) docker_service ;;
    4) source_install ;;
    5) init_os ;;
    5) quit ;; 
    *) echo_log_warn "无效选项，请重新选择。" && main ;;
    esac
}


main