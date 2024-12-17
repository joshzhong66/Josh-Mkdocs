#!/bin/bash

PACKAGE_NAME="nginx"
NGINX_VERSION="1.21.6"
NGINX_TAR="nginx-$NGINX_VERSION.tar.gz"
DOWNLOAD_PATH="/usr/local/src"
NGINX_INSTALL_PATH="/usr/local/nginx"
INTERNAL_NGINX_URL="http://mirrors.sunline.cn/nginx/linux/$NGINX_TAR"
EXTERNAL_NGINX_URL="http://nginx.org/download/$NGINX_TAR"


NGX_TAR="ngx-fancyindex-0.5.2.tar.xz"
INTERNAL_NGX_FANCYINDEX="http://mirrors.sunline.cn/nginx/linux/ngx-fancyindex-0.5.2.tar.xz"
EXTERNAL_NGX_FANCYINDEX="https://github.com/aperezdc/ngx-fancyindex/releases/download/v0.5.2/ngx-fancyindex-0.5.2.tar.xz"


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

check_nginx() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "Installation directory '$INSTALL_PATH' already exists. Please uninstall $PACKAGE_NAME before proceeding!"
    elif which $PACKAGE_NAME &>/dev/null; then
        echo_log_error "$PACKAGE_NAME is already installed. Please uninstall it before installing the new version!"
    fi
    return 0
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


install_nginx() {
    check_nginx
    echo_log_info "Start Install Rely Package..."
    yum install -y wget make gcc gcc-c++ pcre-devel openssl-devel geoip-devel zlib-devel >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Rely Package Install Successful" || echo_log_error "Rely Package Install Failed"

    if [ -f "$DOWNLOAD_PATH/$NGINX_TAR" ]; then
        echo_log_info "The $PACKAGE_NAME source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package $PACKAGE_NAME $DOWNLOAD_PATH "$INTERNAL_NGINX_URL" "$EXTERNAL_NGINX_URL"
    fi

    tar -zxf ${DOWNLOAD_PATH}/${NGINX_TAR} -C $DOWNLOAD_PATH >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $PACKAGE_NAME Failed" || echo_log_info "Unarchive $PACKAGE_NAME Successful"

    cat /etc/passwd | grep $PACKAGE_NAME >/dev/null 2>&1 || useradd -M -s /sbin/nologin $PACKAGE_NAME
    [  $? -eq 0 ] && echo_log_info "Add $PACKAGE_NAME User Successful" || echo_log_error "Add $PACKAGE_NAME User Failed"

    cd ${DOWNLOAD_PATH}/nginx-$NGINX_VERSION
    ./configure \
    --prefix=/usr/local/nginx \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_geoip_module \
    --with-mail \
    --with-mail_ssl_module \
    >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Configure nginx Successfully!" || echo_log_error "Configure nginx Failed!"
    
    make -j $(nproc) >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Make nginx Successfully!" || echo_log_error "Make nginx Failed!"

    make install >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Install nginx Successfully!" || echo_log_error "Install nginx Failed!"

    ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
    [ $? -eq 0 ] && echo_log_info "Add nginx to /usr/bin/nginx Successfully!" || echo_log_error "Add nginx to /usr/bin/nginx Failed!"

    cat > /etc/systemd/system/nginx.service <<'EOF'
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    [ $? -eq 0 ] && echo_log_info "add /etc/systemd/system/nginx.service successfully!" || echo_log_error "Failed to add /etc/systemd/system/nginx.service"
    
    systemctl daemon-reload
    systemctl start nginx && systemctl enable nginx >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "nginx Start successfully!" || echo_log_error "nginx Start Failed!"

    rm -rf "$DOWNLOAD_PATH/nginx-${NGINX_VERSION}"
    echo_log_info "Install nginx Successfully!"
}

