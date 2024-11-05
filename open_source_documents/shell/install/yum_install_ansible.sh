#!/bin/bash

# 检查当前用户是否为 root 用户
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "请以 root 用户运行此脚本。"
        exit 1
    fi
}

# 检查命令是否成功执行
check_command() {
    if [ $? -ne 0 ]; then
        echo "$1 失败，请检查您的网络连接或软件源配置。"
        exit 1
    fi
}

# 安装 EPEL 仓库
install_epel() {
    echo "正在安装 EPEL 仓库..."
    yum install -y epel-release
    check_command "安装 EPEL 仓库"
}

# 安装 Ansible
install_ansible() {
    echo "正在安装 Ansible..."
    yum install -y ansible
    check_command "安装 Ansible"
}

# 检查 Ansible 是否已安装
check_ansible_installed() {
    if command -v ansible > /dev/null; then
        echo "Ansible 已安装，版本信息如下："
        ansible --version
        exit 0
    fi
}

# 主函数
main() {
    check_root
    check_ansible_installed
    install_epel
    install_ansible
    echo "Ansible 安装成功，版本信息如下："
    ansible --version
}

# 执行主函数
main