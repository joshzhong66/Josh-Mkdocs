#!/bin/bash

# 内网下载：
# 官方frp下载链接：https://github.com/fatedier/frp/releases/download/v0.61.1/frp_0.61.1_linux_amd64.tar.gz
# frps.toml下载链接：https://github.com/stilleshan/frps/blob/master/frps.toml (目前没测试该模板使用情况，后续测试使用自己的链接)
# EXEC_FILE="https://raw.githubusercontent.com/stilleshan/frps/refs/heads/master/frps.toml"  #下载github代码文件，需打开代码，再点击 raw 获取文件链接

Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

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
INTERNAL_URL="http://10.22.51.64/5_Linux/${FILE_NAME}.tar.gz"
EXTERNAL_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}.tar.gz"


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

check_package() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "Installation directory '$INSTALL_PATH' already exists. Please uninstall $PACKAGE_NAME before proceeding!"
    elif which $PACKAGE_NAME &>/dev/null; then
        echo_log_error "$PACKAGE_NAME is already installed. Please uninstall it before installing the new version!"
    fi
}

download_package() {
    local PACKAGE_NAME=$1
    local DOWNLOAD_PATH=$2
    shift 2 

    for url in "$@"; do
        if check_url "$url"; then
            echo_log_info "Downloading $PACKAGE_NAME from $url ..."
            wget -P "$DOWNLOAD_PATH" "$url" &>/dev/null && {
                echo_log_info "Download $PACKAGE_NAME Success"
                return 0
            }
            echo_log_error "$url Download failed"
        else
            echo_log_warn "$url is invalid"
        fi
    done
    echo_log_error "All download links are invalid. Download failed!"
    return 1
}


manage_frp() {
    local action=$1         # install 或 uninstall
    local component=$2      # frps 或 frpc

    EXEC_FILE="/usr/local/frp/${component}"
    CONFIG_FILE="/usr/local/frp/${component}.toml"
    SERVICE_FILE="/lib/systemd/system/${component}.service"

    case $action in
        install)
            check_package
            echo_log_info "Start Installing $PACKAGE_NAME..."

            if [ -f "$DOWNLOAD_PATH/${FILE_NAME}.tar.gz" ]; then
                echo_log_info "The $PACKAGE_NAME source package already exists!"
            else
                echo_log_info "Start downloading the $PACKAGE_NAME source package..."
                download_package $PACKAGE_NAME $DOWNLOAD_PATH "$INTERNAL_URL" "$EXTERNAL_URL"
                [ $? -ne 0 ] && {
                    echo_log_error "Download $PACKAGE_NAME Failed!"
                    return 1
                }
            fi

            tar -xzf $DOWNLOAD_PATH/${FILE_NAME}.tar.gz -C $DOWNLOAD_PATH >/dev/null 2>&1
            [ $? -eq 0 ] && echo_log_info "Unarchive $PACKAGE_NAME Successfully!" || {
                echo_log_error "Unarchive $PACKAGE_NAME Failed!"
                return 1
            }

            mkdir -p /usr/local/frp && mv $DOWNLOAD_PATH/${FILE_NAME}/${component}* /usr/local/frp
            [ $? -eq 0 ] && echo_log_info "Move $PACKAGE_NAME Executable Successfully!" || {
                echo_log_error "Move $PACKAGE_NAME Executable Failed!"
                return 1
            }
    
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
            echo_log_info "Service file for $PACKAGE_NAME created successfully!"

            systemctl daemon-reload
            echo_log_info "Systemd reloaded. Please configure $CONFIG_FILE before starting the service."
            echo_log_warn  "先修改配置文件:vim $CONFIG_FILE"
            echo_log_warn  "然后启动服务:sudo systemctl start $component && sudo systemctl enable $component"

            rm -rf $DOWNLOAD_PATH/${FILE_NAME} $DOWNLOAD_PATH/${FILE_NAME}.tar.gz && echo_log_info "Cleaned up installation files."
            ;;

        uninstall)
            if [ -f "$INSTALL_PATH/$component" ]; then
                systemctl stop $component  && systemctl disable $component 2>/dev/null
                [ $? -eq 0 ] && echo_log_info "Stopped and disabled $PACKAGE_NAME service." || echo_log_warning "Service $PACKAGE_NAME was not running or not enabled."
                
                rm -rf $INSTALL_PATH && echo_log_info "Removed $INSTALL_PATH."
                rm -f $SERVICE_FILE && echo_log_info "Removed $SERVICE_FILE."
                [ $? -eq 0 ] && echo_log_info "Removed $SERVICE_FILE." || echo_log_warning "Failed to remove $SERVICE_FILE."
                echo_log_info "Uninstallation completed."
            else
                echo_log_error "$PACKAGE_NAME is not installed."
            fi
            ;;
        *)
            echo_log_error "Invalid action: $action. Use 'install' or 'uninstall'."
            return 1
            ;;
    esac
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${APACHE_VERSION} Install Tool\033[0m
———————————————————————————
1. Install frps-${FRP_VERSION}
2. Uninstall frps-${FRP_VERSION}
3. Install frpc-${FRP_VERSION}
4. Uninstall frpc-${FRP_VERSION}
5. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
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