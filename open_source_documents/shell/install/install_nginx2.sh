#!/bin/bash

Down_DIR="/usr/local/src"

#Nginx变量
NGINX_VERSION="1.21.6"
NGINX_TAR="nginx-$NGINX_VERSION.tar.gz"
INTERNAL_NGINX_URL="http://10.24.1.133/Linux/nginx/$NGINX_TAR"
EXTERNAL_NGINX_URL="http://nginx.org/download/$NGINX_TAR"

function echo_log_info() {
    echo -e "$(date +'%F %T') - [INFO] $*"
    exit 1
}
function echo_log_warn() {
    echo -e "$(date +'%F %T') - [WARN] $*"
    exit 1
}
function echo_log_error() {
    echo -e "$(date + '%F %T') - [ERROR] $*"
    exit 1
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


function install_nginx() {

    if command -v nginx >/dev/null 2>&1; then
        echo "Nginx already installed."
        exit 0
    fi

    # 需要创建的目录列表
    directories=(
        "/usr/local/nginx"
        "/var/log/nginx"
        "/var/cache/nginx"
        "/var/spool/nginx/client_temp"
        "/var/spool/nginx/proxy_temp"
        "/var/spool/nginx/fastcgi_temp"
        "/var/spool/nginx/uwsgi_temp"
        "/var/spool/nginx/scgi_temp"
    )

    # 遍历每个目录，检查是否存在，存在则删除
    for dir in "${directories[@]}"; do
        if [ -d "$dir" ]; then
            echo "目录 $dir 已存在，正在删除..."
            rm -rf "$dir"
        fi
        echo "正在创建目录 $dir..."
        mkdir -p "$dir"
    done

    echo "所有目录已创建。"

    # 检查用户是否存在
    if id "nginx" &>/dev/null; then
        echo "Nginx用户已存在，跳过创建步骤。"
    else
        echo "正在创建Nginx用户..."
        useradd -r -d /usr/local/nginx -s /sbin/nologin nginx
        if [ $? -eq 0 ]; then
            echo "已成功创建Nginx用户。"
        else
            echo "创建Nginx用户失败。"
            exit 1
        fi
    fi
    chown -R nginx:nginx /usr/local/nginx /var/log/nginx /var/cache/nginx
    echo "目录已赋权"


    if [ ! -f "$Down_DIR/$NGINX_TAR" ]; then
        if check_url "$INTERNAL_NGINX_URL"; then
            echo "从内部源下载 Nginx..."
            wget -P "$Down_DIR" "$INTERNAL_NGINX_URL"
        elif check_url "$EXTERNAL_NGINX_URL"; then
            echo "从外部源下载 Nginx..."
            wget -P "$Down_DIR" "$EXTERNAL_NGINX_URL"
        else
            echo "无法从外部源下载 Nginx。"
            exit 1
        fi
        echo "下载成功！"
    else
        echo "Nginx已下载。"
    fi
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
    cat > /etc/systemd/system/nginx.service <<'EOF'
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
EOF

    [Install]
    WantedBy=multi-user.target
EOF

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
    sudo rm -rf /usr/bin/nginx
    sudo rm -rf /usr/local/nginx/sbin/nginx
    sudo rm -rf /usr/local/nginx
    sudo rm -rf /var/log/nginx
    sudo rm -rf /var/spool/nginx
    sudo rm -rf /var/cache/nginx
}

echo -e -e "———————————————————————————
\033[32m Nginx 安装工具\033[0m
———————————————————————————
1. 安装nginx
2. 卸载nginx
3. 退出
———————————————————————————
\033[32m 请选择：\033[]]
———————————————————————————"
read -rp "请输入序号并回车：" num
case $num in
1) install_nginx ;;
2) uninstall_nginx ;;
3) exit ;;
*) echo "输入错误，请重新输入！" && sleep 1 && exec "" ;;
esac
