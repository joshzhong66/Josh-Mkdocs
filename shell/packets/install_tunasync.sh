#!/bin/bash

PACKAGE_NAME="TunaSync"
TUNASYNC_VERSION="0.8.0"
MIRRORS_PATH="/data/mirrors"
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH="/usr/local/tunasync"
PROFILE_FILE="/etc/profile"
TUNASYNC_TAR="tunasync-linux-amd64-bin.tar.gz"
INTERNAL_TUNASYNC_URL="http://mirrors.sunline.cn/source/tunasync/tunasync-linux-amd64-bin.tar.gz"
EXTERNAL_TUNASYNC_URL="https://github.com/tuna/tunasync/releases/download/v0.8.0/tunasync-linux-amd64-bin.tar.gz"

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


check_tunasync() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "Installation directory '$INSTALL_PATH' already exists. Please uninstall $PACKAGE_NAME before proceeding!"
    fi
    return 0
}


download_package() {
    for url in "$INTERNAL_TUNASYNC_URL" "$EXTERNAL_TUNASYNC_URL"; do
        if check_url "$url"; then
            echo_log_info "Download $PACKAGE_NAME source package from $url ..."
            if wget -P "$DOWNLOAD_PATH" "$url" &>/dev/null; then
                echo_log_info "$TUNASYNC_TAR Download Success"
                return 0
            else
                echo_log_error "$url Download failed"
            fi
        else
            echo_log_warn "$url invalid"
        fi
    done
    echo_log_error "Both download links are invalid，Download failed！"
    return 1
}


install_tunasync() {
    check_tunasync
    mkdir -p "${INSTALL_PATH}"/{bin,etc,logs,db}
    if [ $? -eq 0 ]; then
        echo_log_info "Successfully mkdir ${INSTALL_PATH}"
    else
        echo_log_error "Failed to create directories"
    fi

    mkdir -p $MIRRORS_PATH
    [ $? -eq 0 ] && echo_log_info "Successfully mkdir $MIRRORS_PATH"
    
    if ! command -v rsync >/dev/null 2>&1; then
        echo_log_info "Rsync is not installed, installing..."

        yum -y install rsync >>/tmp/install.log 2>&1
        if [ $? -eq 0 ]; then
            echo_log_info "Rsync installed successfully!"
        else
            echo_log_error "Rsync installation failed! Error log: /tmp/install.log"
            cat /tmp/install.log
        fi
    else
        echo_log_info "Rsync is installed."
    fi

    if [ -f "$DOWNLOAD_PATH/$TUNASYNC_TAR" ]; then
        echo_log_info "The $PACKAGE_NAME source package already exists！"
    else
        echo_log_info "Start downloading the $PACKAGE_NAME source package..."
        download_package
    fi

    tar -zxf ${DOWNLOAD_PATH}/${TUNASYNC_TAR} -C $INSTALL_PATH/bin >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "Unarchive $PACKAGE_NAME Failed" || echo_log_info "Unarchive $PACKAGE_NAME Successful"

    cat >> /etc/profile <<'EOF'
# tunasync
export PATH=/usr/local/tunasync/bin:$PATH
EOF

    source /etc/profile
    [ $? -eq 0 ] && echo_log_info "Add environment variables successfully!" || echo_log_error "Failed to add environment variables"

    cat > /usr/local/tunasync/etc/manager.conf <<'EOF'
debug = false

[server]
addr = "127.0.0.1"
port = 14242
ssl_cert = ""
ssl_key = ""

[files]
db_type = "bolt"
db_file = "/usr/local/tunasync/db/manager.db"
ca_cert = ""
EOF
    [ $? -eq 0 ] && echo_log_info "add /usr/local/tunasync/etc/manager.conf successfully!"

    cat > /usr/local/tunasync/etc/worker.conf <<'EOF'
[global]
name = "tunworker"
log_dir = "/usr/local/tunasync/logs/{{.Name}}"   # 日志存储位置
mirror_dir = "/data/mirrors"                     # 仓库存储位置
concurrent = 10                                  # 线程数
interval = 1440                                  # 同步周期，单位分钟

[manager]
api_base = "http://localhost:14242"              # manager的API地址
token = ""
ca_cert = ""

[cgroup]
enable = false
base_path = "/sys/fs/cgroup"
group = "tunasync"

[server]
hostname = "localhost"
listen_addr = "127.0.0.1"
listen_port = 16010
ssl_cert = ""
ssl_key = ""

[[mirrors]]
name = "openeuler"
mirror_dir = "/data/mirrors/openeuler/openEuler-22.03-LTS-SP4/"
provider = "rsync"
upstream = "rsync://mirrors.tuna.tsinghua.edu.cn/openeuler/openEuler-22.03-LTS-SP4/"
rsync_options = [ "--include", "/virtual_machine_img", "--exclude", "/*" ]
interval = 1440
use_ipv6 = false
delete = false
delete-after = false
delay-updates = true
EOF
    [ $? -eq 0 ] && echo_log_info "add /usr/local/tunasync/etc/worker.conf successfully!"

    cat > /usr/lib/systemd/system/tunasync-manager.service <<'EOF'
[Unit]
Description = TUNA mirrors sync manager
After=network.target
Requires=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/tunasync/bin/tunasync manager -c /usr/local/tunasync/etc/manager.conf --with-systemd

[Install]
WantedBy=multi-user.target
EOF
    [ $? -eq 0 ] && echo_log_info "add /usr/lib/systemd/system/tunasync-manager.service successfully!"

    systemctl daemon-reload && systemctl start tunasync-manager >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Tunasync-manager.service Start successfully!"
}