uninstall_nginx() {
    if [ -d $NGINX_INSTALL_PATH ]; then
        systemctl stop nginx && systemctl disable nginx >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "Stop $PACKAGE_NAME successfully!" || echo_log_error "nginx Stop Failed!"

        rm -rf $NGINX_INSTALL_PATH
        [ $? -eq 0 ] && echo_log_info "Remove $NGINX_INSTALL_PATH Successfully!" || echo_log_error "Remove $NGINX_INSTALL_PATH Failed!"

        rm -f /usr/bin/nginx
        [ $? -eq 0 ] && echo_log_info "Remove /usr/bin/nginx Successfully!" || echo_log_error "Remove /usr/bin/nginx Failed!"

        rm -f /etc/systemd/system/nginx.service
        [ $? -eq 0 ] && echo_log_info "Remove /etc/systemd/system/nginx.service Successfully!" || echo_log_error "Remove /etc/systemd/system/nginx.service Failed!"

        #rm -rf "$DOWNLOAD_PATH/nginx-${NGINX_VERSION}"
        #[ $? -eq 0 ] && echo_log_info "Remove $DOWNLOAD_PATH/nginx-${NGINX_VERSION} Successfully!" || echo_log_error "Remove $DOWNLOAD_PATH/nginx-${NGINX_VERSION} Failed!"
        
        echo_log_info "Uninstall nginx Successfully!"
    fi
}


add_ngx_fancyindex_model() {
    if [ -f "$DOWNLOAD_PATH/$NGINX_TAR" ]; then
        echo_log_info "The $PACKAGE_NAME or $PACKAGE_NAME.tar source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package $PACKAGE_NAME $DOWNLOAD_PATH "$INTERNAL_NGINX_URL" "$EXTERNAL_NGINX_URL"
    fi
    
    tar -zxf ${DOWNLOAD_PATH}/${NGINX_TAR} -C $DOWNLOAD_PATH >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $PACKAGE_NAME Failed" || echo_log_info "Unarchive $PACKAGE_NAME Successful"

    if [ -f "$DOWNLOAD_PATH/$NGX_TAR" ]; then
        echo_log_info "The $NGX_TAR source package already exists！"
    else
        echo_log_info "Start downloading the $$NGX_TAR source package..."
        wget $INTERNAL_NGX_FANCYINDEX -P $DOWNLOAD_PATH >/dev/null 2>&1
    fi

    tar -xJf $DOWNLOAD_PATH/ngx-fancyindex-0.5.2.tar.xz -C $DOWNLOAD_PATH>/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $NGX_FANCYINDEX Failed" || echo_log_info "Unarchive $NGX_FANCYINDEX Successful"

    cd "$DOWNLOAD_PATH/nginx-${NGINX_VERSION}"
    ./configure --with-compat --add-dynamic-module=$DOWNLOAD_PATH/ngx-fancyindex-0.5.2 >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Configure $PACKAGE_NAME Failed" || echo_log_info "Configure $PACKAGE_NAME Successful"
    
    make modules >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Make modules $PACKAGE_NAME Failed" || echo_log_info "Make modules $PACKAGE_NAME Successful"

    [ ! -d $NGINX_INSTALL_PATH/modules ] && mkdir -p /usr/local/nginx/modules
    [ $? -eq 0 ] && echo_log_info "Successfully mkdir /usr/local/nginx/modules" || echo_log_error "Failed to create directories"

    cp $DOWNLOAD_PATH/nginx-${NGINX_VERSION}/objs/ngx_http_fancyindex_module.so /usr/local/nginx/modules
    [ $? -eq 0 ] && echo_log_info "Successfully cp objs/ngx_http_fancyindex_module.so" || echo_log_error "Failed to copy files"

    systemctl restart nginx
    [ $? -eq 0 ] && echo_log_info "Successfully restart nginx" || echo_log_error "Failed to restart nginx"

    echo_log_info "Installation completed successfully!"
}



main() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${NGINX_VERSION} Install Tool\033[0m
———————————————————————————
1. Install $PACKAGE_NAME${NGINX_VERSION}
2. Uninstall $PACKAGE_NAME${NGINX_VERSION}
3. Add ngx_fancyindex_model
4. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) install_nginx ;;
    2) uninstall_nginx ;;
    3) add_ngx_fancyindex_model ;;
    4) quit ;;
    *) main ;;
    esac
}


main