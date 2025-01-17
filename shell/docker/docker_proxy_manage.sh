#!/bin/bash

#./manage_docker_proxy.sh enable  # 启用代理
#./manage_docker_proxy.sh disable # 禁用代理

DOCKER_SERVICE_1="/etc/systemd/system/docker.service"
DOCKER_SERVICE_2="/usr/lib/systemd/system/docker.service"

set_proxy() {
    ipzz="^([0-9]\.|[1-9][0-9]\.|1[0-9][0-9]\.|2[0-4][0-9]\.|25[0-5]\.){3}([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$"
    while :; do
        local proxy_ip=$(read -rp "请输入代理 IP 地址: " && echo $REPLY)
        if [ -z $proxy_ip ]; then
            echo "IP 地址不能为空，请重新输入!"
        elif [[  $proxy_ip =~ $ipzz ]]; then
            break
        else
            echo "IP 地址格式错误，请重新输入!"
        fi
    done

	if [ -f "$DOCKER_SERVICE_1" ]; then
		sed -i '/Environment="HTTP_PROXY/d' "$DOCKER_SERVICE_1"
		sed -i '/Environment="HTTPS_PROXY/d' "$DOCKER_SERVICE_1"
		sed -i '/Environment="NO_PROXY/d' "$DOCKER_SERVICE_1"
		sed -i "/\[Install\]/i\Environment=\"HTTP_PROXY=http://${proxy_ip}:7890/\"\nEnvironment=\"HTTPS_PROXY=http://${proxy_ip}:7890/\"\nEnvironment=\"NO_PROXY=localhost,127.0.0.1,.example.com\"" "$DOCKER_SERVICE_1"
	elif [ -f "$DOCKER_SERVICE_2" ]; then
		sed -i '/Environment="HTTP_PROXY/d' "$DOCKER_SERVICE_2"
		sed -i '/Environment="HTTPS_PROXY/d' "$DOCKER_SERVICE_2"
		sed -i '/Environment="NO_PROXY/d' "$DOCKER_SERVICE_2"
		sed -i "/\[Install\]/i\Environment=\"HTTP_PROXY=http://${proxy_ip}:7890/\"\nEnvironment=\"HTTPS_PROXY=http://${proxy_ip}:7890/\"\nEnvironment=\"NO_PROXY=localhost,127.0.0.1,.example.com\"" "$DOCKER_SERVICE_2"
	else
		echo "Docker service file not found in either $DOCKER_SERVICE_1 or $DOCKER_SERVICE_2"
		exit 1
	fi

    #sed -i '/Environment="HTTP_PROXY/d' /usr/lib/systemd/system/docker.service
    #sed -i '/Environment="HTTPS_PROXY/d' /usr/lib/systemd/system/docker.service
    #sed -i '/Environment="NO_PROXY/d' /usr/lib/systemd/system/docker.service
	
	#sed -i '/Environment="HTTP_PROXY/d' /etc/systemd/system/docker.service
	#sed -i '/Environment="HTTPS_PROXY/d' /etc/systemd/system/docker.service
	#sed -i '/Environment="NO_PROXY/d' /etc/systemd/system/docker.service
	
    #sed -i "/\[Install\]/i\Environment=\"HTTP_PROXY=http://${proxy_ip}:7890/\"\nEnvironment=\"HTTPS_PROXY=http://${proxy_ip}:7890/\"\nEnvironment=\"NO_PROXY=localhost,127.0.0.1,.example.com\"" /usr/lib/systemd/system/docker.service

    systemctl daemon-reload && systemctl restart docker

    echo "Docker proxy enabled!"
}



unset_proxy() {
    if [ -f "$DOCKER_SERVICE_1" ]; then
        sed -i '/Environment="HTTP_PROXY/d' "$DOCKER_SERVICE_1"
        sed -i '/Environment="HTTPS_PROXY/d' "$DOCKER_SERVICE_1"
        sed -i '/Environment="NO_PROXY/d' "$DOCKER_SERVICE_1"
        echo "Proxy settings removed from $DOCKER_SERVICE_1"
    elif [ -f "$DOCKER_SERVICE_2" ]; then
        sed -i '/Environment="HTTP_PROXY/d' "$DOCKER_SERVICE_2"
        sed -i '/Environment="HTTPS_PROXY/d' "$DOCKER_SERVICE_2"
        sed -i '/Environment="NO_PROXY/d' "$DOCKER_SERVICE_2"
        echo "Proxy settings removed from $DOCKER_SERVICE_2"
    else
        echo "Docker service file not found in either $DOCKER_SERVICE_1 or $DOCKER_SERVICE_2"
        return 1
    fi

    systemctl daemon-reload && systemctl restart docker
    echo "Docker proxy disabled and Docker service restarted!"
}

case "$1" in
    enable)
        set_proxy
        ;;
    disable)
        unset_proxy
        ;;
    *)
        echo "Usage: $0 {enable|disable}"
        exit 1
        ;;
esac

