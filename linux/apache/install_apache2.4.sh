#!/bin/bash

PORT="80"
PACKAGE_NAME="httpd"
APACHE_VERSION="2.4.62"
APACHE_TAR="httpd-${APACHE_VERSION}.tar.gz"
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH="/usr/local/apache"
PROFILE_FILE="/etc/profile"
INTERNAL_URL="http://10.24.1.133/Linux/apache-skywalking-apm/httpd-2.4.62.tar.gz"
EXTERNAL_URL="https://downloads.apache.org/httpd/httpd-2.4.62.tar.gz"


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

install_tool() {
    local tool=$1
    local package=$2

    if ! command -v "$tool" &>/dev/null; then
        echo_log_info "$tool not found. Installing $package..."
        sudo yum install -y "$package"
        if ! command -v "$tool" &>/dev/null; then
            echo_log_error "$tool installation failed. Please install it manually."
            exit 1
        fi
    fi
}

check_port() {
    if netstat -tuln | grep -q ":$PORT"; then
        echo_log_error "Port $PORT is in use."
    else
        echo_log_info "Port $PORT is available."
    fi
}

check_ss_port() {
    if ss -tuln | grep -q ":$PORT"; then
        echo_log_error "Port $PORT is in use."
    else
        echo_log_info "Port $PORT is available."
    fi
}

check_package() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "Installation directory '$INSTALL_PATH' already exists. Please uninstall $PACKAGE_NAME before proceeding!"
    elif which $PACKAGE_NAME &>/dev/null; then
        echo_log_error "$PACKAGE_NAME is already installed. Please uninstall it before installing the new version!"
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

install_apache2() {
    check_package

    echo_log_info "Start Install Rely Package..."
    yum install -y yum install -y apr apr-devel apr-util apr-util-devel pcre-devel openssl-devel gcc-c++ wget >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Install Rely Package Success" || echo_log_error "Install Rely Package Failed"

    if [ -f "$DOWNLOAD_PATH/$APACHE_TAR" ]; then
        echo_log_info "The $PACKAGE_NAME source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package $PACKAGE_NAME $DOWNLOAD_PATH "$INTERNAL_URL" "$EXTERNAL_URL"
    fi

    tar -xzf $DOWNLOAD_PATH/$APACHE_TAR -C $DOWNLOAD_PATH >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Unarchive $PACKAGE_NAME Successfully!" || echo_log_error "Unarchive $PACKAGE_NAME Failed!"

    cd ${DOWNLOAD_PATH}/${PACKAGE_NAME}-${APACHE_VERSION}
    ./configure --prefix=/usr/local/apache \
    --with-pmp=worker \
    --enable-rewrite \
    --enable-so \
    --enable-ssl \
    >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Configure $PACKAGE_NAME Successfully!" || echo_log_error "Configure $PACKAGE_NAME Failed!"]

    make -j $(nproc) >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Make $PACKAGE_NAME Successfully!" || echo_log_error "Make $PACKAGE_NAME Failed!"]

    make install >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Install $PACKAGE_NAME Successfully!" || echo_log_error "Install $PACKAGE_NAME Failed!"]

    sed -i 's/#ServerName www.example.com:80/ServerName localhost:8088/g' /usr/local/apache/conf/httpd.conf
    [ $? -eq 0 ] &&  echo_log_info "Modify $PACKAGE_NAME Configuration Successfully!" || echo_log_error "Modify $PACKAGE_NAME Configuration Failed!"]

    cat >> /etc/profile <<'EOF'
# Apache
export APACHE_HOME=/usr/local/apache
export PATH=$APACHE_HOME/bin:$PATH
EOF
    source /etc/profile
    [ $? -eq 0 ] && echo_log_info "Apache Configuration Successfully!" || echo_log_error "Apache Configuration Failed!"]

    cat > /etc/systemd/system/httpd.service <<'EOF'
[Unit]
Description=The Apache HTTP Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/apache/bin/apachectl start
ExecStop=/usr/local/apache/bin/apachectl stop
ExecReload=/usr/local/apache/bin/apachectl graceful
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    [ $? -eq 0 ] && echo_log_info "Apache service config file created successfully." || echo_log_error "Apache service config file creation failed!"

    systemctl daemon-reload
    [ $? -eq 0 ] && echo_log_info "Apache service reloaded successfully." || echo_log_error "Apache service reload failed!"

    if ! command -v netstat &>/dev/null; then
        install_tool "netstat" "net-tools"
        check_port
    elif ! command -v ss &>/dev/null; then
        install_tool "ss" "iproute"
        check_ss_port
    else
        echo_log_info "Both 'netstat' and 'ss' are available. Using 'netstat' to check the port."
        check_port
    fi

    systemctl start httpd && systemctl enable httpd >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Apache service started successfully." || echo_log_error "Apache service start failed!"

    rm -rf $INSTALL_PATH/$PACKAGE_NAME-$PACKAGE_VERSION
    echo_log_info "Apache service installed successfully."

}

uninstall_apache2(){
    if [ -d $INSTALL_PATH ]; then
        systemctl stop httpd && systemctl disable httpd >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "Apache uninstalled successfully." || echo_log_error "Apache uninstall failed!"
        
        rm -rf $INSTALL_PATH && rm -rf $DOWNLOAD_PATH/$PACKAGE_NAME-$APACHE_VERSION
        [ $? -eq 0 ] && echo_log_info "Apache files removed successfully." || echo_log_error "Apache files remove failed!"

        rm -f /etc/systemd/system/httpd.service && source /etc/profile
        [ $? -eq 0 ] && echo_log_info "Apache service file removed successfully." || echo_log_error "Apache service file remove failed!"

        sed -i '/# Apache/,+2d' "$PROFILE_FILE"
        source "$PROFILE_FILE"
        [ $? -eq 0 ] && echo_log_info "Apache profile file cleaned successfully." || echo_log_error "Apache profile file clean failed!"

        echo_log_info "Apache has been removed successfully."
    fi
}


main() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${APACHE_VERSION} Install Tool\033[0m
———————————————————————————
1. Install $PACKAGE_NAME${APACHE_VERSION}
2. Uninstall $PACKAGE_NAME${APACHE_VERSION}
3. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) install_apache2 ;;
    2) uninstall_apache2 ;;
    3) quit ;;

    *) main ;;
    esac
}


main