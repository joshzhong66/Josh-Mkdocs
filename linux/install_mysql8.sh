#!/bin/bash
#
#官网下载地址:https://downloads.mysql.com/archives/community/
#
#https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.34-linux-glibc2.17-x86_64.tar.gz
#

PACKAGE_NAME="mysql"
MYSQL_VERSION="8.0.34"
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH="/usr/local/mysql"
MYSQL_CONFIG_FILE="/etc/my.cnf"
MYSQL_DATA_PATH="/data/mysql"
LOG_PATH="$MYSQL_DATA_PATH/log"
ERROR_LOG="$LOG_PATH/mysql_error.log"
SLOW_QUERY_LOG="$LOG_PATH/mysql_slow_query.log"
TEMP_PASSWORD=""
MYSQL_ROOT_PWD="sunline"
RESET_MYSQL_PWD=""
MYSQL_TAR="${PACKAGE_NAME}-${MYSQL_VERSION}-linux-glibc2.17-x86_64.tar.gz"
INTERNAL_URL="http://10.24.1.133/Linux/MySQL/$MYSQL_TAR"
EXTERNAL_URL="https://downloads.mysql.com/archives/get/p/23/file/$MYSQL_TAR"


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
    elif rpm -qa | grep mariadb >/dev/null; then
        echo_log_warn "MariaDB is already installed. Please uninstall it before installing the new version!"
        rpm -e mariadb-libs-5.5.68-1.el7.x86_64 --nodeps >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "MariaDB has been uninstalled successfully." || echo_log_error "Failed to uninstall MariaDB!"
    else
        return 0
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

create_directory() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        echo_log_info "Creating directory: $dir"
        mkdir -p "$dir" && echo_log_info "Directory $dir created successfully." || { echo_log_error "Failed to create directory: $dir"; exit 1; }
    else
        echo_log_error "Directory $dir already exists."
    fi
}

create_log_file() {
    local log_file=$1
    if [ ! -f "$log_file" ]; then
        echo_log_info "Creating log file: $log_file"
        touch "$log_file" && echo_log_info "Log file $log_file created successfully." || { echo_log_error "Failed to create log file: $log_file"; exit 1; }
    else
        echo_log_error "Log file $log_file already exists."
    fi
}

