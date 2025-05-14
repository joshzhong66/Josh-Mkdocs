#!/bin/bash

# Install Nginx
# 官方地址：http://nginx.org/download/
# Sunline yum源不存在：geoip-devel

PACKAGE_NAME="nginx"
VERSION="1.21.6"
PKG_ARCH="nginx-$VERSION.tar.gz"
SRC_DIR="/usr/local/src"
INSTALL_DIR="/usr/local/nginx"
INTERNAL_URL="http://mirrors.sunline.cn/nginx/linux/$PKG_ARCH"
EXTERNAL_URL="http://nginx.org/download/$PKG_ARCH"


NGX_TAR="ngx-fancyindex-0.5.2.tar.xz"
INTERNAL_NGX_FANCYINDEX="http://mirrors.sunline.cn/nginx/linux/ngx-fancyindex-0.5.2.tar.xz"
EXTERNAL_NGX_FANCYINDEX="https://github.com/aperezdc/ngx-fancyindex/releases/download/v0.5.2/ngx-fancyindex-0.5.2.tar.xz"


echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}\033[0m] $*"
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
    if curl -f -s --connect-timeout 5 "$url" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

check_nginx() {
    if [ -d "$INSTALL_DIR" ]; then
        echo_log_error "Nginx Already installed, please uninstall Nginx first!"
    elif which $PACKAGE_NAME &>/dev/null; then
        echo_log_error "$PACKAGE_NAME Already installed. Please uninstall the old version first!"
    fi
    return 0
}

download_package() {
    local PACKAGE_NAME=$1
    local SRC_DIR=$2
    shift 2


    for url in "$@"; do
        if check_url "$url"; then
            echo_log_info "Downloading $PACKAGE_NAME from $url ..."
            wget -P "$SRC_DIR" "$url" &>/dev/null && {
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
    yum install -y wget make gcc gcc-c++ pcre-devel openssl-devel geoip-devel zlib-devel
    [ $? -eq 0 ] && echo_log_info "Rely Package Install Successful" || echo_log_error "Rely Package Install Failed"

    if [ -f "$SRC_DIR/$PKG_ARCH" ]; then
        echo_log_info "The $PACKAGE_NAME source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package $PACKAGE_NAME $SRC_DIR "$INTERNAL_URL" "$EXTERNAL_URL"
    fi

    tar -zxf ${SRC_DIR}/${PKG_ARCH} -C $SRC_DIR >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $PACKAGE_NAME Failed" || echo_log_info "Unarchive $PACKAGE_NAME Successful"

    cat /etc/passwd | grep $PACKAGE_NAME >/dev/null 2>&1 || useradd -M -s /sbin/nologin $PACKAGE_NAME
    [  $? -eq 0 ] && echo_log_info "Add $PACKAGE_NAME User Successful" || echo_log_error "Add $PACKAGE_NAME User Failed"

    cd ${SRC_DIR}/nginx-$VERSION
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

    rm -rf "$SRC_DIR/nginx-${VERSION}"
    echo_log_info "Install nginx Successfully!"
}

uninstall_nginx() {
    if [ -d $INSTALL_DIR ]; then
        systemctl stop nginx && systemctl disable nginx >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "Stop $PACKAGE_NAME successfully!" || echo_log_error "nginx Stop Failed!"

        rm -rf $INSTALL_DIR
        [ $? -eq 0 ] && echo_log_info "Remove $INSTALL_DIR Successfully!" || echo_log_error "Remove $INSTALL_DIR Failed!"

        rm -f /usr/bin/nginx
        [ $? -eq 0 ] && echo_log_info "Remove /usr/bin/nginx Successfully!" || echo_log_error "Remove /usr/bin/nginx Failed!"

        rm -f /etc/systemd/system/nginx.service
        [ $? -eq 0 ] && echo_log_info "Remove /etc/systemd/system/nginx.service Successfully!" || echo_log_error "Remove /etc/systemd/system/nginx.service Failed!"

        #rm -rf "$SRC_DIR/nginx-${VERSION}"
        #[ $? -eq 0 ] && echo_log_info "Remove $SRC_DIR/nginx-${VERSION} Successfully!" || echo_log_error "Remove $SRC_DIR/nginx-${VERSION} Failed!"
        
        echo_log_info "Uninstall nginx Successfully!"
    fi
}


add_ngx_fancyindex_model() {
    if [ -f "$SRC_DIR/$PKG_ARCH" ]; then
        echo_log_info "The $PACKAGE_NAME or $PACKAGE_NAME.tar source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package $PACKAGE_NAME $SRC_DIR "$INTERNAL_URL" "$EXTERNAL_URL"
    fi
    
    tar -zxf ${SRC_DIR}/${PKG_ARCH} -C $SRC_DIR >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $PACKAGE_NAME Failed" || echo_log_info "Unarchive $PACKAGE_NAME Successful"

    if [ -f "$SRC_DIR/$NGX_TAR" ]; then
        echo_log_info "The $NGX_TAR source package already exists！"
    else
        echo_log_info "Start downloading the $$NGX_TAR source package..."
        wget $INTERNAL_NGX_FANCYINDEX -P $SRC_DIR >/dev/null 2>&1
    fi

    tar -xJf $SRC_DIR/ngx-fancyindex-0.5.2.tar.xz -C $SRC_DIR>/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $NGX_FANCYINDEX Failed" || echo_log_info "Unarchive $NGX_FANCYINDEX Successful"

    cd "$SRC_DIR/nginx-${VERSION}"
    ./configure --with-compat --add-dynamic-module=$SRC_DIR/ngx-fancyindex-0.5.2 >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Configure $PACKAGE_NAME Failed" || echo_log_info "Configure $PACKAGE_NAME Successful"
    
    make modules >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Make modules $PACKAGE_NAME Failed" || echo_log_info "Make modules $PACKAGE_NAME Successful"

    [ ! -d $INSTALL_DIR/modules ] && mkdir -p /usr/local/nginx/modules
    [ $? -eq 0 ] && echo_log_info "Successfully mkdir /usr/local/nginx/modules" || echo_log_error "Failed to create directories"

    cp $SRC_DIR/nginx-${VERSION}/objs/ngx_http_fancyindex_module.so /usr/local/nginx/modules
    [ $? -eq 0 ] && echo_log_info "Successfully cp objs/ngx_http_fancyindex_module.so" || echo_log_error "Failed to copy files"

    systemctl restart nginx
    [ $? -eq 0 ] && echo_log_info "Successfully restart nginx" || echo_log_error "Failed to restart nginx"

    echo_log_info "Installation completed successfully!"
}



main() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${VERSION} Install Tool\033[0m
———————————————————————————
1. Install $PACKAGE_NAME${VERSION}
2. Uninstall $PACKAGE_NAME${VERSION}
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