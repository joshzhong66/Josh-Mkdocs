#!/bin/bash

zbxa_name=$(hostname)
download_path="/tmp"
package_name="zabbix_agent-6.4.15.zip"
zbxa_file="/tmp/zabbix_agent-6.4.15.zip"
zabx_file_url="https://file.joshzhong.top/90_tar/zabbix_agent-6.4.15.zip"
zbxa_srvfile="/usr/lib/systemd/system/zabbix_agentd.service"
zbxa_insdir="/usr/local/zabbix_agent"
zbxa_pskfile="${zbxa_insdir}/etc/zabbix_agentd.psk"
zbxa_cfg="${zbxa_insdir}/etc/zabbix_agentd.conf"
zbx_server_ip=10.22.51.65
psk_file="/usr/local/zabbix_agent/etc/zabbix_agentd.psk"
psk="f03a84aa7cc6ea8c13d9e01f2a704705bad15fd26a535dd8bf322c3b5c38d493"

check_url() {
    local url=$1
    if curl --head --silent --fail "$url" > /dev/null; then
        return 0
    else
        return 1
    fi
}

download_package() {
    local package_name=$1
    local download_path=$2
    shift 2 

    for url in "$@"; do
        if check_url "$url"; then
            echo "Downloading $package_name from $url ..."
            wget -P "$download_path" "$url" &>/dev/null && {
                echo "Download $package_name Success"
                return 0
            }
            echo "$url Download failed"
            exit 1
        else
            echo "$url is invalid"
        fi
    done
    echo "All download links are invalid. Download failed!"
    return 1
}

download_package $package_name $download_path "$zabx_file_url"



if [ -f ${zbxa_file} ]; then
    echo "开始创建zabbix 用户"
    id zabbix >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        useradd zabbix -s /sbin/nologin -M
    fi

    echo "创建agentd 服务文件"
    cat > $zbxa_srvfile <<'EOF'
[Unit]
Description=Zabbix Agent
After=syslog.target
After=network.target

[Service]
Environment="CONFFILE=/usr/local/zabbix_agent/etc/zabbix_agentd.conf"
Type=forking
Restart=on-failure
PIDFile=/tmp/zabbix_agentd.pid
KillMode=control-group
ExecStart=/usr/local/zabbix_agent/sbin/zabbix_agentd -c $CONFFILE
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=10s
User=zabbix
Group=zabbix

[Install]
WantedBy=multi-user.target
EOF

    echo "开始解压zabbix agent"

    if command -v unzip >/dev/null 2>&1; then
        echo "unzip is installed"
    else
        echo "unzip is not installed"
        yum install unzip -y
    fi
    
    unzip ${zbxa_file} -d /usr/local/
    chmod -R 755 ${zbxa_insdir}
    chmod 600 ${zbxa_pskfile}
    chown -R zabbix:zabbix ${zbxa_insdir}

    sed -i "/^Hostname=/c Hostname=${zbxa_name}" ${zbxa_cfg}


    if [ ! -d "/usr/local/zabbix_agent/etc/" ]; then
        echo "Error: /usr/local/zabbix_agent/etc/ 目录不存在！"
        exit 1
    else
        cd /usr/local/zabbix_agent/etc
        
        echo $psk > $psk_file   # 创建psk
    fi 
    # 修改agentd.conf
    sed -i 's@# PidFile=/tmp/zabbix_agentd.pid@PidFile=/tmp/zabbix_agentd.pid@g' zabbix_agentd.conf
    sed -i 's@LogFile=/tmp/zabbix_agentd.log@LogFile=/usr/local/zabbix_agent/logs/zabbix_agentd.log@g' zabbix_agentd.conf
    sed -i 's@# LogFileSize=1@LogFileSize=0@g' zabbix_agentd.conf
    sed -i "s@^Server=.*@Server=${zbx_server_ip}@g" zabbix_agentd.conf              # IP地址修改为Zabbix Server服务器端IP
    sed -i "s@^ServerActive=.*@ServerActive=${zbx_server_ip}@g" zabbix_agentd.conf  # IP地址修改为Zabbix Server服务器端IP
    sed -i "s/^Hostname=.*/Hostname=${zbxa_name}/" zabbix_agentd.conf               # 主机名与Zabbix Web配置的主机名一致
    sed -i 's@# AllowRoot=0@AllowRoot=1@g' zabbix_agentd.conf
    sed -i 's@# Include=/usr/local/etc/zabbix_agentd.conf.d/\*.conf@Include=/usr/local/zabbix_agent/etc/zabbix_agentd.conf.d/\*.conf@g' zabbix_agentd.conf
    sed -i 's@# UnsafeUserParameters=0@UnsafeUserParameters=1@g' zabbix_agentd.conf
    sed -i 's@# TLSConnect=unencrypted@TLSConnect=psk@g' zabbix_agentd.conf
    sed -i 's@# TLSAccept=unencrypted@TLSAccept=psk@g' zabbix_agentd.conf
    sed -i 's@# TLSPSKIdentity=@TLSPSKIdentity=psk01@g' zabbix_agentd.conf
    sed -i 's@# TLSPSKFile=@TLSPSKFile=/usr/local/zabbix_agent/etc/zabbix_agentd.psk@g' zabbix_agentd.conf

    # 显示修改后的配置
    egrep -v '#|^$' zabbix_agentd.conf

    systemctl daemon-reload
    pkill -kill zabbix_agentd
    systemctl start zabbix_agentd
    systemctl enable zabbix_agentd
    systemctl status zabbix_agentd

elif [ ! -f ${zbxa_file} ]; then
    echo "Error: file ${zbxa_file} no exist!"

elif [ ! -f ${zbxa_srvfile} ]; then
    echo "Error: file ${zbxa_srvfile} no exist!"

else
    echo "Error: file ${zbxa_file} and ${zbxa_srvfile} no exist!"
fi