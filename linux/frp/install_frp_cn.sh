#!/bin/bash

# 内网下载：
# 官方frp下载链接：https://github.com/fatedier/frp/releases/download/v0.61.1/frp_0.61.1_linux_amd64.tar.gz
# frps.toml下载链接：https://github.com/stilleshan/frps/blob/master/frps.toml (目前没测试该模板使用情况，后续测试使用自己的链接)
# EXEC_FILE="https://raw.githubusercontent.com/stilleshan/frps/refs/heads/master/frps.toml"  #下载github代码文件，需打开代码，再点击 raw 获取文件链接

# 颜色定义
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

# 版本和路径定义
FRP_VERSION="0.61.1"          # frp版本
PACKAGE_NAME="frp"             # 软件包名称
REPO="stilleshan/frps"         # 代码仓库
DOWNLOAD_PATH="/usr/local/src"  # 下载路径
INSTALL_PATH="/usr/local/frp"   # 安装路径

# 平台判断
if [ $(uname -m) = "x86_64" ]; then
    PLATFORM=amd64  # 如果是x86_64架构，设置平台为amd64
fi

if [ $(uname -m) = "aarch64" ]; then
    PLATFORM=arm64  # 如果是aarch64架构，设置平台为arm64
fi

# 文件和URL定义
FILE_NAME=frp_${FRP_VERSION}_linux_${PLATFORM}
INTERNAL_URL="http://10.22.51.64/5_Linux/${FILE_NAME}.tar.gz"  # 内网下载地址
EXTERNAL_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}.tar.gz"  # 外网下载地址

# 日志函数
echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"  # 输出日志，包含时间和颜色
}
echo_log_info() {
    echo_log "\033[32mINFO" "$*"  # 输出信息日志
}
echo_log_warn() {
    echo_log "\033[33mWARN" "$*"  # 输出警告日志
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"  # 输出错误日志并退出
    exit 1
}

# 退出函数
quit() {
    echo_log_info "退出脚本!"  # 退出脚本
}

# 检查URL是否可用
check_url() {
    local url=$1
    if curl -f -s --connect-timeout 5 "$url" &>/dev/null; then  # 使用curl检查URL，超时5秒
        return 0  # URL可用
    else
        return 1  # URL不可用
    fi
}

# 下载软件包
download_package() {
    local PACKAGE_NAME=$1
    local DOWNLOAD_PATH=$2
    shift 2 

    # 尝试从内网下载
    if check_url "$INTERNAL_URL"; then
        echo_log_info "从内网下载$PACKAGE_NAME..."
        if wget -P "$DOWNLOAD_PATH" "$INTERNAL_URL" &>/dev/null; then  # 使用wget下载
            echo_log_info "下载$PACKAGE_NAME成功"
            return 0
        else
            echo_log_error "从内网下载失败"
        fi
    else
        echo_log_warn "内网地址不可访问，尝试外网地址..."  # 内网不可用，提示并尝试外网
    fi

    # 尝试从外网下载
    if check_url "$EXTERNAL_URL"; then
        echo_log_info "从外网下载$PACKAGE_NAME..."
        if wget -P "$DOWNLOAD_PATH" "$EXTERNAL_URL" &>/dev/null; then  # 使用wget下载
            echo_log_info "下载$PACKAGE_NAME成功"
            return 0
        else
            echo_log_error "从外网下载失败"
        fi
    else
        echo_log_error "外网地址也不可用，下载失败！"  # 外网也不可用，提示下载失败
        return 1
    fi
}

# 管理frp服务
manage_frp() {
    local action=$1         # 操作：install 或 uninstall
    local component=$2      # 组件：frps 或 frpc

    # 定义相关文件路径
    EXEC_FILE="/usr/local/frp/${component}"          # 可执行文件路径
    CONFIG_FILE="/usr/local/frp/${component}.toml"  # 配置文件路径
    SERVICE_FILE="/lib/systemd/system/${component}.service"  # 服务文件路径

    case $action in
        install)
            # 检查是否已安装
            check_package

            echo_log_info "开始安装$PACKAGE_NAME..."

            # 检查是否已下载
            if [ -f "$DOWNLOAD_PATH/${FILE_NAME}.tar.gz" ]; then
                echo_log_info "$PACKAGE_NAME源包已存在！"
            else
                echo_log_info "开始下载$PACKAGE_NAME源包..."
                download_package $PACKAGE_NAME $DOWNLOAD_PATH "$INTERNAL_URL" "$EXTERNAL_URL"  # 调用下载函数
                [ $? -ne 0 ] && {  # 下载失败处理
                    echo_log_error "下载$PACKAGE_NAME失败！"
                    return 1
                }
            fi

            # 解压缩
            tar -xzf $DOWNLOAD_PATH/${FILE_NAME}.tar.gz -C $DOWNLOAD_PATH >/dev/null 2>&1
            [ $? -eq 0 ] && echo_log_info "解压$PACKAGE_NAME成功！" || {  # 解压成功或失败
                echo_log_error "解压$PACKAGE_NAME失败！"
                return 1
            }

            # 移动可执行文件
            mkdir -p /usr/local/frp && mv $DOWNLOAD_PATH/${FILE_NAME}/${component}* /usr/local/frp
            [ $? -eq 0 ] && echo_log_info "移动$PACKAGE_NAME可执行文件成功！" || {  # 移动成功或失败
                echo_log_error "移动$PACKAGE_NAME可执行文件失败！"
                return 1
            }

            # 创建服务文件
            cat >$SERVICE_FILE <<EOF
[Unit]
Description=Frp ${component} Service  # 服务描述
After=network.target syslog.target  # 依赖的服务
Wants=network.target

[Service]
Type=simple  # 服务类型
Restart=