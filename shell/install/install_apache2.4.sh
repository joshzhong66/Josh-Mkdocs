#!/bin/bash

set -e

APACHE_VERSION="2.4.62"
EXTERNAL_APACHE_URL="https://downloads.apache.org/httpd/httpd-2.4.62.tar.gz"
INTERNAL_APACHE_URL="http://10.24.1.133/Linux/apache-skywalking-apm/httpd-2.4.62.tar.gz"
Down_DIR="/usr/local/src"
APACHE_TAR="httpd-2.4.62.tar.gz"
WORK_DIR="/usr/local/apache"



function echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}

function echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}

function echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}

function echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}

function check_url() {
    curl --head --silent --fail --connect-timeout 3 --max-time 5 "$1" >/dev/null 2>&1
}


function download_apache() {
    if ! command -v wget &>/dev/null; then
        echo_log_warn "未安装 wget，将先安装wegt"
        yum install -y wget &>/dev/null
    fi

    # 检查安装包是否已存在
    if [ -f "${Down_DIR}/${APACHE_TAR}" ]; then
        echo_log_info "安装包 $APACHE_TAR 已存在，跳过下载。"
        return
    fi

    # 下载 Apache 安装包
    for url in "$INTERNAL_APACHE_URL" "$EXTERNAL_APACHE_URL"; do
        if check_url "$url"; then
            wget -P "$Down_DIR" "$url" &>/dev/null
            if [ $? -eq 0 ]; then
                echo_log_info "$APACHE_TAR 下载成功"
                return
            fi
        fi
    done

    echo_log_error "两个下载链接都无效，下载失败。"    

}


#install Apache
function install_apache() {
    if command -v apache2 || [ -d ${WORK_DIR} ] &>/dev/null; then
        echo_log_warn "系统中已安装 apache2,请先卸载后再安装"
        return
    fi


    # 安装依赖
    yum -y install apr apr-devel apr-util apr-util-devel gcc-c++ wget >/dev/null 2>&1
    
    download_apache

    cd ${Down_DIR}
    tar -zxvf ${APACHE_TAR} >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "解压 $APACHE_TAR 成功" || echo_log_error "解压 $APACHE_TAR 失败"
    cd ${Down_DIR}/httpd-${APACHE_VERSION}

    ./configure --prefix=/usr/local/apache \
    --with-pmp=worker \
    --prefix=/usr/local/apache/ \
    --enable-rewrite \
    --enable-so \
    --enable-ssl \
>/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "编译 apache 成功" || echo_log_error "编译 apache 失败"

    make -j$(nproc) &>/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "make apache 成功" || echo_log_error "make apache 失败"
    make install &>/dev/null
    [ $? -eq 0 ] && echo_log_info "安装 apache 成功" || echo_log_error "安装 apache 失败"

    systemctl stop firewalld && systemctl disable firewalld >/dev/null 2>&1
    grep "SELINUX=disabled" /etc/selinux/config >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
        [ $? -eq 0 ] && echo_log_info "关闭 selinux 成功" || echo_log_error "关闭 selinux 失败"
    fi


    cat >/etc/systemd/system/httpd.service <<EOF
[Unit]
Description=The Apache HTTP Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/apache/bin/apachectl start
ExecStop=/usr/local/apache/bin/apachectl stop
ExecReload=/usr/local/apache/bin/apachectl graceful
PIDFile=/usr/local/apache/logs/httpd.pid
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

    [ $? -eq 0 ] && echo_log_info "配置 apache 服务成功" || echo_log_error "配置 apache 服务失败"
    systemctl daemon-reload >/dev/null 2>&1
    systemctl enable httpd.service >/dev/null 2>&1
    systemctl start httpd.service >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "启动 apache 成功" || echo_log_error "启动 apache 失败"
}



function remove_apache() {
    systemctl stop httpd.service && systemctl disable httpd.service >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "停止 apache 成功" || echo_log_error "停止 apache 失败"
    rm -rf /usr/local/apache
    rm -rf /etc/systemd/system/httpd.service
    rm -rf /usr/local/src/httpd-${APACHE_VERSION}
    rm -rf /usr/local/src/httpd-${APACHE_VERSION}.tar.gz
    [ $? -eq 0 ] && echo_log_info "卸载 apache 成功" || echo_log_error "卸载 apache 失败"
}

function main() {
    clear
    echo -e "———————————————————————————
\033[32m Nginx${NGINX_VER} 安装工具\033[0m
———————————————————————————
1. 安装Apache${APACHE_VERSION}
2. 卸载Apache${APACHE_VERSION}
3. 退出\n"

    read -rp "请输入序号并回车：" num
    case "$num" in
    1) (install_apache) ;;
    2) (remove_apache) ;;
    3) (quit) ;;
    *) (main) ;;
    esac
}


main