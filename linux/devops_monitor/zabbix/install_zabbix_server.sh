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
VER_URL=https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.4.tar.gz

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
                echo_log_info "Mysql my.cnf 配置已存在: $config"
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
            echo_log_error "GCC 版本为 $GCC_VERSION，非 11"
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
        echo_log_error "fping 未安装"
        return 2  # 2 代表未安装
    fi

    INSTALLED_FPING_VERSION=$(fping -v 2>&1 | head -n1 | awk '{print $2}')
    
    if [[ $(echo -e "$INSTALLED_FPING_VERSION\n$REQUIRED_FPING_VERSION" | sort -V | head -n1) == "$REQUIRED_FPING_VERSION" ]]; then
        echo_log_info "fping 已安装，版本满足要求：$INSTALLED_FPING_VERSION ,可以继续安装 Zabbix"
        return 0  # 0 代表符合要求
    else
        echo_log_error "fping 版本过低，当前版本：$INSTALLED_FPING_VERSION，需升级至 $REQUIRED_FPING_VERSION 或更高"
        return 1  # 1 代表版本过低
    fi
}


# 获取已安装的 Apache 版本
check_apache_version() {
    local REQUIRED_APACHE_VERSION="2.4"    # 需要的最低 Apache 版本

    # 检测 apache2 或 httpd 命令是否存在
    if ! { command -v apache2 &>/dev/null || command -v httpd &>/dev/null; }; then
        echo_log_error "Apache 未安装"
        return 1
    fi

    # 获取 Apache 版本（兼容不同发行版）
    local INSTALLED_APACHE_VERSION
    if command -v apache2 &>/dev/null; then
        INSTALLED_APACHE_VERSION=$(apache2 -v | grep -oP 'Apache/\K[\d.]+' | head -n1)
    else
        INSTALLED_APACHE_VERSION=$(httpd -v | grep -oP 'Apache/\K[\d.]+' | head -n1)
    fi

    # 版本比较
    if [[ $(echo -e "$INSTALLED_APACHE_VERSION\n$REQUIRED_APACHE_VERSION" | sort -V | head -n1) == "$REQUIRED_APACHE_VERSION" ]]; then
        echo_log_info "Apache 已安装，版本满足要求：$INSTALLED_APACHE_VERSION"
        return 0
    else
        echo_log_error "Apache 版本过低，当前版本：$INSTALLED_APACHE_VERSION，需升级至 $REQUIRED_APACHE_VERSION 或更高"
        return 1
    fi
}

# 获取已安装的 PHP 版本
check_php_version() {
    local REQUIRED_PHP_VERSION="7.4"    # 需要的最低 PHP 版本

    if ! command -v php &>/dev/null; then
        echo_log_error "PHP 未安装"
        return 1
    fi

    # 获取 PHP 版本并移除后缀（如 -ubuntu）
    local INSTALLED_PHP_VERSION
    INSTALLED_PHP_VERSION=$(php -v | head -n1 | awk '{print $2}' | cut -d'-' -f1)

    if [[ $(echo -e "$INSTALLED_PHP_VERSION\n$REQUIRED_PHP_VERSION" | sort -V | head -n1) == "$REQUIRED_PHP_VERSION" ]]; then
        echo_log_info "PHP 已安装，版本满足要求：$INSTALLED_PHP_VERSION"
        return 0
    else
        echo_log_error "PHP 版本过低，当前版本：$INSTALLED_PHP_VERSION，需升级至 $REQUIRED_PHP_VERSION 或更高"
        return 1
    fi
}


check_version_exists() {
    local version=$1
    echo_log_info "正在验证版本 v${version} 是否存在..."
    
    # 检查GitHub Release标签
    if ! curl -sSLI -o /dev/null -w "%{http_code}" $VER_URL | grep -q 200; then
        echo_log_error "版本 v${version} 不存在于官方仓库"
        return 2
    fi
    echo_log_info "版本 v${version} 存在于官方仓库"
}


# 获取CHECKSUM_MAP值
get_expected_checksum() {
    local version=$1
    local checksum_url="https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-${version}.tar.gz.sha256"

    if ! tmpfile=$(mktemp); then
        echo_log_error "无法创建临时文件"
        return 2
    fi

    for i in {1..3}; do
        if curl -fsSL -o "$tmpfile" "$checksum_url"; then
            break
        elif [ $i -eq 3 ]; then
            echo_log_error "校验文件下载失败: $checksum_url"
            rm -f "$tmpfile"
            return 3
        fi
        sleep 2
    done

    local checksum
    checksum=$(awk '{print $1}' "$tmpfile")  # 直接获取校验值
    rm -f "$tmpfile"

    if [[ -z "$checksum" ]]; then
        echo_log_error "未找到 ${PACKAGE_NAME}-${version}.tar.gz 的校验码"
        return 4
    fi

    echo "$checksum"  # 只返回校验值
    return 0
}


