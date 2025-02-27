#!/bin/bash

version() {
    sed -rn 's#^.* ([0-9]+)\..*#\1#p' /etc/redhat-release
}

install_os_base_rely() {
    set -e

    echo -e "\033[34m开始安装基础依赖包...\033[0m"

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
            echo -e "\033[32m$package 已安装，跳过安装。\033[0m"
        else
            echo -e "\033[33m安装 $package...\033[0m"
            yum -y install "$package" >/dev/null 2>&1
        fi
    done

    echo -e "\033[36mCentOS $centos_version 基础软件安装完成！\033[0m"
}

install_os_base_rely
