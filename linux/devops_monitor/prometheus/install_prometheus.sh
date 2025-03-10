#!/bin/bash
#
#
# 官方下载地址：https://github.com/prometheus/prometheus/releases
#
#
# ubuntu使用               bash ./脚本名.sh
# centos使用sh或bash都行   ./脚本名.sh

# 定义全局变量
DEFAULT_VERSION="2.51.2"
PACKAGE_NAME="prometheus"
INSTALL_PATH="/usr/local/prometheus"
DOWNLOAD_PATH="/usr/local/src"
SYSTEMD_PATH="/etc/systemd/system/prometheus.service"
ENV_FILE="/etc/profile.d/prometheus.sh"


# 通用日志函数
echo_log() {
    local color_code="$1"
    local log_level="$2"
    shift 2  # 移出颜色和日志级别参数

    # 组装带颜色的日志前缀
    local timestamp
    timestamp=$(date +'%F %T')
    local log_prefix="${timestamp} -[\033[${color_code}m${log_level}\033[0m]"

    # 输出带格式的日志
    echo -e "${log_prefix} $*"
}

# 信息日志（绿色）
echo_log_info() {
    echo_log "32" "INFO" "$@"
}

# 警告日志（黄色）
echo_log_warn() {
    echo_log "33" "WARN" "$@"
}

# 错误日志（红色）
echo_log_error() {
    echo_log "31" "ERROR" "$@"
    exit 1  # 可根据需要决定是否退出
}

# 成功日志（绿色加粗）
echo_log_success() {
    echo_log "1;32" "SUCCESS" "$@"
}

# 标题日志（蓝色加粗）
echo_log_header() {
    echo_log "1;34" "HEADER" "$@"
}

check_url() {
    local url=$1
    if curl -f -s --connect-timeout 5 "$url" &>/dev/null; then  # 使用curl检查URL，超时5秒
        return 0  # URL可用
    else
        return 1  # URL不可用
    fi
}

# 检查安装包
check_package() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "安装目录 '$INSTALL_PATH' 已存在，请先卸载！"
    elif which $PACKAGE_NAME &>/dev/null; then
        echo_log_error "$PACKAGE_NAME 已安装，请先卸载！"
    fi
}

# 安装系统依赖
install_dependencies() {
    echo_log_info "检测系统环境，安装依赖..."
    source /etc/os-release
    
    # 安装基础工具
    case "$ID" in
        debian|ubuntu)
            apt-get update >/dev/null
            DEBIAN_FRONTEND=noninteractive apt-get install -y wget tar gzip curl
            ;;
        centos|rhel|fedora|amzn)
            if command -v dnf >/dev/null; then
                dnf install -y wget tar gzip curl >/dev/null 2>&1
            else
                yum install -y wget tar gzip curl >/dev/null 2>&1
            fi
            ;;
        *)
            echo_log_error "不支持的发行版: $ID"
            return 1
            ;;
    esac
}


# 获取校验码
get_expected_checksum() {
    local version=$1
    local arch=$2
    local filename="prometheus-${version}.linux-${arch}.tar.gz"
    
    local checksum_url="https://github.com/prometheus/prometheus/releases/download/v${version}/sha256sums.txt"
    local tmpfile=$(mktemp)
    
    # 下载校验文件（带重试）
    for i in {1..3}; do
        if curl -fsSL -o "$tmpfile" "$checksum_url"; then
            break
        elif [ $i -eq 3 ]; then
            echo_log_error "校验文件下载失败"
            return 3
        fi
        sleep 2
    done

    # 提取校验码
    local checksum=$(grep -F "$filename" "$tmpfile" | awk '{print $1}')
    rm -f "$tmpfile"
    [ -z "$checksum" ] && echo_log_error "校验码提取失败"
    echo "$checksum"
}

