#!/bin/bash

read -rp "请输入安装 PHP 的版本号(默认为 8.3.11)：" PHP_VER
[ -z "$PHP_VER" ] && PHP_VER="8.3.11"
PHP_SOURCE="php-${PHP_VER}.tar.gz"
PHP_DATA_DIR="/usr/local/php"
WORK_DIR="/tmp"
PHP_URL="http://mirrors.sunline.cn/source/php/${PHP_SOURCE}"
APXS_PATH=$(source /etc/profile && which apxs 2>/dev/null)

LIBZIP_VER="1.10.1"
LIBZIP_SOURCE="libzip-${LIBZIP_VER}.tar.gz"
LIBZIP_DATA_DIR="/usr/local/libzip"
LIBZIP_URL="http://mirrors.sunline.cn/source/libzip/${LIBZIP_SOURCE}"

CMAKE_VER="3.30.8"
CMAKE_SOURCE="cmake-${CMAKE_VER}-linux-$(uname -m).tar.gz"
CMAKE_DATA_DIR="/usr/local/cmake"
CMAKE_URL="http://mirrors.sunline.cn/source/cmake/${CMAKE_SOURCE}"

echo_log_info() {
    echo -e "$(date +'%F %T') - [Info] $*"
}
echo_log_warn() {
    echo -e "$(date +'%F %T') - [Warn] $*"
    rm -f $tempfile && exit 1
}
echo_log_error() {
    echo -e "$(date +'%F %T') - [Error] $*"
    rm -f $tempfile && exit 1
}

check_url() {
    curl --head --silent --fail --connect-timeout 5 "$1" > /dev/null
    [ $? -ne 0 ] && echo_log_error "\033[31m$2下载地址无效,请检查下载地址是否正确或该版本是否存在\033[0m"
}

close_fw() {
    if firewall-cmd --state &>/dev/null; then
        echo_log_info "关闭防火墙"
        systemctl stop firewalld && systemctl disable firewalld >/dev/null 2>&1
    fi
    if ! grep -q 'SELINUX=disabled' /etc/selinux/config; then
        echo_log_info "关闭selinux"
        sed -i 's/enforcing/disabled/' /etc/selinux/config
        setenforce 0 &>/dev/null
    fi
}

depend_judge() {
    rpm -q $@ &>/dev/null && return || echo_log_info "安装依赖"
    for arg in $@; do
        if [[ "$arg" == "gcc" ]]; then
            which $arg &>/dev/null || yum install -y $arg &>/dev/null
        elif [[ "$arg" == "gcc-c++" ]]; then
            which g++ &>/dev/null || yum install -y $arg &>/dev/null
        else
            rpm -q $arg &>/dev/null || yum install -y $arg &>/dev/null
        fi
        [ $? -ne 0 ] && return 1
    done
    return 0
}

enter_find_error() {
    echo -e "$(date +'%F %T') - [Error] $1"
    read && vim $2
    rm -f $2 && exit 1
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m php${PHP_VER} 安装工具\033[0m
———————————————————————————
1. 安装php${PHP_VER}
2. 卸载php${PHP_VER}
3. 退出\n"

    read -rp "请输入序号并回车：" num
    case "$num" in
    1) (check_url "$PHP_URL" "php"; check_url "$LIBZIP_URL" "libzip依赖包"; check_url "$CMAKE_URL" "cmake依赖包"; install_php) ;;
    2) (remove_php) ;;
    3) (quit) ;;
    *) (main) ;;
    esac
}

