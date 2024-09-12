#!/bin/bash
#
# Install nginx script
# 官网下载：http://nginx.org/download/nginx-<version>.tar.gz
# \033[33m 表示黄色，\033[32m 表示绿色，\033[31m 表示红色，\033[0m 表示恢复样式

set -e

#全局变量
Down_DIR="/usr/local/src"


#nginx变量
NGINX_VERSION="1.21.6"
NGINX_TAR="nginx-$NGINX_VERSION.tar.gz"
INTERNAL_NGINX_URL="http://10.24.1.133/Linux/nginx/$NGINX_TAR"
EXTERNAL_NGINX_URL="http://nginx.org/download/$NGINX_TAR"

function install_nginx() {

    if command -v nginx >/dev/null 2>&1; then
        echo "Nginx already installed."
        exit 0
    fi

    mkdir -p /usr/local/nginx /var/log/nginx /var/cache/nginx /var/spool/nginx/{client_temp,proxy_temp,fastcgi_temp,uwsgi_temp,scgi_temp}
    if [ $? -ne 0 ]; then
        echo "创建目录失败。"
        exit 1
    fi
    useradd -r -d /usr/local/nginx -s /sbin/nologin nginx
    if [ $? -ne 0 ]; then
        echo "创建用户失败。"
        exit 1
    fi

    chown -R nginx:nginx /usr/local/nginx /var/log/nginx /var/cache/nginx
    if [ $? -ne 0 ]; then
        echo "修改目录所有者失败。"
        exit 1
    fi

    if [ ! -f "$Down_DIR/$NGINX_TAR" ]; then
        echo "从内部源下载 Nginx..."
        wget -P "$Down_DIR" "$INTERNAL_NGINX_URL"
        if [ $? -eq 0 ]; then
            echo "从内部源下载失败，正在尝试外部源..."
            wget -P "$Down_DIR" "$EXTERNAL_NGINX_URL"
            if [ $? -eq 0 ]; then
                echo "无法从外部源下载 Nginx。"
                exit 1
            fi
        fi
        echo "下载成功！"
    else
        echo "Nginx已下载。"
        if [ -d "$Down_DIR/nginx-$NGINX_VERSION" ]; then
            echo "检测到旧的Nginx目录，正在清理..."
            rm -rf "$Down_DIR/nginx-$NGINX_VERSION"
        fi
        echo "正在解压Nginx..."
        tar -zxvf "$Down_DIR/nginx-$NGINX_VERSION.tar.gz" -C "$Down_DIR"
        if [ $? -eq 0 ]; then
            echo "解压成功！"
        else
            echo "解压失败。"
            exit 1
        fi
    fi

    cd "$Down_DIR/nginx-$NGINX_VERSION"
    ./configure \
    --prefix=/usr/local/nginx \
    --sbin-path=/usr/local/nginx/sbin/nginx \
    --conf-path=/usr/local/nginx/conf/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-threads \
    --with-file-aio \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module \
    --with-stream_ssl_preread_module \
    --with-openssl=/usr/local/src/openssl-1.1.1w \
    --with-openssl-opt="no-weak-ssl-ciphers no-ssl3 no-ssl3-method no-tls1 no-tls1_1" \
    --with-cc-opt="-I/usr/local/openssl/include" \
    --with-ld-opt="-L/usr/local/openssl/lib -Wl,-rpath,/usr/local/openssl/lib"

    if [ $? -ne 0 ]; then
        echo "Nginx编译失败..."
        exit 1
    fi
    make -j $(nproc)
    make install
    if [ $? -ne 0 ]; then
        echo "Nginx安装失败..."
        exit 1
    fi
    #以超级用户身份运行整个命令(sudo bash -c)
    sudo bash -c 'cat > /etc/systemd/system/nginx.service <<'EOF'
    [Unit]
    Description=The NGINX HTTP and reverse proxy server
    After=network.target remote-fs.target nss-lookup.target

    [Service]
    Type=forking
    PIDFile=/var/run/nginx.pid
    ExecStartPre=/usr/local/nginx/sbin/nginx -t
    ExecStart=/usr/local/nginx/sbin/nginx
    ExecReload=/usr/local/nginx/sbin/nginx -s reload
    ExecStop=/bin/kill -s QUIT $MAINPID
    PrivateTmp=true

    [Install]
    WantedBy=multi-user.target
    EOF'

    # 检查写入是否成功
    if [ $? -ne 0 ]; then
        echo "无法创建 nginx.service 文件"
        exit 1
    fi
    sudo systemctl daemon-reload
    sudo systemctl start nginx
    sudo systemctl enable nginx
    if [ $? -ne 0 ]; then
        echo "Nginx启动失败"
        exit 1
    fi
    echo "Nginx 安装并启动成功"
}
#nginx变量
NGINX_VERSION="1.21.6"
NGINX_TAR="nginx-$NGINX_VERSION.tar.gz"
INTERNAL_NGINX_URL="http://10.24.1.133/Linux/nginx/$NGINX_TAR"
EXTERNAL_NGINX_URL="http://nginx.org/download/$NGINX_TAR"