download_package() {
    version=$1
    tar_name="$PACKAGE_NAME-${version}.tar.gz"
    
    echo_log_info "传递给 download_package 的版本号: ${version}"

    local internal_base="http://10.22.51.64/5_Linux/监控系统"
    local internal_url="${internal_base}/${tar_name}"
    local external_url="https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-${version}.tar.gz"

    if [[ -z "$version" ]]; then
       echo_log_error "版本号为空，无法进行验证"
       return 1
    fi

    check_version_exists "$DEFAULT_VERSION" || return $?

    # 获取 SHA256 校验值
    expected_checksum=$(get_expected_checksum "$DEFAULT_VERSION")
    if [[ $? -ne 0 || -z "$expected_checksum" ]]; then
        echo_log_error "无法获取 SHA256 校验值"
        return 6
    fi

    echo_log_info "SHA256 预期校验值: $expected_checksum"

    # 下载逻辑
    #echo_log_info "尝试下载安装包..."
    if [ ! -f "$DOWNLOAD_PATH/$tar_name" ]; then 
        if check_url "$internal_url"; then
            echo_log_info "从内网下载: $internal_url"
            if ! wget -q -O "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"; then
                echo_log_warn "wget下载失败，尝试使用curl..."
                if ! curl -sSL -o "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"; then
                    echo_log_error "内网下载失败"
                    return 3
                fi
            fi
        else
            echo_log_warn "内网不可达，尝试外网下载: $external_url"
            if ! wget -q -O "${DOWNLOAD_PATH}/${tar_name}" "$external_url"; then
                echo_log_warn "wget下载失败，尝试使用curl..."
                if ! curl -sSL -o "${DOWNLOAD_PATH}/${tar_name}" "$external_url"; then
                    echo_log_error "外网下载失败"
                    return 4
                fi
            fi
        fi
    else
        echo_log_info "$tar_name 已存在，跳过下载"
    fi

    # 验证文件完整性
    local actual_checksum
    actual_checksum=$(sha256sum "${DOWNLOAD_PATH}/${tar_name}" | awk '{print $1}')
    echo_log_info "正在验证文件 ${tar_name} 完整性..."
    if [[ "$actual_checksum" != "$expected_checksum" ]]; then
        echo_log_error "文件校验失败，预期: ${expected_checksum}，实际: ${actual_checksum}"
        return 5
    else
        echo_log_success "文件校验通过，校验值: ${actual_checksum}"
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

    echo_log_info "正在安装 Zabbix Server v${version}..."

    # 安装依赖
    install_dependencies

    # 安装zabbix依赖
    check_jdk
    check_mysql
    check_gcc11
    check_go_version
    check_fping_version
    check_apache_version
    check_php_version

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
            return 17
        fi

        # 编译
        cd $DOWNLOAD_PATH/$PACKAGE_NAME-$version
        if ./configure --prefix=/data/zabbix \
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
--with-iconv >/dev/null 2>/tmp/configure_error.log
        then
            echo_log_success "./configure 编译成功"
        else
            echo_log_error "configure 编译失败，请检查依赖项是否安装完整"
            echo "错误日志详见: /tmp/configure_error.log" >&2
            cat /tmp/configure_error.log | grep -iE 'error|warning' >&2
            return 18
        fi


        MAKE_LOG="/tmp/make_error.log"
        INSTALL_LOG="/tmp/make_install_err.log"

        # 编译阶段（限制最大8线程防止内存不足）
        if make -j $(( $(nproc) > 8 ? 8 : $(nproc) )) >/dev/null 2>"${MAKE_LOG}"; then
            echo_log_success "make 编译成功"
        else
            echo_log_error "make 失败，关键错误："
            grep -m3 -i 'error:' "${MAKE_LOG}" | sed 's/^/    /' >&2
            echo "完整日志请查看: ${MAKE_LOG}" >&2
            return 19
        fi

        # 安装阶段（增加权限预检）
        if [ -w "/data/zabbix" ]; then
            if make install >/dev/null 2>"${INSTALL_LOG}"; then
                echo_log_success "Zabbix 安装成功"
            else
                echo_log_error "make install 失败，最后一条错误："
                tail -n1 "${INSTALL_LOG}" | sed 's/^/    /' >&2
                echo "建议检查磁盘空间 (df -h)" >&2
                return 20
            fi
        else
            echo_log_error "安装目录不可写: /data/zabbix"
            return 20
        fi

        # 创建日志和告警目录
        if [ ! -d "/data/zabbix/logs" ] || [ ! -d "/data/zabbix/alertscripts" ]; then
            echo_log_info "创建 /data/zabbix/logs 和 /data/zabbix/alertscripts 目录..."
            mkdir -p /data/zabbix/{logs,alertscripts} && echo_log_success "目录创建成功"
        else
            echo_log_info "目录已存在，跳过创建"
        fi
    }

    # 用户和权限管理
    _setup_permissions() {
        # 创建系统用户
        if ! id zabbix &>/dev/null; then
            echo_log_info "正在创建系统用户: zabbix"
            if ! useradd -r -s /sbin/nologin zabbix; then
                echo_log_error "创建用户失败"
                return 18
            fi
            echo_log_success "已创建系统用户: zabbix"
        fi

        # 修改目录权限
        if [ -d "/data/zabbix" ]; then
            echo_log_info "正在修改 /data/zabbix 目录权限..."
            if ! chown -R zabbix:zabbix /data/zabbix; then
                echo_log_error "目录权限修改失败"
                return 19
            fi
            echo_log_success "目录权限修改完成"
        else
            echo_log_warn "/data/zabbix 目录不存在，跳过权限修改"
        fi

        # 修改二进制文件权限
        echo_log_info "正在配置二进制文件权限..."
        for bin in /data/zabbix/bin/*; do
            if [ -f "$bin" ]; then
                if ! chown root:root "$bin"; then
                    echo_log_error "无法设置 $bin 的所有者"
                    return 20
                fi
            fi
        done

        for sbin in /data/zabbix/sbin/zabbix_agentd /data/zabbix/sbin/zabbix_agent2 /data/zabbix/sbin/zabbix_server; do
            if [ -f "$sbin" ]; then
                if ! chown root:root "$sbin"; then
                    echo_log_error "无法设置 $sbin 的所有者"
                    return 21
                fi
            fi
        done
        echo_log_success "二进制文件权限配置完成"

        # 配置 PSK 共享密钥
        PSK_FILE="/data/zabbix/etc/zabbix_agentd.psk"
        if [ ! -f "$PSK_FILE" ]; then
            echo_log_info "正在生成 PSK 共享密钥..."
            if ! cat << EOF > "$PSK_FILE"; then
f03a84aa7cc6ea8c13d9e01f2a704705bad15fd26a535dd8bf322c3b5c38d493
EOF
                echo_log_error "PSK 文件创建失败"
                return 22
            fi
            if ! chown zabbix:zabbix "$PSK_FILE"; then
                echo_log_error "PSK 文件所有者修改失败"
                return 23
            fi
            if ! chmod 600 "$PSK_FILE"; then
                echo_log_error "PSK 文件权限修改失败"
                return 24
            fi
            echo_log_success "PSK 共享密钥配置完成"
        else
            echo_log_info "PSK 共享密钥已存在，跳过创建"
        fi

        # 配置 fping
        FPING_SRC="/usr/local/sbin/fping"
        FPING_DEST="/usr/sbin/fping"
        
        if [ ! -L "$FPING_DEST" ]; then
            echo_log_info "正在创建 fping 软链接..."
            if ! ln -s "$FPING_SRC" "$FPING_DEST"; then
                echo_log_error "软链接创建失败"
                return 25
            fi
            echo_log_success "fping 软链接已创建"
        else
            echo_log_info "fping 软链接已存在，跳过创建"
        fi

        if [ -f "$FPING_SRC" ]; then
            echo_log_info "正在设置 fping 权限..."
            if ! chown root:zabbix "$FPING_SRC"; then
                echo_log_error "无法修改 fping 所有者"
                return 26
            fi
            if ! chmod 6755 "$FPING_SRC"; then
                echo_log_error "无法设置 fping 权限"
                return 27
            fi
            echo_log_success "fping 权限配置完成"
        else
            echo_log_warn "$FPING_SRC 不存在，跳过 fping 配置"
        fi

        echo_log_success "所有权限配置已完成"
    }

    _setup_configure() {
        local conf_dir="/data/zabbix/etc"
        local server_conf="${conf_dir}/zabbix_server.conf"
        local agent_conf="${conf_dir}/zabbix_agentd.conf"
        local db_password="Zabbix2025"  # 建议改为从外部变量读取

        # 进入配置目录
        if ! cd "$conf_dir" 2>/dev/null; then
            echo_log_error "配置目录不存在: $conf_dir"
            return 31
        fi

        _apply_server_config() {
            # 使用数组定义替换规则
            local server_rules=(
                's@LogFile=/tmp/zabbix_server.log@LogFile=/data/zabbix/logs/zabbix_server.log@'
                's@# PidFile=/tmp/zabbix_server.pid@PidFile=/tmp/zabbix_server.pid@'
                's@# DBHost=localhost@DBHost=localhost@'
                "s@# DBPassword=@DBPassword=${db_password}@"
                's@# DBSocket=@DBSocket=/data/mysql/sock/mysql.sock@'
                's@# DBPort=@DBPort=3306@'
                '/# AlertScriptsPath=${datadir}\/zabbix\/alertscripts/a AlertScriptsPath=/data/zabbix/alertscripts'
            )

            # 批量应用配置规则
            for rule in "${server_rules[@]}"; do
                if ! sed -i "$rule" "$server_conf"; then
                    echo_log_error "配置失败: $rule"
                    return 1
                fi
            done
        }

        # 配置 Zabbix Server
        echo_log_info "正在配置 Zabbix Server..."
        if ! _apply_server_config; then
            echo_log_error "Zabbix Server 配置失败"
            return 32
        fi
        echo_log_success "Zabbix Server 配置完成"

        _apply_agent_config() {
        # 使用关联数组定义配置项
        local -A agent_configs=(
            ["PidFile"]="s@# PidFile=/tmp/zabbix_agentd.pid@PidFile=/tmp/zabbix_agentd.pid@"
            ["LogFile"]="s@LogFile=/tmp/zabbix_agentd.log@LogFile=/data/zabbix/logs/zabbix_agentd.log@"
            ["AllowRoot"]="s@# AllowRoot=0@AllowRoot=1@"
            ["IncludePath"]="/# Include=\/usr\/local\/etc\/zabbix_agentd.conf.d\/\*\.conf/a Include=\/data\/zabbix\/etc\/zabbix_agentd.conf.d\/\*\.conf"
            ["UnsafeParams"]="s@# UnsafeUserParameters=0@UnsafeUserParameters=1@"
            ["TLSConnect"]="s@# TLSConnect=unencrypted@TLSConnect=psk@"
            ["TLSAccept"]="s@# TLSAccept=unencrypted@TLSAccept=psk@"
            ["TLSIdentity"]="s@# TLSPSKIdentity=@TLSPSKIdentity=psk01@"
            ["TLSPSKFile"]="s@# TLSPSKFile=@TLSPSKFile=/data/zabbix/etc/zabbix_agentd.psk@"
        )

        # 按顺序应用配置
        for key in PidFile LogFile AllowRoot IncludePath UnsafeParams TLSConnect TLSAccept TLSIdentity TLSPSKFile; do
            if ! sed -i "${agent_configs[$key]}" "$agent_conf"; then
                echo_log_error "Agent 配置失败: $key"
                return 1
            fi
        done
    }

        # 配置 Zabbix Agent
        echo_log_info "正在配置 Zabbix Agent..."
        if ! _apply_agent_config; then
            echo_log_error "Zabbix Agent 配置失败"
            return 33
        fi
        echo_log_success "Zabbix Agent 配置完成"


        _validate_configs() {
            echo_log_info "正在验证配置文件..."
            
            # 检查 Server 配置
            if ! grep -q "LogFile=/data/zabbix/logs/zabbix_server.log" "$server_conf"; then
                echo_log_error "Server 日志路径配置失败"
                return 1
            fi

            # 检查 Agent PSK 配置
            if ! grep -q "TLSPSKFile=/data/zabbix/etc/zabbix_agentd.psk" "$agent_conf"; then
                echo_log_error "Agent PSK 配置缺失"
                return 1
            fi

            # 检查数据库连接配置
            if ! awk '/^DBHost=localhost/ && /^DBPassword=/ && /^DBSocket=\/data\/mysql\/sock\/mysql.sock/' "$server_conf" >/dev/null; then
                echo_log_error "数据库连接配置不完整"
                return 1
            fi

            echo_log_success "配置文件验证通过"
        }

        # 验证配置文件语法
        if ! _validate_configs; then
            return 34
        fi
    }


    ##############################
    ### 主流程开始 ###
    ##############################
    echo_log_header "开始安装 ${package_name} ${version}"

    # 步骤执行链
    local rc=0
    _precheck || rc=$?
    [ $rc -eq 0 ] && download_package "$DEFAULT_VERSION" || rc=$?
    [ $rc -eq 0 ] && _setup_files || rc=$?
    [ $rc -eq 0 ] && _setup_permissions || rc=$?
    [ $rc -eq 0 ] && _setup_configure || rc=$?

    # [ $rc -eq 0 ] && _setup_environment || rc=$?
    # [ $rc -eq 0 ] && _setup_service || rc=$?
    # [ $rc -eq 0 ] && _postcheck || rc=$?


}


install_zabbix_server
