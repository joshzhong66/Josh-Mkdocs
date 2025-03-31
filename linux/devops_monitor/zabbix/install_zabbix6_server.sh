#!/bin/bash
#
#
# 源码包下载地址：https://cdn.zabbix.com/zabbix/sources
#
#https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.4.tar.gz

DEFAULT_VERSION="6.0.4"
PACKAGE_NAME="zabbix"
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH="/usr/local/zabbix"
SYSTEM_PATH="/etc/systemd/system/zabbix-server.service"

echo_log() {
    local color_code="$1"
    local log_level="$2"
    shift 2  # 移出颜色和日志级别参数

    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_prefix="${timestamp} -[\033[${color_code}m${log_level}\033[0m]"

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

# 检查系统是否安装jdk
check_jdk() {
    if command -v java &>/dev/null; then
        echo_log_info "Java 已安装"
    else
        echo_log_error "Java 未安装"
        return 1
    fi
}

# 检查系统是否安装mysql
check_mysql() { 
    if command -v mysql &>/dev/null; then
        echo_log_info "MySQL 已安装"

        CONFIG_FILE="/etc/my.cnf"

        # 定义要添加的配置项
        CONFIG_TO_ADD=(
            "character_set_server=utf8mb4"
            "collation-server=utf8mb4_bin"
            "validate_password.policy=LOW"
            "validate_password.length=8"
            "log_bin_trust_function_creators=1"
        )

        # 备份原始配置文件
        cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

        # 遍历配置项，检查是否存在，不存在则追加
        for config in "${CONFIG_TO_ADD[@]}"; do
            key=$(echo "$config" | cut -d= -f1)  # 提取键名
            if ! grep -q "^$key[[:space:]]*=" "$CONFIG_FILE"; then
                echo "$config" >> "$CONFIG_FILE"
                echo_log_info "已添加配置: $config"
            else
                echo_log_info "配置已存在: $config"
            fi
        done

    else
        echo_log_error "MySQL 未安装"
        return 1
    fi
}

check_gcc11() {
    if command -v gcc &>/dev/null; then
        GCC_VERSION=$(gcc -dumpversion | cut -d. -f1)
        if [ "$GCC_VERSION" -eq 11 ]; then
            echo_log_info "GCC 11 已安装"
            return 0
        else
            echo_log_warn "GCC 版本为 $GCC_VERSION，非 11"
            return 1
        fi
    else
        echo_log_warn "GCC 未安装"
        return 2
    fi
}




# 获取已安装的 Go 版本
check_go_version() {
    local REQUIRED_GO_VERSION="1.16"    #  需要的最低 Go 版本

    if ! command -v go &>/dev/null; then
        echo_log_error "Go 未安装"
    fi

    INSTALLED_GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    if [[ $(echo -e "$INSTALLED_GO_VERSION\n$REQUIRED_GO_VERSION" | sort -V | head -n1) == "$REQUIRED_GO_VERSION" ]]; then
        echo_log_info "Go 已安装，版本满足要求：$INSTALLED_GO_VERSION"
        return 0  # 0 代表符合要求
    else
        echo_log_error "Go 版本过低，当前版本：$INSTALLED_GO_VERSION，需升级至 $REQUIRED_GO_VERSION 或更高"
    fi
}


# 检查 fping 是否已安装，并获取版本号
check_fping_version() {
    local REQUIRED_FPING_VERSION="4.0"  # 需要的最低 fping 版本
    if ! command -v fping &>/dev/null; then
        echo_log_warn "fping 未安装"
        return 2  # 2 代表未安装
    fi

    INSTALLED_FPING_VERSION=$(fping -v 2>&1 | head -n1 | awk '{print $2}')
    
    if [[ $(echo -e "$INSTALLED_FPING_VERSION\n$REQUIRED_FPING_VERSION" | sort -V | head -n1) == "$REQUIRED_FPING_VERSION" ]]; then
        echo_log_info "fping 已安装，版本满足要求：$INSTALLED_FPING_VERSION ,可以继续安装 Zabbix"
        return 0  # 0 代表符合要求
    else
        echo_log_warn "fping 版本过低，当前版本：$INSTALLED_FPING_VERSION，需升级至 $REQUIRED_FPING_VERSION 或更高"
        return 1  # 1 代表版本过低
    fi
}



check_package() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "安装目录 '$INSTALL_PATH' 已存在. 请先卸载 $PACKAGE_NAME 然后再继续！"
    elif which $PACKAGE_NAME &>/dev/null; then
        echo_log_error "$PACKAGE_NAME 已安装。请在安装新版本之前将其卸载！"
    fi
}