# 下载安装包
download_package() {
    local version=$1
    local arch=$2
    local tar_name="prometheus-${version}.linux-${arch}.tar.gz"
    local archive_dir="prometheus-${version}.linux-${arch}"

    if [ ! -f "${DOWNLOAD_PATH}/$tar_name" ]; then
        echo_log_info "下载安装包: ${tar_name}"
        curl -fsSL -o "${DOWNLOAD_PATH}/${tar_name}" "https://github.com/prometheus/prometheus/releases/download/v${version}/${tar_name}"
    else
        echo_log_info "使用本地安装包: ${tar_name}"
        return 0
    fi
     
    # 动态URL配置
    local internal_base="http://10.22.51.64/5_Linux/监控系统"
    local internal_url="${internal_base}/${tar_name}"
    local external_url="https://github.com/prometheus/prometheus/releases/download/v${version}/${tar_name}"

    # 校验码验证
    local expected_checksum=$(get_expected_checksum "$version" "$arch")
    
    # 下载逻辑
    echo_log_info "尝试下载安装包..."
    if curl -sSf --connect-timeout 5 "$internal_url" &>/dev/null; then
        echo_log_info "从内网下载: $internal_url"
        curl -fsSL -o "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"
    else
        echo_log_warn "内网不可达，尝试外网下载"
        curl -fsSL -o "${DOWNLOAD_PATH}/${tar_name}" "$external_url"
    fi

    # 完整性校验
    local actual_checksum=$(sha256sum "${DOWNLOAD_PATH}/${tar_name}" | awk '{print $1}')
    [ "$actual_checksum" != "$expected_checksum" ] && \
        echo_log_error "文件校验失败，预期: ${expected_checksum}，实际: ${actual_checksum}"
}

# 安装主函数
install_prometheus() {
    local version=${1:-$DEFAULT_VERSION}
    version=${version#v}

    install_dependencies
    # 架构检测
    case "$(uname -m)" in
        x86_64)  arch="amd64";;
        aarch64) arch="arm64";;
        *) echo_log_error "不支持的架构";;
    esac

    local archive_dir="prometheus-${version}.linux-${arch}"
    # 预检
    if [ -d "$INSTALL_PATH" ]; then
        read -rp "检测到已安装，是否覆盖？(y/n) " ans
        [[ "$ans" != "y" ]] && exit 1
        systemctl stop prometheus 2>/dev/null
        rm -rf "$INSTALL_PATH"
    fi

    # 安装流程
    echo_log_header "开始安装 Prometheus v${version}"
    
    download_package "$version" "$arch"
    
    # 解压文件
    tar -zxf "${DOWNLOAD_PATH}/prometheus-${version}.linux-${arch}.tar.gz" -C "$DOWNLOAD_PATH"
    mkdir -p "$INSTALL_PATH"
    # 移动文件（保留原始权限）
    #mv -rp "${DOWNLOAD_PATH}/${archive_dir}/"* /usr/local/
    if ! cp -rp "${DOWNLOAD_PATH}/${archive_dir}/"* "${INSTALL_PATH}"; then
        echo_log_error "文件移动失败"
        return 17
    fi

    # 创建系统用户
    id prometheus &>/dev/null || useradd -r -s /sbin/nologin prometheus
    chown -R prometheus:prometheus "$INSTALL_PATH"

    # 配置systemd服务
    cat > $SYSTEMD_PATH <<EOF
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
User=prometheus
Group=prometheus
ExecStart=$INSTALL_PATH/prometheus \\
  --config.file=$INSTALL_PATH/prometheus.yml \\
  --storage.tsdb.path=$INSTALL_PATH/data \\
  --web.listen-address=:9090
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    # 启动服务
    systemctl daemon-reload
    systemctl enable --now prometheus >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_success "服务启动成功" || echo_log_error "服务启动失败"
    sleep 2

    # 验证安装
    if ! systemctl is-active prometheus &>/dev/null; then
        echo_log_error "服务启动失败"
    fi

    local ip=$(hostname -I | awk '{print $1}')
    echo_log_success "安装完成，访问地址：http://${ip}:9090"
}

# 卸载函数
uninstall_prometheus() {
    systemctl stop prometheus 2>/dev/null
    systemctl disable prometheus 2>/dev/null
    rm -f "$SYSTEMD_PATH"
    userdel prometheus 2>/dev/null
    rm -rf "$INSTALL_PATH"
    rm -rf "${DOWNLOAD_PATH}/prometheus-${version}.linux-${arch}"
    echo_log_success "Prometheus 已卸载"
}

# 主菜单
main() {
    clear
    echo  "\033[1;34m╔════════════════════════════════════════════╗
║ \033[1;37mPrometheus 管理脚本 v1.0 \033[1;34m                  ║
╠════════════════════════════════════════════╣
║ \033[1;33m1. 安装 Prometheus\033[1;34m                         ║
║ \033[1;33m2. 卸载 Prometheus\033[1;34m                         ║
║ \033[1;33m3. 退出\033[1;34m                                    ║
╚════════════════════════════════════════════╝\033[0m"

    read -p "请输入选项 (1-3): " choice
    case $choice in
        1) install_prometheus ;;
        2) uninstall_prometheus ;;
        3) exit 0;;
        *) echo -e "\033[31m无效输入\033[0m"; sleep 1; main;;
    esac
}

main