#!/bin/bash

### 设置变量 ###
INTERNAL_MYSQL_URL="http://10.24.1.133/Linux/MySQL/mysql-8.0.34-linux-glibc2.17-x86_64.tar.gz"
EXTERNAL_MYSQL_URL="https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.34-linux-glibc2.17-x86_64.tar.gz"
MYSQL_TAR="mysql-8.0.34-linux-glibc2.17-x86_64.tar.gz"
DOWN_DIR="/usr/local/src"

MYSQL_MASTER_BASE_DIR="/usr/local/mysql"
MYSQL_MASTER_DATA_DIR="/data/mysql"

MYSQL_SLAVE_BASE_DIR="/usr/local/mysql-slave"
MYSQL_SLAVE_DATA_DIR="/data/mysql-slave"

MYSQL_ROOT_PWD="sunline"
MYSQL_REP_PWD="sunline2024"





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


function ck_ok(){
    if [ $? -ne 0 ]
    then
        echo "$1 error."
        exit 1
    fi
}

function check_url() {
    curl --head --silent --fail --connect-timeout 3 --max-time 5 "$1" > /dev/null
}


function download_mysql() { 
    if [ ! -f $DOWN_DIR/$MYSQL_TAR ]; then
        echo_log_info "MySQL安装包不存在服务器，准备开始下载MySQL安装包"
        if check_url "$INTERNAL_MYSQL_URL"; then
            echo_log_info "MySQL内部下载链接有效，开始下载MySQL"
            wget -P "$DOWN_DIR" "$INTERNAL_MYSQL_URL" &>/dev/null
            if [ $? -eq 0 ]; then
                echo_log_info "MySQL安装包下载成功"
            else
                echo_log_warn "内部下载链接有效，但下载失败。尝试使用外部链接"
                if check_url "$EXTERNAL_MYSQL_URL"; then
                    wget -P "$DOWN_DIR" "$EXTERNAL_MYSQL_URL" &>/dev/null
                    if [ $? -eq 0 ]; then
                        echo_log_info "MySQL安装包通过外部链接下载成功"
                    else
                        echo_log_error "两个下载链接都无效或下载失败。"
                    fi
                else
                    echo_log_error "两个下载链接都无效，下载失败。"
                fi
            fi
        else
            echo_log_warn "MySQL内部下载链接无效，通过外部链接下载MySQL"
            if check_url "$EXTERNAL_MYSQL_URL"; then
                wget -P "$DOWN_DIR" "$EXTERNAL_MYSQL_URL" &>/dev/null
                if [ $? -eq 0 ]; then
                    echo_log_info "MySQL安装包通过外部链接下载成功"
                else
                    echo_log_error "两个下载链接都无效或下载失败。"
                fi
            else
                echo_log_error "两个下载链接都无效，下载失败。"
            fi
        fi
    else
        echo_log_info "安装包 $MYSQL_TAR 已存在，跳过下载。"
    fi
}


function check_md5() {
    # 官方提供的MD5值
    OFFICIAL_MD5="c5fa071912612b7607d82de73b51fa07" 

    # 检查文件是否存在
    if [ -f "$DOWN_DIR/$MYSQL_TAR" ]; then
        # 计算本地文件的MD5值
        LOCAL_MD5=$(md5sum "$DOWN_DIR/$MYSQL_TAR" | awk '{ print $1 }')

        # 比较MD5值
        if [ "$LOCAL_MD5" = "$OFFICIAL_MD5" ]; then
            echo_log_info "MD5 校验成功，文件完整。"
        else
            echo_log_warn "MD5 校验失败，文件可能损坏。"
            rm -rf "$DOWN_DIR/$MYSQL_TAR"
            download_mysql
        fi
    else
        echo_log_error "MD5 校验失败，文件不存在。"
    fi
}


