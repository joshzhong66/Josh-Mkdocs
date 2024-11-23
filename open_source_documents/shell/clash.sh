#!/bin/bash

download_path="/usr/local/src"

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
}

clash_url="http://10.22.51.64/5_Linux/clash.tar.gz"

check_url() {
    local url=$1
    if curl --head --silent --fail "$url" > /dev/null; then
      return 0  # URL 有效
    else
      return 1  # URL 无效
    fi
}

install_clash() {
    if [ -x "$(command -v clash)" ]; then
        echo_log_warn "Clash Already installed, no need to reinstall."
        exit 1
    fi
    check_url "$clash_url"
    wget "$clash_url" -P "$download_path" >/dev/null 2>&1
    tar -zxf "$download_path"/clash.tar.gz -C /data/ >/dev/null 2>&1
    cd /data/clash
    gunzip clash-linux-amd64-v1.7.1.gz  >/dev/null 2>&1
    mv clash-linux-amd64-v1.7.1 clash-linux-amd64 >/dev/null 2>&1
    chmod +x clash-linux-amd64
    ln -s /data/clash/clash-linux-amd64 /usr/bin/clash

    # 创建 Clash systemd 服务
    cat > /etc/systemd/system/clash.service << EOF
[Unit]
Description=Clash daemon, A rule-based proxy in Go.
After=network.target

[Service]
Type=simple
Restart=always
ExecStart=/data/clash/clash-linux-amd64 -d /data/clash

[Install]
WantedBy=multi-user.target
EOF

    echo -e "export http_proxy=http://127.0.0.1:7890\nexport https_proxy=http://127.0.0.1:7890" | tee /etc/profile.d/clash.sh
    source /etc/profile.d/clash.sh

    systemctl daemon-reload
    systemctl enable --now clash.service >/dev/null 2>&1
}



remove_clash() {
    systemctl stop clash && systemctl disable clash >/dev/null 2>&1
    rm -rf /data/clash
    rm -rf /etc/profile.d/clash.sh
    rm -rf /etc/systemd/system/clash.service
    rm -rf /usr/bin/clash
}


main() {
    install_clash
    remove_clash
}


main() {
    echo -e "———————————————————————————
\033[32m docker服务工具\033[0m
———————————————————————————
1. 安装clash
2. 卸载clash
3. 退出\n"

    read -rp "请输入序号并回车: " num
    case "$num" in
    1) install_clash ;;     # 安装clash
    2) remove_clash ;;      # 卸载clash
    3) quit ;;              # 退出脚本
    *) echo_log_warn "无效选项，请重新选择。" && main ;;
    esac
}

main