# 检测&安装依赖函数
check_dependencies_packages() {
    local pkg_manager=$1  # 接收包管理器命令
    shift                 # 移除第一个参数，剩余为包列表
    local packages=("$@") # 所有包存入数组
    local installed=()    # 已安装的包
    local to_install=()   # 待安装的包

    # 检测已安装的包 (RPM系)
    for pkg in "${packages[@]}"; do
        if rpm -q "$pkg" &>/dev/null; then
            installed+=("$pkg")
        else
            to_install+=("$pkg")
        fi
    done

    # 显示已安装信息
    if [ ${#installed[@]} -gt 0 ]; then
        echo_log_info "已安装的包: ${installed[*]}"
    fi

    # 安装缺失的包
    if [ ${#to_install[@]} -gt 0 ]; then
        echo_log_info "正在安装: ${to_install[*]}"
        if ! $pkg_manager install -y "${to_install[@]}" >/dev/null; then
            echo_log_error "安装失败: ${to_install[*]}"
            return 1
        fi
        echo_log_info "安装完成: ${to_install[*]}"
    else
        echo_log_info "所有依赖已安装"
    fi
}

# 安装系统依赖
install_dependencies() {
    echo_log_info "检测系统环境，安装依赖..."
    
    # 加载系统信息
    if ! . /etc/os-release; then
        echo_log_error "无法获取系统信息"
        return 1
    fi

    echo_log_info "检测到系统ID：$ID"

    # 定义基础工具包
    local base_packages=(wget tar gzip curl openssl-devel libevent-devel libcurl-devel libxml2-devel net-snmp-devel 
    unixODBC-devel libssh-devel OpenIPMI-devel openldap-devel fping)

    case "$ID" in
        debian|ubuntu)
            echo_log_info "更新软件源..."
            if ! apt-get update >/dev/null; then
                echo_log_error "软件源更新失败"
                return 1
            fi
            check_dependencies_packages "DEBIAN_FRONTEND=noninteractive apt-get" "${base_packages[@]}"
            ;;
        centos|rhel|fedora|amzn)
            if command -v dnf >/dev/null; then
                check_dependencies_packages "dnf" "${base_packages[@]}"
            else
                check_dependencies_packages "yum" "${base_packages[@]}"
            fi
            ;;
        *)
            echo_log_error "不支持的发行版: $ID"
            return 1
            ;;
    esac
}


# 获取CHECKSUM_MAP值
get_expected_checksum() {
    local version=$1
    echo "Checking version: $version"

    local filename="${PACKAGE_NAME}-${version}.tar.gz"
    local checksum_url="https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-${version}.tar.gz.sha256"

    if ! tmpfile=$(mktemp); then
        echo "无法创建临时文件"
        return 2
    fi

    for i in {1..3}; do
        if curl -fsSL -o "$tmpfile" "$checksum_url"; then
            break
        elif [ $i -eq 3 ]; then
            echo "校验文件下载失败: $checksum_url"
            rm -f "$tmpfile"
            return 3
        fi
        sleep 2
    done

    local checksum
    checksum=$(awk '{print $1}' "$tmpfile")  # 直接获取校验值

    if [[ -z "$checksum" ]]; then
        echo "未找到 ${filename} 的校验码"
        rm -f "$tmpfile"
        return 4
    fi

    rm -f "$tmpfile"
    echo "SHA256校验值: $checksum"
}


download_package() {
    version=$1
    arch=$2
    tar_name="$PACKAGE_NAME-${version}.tar.gz"
    archive_dir="$PACKAGE_NAME-${version}"
    
    
    # 打印 version 以便调试
    echo_log_info "传递给 download_package 的版本号: ${version}"
    # 生成动态URL
    local internal_base="http://10.22.51.64/5_Linux/监控系统"
    local internal_url="${internal_base}/${tar_name}"
    local external_url="https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.4.tar.gz"

    # 动态获取校验码
    local expected_checksum
    if ! expected_checksum=$(get_expected_checksum "$DEFAULT_VERSION"); then
        return $?  # 传递错误代码
    fi

    # 下载逻辑
    echo_log_info "尝试下载安装包..."
    if check_url "$internal_url"; then
        echo_log_info "从内网下载: $internal_url"
        # 使用wget下载，失败后尝试curl
        if ! wget -q -O "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"; then
            echo_log_warn "wget下载失败，尝试使用curl..."
            if ! curl -sSL -o "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"; then
                echo_log_error "内网下载失败"
                return 3
            fi
        fi
    else
        echo_log_warn "内网不可达，尝试外网下载: $external_url"
        # 使用wget下载，失败后尝试curl
        if ! wget -q -O "${DOWNLOAD_PATH}/${tar_name}" "$external_url"; then
            echo_log_warn "wget下载失败，尝试使用curl..."
            if ! curl -sSL -o "${DOWNLOAD_PATH}/${tar_name}" "$external_url"; then
                echo_log_error "外网下载失败"
                return 4
            fi
        fi
    fi
    
    # 验证文件完整性
    local actual_checksum
    actual_checksum=$(sha256sum "${DOWNLOAD_PATH}/${tar_name}" | awk '{print $1}')
    if [[ "$actual_checksum" != "$expected_checksum" ]]; then
        echo_log_error "文件校验失败，预期: ${expected_checksum}，实际: ${actual_checksum}"
        return 5
    fi
}


install_zabbix_server() {
    local package_name="zabbix"
    local service_name="zabbix_server.service"
    local systemd_service_path="/etc/systemd/system/${service_name}"


    # 获取版本号
    read -rp "请输入 Zabbix 版本号（回车使用默认值 ${DEFAULT_VERSION}）：" version
    version=${version:-$DEFAULT_VERSION}
    version=${version#v}

    # 验证版本格式
    if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo_log_error "无效的版本格式，请使用数字格式如：1.8.1"
        return 1
    fi

    # 检测系统架构
    local arch
    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *)
            echo_log_error "不支持的架构: $(uname -m)"
            return 5
            ;;
    esac

    echo_log_info "正在安装 Zabbix Server v${version}..."

    # 安装依赖
    install_dependencies

    # 安装zabbix依赖
    check_jdk
    check_mysql
    check_gcc11
    check_go_version
    check_fping_version

    # 预检验证
    _precheck() {
        # 检查现有安装
        if [ -d "${INSTALL_PATH}" ]; then
            echo_log_warn "检测到已存在的安装目录: ${INSTALL_PATH}"
            read -rp "是否强制覆盖？(y/n) " force_install
            if [[ "${force_install}" != "y" ]]; then
                return 12
            fi

            # 停止旧服务
            if systemctl is-active --quiet "$service_name"; then
                echo_log_info "停止运行中的服务..."
                systemctl stop "$service_name" || {
                    echo_log_error "无法停止服务，请手动检查"
                    return 13
                }
            fi

            # 删除旧目录
            echo_log_info "清理旧安装目录..."
            rm -rf "${INSTALL_PATH}" || {
                echo_log_error "目录删除失败: ${INSTALL_PATH}"
                return 14
            }

            # 清理旧配置文件
            if [ -f "$systemd_service_path" ]; then
                rm -f "$systemd_service_path" || {
                    echo_log_error "服务文件删除失败: $systemd_service_path"
                    return 15
                }
            fi
        fi

        # 检查依赖命令
        local cmds=(tar curl systemctl)
        for cmd in "${cmds[@]}"; do
            if ! command -v "$cmd" >/dev/null; then
                echo_log_error "依赖命令缺失: $cmd"
                return 16
            fi
        done
    }

    # 解压 & 编译
    _setup_files() {
        # 解压文件
        if ! tar -zxf "${DOWNLOAD_PATH}/${tar_name}" -C "${DOWNLOAD_PATH}"; then
            echo_log_error "文件解压失败"
            return 15
        fi

        # 编译
        cd $archive_dir

        ./configure --prefix=/data/zabbix \
--enable-server \
--enable-agent \
--enable-agent2 \
--with-mysql \
--with-net-snmp \
--with-libcurl \
--with-libxml2 \
--with-unixodbc \
--enable-java \
--enable-ipv6 \
--with-openssl \
--with-openipmi \
--with-libpcre \
--with-libevent \
--with-iconv

        make -j $(nproc) && make install

        # 创建日志和告警目录
        mkdir -p /data/zabbix/{logs,alertscripts}

    }

    # 用户和权限管理
    _setup_permissions() {
        # 创建系统用户
        if ! id zabbix &>/dev/null; then
            if ! useradd -r -s /sbin/nologin zabbix; then
                echo_log_error "创建用户失败"
                return 18
            fi
            echo_log_info "已创建系统用户: zabbix"
        fi

        # 修改目录权限
        chown -R zabbix:zabbix /data/zabbix

        chown root:root /data/zabbix/bin/*
        chown root:root /data/zabbix/sbin/zabbix_agentd
        chown root:root /data/zabbix/sbin/zabbix_agent2
        chown root:root /data/zabbix/sbin/zabbix_server

        # 配置PSK共享密钥
        cat > /data/zabbix/etc/zabbix_agentd.psk << EOF
#!/bin/bash
cat << EOF > /data/zabbix/etc/zabbix_agentd.psk
f03a84aa7cc6ea8c13d9e01f2a704705bad15fd26a535dd8bf322c3b5c38d493
EOF

        chown zabbix:zabbix zabbix_agentd.psk
        chmod 600 zabbix_agentd.psk

        echo_log_info "PSK共享密钥已配置完成"

        
        ln -s /usr/local/sbin/fping /usr/sbin/fping
        chown root:zabbix /usr/local/sbin/fping
        chmod 6755 /usr/local/sbin/fping
        echo_log_info "fping已配置完成"


    }

    _setup_permissions() {

        cd /data/zabbix/etc
        sed -i 's@LogFile=/tmp/zabbix_server.log@LogFile=/data/zabbix/logs/zabbix_server.log@g' zabbix_server.conf
        sed -i 's@# PidFile=/tmp/zabbix_server.pid@PidFile=/tmp/zabbix_server.pid@g' zabbix_server.conf
        sed -i 's@# DBHost=localhost@DBHost=localhost@g' zabbix_server.conf
        sed -i 's@# DBPassword=@DBPassword=Zabbix2025@g' zabbix_server.conf
        sed -i 's@# DBSocket=@DBSocket=/data/mysql/sock/mysql.sock@g' zabbix_server.conf
        sed -i 's@# DBPort=@DBPort=3306@g' zabbix_server.conf
        sed -i '/# AlertScriptsPath=${datadir}\/zabbix\/alertscripts/a AlertScriptsPath=/data/zabbix/alertscripts' zabbix_server.conf

    }
    ##############################
    ### 主流程开始 ###
    ##############################
    echo_log_header "开始安装 ${package_name} ${version}"

    # 步骤执行链
    local rc=0
    _precheck || rc=$?
    [ $rc -eq 0 ] && download_package "$version" "$arch" || rc=$?
    # [ $rc -eq 0 ] && _setup_files || rc=$?
    # [ $rc -eq 0 ] && _setup_permissions || rc=$?
    # [ $rc -eq 0 ] && _setup_environment || rc=$?
    # [ $rc -eq 0 ] && _setup_service || rc=$?
    # [ $rc -eq 0 ] && _postcheck || rc=$?

}


install_zabbix_server