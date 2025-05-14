#!/bin/bash

# 内网下载：
# 官方frp下载链接：https://github.com/fatedier/frp/releases/download/v0.61.1/frp_0.61.1_linux_amd64.tar.gz
# frps.toml下载链接：https://github.com/stilleshan/frps/blob/master/frps.toml (目前没测试该模板使用情况，后续测试使用自己的链接)
# EXEC_FILE="https://raw.githubusercontent.com/stilleshan/frps/refs/heads/master/frps.toml"  #下载github代码文件，需打开代码，再点击 raw 获取文件链接

FRP_VERSION="0.61.1"
PACKAGE_NAME="frp" 
REPO="stilleshan/frps"
DOWNLOAD_PATH="/usr/local/src" 
INSTALL_PATH="/usr/local/frp"


if [ $(uname -m) = "x86_64" ]; then
    PLATFORM=amd64
fi

if [ $(uname -m) = "aarch64" ]; then
    PLATFORM=arm64
fi

FILE_NAME=frp_${FRP_VERSION}_linux_${PLATFORM}
INTERNAL_URL="http://10.22.51.64/5_Linux/${FILE_NAME}.tar.gz"  # 内网下载地址
EXTERNAL_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}.tar.gz"  # 外网下载地址


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



download_package() {
    local PACKAGE_NAME=$1
    local DOWNLOAD_PATH=$2
    shift 2 


    if check_url "$INTERNAL_URL"; then
        echo_log_info "从内网下载$PACKAGE_NAME..."
        if wget -P "$DOWNLOAD_PATH" "$INTERNAL_URL" &>/dev/null; then
            echo_log_info "下载$PACKAGE_NAME成功"
            return 0
        else
            echo_log_error "从内网下载失败"
        fi
    else
        echo_log_warn "内网地址不可访问，尝试外网地址..."
    fi

    if check_url "$EXTERNAL_URL"; then
        echo_log_info "从外网下载$PACKAGE_NAME..."
        if wget -P "$DOWNLOAD_PATH" "$EXTERNAL_URL" &>/dev/null; then
            echo_log_info "下载$PACKAGE_NAME成功"
            return 0
        else
            echo_log_error "从外网下载失败"
        fi
    else
        echo_log_error "外网地址也不可用，下载失败！"
        return 1
    fi
}


manage_frp() {
    local action=$1         # 操作：install 或 uninstall
    local component=$2      # 组件：frps 或 frpc

    # 定义相关文件路径
    EXEC_FILE="/usr/local/frp/${component}"          # 可执行文件路径
    CONFIG_FILE="/usr/local/frp/${component}.toml"   # 配置文件路径
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
Description=Frp ${component} Service
After=network.target syslog.target
Wants=network.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=$EXEC_FILE -c $CONFIG_FILE

[Install]
WantedBy=multi-user.target
EOF

            echo_log_info "创建服务文件成功！"

            systemctl daemon-reload

            rm -rf $DOWNLOAD_PATH/${FILE_NAME} $DOWNLOAD_PATH/${FILE_NAME}.tar.gz && echo_log_info "清理安装文件。"

            echo -e "\033[32m ===============================================================\033[0m"
            echo -e "\033[32m 安装成功，请先修改配置文件，然后启动服务。\033[0m"
            echo -e  "\033[31m vim $CONFIG_FILE"
            echo -e  "\033[32m 修改完毕后，再执行以下命令启动服务:\033[0m"
            echo -e  "\033[32m systemctl start $component && systemctl enable $component\033[0m"
            echo -e "\033[32m ================================================================\033[0m"
            ;;

        uninstall)
            if [ -f "$INSTALL_PATH/$component" ]; then
                systemctl stop $component  && systemctl disable $component 2>/dev/null
                [ $? -eq 0 ] && echo_log_info "已停止并禁用 $PACKAGE_NAME 服务。" || echo_log_warning "服务 $PACKAGE_NAME 未运行或未启用。"
                
                rm -rf $INSTALL_PATH && echo_log_info "删除 $INSTALL_PATH."
                rm -f $SERVICE_FILE && echo_log_info "删除 $SERVICE_FILE."
                [ $? -eq 0 ] && echo_log_info "删除 $SERVICE_FILE." || echo_log_warning "无法删除 $SERVICE_FILE。"
                echo_log_info "卸载完成。"
            else
                echo_log_error "$PACKAGE_NAME 未安装。"
            fi
            ;;
        *)
            echo_log_error "无效操作: $action. 请使用“install”或“uninstall”。"
            return 1
            ;;
    esac
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${APACHE_VERSION} Install Tool\033[0m
———————————————————————————
1. 安装 frps-${FRP_VERSION}
2. 卸载 frps-${FRP_VERSION}
3. 安装 frpc-${FRP_VERSION}
4. 卸载 frpc-${FRP_VERSION}
5. Quit Scripts\n"

    read -rp "请输入序列号并按 Enter：" num
    case "$num" in
    1) manage_frp install frps ;;
    2) manage_frp uninstall frps ;;
    3) manage_frp install frpc ;;
    4) manage_frp uninstall frpc ;;
    5) quit ;;

    *) main ;;
    esac
}


main