install_mysql8() {
    check_package

    echo_log_info "Start Installing MySQL $MYSQL_VERSION..."

    yum install -y ncurses-compat-libs-6.1-9.20180224.el8.x86_64  libaio-devel >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Rely Package Install Successful" || echo_log_error "Rely Package Install Failed"

    if [ -f "$DOWNLOAD_PATH/$MYSQL_TAR" ]; then
        echo_log_info "The $PACKAGE_NAME source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package $PACKAGE_NAME $DOWNLOAD_PATH "$INTERNAL_URL" "$EXTERNAL_URL"
    fi

    tar -zxf $DOWNLOAD_PATH/$MYSQL_TAR -C /usr/local >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Unzip $PACKAGE_NAME source package successful！" || echo_log_error "Unzip $PACKAGE_NAME source package failed！"

    mv /usr/local/$PACKAGE_NAME-$MYSQL_VERSION-linux-glibc2.17-x86_64/ $INSTALL_PATH
    [ $? -eq 0 ] && echo_log_info "Rename $PACKAGE_NAME successful！" || echo_log_error "Rename $PACKAGE_NAME failed！"

    echo_log_info "Start mkdir $PACKAGE_NAME dir..."
    create_directory "$MYSQL_DATA_PATH/data"
    create_directory "$MYSQL_DATA_PATH/log"
    create_directory "$MYSQL_DATA_PATH/tmpdir"
    create_directory "$MYSQL_DATA_PATH/sock"
    create_directory "$MYSQL_DATA_PATH/binlog"
    create_directory "$MYSQL_DATA_PATH/relaylog"

    echo_log_info "Start install $PACKAGE_NAME logfiles..."
    create_log_file "$ERROR_LOG"
    create_log_file "$SLOW_QUERY_LOG"

    cat /etc/passwd | grep $PACKAGE_NAME >/dev/null 2>&1 || useradd -M -s /sbin/nologin $PACKAGE_NAME
    [  $? -eq 0 ] && echo_log_info "Add $PACKAGE_NAME User Successful" || echo_log_error "Add $PACKAGE_NAME User Failed"


    chown -R $PACKAGE_NAME:$PACKAGE_NAME $MYSQL_DATA_PATH >/dev/null 2>&1
    chown -R $PACKAGE_NAME:$PACKAGE_NAME $INSTALL_PATH >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Change Owner Successful" || echo_log_error "Change Owner Failed"

    cat > $MYSQL_CONFIG_FILE <<'EOF'
# mysql 8.0
[mysql]
default-character-set=utf8

[mysqld]
######## basic settings ########
server_id  = 1
user       = mysql
port       = 3306
#basedir    = /usr/local/mysql
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
binlog_format             = ROW
binlog_gtid_simple_recovery = 1
binlog_expire_logs_seconds  = 604800

[client]
default-character-set=utf8
socket=/data/mysql/sock/mysql.sock

[mysqldump]
default-character-set=utf8
max-allowed-packet=2G
EOF
    [ $? -eq 0 ] && echo_log_info "Configuration $PACKAGE_NAME file generated successfully" || echo_log_error "Configuration $PACKAGE_NAME file generation failed"


    chown $PACKAGE_NAME:$PACKAGE_NAME $MYSQL_CONFIG_FILE
    chmod -R 755 $MYSQL_DATA_PATH/data >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Change $PACKAGE_NAME Permission Successful" || echo_log_error "Change $PACKAGE_NAME Permission Failed"

    $INSTALL_PATH/bin/mysqld --user=$PACKAGE_NAME --initialize --basedir=$INSTALL_PATH --datadir=$MYSQL_DATA_PATH/data >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "MySQL $PACKAGE_NAME database initialized successfully" || echo_log_error "MySQL $PACKAGE_NAME database initialization failed"

    ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql 2>/dev/null
    [ $? -eq 0 ] && echo_log_info "MySQL $PACKAGE_NAME symlink created successfully" || echo_log_error "MySQL $PACKAGE_NAME symlink creation failed"

    cat > /etc/systemd/system/mysqld.service <<'EOF'
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

[Install]
WantedBy=multi-user.target
EOF


    [ $? -eq 0 ] && echo_log_info "Create mysql service success." || echo_log_error "Create mysql service failed."

    systemctl daemon-reload >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Reload systemctl daemon success." || echo_log_error "Reload systemctl daemon failed."
    
    systemctl start mysqld && systemctl enable mysqld >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Start mysql service success." || echo_log_error "Start mysql service failed."]

    echo_log_info "Initialize mysql root password."
    TEMP_PASSWORD=$(grep -oP '(?<=temporary password is generated for root@localhost: )\S+' "$ERROR_LOG")
    [ $? -eq 0 ] && echo_log_info "Temporary password: $TEMP_PASSWORD" || echo_log_error "Failed to get temporary password."
    
    echo_log_info "mysql root password: $TEMP_PASSWORD"
    echo_log_info "Connecting to MySQL using temporary password..."

    mysql -uroot -p"$TEMP_PASSWORD" --connect-expired-password 2>/dev/null <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PWD'; 
EOF
    [ $? -eq 0 ] && echo_log_info "Initialize mysql root password $MYSQL_ROOT_PWD success." || echo_log_error "Initialize mysql root password failed."

    mysql -uroot -p"$MYSQL_ROOT_PWD" 2>/dev/null  <<EOF
USE mysql;
UPDATE user SET host='%' WHERE user='root';
FLUSH PRIVILEGES;
EOF
    [ $? -eq 0 ] && echo_log_info "Update mysql root host success." || echo_log_error "Update mysql root host failed."

    echo_log_info "Install mysql success."
}

