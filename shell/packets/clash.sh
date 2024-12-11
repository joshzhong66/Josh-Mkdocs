#!/bin/bash
#author:josh

install_path="/usr/local"
download_path="/usr/local/src"
version="clash-linux-amd64-v1.7.1"
clash_url="http://10.22.51.64/5_Linux/clash-linux-amd64-v1.7.1.tar.gz"


echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}\033[0m] $*"
}
echo_log_info() {
    echo_log "\033[32INFO" "$*"
}
echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}

check_url() {
    local url=$1
    if curl --head --silent --fail "$url" > /dev/null; then
        return 0
    else
        return 1
    fi
}

install_clash() {
    if [ -x "$(command -v clash)" ]; then
        echo_log_warn "Clash Already installed, no need to reinstall."
        exit 1
    fi

    if check_url "$clash_url"; then
        echo_log_info "Clash Download Success !"
        wget "$clash_url" -P "$download_path" >/dev/null 2>&1
    else
        echo_log_error "Clash Download Failed!"
    fi
    tar -xzf "$download_path"/clash-linux-amd64-v1.7.1.tar.gz -C $install_path >/dev/null 2>&1
    mv $install_path/clash-linux-amd64-v1.7.1/ $install_path/clash
    chmod +x $install_path/clash/clash-linux-amd64
    ln -s $install_path/clash/clash-linux-amd64 /usr/bin/clash

    cat > /etc/systemd/system/clash.service << EOF
[Unit]
Description=Clash daemon, A rule-based proxy in Go.
After=network.target

[Service]
Type=simple
Restart=always
ExecStart=$install_path/clash/clash-linux-amd64 -d $install_path/clash

[Install]
WantedBy=multi-user.target
EOF
    echo -e "export http_proxy=http://127.0.0.1:7890\nexport https_proxy=http://127.0.0.1:7890" | tee /etc/profile.d/clash.sh >/dev/null
    source /etc/profile.d/clash.sh

    systemctl daemon-reload
    systemctl enable --now clash.service >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "clash service startd successfully." || { echo_log_error "Failed to start the clash service!"; return; }
}


uninstall_clash() {
    if  ! command -v clash ; then
        echo_log_warn "Clash not installed."
        exit 1
    fi
    echo_log_info "Stop the clash service."
    systemctl stop clash && systemctl disable clash >/dev/null 2>&1
    unset http_proxy https_proxy
    echo_log_info "Delete the clash file."
    rm -rf $install_path/clash
    rm -f /etc/profile.d/clash.sh
    rm -f /etc/systemd/system/clash.service
    rm -f /usr/bin/clash

    echo_log_info "clash has been uninstalled."
}


install_clash_ui() {
    which docker >/dev/null 2>&1 || echo_log_error "Docker is not installed."
    [ -d "$install_path/clash" ] || echo_log_error "Clash is not installed."
    docker ps | grep -q yacd && echo_log_error "Clash UI already installed, no need to reinstall."

    gunzip -c $install_path/clash/ghcr.io_haishanh_yacd_master.tar.gz | docker load >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "docker image Loading Successfully!" || { echo_log_error "docker image Loading Failed!"; return; }
    
    echo_log_info "Start the Docker container."
    mkdir -p /usr/local/clash/ui
    docker network create --subnet=172.19.199.0/24 clash >/dev/null 2&>1
    docker run -p 8234:80 \
-d \
--name yacd \
--restart unless-stopped \
--net clash \
-v /usr/local/clash/ui:/data \
ghcr.io/haishanh/yacd:master >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "clash ui startd Successfully." || { echo_log_error "clash ui startd Failed."; return; }
}

uninstall_clash_ui() {
    docker ps | grep yacd >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "clash_ui is not installed"
    docker stop yacd >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Stop yacd Container Successfully!" || { echo_log_error "Stop yacd Container Failed!"; return; }
    rm -rf /usr/local/clash/ui
    docker rm -f yacd >/dev/null 2>&1
    docker rmi -f docker rmi -f ghcr.io/haishanh/yacd:master >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Delete yacd image Successfully!" || { echo_log_error "Delete yacd image Container Failed!"; return; }

}

quit() {
    echo_log_info "Exit Script"
    exit 0
}

main() {
    echo -e "———————————————————————————
\033[32m clash install tools\033[0m
———————————————————————————
1. install clash
2. uninstallclash
3. install clash ui
4. uninstall clash ui
5. quit\n"

    read -rp "Please enter the serial number and press Enter:"  num
    case "$num" in
    1) install_clash ;;
    2) uninstall_clash ;;
    3) install_clash_ui ;;
    4) uninstall_clash_ui ;;
    5) quit ;;
    *) echo_log_warn "Invalid selection, please select again." && main ;;
    esac
}


main
