#!/bin/bash
#
# Install nginx script
# 官网下载：https://www.openssl.org/source/<version>.tar.gz
# \033[33m 表示黄色，\033[32m 表示绿色，\033[31m 表示红色，\033[0m 表示恢复样式

set -e

#全局变量
Down_DIR="/usr/local/src"
#openssl变量
OPENSSL_VERSION="1.1.1w"
OPENSSL_TAR="openssl-$OPENSSL_VERSION.tar.gz"
EXTERNAL_OPENSSL_URL="https://www.openssl.org/source/$OPENSSL_TAR"
INTERNAL_OPENSSL_URL="http://10.24.1.133/Linux/$OPENSSL_TAR"


# 日志输出
function echo_log_info() {
    echo -e "$(date +'%F %T') - [Info] $*"
}
function echo_log_warn() {
    echo -e "$(date +'%F %T') - [Warn] $*"
    exit 1
}
function echo_log_error() {
    echo -e "$(date +'%F %T') - [Error] $*"
    exit 1
}

function main() {
    clear
    echo -e "———————————————————————————
    \033[32m OpenSSL${OPENSSL_VER} 安装工具\033[0m
    ———————————————————————————
    1. 安装OpenSSL
    2. 卸载OpenSSL
    3. 退出
    ———————————————————————————
    \033[32m 请选择：\033[0m
    ———————————————————————————"

    read -rp "请输入序号并回车：" num
    case $num in
    1) install_openssl ;;
    2) uninstall_openssl ;;
    3) exit ;;
    *) echo_log_info "\033[33m输入错误，请重新输入！" && sleep 1 && exec "$0\033[0m" ;;
    esac
}

# 检查URL是否有效的函数
function check_url() {
  local url=$1
  if curl --head --silent --fail "$url" > /dev/null; then
    return 0  # URL 有效
  else
    return 1  # URL 无效
  fi
}

function install_openssl() {
    if command -v openssl &>/dev/null; then
        echo_log_info "\033[33mOpenSSL 已安装，请先卸载再重新安装！\033[0m"
        return 1
    fi

    if [ ! -f "$Down_DIR/$OPENSSL_TAR" ]; then
        if check_url "$INTERNAL_OPENSSL_URL"; then
            echo_log_info "内部链接有效，准备从内部源开始下载 $OPENSSL_TAR..."
            wget -P "$Down_DIR" "$INTERNAL_OPENSSL_URL" &>/dev/null 2>&1
            [ $? -ne 0 ] && echo_log_error "\033[31m内部链接下载失败，请检查网络或下载链接。\033[0m" && exit 1 
        else
            echo_log_info "内部链接无效，尝试外部链接..."
            if check_url "$EXTERNAL_OPENSSL_URL"; then
                echo_log_info "外部链接有效，通过外部链接下载 $OPENSSL_TAR..."
                wget -P "$Down_DIR" "$EXTERNAL_OPENSSL_URL" &>/dev/null 2>&1
                [ $? -ne 0 ] && echo_log_error "\033[31m外部链接下载失败，请检查网络或下载链接。\033[0m" && exit 1
            else
                echo_log_error "\033[31m内部&外部两个链接都无效，无法下载 OpenSSL，请检查链接...\033[0m"
                exit 1
            fi
        fi
        echo_log_info "\033[33m$OPENSSL_TAR 下载成功！\033[0m"
    else
        echo_log_info "\033[33mOpenSSL 已下载。\033[0m"
        if [ -d "$Down_DIR/openssl-$OPENSSL_VERSION" ]; then
            echo_log_info "\033[33m检测到旧的OpenSSL目录，正在清理...\033[0m"
            rm -rf "$Down_DIR/openssl-$OPENSSL_VERSION"
        fi
        echo_log_info "\033[33m正在解压$OPENSSL_TAR...\033[0m"
        tar -zxvf "$Down_DIR/$OPENSSL_TAR" -C "$Down_DIR" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo_log_error "\033[33m解压失败，请检查文件是否损坏。\033[0m"
            exit 1
        fi
    fi
    echo_log_info "\033[33m$OPENSSL_TAR 已解压成功，准备安装OpenSSL依赖...\033[0m"
    #安装依赖
    yum -y upgrade  >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo_log_error "\033[31m升级系统失败，请检查网络连接。\033[0m"
        exit 1
    fi
    yum install -y wget gcc gcc-c++ make zlib-devel pcre-devel geoip-devel epel-release perl-IPC-Cmd perl-Test-Simple perl-Test-Harness  >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "\033[33m依赖安装成功，准备安装OpenSSL...\033[0m" || { echo_log_error "\033[31m依赖安装失败，请检查网络连接。\033[0m"; exit 1; }


    cd "$Down_DIR/openssl-$OPENSSL_VERSION" || exit 1
    ./config -fPIC --prefix=/usr/local/openssl zlib >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "\033[31mOpenSSL 配置失败，请检查依赖是否安装成功。\033[0m" && exit 1
    make -j $(nproc) >/dev/null 2>&1
    [ $? -ne 0 ] &&  echo_log_error "\033[31mOpenSSL 编译失败，请检查依赖是否安装成功。\033[0m" && exit 1
    make test >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "\033[31mOpenSSL 安装失败，请检查依赖是否安装成功。\033[0m"  && exit 1
    make -j$(nproc)  >/dev/null 2>&1 && make install >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "\033[31mOpenSSL 安装失败...\033[0m" && exit 1
    echo_log_info "\033[33mOpenSSL 安装成功！\033[0m"
    if [ -f "/usr/bin/openssl" ]; then
        echo_logo_info "\033[33mOpenSSL 已安装,正在备份旧版本 /usr/local/openssl。\033[0m"
        mv /usr/bin/openssl /usr/bin/openssl.bak
    fi
    ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl >/dev/null 2>&1
    echo_log_info "\033[33mOpenSSL 软链接创建成功...\033[0m"]
    echo "/usr/local/openssl/lib" | sudo tee -a /etc/ld.so.conf.d/openssl.conf >/dev/null 2>&1
    sudo ldconfig
    [ $? -eq 0 ] && echo_log_info "\033[33m配置动态链接库路径成功...\033[0m" || { echo_log_error "\033[33m配置动态链接库路径失败。\033[0m"; exit 1; }
    cat > /etc/profile.d/openssl.sh << EOF
export PKG_CONFIG_PATH=/usr/local/openssl/lib/pkgconfig:$PKG_CONFIG_PATH
export LDFLAGS="-L/usr/local/openssl/lib"
export CPPFLAGS="-I/usr/local/openssl/include"
EOF
    [ $? -ne 0 ] && echo_log_error "\033[31mOpenSSL 环境变量配置失败。\033[0m" && exit 1
    source /etc/profile
}

function uninstall_openssl(){
    if ! command -v openssl &>/dev/null; then
        echo_log_warn "OpenSSL 未安装，请先安装。"
        exit 1
    else
        echo_log_info "正在卸载 OpenSSL..."
        rm -rf /usr/local/openssl
        rm -rf /usr/bin/openssl
        rm -rf /etc/profile.d/openssl.sh
        source /etc/profile
        echo_log_info "OpenSSL 已卸载。"
    fi
}


main