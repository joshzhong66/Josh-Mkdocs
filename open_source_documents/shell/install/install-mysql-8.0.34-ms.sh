#!/bin/bash

#Install MySQL Script
#官网下载：https://downloads.mysql.com/archives/community/
# \033[33m 表示黄色， \033[32m 表示绿色， \033[31m 表示红色， \033[0m 表示恢复样式

MYSQL_VER="8.0.34"
MYSQL_SOURCE="mysql-${MYSQL_VER}-linux-glibc2.17-x86_64.tar.gz"
INSTALL_DIR="/data/mysql"
LINK_DIR="${INSTALL_DIR}/mysql"
SLAVE_INSTALL_DIR="/data/mysql_slave"
SLAVE_LINK_DIR="${SLAVE_INSTALL_DIR}/mysql"
WORK_DIR="/usr/local/src/mysql${MYSQL_VER}"
INTERNAL_MYSQL_URL="http://10.24.1.133/Linux/MySQL/${MYSQL_SOURCE}"
EXTERNAL_MYSQL_URL="https://downloads.mysql.com/archives/get/p/23/file/${MYSQL_SOURCE}"

# 日志输出
function echo_log_info() {
    echo -e "$(date +'%F %T') - [Info] $*"
}
function echo_log_warn() {
    echo -e "$(date +'%F %T') - [Warn] $*"
    exit 1
}
function echo_log_error() {
    echo -e "$(date +'%F %T') - [Error] $*"
    exit 1
}

function main() {
    clear
    echo -e "———————————————————————————
\033[32m MySQL${MYSQL_VER} 安装工具\033[0m
———————————————————————————
1. 安装MySQL${MYSQL_VER} (Master)
2. 安装MySQL${MYSQL_VER} (Slave)
3. 配置MySQL主从复制
4. 检测主从复制状态
5. 卸载MySQL${MYSQL_VER} (Master)
6. 卸载MySQL${MYSQL_VER} (Slave)
7. 退出\n"

    read -rp "请输入序号并回车：" num
    case "$num" in
    1) (install_mysql) ;;
    2) (install_mysql) ;;
    3) (config_mysql_rep) ;;
    4) (check_ps_status) ;;
    5) (remove_mysql) ;;
    6) (remove_mysql) ;;
    7) (quit) ;;
    *) (main) ;;
    esac
}

# 检查URL是否有效的函数
function check_url() {
    local url=$1
    if curl --head --silent --fail "$url" > /dev/null; then
        return 0  # URL 有效
    else
        return 1  # URL 无效
    fi
}