install_php() {
    if [ -d "$PHP_DATA_DIR" ]; then
        echo_log_warn "\033[31m系统中已安装 php,请先卸载后再安装\033[0m\n"
    fi

    close_fw && echo_log_info "清理系统默认 php"
    rpm -qa | grep php | xargs yum remove -y >/dev/null 2>&1

    if grep -qi "openEuler" /etc/os-release; then
        PKGS="openssl-devel zlib-devel bzip2-devel libffi-devel sqlite-devel gettext-devel \
        oniguruma-devel libsodium-devel xz-devel libxml2-devel libcurl-devel libicu-devel boost-devel \
        libevent-devel gd-devel openjpeg2-devel freetype-devel libgcrypt-devel libjpeg-devel libpng-devel \
        libgpg-error-devel libxslt-devel libmcrypt-devel recode-devel pcre-devel readline-devel perl-devel libjpeg-turbo-devel"
    else
        PKGS="openssl-devel zlib-devel bzip2-devel libffi-devel sqlite-devel gettext-devel \
        oniguruma-devel libsodium-devel xz-devel libxml2-devel libcurl-devel libicu-devel boost-devel \
        libevent-devel gd-devel openjpeg-devel freetype-devel libgcrypt-devel libjpeg-devel libpng-devel \
        libgpg-error-devel libxslt-devel libmcrypt-devel recode-devel pcre-devel readline-devel perl-devel libjpeg-turbo-devel"
    fi

    depend_judge $PKGS

    && install_cmake && install_libzip
    [ $? -ne 0 ] && echo_log_error "\033[31m安装依赖失败,请检查网络连接\033[0m"

    echo_log_info "\033[32m开始安装 php ${PHP_VER}...\033[0m" && source /etc/profile

    echo_log_info "下载并解压源码包"
    [ -d "$WORK_DIR/${PHP_SOURCE%.tar.gz}" ] && rm -rf $WORK_DIR/${PHP_SOURCE%.tar.gz}
    wget -qP $WORK_DIR $PHP_URL &>/dev/null && tar -xzf $WORK_DIR/$PHP_SOURCE -C $WORK_DIR && rm -f $WORK_DIR/$PHP_SOURCE

    echo -e -n "$(date +'%F %T') - [Info] 是否需要在编译时添加 Apache 扩展参数？\033[33m(如需要请先确保已安装Apache)\033[0m (y/n) " && read -r answer
    while [[ "$answer" != "y" && "$answer" != "n" ]]; do
        echo -e -n "$(date +'%F %T') - [Info] 请重新输入(y/n) "
        read -r answer
    done

    if [[ "$answer" = "y" ]]; then
        if source /etc/profile && ! which apxs &>/dev/null; then
            echo_log_info "\033[33m系统检测到未安装 Apache,无法添加 Apache 扩展参数\033[0m"
            echo -e -n "$(date +'%F %T') - [Info] 是否继续执行编译 php ？(y/n) " && read -r answer2
            while [[ "$answer2" != "y" && "$answer2" != "n" ]]; do
                echo -e -n "$(date +'%F %T') - [Info] 请重新输入(y/n) "
                read -r answer2
            done
            [[ "$answer2" = "n" ]] && quit
        fi
    fi

    echo_log_info "编译并安装 php"
    tempfile=$(mktemp) && cd $WORK_DIR/${PHP_SOURCE%.tar.gz}
    if [[ "$answer" = "y" && "$answer2" != "y" ]]; then
        ./configure \
        --prefix=$PHP_DATA_DIR --with-config-file-path=$PHP_DATA_DIR/etc --with-fpm-user=php --with-fpm-group=php --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-fpm \
        --enable-mbstring --enable-shared --enable-soap --enable-sockets --enable-gd --enable-opcache --enable-xml --enable-bcmath  --enable-calendar --enable-exif \
        --enable-ftp --enable-pcntl --enable-shmop --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-pdo  --enable-mbregex --enable-cli --enable-opcache \
        --enable-intl --disable-ipv6 --disable-debug --with-jpeg  --with-freetype --with-zlib --with-libxml --with-curl --with-openssl --with-bz2 --with-gettext \
        --with-readline --with-pear --with-mhash --with-ldap-sasl --with-xsl --with-zip --with-iconv --with-kerberos --with-libdir=lib64 \
        --with-apxs2=$APXS_PATH \
        > /dev/null 2> $tempfile
    else
        ./configure \
        --prefix=$PHP_DATA_DIR --with-config-file-path=$PHP_DATA_DIR/etc --with-fpm-user=php --with-fpm-group=php --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-fpm \
        --enable-mbstring --enable-shared --enable-soap --enable-sockets --enable-gd --enable-opcache --enable-xml --enable-bcmath  --enable-calendar --enable-exif \
        --enable-ftp --enable-pcntl --enable-shmop --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-pdo  --enable-mbregex --enable-cli --enable-opcache \
        --enable-intl --disable-ipv6 --disable-debug --with-jpeg  --with-freetype --with-zlib --with-libxml --with-curl --with-openssl --with-bz2 --with-gettext \
        --with-readline --with-pear --with-mhash --with-ldap-sasl --with-xsl --with-zip --with-iconv --with-kerberos --with-libdir=lib64 \
        > /dev/null 2> $tempfile
    fi
    [ $? -ne 0 ] && enter_find_error "\033[31m编译 php 失败,请按回车键查看报错信息...\033[0m" "$tempfile" || echo_log_info "\033[33m编译 php 成功\033[0m"

    make -j $(nproc) > /dev/null 2> $tempfile && make install > /dev/null 2> $tempfile
    [ $? -ne 0 ] && echo_log_error "\033[31m安装 php 失败\033[0m" || echo_log_info "\033[33m安装 php 成功\033[0m"

    echo_log_info "配置环境变量"
    cat > /etc/profile.d/php.sh <<EOF
# PHP
export PHP_HOME=$PHP_DATA_DIR
export PATH=\$PHP_HOME/bin:\$PATH
EOF
    source /etc/profile

    if [ ! -z $APXS_PATH ]; then
        echo_log_info "修改 apache 配置文件,使 Apache 支持 PHP"
        grep -q "modules/libphp.so" ${APXS_PATH%/bin/apxs}/conf/httpd.conf || sed -i '66i LoadModule php_module  modules/libphp.so' ${APXS_PATH%/bin/apxs}/conf/httpd.conf
        sed -i 's/DirectoryIndex index.html/DirectoryIndex index.html index.php/g' ${APXS_PATH%/bin/apxs}/conf/httpd.conf
        cat >> ${APXS_PATH%/bin/apxs}/conf/httpd.conf <<EOF
<FilesMatch \.php$>
SetHandler application/x-httpd-php
</FilesMatch>
EOF
        echo_log_info "重启 apache 服务" && systemctl restart httpd >/dev/null 2>&1
    fi
 
    echo_log_info "修改 php 配置文件"
    cp $WORK_DIR/${PHP_SOURCE%.tar.gz}/php.ini-development /usr/local/php/etc/php.ini
    sed -i 's@max_execution_time = 30@max_execution_time = 300@g' ${PHP_DATA_DIR}/etc/php.ini
    sed -i 's@max_input_time = 60@max_input_time = 300@g' ${PHP_DATA_DIR}/etc/php.ini
    sed -i 's@post_max_size = 8M@post_max_size = 500M@g' ${PHP_DATA_DIR}/etc/php.ini
    sed -i 's@memory_limit = 128M@memory_limit = 1024M@g' ${PHP_DATA_DIR}/etc/php.ini
    sed -i 's@upload_max_filesize = 2M@upload_max_filesize = 500M@g' ${PHP_DATA_DIR}/etc/php.ini
    sed -i 's@;date.timezone =@date.timezone = Asia/Shanghai@g' ${PHP_DATA_DIR}/etc/php.ini

    cd && rm -rf $WORK_DIR/${PHP_SOURCE%.tar.gz}
    if id "php" &>/dev/null; then
        userdel -r php &>/dev/null
    fi
    echo_log_info "创建 php-fpm 运行用户 php" && useradd -s /sbin/nologin -M php

    echo_log_info "修改 php-fpm 配置文件,修改 PID 文件路径"
    cd $PHP_DATA_DIR/etc && cp php-fpm.conf.default php-fpm.conf
    sed -i "s@;pid = run/php-fpm.pid@pid = ${PHP_DATA_DIR}/var/run/php-fpm.pid@g" php-fpm.conf

    echo_log_info "修改 www 配置文件,设置运行权限用户为 \033[33mphp\033[0m ,并与站点目录权限一致"
    cd $PHP_DATA_DIR/etc/php-fpm.d && cp www.conf.default www.conf
    sed -i 's/user = php/user = php/g' www.conf
    sed -i 's/group = php/group = php/g' www.conf
    sed -i 's/listen = 127.0.0.1:9000/listen = 127.0.0.1:9000/g' www.conf
    sed -i 's/;listen.owner = php/listen.owner = php/g' www.conf
    sed -i 's/;listen.group = php/listen.group = php/g' www.conf
    sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' www.conf

    cat > /usr/lib/systemd/system/php-fpm.service <<EOF
[Unit]
Description=The PHP FastCGI Process Manager
Documentation=http://php.net/docs.php
After=network.target

[Service]
Type=forking
ExecStart=${PHP_DATA_DIR}/sbin/php-fpm -R
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -SIGINT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    [ $? -ne 0 ] && echo_log_error "\033[31m创建 php-fpm.service 文件失败\033[0m"

    echo_log_info "启动 php-fpm 服务"
    systemctl daemon-reload && systemctl start php-fpm >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "\033[31m启动 php-fpm 服务失败\033[0m"
    systemctl enable php-fpm >/dev/null 2>&1 && rm -f $tempfile
}

