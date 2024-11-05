#!/bin/bash

# Install MySQL Script
# 官网下载地址: https://downloads.mysql.com/archives/community/
# \033[33m 表示黄色， \033[32m 表示绿色， \033[31m 表示红色， \033[0m 表示恢复样式

Down_DIR="/usr/local/src"
MYSQL_VERSION="8.0.34"
MYSQL_TAR="mysql-$MYSQL_VERSION-linux-glibc2.17-x86_64.tar.gz"
EXTERNAL_MYSQL_URL="https://downloads.mysql.com/archives/get/p/23/file/$MYSQL_TAR"
INTERNAL_MYSQL_URL="http://10.24.1.133/Linux/MySQL/$MYSQL_TAR"
MYSQL_INSTALL_DIR="/usr/local/mysql"
MYSQL_DATA_DIR="/data/mysql"
MYSQL_CONFIG_FILE="/etc/my.cnf"

function echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}

function echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}

function echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}

function echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}

function main() {
    clear
    echo -e "———————————————————————————
\033[32m MySQL${MYSQL_VERSION} 安装工具\033[0m
———————————————————————————
1. 安装MySQL${MYSQL_VERSION}
2. 卸载MySQL${MYSQL_VERSION}
3. 重置MYSQL root密码
4. 退出\n"

    read -rp "请输入序号并回车：" num
    case "$num" in
    1) install_source_mysql ;;
    2) remove_source_mysql ;;
    3) resetpwd_root ;;
    4) quit ;;
    *) echo_log_warn "无效选项，请重新选择。" && main ;;
    esac
}

function check_url() {
    curl --head --silent --fail --connect-timeout 3 --max-time 5 "$1" > /dev/null
}

function download_mysql() {
    if ! command -v wget &>/dev/null; then
        echo_log_warn "未安装 wget，将先安装wegt"
        yum install -y wget &>/dev/null
    fi
        
    if [ ! -f "$Down_DIR/$MYSQL_TAR" ]; then
        if check_url "$INTERNAL_MYSQL_URL"; then
            echo_log_info "INTERNAL_MYSQL_URL 链接有效，开始下载 $MYSQL_TAR..."
            wget -P "$Down_DIR" "$INTERNAL_MYSQL_URL" &>/dev/null
        else
            echo_log_warn "INTERNAL_MYSQL_URL 无效，检查 EXTERNAL_MYSQL_URL..."
            if check_url "$EXTERNAL_MYSQL_URL"; then
                echo_log_info "EXTERNAL_MYSQL_URL 有效，开始下载 $MYSQL_TAR..."
                wget -P "$Down_DIR" "$EXTERNAL_MYSQL_URL" &>/dev/null
            else
                echo_log_error "两个下载链接都无效，下载失败。"
            fi
        fi

        [ $? -eq 0 ] && echo_log_info "$MYSQL_TAR 下载成功" || echo_log_error "$MYSQL_TAR 下载失败，请检查 URL。"
    else
        echo_log_info "安装包 $MYSQL_TAR 已存在，跳过下载。"
    fi
}