clone_tunasync_theme() {
    echo_log_info "Cloning tunasync-theme..."

    cd /data/mirrors

    if ! command -v git >/dev/null 2>&1; then
        echo_log_info "Git is not installed, installing..."

        yum -y install git >>/tmp/install.log 2>&1
        if [ $? -eq 0 ]; then
            echo_log_info "Git installed successfully!"
        else
            echo_log_error "Git installation failed! Error log: /tmp/install.log"
            cat /tmp/install.log
        fi
    else
        echo_log_info "Git is installed."
    fi

    git clone https://github.com/marioplus/nginx-fancyindex-theme.git >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Clone tunasync-theme successfully!" || echo_log_error "Clone tunasync-theme failed!"
    mv /data/mirrors/nginx-fancyindex-theme /data/mirrors/fancyindex

    file="/data/mirrors/fancyindex/js/FileBrowserContext.js"
    sed -i "s|root = new FileContext('home', '/download/', 'home', true)|root = new FileContext('home', '/', 'home', true)|g" "$file"
    [ $? -eq 0 ] && echo_log_info "Modify tunasync-theme successfully!" || echo_log_error "Modify tunasync-theme failed!"

    cat > /usr/local/nginx/conf/modules.conf <<'EOF'
load_module modules/ngx_http_fancyindex_module.so;
EOF
    [ $? -eq 0 ] &&  echo_log_info "Add nginx module successfully!" || echo_log_error "Add nginx module failed!"

    nginx_conf="/usr/local/nginx/conf/nginx.conf"
    config_line="load_module   /usr/local/nginx/modules/ngx_http_fancyindex_module.so;"

    sed -i "1i $config_line" "$nginx_conf"
    
    confd="/usr/local/nginx/conf.d"
    confd_line="   include       $confd/*.conf;"
    [ ! -d $confd ] && mkdir -p $confd
    if grep -q "http {" "$nginx_conf"; then
        sed -i "/http {/a \ $confd_line" "$nginx_conf"
        echo_log_info "The configuration has been added to the beginning of the http block"
    else
        echo_log_error "The http block does not exist and cannot be added to the configuration"
    fi

    cat > /usr/local/nginx/conf.d/tunasync-fancyindex.conf << 'EOF'
server {
  listen 8083;
  server_name  localhost;

  location / {
    root /data/mirrors;
    charset utf-8,gbk;
    fancyindex on;
    fancyindex_localtime on;
    fancyindex_exact_size off;
    fancyindex_name_length 256;
    fancyindex_show_path on;
    fancyindex_time_format "%Y-%m-%d %T";
    fancyindex_header "/fancyindex/header.html";
    fancyindex_footer "/fancyindex/footer.html";
    fancyindex_ignore "^fancyindex" "^favicon.ico";
  }
  
  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
    root html;
  }
}
EOF
    [ $? -eq 0 ] && echo_log_info "Create a tunasync site configuration file Successfully!" || echo_log_error "Create a tunasync site configuration file Failed!"

    nginx -s reload 2>/dev/null
    [ $? -eq 0 ] && echo_log_info "Reload nginx Successfully!" || echo_log_error "Reload nginx Failed!"

    head_file="/data/mirrors/fancyindex/header.html"
    sed -i 's#<title>File Browser</title>#<title>Sunline软件镜像站|Sunline Mirrors</title>#' "$head_file"
    [ $? -eq 0 ] && echo_log_info "Modify the header.html Successfully!" || echo_log_error "Modify the header.html Failed!"

    sed -i 's|Fancyindex|Mirrors|' /data/mirrors/fancyindex/header.html
    [ $? -eq 0 ] && echo_log_info "Modify the header.html Successfully!" || echo_log_error "Modify the header.html Failed!"]


    echo_log_info "Clone_tunasync_theme Successfully!"

}


uninstall_tunasync() {
    systemctl stop tunasync-manager && systemctl disable tunasync-manager >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Stop tunasync-manager Successfully!" || echo_log_error "Stop tunasync-manager Failed!"]

    rm -rf $INSTALL_PATH && rm -rf $MIRRORS_PATH
    [ $? -eq 0 ] && echo_log_info "Uninstall tunasync-manager Successfully!" || echo_log_error "Uninstall tunasync-manager Failed!"]

    rm -f /usr/lib/systemd/system/tunasync-manager.service
    [ $? -eq 0 ] && echo_log_info "Remove tunasync-manager.service Successfully!" || echo_log_error "Remove tunasync-manager.service Failed!"]

    sed -i '/# tunasync/,+1d' "$PROFILE_FILE" && source "$PROFILE_FILE"
    [ $? -eq 0 ] && echo_log_info "Remove tunasync-manager from profile Successfully!" || echo_log_error "Remove tunasync-manager from profile Failed!"]
    
    [ $? -eq 0 ] && echo_log_info "Tunasync Unistall successfully!"
}


main() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME${TUNASYNC_VERSION} Install Tool\033[0m
———————————————————————————
1. Install $PACKAGE_NAME${TUNASYNC_VERSION}
2. Uninstall $PACKAGE_NAME${TUNASYNC_VERSION}
3. Clone Tunasync_Theme
4. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter:" num
    case "$num" in
    1) install_tunasync ;;
    2) uninstall_tunasync ;;
    3) clone_tunasync_theme ;;
    4) quit ;;

    *) main ;;
    esac
}

main