remove_php() {
    if [ ! -d "$PHP_DATA_DIR" ]; then
        echo_log_warn "\033[31m系统中已卸载 php,请先安装后再卸载\033[0m\n"
    fi

    echo_log_info "\033[32m开始卸载 php ${PHP_VER}...\033[0m"

    echo_log_info "停止 php-fpm 服务"
    systemctl stop php-fpm >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "\033[31m停止 php-fpm 服务失败\033[0m"

    rm -rf /usr/lib/systemd/system/php-fpm.service && systemctl daemon-reload && echo_log_info "删除 php-fpm systemd 服务"
    rm -rf $PHP_DATA_DIR && echo_log_info "删除 php 安装目录"
    rm -f /etc/profile.d/php.sh && source /etc/profile && echo_log_info "删除 php 环境变量"

    if [ ! -z $APXS_PATH ]; then
        echo_log_info "修改 apache 配置文件,删除 Apache 支持 PHP"
        sed -i '/modules\/libphp.so/d' ${APXS_PATH%/bin/apxs}/conf/httpd.conf
        sed -i 's/DirectoryIndex index.html index.php/DirectoryIndex index.html/g' ${APXS_PATH%/bin/apxs}/conf/httpd.conf
        sed -i '/<FilesMatch \\.php\$>/,/<\/FilesMatch>/d' ${APXS_PATH%/bin/apxs}/conf/httpd.conf
        echo_log_info "重启 apache 服务" && systemctl restart httpd >/dev/null 2>&1
    fi
}