function install_master(){
    if [ -d "$MYSQL_MASTER_BASE_DIR" ]; then
        echo_log_error "mysql已经安装，请先卸载后再安装！"
    fi
    download_mysql
    check_md5

    # 检查是否存在mysql组与用户
    if getent group mysql &>/dev/null; then
        echo_log_info "系统已经存在mysql组，跳过创建"
    else
        echo_log_info "创建mysql组"
        groupadd mysql
    fi

    if id mysql &>/dev/null; then
        echo_log_info "系统已经存在mysql用户，跳过创建"
    else
        echo_log_info "创建mysql用户"
        useradd -s /sbin/nologin  mysql
    fi

    cd /usr/local/src
    echo_log_info "准备解压mysql安装包..."
    tar zxf $MYSQL_TAR
    ck_ok "解压mysql安装包"
    mv "${DOWN_DIR}/mysql-8.0.34-linux-glibc2.17-x86_64" $MYSQL_MASTER_BASE_DIR

    echo_log_info "MySQL数据目录创建&赋权"
    chmod -R 755 $MYSQL_MASTER_BASE_DIR
    chown -R mysql.mysql $MYSQL_MASTER_BASE_DIR
    mkdir -p $MYSQL_MASTER_DATA_DIR
    chown -R mysql.mysql $MYSQL_MASTER_DATA_DIR
    chmod -R 755 $MYSQL_MASTER_DATA_DIR
    ck_ok "mysql data目录赋权"

    if [ -d ${MYSQL_MSATER_DATA_DIR} ]; then
        echo_log_info "${MYSQL_MASTER_DATA_DIR}已经存在，删除"
        rm -rf ${MYSQL_MASTER_DATA_DIR}
    fi
    echo_log_info "创建master配置文件my.cnf"
    cat > ${MYSQL_MASTER_BASE_DIR}/my.cnf <<EOF
[mysqld]
user = mysql
port = 3306
server_id = 1
basedir = ${MYSQL_MASTER_BASE_DIR}
datadir = ${MYSQL_MASTER_DATA_DIR}
socket = ${MYSQL_MASTER_BASE_DIR}/mysql-master.sock
pid-file = ${MYSQL_MASTER_DATA_DIR}/mysqld.pid
log-error = ${MYSQL_MASTER_DATA_DIR}/mysql.err
EOF
    ck_ok "创建配置文件"
    echo_log_info "安装依赖"
    ## 基于Rocky8的依赖安装方法
    yum install -y ncurses-compat-libs-6.1-9.20180224.el8.x86_64  libaio-devel >/dev/null 2>&1
    ck_ok "依赖安装"

    echo_log_info "初始化"
    ${MYSQL_MASTER_BASE_DIR}/bin/mysqld --console --basedir=${MYSQL_MASTER_BASE_DIR} --datadir=${MYSQL_MASTER_DATA_DIR} --initialize-insecure --user=mysql >/dev/null 2>&1
    ck_ok "初始化"


    if [ -f /etc/systemd/system/mysqld.service ]; then
        echo_log_info "mysql服务管理脚本已经存在，删除"
        rm -rf /etc/systemd/system/mysqld.service
    fi
    echo_log_info "创建服务启动脚本"
    cat > /etc/systemd/system/mysqld.service <<EOF
[Unit]
Description=MYSQL server
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
Type=forking
TimeoutSec=0
PermissionsStartOnly=true
ExecStart=${MYSQL_MASTER_BASE_DIR}/bin/mysqld --defaults-file=${MYSQL_MASTER_BASE_DIR}/my.cnf --daemonize $OPTIONS
ExecReload=/bin/kill -HUP -$MAINPID
ExecStop=/bin/kill -QUIT $MAINPID
KillMode=process
LimitNOFILE=65535
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=1
PrivateTmp=false
EOF
    ck_ok "创建服务启动脚本"
    ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
    systemctl unmask mysqld
    systemctl daemon-reload
    systemctl enable mysqld >/dev/null 2>&1
    systemctl start mysqld
    [ $? -eq 0 ] && echo_log_info "mysql启动成功" 

    sleep 3
    ln -s /usr/local/mysql/mysql-master.sock /tmp/mysql.sock
    echo_log_info "设置mysql密码"
    ${MYSQL_MASTER_BASE_DIR}/bin/mysqladmin -S ${MYSQL_MASTER_BASE_DIR}/mysql-master.sock -uroot  password "${MYSQL_ROOT_PWD}" >/dev/null 2>&1
    
    ck_ok "设置mysql密码"
    echo_log_info "---主Mysql---安装完成"
}


