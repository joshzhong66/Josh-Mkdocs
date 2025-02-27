#!/bin/bash
# 
# Install Git
# Git官网: https://github.com/git/git
# 安装包:  https://mirrors.edge.kernel.org/pub/software/scm/git/

VERSION=2.9.5
PACKAGE_NAME=git
GIT_TAR=$PACKAGE_NAME-$VERSION.tar.gz
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH=/usr/local/$PACKAGE_NAME
INTERNAL_URL=http://10.22.51.64/software/$GIT_TAR
EXTERNAL_URL="https://mirrors.edge.kernel.org/pub/software/scm/git/$$GIT_TAR"



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
    if curl -f -s --connect-timeout 5 "$url" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

check_git() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "安装目录 "$INSTALL_PATH" 已存在，请先卸载Git！"
    elif which git &>/dev/null; then
        echo_log_error "Git 已安装，请先卸载Git！"
    fi
}



download_package() {
    # 下载指定软件包函数
    # 参数：
    #   $1 - PACKAGE_NAME: 需要下载的软件包名称
    #   $2 - DOWNLOAD_PATH: 软件包下载存储路径
    # 返回值：
    #   0 表示下载成功，1 表示所有下载尝试都失败
    # 声明局部变量（函数参数）
    local PACKAGE_NAME=$1    # 软件包名称参数
    local DOWNLOAD_PATH=$2   # 下载存储路径参数
    shift 2  # 移除了前两个位置参数，以便后续处理其他参数（虽然当前脚本未使用）

    # 首先尝试从内部源下载
    if check_url "$INTERNAL_URL"; then  # 检查内部URL是否可达
        echo_log_info "正在从内部URL下载 $PACKAGE_NAME..."
        if wget -P "$DOWNLOAD_PATH" "$INTERNAL_URL" &>/dev/null; then
            echo_log_info "$PACKAGE_NAME 下载成功"
            return 0  # 返回成功状态
        else
            echo_log_error "内部URL下载失败"
        fi
    else
        echo_log_warn "内部URL不可用，尝试外部URL..."
    fi

    # 当内部源失败后尝试外部源
    if check_url "$EXTERNAL_URL"; then
        echo_log_info "正在从外部URL下载 $PACKAGE_NAME..."
        if wget -P "$DOWNLOAD_PATH" "$EXTERNAL_URL" &>/dev/null; then
            echo_log_info "$PACKAGE_NAME 下载成功"
            return 0
        else
            echo_log_error "外部URL下载失败"
        fi
    else
        echo_log_error "外部URL也不可用，下载失败！"
        return 1
    fi
}

install_git() {
    check_git

    # 安装依赖
    yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel >/dev/null 2>&1

    if [ -f "$DOWNLOAD_PATH/${PACKAGE_NAME}-${VERSION}.tar.gz" ]; then
        echo_log_info "$PACKAGE_NAME 的软件包已存在！"
    else
        echo_log_info "开始下载 $PACKAGE_NAME 的软件包..."
        download_package "$PACKAGE_NAME" "$DOWNLOAD_PATH"
    fi

    tar -zxf $DOWNLOAD_PATH/$GIT_TAR -C $DOWNLOAD_PATH >/dev/null 2>&1
    cd /usr/local/src/$PACKAGE_NAME-$VERSION
    make -j $CPUS all && \
    make install prefix=$INSTALL_PATH
    if [ $? -eq 0 ];then 
        echo_log_info "Git 编译安装完成" 0 
    else
        echo_log_error "Git 编译安装失败" 1
    fi
    echo PATH="$INSTALL_PATH/bin/":'$PATH' > /etc/profile.d/git.sh
    . /etc/profile.d/git.sh
    ln -s $INSTALL_PATH/bin/* /usr/local/bin
    git version
}


uninstall_git() {
    if [ -d "${INSTALL_PATH}" ]; then
        echo_log_info "Git 已安装，开始卸载..."
        rm -rf ${INSTALL_PATH}
        rm -rf /etc/profile.d/git.sh
        echo_log_info "Git 卸载成功"
        sed -i '/git/d' /etc/profile.d/git.sh
        rm -f /etc/profile.d/git.sh
        source /etc/profile
    fi
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m Git Install Tool\033[0m
———————————————————————————
1. Install Git${VERSION}
2. Uninstall Git${VERSION}
3. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) (install_git) ;;
    2) (uninstall_git) ;;
    3) (quit) ;;
    *) (main) ;;
    esac
}


main