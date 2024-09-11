#!/bin/bash

#Install MySQL Script
#官网下载地址:https://downloads.mysql.com/archives/community/
# \033[33m 表示黄色， \033[32m 表示绿色， \033[31m 表示红色， \033[0m 表示恢复样式

Down_DIR="/usr/local/src"
MYSQL_VERSION="8.0.34"
MYSQL_TAR="mysql-$MYSQL_VERSION-linux-glibc2.17-x86_64.tar.gz"
EXTERNAL_MYSQL_URL="https://downloads.mysql.com/archives/get/p/23/file/$MYSQL_TAR"
INTERNAL_MYSQL_URL="http://10.24.1.133/Linux/MySQL/$MYSQL_TAR"
MYSQL_ROOT_PWD="sunline"
MYSQL_INSTALL_DIR="/usr/local/mysql"
MYSQL_DATA_DIR="/data/mysql"
MYSQL_CONFIG_FILE="/etc/my.conf"


function echo_log_info() {
    echo -e "$(date +'%F %T') -[INFO] $*"
}
function echo_log_warn() {
    echo -e "$(date +'%F %T') -[WARN] $*"
}
function echo_log_error() {
    echo -e "$(date +'%F %T') -[ERROR] $*"
    exit 1
}


function main() {
  clear
  echo -e "———————————————————————————
\033[32m Mysql${MYSQL_VER} 安装工具\033[0m
———————————————————————————
1. 安装MYSQL${MYSQL_VER}
2. 卸载MYSQL${MYSQL_VER}
3. 退出\n"

  read -rp "请输入序号并回车：" num
  case "$num" in
  1) (install_source_mysql) ;;
  2) (remove_source_mysql) ;;
  3) (quit) ;;
  *) (main) ;;
  esac
}


function check_url() {
    local url=$1
    if curl --head --silent --fail "$url" > /dev/null; then
        return 0  # URL 有效
    else
        return 1  # URL 无效
    fi
}

function download_mysql() {
    if [ ! -f "$Down_DIR/$MYSQL_TAR" ]; then
        if check_url "$INTERNAL_MYSQL_URL"; then
            echo_log_info "\033[33mINTERNAL_MYSQL_URL链接有效，准备开始下载 $MYSQL_TAR...\033[0m"
            wget -P "$Down_DIR" "$INTERNAL_MYSQL_URL" &>/dev/null 2>&1
            [ $? -eq 0 ] && echo_log_info "\033[32m$MYSQL_TAR下载成功...\033[0m" || { echo_log_error "\033[31m$MYSQL_TAR下载失败...请检查URL是否正确!\033[0m"; }
        else
            echo_log_error "\033[31mINTERNAL_MYSQL_URL无效，将检查外部链接是否有效...\033[0m"
            if check_url "$EXTERNAL_MYSQL_URL"; then
                echo_log_info "EXTERNAL_MYSQL_URL有效，准备开始下载 $MYSQL_TAR"
                wget -P "$Down_DIR" "$EXTERNAL_MYSQL_URL" &>/dev/null 2>&1
                [ $? -eq 0 ] && echo_log_info "\033[32m$MYSQL_TAR下载成功...\033[0m" || { echo_log_error "\033[31m$MYSQL_TAR下载失败...请检查URL是否正确!\033[0m"; }
            else
                echo_log_error "\033[31m两个下载链接都无效，$MYSQL_TAR下载失败...请检查URL...\033[0m"
                return 1
            fi
        fi
    else
        echo_log_info "\033[32m安装包$MYSQL_TAR已存在，跳过下载！\033[0m"
    fi  
}



function install_source_mysql() {
    download_mysql
    if [ -d $Down_DIR/mysql-$MYSQL_VERSION ]; then
        echo_log_info "\033[32检测到mmysql-$MYSQL_VERSION旧文件目录,准备清理该文件夹...\033[0m"
        rm -rf $Down_DIR/mysql-$MYSQL_VERSION
    fi
    cd $Down_DIR || exit 1
    tar -zxvf $MYSQL_TAR >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "解压成功" || { echo_log_info "解压失败"; }
  
    # 检查mysql用户是否存在
    if id "mysql" &>/dev/null; then
        echo_log_info "\033[33mmysql 用户已存在,跳过创建...\033[0m"
    else
        useradd -s /sbin/nologin mysql
        [ $? -eq 0 ] && echo_log_info "\033[33mmysql 用户创建成功.\033[0m" || { echo_log_error "\033[31m创建 mysql 用户失败.\033[0m"; }
    fi

    #创建mysql目录
    mkdir -p $MYSQL_DATA_DIR
    echo_log_info "$MYSQL_DATA_DIR 目录创建成功"
    chown -R mysql $MYSQL_DATA_DIR
    echo_log_info "目录 $MYSQL_DATA_DIR 赋权成功"

    if [ -f $MYSQL_CONFIG_FILE ]; then
        echo "mysql配置文件已存在，删除"
        rm -f $MYSQL_CONFIG_FILE
    fi
    if [ -f /tmp/mysqld.service ]; then
        echo_log_info "/tmp/mysqld.service文件已存在，删除文件"
        rm -rf /tmp/mysqld.service
    fi
    cat > /tmp/my.conf <<EOF
[mysqld]
user = mysql
port = 3306
server_id = 1
basedir = ${MYSQL_INSTALL_DIR}
datadir = ${MYSQL_DATA_DIR}
socket = ${MYSQL_INSTALL_DIR}/mysql-master.sock
pid-file = ${MYSQL_INSTALL_DIR}/mysqld.pid
log-error = ${MYSQL_INSTALL_DIR}/mysql.err
EOF    

    /bin/mv /tmp/my.conf $MYSQL_CONFIG_FILE
    echo_log_info "开始安装依赖"
    yum install -y ncurses-compat-libs-6.1-9.20180224.el8.x86_64  libaio-devel
    echo_log_info "开始初始化"
    
    if [ -f /etc/systemd/system/mysqld.service ]; then
        rm -rf /etc/systemd/system/mysqld.service
    fi
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
ExecStart=${MYSQL_INSTALL_DIR}/bin/mysqld --defaults-file=$MYSQL_CONFIG_FILE --daemonize \$OPTIONS
ExecReload=/bin/kill -HUP -\$MAINPID
ExecStop=/bin/kill -QUIT \$MAINPID
KillMode=process
LimitNOFILE=65535
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=1
PrivateTmp=false
EOF
    
    systemctl daemon-reload
    systemctl start mysqld
    systemctl enable mysqld
    if [ $? -eq 0 ]; then
        echo "启动mysql成功"
    fi
    ${MYSQL_INSTALL_DIR}/bin/mysqladmin -S/tmp/mysql-master.sock -uroot  password ${MYSQL_ROOT_PWD}
        if [ $? -eq 0 ]; then
        echo "密码设置成功成功"
    fi
}


function remove_source_mysql() {
    sudo systemctl disable mysqld
    sudo systemctl stop mysqld
    rm -rf $MYSQL_INSTALL_DIR
    rm -rf $MYSQL_CONFIG_FILE
    rm -rf /etc/systemd/system/mysqld.service
}

# 退出工具
function quit() {
  echo_log_info "\033[33m退出安装工具\033[0m"
  exit 0
}


main