uninstall_mysql8() {
    if [ -d ${INSTALL_PATH} ]; then
        echo_log_info "Start Uninstall mysql8"
        systemctl stop mysqld && systemctl disable mysqld >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "Stop mysql service success." || echo_log_error "Stop mysql service failed."

        rm -f /etc/systemd/system/mysqld.service
        [ $? -eq 0 ] && echo_log_info "Remove mysql service success." || echo_log_error "Remove mysql service failed."

        rm -rf $INSTALL_PATH
        [ $? -eq 0 ] && echo_log_info "Delete $INSTALL_PATH success." || echo_log_error "Delete $INSTALL_PATH failed."]
        
        rm -rf $MYSQL_DATA_PATH >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "Delete  $MYSQL_DATA_PATH success." || echo_log_error "Delete  $MYSQL_DATA_PATH failed."

        rm -f $MYSQL_CONFIG_FILE
        [ $? -eq 0 ] && echo_log_info "Delete mysql8 $MYSQL_CONFIG_FILE success." || echo_log_error "Delete  $MYSQL_CONFIG_FILE file failed."

        rm -f /usr/bin/mysql
        [ $? -eq 0 ] && echo_log_info "Delete /usr/bin/mysql success." || echo_log_error "Delete /usr/bin/mysql failed."

        echo_log_info "Uninstall mysql8 success."
    fi
}

reset_root_pwd() {
    [ ! -d $INSTALL_PATH ] && echo_log_error "Please check the installation path." && exit 1

    while [ ${#RESET_MYSQL_PWD} -lt 4 ]; do
        read -rp "Please enter the root password you need to set for MySQL >= 4 characters:" RESET_MYSQL_PWD
        if [ ${#RESET_MYSQL_PWD} -lt 4 ]; then
            echo_log_info "MySQL root password>=4 digits, please re-enter"
        fi
    done

    #${INSTALL_PATH}/bin/mysqladmin -S/data/mysql/sock/mysql.sock -uroot  password "${mysql_root_pwd}"
    sed -i 's/skip-grant-tables       = 0/skip-grant-tables       = 1/g' /etc/my.cnf
    #sed -i 's/skip-grant-tables/#skip-grant-tables/g' /etc/my.cnf
    [ $? -eq 0 ] && echo_log_info "Modify MySQL config success" || echo_log_error "Modify MySQL config failed"

    systemctl restart mysqld
    [ $? -eq 0 ] && echo_log_info "Restart MySQL service success" || echo_log_error "Restart MySQL service failed"

    sleep 5
    echo_log_info "MySQL Connect..."

    # 注意'root'@'%'有时候并不是这个%
    $INSTALL_PATH/bin/mysql -uroot --connect-expired-password 2>/dev/null <<EOF
FLUSH PRIVILEGES;   #强制更新
ALTER USER 'root'@'%' IDENTIFIED BY '$RESET_MYSQL_PWD'; 
FLUSH PRIVILEGES;
EOF
    [ $? -eq 0 ] && echo_log_info "MySQL root password reset successfully" || echo_log_error "MySQL root password reset failed"
    
    sed -i 's/skip-grant-tables       = 1/skip-grant-tables       = 0/g' /etc/my.cnf
    systemctl restart mysqld
    [ $? -eq 0 ] && echo_log_info "MySQL restart successfully" || echo_log_error "MySQL restart failed"
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${MYSQL_VERSION} Install Tool\033[0m
———————————————————————————
1. Install $PACKAGE_NAME${MYSQL_VERSION}
2. Uninstall $PACKAGE_NAME${MYSQL_VERSION}
3. Reset $PACKAGE_NAME${MYSQL_VERSION} Password
4. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) install_mysql8 ;;
    2) uninstall_mysql8 ;;
    3) reset_root_pwd ;;
    4) quit ;;
    *) main ;;
    esac
}


main