function install_slave(){
    if [ -d "$MYSQL_SLAVE_BASE_DIR" ]; then
        echo_log_error "mysql已经安装，请先卸载后再安装！"
    fi
    download_mysql
    check_md5

    # 检查是否存在mysql组
    if getent group mysql &>/dev/null; then
        echo_log_info "系统已经存在mysql组，跳过创建"
    else
        echo_log_info "创建mysql组"
        groupadd mysql
    fi

    if id mysql &>/dev/null; then
        echo_log_info "系统已经存在mysql用户，跳过创建"
    else
        echo_log_info "创建mysql用户"
        sudo useradd -s /sbin/nologin  mysql
    fi

    cd /usr/local/src
    echo_log_info "解压mysql"
    tar zxf "$MYSQL_TAR"
    ck_ok "解压mysql"

    mv $DOWN_DIR/mysql-8.0.34-linux-glibc2.17-x86_64 $MYSQL_SLAVE_BASE_DIR


    if [ -d ${MYSQL_SLAVE_DATA_DIR} ]; then
        echo_log_info "${MYSQL_SLAVE_DATA_DIR}已经存在，删除"
        rm -rf ${MYSQL_SLAVE_DATA_DIR}
    fi
    echo_log_info "创建mysql data 目录"
    mkdir -p ${MYSQL_SLAVE_DATA_DIR}
    ck_ok "创建mysql data 目录"

    echo_log_info "MySQL数据目录创建&赋权"
    chown -R mysql.mysql ${MYSQL_SLAVE_DATA_DIR}
    chmod -R 755 "$MYSQL_SLAVE_DATA_DIR"
    chmod -R 755 "$MYSQL_SLAVE_BASE_DIR"
    chown -R mysql.mysql "$MYSQL_SLAVE_BASE_DIR"
    ck_ok "mysql data目录赋权"
    echo_log_info "创建slave配置文件my.cnf"
    cat > ${MYSQL_SLAVE_BASE_DIR}/my.cnf <<EOF
[mysqld]
user = mysql
port = 3307
server_id = 2
basedir = ${MYSQL_SLAVE_BASE_DIR}
datadir = ${MYSQL_SLAVE_DATA_DIR}
socket = ${MYSQL_SLAVE_BASE_DIR}/mysql-slave.sock
pid-file = ${MYSQL_SLAVE_DATA_DIR}/mysqld.pid
log-error = ${MYSQL_SLAVE_DATA_DIR}/mysql.err
EOF


    ck_ok "创建配置文件"
    echo_log_info "安装MySQL依赖"
    yum install -y ncurses-compat-libs-6.1-9.20180224.el8.x86_64  libaio-devel >/dev/null 2>&1
    ck_ok "依赖安装"
    echo_log_info "初始化MySQL"
    ${MYSQL_SLAVE_BASE_DIR}/bin/mysqld --console --basedir=${MYSQL_SLAVE_BASE_DIR} --datadir=${MYSQL_SLAVE_DATA_DIR}  --initialize-insecure --user=mysql >/dev/null 2>&1
    ck_ok "初始化"


    if [ -f /etc/systemd/system/mysqld-slave.service ]; then
        echo_log_info "mysql-slave服务管理已经存在，删除"
        rm -f /etc/systemd/system/mysqld-slave.service
    fi
    echo_log_info "创建服务启动脚本"
    cat > /etc/systemd/system/mysqld-slave.service <<EOF
[Unit]
Description=MYSQL server
After=network.target
[Install]
WantedBy=multi-user.target
[Service]
Type=forking
TimeoutSec=0
PermissionsStartOnly=true
ExecStart=${MYSQL_SLAVE_BASE_DIR}/bin/mysqld --defaults-file=${MYSQL_SLAVE_BASE_DIR}/my.cnf --daemonize $OPTIONS
ExecReload=/bin/kill -HUP -$MAINPID
ExecStop=/bin/kill -QUIT $MAINPID
KillMode=process
LimitNOFILE=65535
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=1
PrivateTmp=false
EOF

    ck_ok "创建服务启动脚本"
    ln -s ${MYSQL_SLAVE_BASE_DIR}/bin/mysql /usr/bin/mysql-slave

    echo_log_info "启动mysql"
    systemctl unmask mysqld-slave   #解除对 mysqld-slave 服务的屏蔽
    systemctl daemon-reload
    systemctl enable mysqld-slave >/dev/null 2>&1
    systemctl start mysqld-slave
    ck_ok "启动mysql"
    ln -s ${MYSQL_SLAVE_BASE_DIR}/mysql-slave.sock /tmp/mysql-slave.sock
    echo_log_info "设置mysql密码"
    ${MYSQL_SLAVE_BASE_DIR}/bin/mysqladmin -S ${MYSQL_SLAVE_BASE_DIR}/mysql-slave.sock -uroot  password "${MYSQL_ROOT_PWD}" >/dev/null 2>&1

    ck_ok "设置mysql密码"
    echo_log_info "---从Mysql---安装完成"
}