function install_nginx() {

    if command -v nginx >/dev/null 2>&1; then
        echo "Nginx already installed."
        exit 0
    fi

    mkdir -p /usr/local/nginx /var/log/nginx /var/cache/nginx /var/spool/nginx/{client_temp,proxy_temp,fastcgi_temp,uwsgi_temp,scgi_temp}
    if [ $? -ne 0 ]; then
        echo "创建目录失败。"
        exit 1
    fi
    useradd -r -d /usr/local/nginx -s /sbin/nologin nginx
    if [ $? -ne 0 ]; then
        echo "创建用户失败。"
        exit 1
    fi

    chown -R nginx:nginx /usr/local/nginx /var/log/nginx /var/cache/nginx
    if [ $? -ne 0 ]; then
        echo "修改目录所有者失败。"
        exit 1
    fi

    if [ ! -f "$Down_DIR/$NGINX_TAR" ]; then
        echo "从内部源下载 Nginx..."
        wget -P "$Down_DIR" "$INTERNAL_NGINX_URL"
        if [ $? -eq 0 ]; then
            echo "从内部源下载失败，正在尝试外部源..."
            wget -P "$Down_DIR" "$EXTERNAL_NGINX_URL"
            if [ $? -eq 0 ]; then
                echo "无法从外部源下载 Nginx。"
                exit 1
            fi
        fi
        echo "下载成功！"
    else
        echo "Nginx已下载。"
        if [ -d "$Down_DIR/nginx-$NGINX_VERSION" ]; then
            echo "检测到旧的Nginx目录，正在清理..."
            rm -rf "$Down_DIR/nginx-$NGINX_VERSION"
        fi
        echo "正在解压Nginx..."
        tar -zxvf "$Down_DIR/nginx-$NGINX_VERSION.tar.gz" -C "$Down_DIR"
        if [ $? -eq 0 ]; then
            echo "解压成功！"
        else
            echo "解压失败。"
            exit 1
        fi
    fi

    cd "$Down_DIR/nginx-$NGINX_VERSION"
    ./configure \
    --prefix=/usr/local/nginx \
    --sbin-path=/usr/local/nginx/sbin/nginx \
    --conf-path=/usr/local/nginx/conf/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-threads \
    --with-file-aio \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module \
    --with-stream_ssl_preread_module \
    --with-openssl=/usr/local/src/openssl-1.1.1k \
    --with-openssl-opt="no-weak-ssl-ciphers no-ssl3 no-ssl3-method no-tls1 no-tls1_1" \
    --with-cc-opt="-I/usr/local/openssl/include" \
    --with-ld-opt="-L/usr/local/openssl/lib -Wl,-rpath,/usr/local/openssl/lib"

    if [ $? -ne 0 ]; then
        echo "Nginx编译失败..."
        exit 1
    fi
    make -j $(nproc)
    make install
    if [ $? -ne 0 ]; then
        echo "Nginx安装失败..."
        exit 1
    fi
    #以超级用户身份运行整个命令(sudo bash -c)
    sudo bash -c 'cat > /etc/systemd/system/nginx.service <<'EOF'
    [Unit]
    Description=The NGINX HTTP and reverse proxy server
    After=network.target remote-fs.target nss-lookup.target

    [Service]
    Type=forking
    PIDFile=/var/run/nginx.pid
    ExecStartPre=/usr/local/nginx/sbin/nginx -t
    ExecStart=/usr/local/nginx/sbin/nginx
    ExecReload=/usr/local/nginx/sbin/nginx -s reload
    ExecStop=/bin/kill -s QUIT $MAINPID
    PrivateTmp=true

    [Install]
    WantedBy=multi-user.target
    EOF'

    # 检查写入是否成功
    if [ $? -ne 0 ]; then
        echo "无法创建 nginx.service 文件"
        exit 1
    fi
    sudo systemctl daemon-reload
    sudo systemctl start nginx
    sudo systemctl enable nginx
    if [ $? -ne 0 ]; then
        echo "Nginx启动失败"
        exit 1
    fi
    echo "Nginx 安装并启动成功"
}

