#!/bin/bash

LIBNL3_VERSION="3.9.0"
INSTALL_DIR="/usr/local/libnl3"
DOWNLOAD_DIR="/usr/local/src"
LIBNL3_TAR="libnl-${LIBNL3_VERSION}.tar.gz"
INTERNAL_LIBNL3_URL="http://mirrors.sunline.cn/source/libnl/libnl-3.9.0.tar.gz"
EXTERNAL_LIBNL3_URL="https://github.com/thom311/libnl/releases/download/libnl3_9_0/libnl-3.9.0.tar.gz"


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
    exit 1
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}

quit() {
    echo_log_info "退出脚本！"
    exit 0
}

check_libnl3() {
    if rpm -qa | grep -q libnl; then
        echo_log_warn "libnl3 通过 rpm 安装，如需安装源码包，请先卸载后再安装！"
    elif [ -d "$INSTALL_DIR" ]; then
        echo_log_warn "libnl3 已通过源码包安装，如需重新安装，请先卸载后再安装！"
    else
        return 0
    fi
    exit 1
}

check_url() {
    if curl --head --silent --fail --connect-timeout 3 --max-time 5 "$1" >/dev/null 2>&1; then
        echo "URL is valid"
    else
        echo "URL is invalid"
    fi
}

download_libnl3() {
    for url in "$INTERNAL_LIBNL3_URL" "$EXTERNAL_LIBNL3_URL"; do
        if check_url "$url"; then
            echo_log_info "尝试从 $url 下载 libnl3 源码包..."
            wget -P "$DOWNLOAD_DIR" "$url" &>/dev/null && {
                echo_log_info "$LIBNL3_TAR 下载成功"
                return 0
            }
            echo_log_warn "$url 下载失败"
        else
            echo_log_warn "$url 无效"
        fi
    done
    echo_log_error "两个下载链接均无效，下载失败！"
    return 1
}

install_libnl3() {
    check_libnl3

    if [ -f "$DOWNLOAD_DIR/$LIBNL3_TAR" ]; then
        echo_log_info "libnl3 源码包已存在！"
    else
        echo_log_info "开始下载 libnl3 源码包..."
        download_libnl3
    fi

    yum install -y bison flex gcc gcc-c++ make wget >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "依赖安装成功！" || echo_log_error "依赖安装失败！"

    cd  ${DOWNLOAD_DIR} && tar -zxf ${LIBNL3_TAR} >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "解压 $LIBNL3_TAR 成功" || echo_log_error "解压 $LIBNL3_TAR 失败"

    cd "${DOWNLOAD_DIR}/libnl-${LIBNL3_VERSION}"
    ./configure --prefix=$INSTALL_DIR --sysconfdir=/etc --disable-static >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "编译 libnl3 成功" || echo_log_error "编译 libnl3 失败"

    make -j $(nproc) &>/dev/null && make install &>/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "安装 libnl3 成功" || echo_log_error "安装 libnl3 失败"

    echo ${INSTALL_DIR}/lib > /etc/ld.so.conf.d/libnl3.conf
    sudo ldconfig
    [ $? -eq 0 ] && echo_log_info "ldconfig 成功" || echo_log_error "ldconfig 失败"

    cat > /etc/profile.d/libnl3.sh << 'EOF'
# libnl3
export PATH="/usr/local/libnl3/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/libnl3/lib/pkgconfig:$PKG_CONFIG_PATH"
EOF
    source /etc/profile
    pkg-config --modversion libnl-genl-3.0 >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "libnl3 安装成功！" || echo_log_error "libnl3 安装失败！"
}

uninstall_libnl3() {
    rpm -qa | grep libnl >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        yum remove -y libnl3-cli libnl3 >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "rpm libnl3 已卸载成功！" || echo_log_error "rpm libnl3 卸载失败！"
    elif [ -d "${INSTALL_DIR}" ]; then
        rm -rf "${INSTALL_DIR}"
        rm -rf "${DOWNLOAD_DIR}/libnl-${LIBNL3_VERSION}"
        [ $? -eq 0 ] && echo_log_info "libnl3 源码安装文件已卸载成功！" || echo_log_error "源码 libnl3 卸载失败！"
    fi
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m libnl${LIBNL3_VERSION} 安装工具\033[0m
———————————————————————————
1. 安装 libnl3
2. 卸载 libnl3
3. 退出\n"
    read -rp "请输入序号并回车：" num
    case "$num" in
    1) install_libnl3 ;;
    2) uninstall_libnl3 ;;
    3) quit ;;
    *) main ;;
    esac
}

main