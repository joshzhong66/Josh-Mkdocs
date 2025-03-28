#!/bin/bash

# 免编译包安装
# https://mirrors.sunline.cn/source/gcc/gcc-11.4.0-bin.tar.xz
# https://file.joshzhong.top/4_Install/gcc-11.4.0-bin.tar.xz

PACKAGE_NAME="gcc"
VERSION="11.4.0"
PKG_ARCH="gcc-11.4.0-bin.tar.xz"
SRC_DIR="/usr/local/src"
INSTALL_DIR="/usr/local"
MIRROR_URLS=(
    "https://mirrors.sunline.cn/source/gcc/"
    "https://file.joshzhong.top/4_Install/"
)

echo_log() {
    local color_code="$1"
    local log_level="$2"
    shift 2 

    local timestamp
    timestamp=$(date +'%F %T')
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
echo_log_success() {
    echo_log "1;32" "SUCCESS" "$@"
}

check_root() {
    if [[ $(id -u) != 0 ]]; then
        echo_log_error "必须使用root权限运行此脚本"
        exit 1
    fi
}

check_url() {
    local url=$1
    curl -fsSL --connect-timeout 5 "$url" &>/dev/null
}

check_gcc() {
    if command -v gcc &>/dev/null; then
        CHECK_GCC_VERSION=$(gcc -dumpversion | cut -d. -f1)
        if [ "$CHECK_GCC_VERSION" -eq 11 ]; then
            echo_log_info "GCC 11 已安装"
            exit 1
        else
            echo_log_warn "GCC 版本为 $CHECK_GCC_VERSION，继续安装 $PACKAGE_NAME-$VERSION"
            return 0
        fi
    else
        echo_log_warn "GCC 未安装，开始安装 $PACKAGE_NAME-$VERSION"
        return 0
    fi
}

select_mirror() {
    for url in "${MIRROR_URLS[@]}"; do
        if check_url "${url}${PKG_ARCH}"; then
            SELECTED_URL="$url"
            echo_log_info "使用镜像源：${SELECTED_URL}"
            return 0
        fi
    done
    echo_log_error "所有镜像源不可用"
}

check_pkg_arch() {
    local zip_path="$SRC_DIR/linux.zip"
    local tar_xz_path="$SRC_DIR/linux/$PKG_ARCH"


    if [[ -f "$zip_path" ]]; then
        echo_log_info "发现linux.zip，尝试解压..."
        if ! unzip -o "$zip_path" -d "$SRC_DIR"; then
            echo_log_error "解压linux.zip失败"
            return 1
        fi

        if [[ -f "$tar_xz_path" ]]; then
            echo_log_info "找到$PKG_ARCH，开始解压安装..."
            if ! tar -Jxvf "$tar_xz_path" -C "$INSTALL_DIR"; then
                echo_log_error "解压$PKG_ARCH 失败"
            fi
            return 0
        else
            echo_log_error "解压后未找到$PKG_ARCH"
        fi
    fi
    return 1
}

download_package() {
    cd "$SRC_DIR" || echo_log_error "无法进入下载目录"
    local url="${SELECTED_URL}${PKG_ARCH}"
    
    echo_log_info "下载 $PKG_ARCH ..."
    if ! wget -t 3 --timeout 30 "$url"; then
        echo_log_error "下载失败：$PKG_ARCH"
    fi
}

extract_package() {
    cd "$SRC_DIR" || echo_log_error "无法进入下载目录"
    echo_log_info "解压 $PKG_ARCH ..."
    if ! tar -Jxvf "$PKG_ARCH" -C "$INSTALL_DIR"; then
        echo_log_error "解压失败：$PKG_ARCH"
    fi
}

configure_system() {
    echo_log_info "配置系统环境..."
    echo "/usr/local/gcc/lib64" > "/etc/ld.so.conf.d/gcc-$(uname -m).conf" || echo_log_error "写入配置文件失败"
    ldconfig || echo_log_error "ldconfig执行失败"

    [[ -f /usr/bin/gcc ]] && mv /usr/bin/gcc /usr/bin/gcc_bak
    [[ -f /usr/bin/g++ ]] && mv /usr/bin/g++ /usr/bin/g++_bak

    ln -sf "$INSTALL_DIR/gcc/bin/gcc" "/usr/bin/gcc" || echo_log_error "创建gcc链接失败"
    ln -sf "$INSTALL_DIR/gcc/bin/g++" "/usr/bin/g++" || echo_log_error "创建g++链接失败"
}

validate_installation() {
    echo_log_info "验证安装..."
    if ! gcc --version | grep -q "$VERSION"; then
        echo_log_error "GCC版本验证失败"
    fi
    echo_log_info "验证通过，安装成功！"
}

cleanup() {
    echo_log_info -e "清理临时文件..."
    rm -f "$SRC_DIR/$$PKG_ARCH"
}


install_gcc() {
    if check_pkg_arch; then
        echo_log_info "从本地文件安装成功..."
    else
        echo_log_info "开始从镜像源下载安装包..."
        select_mirror
        download_package
        extract_package
    fi

    configure_system
    validate_installation
    cleanup
}

main() {
    check_gcc
    check_root
    install_gcc
    echo_log_success "$PACKAGE_NAME-$VERSION 安装完成"
}


main