install_cmake() {
    [ -d "$CMAKE_DATA_DIR" ] && return

    rpm -qa | grep cmake | xargs yum remove -y >/dev/null 2>&1

    wget -qP "$WORK_DIR" $CMAKE_URL >/dev/null 2>&1

    mkdir -p $CMAKE_DATA_DIR
    tar -xzf "$WORK_DIR/$CMAKE_SOURCE" -C $CMAKE_DATA_DIR && rm -rf $WORK_DIR/$CMAKE_SOURCE

    cd $CMAKE_DATA_DIR && ln -s ${CMAKE_SOURCE%.tar.gz} cmake

    cat > /etc/profile.d/cmake.sh <<EOF
# Cmake
export CMAKE_HOME=$CMAKE_DATA_DIR/cmake
export PATH=\$PATH:\$CMAKE_HOME/bin
EOF
    source /etc/profile
}

install_libzip() {
    [ -d "$LIBZIP_DATA_DIR" ] && return

    rpm -qa | grep libzip | xargs yum remove -y >/dev/null 2>&1

    [ -d "$WORK_DIR/${LIBZIP_SOURCE%.tar.gz}" ] && rm -rf $WORK_DIR/${LIBZIP_SOURCE%.tar.gz}
    wget -qP $WORK_DIR $LIBZIP_URL &>/dev/null && tar -xzf $WORK_DIR/$LIBZIP_SOURCE -C $WORK_DIR && rm -f $WORK_DIR/$LIBZIP_SOURCE

    mkdir $WORK_DIR/${LIBZIP_SOURCE%.tar.gz}/build && cd $WORK_DIR/${LIBZIP_SOURCE%.tar.gz}/build
    cmake .. \
    -DCMAKE_INSTALL_PREFIX=$LIBZIP_DATA_DIR \
    -DENABLE_OPENSSL=on \
    -DENABLE_GNUTLS=off \
    -DENABLE_MBEDTLS=off \
    >/dev/null 2>&1

    make -j $(nproc) > /dev/null 2>&1 && make install > /dev/null 2>&1

    echo "${LIBZIP_DATA_DIR}/lib64" | sudo tee -a /etc/ld.so.conf.d/libzip.conf >/dev/null 2>&1
    ldconfig

    cd && rm -rf $WORK_DIR/${LIBZIP_SOURCE%.tar.gz}
    cat > /etc/profile.d/libzip.sh <<EOF
# libzip
export PATH=${LIBZIP_DATA_DIR}/bin:\$PATH
export PKG_CONFIG_PATH=${LIBZIP_DATA_DIR}/lib64/pkgconfig:\$PKG_CONFIG_PATH
EOF
    source /etc/profile
}

quit() {
    echo_log_info "\033[33m退出安装工具\033[0m\n"
    exit 0
}

main