function uninstall_nginx() {
    if ! command -v nginx &>/dev/null; then
        echo "Nginx 未安装，无需卸载。"
        exit 0
    fi

    sudo systemctl stop nginx
    sudo systemctl disable nginx
    sudo rm -f /etc/systemd/system/nginx.service
    sudo rm -rf /usr/local/nginx
    sudo rm -rf /var/log/nginx
}


URL="http://10.22.51.64:8071/05_%E6%BA%90%E7%A0%81%E5%8C%85/02_python/Python-3.9.7.tgz"
PYTHON_VER="3.9.7"
SOFTWARE_DIR="/usr/local/src"
PYTHON_INSTER_DIR="/usr/local/python"

#install_python
function install_python(){
    if command -v python3 &>/dev/null; then
        echo "python3已安装,是否卸载后重新安装?(y/n)"
        read -rp "请输入y 或者 n :" response
        if [[ $response == "y" ]]; then
            uninstall_python
        else
            echo "取消安装！"
            exit
        fi
    fi

    echo "安装python依赖"
    yum -y install openssl-devel bzip2-devel libffi-devel zlib-devel readline-devel sqlite-devel wget >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "安装依赖成功"
    else
        echo "安装依赖失败"
        exit
    fi

    echo "开始安装Python ${PYTHON_VER}..."
    cd $SOFTWARE_DIR
    if [ ! -f Python-3.9.7.tgz ]; then
        echo "Python-3.9.7.tgz不存在，开始下载..."
        wget -P $SOFTWARE_DIR $URL && cd $SOFTWARE_DIR
    else
        echo "Python-3.9.7.tgz已存在，判断目录Python-3.9.7是否存在..."
		if [ -d $SOFTWARE_DIR/Python-3.9.7 ]; then
            echo "Python-3.9.7目录已存在，删除目录"
            rm -rf $SOFTWARE_DIR/Python-3.9.7
        else
            echo "Python-3.9.7目录不存在"
			tar -zxvf Python-3.9.7.tgz && cd Python-3.9.7
        fi
        exit
    fi
    
    ./configure --prefix=${PYTHON_INSTER_DIR} --enable-optimizations >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "编译成功"
    else
        echo "编译失败"
        exit
    fi
    make altinstall
    if [ $? -eq 0 ]; then
        echo "安装成功"
    else
        echo "安装失败"
        exit
    fi


    echo "Python ${PYTHON_VER} 安装成功，验证python版本..."

    $PYTHON_INSTER_DIR/bin/python3.9 --version
    if [ $? -eq 0 ]; then
        echo "版本验证成功"
    else
        echo "验证失败"
        exit
    fi
    #创建软链接
    if [ -e /usr/bin/python3 ]; then
        echo "软链接已存在"
        mv /usr/bin/python3 /usr/bin/python3.bak
    else
        echo "创建软链接"
    fi

    if [ -e /usr/bin/pip3 ]; then
        ehco "软链接/usr/bin/pip3 已存在"
        mb /usr/bin/pip3 /usr/bin/pip3.bak
    else
        echo "创建软链接"
    fi
    ln -s /usr/local/python/bin/python3.9 /usr/bin/python3
    ln -s /usr/local/python/bin/pip3.9 /usr/bin/pip3
}
#uninstall_python
function uninstall_python(){
    echo "开始卸载python3..."
    rm -rf ${PYTHON_INSTER_DIR}
    rm /usr/bin/python3
    rm /usr/bin/pip3
    if [ -e /usr/bin/python3.bak ]; then
        echo "软链接已存在"
        mv /usr/bin/python3.bak /usr/bin/python3
    else
        echo "软链接不存在"
    fi
    if [ -e /usr/bin/pip3.bak ]; then
        echo "软链接已存在"
        mv /usr/bin/pip3.bak /usr/bin/pip3
    else
        echo "软链接不存在"
    fi
    echo "卸载成功"
}

echo -e -e "———————————————————————————
\033[32m Nginx 安装工具\033[0m
———————————————————————————
1. 安装openssl
2. 安装nginx
3. 安装python
4. 安装mysql
10.卸载nginx
11.卸载python
12.退出
————
———————————————————————————
\033[32m 请选择：\033[]]
———————————————————————————"
read -rp "请输入序号并回车：" num
case $num in
1) install_openssl ;;
2) install_nginx ;;
3) install_python ;;
4) install_mysql ;;
10)uninstall_nginx ;;
11) uninstall_python ;;
12) exit ;;
*) echo "输入错误，请重新输入！" && sleep 1 && exec "" ;;
esac
