#!/bin/bash

# External url
# ubuntu:  https://artifacts.elastic.co/downloads/logstash/logstash-8.17.0-amd64.deb
# centos7: https://artifacts.elastic.co/downloads/logstash/logstash-8.14.1-linux-x86_64.tar.gz
#          https://artifacts.elastic.co/downloads/logstash/logstash-8.17.0-linux-x86_64.tar.gz

# Internal url
# centos7: http://mirrors.sunline.cn/devtools/monitor/logstash-8.14.1-linux-x86_64.tar.gz

PACKAGE_NAME="logstash"
LOGSTASH_VERSION=7.9.3
RHEL_URL="https://mirrors.sunline.cn/devtools/monitor/logstash/${PACKAGE_NAME}-${LOGSTASH_VERSION}.rpm"

# 获取系统信息
. /etc/os-release

color () {
    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ] ;then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "    
    elif [ $2 = "failure" -o $2 = "1"  ] ;then 
        ${SETCOLOR_FAILURE}
        echo -n $"FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n $"WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo 
}

install_jdk () {
    if [ $ID = "centos" -o $ID = "rocky" ];then
        yum -y install java-1.8.0-openjdk 
    elif [ $ID = "ubuntu" ];then
        apt -y install openjdk-8-jdk
    else
        color "不支持此操作系统!" 1
        exit
    fi
    [ $? -eq 0 ] ||  { color '安装JDK失败,退出!' 1; exit; }
}

install_logstash () {
    if [ $ID = "centos" -o $ID = "rocky" ];then
        if [ ! -e /usr/local/src/${RHEL_URL##*/} ];then
            wget -P /usr/local/src/ $RHEL_URL || { color  "下载失败!" 1 ;exit ; } 
        fi
        yum -y install /usr/local/src/${RHEL_URL##*/}
    elif [ $ID = "ubuntu" ];then
        if [ ! -e /usr/local/src/${UBUNTU_URL##*/} ];then
            apt update 
            wget -P /usr/local/src/ $UBUNTU_URL || { color  "下载失败!" 1 ;exit ; }
        fi
        dpkg -i /usr/local/src/${UBUNTU_URL##*/}
    else
        color "不支持此操作系统!" 1
        exit
    fi
    ln -s  /usr/share/logstash/bin/logstash /usr/bin/logstash
    [ $? -eq 0 ] ||  { color '安装软件失败,退出!' 1; exit; }
}

start_logstash () {
    systemctl	enable  logstash 
    [ $? -eq 0 ] && color "安装logstash成功!" 0 || color "安装logstash失败!" 1
}

install_jdk
install_logstash
start_logstash 
