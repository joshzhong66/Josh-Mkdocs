#!/bin/bash
# command:安装 devpi
# 前置条件
# 1.安装openssl 1.1.1w

# 2.安装python3.9.7
# 在python3编译时，添加openssl库
#  ./configure --prefix=${INSTALL_PATH} --with-openssl=/usr/local/openssl --enable-optimizations >/dev/null 2>&1


# 3.更新pip包
update_pip() {
    python3 -m pip install --upgrade pip
}

# 4.安装devpi服务端
install_devpi() {
    # 安装devpi
    python3 -m pip install devpi-server
    # 验证安装
    pip list | grep devpi
    # 显示版本
    devpi-server --version
    # 初始化数据目录
    devpi-init --serverdir /data/pypi/

    # 配置启动服务
    cat > /usr/lib/systemd/system/devpi.service <<'EOF'
[Unit]
Description=PyPI Server for Sunline
After=network.target

[Service]
Type=simple
User=root
Group=root

PIDFile=/var/run/devpi.pid
ExecStart=/usr/local/python3/bin/devpi-server --host 0.0.0.0 --port 3141 --serverdir /data/pypi     # 注意python路径
ExecStop=/bin/kill -TERM $MAINPID
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

TimeoutStartSec=3
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl start devpi
    systemctl enable devpi
}

# 5.安装配置devpi客户端
# 通过 devpi 客户端工具来配置 devpi 服务器上的索引
init_devpi_client(){
    pip install devpi-client 			# 安装devpi客户端（客户端用于连接devpi服务端）
    devpi use http://127.0.0.1:3141/	# 连接到服务器
    devpi login root --password=''		# 登录使用 root 用户

    # 修改默认镜像索引
    devpi index pypi type=mirror mirror_url=https://mirrors.aliyun.com/pypi/simple/
    mirror_web_url_fmt=https://mirrors.aliyun.com/pypi/simple/{name}/

    # 查看索引信息
    devpi index root/pypi
}


main() {
    update_pip
    install_devpi
    init_devpi_client
}

main