# 安装mysql
function install_mysql() {
    if [ $num -eq 1 ]; then
        if [ -d "$INSTALL_DIR" ]; then
            echo_log_warn "\033[31m系统中已安装 mysql (Master) ,请先卸载后再安装\033[0m\n"
        fi
    else
        if [ -d "$SLAVE_INSTALL_DIR" ]; then
            echo_log_warn "\033[31m系统中已安装 mysql (Slave) ,请先卸载后再安装\033[0m\n"
        elif [ ! -d "$INSTALL_DIR" ]; then
            echo_log_warn "\033[31m系统中未安装 mysql (Master) ,请先安装后再安装 mysql (Slave)\033[0m\n"  
        fi
    fi

    mysql_root_password=""
    while [ ${#mysql_root_password} -lt 4 ]; do
        read -rp "请输入需要设置 MySQL 的 root 密码>=4位：" mysql_root_password
        if [ ${#mysql_root_password} -lt 4 ]; then
            echo_log_info "\033[31mMySQL root 密码>=4位,请重新输入\033[0m\n"
        fi
    done
    
    if [ $num -eq 1 ]; then
        sed -i 's/enforcing/disabled/' /etc/selinux/config && setenforce 0 >/dev/null 2>&1
        echo
        echo_log_info "清理系统默认 mysql 和 mariadb"
        rpm -qa | grep mysql | xargs rpm -e --nodeps >/dev/null 2>&1
        rpm -qa | grep mariadb | xargs rpm -e --nodeps >/dev/null 2>&1

        echo_log_info "安装 mysql 依赖"
        yum -y install wget libaio >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "\033[33m安装依赖成功\033[0m" ||  echo_log_error "\033[31m安装依赖失败,请检查网络连接\033[0m"

        echo_log_info "\033[32m开始安装 mysql ${MYSQL_VER} (Master)...\033[0m"
    else
        echo_log_info "\033[32m开始安装 mysql ${MYSQL_VER} (Slave)...\033[0m"
    fi

    # 判断工作目录是否存在
    [ ! -d "$WORK_DIR" ] && mkdir -p "$WORK_DIR"
    # 判断 mysql 源码包是否存在，如果不存在则下载
    if [ ! -f "$WORK_DIR/$MYSQL_SOURCE" ]; then
        # 判断内部源和外部源下载地址哪个有效
        if check_url "$INTERNAL_MYSQL_URL"; then
            echo_log_info "从内部源下载 mysql 源码包 $INTERNAL_MYSQL_URL"
            wget -qP "$WORK_DIR" $INTERNAL_MYSQL_URL >/dev/null 2>&1
        elif check_url "$EXTERNAL_MYSQL_URL"; then
            echo_log_info "从外部源下载 mysql 源码包 $EXTERNAL_MYSQL_URL"
            wget -qP "$WORK_DIR" $EXTERNAL_MYSQL_URL >/dev/null 2>&1
        else
            echo_log_error "\033[31m下载 mysql 源码包失败,请检查内部源或外部源下载地址是否正确\033[0m"
        fi
    fi

    # 判断安装主从数据库
    [ $num -eq 1 ] && { local INSTALL_PATH=$INSTALL_DIR; local LINK_PATH=$LINK_DIR; } || { local INSTALL_PATH=$SLAVE_INSTALL_DIR; local LINK_PATH=$SLAVE_LINK_DIR; }
    
    echo_log_info "创建 mysql 安装路径 \033[33m$INSTALL_PATH\033[0m" && mkdir -p "$INSTALL_PATH"

    echo_log_info "正在解压文件 $MYSQL_SOURCE 到 \033[33m$INSTALL_PATH\033[0m 安装路径下"
    tar -xzf "$WORK_DIR/$MYSQL_SOURCE" -C $INSTALL_PATH

    echo_log_info "创建 mysql 软链接 \033[33m{${INSTALL_PATH}/${MYSQL_SOURCE%.tar.gz}} -> {${LINK_PATH}}\033[0m"
    cd $INSTALL_PATH && ln -s "${MYSQL_SOURCE%.tar.gz}" ${LINK_PATH}
    
    mkdir ${LINK_PATH}/{logs,data,tmp,binlog} && echo_log_info "创建 mysql 所需的数据目录 \033[33m{logs,data,tmp,binlog}\033[0m"

    if [ $num -eq 1 ]; then
        # 检查mysql用户是否存在
        if id "mysql" &>/dev/null; then
            userdel -r mysql &>/dev/null
        fi
        echo_log_info "创建 mysql 用户" && useradd -r -s /sbin/nologin -M mysql
    fi

    echo_log_info "设置 mysql 安装目录所有权为 \033[33mmysql\033[0m 用户" && chown -R mysql:mysql ${INSTALL_PATH}

    if [ $num -eq 1 ]; then
        if ! grep -q "MYSQL_HOME=" /etc/profile; then
            echo_log_info "配置 mysql 环境变量"
            cat >> /etc/profile <<EOF
# MySQL
export MYSQL_HOME=${LINK_PATH}
export PATH=\$MYSQL_HOME/bin:\$PATH
EOF
            source /etc/profile
        fi        
        echo_log_info "查看 mysql 版本为 \033[33m$(mysql --version 2>&1 | awk '{print $3}')\033[0m"
    fi

    echo_log_info "创建 mysql 配置文件"
    cat >$LINK_PATH/my.cnf <<EOF
# mysql ${MYSQL_VER}
[mysql]
default-character-set=utf8

[mysqld]
server_id  = $num
user       = mysql
port       = $(( 3305 + $num ))
datadir    = $LINK_PATH/data
tmpdir     = $LINK_PATH/tmp
socket     = $LINK_PATH/tmp/mysql.sock
log_error  = $LINK_PATH/logs/mysqld.log
pid_file   = $LINK_PATH/tmp/mysqld.pid
log_bin    = $LINK_PATH/binlog/mysql-bin.log

character_set_server  = utf8mb4
collation_server      = utf8mb4_unicode_ci
skip-grant-tables     = 0
authentication_policy = mysql_native_password
log_bin_trust_function_creators = 1

[client]
port = $(( 3305 + $num ))
default-character-set = utf8
socket = $LINK_PATH/tmp/mysql.sock
EOF

    # 初始化数据库
    echo_log_info "初始化 mysql 数据库"
    ${LINK_PATH}/bin/mysqld --initialize-insecure --user=mysql --basedir=${LINK_PATH} --datadir=${LINK_PATH}/data
    [ $? -ne 0 ] && echo_log_error "\033[31m初始化数据库失败\033[0m"

    # 设置mysql systemd服务
    [ $num -eq 1 ] && { local service_name="mysqld"; echo_log_info "配置 mysql systemd 服务"; } || { local service_name="mysqld-slave"; echo_log_info "配置 mysql-slave systemd 服务"; }
    cat > /etc/systemd/system/${service_name}.service <<EOF
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target

[Service]
User=mysql
Group=mysql
ExecStart=${LINK_PATH}/bin/mysqld --defaults-file=${LINK_PATH}/my.cnf
LimitNOFILE=65535

Restart=on-failure
RestartPreventExitStatus=1
PrivateTmp=false

[Install]
WantedBy=multi-user.target
EOF
    [ $? -ne 0 ] && echo_log_error "\033[31m创建 ${service_name}.service 文件失败\033[0m"
 
    echo_log_info "启动 ${service_name} 服务"
    systemctl daemon-reload && systemctl start ${service_name} >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "\033[31m启动 ${service_name} 服务失败\033[0m"
    systemctl enable ${service_name} >/dev/null 2>&1
    
    sleep 3
    # 设置mysql root 密码
    echo && echo_log_info "设置 MySQL root 密码..."
    ${LINK_PATH}/bin/mysql -uroot -S$LINK_PATH/tmp/mysql.sock <<EOF
use mysql;
update user set host='%' where user='root';
flush privileges;
alter user 'root'@'%' identified by '$mysql_root_password';
flush privileges;
EOF

    if [ $? -eq 0 ]; then
        echo_log_info "设置 MySQL root 密码 \033[33m${mysql_root_password}\033[0m 成功"
        [ $num -eq 1 ] && echo "export MYSQL_PASSWD=${mysql_root_password}" >> /etc/profile || echo "export SLAVE_MYSQL_PASSWD=${mysql_root_password}" >> /etc/profile
        source /etc/profile
    else
        echo_log_error "\033[31m设置 MySQL root 密码失败,检查并再执行脚本,重置 root 密码\033[0m"
    fi
}

# 配置mysql主从复制
function config_mysql_rep() {
    if [ ! -d "$INSTALL_DIR" ]; then
        echo_log_error "\033[31m系统中未安装 mysql (Master)\033[0m\n"
    elif [ ! -d "$SLAVE_INSTALL_DIR" ]; then
        echo_log_error "\033[31m系统中未安装 mysql (Slave) ,清先安装后再配置 mysql 主从复制\033[0m\n"
    fi

    tempfile=$(mktemp)
    ${LINK_DIR}/bin/mysql -uroot -p${MYSQL_PASSWD} -e "use mysql; select user from user where user = 'rep';" >/dev/null 2>&1 > $tempfile
    # 判断用户是否存在，即文件是否非空
    if [ ! -s $tempfile ]; then
        rep_password=""
        while [ ${#rep_password} -lt 4 ]; do
            read -rp "请输入需要设置MySQL主从复制的 rep 用户密码>=4位：" rep_password
            if [ ${#rep_password} -lt 4 ]; then
                echo_log_info "\033[31mMySQL rep 用户密码>=4位,请重新输入\033[0m\n"
            fi
        done

        echo_log_info "在 mysql (Master) 上创建 \033[33mrep\033[0m 复制用户"
        ${LINK_DIR}/bin/mysql -uroot -p${MYSQL_PASSWD} >/dev/null 2>&1 <<EOF
create user 'rep'@'%' identified by '$rep_password';
flush privileges;
EOF
        [ $? -ne 0 ] && echo_log_error "\033[31m创建 rep 用户失败\033[0m"

        echo_log_info "授予 rep 用户 \033[33mREPLICATION SLAVE\033[0m 权限"
        ${LINK_DIR}/bin/mysql -uroot -p${MYSQL_PASSWD} >/dev/null 2>&1 <<EOF
grant REPLICATION SLAVE on *.* to 'rep'@'%';
flush privileges;
EOF
        [ $? -ne 0 ] && echo_log_error "\033[31m授权 rep 用户失败\033[0m"
    fi

    if ! grep -q "MYSQL_REP_PASSWD=" /etc/profile; then
        echo "export MYSQL_REP_PASSWD=${rep_password}" >> /etc/profile
        source /etc/profile
    fi

    echo_log_info "\033[32m开始配置 mysql 主从复制...\033[0m" && sleep 1
    
    echo_log_info "获取 mysql (Master) 的binlog文件名和位置"

    ${LINK_DIR}/bin/mysql -uroot -p${MYSQL_PASSWD} -e "show master status\G;" >/dev/null 2>&1 > $tempfile
    binfile=$(grep "File" $tempfile | awk -F': ' '{print $2}') && pos=$(grep "Position" $tempfile | awk -F': ' '{print $2}')
    echo_log_info "binlog文件名为\033[33m $binfile \033[0m,位置为\033[33m $pos \033[0m"
    
    rm -f $tempfile && sleep 2

    echo_log_info "在 mysql (Slave) 上配置主从复制"
    [ -z $rep_password ] && rep_password=${MYSQL_REP_PASSWD}
    ${LINK_DIR}/bin/mysql -uroot -p${SLAVE_MYSQL_PASSWD} -S${SLAVE_LINK_DIR}/tmp/mysql.sock >/dev/null 2>&1 <<EOF
stop slave;
change master to
master_host='127.0.0.1',
master_user='rep',
master_password='${rep_password}',
master_log_file='${binfile}',
master_log_pos=${pos};
EOF
    [ $? -ne 0 ] && echo_log_error "\033[31m配置主从复制失败\033[0m"
    sleep 1

    echo_log_info "开启主从复制"
    ${LINK_DIR}/bin/mysql -uroot -p${SLAVE_MYSQL_PASSWD} -S${SLAVE_LINK_DIR}/tmp/mysql.sock -e "start slave;" >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "\033[31m开启主从复制失败\033[0m"

    echo_log_info "检查复制状态"
    tempfile=$(mktemp)
    ${LINK_DIR}/bin/mysql -uroot -p${SLAVE_MYSQL_PASSWD} -S${SLAVE_LINK_DIR}/tmp/mysql.sock -e "show slave status\G;" >/dev/null 2>&1 > $tempfile 
    io_run=$(grep 'Slave_IO_Running:' $tempfile | awk -F': ' '{print $2}') && sql_run=$(grep 'Slave_SQL_Running:' $tempfile | awk -F': ' '{print $2}')
    rm -f $tempfile
    
    sleep 1
    if [ ${io_run} == "Yes" ] && [ ${sql_run} == 'Yes' ]; then
        echo_log_info "mysql 主从状态\033[33m 正常\033[0m"
    else
        echo_log_error "mysql 主从状态\033[31m 不正常 \033[0m,检查并再执行脚本,配置 mysql 主从复制"
    fi
}

# 检测主从复制状态
function check_ps_status() {
    if [ ! -d "$INSTALL_DIR" ]; then
        echo_log_error "\033[31m系统中未安装 mysql (Master)\033[0m\n"
    elif [ ! -d "$SLAVE_INSTALL_DIR" ]; then
        echo_log_error "\033[31m系统中未安装 mysql (Slave) ,清先安装后再检测主从复制状态\033[0m\n"
    fi

    echo_log_info "\033[32m开始检测主从复制状态...\033[0m"

    tempfile=$(mktemp)
    ${LINK_DIR}/bin/mysql -uroot -p${SLAVE_MYSQL_PASSWD} -S${SLAVE_LINK_DIR}/tmp/mysql.sock -e "show slave status\G;" >/dev/null 2>&1 > $tempfile 
    io_run=$(grep 'Slave_IO_Running:' $tempfile | awk -F': ' '{print $2}') && sql_run=$(grep 'Slave_SQL_Running:' $tempfile | awk -F': ' '{print $2}')
    rm -f $tempfile

    sleep 1
    if [ ${io_run} == "Yes" ] && [ ${sql_run} == 'Yes' ]; then
        echo_log_info "mysql 主从状态\033[33m 正常\033[0m"
    else
        echo_log_error "mysql 主从状态\033[31m 不正常 \033[0m,检查并再执行脚本,配置 mysql 主从复制"
    fi
}

# 卸载mysql
function remove_mysql() {
    if [ $num -eq 5 ]; then
        [ ! -d "$INSTALL_DIR" ] && echo_log_warn "\033[31m系统中已卸载 mysql (Master) ,请先安装后再卸载\033[0m\n"
        
        local INSTALL_PATH=$INSTALL_DIR
        local LINK_PATH=$LINK_DIR
        local service_name="mysqld"

        echo_log_info "\033[32m开始卸载 MYSQL ${MYSQL_VER} (Master)...\033[0m"
        echo_log_info "停止 mysql 服务"

        sed -i '/export MYSQL_PASSWD/d' /etc/profile
        sed -i '/export MYSQL_REP_PASSWD/d' /etc/profile
    else
        [ ! -d "$SLAVE_INSTALL_DIR" ] && echo_log_warn "\033[31m系统中已卸载 mysql (Slave) ,请先安装后再卸载\033[0m\n"

        local INSTALL_PATH=$SLAVE_INSTALL_DIR
        local LINK_PATH=$SLAVE_LINK_DIR
        local service_name="mysqld-slave"

        echo_log_info "\033[32m开始卸载 MYSQL ${MYSQL_VER} (Slave)...\033[0m"
        echo_log_info "停止 mysql-slave 服务"

        sed -i '/export SLAVE_MYSQL_PASSWD/d' /etc/profile
    fi
    
    systemctl stop $service_name >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "\033[31m停止 ${service_name} 服务失败\033[0m"

    rm -rf /etc/systemd/system/${service_name}.service && systemctl daemon-reload && echo_log_info "删除 ${service_name} systemd 服务"
    rm -rf $INSTALL_PATH && echo_log_info "删除 mysql 安装目录"
    rm -rf $LINK_PATH/my.cnf && echo_log_info "删除 mysql 配置文件"

    [ $num -eq 5 ] && sed -i '/# MySQL/,/$MYSQL_HOME\/bin:$PATH/d' /etc/profile
    source /etc/profile && echo_log_info "删除 mysql 环境变量"
}

# 退出工具
function quit() {
    echo_log_info "\033[33m退出安装工具\033[0m\n"
    exit 0
}

main

