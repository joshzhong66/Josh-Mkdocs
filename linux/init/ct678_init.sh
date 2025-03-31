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
    yum clean all
    yum repolist                                                                                            
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
    yum clean all
    yum repolist
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
    dnf clean all
    dnf repolist
    echo_log_info "centos`version` yum 设置完成!"
}


yum_settings() {
    echo -e "———————————————————————————
\033[32m yum工具\033[0m
———————————————————————————
0. 返回上一级
1. 设置 centos6 yum
2. 设置 centos7 yum
3. 设置 centos8 yum
4. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    0) main ;;             
    1) set_yum_centos6 ;;
    2) set_yum_centos7 ;;
    4) set_yum_centos8 ;;
    6) quit ;;
    *) echo_log_warn "无效选项，请重新选择。" && yum_settings ;;
    esac
}

yum_settings