function install_source_mysql() {
    if command -v mysql &>/dev/null; then
        echo_log_info "系统已安装mysql，请先卸载后再进行安装！"
        exit 1
    fi

    mysql_root_password=""
    while [ ${#mysql_root_password} -lt 4 ]; do
        read -rp "请输入需要设置的MYSQL的root密码>=4位：" mysql_root_password
        if [ ${#mysql_root_password} -lt 4 ]; then
            echo_log_info "密码长度小于4位，请重新输入！"
        fi
    done
    sed -i 's/enforcing/disabled/' /etc/selinux/config && setenforce 0 >/dev/null 2>&1
    download_mysql
    # 解压 MySQL 并移动到目标目录
    if [ -d "$MYSQL_INSTALL_DIR" ]; then
        rm -rf $MYSQL_INSTALL_DIR
        echo_log_info "$MYSQL_INSTALL_DIR 目录存在,清理该目录"
    fi

    if [ -d $MYSQL_DATA_DIR ]; then
        rm -rf $MYSQL_DATA_DIR
        echo_log_info "$MYSQL_DATA_DIR 目录存在,清理该目录"
    fi

    tar -zxvf "$Down_DIR/$MYSQL_TAR" -C /usr/local/ >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo_log_error "解压 $MYSQL_TAR 失败，请检查安装包是否正确。"
    fi
    echo_log_info "$MYSQL_TAR 解压成功"
    mv /usr/local/mysql-8.0.34-linux-glibc2.17-x86_64 /usr/local/mysql
    if [ $? -eq 0 ]; then
        echo_log_info "MySQL 安装目录创建成功。"
    else
        echo_log_error "MySQL 安装目录创建失败。"
    fi
    # 创建 MySQL 数据目录
    if mkdir -p "$MYSQL_DATA_DIR"; then
        echo_log_info "$MYSQL_DATA_DIR 目录不存在，创建成功。"
    else
        echo_log_error "$MYSQL_DATA_DIR 目录创建失败。"
    fi

    # 需要创建的目录列表
    directories=(
        "/data/mysql/data"
        "/data/mysql/log"
        "/data/mysql/tmpdir"
        "/data/mysql/sock"
        "/data/mysql/binlog"
        "/data/mysql/relaylog"
    )
    # 遍历每个目录，检查是否存在，存在则删除
    for dir in "${directories[@]}"; do
        if [ -d "$dir" ]; then
            echo "目录 $dir 已存在，正在删除..." > /dev/null 2>&1
            rm -rf "$dir"
        fi
        echo_log_info "正在创建目录 $dir..."
        mkdir -p "$dir"
    done
    echo_log_info "所有目录已创建。"
    touch /data/mysql/log/mysql_error.log
    touch /data/mysql/log/mysql_slow_query.log
    if [ $? -eq 0 ]; then
        echo_log_info "文件创建成功。"
    else
        echo_log_error "文件创建失败。"
    fi


    if id "mysql" &>/dev/null; then
        echo_log_info "Mysql用户已存在，跳过创建步骤。"
    else
        echo_log_info "正在创建Mysql用户..."
        groupadd mysql
        useradd -r -g mysql -s /sbin/nologin mysql
        if [ $? -eq 0 ]; then
            echo_log_info "已成功创建Mysql用户。"
        else
            echo_log_error "创建Mysql用户失败。"
        fi
    fi
    # 配置 MySQL
    cat > "$MYSQL_CONFIG_FILE" <<EOF
# mysql 8.0
[mysql]
default-character-set=utf8

[mysqld]
######## basic settings ########
server_id  = 1
user       = mysql
port       = 3306
#basedir   = /data/mysql
pid_file   = /data/mysql/sock/mysql.pid
socket     = /data/mysql/sock/mysql.sock
datadir    = /data/mysql/data
tmpdir     = /data/mysql/tmpdir
skip-grant-tables       = 0
skip_name_resolve       = 1
max_connections         = 800
max_connect_errors      = 100000
max_allowed_packet      = 64M
lower_case_table_names  = 1
character_set_server    = utf8mb4
collation_server        = utf8mb4_bin
transaction_isolation   = READ-COMMITTED
authentication_policy   = mysql_native_password
sql-mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"

######## log settings ########
log_error                     = /data/mysql/log/mysql_error.log
slow_query_log_file           = /data/mysql/log/mysql_slow_query.log
slow_query_log                = 1
log_queries_not_using_indexes = 1
log_slow_admin_statements     = 1
log_slow_replica_statements   = 1
long_query_time               = 2
min_examined_row_limit        = 100
log_throttle_queries_not_using_indexes = 10

########replication settings########
log_bin              = /data/mysql/binlog/mysql-bin
relay_log            = /data/mysql/relaylog/mysql-relay-bin
sync_binlog               = 1
gtid_mode                 = on
enforce_gtid_consistency  = 1
log_replica_updates       = 1
binlog_gtid_simple_recovery = 1
binlog_expire_logs_seconds  = 604800

[client]
default-character-set=utf8
socket=/data/mysql/sock/mysql.sock

[mysqldump]
default-character-set=utf8
max-allowed-packet=2G
EOF

    if [ $? -eq 0 ]; then
        echo_log_info "配置文件$$MYSQL_CONFIG_FILE 创建成功。"
    else
        echo_log_error "配置文件$$MYSQL_CONFIG_FILE 创建失败。"
    fi
    # 创建和启动服务
    cat > /etc/systemd/system/mysqld.service <<EOF
[Unit]
Description=MySQL server
After=syslog.target network.target
 
[Service]
User=mysql
Group=mysql
Type=forking
TimeoutSec=0
#PermissionsStartOnly=true
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --daemonize
LimitNOFILE = 65535
Restart=on-failure
RestartSec=3
RestartPreventExitStatus=1
PrivateTmp=false
 
[Install]
WantedBy=multi-user.target
EOF

    [ $? -eq 0 ] && echo_log_info "服务配置成功" || echo_log_error "服务配置失败"
    chown -R mysql.mysql "$MYSQL_INSTALL_DIR"
    chown -R mysql.mysql "$MYSQL_DATA_DIR"
    chown mysql.mysql "$MYSQL_CONFIG_FILE"
    chown mysql.mysql  /etc/systemd/system/mysqld.service

    ${MYSQL_INSTALL_DIR}/bin/mysqld  --initialize-insecure  --user=mysql --basedir=${MYSQL_INSTALL_DIR} --datadir=${MYSQL_DATA_DIR}/data
    if [ $? -eq 0 ]; then
        echo_log_info "MySQL 数据库初始化成功"
    else
        echo_log_error "MySQL 数据库初始化失败"
    fi
    ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
    systemctl daemon-reload >/dev/null 2>&1
    systemctl start mysqld  >/dev/null 2>&1
    systemctl enable mysqld >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "MySQL 服务启动成功" || echo_log_error "MySQL 服务启动失败"
    sleep 3

    #设置mysql密码
    echo
    echo_log_info "设置MySQL root密码..."
    mysql -uroot <<EOF
use mysql;
update user set host='%' where user='root';
flush privileges;
alter user 'root'@'%' identified by '$mysql_root_password';
flush privileges;
EOF

    [ $? -eq 0 ] && echo_log_info "MySQL root密码设置成功" || echo_log_error "MySQL root密码设置失败"
}

# 重置root密码
function resetpwd_root() {
    if [ ! -x "${MYSQL_INSTALL_DIR}/bin/mysql" ]; then
        echo_log_error "MySQL未安装或未配置环境变量"
    fi

    while [ ${#mysql_root_password} -lt 4 ]; do
        read -rp "请输入需要设置MySQL的 root 密码>=4位：" mysql_root_password
        if [ ${#mysql_root_password} -lt 4 ]; then
            echo_log_info "MySQL root 密码>=4位,请重新输入..."
        fi
    done

    echo
    echo_log_info "重置MySQL root密码..."
    sed -i 's/skip-grant-tables\s*=\s*0/skip-grant-tables=1/g' /etc/my.cnf
    systemctl restart mysqld >/dev/null 2>&1
    sleep 5
    mysql -uroot <<EOF
flush privileges;
alter user 'root'@'%' identified by '$mysql_root_password';
flush privileges;
EOF
    if [ $? -eq 0 ]; then
        echo_log_info "重置MySQL root密码 \033[33m${mysql_root_password}\033[0m 成功"
        sed -i 's/skip-grant-tables\s*=\s*0/skip-grant-tables=1/g' /etc/my.cnf
    else
        echo_log_error "重置MySQL root密码失败\033[0m"
    fi
    systemctl restart mysqld >/dev/null 2>&1
}


function remove_source_mysql() {
    systemctl disable mysqld >/dev/null 2>&1
    rpm -qa | grep mariadb | xargs rpm -e --nodeps >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo_log_info "卸载mariadb成功"
    fi
    systemctl stop mysqld
    rm -rf "$MYSQL_INSTALL_DIR" "$MYSQL_CONFIG_FILE" /etc/systemd/system/mysqld.service
    echo_log_info "删除mysql目录"
    rm -rf /data/mysql /usr/bin/mysql
    echo_log_info "MySQL 卸载完成"
}

function quit() {
    echo_log_info "退出安装工具"
    exit 0
}

main