#!/bin/bash
#
# Install python3 script
# 官网下载：https://www.python.org/ftp/python/<version>/Python-<version>.tgz
# 公司资源：http://mirrors.sunline.cn/python/linux/${PYTHON_TAR}
#

PYTHON_VERSION="3.9.7"
INSTALL_PATH="/usr/local/python3"
DOWNLOAD_PATH="/usr/local/src"
PYTHON_TAR="Python-${PYTHON_VERSION}.tgz"
INTERNAL_PYTHON_URL="http://mirrors.sunline.cn/python/linux/${PYTHON_TAR}"
EXTERNAL_PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/${PYTHON_TAR}"

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
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}

quit() {
    echo_log_info "退出脚本!"
}

check_url() {
    local url=$1
    if curl --head --silent --fail "$url" > /dev/null; then
        return 0
    else
        return 1
    fi
}

check_python() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "安装目录 '$INSTALL_PATH' 已存在,请先卸载 Python3 再继续！"
    elif which python3 &>/dev/null; then
        echo_log_error "Python3 已经安装。请在安装新版本之前卸载它！"
    fi
    return 0
}

download_python() {
    for url in "$INTERNAL_PYTHON_URL" "$EXTERNAL_PYTHON_URL"; do
        if check_url "$url"; then
            echo_log_info "从 $url 下载 Python 源码包..."
            wget -P "$DOWNLOAD_PATH" "$url" &>/dev/null && {
                echo_log_info "$PYTHON_TAR 下载成功"
                return 0
            }
            echo_log_error "$url 下载失败"
        else
            echo_log_warn "$url 无效"
        fi
    done
    echo_log_error "所有下载链接均无效，下载失败！"
    return 1
}

install_python() {
    check_python

    if [ -f "$DOWNLOAD_PATH/$PYTHON_TAR" ]; then
        echo_log_info "Python3 源码包已存在！"
    else
        echo_log_info "开始下载 Python3 源码包..."
        download_python
    fi

    yum -y install gcc openssl-devel bzip2-devel libffi-devel zlib-devel readline-devel sqlite-devel wget >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "依赖安装成功" ||  echo_log_error "依赖安装失败"

    tar -xzf "$DOWNLOAD_PATH/$PYTHON_TAR" -C $DOWNLOAD_PATH >/dev/null 2>&1
    cd "$DOWNLOAD_PATH/Python-${PYTHON_VERSION}"
    ./configure --prefix=${INSTALL_PATH} --with-openssl=/usr/local/openssl --enable-optimizations >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "配置 Python3 失败" || echo_log_info "配置 Python3 成功"

    make -j$(nproc) altinstall >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "编译 Python3 失败" || echo_log_info "编译 Python3 成功"

    ln -s ${INSTALL_PATH}/bin/python${PYTHON_VERSION%.*} /usr/bin/python3
    ln -s ${INSTALL_PATH}/bin/pip${PYTHON_VERSION%.*} /usr/bin/pip3
    
    [ $? -eq 0 ] && echo_log_info "创建 Python3 软链接成功" || echo_log_error "创建 Python3 软链接失败"
    rm -rf "$DOWNLOAD_PATH/Python*"

    echo_log_info "显示 Python3 版本 $(python3 --version 2>/dev/null | awk '{print $NF}' | awk -F] '{print }')"
    echo_log_info "安装成功完成"

    # 添加环境变量
    echo "export PATH=${INSTALL_PATH}/bin:\$PATH" > /etc/profile.d/python3.sh
    source /etc/profile.d/python3.sh

    # 删除安装包
    rm -rf "$DOWNLOAD_PATH/$PYTHON_TAR"
    rm -rf "$DOWNLOAD_PATH/Python-${PYTHON_VERSION}"

}

uninstall_python() {
    if [ -d "${INSTALL_PATH}" ]; then
        echo_log_info "Python3 已安装，开始卸载..."
        rm -rf ${INSTALL_PATH}
        echo_log_info "删除 Python3 安装目录成功"
        rm -rf "$DOWNLOAD_PATH/Python-${PYTHON_VERSION}"
        echo_log_info "删除 Python3 源码包目录成功"
        rm -rf /usr/bin/python3
        rm -rf /usr/bin/pip3
        echo_log_info "删除 Python3 软链接成功"
        rm -f  /etc/profile.d/python3.sh
        echo_log_info "删除 Python3 环境变量成功"
        echo_log_info "卸载 Python3 成功"
    else
        echo_log_warn "Python3 未安装"
    fi
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m Python${PYTHON_VERSION} 安装工具\033[0m
———————————————————————————
1. 安装 PYTHON${PYTHON_VERSION}
2. 卸载 PYTHON${PYTHON_VERSION}
3. 退出脚本\n"

    read -rp "请输入序号并按回车：" num
    case "$num" in
    1) (install_python) ;;
    2) (uninstall_python) ;;
    3) (quit) ;;
    *) (main) ;;
    esac
}

main