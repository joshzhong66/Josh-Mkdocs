#!/bin/bash

PACKAGE_NAME="fping"
VERSION="5.3"
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH="/usr/local/${PACKAGE_NAME}-${VERSION}"


echo_log() {
    local color_code="$1"
    local log_level="$2"
    shift 2

    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_prefix="${timestamp} -[\033[${color_code}m${log_level}\033[0m]"

    echo -e "${log_prefix} $*"
}
echo_log_info() {
    echo_log "32" "INFO" "$@"
}

echo_log_warn() {
    echo_log "33" "WARN" "$@"
}

echo_log_error() {
    echo_log "31" "ERROR" "$@"
    exit 1
}

check_url() {
    local url=$1
    if curl -f -s --connect-timeout 5 "$url" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

check_package() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "安装目录 '$INSTALL_PATH' 已存在. 请先卸载 $PACKAGE_NAME 然后再继续！"
    elif which $PACKAGE_NAME &>/dev/null; then
        echo_log_error "$PACKAGE_NAME 已安装。请在安装新版本之前将其卸载！"
    fi
}


download_package() {
    version=$1
    
    tar_name="$PACKAGE_NAME-${version}.tar.gz"
    
    echo_log_info "传递给 download_package 的版本号: ${version}"

    local internal_base="http://10.22.51.64/5_Linux/监控系统"
    local internal_url="${internal_base}/${tar_name}"
    local external_url="https://fping.org/dist/${PACKAGE_NAME}-${version}.tar.gz"

    # 下载逻辑
    if [ ! -f "$DOWNLOAD_PATH/$tar_name" ]; then 
        if check_url "$internal_url"; then
            echo_log_info "从内网下载: $internal_url"
            if ! wget -q -O "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"; then
                echo_log_warn "wget下载失败，尝试使用curl..."
                if ! curl -sSL -o "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"; then
                    echo_log_error "内网下载失败"
                    return 3
                else
                    echo_log_info "内网下载${tar_name}成功"
                fi
            fi  
        else
            echo_log_warn "内网不可达，尝试外网下载: $external_url"
            if ! wget -q -O "${DOWNLOAD_PATH}/${tar_name}" "$external_url"; then
                echo_log_warn "wget下载失败，尝试使用curl..."
                if ! curl -sSL -o "${DOWNLOAD_PATH}/${tar_name}" "$external_url"; then
                    echo_log_error "外网下载${tar_name}失败"
                    return 4
                else 
                    echo_log_info "外网下载${tar_name}成功"
                fi
            fi
        fi
    else
        echo_log_info "$tar_name 已存在，跳过下载"
    fi
}


install_fping() {
    check_package
    download_package $VERSION

    cd $DOWNLOAD_PATH
    tar -zxf $DOWNLOAD_PATH/${PACKAGE_NAME}-${VERSION}.tar.gz
    
    cd $DOWNLOAD_PATH/${PACKAGE_NAME}-${VERSION}
    ./configure --prefix=/usr/local/${PACKAGE_NAME}-${VERSION}
    make && make install

    /usr/local/${PACKAGE_NAME}-${VERSION}/sbin/fping -v

    ln -s /usr/local/${PACKAGE_NAME}-${VERSION}/sbin/fping /usr/sbin/fping

    fping -v

    echo_log_info "fping 安装成功"
}

install_fping


