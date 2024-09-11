#!/bin/bash
#author:josh
#date:2023-10-01
#version:v1.0

#确保路径和文件名：确保你的SSL证书路径、Nginx和Kibana
# 设置脚本在遇到错误时退出
set -e

# 安装 Docker
function install_docker() {
    echo "卸载旧版本 Docker..."
    yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

    echo "安装 yum-utils..."
    yum install -y yum-utils

    echo "添加 Docker CE 仓库..."
    yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

    echo "更新 yum 软件包索引..."
    yum makecache fast

    echo "安装 Docker CE..."
    yum install -y docker-ce docker-ce-cli containerd.io

    echo "启动 Docker..."
    systemctl start docker
    systemctl enable docker

    echo "查看 Docker 版本..."
    docker version
}

# 安装 Docker Compose
function install_docker_compose() {
    echo "下载 Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    echo "修改 Docker Compose 文件权限..."
    chmod +x /usr/local/bin/docker-compose
}

# 配置 Canal
function setup_canal() {
    echo "拉取 Canal 镜像..."
    docker pull canal/canal-server:latest

    echo "启动 Canal 镜像..."
    docker run --name canal -d canal/canal-server:latest

    echo "创建映射文件目录..."
    mkdir -p /usr/local/canal
    cd /usr/local/canal
    touch canal.properties instance.properties

    echo "复制容器内的配置文件到本地..."
    docker cp canal:/home/admin/canal-server/conf/canal.properties /usr/local/canal/canal.properties
    docker cp canal:/home/admin/canal-server/conf/example/instance.properties /usr/local/canal/instance.properties

    echo "停止并移除 Canal 容器..."
    docker stop canal
    docker rm canal

    # 需要手动调整配置文件
}

# 配置 Nginx 和 HTTPS
function setup_nginx() {
    echo "配置 Nginx 和 HTTPS..."
    mkdir -p /etc/ssl/certs
    # 假设 SSL 证书已经下载到本地并准备上传
    cp /path/to/your/certificate.pem /etc/ssl/certs/
    cp /path/to/your/private.key /etc/ssl/certs/
    # 配置文件应该提前准备好
    mkdir -p /usr/local/nginx
    cp /path/to/your/nginx.conf /usr/local/nginx/nginx.conf
}

# 配置 Kibana
function setup_kibana() {
    echo "配置 Kibana..."
    mkdir -p /usr/local/kibana
    echo "server.host: \"0.0.0.0\"
server.shutdownTimeout: \"5s\"
elasticsearch.hosts: [ \"http://elasticsearch:9200\" ]
elasticsearch.username: \"elastic\"
elasticsearch.password: \"你的密码\"
monitoring.ui.container.elasticsearch.enabled: true" > /usr/local/kibana/kibana.yml
}

# 主函数
function main() {
    install_docker
    install_docker_compose
    setup_canal
    setup_nginx
    setup_kibana
    echo "所有部署步骤完成。"
}

main
