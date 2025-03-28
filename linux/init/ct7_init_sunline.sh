#!/bin/bash

# CentOS 7 yum 源设置 (Sunline)

# 手动配置 yum 源(Sunline)
# curl -So /etc/yum.repos.d/CentOS-7.repo http://mirrors.sunline.cn/centos/7/CentOS-7.repo
# curl -So /etc/yum.repos.d/epel-7.repo http://mirrors.sunline.cn/epel/7/epel-7.repo
# yum clean all && yum makecache

REPO_DIR="/etc/yum.repos.d"

if [ ! -d ${REPO_DIR}/bak ]; then
    mkdir -p ${REPO_DIR}/bak
fi

if [ -f ${REPO_DIR}/CentOS-7.repo ]; then
    if ! mv ${REPO_DIR}/*.repo ${REPO_DIR}/bak/; then
        echo "备份 CentOS 7 yum 源失败"
        exit 1
    fi
    if  cat > /etc/yum.repos.d/CentOS-7.repo <<'EOF'; then
[base]
name=CentOS-$releasever - Base
baseurl=http://mirrors.sunline.cn/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=http://mirrors.sunline.cn/centos/RPM-GPG-KEY-CentOS-7

[update]
name=CentOS-$releasever - Updates
baseurl=http://mirrors.sunline.cn/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.sunline.cn/centos/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever - Extras
baseurl=http://mirrors.sunline.cn/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.sunline.cn/centos/RPM-GPG-KEY-CentOS-7
EOF
        echo "配置 CentOS 7 yum 源成功"
    else
        echo "配置 CentOS 7 yum 源失败" && exit 1
    fi
    if  cat > /etc/yum.repos.d/epel-7.repo <<'EOF'; then
[epel]
name=Extra Packages for Enterprise Linux 7 - $basearch
baseurl=http://mirrors.sunline.cn/epel/7/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://mirrors.sunline.cn/epel/RPM-GPG-KEY-EPEL-7
EOF
        echo "配置 epel 7 yum 源成功"
    else
        echo "配置 epel 7 yum 源失败" && exit 1
    fi

    yum clean all && yum makecache
fi