function config_rep() {
    mysql -uroot -S ${MYSQL_MASTER_BASE_DIR}/mysql-master.sock -p"${MYSQL_ROOT_PWD}" -e "
    SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'repuser' AND host = '127.0.0.1');" | grep 1 >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo_log_info "repuser用户已经存在，跳过创建"
    else
        echo_log_info "创建repuser用户"
        mysql -uroot -S ${MYSQL_MASTER_BASE_DIR}/mysql-master.sock -p"${MYSQL_ROOT_PWD}" -e "CREATE USER 'repuser'@'127.0.0.1' IDENTIFIED WITH 'mysql_native_password' BY \"${MYSQL_REP_PWD}\";"
        ck_ok "创建repuser用户"
    fi

    mysql -uroot -S ${MYSQL_MASTER_BASE_DIR}/mysql-master.sock -p"${MYSQL_ROOT_PWD}" -e "grant REPLICATION SLAVE ON *.* to 'repuser'@'127.0.0.1'; flush privileges;"
    ck_ok "用户授权"


    echo_log_info "获取mster的binlog文件和位置"
    mysql -uroot -S ${MYSQL_MASTER_BASE_DIR}/mysql-master.sock -p"${MYSQL_ROOT_PWD}" -e "show master status\G"  > /tmp/master_file_pos.txt
    ck_ok "获取master status"
    binfile=`grep "File" /tmp/master_file_pos.txt|awk -F': ' '{print $2}'`
    pos=`grep "Position" /tmp/master_file_pos.txt|awk -F': ' '{print $2}'`

    echo_log_info "到slave上配置主从"
    mysql -uroot -S ${MYSQL_SLAVE_BASE_DIR}/mysql-slave.sock -p"${MYSQL_ROOT_PWD}" -e "stop slave; change master to master_host='127.0.0.1',master_user='repuser',master_password=\"${MYSQL_REP_PWD}\",master_log_file=\"${binfile}\",master_log_pos=${pos}; start slave;"

    sleep 3
    echo_log_info "检测主从状态" 
    mysql-slave -uroot  -p"${MYSQL_ROOT_PWD}" -e "show slave status\G" > /tmp/slave_stat.txt
    ck_ok "获取slave status" 
    io_run=`grep 'Slave_IO_Running:' /tmp/slave_stat.txt|awk -F': ' '{print $2}'`
    sql_run=`grep 'Slave_SQL_Running:' /tmp/slave_stat.txt|awk -F': ' '{print $2}'`
    if [ ${io_run} == "Yes" ] && [ ${sql_run} == 'Yes' ]; then
            echo "mysql主从状态正常"
    else
            echo "mysql主从状态不正常"
            exit 1
    fi
}


function remove_mysql() {
    if [ -d ${MYSQL_MASTER_BASE_DIR} ] && [ -d ${MYSQL_SLAVE_BASE_DIR} ]; then
        systemctl stop mysqld && systemctl disable mysqld >/dev/null 2>&1
        systemctl stop mysqld-slave && systemctl disable mysqld-slave >/dev/null 2>&1
        rm -rf ${MYSQL_MASTER_BASE_DIR} ${MYSQL_SLAVE_BASE_DIR}
        rm -rf ${MYSQL_MASTER_DATA_DIR} ${MYSQL_SLAVE_DATA_DIR}
        rm -f /usr/bin/mysql
        rm -f /usr/bin/mysql-slave
        rm -rf /etc/systemd/system/mysqld.service
        rm -rf /etc/systemd/system/mysqld-slave.service
        rm -rf /tmp/mysql*
        ck_ok "卸载主从MySQL"
        echo_log_info "卸载完成"
    else
        echo_log_error "MySQL未安装，退出卸载"
    fi
}


function quit() {
    echo_log_info "退出脚本"
    exit 0
}


function main() {
    clear
    echo -e "———————————————————————————
\033[32m MySQL${MYSQL_VERSION} 安装工具\033[0m
———————————————————————————
1. 安装主MySQL
2. 安装从MySQL
3. 检测主从状态
4. 卸载主从MySQL
5. 退出\n"

    read -rp "请输入序号并回车：" num
    case "$num" in
    1) install_master ;;
    2) install_slave ;;
    3) config_rep ;;
    4) remove_mysql ;;
    5) quit ;;
    *) echo_log_warn "无效选项，请重新选择。" && main ;;
    esac
}

main

