#!/bin/bash

#
# 官方frp下载链接：https://github.com/fatedier/frp/releases/download/v0.61.1/frp_0.61.1_linux_amd64.tar.gz
# frps.toml下载链接：https://github.com/stilleshan/frps/blob/master/frps.toml

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
FRPS_CONFIG="https://github.com/stilleshan/frps/blob/master/frps.toml"

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


install_frps() {
    check_package

    echo_log_info "Start Install Rely Package..."

    if [ -f "$DOWNLOAD_PATH/${FILE_NAME}.tar.gz" ]; then
        echo_log_info "The $PACKAGE_NAME source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package $PACKAGE_NAME $DOWNLOAD_PATH "$INTERNAL_URL" "$EXTERNAL_URL"
    fi

    tar -xzf $DOWNLOAD_PATH/${FILE_NAME}.tar.gz -C $DOWNLOAD_PATH >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Unarchive $PACKAGE_NAME Successfully!" || echo_log_error "Unarchive $PACKAGE_NAME Failed!"

    mkdir -p $INSTALL_PATH && cd $DOWNLOAD_PATH/${FILE_NAME}
    mv $DOWNLOAD_PATH/${FILE_NAME}/frps* $INSTALL_PATH

    # download_package $PACKAGE_NAME $DOWNLOAD_PATH "$FRPS_CONFIG"
    # [ $? -eq 0 ] && {
    #     echo_log_info "Download $PACKAGE_NAME Configuration Successfully!"
    #     mv $DOWNLOAD_PATH/frps.toml $INSTALL_PATH/frps.toml
    # } || {
    #     echo_log_error "Download $PACKAGE_NAME Configuration Failed!"
    # }

    cat >/lib/systemd/system/frps.service <<'EOF'
[Unit]
Description=Frp Server Service
After=network.target syslog.target
Wants=network.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.toml

[Install]
WantedBy=multi-user.target

EOF

    systemctl daemon-reload
    [  $? -eq 0 ] && echo_log_info "Install $PACKAGE_NAME Successfully!" || echo_log_error "Install $PACKAGE_NAME Failed!"
    #systemctl start frps && systemctl enable frps >/dev/null 2>&1
    #[ $? -eq 0 ] && echo_log_info "Start $PACKAGE_NAME Successfully!" || echo_log_error "Start $PACKAGE_NAME Failed!"]

    rm -rf $DOWNLOAD_PATH/${FILE_NAME}.tar.gz

    echo -e "${Green}====================================================================${Font}"
    echo -e "${Green}安装成功,请先修改 frps.toml 文件,确保格式及配置正确无误!${Font}"
    echo -e "${Red}vi /usr/local/frp/frps.toml${Font}"
    echo -e "${Green}修改完毕后执行以下命令重启服务:${Font}"
    echo -e "${Red}sudo systemctl restart frps ${Font}"
    echo -e "${Green}====================================================================${Font}"
}


uninstall_frps() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_info "Uninstall $PACKAGE_NAME ..."
        systemctl stop frps && systemctl disable frps >/dev/null 2>&1
        rm -rf $INSTALL_PATH && rm -rf /lib/systemd/system/frps.service
        echo_log_info "Uninstall $PACKAGE_NAME Successfully!"
    else
        echo_log_error "$PACKAGE_NAME is not installed. Please install it before uninstalling!"
    fi
}



main() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${APACHE_VERSION} Install Tool\033[0m
———————————————————————————
1. Install frps${FRP_VERSION}
2. Uninstall frps${FRP_VERSION}
3. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) install_frps ;;
    2) uninstall_frps ;;
    3) quit ;;

    *) main ;;
    esac
}


main