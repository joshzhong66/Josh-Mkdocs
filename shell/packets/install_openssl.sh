#!/bin/bash

PACKAGE_NAME="openssl"
OPENSSL_VERSION="1.1.1w"
OPENSSL_TAR="$PACKAGE_NAME-$OPENSSL_VERSION.tar.gz"
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH="/usr/local/openssl"
CONF_FILE="/etc/ld.so.conf.d/openssl.conf"
OPENSSL_LIB_PATH="$INSTALL_PATH/lib"
INTERNAL_URL="http://10.24.1.133/Linux/$OPENSSL_TAR"
EXTERNAL_URL="https://www.openssl.org/source/$OPENSSL_TAR"

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
    # elif which $PACKAGE_NAME &>/dev/null; then
    #     echo_log_error "$PACKAGE_NAME is already installed. Please uninstall it before installing the new version!"
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

install_openssl() {
    check_package

    echo_log_info "Start Install Rely Package..."
    yum install -y gcc gcc-c++ make zlib-devel pcre-devel geoip-devel epel-release perl-IPC-Cmd perl-Test-Simple >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Install Rely Package Success" || echo_log_error "Install Rely Package Failed"

    if [ -f "$DOWNLOAD_PATH/$OPENSSL_TAR" ]; then
        echo_log_info "The $PACKAGE_NAME source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package $PACKAGE_NAME $DOWNLOAD_PATH "$INTERNAL_URL" "$EXTERNAL_URL"
    fi

    tar -zxf $DOWNLOAD_PATH/$OPENSSL_TAR -C $DOWNLOAD_PATH >/dev/null 2>&1 
    [ $? -eq 0 ] && echo_log_info "Unarchive $PACKAGE_NAME Successfully!" || echo_log_error "Unarchive $PACKAGE_NAME Failed!"
    
    cd ${DOWNLOAD_PATH}/${PACKAGE_NAME}-${OPENSSL_VERSION}
    ./config -fPIC --prefix=/usr/local/openssl zlib >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Configure $PACKAGE_NAME Successfully!" || echo_log_error "Configure $PACKAGE_NAME Failed!"

    make -j $(nproc) >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Make $PACKAGE_NAME Successfully!" || echo_log_error "Make $PACKAGE_NAME Failed!"

    make install >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Install $PACKAGE_NAME Successfully!" || echo_log_error "Install $PACKAGE_NAME Failed!"

    [ -f /usr/bin/openssl ] && mv /usr/bin/openssl /usr/bin/openssl.bak >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Back up openssl files, Update Successfully!"

    ln -s $INSTALL_PATH/bin/$PACKAGE_NAME /usr/bin/$PACKAGE_NAME
    [ $? -eq 0 ] && echo_log_info "Create symlink Successfully!" || echo_log_error "Create symlink Failed!"

    if grep -Fxq "$OPENSSL_LIB_PATH" "$CONF_FILE"; then
        echo_log_error "The path '$OPENSSL_LIB_PATH' is already present in $CONF_FILE. No changes made."
    else
        echo "$OPENSSL_LIB_PATH" | sudo tee -a "$CONF_FILE" >/dev/null
        echo_log_info "Added '$OPENSSL_LIB_PATH' to $CONF_FILE."
    fi
    sudo ldconfig;
    [ $? -eq 0 ] && echo_log_info "Shared library cache updated successfully." || echo_log_error "ldconfig Failed!"

    cat > /etc/profile.d/openssl.sh << 'EOF'
export PKG_CONFIG_PATH=/usr/local/openssl/lib/pkgconfig:$PKG_CONFIG_PATH
export LDFLAGS="-L/usr/local/openssl/lib"
export CPPFLAGS="-I/usr/local/openssl/include"
EOF
    source /etc/profile
    [ $? -eq 0 ] && echo_log_info "openssl.sh added to /etc/profile successfully." || echo_log_error "openssl.sh Failed!"
    
    echo_log_info "Openssl installed successfully."
}


uninstall_openssl(){
    if [ -d $INSTALL_PATH ]; then
        rm -rf $INSTALL_PATH && rm -rf $DOWNLOAD_PATH/$PACKAGE_NAME-$OPENSSL_VERSION
        [ $? -eq 0 ] && echo_log_info "Openssl uninstalled successfully." || echo_log_error "Openssl uninstall failed!"

        rm -f $CONF_FILE && rm -f $OPENSSL_LIB_PATH
        [ $? -eq 0 ] && echo_log_info "Openssl config file removed successfully." || echo_log_error "Openssl config file remove failed!"]
        
        rm -f /etc/profile.d/openssl.sh && source /etc/profile
        [ $? -eq 0 ] && echo_log_info "Openssl config file removed successfully." || echo_log_error "Openssl config file remove failed!"
    
        [ -f /usr/bin/openssl.bak ] && mv /usr/bin/openssl.bak /usr/bin/openssl
        [ $? -eq 0 ] && echo_log_info "Openssl binary file restored successfully." || echo_log_error "Openssl binary file restore failed!"

        echo_log_info "Openssl has been removed successfully."
    fi 
}


main() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${OPENSSL_VERSION} Install Tool\033[0m
———————————————————————————
1. Install $PACKAGE_NAME${OPENSSL_VERSION}
2. Uninstall $PACKAGE_NAME${OPENSSL_VERSION}
3. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) install_openssl ;;
    2) uninstall_openssl ;;
    3) quit ;;
    *) main ;;
    esac
}


main