#!/bin/bash



VERSION=2.54.1
PACKAGE_NAME=prometheus
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH=/data/$PACKAGE_NAME
PRO_TAR="$DOWNLOAD_PATH/$PACKAGE_NAME-${VERSION}.linux-amd64.tar.gz"
INTERNAL_URL="https://mirrors.sunline.cn/prometheus/linux/prometheus-2.54.1.linux-amd64.tar.gz"
EXTERNAL_URL="https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz"


HOST=`hostname -I|awk '{print $1}'`


. /etc/os-release

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

check_prometheus() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "安装目录 "$INSTALL_PATH" 已存在，请先卸载$PACKET_NAME！"
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


install_prometheus () {
    check_prometheus

    if [ -f "$DOWNLOAD_PATH/${PACKAGE_NAME}-${VERSION}.tar.gz" ]; then
        echo_log_info "$PACKAGE_NAME 的软件包已存在！"
    else
        echo_log_info "开始下载 $PACKAGE_NAME 的软件包..."
        download_package "$PACKAGE_NAME" "$DOWNLOAD_PATH"
    fi

    # 解压前确保目标目录存在
    mkdir -p /data/
    
    tar -zxvf $PRO_TAR -C /data/ >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Prometheus 解压完成" || { echo_log_error "Prometheus 解压失败"; exit 1; }

    # 检查解压后的文件夹名是否正确
    SOURCE_DIR=$(find /data/ -maxdepth 1 -type d -name "prometheus-${VERSION}.linux-amd64")
    if [ -z "$SOURCE_DIR" ]; then
        echo_log_error "未能找到解压后的Prometheus目录，请确认版本号或文件完整性"
    fi
    
    mv "$SOURCE_DIR" /data/prometheus || { echo_log_error "移动Prometheus目录失败"; exit 1; }
    
    cd $INSTALL_PATH && ln -s prometheus-${VERSION}.linux-amd64 prometheus
    mkdir -p $INSTALL_PATH/{bin,conf,data}

    # 检查用户是否存在，不存在则创建
    if ! id "prometheus" &>/dev/null; then
        useradd prometheus -s /sbin/nologin -M
    fi
    
    chown -R prometheus:prometheus $INSTALL_PATH

    # 确保相关文件存在再进行移动
    if [ -f "/data/prometheus/prometheus.yml" ]; then
        mv /data/prometheus/prometheus.yml $INSTALL_PATH/conf/prometheus.yml
    else
        echo_log_error "配置文件 /data/prometheus/prometheus.yml 不存在"
        exit 1
    fi

    if [ -f "/data/prometheus/prometheus" ]; then
        mv /data/prometheus/prometheus $INSTALL_PATH/bin/prometheus
    else
        echo_log_error "二进制文件 /data/prometheus/prometheus 不存在"
        exit 1
    fi

    if [ -f "/data/prometheus/promtool" ]; then
        mv /data/prometheus/promtool $INSTALL_PATH/bin/promtool
    else
        echo_log_error "工具文件 /data/prometheus/promtool 不存在"
        exit 1
    fi
    
    cat > /etc/profile.d/prometheus.sh <<EOF
export PROMETHEUS_HOME=${INSTALL_PATH}/prometheus
export PATH=\${PROMETHEUS_HOME}/bin:\$PATH
EOF

    cat > /lib/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
Restart=on-failure
User=prometheus
WorkingDirectory=${INSTALL_PATH}/prometheus
ExecStart=${INSTALL_PATH}/prometheus/bin/prometheus --config.file=${INSTALL_PATH}/prometheus/conf/prometheus.yml
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now prometheus.service
    echo_log_info "Prometheus 安装完成"
}


uninstall_prometheus () {
    if [ -d "${INSTALL_PATH}" ]; then
        echo_log_info "Prometheus 已安装，开始卸载..."
        rm -rf ${INSTALL_PATH}
        rm -rf /etc/profile.d/prometheus.sh
        echo_log_info "Prometheus 卸载成功"
        sed -i '/prometheus/d' /etc/profile.d/prometheus.sh
    fi
}


main() {
    clear
    echo -e "———————————————————————————
\033[32m Prometheus Install Tool\033[0m
———————————————————————————
1. Install Prometheus ${VERSION}
2. Uninstall Prometheus ${VERSION}
3. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) (install_prometheus) ;;
    2) (uninstall_prometheus) ;;
    3) (quit) ;;
    *) (main) ;;
    esac
}


main
