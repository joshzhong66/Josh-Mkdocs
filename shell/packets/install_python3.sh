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
    echo_log_info "Exit Script!"
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
        echo_log_error "Installation directory '$INSTALL_PATH' already exists. Please uninstall Python3 before proceeding!"
    elif which python3 &>/dev/null; then
        echo_log_error "Python3 is already installed. Please uninstall it before installing the new version!"
    fi
    return 0
}

download_python() {
    for url in "$INTERNAL_PYTHON_URL" "$EXTERNAL_PYTHON_URL"; do
        if check_url "$url"; then
            echo_log_info "Download PYTHON source package from $url ..."
            wget -P "$DOWNLOAD_PATH" "$url" &>/dev/null && {
                echo_log_info "$PYTHON_TAR Download Success"
                return 0
            }
            echo_log_error "$url Download failed"
        else
            echo_log_warn "$url invalid"
        fi
    done
    echo_log_error "Both download links are invalid，Download failed！"
    return 1
}

install_python() {
    check_python

    if [ -f "$DOWNLOAD_PATH/$PYTHON_SOURCE" ]; then
        echo_log_info "Python3 The source package already exists！"
    else
        echo_log_info "Start downloading the Python3 source package..."
        download_python
    fi

    yum -y install gcc openssl-devel bzip2-devel libffi-devel zlib-devel readline-devel sqlite-devel wget >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Dependency installation successful" ||  echo_log_error "Failed to install dependencies"

    tar -xzf "$DOWNLOAD_PATH/$PYTHON_TAR" -C $DOWNLOAD_PATH >/dev/null 2>&1
    cd "$DOWNLOAD_PATH/Python-${PYTHON_VERSION}"
    ./configure --prefix=${INSTALL_PATH} --enable-optimizations >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Configure Python3 Failed" || echo_log_info "Configure Python3 Successful"

    make -j$(nproc) altinstall >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Make Python3 Failed" || echo_log_info "Make python3 Successful"

    ln -s ${INSTALL_PATH}/bin/python${PYTHON_VERSION%.*} /usr/bin/python3
    ln -s ${INSTALL_PATH}/bin/pip${PYTHON_VERSION%.*} /usr/bin/pip3
    
    [ $? -eq 0 ] && echo_log_info "Create Python3 symlinks successfully" || echo_log_error "Failed to create Python3 symlinks"
    rm -rf "$DOWNLOAD_PATH/Python*"

    echo_log_info "Display Python3 Version $(python3 --version 2>/dev/null | awk '{print $NF}' | awk -F] '{print }')"
    echo_log_info "Installation completed successfully"
}

uninstall_python() {
    if [ -d "${INSTALL_PATH}" ]; then
        echo_log_info "Python3 is installed, start uninstalling..."
        rm -rf ${INSTALL_PATH}
        rm -rf /usr/bin/python3
        rm -rf /usr/bin/pip3
        echo_log_info "Uninstall Python3 Successfully"
    else
        echo_log_warn "Python3 is not installed"
    fi
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m Python${PYTHON_VERSION} Install Tool\033[0m
———————————————————————————
1. Install PYTHON${PYTHON_VERSION}
2. Uninstall PYTHON${PYTHON_VERSION}
3. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) (install_python) ;;
    2) (uninstall_python) ;;
    3) (quit) ;;
    *) (main) ;;
    esac
}


main