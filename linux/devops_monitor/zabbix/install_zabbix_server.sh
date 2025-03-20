#!/bin/bash
#
#
# 源码包下载地址：https://cdn.zabbix.com/zabbix/sources
#                https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.4.tar.gz
#
#
#
# 问题：
#1.return 那么多返回值的含义？
#2.server如启动存在问题，检查DBSocket=@DBSocket=/data/mysql/mysql/tmp/mysql.sock与Mysql是否一致

DEFAULT_VERSION="6.0.4"
PACKAGE_NAME="zabbix"
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH="/usr/local/zabbix"
SYSTEM_PATH="/etc/systemd/system/zabbix-server.service"
VER_URL=https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.4.tar.gz

# 定义mysql变量
MYSQL_ROOT_USER="root"
MYSQL_ROOT_PWD="Sunline2024"
ZABBIX_DB_USER="zabbix"
ZABBIX_DB_PWD="Zabbix2025"
SQL_BASE_DIR="/usr/local/src/zabbix-${DEFAULT_VERSION}/database/mysql"
REQUIRED_SQL_FILES=("schema.sql" "images.sql" "data.sql")
SERVICE_FILES_DIR="/usr/local/src/zabbix-${DEFAULT_VERSION}/misc/init.d/fedora/core5"

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
        openEuler)
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

        # 备份原始配置文件
        cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

        # 定义要添加的配置项
        cat > $CONFIG_FILE <<EOF
[mysql]
default-character-set=utf8

[mysqld]
server_id = 1
user = mysql
port = 3306
datadir = /data/mysql/mysql/data
tmpdir = /data/mysql/mysql/tmp
socket = /data/mysql/mysql/tmp/mysql.sock
log_error = /data/mysql/mysql/logs/mysqld.log
pid_file = /data/mysql/mysql/tmp/mysqld.pid
log_bin = /data/mysql/mysql/binlog/mysql-bin.log
character_set_server = utf8mb4
collation_server = utf8mb4_unicode_ci
skip-grant-tables = 0
skip_name_resolve = 1
lower_case_table_names = 1
authentication_policy = mysql_native_password
log_bin_trust_function_creators = 1
#validate_password.policy = LOW
#validate_password.length = 8

[client]
port = 3306
default-character-set = utf8
socket = /data/mysql/mysql/tmp/mysql.sock
EOF
    else
        echo_log_error "MySQL 未安装"
        return 1
    fi
}



check_gcc11() {
    # 如果是openEuler系统则跳过检测
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [ "$ID" = "openEuler" ]; then
            echo_log_info "检测到 openEuler 系统，跳过 GCC 版本检查"
            return 0
        fi
    fi

    # 非openEuler系统执行原检测逻辑
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
    local REQUIRED_PHP_MIN_VERSION="7.4"  # 需要的最低 PHP 版本
    local REQUIRED_PHP_MAX_VERSION="8.1"  # 允许的最高 PHP 版本（含 8.0）

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

    if [[ $(echo -e "$INSTALLED_PHP_VERSION\n$REQUIRED_PHP_MIN_VERSION" | sort -V | head -n1) == "$REQUIRED_PHP_MIN_VERSION" ]] && 
        [[ $(echo -e "$INSTALLED_PHP_VERSION\n$REQUIRED_PHP_MAX_VERSION" | sort -V | tail -n1) == "$REQUIRED_PHP_MAX_VERSION" ]]; then
        echo "PHP 版本符合要求: $INSTALLED_PHP_VERSION"
    else
        echo "PHP 版本不符合要求，请安装 7.4.x ~ 7.9.x 版本！"
        exit 1
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

        #make -j "$(nproc)" >/dev/null 2>/tmp/make_error.log
        #make install >/dev/null 2>/tmp/make_install_error.log

        MAKE_LOG="/tmp/make_error.log"
        INSTALL_LOG="/tmp/make_install_err.log"

        # 编译阶段
        if make -j "$(nproc)" > /dev/null 2>"${MAKE_LOG}"; then
            echo_log_success "make 成功!"
        else
            echo_log_error "make 失败，关键错误："
            grep -m3 -i 'error:' "${MAKE_LOG}" | sed 's/^/    /' >&2
            echo "完整日志请查看: ${MAKE_LOG}" >&2
            return 19
        fi

        # 安装阶段
        if make install > /dev/null 2>"${INSTALL_LOG}"; then
            echo_log_success "make install 成功!"
        else
            echo_log_error "make install 失败，关键错误："
            grep -m3 -i 'error:' "${INSTALL_LOG}" | sed 's/^/    /' >&2
            echo "建议检查磁盘空间 (df -h)" >&2
            echo "完整日志请查看: ${INSTALL_LOG}" >&2
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
                's@# DBSocket=@DBSocket=/data/mysql/mysql/tmp/mysql.sock@'
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

    _setup_database() {
        # ----------------------- 通用验证函数 ------------------------
        validate_mysql_connection() {
            if ! mysql -u"$1" -p"$2" -e "SELECT 1" &>/dev/null; then
                echo_log_error "MySQL连接验证失败 用户: $1"
                return 1
            fi
        }

        validate_sql_files() {
            echo_log_info "验证SQL文件完整性"
            for sql in "${REQUIRED_SQL_FILES[@]}"; do
                local sql_path="${SQL_BASE_DIR}/${sql}"
                if [[ ! -f "$sql_path" ]]; then
                    echo_log_error "缺失必要SQL文件: $sql_path"
                    return 2
                fi
                if [[ ! -s "$sql_path" ]]; then
                    echo_log_error "空SQL文件: $sql_path"
                    return 3
                fi
            done
        }

        # ---------------------- 数据库操作函数 -----------------------
        setup_database() {
            echo_log_info "开始初始化Zabbix数据库"
            
            # 创建数据库和用户（幂等操作）
            mysql -u"${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PWD}" 2>/dev/null <<EOF
CREATE DATABASE IF NOT EXISTS zabbix 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_bin;

CREATE USER IF NOT EXISTS '${ZABBIX_DB_USER}'@'%' 
IDENTIFIED BY '${ZABBIX_DB_PWD}';

GRANT ALL PRIVILEGES ON zabbix.* 
TO '${ZABBIX_DB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

            [[ $? -eq 0 ]] || {
                echo_log_error "数据库初始化失败"
                return 4
            }
            echo_log_info "数据库架构创建完成"
        }

        import_sql_data() {
            echo_log_info "开始导入SQL数据"
            
            cd "${SQL_BASE_DIR}" || return 5
            
            for sql_file in "${REQUIRED_SQL_FILES[@]}"; do
                echo_log_info "正在导入: ${sql_file}"
                
                # 使用root用户导入确保权限
                if ! mysql -u"${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PWD}" zabbix < "${sql_file}" >/dev/null 2>&1; then
                    echo_log_error "SQL导入失败: ${sql_file}"
                    return 6
                fi
                
                # 验证导入效果（可选）
                local table_count
                table_count=$(mysql -u"${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PWD}" zabbix -Nse \
                    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'zabbix';" 2>/dev/null)
                    
                echo_log_info "当前数据库表数量: ${table_count}"
            done
            
            echo_log_info "SQL数据导入完成"
        }

        # ----------------------- 主逻辑执行流程 -----------------------
        # 预验证：检查root连接和SQL文件
        validate_mysql_connection "${MYSQL_ROOT_USER}" "${MYSQL_ROOT_PWD}" || return 1
        validate_sql_files || return 1

        # 创建数据库和用户
        setup_database || return 1

        # 创建后验证zabbix用户连接
        validate_mysql_connection "${ZABBIX_DB_USER}" "${ZABBIX_DB_PWD}" || {
            echo_log_error "请检查zabbix用户权限及密码是否正确"
            return 1
        }

        # 导入SQL数据
        import_sql_data || return 1

        # 最终验证
        echo_log_info "最终数据库状态验证"
        mysql -u"${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PWD}" zabbix -e "
            SHOW TABLES LIKE 'users%';
            SELECT COUNT(*) AS total_tables FROM information_schema.tables 
            WHERE table_schema = 'zabbix';" >/dev/null 2>&1
        
        echo_log_info "Zabbix数据库初始化成功完成"
    }

    # ---------------------- 服务配置函数 -----------------------
    _setup_service() {
        echo_log_info "配置Zabbix服务文件"
        
        [[ -d "${SERVICE_FILES_DIR}" ]] || {
            echo_log_error "服务文件目录不存在: ${SERVICE_FILES_DIR}"
            return 7
        }
        
        for service in zabbix_server zabbix_agentd; do
            local src_file="${SERVICE_FILES_DIR}/${service}"
            local dest_file="/etc/init.d/${service}"
            
            # 验证源文件存在
            [[ -f "$src_file" ]] || {
                echo_log_error "服务文件不存在: $src_file"
                return 8
            }
            
            # 修改二进制路径
            sed -i "s@/usr/local/sbin/${service}@/data/zabbix/sbin/${service}@" "$src_file"
            
            # 复制服务文件
            cp -r "$src_file" "$dest_file"
            
            # 设置执行权限
            chmod +x "$dest_file"
            chkconfig "$service" on
        done
        
        echo_log_info "服务配置完成"
    }

    # ---------------------- 启动函数 -----------------------
    _start_services() {
        echo_log_info "开始启动Zabbix服务"

        # 定义服务列表
        local services=("zabbix_server" "zabbix_agentd")
        local service_script_dir="/etc/init.d"
        
        # 验证服务脚本目录存在
        [[ -d "$service_script_dir" ]] || {
            echo_log_error "服务脚本目录不存在: $service_script_dir"
            return 7
        }

        # 初始化服务
        for service in "${services[@]}"; do
            # 使用service命令启动服务
            if ! service "$service" start; then
                echo_log_error "使用service命令启动$service失败"
                return 8
            fi

            # 设置服务开机自启（对于使用service命令的情况）
            if ! chkconfig "$service" on; then
                echo_log_error "设置$service开机自启失败"
                return 9
            fi

            # 确认服务状态
            if ! service "$service" status | grep -q 'running'; then
                echo_log_error "$service未成功运行，请检查配置和服务状态"
                return 10
            fi
            
            # 使用systemctl确认服务状态并重启服务（可选）
            if systemctl is-active --quiet "$service"; then
                echo_log_info "$service正在运行中，尝试重启以应用最新配置"
                if ! systemctl restart "$service"; then
                    echo_log_error "重启$service失败"
                    return 11
                fi
            else
                echo_log_info "使用systemctl启动$service"
                if ! systemctl start "$service"; then
                    echo_log_error "使用systemctl启动$service失败"
                    return 12
                fi
            fi
            
            echo_log_info "$service已成功启动并设置为开机自启"
        done

        # 修改日志文件的所有权
        local log_file="/data/zabbix/logs/zabbix_agentd.log"
        if [ -f "$log_file" ]; then
            if chown zabbix.zabbix "$log_file"; then
                echo_log_success "日志文件所有权修改成功: $log_file"
            else
                echo_log_error "修改日志文件所有权失败: $log_file"
                return 13
            fi
        else
            echo_log_warning "日志文件不存在: $log_file"
        fi
        
        echo_log_success "所有服务均已成功启动并设置为开机自启"
    }


    # ---------------------- 配置web函数 -----------------------
    _confihure_web() {
        # ---------------------- 配置PHP函数 -----------------------
        _configure_php() {
            local php_ini_file="/usr/local/php/etc/php.ini"
            
            # 检查 php.ini 文件是否存在
            if [[ ! -f "$php_ini_file" ]]; then
                echo_log_error "PHP 配置文件不存在: $php_ini_file"
                return 1
            fi
            
            sed -i 's@max_execution_time = 30@max_execution_time = 300@g' "$php_ini_file"
            sed -i 's@max_input_time = 60@max_input_time = 300@g' "$php_ini_file"
            sed -i 's@post_max_size = 8M@post_max_size = 500M@g' "$php_ini_file"
            sed -i 's@memory_limit = 128M@memory_limit = 1024M@g' "$php_ini_file"
            sed -i 's@upload_max_filesize = 2M@upload_max_filesize = 500M@g' "$php_ini_file"
            sed -i 's@;date.timezone =@date.timezone = Asia/Shanghai@g' "$php_ini_file"
            sed -i 's@mysqli.default_socket =@mysqli.default_socket = /data/mysql/sock/mysql.sock@g' "$php_ini_file"
            
            echo_log_success "PHP 配置更新成功"
        }


        # ---------------------- 配置Apache函数 -----------------------
        _configure_apache() {
            local apache_conf_dir="/usr/local/apache/conf"
            local zabbix_ui_src="$DOWNLOAD_PATH/$PACKAGE_NAME-$DEFAULT_VERSION/ui"
            local web_root="/var/www/zabbix"
            local vhost_conf="/usr/local/apache/conf/conf.d/zabbix.conf"

            log_info "开始配置Apache HTTP服务器"

            # 检查Apache配置文件目录是否存在
            [[ -d "$apache_conf_dir" ]] || {
                echo_log_error "Apache配置文件目录不存在: $apache_conf_dir"
                return 1
            }

            # 修改 apache主配置文件 httpd.conf 
            sed -i 's@^Listen 80@#Listen 80@g' "$apache_conf_dir/httpd.conf"
            sed -i 's@^ServerName www.example.com:80@#ServerName www.example.com:80@g' "$apache_conf_dir/httpd.conf"
            sed -i 's/^\(LoadModule php_module.*\)$/#\1/' "$apache_conf_dir/httpd.conf"
            sed -i 's/LoadModule php_module   modules/libphp.so/g'
            sed -i 's/#LoadModule proxy_module/LoadModule proxy_module/g' "$apache_conf_dir/httpd.conf"
            sed -i 's/#LoadModule proxy_fcgi_module/LoadModule proxy_fcgi_module/g' "$apache_conf_dir/httpd.conf"
            grep -q '^Include conf/conf.d/\*.conf' "$apache_conf_dir/httpd.conf" || echo 'Include conf/conf.d/*.conf' >> "$apache_conf_dir/httpd.conf"

            echo_log_success "修改Apache主配置文件成功"

            # 复制Zabbix UI文件到Web根目录
            if [[ ! -d "$zabbix_ui_src" ]]; then
                echo_log_error "Zabbix UI源文件目录不存在: $zabbix_ui_src"
                return 2
            fi

            if [[ ! -d "$web_root" ]]; then
                mkdir -p /var/www
                cp -r "$zabbix_ui_src" "$web_root"
                chown -R apache:apache "$web_root"
                echo_log_success "复制Zabbix UI文件到Web根目录成功"
            fi

            if [[ ! -d "$apache_conf_dir/conf.d" ]]; then
                echo_log_info "$apache_conf_dir/conf.d 不存在，创建目录" 
                mkdir "$apache_conf_dir/conf.d"
            fi 

            # 配置Apache虚拟主机
            cat > "$vhost_conf" <<'EOF'
# zabbix web
Listen 80
<VirtualHost *:80>
        ServerName localhost
        DocumentRoot /var/www/zabbix
        DirectoryIndex index.php
        AddDefaultCharset UTF-8

        <Directory /var/www/zabbix>
            AllowOverride None
            <IfVersion >= 2.3>
                Require all granted
            </IfVersion>
            <IfVersion < 2.3>
                Order Deny,Allow
                Allow from all
            </IfVersion>
        </Directory>

        LogLevel warn
        ErrorLog /usr/local/apache/logs/zabbix_error.log
        CustomLog /usr/local/apache/logs/zabbix_access.log combined
</VirtualHost>
EOF
            echo_log_success "配置Apache虚拟主机成功"


            # 启动Apache服务
            systemctl start httpd
            if systemctl is-active --quiet httpd; then
                echo_log_success "Apache服务启动成功"
            else
                echo_log_error "启动Apache服务失败"
                return 4
            fi

            echo_log_info "所有配置已完成，Apache服务已启动"
        }
        _configure_php
        _configure_apache
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
    [ $rc -eq 0 ] && _setup_database || rc=$?
    [ $rc -eq 0 ] && _setup_service || rc=$?
    [ $rc -eq 0 ] && _start_services || rc=$?
    [ $rc -eq 0 ] && _confihure_web || rc=$?
}



uninstall_zabbix_server() {
    systemctl stop zabbix_server
    systemctl stop zabbix_agent

    # 创建数据库和用户（幂等操作）
    mysql -u"${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PWD}" <<EOF
DROP DATABASE zabbix;
exit
EOF
    rm -rf /etc/init.d/zabbix_agentd 
    rm -rf /etc/init.d/zabbix_server 

    rm -rf /data/zabbix
    rm -rf $DOWNLOAD_PATH/$PACKAGE_NAME-$DEFAULT_VERSION


}

main() {
    clear
    # 定义颜色常量
    local COLOR_BORDER="\033[1;34m"     # 亮蓝色边框
    local COLOR_TITLE="\033[1;37m"      # 亮白色标题
    local COLOR_OPTION="\033[1;33m"     # 黄色选项
    local COLOR_INPUT="\033[1;35m"      # 紫色输入提示
    local COLOR_RESET="\033[0m"         # 重置颜色

    # 动态生成标题
    print_menu_header() {
        echo -e "${COLOR_BORDER}╔════════════════════════════════════════════════════════════════════════╗${COLOR_RESET}"
        echo -e "${COLOR_BORDER}║${COLOR_TITLE}           $PACKAGE_NAME${NODE_VERSION} 管理脚本                                       ${COLOR_BORDER}║${COLOR_RESET}"
        echo -e "${COLOR_BORDER}╠════════════════════════════════════════════════════════════════════════╣${COLOR_RESET}"
    }

    # 生成菜单选项
    print_menu_body() {
        echo -e "${COLOR_BORDER}║${COLOR_OPTION}  1. 安装 $PACKAGE_NAME${NODE_VERSION}                                                 ${COLOR_BORDER}║${COLOR_RESET}"
        echo -e "${COLOR_BORDER}║${COLOR_OPTION}  2. 卸载 $PACKAGE_NAME${NODE_VERSION}                                                 ${COLOR_BORDER}║${COLOR_RESET}"
        echo -e "${COLOR_BORDER}║${COLOR_OPTION}  3. 退出脚本                                                           ${COLOR_BORDER}║${COLOR_RESET}"
        echo -e "${COLOR_BORDER}╚════════════════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    }


    # 显示完整菜单
    print_menu_header
    print_menu_body

    # 输入提示（带颜色重置）
    echo -en "${COLOR_INPUT}▷▷▷ 请输入操作序号 (1-3): ${COLOR_RESET}"
    read -r num

    # 处理选择
    case "$num" in
        1) install_zabbix_server ;;
        2) uninstall_zabbix_server ;;
        3) quit ;;
        *) 
            echo -e "${COLOR_INPUT}无效输入，请重新选择！${COLOR_RESET}"
            sleep 1
            main 
            ;;
    esac
}

# 启动主菜单
main